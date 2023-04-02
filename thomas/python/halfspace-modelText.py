import os
import numpy as np 
import sys
import io
from generateRLFLAText import antenna_like_RLFLAText

fid = open('dummy.in', 'w')

# Model Settings
isRLFLA     = True   # use RLFLA or point antennae
is3D        = True   # use 3D Model or 2D [1 cell in y direction]
isGradient  = False  # include gradient in model
isSlice     = True  # use 2D slide for movies and geometry through feeding point of Antenna
# Geometry Settings
nSnaps      = 100
isGeometry  = True

nameIdentifier = ''  # to be included in title and geometry file

# Resolution / Grid Size
resolutionX  = 0.01
resolutionY  = 0.01
resolutionZ  = 0.01

fid.write('#dx_dy_dz: %f %f %f\n' %(resolutionX,resolutionY,resolutionZ))


# Materials
er_0            = 12.5       
er_halfspace    = 5 
h               = 0.5
               
# Antenna Position
dx              = 6.0  # [m] TX-RX distance
buffer          = 0.4 # [m] buffer from each side of x-direction
nCellAboveInter = 2  # [m] antennas are placed above air soil interface  

# nRX
nRX            = 1
dxRX           = 0.2

# Antenna Parameters
antLength    = 0.6  # [m]
antFeedPoint = 0.26 # [m] from bottom of antenna
polari       = 'y'  # Polarisation       


airSoilInterface = 2.0    # air - halfspace interface

freqDipole       = 200e6  # Frequency of point source
nPml             = 20     # number of PML cells from each side of domain 

# Domain Geometries
xDimNet = 2*buffer + dx
yDimNet = 1.5
zDimNet = 3.0

xDimAll = 2*buffer + dx + 2*nPml*resolutionX
yDimAll = 1.5 + 2*nPml*resolutionY
zDimAll = 3.0 + 2*nPml*resolutionZ


########## Start of Model ##########  
if is3D:
    fid.write('#domain: %f %f %f\n' %( xDimAll,
                                       yDimAll,
                                       zDimAll))

    TXPos = (nPml*resolutionX + buffer,       0.5*xDimAll-antLength/2+antFeedPoint, airSoilInterface + nCellAboveInter * resolutionZ)
    RXPos = (nPml*resolutionX + buffer + dx,  0.5*xDimAll-antLength/2+antFeedPoint, airSoilInterface + nCellAboveInter * resolutionZ)

else:
    fid.write('#domain: %f %f %f\n' %(xDimAll,
                                      resolutionY,
                                      zDimAll))

    TXPos = (nPml*resolutionX + buffer,      0, airSoilInterface + nCellAboveInter * resolutionZ)
    RXPos = (nPml*resolutionX + buffer + dx, 0, airSoilInterface + nCellAboveInter * resolutionZ)

# Time & PML cells
tSim = 1e-7
fid.write('#time_window: %e\n' %(tSim))
fid.write('#pml_cells: %d\n' %(nPml))

# Halfspace
fid.write('#material: %f %f %f %f %s\n' %(er_halfspace, 0, 1, 0, 'half_space'))


# Boxes
fid.write('#box: %f %f %f %f %f %f %s\n' % (0,0,airSoilInterface,
                                          xDimAll, yDimAll, zDimAll, 'free_space'))
fid.write('#box: %f %f %f %f %f %f %s\n' % (0,0,0,
                                          xDimAll, yDimAll, airSoilInterface, 'half_space'))

dirName = 'HalfSpace_dx%.1fm_eps_%.1f_i3D%d' %(dx,er_halfspace,is3D)

# Gradient
if isGradient:
    nLayers     = int(np.round(h / resolutionZ) - 1)         # returns the nearest lower integer result
    deltaEr     = (er_halfspace - er_0) / nLayers

    dirName += '_er0_%.1f_h%.1fm' %(er_0, h)

    for iLayer in range(nLayers):
        fid.write('#material: %f %f %f %f %s\n' %(er_0 + iLayer*deltaEr, 0, 1, 0, 'layer' + str(iLayer+1)))

        fid.write('#box: %f %f %f %f %f %f %s\n' %(0,0, airSoilInterface - (iLayer + 1)*resolutionZ,
                                                xDimAll, yDimAll, airSoilInterface - iLayer * resolutionZ,
                                                'layer' + str(iLayer+1)))

    # update names
    if er_0 > er_halfspace:
        dirName += 'Decrease'
    elif er_0 < er_halfspace:
        dirName += 'Increase'
    else:
        dirName += 'NoGrad'

#### Y-polar
if isRLFLA:
    antenna_like_RLFLAText(x=TXPos[0],y=TXPos[1],z=TXPos[2],            # TX
                    resolution=resolutionY, polarisation=polari,
                    ID='RLFLA-TX', isTx=True, fid=fid)
    
    dirName += 'RLFLA'
 
    for iRX in range(nRX): # RX
            antenna_like_RLFLAText(x=RXPos[0]-iRX*dxRX,y=RXPos[1],z=RXPos[2],
                resolution=resolutionY, polarisation=polari,
                ID='RLFLARx' + str(iRX), isTx=False, fid=fid)


else:
    fid.write('#waveform: gaussian %f %f %s\n' % (1, freqDipole, 'GausDipole'))
    fid.write('#hertzian_dipole: %s %f %f %f %s\n' %(polari,TXPos[0],TXPos[1],TXPos[2],
                                                          'GausDipole'))

    for iRX in range(nRX): # RX
        fid.write('rx: %f %f %f\n' %(RXPos[0]-iRX*dxRX,
                                   RXPos[1],
                                   RXPos[2]))

    dirName += 'InfDip'


# Set Directory and Title name
if nRX > 1:
    dirName += 'nRX%d_dxRX%.2fm' %(nRX, dxRX)

dirName += nameIdentifier 
fid.write('#title: %s\n' %(dirName))

# Geometry
if isGeometry:
    if isSlice:
        fid.write('#geometry_view: %f %f %f %f %f %f %f %f %f %s n\n' %(
                0,TXPos[1],0,xDimAll, TXPos[1]+resolutionY, zDimAll,
                resolutionX, resolutionY, resolutionZ, dirName))

    else:
        fid.write('#geometry_view: %f %f %f %f %f %f %f %f %f %s n\n' %(
                0,0,0,xDimAll, yDimAll, zDimAll,
                resolutionX, resolutionY, resolutionZ, dirName))

# Snapshots
if nSnaps > 0:
    dt = tSim/nSnaps 
    # set dt to 0.5e-9
    name = 'snap' + dirName + 'dt_%.2e_' %(dt)
    if isSlice:
        for i in range(1, nSnaps+1):
            fid.write('#snapshot: %f %f %f %f %f %f %f %f %f %f %s' %(
                        0, RXPos[1], 0, xDimAll, RXPos[1] + resolutionY, zDimAll,  i*dt,
                        resolutionX,resolutionY,resolutionZ, name + str(i) ))
    else:
        for i in range(1, nSnaps+1):
            fid.write('#snapshot: %f %f %f %f %f %f %f %f %f %f %s' %(
                        0, 0, 0, xDimAll, yDimAll, zDimAll,  i*dt,
                        resolutionX,resolutionY,resolutionZ, name + str(i) ))

fid.close()
os.rename('dummy.in', )

###################
#end_python: