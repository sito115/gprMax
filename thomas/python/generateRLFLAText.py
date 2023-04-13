import numpy as np 
import io

def antenna_like_RLFLAText(x:float, y:float, z:float, polarisation:str, 
                       resolution:float, fid:io.TextIOWrapper, isTx:bool = True, ID:str = 'RLFLA'):
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
    fid             : file object
    '''


    geometries = {'antennaLength'   :0.60,
                  'deltaRes'        :0.01,
                  'lengthRes'       :0.01,
                  'lengthWire'      :0.24,
                  'posFeedSource'   :0.26,
                  'cellSize'        :resolution}


    # Source Frequency and waveform
    radiusAn       = 0.03   # radius antenna
    radiusRes      = 0.02
    centerFreq     = 92e6
    resSrc         = 0       # resistance of voltage -> hard source
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
    fid.write('#material: 4 1e-4  1 0 resistor%s\n' %(ID) )
    fid.write('#material: 4 1e-10 1 0 insulator%s\n' %(ID) )


    ####################### Geometry

    # Outer Cylinder / Insulator       
    fid.write('#cylinder: %f %f %f %f %f %f %f insulator%s\n' %(x-Xgeom['posFeedSource'],
                                                       y-Ygeom['posFeedSource'], 
                                                       z-Zgeom['posFeedSource'],
                                                       x+Xgeom['antennaLength']-Xgeom['posFeedSource'],
                                                       y+Ygeom['antennaLength']-Ygeom['posFeedSource'],
                                                       z+Zgeom['antennaLength']-Zgeom['posFeedSource'],
                                                       radiusAn,
                                                       ID))
    #  Wire   

    # edge(xs=x-Xgeom['cellSize']-Xgeom['lengthWire'], ys=y-Ygeom['cellSize']-Ygeom['lengthWire'], zs=z-Zgeom['cellSize']-Zgeom['lengthWire'],           # add deltaXRes to y2 due to discetization error with 0.01m
    #      xf=x+Xgeom['cellSize']+Xgeom['lengthWire'], yf=y+Ygeom['cellSize']+Ygeom['lengthWire'], zf=z+Zgeom['cellSize']+Zgeom['lengthWire'],
    #      material='pec')

    fid.write('#cylinder: %f %f %f %f %f %f %f pec\n' %(x-Xgeom['lengthWire']-Xgeom['cellSize'],
                                                        y-Ygeom['lengthWire']-Ygeom['cellSize'],
                                                        z-Zgeom['lengthWire']-Zgeom['cellSize'],
                                                        x+Xgeom['lengthWire']+Xgeom['cellSize'],
                                                        y+Ygeom['lengthWire']+Ygeom['cellSize'],
                                                        z+Zgeom['lengthWire']+Zgeom['cellSize'],
                                                        radiusRes))

    # Place resistors
    for iRes in range(nResistor): 


        fid.write('#cylinder: %f %f %f %f %f %f %f resistor%s\n' %(x-Xgeom['cellSize']-Xgeom['lengthWire']+iRes*(Xgeom['deltaRes']+Xgeom['lengthRes']),
                                                                   y-Ygeom['cellSize']-Ygeom['lengthWire']+iRes*(Ygeom['deltaRes']+Ygeom['lengthRes']),
                                                                   z-Zgeom['cellSize']-Zgeom['lengthWire']+iRes*(Zgeom['deltaRes']+Zgeom['lengthRes']),
                                                                   x-Xgeom['cellSize']-Xgeom['lengthWire']+iRes*(Xgeom['deltaRes']+Xgeom['lengthRes'])+Xgeom['lengthRes'],
                                                                   y-Ygeom['cellSize']-Ygeom['lengthWire']+iRes*(Ygeom['deltaRes']+Ygeom['lengthRes'])+Ygeom['lengthRes'],
                                                                   z-Zgeom['cellSize']-Zgeom['lengthWire']+iRes*(Zgeom['deltaRes']+Zgeom['lengthRes'])+Zgeom['lengthRes'],
                                                                   radiusRes,
                                                                   ID))
  
        fid.write('#cylinder: %f %f %f %f %f %f %f resistor%s\n'   %(x+Xgeom['cellSize']+Xgeom['lengthWire']-iRes*(Xgeom['deltaRes']+Xgeom['lengthRes'])-Xgeom['lengthRes'],
                                                                     y+Ygeom['cellSize']+Ygeom['lengthWire']-iRes*(Ygeom['deltaRes']+Ygeom['lengthRes'])-Ygeom['lengthRes'],
                                                                     z+Zgeom['cellSize']+Zgeom['lengthWire']-iRes*(Zgeom['deltaRes']+Zgeom['lengthRes'])-Zgeom['lengthRes'],
                                                                     x+Xgeom['cellSize']+Xgeom['lengthWire']-iRes*(Xgeom['deltaRes']+Xgeom['lengthRes']),
                                                                     y+Ygeom['cellSize']+Ygeom['lengthWire']-iRes*(Ygeom['deltaRes']+Ygeom['lengthRes']),
                                                                     z+Zgeom['cellSize']+Zgeom['lengthWire']-iRes*(Zgeom['deltaRes']+Zgeom['lengthRes']),
                                                                     radiusRes,
                                                                     ID))

        
    # Feeding Point 
    # edge(xs=x-Xgeom['cellSize'], ys=y-Ygeom['cellSize'], zs=z-Zgeom['cellSize'],           # add deltaXRes to y2 due to discetization error with 0.01m
    #      xf=x+Xgeom['cellSize'], yf=y+Ygeom['cellSize'], zf=z+Zgeom['cellSize'],
    #      material='free_space')

    fid.write('#cylinder: %f %f %f %f %f %f %f free_space\n' % (x-Xgeom['cellSize'],
                                                               y-Ygeom['cellSize'],
                                                               z-Zgeom['cellSize'],
                                                               x+Xgeom['cellSize'],
                                                               y+Ygeom['cellSize'],
                                                               z+Zgeom['cellSize'],
                                                               radiusRes))

    if isTx:    # Source
        fid.write('#waveform: gaussian %f %f %s\n' % (1, centerFreq, 'Gaus' + ID))
        fid.write('#voltage_source: %s %f %f %f %f %s\n' %(polarisation,x,y,z,resSrc,'Gaus' + ID))

    else:       # Receiver
        fid.write('#rx: %f %f %f\n' %(x,y,z))
