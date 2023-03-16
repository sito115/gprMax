import numpy as np 
from gprMax.input_cmd_funcs import *
from gprMax.exceptions import CmdInputError
import os

def antenna_like_RLFLA(x:float, y:float, z:float, polarisation:str, azimuth:float, inclination:float,
                       resolution:float, timeRemove:float, timeDelay:float = 0, isTx:bool = True, ID:str = 'RLFLA'):
    '''
    Generates a Resistor Loaded Finite Length Antenna (RLFLA) in gprMax.
    based on Sensors and Software crosshole 200 MHz based on PulseEKKO design 
    and Mozzafarri et al 2022.

    x          	    : coordinate of dipole position (+0.26m from left end of antenna)
    y               : coordinate of dipole position 
    z               : coordinate of dipole position 
    polarisation    : polarisation of voltage source ('x', 'y' or 'z')
    azimuth         : degree (assuming that positive x-direction is north)
    inclination     : degree (0 for horizontal, 90 for vertical)
    resolution      : 
    timeDelay       : time delay in starting the source (optional)
    timeRemove      : time to remove the source (optional)
    isTx            : logical, true by default (transmitter antenna)
    identifier      : string
    '''

    # Define geometry size in [m]:

    antennaLength  = 0.60   # total length (originally 1.21m, but cut-off due to performance enhancement)
    radiusAn       = 0.02   # radius antenna

    resistorLength = 0.2     # from feeding point to the left and right (originally 0.24m), cut-off due to performance)
    lengthRes      = 0.01    # length of resistor
    nResistor      = 10      # number of resistors at each side of feeding point

    radiusWire     = 0.01               # radius of wire
    lengthWire     = 0.24
    radiusRes      = radiusWire

    posFeedSource  = 0.26    # from left end of antenna
   
    # Source Frequency and waveform
    centerFreq     = 92e6
    resSrc         = 0

    # old geometries
    hCasing        = 0.01   # thickness of casing
    heightRes      = 0.01
    radiusIns      = 0.01   # radius of insulator

    # Materials
    #change resistor to epsr 20
    material(permittivity=20, conductivity=0.1e-3,
             permeability=1, magconductivity=0, name='resistor' + ID)

    material(permittivity=1, conductivity=0,
            permeability=1, magconductivity=0, name='air' + ID)         

    material(permittivity=4, conductivity=1e-10,
             permeability=1, magconductivity=0, name='insulator' + ID)

    # not used
    material(permeability= 2.35,conductivity= 0,                            
             permittivity= 1,magconductivity= 0, name='plasticCase' + ID)    

    ####################### Geometry

    # Outer Cylinder / Insulator
    cylinder(x1=x-posFeedSource, y1=y, z1=z,
            x2=x+antennaLength-posFeedSource, y2=y, z2=z,
            radius=radiusAn, material='insulator' + ID)
       

    # Resistors spacing
    deltaXRes      = (resistorLength -  lengthRes * nResistor) / nResistor   
    
    # Wire Cylinder
    # cylinder(x1=x-lengthWire, y1=y+radiusAn, z1=z,           # add deltaXRes to y2 due to discetization error with 0.01m
    #          x2=x+lengthWire, y2=y+radiusAn, z2=z,
    #          radius= radiusWire, material='pec')

    edge(xs=x-lengthWire, ys=y, zs=z,           # add deltaXRes to y2 due to discetization error with 0.01m
             xf=x+lengthWire, yf=y, zf=z,
             material='pec')

    # Place resistors
    dx    = (lengthWire - resistorLength) 
    for iRes in range(nResistor):   # from left to center     
        cylinder(x1=x-dx, y1=y, z1=z,               # resistor paralell  to wire
            x2=x-lengthRes-dx ,y2 =y,z2=z,
            radius=radiusRes, material='resistor' + ID)   
               
        dx = dx + deltaXRes + lengthRes

    dx = +(lengthWire - resistorLength)
    for iRes in range(nResistor):   # from center to right
        cylinder(x1=x+dx, y1=y, z1=z,                              # resistor paralell  to wire
            x2=x+lengthRes+dx ,y2 =y ,z2=z,
            radius=radiusRes, material='resistor' + ID)

        dx = dx + deltaXRes + lengthRes

    # Feeding Point 
    edge(xs=x-resolution, ys=y, zs=z,           # add deltaXRes to y2 due to discetization error with 0.01m
         xf=x+resolution, yf=y, zf=z,
            material='air' + ID)


    cylinder(x1=x-resolution, y1=y, z1=z,
             x2=x+resolution, y2=y, z2=z,
             radius=resolution, material='air' + ID)

    
    if isTx:    # Source
        waveformID  = waveform(shape='gaussian', amplitude=1,
                                frequency=centerFreq, identifier='Gaus' + ID)
        tx = voltage_source(polarisation=polarisation, f1=x, f2=y, f3= z, resistance = resSrc,
                            identifier= waveformID, t0=timeDelay, t_remove = timeRemove)

    else:       # Receiver
        rx(x, y, z)