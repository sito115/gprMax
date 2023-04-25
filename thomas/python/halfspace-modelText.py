import os
import numpy as np 
import sys
import io
from generateRLFLAText import antenna_like_RLFLAText

saveFolder  = 'ProcessedFiles'
current_dir = 'C:/OneDrive - Delft University of Technology/3. Semester - Studienunterlagen/Thesis/gprMaxFolder/gprMax'
saveFolder  = os.path.join(current_dir, saveFolder)

# Model Settings
nameIdentifier = '100PML'  # to be included in title and geometry file

isRLFLA_TX       = False   # use RLFLA or point antennae
isRLFLA_RX       = False
is3D             = False   # use 3D Model or 2D [1 cell in y direction]
isGradient       = False  # include gradient in model
isSlice          = True  # use 2D slide for movies and geometry through feeding point of Antenna
isBottmReflector = False
# Geometry Settings
nSnaps      = -1
isGeometry  = True

# Materials
er_0                  = 5  
er_halfspace          = 5
h                     = 0.5
er_bottom_reflector   = 20

# geometries
airSoilInterface  = 2.0    # air - halfspace interface
gradientStart     = airSoilInterface
thicknessBottomRef = 0.3   # m

#Time
tSim  = 2e-7
tSnap = tSim

# Antenna Position
dx              = 10.0   # [m] TX-RX distance
buffer          = 0.3   # [m] buffer from each side of x-direction
nCellAboveInter = 3     # [m] antennas are placed above air soil interface  

# nRX
start_RX       = 0.5      # rel. to TX position
dx_RX          = 0.2    # spacing of TX


# Antenna Parameters
antLength    = 0.6  # [m]
antFeedPoint = 0.26 # [m] from bottom of antenna
polari       = 'y'  # Polarisation       


# Resolution / Grid Size
resolutionX  = 0.01
resolutionY  = 0.01
resolutionZ  = 0.01


assert gradientStart <= airSoilInterface, "Gradient can not be above air soil interface"

freqDipole       = 200e6  # Frequency of point source
nPml             = 100     # number of PML cells from each side of domain 



# Domain Geometries
xDimNet = 2*buffer + dx
yDimNet = 1.5
zDimNet = 3.0


xDimAll = xDimNet + 2*nPml*resolutionX
yDimAll = yDimNet + 2*nPml*resolutionY
zDimAll = zDimNet + 2*nPml*resolutionZ


# write FileName
dirName = 'HaSp_dx%.1fm_eps%.1f_' %(dx,er_halfspace)

if er_0 > er_halfspace and isGradient:
    dirName += '--er0_%.1f_h%.1fm' %(er_0, h)
elif er_0 < er_halfspace and isGradient:
    dirName += '++er0_%.1f_h%.1fm' %(er_0, h)
elif airSoilInterface != gradientStart:
    dirName += '00er0_%.1f' %(er_0)
else:
    dirName += '00'

if isRLFLA_TX:
    dirName += 'RLFLA'
else:
    dirName += 'InfDi%dMHz' %(freqDipole/1e6)

if isBottmReflector:
    dirName += '_br_'

# Set Directory and Title name
if gradientStart != airSoilInterface:
    dirName += 'Goffset%.1fm' % (airSoilInterface - gradientStart)

dirName += nameIdentifier 


fileName = os.path.join(saveFolder, dirName + '.in')
fid = open(fileName, 'w')

########## Start of Model ##########  
fid.write('#dx_dy_dz: %.3f %.3f %.3f\n' %(resolutionX,resolutionY,resolutionZ))

thicknessBottomRef  += nPml * resolutionZ
airSoilInterface    += nPml * resolutionZ
gradientStart       += nPml * resolutionZ

if is3D:
    fid.write('#domain: %.3f %.3f %.3f\n' %( xDimAll,
                                             yDimAll,
                                             zDimAll))

    TXPos = (nPml*resolutionX + buffer,       0.5*yDimAll-antLength/2+antFeedPoint, airSoilInterface + nCellAboveInter * resolutionZ)
    RXPos = (nPml*resolutionX + buffer + dx,  0.5*yDimAll-antLength/2+antFeedPoint, airSoilInterface + nCellAboveInter * resolutionZ)

    # PML cells
    fid.write('#pml_cells: %d\n' %(nPml))
else:
    yDimAll = resolutionY
    fid.write('#domain: %.3f %.3f %.3f\n' %(xDimAll,
                                            yDimAll,
                                            zDimAll))

    TXPos = (nPml*resolutionX + buffer,      0, airSoilInterface + nCellAboveInter * resolutionZ)
    RXPos = (nPml*resolutionX + buffer + dx, 0, airSoilInterface + nCellAboveInter * resolutionZ)

    # PML cells
    fid.write('#pml_cells: %d %d %d %d %d %d\n' %(nPml, 0, nPml, nPml, 0, nPml))

# rx-start
rx_x_array     = np.arange(TXPos[0] + start_RX, TXPos[0] + dx + dx_RX, dx_RX)
assert rx_x_array[-1] - nPml*resolutionX < xDimNet, 'RX inside PML'

if len(rx_x_array) > 1:
    dirName += 'nRX%d_dxRX%.2fm' %(len(rx_x_array), dx_RX)

# Time # PML cells
fid.write('#time_window: %e\n' %(tSim))


# Halfspace


fid.write('#material: %.5f %.5f %.5f %.5f %s\n' %(er_halfspace, 0, 1, 0, 'half_space'))


# Boxes
fid.write('#box: %.3f %.3f %.3f %.3f %.3f %.3f %s\n' % (0,0,airSoilInterface,
                                          xDimAll, yDimAll, zDimAll, 'free_space'))
fid.write('#box: %.3f %.3f %.3f %.3f %.3f %.3f %s\n' % (0,0,0,
                                          xDimAll, yDimAll, airSoilInterface, 'half_space'))

if isBottmReflector:
    fid.write('#material: %.5f %.5f %.5f %.5f %s\n' %(er_bottom_reflector, 0, 1, 0, 'bottom_reflector'))
    fid.write('#box: %.3f %.3f %.3f %.3f %.3f %.3f %s\n' % (0,0,0,
                                            xDimAll, yDimAll, thicknessBottomRef, 'bottom_reflector'))

if gradientStart != airSoilInterface:
    fid.write('#material: %.5f %.5f %.5f %.5f %s\n' %(er_0, 0, 1, 0, 'upper_half_space'))

    fid.write('#box: %.3f %.3f %.3f %.3f %.3f %.3f %s\n' % (0,0,gradientStart,
                                          xDimAll, yDimAll, airSoilInterface, 'upper_half_space'))

# Gradient
if isGradient:
    nLayers     = int(np.round(h / resolutionZ) - 1)         # returns the nearest lower integer result
    deltaEr     = (er_halfspace - er_0) / nLayers

    for iLayer in range(nLayers):
        fid.write('#material: %.5f %.5f %.5f %.5f %s\n' %(er_0 + iLayer*deltaEr, 0, 1, 0, 'layer' + str(iLayer+1)))

        fid.write('#box: %.3f %.3f %.3f %.3f %.3f %.3f %s\n' %(0,0, gradientStart - (iLayer + 1)*resolutionZ,
                                                xDimAll, yDimAll, gradientStart - iLayer * resolutionZ,
                                                'layer' + str(iLayer+1)))

#### Y-polar
if isRLFLA_TX:
    antenna_like_RLFLAText(x=TXPos[0],y=TXPos[1],z=TXPos[2],            # TX
                    resolution=resolutionY, polarisation=polari,
                    ID='RLFLA-TX', isTx=True, fid=fid)
    
else:
    
    fid.write('#waveform: ricker %.3f %.3f %s\n' % (1, freqDipole, 'GausDipole'))
    fid.write('#hertzian_dipole: %s %.3f %.3f %.3f %s\n' %(polari,TXPos[0],TXPos[1],TXPos[2],
                                                          'GausDipole'))



if isRLFLA_RX:
    for iRx, xRx in enumerate(rx_x_array): # RX
            antenna_like_RLFLAText(x=xRx,y=RXPos[1],z=RXPos[2],
                resolution=resolutionY, polarisation=polari,
                ID='RLFLARx' + str(iRx), isTx=False, fid=fid)

else:

    for xRx in rx_x_array: # RX
        fid.write('#rx: %.3f %.3f %.3f\n' %(xRx,
                                            RXPos[1],
                                            RXPos[2]))

fid.write('#title: %s\n' %(dirName))

# Geometry
if isGeometry:
    if isSlice:
        fid.write('#geometry_view: %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %s n\n' %(
                0,TXPos[1],0,xDimAll, TXPos[1]+resolutionY, zDimAll,
                resolutionX, resolutionY, resolutionZ, dirName))

    else:
        fid.write('#geometry_view: %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %s n\n' %(
                0,0,0,xDimAll, yDimAll, zDimAll,
                resolutionX, resolutionY, resolutionZ, dirName))

# Snapshots
if nSnaps > 0:
    dt = tSnap/nSnaps 
    # set dt to 0.5e-9
    if isSlice and is3D:
        for i in range(1, nSnaps+1):
            name = 'halfspace' + 'dt%.2e_snap' %(i*dt)
            fid.write('#snapshot: %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %e %s\n' %(
                        0, RXPos[1], 0, xDimAll, RXPos[1] + resolutionY, zDimAll,  
                        resolutionX,resolutionY,resolutionZ,i*dt, name + str(i) ))
    else:
        for i in range(1, nSnaps+1):
            name = 'halfspace' + 'dt%.2e_snap' %(i*dt)
            fid.write('#snapshot: %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %e %s\n' %(
                        0, 0, 0, xDimAll, yDimAll, zDimAll,  
                        resolutionX,resolutionY,resolutionZ, i*dt, name + str(i) ))

fid.close()
print(fileName)
###################
