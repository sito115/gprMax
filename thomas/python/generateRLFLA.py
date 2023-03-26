import numpy as np 
from gprMax.input_cmd_funcs import *
from gprMax.exceptions import CmdInputError
import os

def antenna_like_RLFLA(x:float, y:float, z:float, polarisation:str, 
                       resolution:float, timeRemove:float, timeDelay:float = 0,
                       isTx:bool = True, ID:str = 'RLFLA'):
    '''
    Generates a Resistor Loaded Finite Length Antenna (RLFLA) in gprMax.
    based on Sensors and Software crosshole 200 MHz based on PulseEKKO design 
    and Mozzafarri et al 2022.
    x          	    : coordinate of dipole position (+0.26m from left end of antenna)
    y               : coordinate of dipole position 
    z               : coordinate of dipole position 
    polarisation    : polarisation of voltage source ('x', 'y' or 'z')
    resolution      : cell size in each direction
    timeDelay       : time delay in starting the source (optional)
    timeRemove      : time to remove the source (optional)
    isTx            : logical, true by default (transmitter antenna)
    identifier      : string
    '''


    geometries = {'antennaLength':0.60, 'resistorLength':0.20, 'lengthRes':0.01, 'lengthWire':0.24,
                  'posFeedSource':0.26, 'cellSize':resolution}


    # Source Frequency and waveform
    radiusAn       = 0.02   # radius antenna
    centerFreq     = 92e6
    resSrc         = 0
    nResistor      = 10      # number of resistors at each side of feeding point
    radiusRes      = 0.01


    Xgeom = {}
    Ygeom = {}
    Zgeom = {}

   # Resistors spacing
    geometries['deltaRes']  = (geometries['resistorLength'] -  geometries['lengthRes'] * nResistor) / nResistor   
    geometries['delta']     = (geometries['lengthWire'] - geometries['resistorLength']) 


    if polarisation == 'x': 
        # Define geometry size in [m]:
        for key,value in geometries.items():
            Xgeom[key] = value   
            Ygeom[key] = 0
            Zgeom[key] = 0
    elif polarisation == 'y': 
        for key, value in geometries.items():
            Xgeom[key] = 0   
            Ygeom[key] = value
            Zgeom[key] = 0
    elif polarisation == 'z':
        for key, value in geometries.items():
            Xgeom[key] = 0   
            Ygeom[key] = 0
            Zgeom[key] = value

    # Materials
    #change resistor to epsr 20
    material(permittivity=20, conductivity=0.1e-3,
             permeability=1, magconductivity=0, name='resistor' + ID)     

    material(permittivity=4, conductivity=1e-10,
             permeability=1, magconductivity=0, name='insulator' + ID)

    # not used
    # material(permeability= 2.35,conductivity= 0,                            
    #          permittivity= 1,magconductivity= 0, name='plasticCase' + ID)    

    ####################### Geometry

    # Outer Cylinder / Insulator
    cylinder(x1=x-Xgeom['posFeedSource'], y1=y-Ygeom['posFeedSource'], z1=z-Zgeom['posFeedSource'],
            x2=x+Xgeom['antennaLength']-Xgeom['posFeedSource'], y2=y+Ygeom['antennaLength']-Ygeom['posFeedSource'],
            z2=z+Zgeom['antennaLength']-Zgeom['posFeedSource'],
            radius=radiusAn, material='insulator' + ID)
       
    #  Wire   
    edge(xs=x-Xgeom['lengthWire'], ys=y-Ygeom['lengthWire'], zs=z-Zgeom['lengthWire'],           # add deltaXRes to y2 due to discetization error with 0.01m
         xf=x+Xgeom['lengthWire'], yf=y+Ygeom['lengthWire'], zf=z+Zgeom['lengthWire'],
         material='pec')

    # Place resistors
    dx = Xgeom['delta']
    dy = Ygeom['delta']
    dz = Zgeom['delta']

    for iRes in range(nResistor):        
        cylinder(x1=x-dx, y1=y-dy, z1=z-dz,               # resistor paralell  to wire, # from left to center
            x2=x-Xgeom['lengthRes']-dx ,y2 =y -Ygeom['lengthRes']-dy,z2=z-Zgeom['lengthRes']-dz,
            radius=radiusRes, material='resistor' + ID)   

        cylinder(x1=x+dx, y1=y+dy, z1=z+dz,               # resistor paralell  to wire # from center to right
            x2=x+Xgeom['lengthRes']+dx ,y2 =y+Ygeom['lengthRes']+dy ,z2=z+Zgeom['lengthRes']+dz,
            radius=radiusRes, material='resistor' + ID)

        dx = dx + Xgeom['deltaRes'] + Xgeom['lengthRes']
        dy = dy + Ygeom['deltaRes'] + Ygeom['lengthRes']
        dz = dz + Zgeom['deltaRes'] + Zgeom['lengthRes']

    # Feeding Point 
    edge(xs=x-Xgeom['cellSize'], ys=y-Ygeom['cellSize'], zs=z-Zgeom['cellSize'],           # add deltaXRes to y2 due to discetization error with 0.01m
         xf=x+Xgeom['cellSize'], yf=y+Ygeom['cellSize'], zf=z+Zgeom['cellSize'],
         material='free_space')

    if isTx:    # Source
        waveformID  = waveform(shape='gaussian', amplitude=1,
                                frequency=centerFreq, identifier='Gaus' + ID)
        tx = voltage_source(polarisation=polarisation, f1=x, f2=y, f3= z, resistance = resSrc,
                            identifier= waveformID) #, t0=timeDelay, t_remove = timeRemove)

    else:       # Receiver
        rx(x, y, z)