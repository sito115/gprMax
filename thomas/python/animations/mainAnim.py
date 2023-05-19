import os
from createAnimation import createAnimation
import matplotlib as mpl 
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import gc

# parameters
isSave          = True
ffmepPath       = "C:\\Users\\thomas\Downloads\\ffmpeg-n6.0-latest-win64-lgpl-6.0\\ffmpeg-n6.0-latest-win64-lgpl-6.0\\bin\\ffmpeg.exe"
folderGeo       = "C:\\OneDrive - Delft University of Technology\\3. Semester - Studienunterlagen\\Thesis\\gprMaxFolder\\gprMax\\ProcessedFiles"
folderSnapsAll  = 'C:\\Users\\thomas\\Downloads\\snaps'

mpl.rcParams['animation.ffmpeg_path'] = ffmepPath

class snapshots:
    def __init__(self, foldername, fileGeom, title, scaling, dt):
        self.folderSnap = foldername
        self.fileGeom   = os.path.join(fileGeom,os.path.basename(foldername).replace('_snaps', '.vti'))
        self.title      = title
        self.scaling    = scaling
        self.dt         = dt

        # Default
        self.field           = 'E-field'
        self.inter           = 500
        self.alphaValue      = 0.5
        self.plane           = 'y'
        self.idx             = 0

snap1 = snapshots(os.path.join(folderSnapsAll,'HaSp_dx6.0m_eps12.5_00er0_5.0RLFLAGoffset0.5mRX0_1.0m_dxRX0.20mTX-RLARX-RLA_snaps'),
                 os.path.join(folderGeo,'2_TwoLayer'),
                 'Two Layer (5-12.5) RLFLA TX RX h=0.5m',1e-5,1.2e-9)

snap2 = snapshots(os.path.join(folderSnapsAll,'HaSp_dx6.0m_eps12.5_00er0_5.0RLFLAGoffset0.2mRX0_1.0m_dxRX0.20mTX-RLARX-RLA_snaps'),
                 os.path.join(folderGeo,'2_TwoLayer'),
                 'Two Layer (5-12.5) RLFLA TX RX h=0.25m',1e-5,1.2e-9)

snap3 = snapshots(os.path.join(folderSnapsAll,'HaSp_dx6.0m_eps12.5_00er0_5.0RLFLAGoffset0.1mRX0_1.0m_dxRX0.20mTX-RLARX-RLA_snaps'),
                 os.path.join(folderGeo,'2_TwoLayer'),
                'Two Layer (5-12.5) RLFLA TX RX h=0.10m',1e-5,1.2e-9)

for snap in gc.get_objects():
    if isinstance(snap, snapshots):
        fig, ax = plt.subplots()
        folderSnaps = snap.folderSnap
        fileGeom    = snap.fileGeom
        print(fileGeom)
        title       = snap.title
        scaling     = snap.scaling

        curr_animation = createAnimation(fileGeom,folderSnaps, snap.field,
                            snap.plane,snap.idx, snap.inter, snap.alphaValue,
                            scaling, title,snap.dt,ax, fig)

        if isSave: 
            writervideo = animation.FFMpegWriter(fps=60) 
            name = os.path.basename(fileGeom).replace('.vti', '.mp4')
            saveAbs = os.path.join(folderSnapsAll,  name)
            print('Saving  %s...' %(saveAbs))
            curr_animation.save(saveAbs)
            print('Done\n')

    # anim.append(animation)

    # define folder
    # print('Iteration:', i)
    # print('Column:', nColCounter)
    # print('Row', nRowCounter)
    # nColCounter += 1
    # if nColCounter > ax.shape[1]-1:
    #     nColCounter = 0
    #     nRowCounter += 1


# snapFolderDir = {
# 'Homegenous (5) 140MHz Point'       :  'HalfSpa_dx6.0m_eps_5.0_i3D0_er0_12.5_h0.5mNoGradInfDip_snaps' ,
# 'Decreasing (12.5 - 5) 140MHz Point': 'HalfSpa_dx6.0m_eps_5.0_i3D0_er0_12.5_h0.5mDecreaseInfDip_snaps',
# 'Increasing (5 - 12.5) 140MHz Point': 'HalfSpa_dx6.0m_eps_12.5_i3D0_er0_5.0_h0.5mIncreaseInfDip_snaps'  ,
# 'Homegenous (5) RLFLA '             : 'HalfSpace_dx6.0m_eps_5.0_i3D1RLFLA_snaps',
# 'Decreasing (12.5 - 5) RLFLA '      : 'HalfSpace_dx6.0m_eps_5.0_i3D1_er0_12.5_h0.5mDecreaseRLFLA_snaps',
# 'Increasing (5 - 12.5) RLFLA '      : 'HalfSpace_dx6.0m_epsr12.5_i3D1_er05.0_h0.5mIncreaseRLFLA_snaps'
# }

# geometryNames = [
# 'HalfSpa_dx6.0m_eps_5.0_i3D0_er0_12.5_h0.5mNoGradInfDip.vti' ,
# 'HalfSpa_dx6.0m_eps_5.0_i3D0_er0_12.5_h0.5mDecreaseInfDip.vti',
# 'HalfSpa_dx6.0m_eps_12.5_i3D0_er0_5.0_h0.5mIncreaseInfDip.vti'  ,
# 'HalfSpace_dx6.0m_eps_5.0_i3D1RLFLA.vti',
# 'HalfSpace_dx6.0m_eps_5.0_i3D1_er0_12.5_h0.5mDecreaseRLFLA.vti',
# 'HalfSpace_dx6.0m_epsr12.5_i3D1_er05.0_h0.5mIncreaseRLFLA.vti']

# snapFolderDir = {
# 'Homegenous (5) 140MHz Point'       : 'HaSp_dx6.0m_eps5.0_00InfDipGoffset0.5m3cm_snaps',
# 'Decreasing (12.5 - 5) 140MHz Point': 'HaSp_dx6.0m_eps12.5_++er05.0_h0.5mInfDipGoffset0.5m3cm_snaps',
# 'Increasing (5 - 12.5) 140MHz Point': 'HaSp_dx6.0m_eps5.0_--er012.5_h0.5mInfDipGoffset0.5m3cm_snaps',
# 'Homegenous (12.5) 140MHz Point'    : 'HaSp_dx6.0m_eps12.5_00InfDipGoffset0.5m3cm_snaps',
# 'Homegenous (5) RLFLA '             : 'HaSp_dx6.0m_eps5.0_00RLFLAGoffset0.5m3cm_snaps',
# 'Decreasing (12.5 - 5) RLFLA '      : 'HaSp_dx6.0m_eps12.5_++er05.0_h0.5mRLFLAGoffset0.5m3cm_snaps',
# 'Increasing (5 - 12.5) RLFLA '      : 'HaSp_dx6.0m_eps5.0_--er012.5_h0.5mRLFLAGoffset0.5m3cm_snaps',
# 'Homegenous (12.5) RLFLA'           : 'HaSp_dx6.0m_eps12.5_00RLFLAGoffset0.5m3cm_snaps'
# }


# snapFolderDir = {
# 'Homegenous (5) 140MHz Point'       :  'HalfSpa_dx6.0m_eps_5.0_i3D0_er0_12.5_h0.5mNoGradInfDip_snaps' ,
# 'Decreasing (12.5 - 5) 140MHz Point': 'HalfSpa_dx6.0m_eps_5.0_i3D0_er0_12.5_h0.5mDecreaseInfDip_snaps',
# 'Increasing (5 - 12.5) 140MHz Point': 'HalfSpa_dx6.0m_eps_12.5_i3D0_er0_5.0_h0.5mIncreaseInfDip_snaps'  ,
# 'Homegenous (5) RLFLA '             : 'HalfSpace_dx6.0m_eps_5.0_i3D1RLFLA_snaps',
# 'Decreasing (12.5 - 5) RLFLA '      : 'HalfSpace_dx6.0m_eps_5.0_i3D1_er0_12.5_h0.5mDecreaseRLFLA_snaps',
# 'Increasing (5 - 12.5) RLFLA '      : 'HalfSpace_dx6.0m_epsr12.5_i3D1_er05.0_h0.5mIncreaseRLFLA_snaps'
# }

# snapFolderDir = {
# 'Increasing (5 - 12.5) 140MHz Point': 'HaSp_dx8.0m_eps12.5_++er0_5.0_h0.5mInfDipGoffset0.5m_snaps',
# 'homogenous (5) 140MHz Point'           :'HaSp_dx8.0m_eps5.0_00InfDip_snaps',
# 'Static (5 - 12.5) 140MHz Point'    :'HaSp_dx8.0m_eps12.5_00er0_5.0InfDipGoffset0.5m_snaps',
# 'Decreasing (12.5 - 5)  140MHz Point'        :'HaSp_dx8.0m_eps5.0_--er0_12.5_h0.5mInfDipGoffset0.5m_snaps',
# 'homogenous (12.5) 140MHz Point'    :'HaSp_dx8.0m_eps12.5_00InfDip_snaps'}
# 'homogenous (12.5) RLFLA'           :'HaSp_dx8.0m_eps12.5_00RLFLA_snaps',
# 'Static (5 - 12.5) 10 x RLFLA'      :'HaSp_dx8.0m_eps12.5_00er0_5.0RLFLAnRX10_dxRX0.50mGoffset0.5m_snaps',
# 'Decreasing (12.5 - 5)  RLFLA'        :'HaSp_dx8.0m_eps5.0_--er0_12.5_h0.5mRLFLAGoffset0.5m_snaps',
# 'Static (5 - 12.5) RLFLA'           :'HaSp_dx8.0m_eps12.5_00er0_5.0RLFLAGoffset0.5m_snaps',
# 'Increasing (5 - 12.5) RLFLA'       : 'HaSp_dx8.0m_eps12.5_++er0_5.0_h0.5mRLFLAGoffset0.5m_snaps',
# 'homogenous (5) RLFLA'           :'HaSp_dx8.0m_eps5.0_00RLFLA_snaps'
# }

# snapFolderDir = {
# '200MHz Inf. Dipole: Homogeneous (5)'                         : 'HaSp_dx10.0m_eps5.0_00InfDi200MHzRX0_0.5m_dxRX0.20m_snaps',
# '200MHz Inf. Dipole: Homogeneous (5) bottom reflector'        : 'HaSp_dx10.0m_eps5.0_00InfDi200MHz_br_RX0_0.5m_dxRX0.20m_snaps',
# '200MHz Inf. Dipole: Decreasing (12.5 - 5) bottom reflector'  : 'HaSp_dx10.0m_eps5.0_--er0_12.5_h0.5mInfDi200MHz_br_RX00.5m_dxRX0.20m_snaps',
# '200MHz Inf. Dipole: Decreasing (12.5 - 5) '                  : 'HaSp_dx10.0m_eps5.0_--er0_12.5_h0.5mInfDi200MHzRX00.5m_dxRX0.20m_snaps',
# '200MHz Inf. Dipole: Increasing (5-12.5) bottom reflector'    : 'HaSp_dx10.0m_eps12.5_++er0_5.0_h0.5mInfDi200MHz_br_RX00.5m_dxRX0.20m_snaps',
# '200MHz Inf. Dipole: Increasing (5-12.5) '                    : 'HaSp_dx10.0m_eps12.5_++er0_5.0_h0.5mInfDi200MHzRX00.5m_dxRX0.20m_snaps',
# '200MHz Inf. Dipole: 2-Layer (5,12.5) bottom reflector'       : 'HaSp_dx10.0m_eps12.5_00er0_5.0InfDi200MHz_br_Goffset0.5mRX00.5m_dxRX0.20m_snaps',
# '200MHz Inf. Dipole: 2-Layer (5,12.5)'                        : 'HaSp_dx10.0m_eps12.5_00er0_5.0InfDi200MHzGoffset0.5mRX00.5m_dxRX0.20m_snaps',
# }
# snapFolderDir = {
# '200MHz Inf. Dipole: Increasing (5-12.5)'                     : 'HaSp_dx10.0m_eps12.5_++er0_5.0_h0.5mInfDi200MHznRX49_dxRX0.20m_snaps',
# '200MHz Inf. Dipole: Increasing (5-12.5) bottom reflector'    : 'HaSp_dx10.0m_eps12.5_++er0_5.0_h0.5mInfDi200MHz_brnRX49_dxRX0.20m_snaps',
# '200MHz Inf. Dipole: Decreasing (12.5 - 5)'                   : 'HaSp_dx10.0m_eps5.0_--er0_12.5_h0.5mInfDi200MHznRX49_dxRX0.20m_snaps',
# '200MHz Inf. Dipole: Decreasing (12.5 - 5) bottom reflector'  : 'HaSp_dx10.0m_eps5.0_--er0_12.5_h0.5mInfDi200MHz_brnRX49_dxRX0.20m_snaps',
# '200MHz Inf. Dipole: Homogeneous (5)'                         : 'HaSp_dx10.0m_eps5.0_00InfDi200MHznRX49_dxRX0.20mnoBR_snaps',
# '200MHz Inf. Dipole: Homogeneous (5) bottom reflector'        : 'HaSp_dx10.0m_eps5.0_00InfDipnRX49_dxRX0.200mBR200MHz_snaps'
# }
