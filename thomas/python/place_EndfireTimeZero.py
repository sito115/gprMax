#python:
import os
import numpy as np 
from generateRLFLAText import antenna_like_RLFLAText

saveFolder  = 'ProcessedFiles'
current_dir = 'C:/OneDrive - Delft University of Technology/3. Semester - Studienunterlagen/Thesis/gprMaxFolder/gprMax'
saveFolder  = os.path.join(current_dir, saveFolder)

###### Parameter
isAntenna   = False              # Test for RLFLA and Dipole
isBorehole  = True              # Is Borehole, else homogeneous environment
nSnaps      = -1               # Number of Snapshots
geomScaling = 1               # Scaling Step Size for GeomView
isSlice     = True                 # True for geometry file to be a slice through the endfire plance [2D], else it is the whole domain [3D]
environ     = 'unsatGravel'       # for borehole ['satGravel', 'unsatGravel']
boreholeEnv = 'airBoreHole'   # for borehole ['waterBoreHole', 'airBoreHole']
extraInf    = '3cm'                # extra information in title
eps_r       = 1                 # Homo environment (isBorehole == 0)

if isBorehole:
    tSim = 1e-7
    # tSim = time_window(2.5 * dYAntenna * np.sqrt(15) /3e8) # Time window is 3x travel distance between TX-RX
else:
    tSim = 6e-8
    # tSim = time_window(3 * dYAntenna * np.sqrt(eps_r) /3e8) # Time window is 3x travel distance between TX-RX

dYAntenna   = 5        # Distance betwenn TX and RX in y direction
resolution  = 0.01      # uniform spatial step 

freq    = 140e6        # for point dipole
nPML    = 30           # number of PML cells


xDimNet = 0.9
yDimNet = 0.6 + dYAntenna
zDimNet = 0.5

xDimAll = xDimNet + 2*nPML*resolution
yDimAll = yDimNet + 2*nPML*resolution
zDimAll = zDimNet + 2*nPML*resolution

 # title string
if isBorehole:
    dirName = 'Dist%.2fm_tSim%.2e_iA%d_iBH%d-%s-%s%s' %(dYAntenna, tSim, isAntenna, isBorehole, environ, boreholeEnv,extraInf)
else:
    dirName = 'PlaceAntennas_Dist%.1fm_tSim%.2e_eps%.2f_iA%d_iBH%d%s' %(dYAntenna, tSim, eps_r, isAntenna, isBorehole,extraInf)

if not(isAntenna):    
    dirName = dirName + '_' + '%d' % (freq/1e6) + 'MHz'


# open
fileName = os.path.join(saveFolder, dirName + '.in')
fid = open(fileName, 'w')


###### END Parameter
fid.write('#dx_dy_dz: %f %f %f\n' %(resolution,resolution,resolution))
fid.write('#domain: %.3f %.3f %.3f\n' %( xDimAll,
                                         yDimAll,
                                         zDimAll))

fid.write('#time_window: %e\n' %(tSim))
fid.write('#pml_cells: %d\n' %(nPML))

antennaPos = (xDimAll/2-0.6/2+0.26, (yDimAll+dYAntenna)/2, zDimAll/2 )  # Scale Placing of RLFLA

# Borehole environment
if isBorehole:

    rBoreHole = 0.03

    fid.write('#material: %.5f %.5f %.5f %.5f %s\n' %(80, 0, 1, 0, 'waterBoreHole'))
    fid.write('#material: %.5f %.5f %.5f %.5f %s\n' %(1, 0, 1, 0, 'airBoreHole'))
    fid.write('#material: %.5f %.5f %.5f %.5f %s\n' %(12.5, 0, 1, 0, 'satGravel'))
    fid.write('#material: %.5f %.5f %.5f %.5f %s\n' %(5, 0, 1, 0, 'unsatGravel'))


    fid.write('#box: %.3f %.3f %.3f %.3f %.3f %.3f %s\n' % (0,0,0,
                                          xDimAll, yDimAll, zDimAll, environ))

 
    # TX
    fid.write('#cylinder: %.3f %.3f %.3f %.3f %.3f %.3f %.3f %s\n' %(0,
                                                       antennaPos[1],
                                                       antennaPos[2],
                                                       xDimAll,
                                                       antennaPos[1],
                                                       antennaPos[2],
                                                       rBoreHole,
                                                       boreholeEnv))

    # RX
    fid.write('#cylinder: %.3f %.3f %.3f %.3f %.3f %.3f %.3f %s\n' %(0,
                                                       antennaPos[1]-dYAntenna,
                                                       antennaPos[2],
                                                       xDimAll,
                                                       antennaPos[1]-dYAntenna,
                                                       antennaPos[2],
                                                       rBoreHole,
                                                       boreholeEnv))


    # title string
    
else: # Homogeneous environment

    fid.write('#material: %.5f %.5f %.5f %.5f %s\n' %(eps_r, 0, 1, 0, 'eps_r' + str(eps_r)))

    fid.write('#box: %.3f %.3f %.3f %.3f %.3f %.3f %s\n' % (0,0,0,
                                          xDimAll, yDimAll, zDimAll, 'eps_r' + str(eps_r)))

   


if isAntenna:   #RLFLA
    antenna_like_RLFLAText(x=antennaPos[0], y=antennaPos[1], z=antennaPos[2], resolution=resolution,
                       polarisation='x',isTx=True, ID='TX', fid=fid)
    
    antenna_like_RLFLAText(x=antennaPos[0], y=antennaPos[1]-dYAntenna, z=antennaPos[2],resolution=resolution,
                       polarisation='x',isTx=False, ID='RX', fid=fid)
else:           #Point Source
    fid.write('#waveform: gaussian %.3f %.3f %s\n' % (1, freq, 'GausDipole'))

    
    fid.write('#box: %.3f %.3f %.3f %.3f %.3f %.3f free_space\n' % (antennaPos[0] - resolution,antennaPos[1] - resolution,antennaPos[2] - resolution,
                                                                    antennaPos[0] + resolution, antennaPos[1] + resolution, antennaPos[2] + resolution))

    fid.write('#box: %.3f %.3f %.3f %.3f %.3f %.3f free_space\n' % (antennaPos[0] - resolution,antennaPos[1] - resolution-dYAntenna,antennaPos[2] - resolution,
                                                                    antennaPos[0] + resolution, antennaPos[1] + resolution -dYAntenna, antennaPos[2] + resolution))

    fid.write('#hertzian_dipole: x %.3f %.3f %.3f %s\n' %(antennaPos[0],antennaPos[1],antennaPos[2],
                                                          'GausDipole'))
    
    fid.write('#rx: %.3f %.3f %.3f\n' %(antennaPos[0],
                                   antennaPos[1]-dYAntenna,
                                   antennaPos[2]))



    

fid.write('#title: %s\n' %(dirName))

# Geometry view
if geomScaling > 0:
    if isSlice: # geometry view through endireplane [2D]
        fid.write('#geometry_view: %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %s n\n' %(
            0,0,antennaPos[2], xDimAll, yDimAll, antennaPos[2] + resolution,
            geomScaling*resolution, geomScaling*resolution, geomScaling*resolution, dirName))
    else: # geometry view through whole domain [3D]
        fid.write('#geometry_view: %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %s n\n' %(
            0,0,0, xDimAll, yDimAll, zDimAll,
            geomScaling*resolution, geomScaling*resolution, geomScaling*resolution, dirName))

# Snapshots
if nSnaps > 0:
    dt = tSim/nSnaps 
    # set dt to 0.5e-9
    name = 'snap' + dirName +  'dt_%.2e_' %(dt)

    if isSlice: # geometry view through endireplane [2D]
        for i in range(1, nSnaps+1):
            fid.write('#snapshot: %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %e %s\n' %(
                        0,0,antennaPos[2], xDimAll, yDimAll, antennaPos[2] + resolution,
                        resolution,resolution,resolution,i*dt, name + str(i) ))
    else: # geometry view through whole domain [3D]
        for i in range(1, nSnaps+1):
            fid.write('#snapshot: %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %e %s\n' %(
                0,0,0, xDimAll, yDimAll, zDimAll,
                resolution,resolution,resolution,i*dt, name + str(i) ))

fid.close()
print(dirName + '.in')
###################
#end_python: