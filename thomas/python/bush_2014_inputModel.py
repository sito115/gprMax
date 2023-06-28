# Busch, S., van der Kruk, J., & Vereecken, H. (2014).
# Improved Characterization of Fine-Texture Soils Using On-Ground GPR Full-Waveform Inversion.
# IEEE Transactions on Geoscience and Remote Sensing, 52(7), 3947–3958. https://doi.org/10.1109/TGRS.2013.2278297

import numpy as np
import os

# Oututs
isGeometry = True # Write an geometry file
isSlice    = True # True:Geometry is a slice in the receiver plane, False: 3D Geometry File
nSnaps     = 100

# Check default folder existence, if not use wd
saveFolder  = 'ProcessedFiles'
current_dir = 'C:/OneDrive - Delft University of Technology/3. Semester - Studienunterlagen/Thesis/gprMaxFolder/gprMax'
saveFolder  = os.path.join(current_dir, saveFolder)
if not os.path.exists(saveFolder):
    print('The given folder %s does not exist\n' %(saveFolder))
    saveFolder = os.getcwd()
    print('The file will be saved in the pwd folder %s\n' %(saveFolder))


# Parameters
extraInf    = '20PML-small'     # will be added to as suffix to the generated input file

size        = 0.03

warrPos     = 10        # src position for Warr, choose between [10, 30, 40, 50, 80, 90, 100, 110]


ds0Rx       = 0.9         #initial offset to source [m] (table 1 n_x)
maxRxOffset = 1.7        # max receiver offset to source [m] (table 1 n_x)


dsRx        = 0.1       # receiver spacing [m] (table 1)
if dsRx % size != 0:
    dsRx += size - (dsRx % size)
    dsRx = np.round(dsRx, decimals= 4)


tSim        = 70e-9     # figure 2

isRB        = False      # use initial parameters obtained from ray-based or FWI inversion (table 1)
### Geometries #####

cellSize = (size,size,size) # x,y,z
nBufferCells = 15
# the direct ground wave which propagates to a depth of up to ∼30 cm - stated in Introduction of II. METHODOLOGY 
buffer           = nBufferCells*size         # buffer between source and last receiver to start of PML region [m]
hSoil            = 0.4             # thickness of halfspace [m]
hAir             = 0.2 #nBufferCells*size         # thickness of free_space [m]
yDimNet          = 2*nBufferCells*size     # net size of y-Dimension (without PMLs)
nPml             = 20          # number of PML cells from each side of domain 
nCellsAboveInt   = 3           # how many cells between source/receiver and soil-air interface


warrPosAll = np.array([10, 30, 40, 50, 80, 90, 100, 110]) # position of WARR measurement included for inversion (table 1)
# from 0m to 110m in 10m steps
# Note that, due to metal objects at the surface,
# the area between 55 and 85 m is excluded from the calibration of the EMI data.
# 20m is also missing
assert warrPos in warrPosAll, 'warrPos is not available'
idx = np.where(warrPosAll == warrPos) # idx of chosen Warr position
if isRB:
    eps    = np.array([10.6, 10.7, 13.4, 14.9, 16.4, 17.4, 14.2, 16.9])[idx] # permittivity estimates ray-based (table 1)
    sigma  = np.array([5.9, 5.5, 8.0, 6.2, 23.9, 25.9, 28.2, 25.4])[idx]     # conductivity estimates ray-based (table 1)
else:
    eps   = np.array([12.2, 8.1, 14.4, 14.9, 18.0, 17.6, 17.3, 18.5])[idx]  # permittivity estimates FWI (table 1)
    sigma = np.array([2.4, 6.1, 6.3, 9.8, 17.7, 22.9, 28.5, 27.7])[idx]  # conductivity estimates FWI (table 1)

sigma = sigma * 1e-3

# Center Frequencies from Figure 9 in MHz
centerFreqs = np.array([115.0000,  111.8000,  110.2000,  108.6000,  103.8000,  102.2000,  100.6000,   99.0000])
freqDipole  = centerFreqs[idx]*1e6   # Frequency of point source

# Domain Geometries
xDimNet = 2*buffer + maxRxOffset
zDimNet = hAir + hSoil

xDimAll = xDimNet + 2*nPml*cellSize[0]
yDimAll = yDimNet + 2*nPml*cellSize[1]
zDimAll = zDimNet + 2*nPml*cellSize[2]

name = 'Busch2014Warr%dm_isRB%d_maxOff%.2fm%s' %(warrPos, isRB, maxRxOffset,extraInf)
fileName = os.path.join(saveFolder, name + '.in')
fid = open(fileName, 'w')

########################## Start of Model ##########################
fid.write('#dx_dy_dz: %.3f %.3f %.3f\n' %(cellSize[0],cellSize[1],cellSize[2]))

fid.write('#domain: %.3f %.3f %.3f\n' %( xDimAll,
                                            yDimAll,
                                            zDimAll))

fid.write('#pml_cells: %d\n' %(nPml))
fid.write('#time_window: %e\n' %(tSim))


#Material
fid.write('#material: %.5f %.5f %.5f %.5f %s\n' %(eps, sigma, 1, 0, 'half_space'))

# Boxes
fid.write('#box: %.3f %.3f %.3f %.3f %.3f %.3f %s\n' % (0,0,cellSize[2]*nPml + hSoil,
                                          xDimAll, yDimAll, zDimAll, 'free_space'))

fid.write('#box: %.3f %.3f %.3f %.3f %.3f %.3f %s\n' % (0,0,0,
                                          xDimAll, yDimAll, cellSize[2]*nPml + hSoil, 'half_space'))

# Sources
TXPos = np.array([nPml*cellSize[0]+buffer, yDimAll/2, cellSize[2]*(nPml+nCellsAboveInt) + hSoil])
fid.write('#waveform: ricker %.3f %e %s\n' % (1, freqDipole, 'Ricker'))
fid.write('#hertzian_dipole: %s %.3f %.3f %.3f %s\n' %('y',TXPos[0],TXPos[1],TXPos[2],
                                                        'Ricker'))                                          


# Receivers
rx_x_array     = np.arange(TXPos[0] + ds0Rx, TXPos[0] + maxRxOffset + dsRx, dsRx)
assert rx_x_array[-1] - nPml*cellSize[0] < xDimNet, 'RX inside PML'
for xRx in rx_x_array: # RX
    fid.write('#rx: %.3f %.3f %.3f\n' %(xRx,
                                        TXPos[1],
                                        TXPos[2]))

fid.write('#title: %s\n' %(name))

if isGeometry:
    if isSlice: # 2D
        fid.write('#geometry_view: %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %s n\n' %(
                0,TXPos[1],0,xDimAll, TXPos[1]+cellSize[1], zDimAll,
                cellSize[0], cellSize[1], cellSize[2], name))
        
    else:       # 3D
        fid.write('#geometry_view: %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %s n\n' %(
            0,0,0,xDimAll, yDimAll, zDimAll,
            cellSize[0], cellSize[1], cellSize[2], name))
        
if nSnaps > 0:
    fid.write('\n----------Snaps----------\n')
    dt = tSim/nSnaps 
    # set dt to 0.5e-9
    if isSlice:
        for i in range(1, nSnaps+1):
            name = 'halfspace' + 'dt%.2e_snap' %(i*dt)
            fid.write('#snapshot: %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %e %s\n' %(
                        0,TXPos[1],0,xDimAll, TXPos[1]+cellSize[1], zDimAll,  
                         cellSize[0], cellSize[1], cellSize[2],i*dt, name + str(i) ))
    else:
        for i in range(1, nSnaps+1):
            name = 'halfspace' + 'dt%.2e_snap' %(i*dt)
            fid.write('#snapshot: %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %e %s\n' %(
                        0, 0, 0, xDimAll, yDimAll, zDimAll,  
                        cellSize[0], cellSize[1], cellSize[2], i*dt, name + str(i) ))


fid.close()
print('Run successfull!')
print('Input File saved in:')
print(fileName)
