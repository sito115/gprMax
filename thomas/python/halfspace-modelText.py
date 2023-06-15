import os
import numpy as np 
from generateRLFLAText import antenna_like_RLFLAText # @johannes: not important for now

# Check default folder existence, if not use wd
saveFolder  = 'ProcessedFiles'
current_dir = 'C:/OneDrive - Delft University of Technology/3. Semester - Studienunterlagen/Thesis/gprMaxFolder/gprMax'
saveFolder  = os.path.join(current_dir, saveFolder)
if not os.path.exists(saveFolder):
    print('The given folder %s does not exist\n' %(saveFolder))
    saveFolder = os.getcwd()
    print('The file will be saved in the pwd folder %s\n' %(saveFolder))

# Model Settings
nameIdentifier = '300PML'  # to be included in title and geometry file (optional)

isRLFLA_TX        = False    # use RLFLA or point antennae
isRLFLA_RX        = False   # use RLFLA or point antennae
is3D              = False    # use 3D Model or 2D [1 cell in y direction]
isGradient        = False   # include gradient in model
isVDK5Gradient    = False   # gradient from page 186 thesis jan van der kruk (2001)
isVDK10Gradient   = False   # gradient from page 186 thesis jan van der kruk (2001)
isSlice           = True    # use 2D slide for movies and geometry through feeding point of Antenna
isBottomReflector = False   # include a bottem reflecotr in model
conductivity      = 0.00   # S/m
# Geometry Settings
nSnaps      = -1        # negative if no animation is created
isGeometry  = False     # create geometry file, true false

# Materials
er_0                  = 5    # permittivity at start defined by 'gradientStart'

er_halfspace          = 5    # permittivity of lower halfspace

h                     = 0.5   # thickness of gradient
er_bottom_reflector   = 20    # permittivity of bottom reflector if included

# geometries
airSoilInterface  = 0.9   # air - halfspace interface
gradientStart     = airSoilInterface   # can be used to let the gradient start under the surface
                                      # this will include an upper halfpspace with er_0 in the model
thicknessBottomRef = 0.3   # m, thickness of bottom reflector

#Time
tSim  = 1e-7     # time window simulation
tSnap = tSim     # time window for animation to save


# Resolution / Grid Size
resolutionX  = 0.01
resolutionY  = 0.01
resolutionZ  = 0.01

# Antenna Position
dx              = 6                 # [m] TX-RX distance
buffer          = 20* resolutionX   #(20) [m] buffer from each side of x-direction
nCellAboveInter = 5                 # [m] antennas are placed n cells above air soil interface  
start_RX        = 1.0               # [m] rel. to TX position (start offset)
dx_RX           = 0.2               # [m] spacing of TX

# Antenna Parameters
antLength    = 0.6  # [m]
antFeedPoint = 0.26 # [m] from bottom of antenna
polari       = 'y'  # Polarisation       

# Domain Geometries
xDimNet = 2*buffer + dx
if is3D and (isRLFLA_TX or isRLFLA_RX):
    yDimNet = antLength + 2*15*resolutionY
else:
    yDimNet = 2*buffer

zDimNet = airSoilInterface + 25*resolutionZ

# only for van der Kruk Gradient
if isVDK10Gradient or isVDK5Gradient:
    er_halfspace     = 4.1*isVDK5Gradient + 3.9*isVDK10Gradient
    airSoilInterface = gradientStart = 1.0

assert gradientStart <= airSoilInterface, "Gradient can not be above air soil interface"

freqDipole       = 200e6   # Frequency of point source
nPml             = 300     # 20 number of PML cells from each side of domain 

############################ Start of Model ############################  

# calculate gross geoemtries adding pml layers
xDimAll = xDimNet + 2*nPml*resolutionX
yDimAll = yDimNet + 2*nPml*resolutionY
zDimAll = zDimNet + 2*nPml*resolutionZ

# write FileName
dirName = 'HaSp_dx%.1fm_eps%.1f_' %(dx,er_halfspace)

if er_0 > er_halfspace and isGradient:
    dirName += '--er0_%.1f_h%.2fm' %(er_0, h)
elif er_0 < er_halfspace and isGradient:
    dirName += '++er0_%.1f_h%.2fm' %(er_0, h)
elif airSoilInterface != gradientStart:
    dirName += '00er0_%.1f' %(er_0)
elif isVDK5Gradient or isVDK10Gradient:
    dirName += 'VDK%d' %(5*isVDK5Gradient+10*isVDK10Gradient)
else:
    dirName += '00'

if isRLFLA_TX:
    dirName += 'RLFLA'
else:
    dirName += 'InfDi%dMHz' %(freqDipole/1e6)

if isBottomReflector:
    dirName += '_br_'

# Set Directory and Title name
if gradientStart != airSoilInterface:
    dirName += 'Goffset%.2fm' % (airSoilInterface - gradientStart)
if start_RX != dx:
    dirName += 'RX0_%.1fm_dxRX%.2fm' %(start_RX, dx_RX)

if isRLFLA_RX:
    dirName += 'RX-RLA'

if is3D:
    dirName += '3D'

dirName += nameIdentifier 


fileName = os.path.join(saveFolder, dirName + '.in')
fid = open(fileName, 'w')
fid.write('----------Metadata----------\n')
fid.write('#dx_dy_dz: %.3f %.3f %.3f\n' %(resolutionX,resolutionY,resolutionZ))

thicknessBottomRef  += nPml * resolutionZ
airSoilInterface    += nPml * resolutionZ
gradientStart       += nPml * resolutionZ

if is3D:
    fid.write('#domain: %.3f %.3f %.3f\n' %( xDimAll,
                                             yDimAll,
                                             zDimAll))
    if isRLFLA_TX: # voltage source is not in the center of the RLFLA
        TXPos = (nPml*resolutionX + buffer,       0.5*yDimAll-antLength/2+antFeedPoint, airSoilInterface + nCellAboveInter * resolutionZ)
    else:
        TXPos = (nPml*resolutionX + buffer,       0.5*yDimAll, airSoilInterface + nCellAboveInter * resolutionZ)

    if isRLFLA_RX: # receiver is not in the center of the RLFLA
        RXPos = (nPml*resolutionX + buffer + dx,  0.5*yDimAll-antLength/2+antFeedPoint, airSoilInterface + nCellAboveInter * resolutionZ)
    else:
        RXPos = (nPml*resolutionX + buffer + dx,  0.5*yDimAll, airSoilInterface + nCellAboveInter * resolutionZ)

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
rx_x_array     = np.arange(TXPos[0] + start_RX, TXPos[0] + dx, dx_RX)
assert rx_x_array[-1] - nPml*resolutionX < xDimNet, 'RX inside PML'

# Time # PML cells
fid.write('#time_window: %e\n' %(tSim))


# Halfspace

fid.write('\n----------Materials and Geometries----------\n')
fid.write('#material: %.5f %.5f %.5f %.5f %s\n' %(er_halfspace, conductivity, 1, 0, 'half_space'))


# Boxes
fid.write('#box: %.3f %.3f %.3f %.3f %.3f %.3f %s\n' % (0,0,airSoilInterface,
                                          xDimAll, yDimAll, zDimAll, 'free_space'))
fid.write('#box: %.3f %.3f %.3f %.3f %.3f %.3f %s\n' % (0,0,0,
                                          xDimAll, yDimAll, airSoilInterface, 'half_space'))

if isBottomReflector:
    fid.write('#material: %.5f %.5f %.5f %.5f %s\n' %(er_bottom_reflector, conductivity, 1, 0, 'bottom_reflector'))
    fid.write('#box: %.3f %.3f %.3f %.3f %.3f %.3f %s\n' % (0,0,0,
                                            xDimAll, yDimAll, thicknessBottomRef, 'bottom_reflector'))

if gradientStart != airSoilInterface:
    fid.write('#material: %.5f %.5f %.5f %.5f %s\n' %(er_0, conductivity, 1, 0, 'upper_half_space'))

    fid.write('#box: %.3f %.3f %.3f %.3f %.3f %.3f %s\n' % (0,0,gradientStart,
                                          xDimAll, yDimAll, airSoilInterface, 'upper_half_space'))

# Gradient
if isGradient:
    fid.write('\n\t----------Gradient----------\n')
    nLayers     = int(np.round(h / resolutionZ))         # returns the nearest lower integer result
    deltaEr     = (er_halfspace - er_0) / nLayers

    for iLayer in range(nLayers):
        fid.write('#material: %.5f %.5f %.5f %.5f %s\n' %(er_0 + iLayer*deltaEr, conductivity, 1, 0, 'layer' + str(iLayer+1)))

        fid.write('#box: %.3f %.3f %.3f %.3f %.3f %.3f %s\n' %(0,0, gradientStart - (iLayer + 1)*resolutionZ,
                                                xDimAll, yDimAll, gradientStart - iLayer * resolutionZ,
                                                'layer' + str(iLayer+1)))


if isVDK5Gradient or isVDK10Gradient:
    h = 0.5
    zMeasured = np.arange(0,0.5025,0.025)

    if isVDK5Gradient:
        epsMeasured = np.array([2.9,2.9, 3.4, 3.75, 4.2,   # <= 0.1m
                    3.9, 4.1, 4.2, 4.4,    # <= 0.2m
                    4.8, 4.1, 4.05, 4.0,   # <= 0.3m
                    4.25, 4.22, 4.2, 4.,   # <= 0.4m
                    4.05, 4.1, 4.15, 4.1])  # <= 0.5m
    elif isVDK10Gradient:
        epsMeasured = np.array([3.4, 3.4, 3.6, 3.9, 4.7,    # <= 0.1m
                4.1, 4.2, 4.25, 4.25,    # <= 0.2m
                4.35, 4.2, 4.1, 4.1,   # <= 0.3m
                4.25, 4.2, 4.2, 4.0,   # <= 0.4m
                3.9, 4.1, 3.9, 3.9])  # <= 0.5m
    
    zModel   = np.arange(0,h+resolutionZ,resolutionZ)
    epsModel =  np.interp(zModel, zMeasured, epsMeasured, left=None, right=None)
    assert len(zModel) == len(epsModel)
    nLayers  = len(epsModel)
    for iLayer in range(nLayers):
        fid.write('#material: %.5f %.5f %.5f %.5f %s\n' %(epsModel[iLayer], conductivity, 1, 0, 'layer' + str(iLayer+1)))

        fid.write('#box: %.3f %.3f %.3f %.3f %.3f %.3f %s\n' %(0,0, gradientStart - (iLayer + 1)*resolutionZ,
                                        xDimAll, yDimAll, gradientStart - iLayer * resolutionZ,
                                        'layer' + str(iLayer+1)))
fid.write('\n----------Sources----------\n')
#### Y-polar
if isRLFLA_TX:
    antenna_like_RLFLAText(x=TXPos[0],y=TXPos[1],z=TXPos[2],            # TX
                    resolution=resolutionY, polarisation=polari,
                    ID='RLFLA-TX', isTx=True, fid=fid)
    
else:
    
    fid.write('#waveform: ricker %.3f %e %s\n' % (1, freqDipole, 'GausDipole'))
    fid.write('#hertzian_dipole: %s %.3f %.3f %.3f %s\n' %(polari,TXPos[0],TXPos[1],TXPos[2],
                                                          'GausDipole'))


fid.write('\n----------Receivers----------\n')
if isRLFLA_RX:
    for iRx, xRx in enumerate(rx_x_array): # RX
            antenna_like_RLFLAText(x=xRx,y=RXPos[1],z=RXPos[2],
                resolution=resolutionY, polarisation=polari,
                ID='RLFLARX' + str(iRx), isTx=False, fid=fid)

else:

    for xRx in rx_x_array: # RX
        fid.write('#rx: %.3f %.3f %.3f\n' %(xRx,
                                            RXPos[1],
                                            RXPos[2]))

fid.write('\n----------Title (FileName)----------\n')
fid.write('#title: %s\n' %(dirName))

# Geometry
if isGeometry:
    fid.write('\n----------Geometry----------\n')
    if isSlice: #2D
        fid.write('#geometry_view: %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %s n\n' %(
                0,TXPos[1],0,xDimAll, TXPos[1]+resolutionY, zDimAll,
                resolutionX, resolutionY, resolutionZ, dirName))

    else:       #3D
        fid.write('#geometry_view: %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %.3f %s n\n' %(
                0,0,0,xDimAll, yDimAll, zDimAll,
                resolutionX, resolutionY, resolutionZ, dirName))

# Snapshots
if nSnaps > 0:
    fid.write('\n----------Snaps----------\n')
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


##PLOT
# fig, ax = plt.subplots()

# # Plot the data with a dotted line
# ax.plot(epsMeasured,zMeasured, 'go', label='Measurement points')
# ax.plot(epsModel,zModel, linestyle='dotted', label='Interpolation')
# ax.invert_yaxis()
# ax.grid(True, linestyle='--', color='gray', alpha=0.5)
# # Add a title and axis labels
# ax.set_title("Gradient Thesis v.d.K (2001)")
# ax.set_xlabel("rel. permittvity [-]")
# ax.set_ylabel("Depth [m]")

# plt.legend(loc='best')
# # Display the plot
# plt.show()