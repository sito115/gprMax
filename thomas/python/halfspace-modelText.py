import os
import numpy as np 
import sys
import io
from generateRLFLAText import antenna_like_RLFLAText

saveFolder  = 'ProcessedFiles'
current_dir = 'C:/OneDrive - Delft University of Technology/3. Semester - Studienunterlagen/Thesis/gprMaxFolder/gprMax'
saveFolder  = os.path.join(current_dir, saveFolder)

# Model Settings
nameIdentifier = ''  # to be included in title and geometry file

isRLFLA     = True   # use RLFLA or point antennae
is3D        = True   # use 3D Model or 2D [1 cell in y direction]
isGradient  = False  # include gradient in model
isSlice     = True  # use 2D slide for movies and geometry through feeding point of Antenna
# Geometry Settings
nSnaps      = 100
isGeometry  = True

# Materials
er_0            = 5     
er_halfspace    = 5
h               = 0.5

#Time
tSim = 1e-7
tSnap = tSim



airSoilInterface  = 2.0    # air - halfspace interface
gradientStart     = airSoilInterface -0.5

# nRX
nRX            = 9
dxRX           = 0.5


# Antenna Position
dx              = 6.0   # [m] TX-RX distance
buffer          = 0.4   # [m] buffer from each side of x-direction
nCellAboveInter = 5     # [m] antennas are placed above air soil interface  




# Antenna Parameters
antLength    = 0.6  # [m]
antFeedPoint = 0.26 # [m] from bottom of antenna
polari       = 'y'  # Polarisation       


# Resolution / Grid Size
resolutionX  = 0.01
resolutionY  = 0.01
resolutionZ  = 0.01


assert gradientStart < airSoilInterface, "Gradient can not be above air soil interface"

freqDipole       = 140e6  # Frequency of point source
nPml             = 20     # number of PML cells from each side of domain 

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
    dirName += '--er0%.1f_h%.1fm' %(er_0, h)
elif er_0 < er_halfspace and isGradient:
    dirName += '++er0%.1f_h%.1fm' %(er_0, h)
else:
    dirName += '00'

if isRLFLA:
    dirName += 'RLFLA'
else:
    dirName += 'InfDip'

# Set Directory and Title name
if nRX > 1:
    dirName += 'nRX%d_dxRX%.2fm' %(nRX, dxRX)
if gradientStart != airSoilInterface:
    dirName += 'Goffset%.1fm' % (airSoilInterface - gradientStart)

dirName += nameIdentifier 


fileName = os.path.join(saveFolder, dirName + '.in')
fid = open(fileName, 'w')

########## Start of Model ##########  
fid.write('#dx_dy_dz: %.2f %.2f %.2f\n' %(resolutionX,resolutionY,resolutionZ))

if is3D:
    fid.write('#domain: %.2f %.2f %.2f\n' %( xDimAll,
                                             yDimAll,
                                             zDimAll))

    TXPos = (nPml*resolutionX + buffer,       0.5*yDimAll-antLength/2+antFeedPoint, airSoilInterface + nCellAboveInter * resolutionZ)
    RXPos = (nPml*resolutionX + buffer + dx,  0.5*yDimAll-antLength/2+antFeedPoint, airSoilInterface + nCellAboveInter * resolutionZ)

    fid.write('#pml_cells: %d\n' %(nPml))
else:
    yDimAll = resolutionY
    fid.write('#domain: %.2f %.2f %.2f\n' %(xDimAll,
                                            yDimAll,
                                            zDimAll))

    TXPos = (nPml*resolutionX + buffer,      0, airSoilInterface + nCellAboveInter * resolutionZ)
    RXPos = (nPml*resolutionX + buffer + dx, 0, airSoilInterface + nCellAboveInter * resolutionZ)

    fid.write('#pml_cells: %d %d %d %d %d %d\n' %(nPml, 0, nPml, nPml, 0, nPml))

# Time & PML cells
fid.write('#time_window: %e\n' %(tSim))


# Halfspace
fid.write('#material: %.5f %.5f %.5f %.5f %s\n' %(er_halfspace, 0, 1, 0, 'half_space'))


# Boxes
fid.write('#box: %.2f %.2f %.2f %.2f %.2f %.2f %s\n' % (0,0,airSoilInterface,
                                          xDimAll, yDimAll, zDimAll, 'free_space'))
fid.write('#box: %.2f %.2f %.2f %.2f %.2f %.2f %s\n' % (0,0,0,
                                          xDimAll, yDimAll, airSoilInterface, 'half_space'))

# Gradient
if isGradient:
    nLayers     = int(np.round(h / resolutionZ) - 1)         # returns the nearest lower integer result
    deltaEr     = (er_halfspace - er_0) / nLayers

    

    for iLayer in range(nLayers):
        fid.write('#material: %.5f %.5f %.5f %.5f %s\n' %(er_0 + iLayer*deltaEr, 0, 1, 0, 'layer' + str(iLayer+1)))

        fid.write('#box: %.2f %.2f %.2f %.2f %.2f %.2f %s\n' %(0,0, gradientStart - (iLayer + 1)*resolutionZ,
                                                xDimAll, yDimAll, gradientStart - iLayer * resolutionZ,
                                                'layer' + str(iLayer+1)))

#### Y-polar
if isRLFLA:
    antenna_like_RLFLAText(x=TXPos[0],y=TXPos[1],z=TXPos[2],            # TX
                    resolution=resolutionY, polarisation=polari,
                    ID='RLFLA-TX', isTx=True, fid=fid)
    
    
    for iRX in range(nRX): # RX
            antenna_like_RLFLAText(x=RXPos[0]-iRX*dxRX,y=RXPos[1],z=RXPos[2],
                resolution=resolutionY, polarisation=polari,
                ID='RLFLARx' + str(iRX), isTx=False, fid=fid)


else:
    fid.write('#waveform: gaussian %.2f %.2f %s\n' % (1, freqDipole, 'GausDipole'))
    fid.write('#hertzian_dipole: %s %.2f %.2f %.2f %s\n' %(polari,TXPos[0],TXPos[1],TXPos[2],
                                                          'GausDipole'))

    for iRX in range(nRX): # RX
        fid.write('#rx: %.2f %.2f %.2f\n' %(RXPos[0]-iRX*dxRX,
                                            RXPos[1],
                                            RXPos[2]))

fid.write('#title: %s\n' %(dirName))

# Geometry
if isGeometry:
    if isSlice:
        fid.write('#geometry_view: %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f %s n\n' %(
                0,TXPos[1],0,xDimAll, TXPos[1]+resolutionY, zDimAll,
                resolutionX, resolutionY, resolutionZ, dirName))

    else:
        fid.write('#geometry_view: %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f %s n\n' %(
                0,0,0,xDimAll, yDimAll, zDimAll,
                resolutionX, resolutionY, resolutionZ, dirName))

# Snapshots
if nSnaps > 0:
    dt = tSnap/nSnaps 
    # set dt to 0.5e-9
    name = dirName + 'dt%.1e_' %(dt)
    if isSlice and is3D:
        for i in range(1, nSnaps+1):
            fid.write('#snapshot: %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f %e %s\n' %(
                        0, RXPos[1], 0, xDimAll, RXPos[1] + resolutionY, zDimAll,  
                        resolutionX,resolutionY,resolutionZ,i*dt, name + str(i) ))
    else:
        for i in range(1, nSnaps+1):
            fid.write('#snapshot: %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f %e %s\n' %(
                        0, 0, 0, xDimAll, yDimAll, zDimAll,  
                        resolutionX,resolutionY,resolutionZ, i*dt, name + str(i) ))

fid.close()
print(fileName)
###################
