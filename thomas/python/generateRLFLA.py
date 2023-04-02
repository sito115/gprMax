import numpy as np 
from gprMax.input_cmd_funcs import *
from gprMax.exceptions import CmdInputError
import os

def antenna_like_RLFLA(x:float, y:float, z:float, polarisation:str, 
                       resolution:float, isTx:bool = True, ID:str = 'RLFLA'):
    '''
    Generates a Resistor Loaded Finite Length Antenna (RLFLA) in gprMax.
    based on Sensors and Software crosshole 200 MHz based on PulseEKKO design 
    and Mozzafarri et al 2022.
    https://github.com/amozaffari/CrossholeGPR/blob/master/FWI_build_a_3D_cube_widen_5.m
    x          	    : coordinate of dipole position (+0.26m from left end of antenna)
    y               : coordinate of dipole position 
    z               : coordinate of dipole position 
    polarisation    : polarisation of voltage source ('x', 'y' or 'z')
    resolution      : cell size in each direction
    isTx            : logical, true by default (transmitter antenna)
    ID              : string identifier
    '''


    geometries = {'antennaLength':0.60, 'deltaRes':0.01, 'lengthRes':0.01, 'lengthWire':0.24,
                  'posFeedSource':0.26, 'cellSize':resolution}


    # Source Frequency and waveform
    radiusAn       = 0.02   # radius antenna
    radiusRes      = 0.01
    centerFreq     = 92e6
    resSrc         = 0
    nResistor      = 10      # number of resistors at each side of feeding point
 
    Xgeom = {}
    Ygeom = {}
    Zgeom = {}

    # Define geometry size in [m]:
    if polarisation == 'x': 
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

# A PEC material is used as transmission wire that contained 10 resistor segments with constant
# σ of 0.1 mS/m for each of the two antenna arms. As indicated by the manufacturer (personal communication),
#     this PEC is surrounded by an insulation having εr = 4 and σ = 10−7 mS/m as reported by Lampe and Holliger [91].

    # Materials
    material(permittivity=4, conductivity=1e-4,
             permeability=1, magconductivity=0, name='resistor' + ID)     

    material(permittivity=4, conductivity=1e-10,
             permeability=1, magconductivity=0, name='insulator' + ID)
 

    ####################### Geometry

    # Outer Cylinder / Insulator
    cylinder(x1=x-Xgeom['posFeedSource'], y1=y-Ygeom['posFeedSource'], z1=z-Zgeom['posFeedSource'],
            x2=x+Xgeom['antennaLength']-Xgeom['posFeedSource'], y2=y+Ygeom['antennaLength']-Ygeom['posFeedSource'],
            z2=z+Zgeom['antennaLength']-Zgeom['posFeedSource'],
            radius=radiusAn, material='insulator' + ID)
       
    #  Wire   

    # edge(xs=x-Xgeom['cellSize']-Xgeom['lengthWire'], ys=y-Ygeom['cellSize']-Ygeom['lengthWire'], zs=z-Zgeom['cellSize']-Zgeom['lengthWire'],           # add deltaXRes to y2 due to discetization error with 0.01m
    #      xf=x+Xgeom['cellSize']+Xgeom['lengthWire'], yf=y+Ygeom['cellSize']+Ygeom['lengthWire'], zf=z+Zgeom['cellSize']+Zgeom['lengthWire'],
    #      material='pec')

    cylinder(x1=x-Xgeom['lengthWire']-Xgeom['cellSize'], y1=y-Ygeom['lengthWire']-Ygeom['cellSize'], z1=z-Zgeom['lengthWire']-Zgeom['cellSize'],
             x2=x+Xgeom['lengthWire']+Xgeom['cellSize'], y2=y+Ygeom['lengthWire']+Ygeom['cellSize'], z2=z+Zgeom['lengthWire']+Zgeom['cellSize'],
             radius=radiusRes, material='pec')     

    # Place resistors
    for iRes in range(nResistor):         
        cylinder(x1=x-Xgeom['cellSize']-Xgeom['lengthWire']+iRes*(Xgeom['deltaRes']+Xgeom['lengthRes']), # resistor paralell  to wire, from bottom to center
                 x2=x-Xgeom['cellSize']-Xgeom['lengthWire']+iRes*(Xgeom['deltaRes']+Xgeom['lengthRes'])+Xgeom['lengthRes'],
                 y1=y-Ygeom['cellSize']-Ygeom['lengthWire']+iRes*(Ygeom['deltaRes']+Ygeom['lengthRes']),
                 y2=y-Ygeom['cellSize']-Ygeom['lengthWire']+iRes*(Ygeom['deltaRes']+Ygeom['lengthRes'])+Ygeom['lengthRes'],
                 z1=z-Zgeom['cellSize']-Zgeom['lengthWire']+iRes*(Zgeom['deltaRes']+Zgeom['lengthRes']),               
                 z2=z-Zgeom['cellSize']-Zgeom['lengthWire']+iRes*(Zgeom['deltaRes']+Zgeom['lengthRes'])+Zgeom['lengthRes'], 
                 radius=radiusRes, material='resistor' + ID)   
    # Place resistors
        cylinder(x1=x+Xgeom['cellSize']+Xgeom['lengthWire']-iRes*(Xgeom['deltaRes']+Xgeom['lengthRes'])-Xgeom['lengthRes'], # resistor paralell  to wire # from top to center
                 x2=x+Xgeom['cellSize']+Xgeom['lengthWire']-iRes*(Xgeom['deltaRes']+Xgeom['lengthRes']),
                 y1=y+Ygeom['cellSize']+Ygeom['lengthWire']-iRes*(Ygeom['deltaRes']+Ygeom['lengthRes'])-Ygeom['lengthRes'],               
                 y2=y+Ygeom['cellSize']+Ygeom['lengthWire']-iRes*(Ygeom['deltaRes']+Ygeom['lengthRes']),
                 z1=z+Zgeom['cellSize']+Zgeom['lengthWire']-iRes*(Zgeom['deltaRes']+Zgeom['lengthRes'])-Zgeom['lengthRes'],
                 z2=z+Zgeom['cellSize']+Zgeom['lengthWire']-iRes*(Zgeom['deltaRes']+Zgeom['lengthRes']),
                 radius=radiusRes, material='resistor' + ID)
        
    # Feeding Point 
    # edge(xs=x-Xgeom['cellSize'], ys=y-Ygeom['cellSize'], zs=z-Zgeom['cellSize'],           # add deltaXRes to y2 due to discetization error with 0.01m
    #      xf=x+Xgeom['cellSize'], yf=y+Ygeom['cellSize'], zf=z+Zgeom['cellSize'],
    #      material='free_space')

    cylinder(x1=x-Xgeom['cellSize'], y1=y-Ygeom['cellSize'], z1=z-Zgeom['cellSize'],
             x2=x+Xgeom['cellSize'], y2=y+Ygeom['cellSize'], z2=z+Zgeom['cellSize'],
             radius=radiusRes, material='free_space')  


    if isTx:    # Source
        waveformID  = waveform(shape='gaussian', amplitude=1,
                                frequency=centerFreq, identifier='Gaus' + ID)
        tx = voltage_source(polarisation=polarisation, f1=x, f2=y, f3=z, resistance = resSrc,
                            identifier= waveformID) #, t0=timeDelay, t_remove = timeRemove)

    else:       # Receiver
        rx(x=x, y=y, z=z)