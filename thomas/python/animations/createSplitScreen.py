from moviepy.editor import VideoFileClip, clips_array
import os

moviePath = 'C:\\Users\\thomas\\Downloads\\snaps'

# movieFiles = [
# 'HalfSpa_dx6.0m_eps_5.0_i3D0_er0_12.5_h0.5mNoGradInfDip.mp4',
# 'HalfSpa_dx6.0m_eps_12.5_i3D0_er0_5.0_h0.5mIncreaseInfDip.mp4',
# 'HalfSpa_dx6.0m_eps_5.0_i3D0_er0_12.5_h0.5mDecreaseInfDip.mp4',
# 'HalfSpace_dx6.0m_eps_5.0_i3D1RLFLA.mp4',
# 'HalfSpace_dx6.0m_epsr12.5_i3D1_er05.0_h0.5mIncreaseRLFLA.mp4',
# 'HalfSpace_dx6.0m_eps_5.0_i3D1_er0_12.5_h0.5mDecreaseRLFLA.mp4'
# ]

class movieFile:
    def __init__(self,path,file):
        self.path = path
        self.file = file

    def create_VideoFileClip(self):
        return  VideoFileClip(os.path.join(self.path, self.file))


# movie1 = movieFile(moviePath, 'HaSp_dx8.0m_eps5.0_00InfDip.mp4')
# movie2 = movieFile(moviePath, 'HaSp_dx8.0m_eps12.5_00er0_5.0InfDipGoffset0.5m.mp4')
# movie3 = movieFile(moviePath, 'HaSp_dx8.0m_eps12.5_++er0_5.0_h0.5mInfDipGoffset0.5m.mp4')
# movie4 = movieFile(moviePath, 'HaSp_dx8.0m_eps5.0_--er0_12.5_h0.5mInfDipGoffset0.5m.mp4')
# movie5 = movieFile(moviePath, 'HaSp_dx8.0m_eps5.0_00RLFLA.mp4')
# movie6 = movieFile(moviePath, 'HaSp_dx8.0m_eps12.5_00er0_5.0RLFLAGoffset0.5m.mp4')
# movie7 = movieFile(moviePath, 'HaSp_dx8.0m_eps12.5_++er0_5.0_h0.5mRLFLAGoffset0.5m.mp4')
# movie8 = movieFile(moviePath, 'HaSp_dx8.0m_eps5.0_--er0_12.5_h0.5mRLFLAGoffset0.5m.mp4')
# movie9 = movieFile(moviePath, 'HaSp_dx8.0m_eps12.5_00er0_5.0RLFLAnRX10_dxRX0.50mGoffset0.5m.mp4')
# movie10 = movieFile(moviePath, 'HaSp_dx8.0m_eps12.5_00RLFLA.mp4')



# movie1 = movieFile(moviePath, 'HaSp_dx10.0m_eps5.0_00InfDi200MHzRX0_0.5m_dxRX0.20m.mp4')
# movie2 = movieFile(moviePath, 'HaSp_dx10.0m_eps12.5_00er0_5.0InfDi200MHzGoffset0.5mRX00.5m_dxRX0.20m.mp4')
# movie3 = movieFile(moviePath, 'HaSp_dx10.0m_eps12.5_++er0_5.0_h0.5mInfDi200MHzRX00.5m_dxRX0.20m.mp4')
# movie4 = movieFile(moviePath, 'HaSp_dx10.0m_eps5.0_--er0_12.5_h0.5mInfDi200MHzRX00.5m_dxRX0.20m.mp4')


# movie5 = movieFile(moviePath, 'HaSp_dx10.0m_eps5.0_00InfDi200MHz_br_RX0_0.5m_dxRX0.20m.mp4')
# movie6 = movieFile(moviePath, 'HaSp_dx10.0m_eps12.5_00er0_5.0InfDi200MHz_br_Goffset0.5mRX00.5m_dxRX0.20m.mp4')
# movie7 = movieFile(moviePath, 'HaSp_dx10.0m_eps12.5_++er0_5.0_h0.5mInfDi200MHz_br_RX00.5m_dxRX0.20m.mp4')
# movie8 = movieFile(moviePath, 'HaSp_dx10.0m_eps5.0_--er0_12.5_h0.5mInfDi200MHz_br_RX00.5m_dxRX0.20m.mp4')


movie1 = movieFile(moviePath, 'HaSp_dx10.0m_eps4.1_VDK5InfDi200MHzRX0_0.5m_dxRX0.20m.mp4')
movie2 = movieFile(moviePath, 'HaSp_dx10.0m_eps3.9_VDK10InfDi200MHzRX0_0.5m_dxRX0.20m.mp4')



clip1 = movie1.create_VideoFileClip() 
clip2 = movie2.create_VideoFileClip()
# clip3 = movie3.create_VideoFileClip()
# clip4 = movie4.create_VideoFileClip()
# clip5 = movie5.create_VideoFileClip()
# clip6 = movie6.create_VideoFileClip()
# clip7 = movie7.create_VideoFileClip()
# clip8 = movie8.create_VideoFileClip()

combined = clips_array([[clip1,clip2]])

combined.write_videofile(os.path.join(moviePath,'VDKScenarios.mp4'))