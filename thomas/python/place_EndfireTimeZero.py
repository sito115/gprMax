#python:
import os
import numpy as np 
from generateRLFLAText import antenna_like_RLFLAText

saveFolder  = 'ProcessedFiles/21_BoreHolesEndFire'
current_dir = 'C:/OneDrive - Delft University of Technology/3. Semester - Studienunterlagen/Thesis/gprMaxFolder/gprMax'
saveFolder  = os.path.join(current_dir, saveFolder)

###### Parameter
isRLFLA_TX   = True              # Test for RLFLA and Dipole
isRLFLA_RX   = True
isBorehole  = True              # Is Borehole, else homogeneous environment
nSnaps      = 100               # Number of Snapshots, negative for no snap
geomScaling = 1               # Scaling Step Size for GeomView
isSlice     = True                 # True for geometry file to be a slice through the endfire plance [2D], else it is the whole domain [3D]
environ     = 'satGravel'       # for borehole ['satGravel', 'unsatGravel']
boreholeEnv = 'airBoreHole'   # for borehole ['waterBoreHole', 'airBoreHole']
extraInf    = '0.5cmRes'                # extra information in title
eps_r       = 1             # Homo environment (isBorehole == 0)
angle       = 45

conductivity = 1e-4
tSim      = 1.25e-7
tSimSnap  = 0.5*tSim
rBoreHole = 0.05

amplitude = 1
    
    # tSim = time_window(2.5 * dYAntenna * np.sqrt(15) /3e8) # Time window is 3x travel distance between TX-RX

       
    # tSim = time_window(3 * dYAntenna * np.sqrt(eps_r) /3e8) # Time window is 3x travel distance between TX-RX

dXAntenna   = 5                                    # Distance betwenn TX and RX in y direction
dZAntenna   = np.tan(angle*np.pi/180)*dXAntenna

resolution  = 0.005      # uniform spatial step 0.005 for water, else 0.01

freq    = 140e6        # for point dipole
nPML    = 70           # number of PML cells

nbufferCells = 40


xDimNet = (nbufferCells*resolution + rBoreHole)*2  + dXAntenna
yDimNet = (nbufferCells*resolution + rBoreHole)*2 
zDimNet = (nbufferCells*resolution)*2 + 1.2 + dZAntenna

xDimAll = xDimNet + 2*nPML*resolution
yDimAll = yDimNet + 2*nPML*resolution
zDimAll = zDimNet + 2*nPML*resolution


 # title string
if isBorehole:
    dirName = 'Dist%.2fm_tSim%.2e_iA%d_iBH%d-%s-%sr%.2fm_a%d%s' %(dXAntenna, tSim, isRLFLA_TX, isBorehole, environ, boreholeEnv,rBoreHole,angle,extraInf)
else:
    dirName = 'Dist%.2fm_tSim%.2e_iA%d_iBH%d-epsr%.2fm_a%d%s' %(dXAntenna, tSim, isRLFLA_TX, isBorehole, eps_r,angle,extraInf)

dirName += 'iRX%d' %(isRLFLA_RX) 

if not(isRLFLA_TX):    
    dirName = dirName + '_' + '%d' % (freq/1e6) + 'MHz'


# open
fileName = os.path.join(saveFolder, dirName + '.in')
fid = open(fileName, 'w')


###### END Parameter
fid.write('#domain: %.3f %.3f %.3f\n' %( xDimAll,
                                         yDimAll,
                                         zDimAll))

fid.write('#dx_dy_dz: %f %f %f\n' %(resolution,resolution,resolution))


fid.write('#time_window: %e\n' %(tSim))

antennaPos = [(nbufferCells+nPML)*resolution+rBoreHole,
             yDimAll/2 ,
             zDimAll-(nbufferCells+nPML)*resolution - 0.6]  # Scale Placing of RLFLA



fid.write('#pml_cells: %d\n' %(nPML))



# Borehole environment
if isBorehole:

    fid.write('#material: %.5f %.5f %.5f %.5f %s\n' %(80, conductivity, 1, 0, 'waterBoreHole'))
    fid.write('#material: %.5f %.5f %.5f %.5f %s\n' %(1, conductivity, 1, 0, 'airBoreHole'))
    fid.write('#material: %.5f %.5f %.5f %.5f %s\n' %(12.5, conductivity, 1, 0, 'satGravel'))
    fid.write('#material: %.5f %.5f %.5f %.5f %s\n' %(5, conductivity, 1, 0, 'unsatGravel'))


    fid.write('#box: %.3f %.3f %.3f %.3f %.3f %.3f %s\n' % (0,0,0,
                                          xDimAll, yDimAll, zDimAll, environ))

 
    # TX
    fid.write('#cylinder: %.3f %.3f %.3f %.3f %.3f %.3f %.3f %s\n' %(antennaPos[0],
                                                                     antennaPos[1],
                                                                     0,
                                                                     antennaPos[0],
                                                                     antennaPos[1],
                                                                     zDimAll,
                                                                     rBoreHole,
                                                                     boreholeEnv))

    # RX
    fid.write('#cylinder: %.3f %.3f %.3f %.3f %.3f %.3f %.3f %s\n' %(antennaPos[0]+dXAntenna,
                                                                     antennaPos[1],
                                                                     0,
                                                                     antennaPos[0]+dXAntenna,
                                                                     antennaPos[1],
                                                                     zDimAll,
                                                                     rBoreHole,
                                                                     boreholeEnv))


    # title string
    
else: # Homogeneous environment

    fid.write('#material: %.5f %.5f %.5f %.5f %s\n' %(eps_r, conductivity, 1, 0, 'eps_r' + str(eps_r)))

    fid.write('#box: %.3f %.3f %.3f %.3f %.3f %.3f %s\n' % (0,0,0,
                                          xDimAll, yDimAll, zDimAll, 'eps_r' + str(eps_r)))

   


if isRLFLA_TX:   #RLFLA
    antenna_like_RLFLAText(x=antennaPos[0], y=antennaPos[1], z=antennaPos[2], resolution=resolution,
                       polarisation='z',isTx=True, ID='TX', fid=fid,amplitude=amplitude)
    
else:

    fid.write('#waveform: gaussiandot %.2f %e %s\n' % (1, freq, 'GausDotDipole'))

    
    # fid.write('#box: %.3f %.3f %.3f %.3f %.3f %.3f free_space\n' % (antennaPos[0] - resolution,antennaPos[1] - resolution,antennaPos[2] - resolution,
    #                                                                 antennaPos[0] + resolution, antennaPos[1] + resolution, antennaPos[2] + resolution))

    # fid.write('#box: %.3f %.3f %.3f %.3f %.3f %.3f free_space\n' % (antennaPos[0] - resolution+dXAntenna, antennaPos[1] - resolution, antennaPos[2] - resolution - dZAntenna,
    #                                                                 antennaPos[0] + resolution+dXAntenna, antennaPos[1] + resolution, antennaPos[2] + resolution - dZAntenna))

    fid.write('#hertzian_dipole: z %.3f %.3f %.3f %s\n' %(antennaPos[0],antennaPos[1],antennaPos[2],
                                                          'GausDotDipole'))

    

if  isRLFLA_RX:       #Point Source

    antenna_like_RLFLAText(x=antennaPos[0]+dXAntenna, y=antennaPos[1], z=antennaPos[2]-dZAntenna,resolution=resolution,
                       polarisation='z',isTx=False, ID='RX', fid=fid)
    
else:

    fid.write('#rx: %.3f %.3f %.3f\n' %(antennaPos[0] + dXAntenna,
                                        antennaPos[1],
                                        antennaPos[2] - dZAntenna))

fid.write('#title: %s\n' %(dirName))

# Geometry view
if geomScaling > 0:
    if isSlice: # geometry view through endireplane [2D]
        fid.write('#geometry_view: %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %s n\n' %(
            0,antennaPos[1],0, xDimAll, antennaPos[1] + resolution, zDimAll,
            geomScaling*resolution, geomScaling*resolution, geomScaling*resolution, dirName))
    else: # geometry view through whole domain [3D]
        fid.write('#geometry_view: %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %s n\n' %(
             0,0,0, xDimAll, yDimAll, zDimAll,
            geomScaling*resolution, geomScaling*resolution, geomScaling*resolution, dirName))

# Snapshots
if nSnaps > 0:
    dt = tSimSnap/nSnaps 
    # set dt to 0.5e-9
    name = 'snap' + 'dt_%.2e_' %(dt)
    if isSlice: # geometry view through endireplane [2D]
        for i in range(1, nSnaps+1):
            fid.write('#snapshot: %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %e %s\n' %(
                         0,antennaPos[1],0, xDimAll, antennaPos[1] + resolution, zDimAll,
                        resolution,resolution,resolution,i*dt, name + str(i) ))
    else: # geometry view through whole domain [3D]
        for i in range(1, nSnaps+1):
            fid.write('#snapshot: %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %e %s\n' %(
                0,0,0, xDimAll, yDimAll, zDimAll,
                resolution,resolution,resolution,i*dt, name + str(i) ))

fid.close()
print('Run sucessfull')
print(os.path.join(saveFolder,dirName + '.in'))
###################
#end_python: