import numpy as np 
from gprMax.input_cmd_funcs import *
from gprMax.exceptions import CmdInputError


def antenna_like_RLFLA(x:float, y:float, z:float, polarisation:str, azimuth:float, inclination:float,
                       timeDelay:float = 0, timeRemove = np.inf):
    '''
    Generates a Resistor Loaded Finite Length Antenna (RLFLA) in gprMax.
    based on Sensors and Software crosshole 200 MHz based on PulseEKKO design 
    and Mozzafarri et al 2022.

    x          	    : coordinate of dipole position (+0.26m from left end)
    y               : coordinate of dipole position (projection to bottom)
    z               : coordinate of dipole position (projection to bottom)
    polarisation    : polarisation of voltage source ('x', 'y' or 'z')
    azimuth         : degree (assuming that positive x-direction is north)
    inclination     : degree (0 for horizontal, 90 for vertical)
    timeDelay       : time delay in starting the source (optional)
    timeRemove      : time to remove the source (optional)
    '''

    # Define geometry size in [m]:

    antennaLength  = 1.21   # total length
    radiusAn       = 0.02   # radius antenna
    hCasing        = 0.01  # thickness of casing

    resistorLength = 0.24    # from feeding point to the left and right
    radiusRes      = 0.005   # radius of resistor
    heightRes      = 0.02    # height of resistor
    nResistor      = 10      # number of resistors at each side of feeding point

    radiusIns      = 0.01    # radius of insulator
    radiusWire     = 0.005   # radius of wire

    heightFeedVoid = 0.01    # box is placed around source position with 1cm edges

    posFeedSource  = 0.26    # from left end of antenna
   
    # Source Frequency and waveform
    centerFreq     = 92e6
    waveformID     = waveform('gaussiandotnorm ', amplitude=1, frequency=centerFreq, identifier='GausDotNorm')

    # Materials
    material(permittivity=4, conductivity=0.1e-3,
             permeability=1, magconductivity=0, name='resistor')

    material(permittivity=4, conductivity=1e-7,
             permeability=1, magconductivity=0, name='insulator')

    material(permeability= 2.35,conductivity= 0,
             permittivity= 1,magconductivity= 0, name='plasticCase')    

    ####################### Geometry

    # Outer Cylinder / Insulator
    cylinder(x1=x-posFeedSource, y1=y+radiusAn, z1=z,
            x2=x+antennaLength-posFeedSource, y2=y+radiusAn, z2=z,
            radius=radiusAn, material='insulator')

#     #Filled with Air
#     cylinder(x1=x-posFeedSource+hCasing, y1=y+radiusAn, z1=z,
#             x2=x+antennaLength-posFeedSource-hCasing, y2=y+radiusAn, z2=z,
#             radius=radiusAn-hCasing, material='free_space')
#     #Insulator
#     cylinder(x1=x-resistorLength-radiusIns, y1=y+radiusAn, z1=z,
#             x2=x+resistorLength+radiusIns, y2=y+radiusAn, z2=z,
#             radius=radiusIns, material='insulator')     
#     # Wire
#     edge(xs=x-resistorLength, ys=y+radiusAn, zs=z,
#          xf=x+resistorLength, yf=y+radiusAn, zf=z, material='pec')

    # Wire Cylinder
    cylinder(x1=x-resistorLength, y1=y+radiusAn, z1=z,
             x2=x+resistorLength, y2=y+radiusAn, z2=z, radius= radiusWire, material='pec')

    # Resistors
    lengthFeedVoid = heightFeedVoid/2 
    deltaXRes      = (resistorLength -  2*radiusRes * nResistor) / nResistor   
    dx             = radiusRes

    for iRes in range(nResistor):   # from left to center
        cylinder(x1=x-resistorLength+dx, y1=y+radiusAn-heightRes/2, z1=z,
                 x2=x-resistorLength+dx ,y2 =y+radiusAn+heightRes/2 ,z2=z,
                 radius=radiusRes, material='resistor')         
        dx = dx + deltaXRes + 2*radiusRes

    dx = deltaXRes + lengthFeedVoid + radiusRes
    for iRes in range(nResistor):   # from center to right
        cylinder(x1=x+dx, y1=y+radiusAn-heightRes/2, z1=z,
                 x2=x+dx ,y2 =y+radiusAn+heightRes/2 ,z2=z,
                 radius=radiusRes, material='resistor') 
        dx = dx + deltaXRes + 2*radiusRes

    # Antenna feeding point void:   
    box(xs=x-lengthFeedVoid, ys=y+radiusAn-lengthFeedVoid, zs=z-lengthFeedVoid,
        xf=x+lengthFeedVoid, yf=y+radiusAn+lengthFeedVoid, zf=z+lengthFeedVoid,
        material='free_space')    

    # Source
    tx             = voltage_source(polarisation, x, y + radiusAn, z, 0, waveformID,
                                    timeDelay, timeRemove)