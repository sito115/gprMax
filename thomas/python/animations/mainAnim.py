import os
from createAnimation import createAnimation
import matplotlib as mpl 
import matplotlib.pyplot as plt
import matplotlib.animation as animation


# parameters
field           = 'E-field'
inter           = 300
alphaValue      = 0.5
absoluteScaling = 5* [1e-2] #+ 6*[1e-5]
plane           = 'y'
idx             = 0
isSave          = True
dt              = 1e-9


ffmepPath       = "C:\\Users\\thomas\Downloads\\ffmpeg-n6.0-latest-win64-lgpl-6.0\\ffmpeg-n6.0-latest-win64-lgpl-6.0\\bin\\ffmpeg.exe"
folderGeo       = "C:\\OneDrive - Delft University of Technology\\3. Semester - Studienunterlagen\\Thesis\\gprMaxFolder\\gprMax\\ProcessedFiles"
folderSnapsAll  = 'C:\\Users\\thomas\\Downloads\\snaps'

mpl.rcParams['animation.ffmpeg_path'] = ffmepPath


class snapshots:
    def __init__(self, foldername, folderpath, title, scaling, dt):
        self.foldername = foldername
        self.foldername = folderpath
        self.title      = title
        self.scaling    = scaling
        self.dt         = dt


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

snapFolderDir = {
'Increasing (5 - 12.5) 140MHz Point': 'HaSp_dx8.0m_eps12.5_++er0_5.0_h0.5mInfDipGoffset0.5m_snaps',
'homogenous (5) 140MHz Point'           :'HaSp_dx8.0m_eps5.0_00InfDip_snaps',
'Static (5 - 12.5) 140MHz Point'    :'HaSp_dx8.0m_eps12.5_00er0_5.0InfDipGoffset0.5m_snaps',
'Decreasing (12.5 - 5)  140MHz Point'        :'HaSp_dx8.0m_eps5.0_--er0_12.5_h0.5mInfDipGoffset0.5m_snaps',
'homogenous (12.5) 140MHz Point'    :'HaSp_dx8.0m_eps12.5_00InfDip_snaps'}
# 'homogenous (12.5) RLFLA'           :'HaSp_dx8.0m_eps12.5_00RLFLA_snaps',
# 'Static (5 - 12.5) 10 x RLFLA'      :'HaSp_dx8.0m_eps12.5_00er0_5.0RLFLAnRX10_dxRX0.50mGoffset0.5m_snaps',
# 'Decreasing (12.5 - 5)  RLFLA'        :'HaSp_dx8.0m_eps5.0_--er0_12.5_h0.5mRLFLAGoffset0.5m_snaps',
# 'Static (5 - 12.5) RLFLA'           :'HaSp_dx8.0m_eps12.5_00er0_5.0RLFLAGoffset0.5m_snaps',
# 'Increasing (5 - 12.5) RLFLA'       : 'HaSp_dx8.0m_eps12.5_++er0_5.0_h0.5mRLFLAGoffset0.5m_snaps',
# 'homogenous (5) RLFLA'           :'HaSp_dx8.0m_eps5.0_00RLFLA_snaps'
# }





# create plot
# fig, ax = plt.subplots(2,3)

nColCounter = nRowCounter = 0
for i, (key,value) in enumerate(snapFolderDir.items()):
    fig, ax = plt.subplots()
    folderSnaps = os.path.join(folderSnapsAll,value)
    geomName    = value.replace('_snaps', '.vti')
    print(geomName)
    fileGeom    = os.path.join(folderGeo,geomName)
    displayFile = value
    title       = key
    scaling     = absoluteScaling[i]

    curr_animation = createAnimation(fileGeom,folderSnaps,displayFile, field,
                          plane,idx, inter, alphaValue,
                          scaling, title,dt,ax, fig)

    # ax[nRowCounter, nColCounter]

    if isSave: 
        writervideo = animation.FFMpegWriter(fps=60) 
        name = geomName.replace('.vti', '.mp4')
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

