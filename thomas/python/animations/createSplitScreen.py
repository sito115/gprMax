from moviepy.editor import VideoFileClip, clips_array
import os

moviePath = 'C:\\Users\\thomas\\Downloads\\snaps'
fileName  = 'Weak-GradientRLFLAScenariosAllHeightsRXRLFA.mp4'

class movieFile:
    def __init__(self,path,file):
        self.path = path
        self.file = file

    def create_VideoFileClip(self):
        return  VideoFileClip(os.path.join(self.path, self.file))



movie00 = movieFile(moviePath,'HaSp_dx6.0m_eps5.0_00RLFLARX0_1.0m_dxRX0.20mTX-RLA.mp4')
movie1 = movieFile(moviePath,'HaSp_dx6.0m_eps12.5_00er0_5.0RLFLAGoffset0.1mRX0_1.0m_dxRX0.20mTX-RLA.mp4')
movie2 = movieFile(moviePath,'HaSp_dx6.0m_eps12.5_++er0_5.0_h0.1mRLFLARX0_1.0m_dxRX0.20mTX-RLA.mp4')
movie3 = movieFile(moviePath,'HaSp_dx6.0m_eps5.0_--er0_12.5_h0.1mRLFLARX0_1.0m_dxRX0.20mTX-RLA.mp4')
movie4 = movieFile(moviePath,'HaSp_dx6.0m_eps12.5_00er0_5.0RLFLAGoffset0.2mRX0_1.0m_dxRX0.20mTX-RLA.mp4')
movie5 = movieFile(moviePath,'HaSp_dx6.0m_eps12.5_++er0_5.0_h0.2mRLFLARX0_1.0m_dxRX0.20mTX-RLA.mp4')
movie6 = movieFile(moviePath,'HaSp_dx6.0m_eps5.0_--er0_12.5_h0.2mRLFLARX0_1.0m_dxRX0.20mTX-RLA.mp4')
movie7 = movieFile(moviePath,'HaSp_dx6.0m_eps12.5_00er0_5.0RLFLAGoffset0.5mRX0_1.0m_dxRX0.20mTX-RLA.mp4')
movie8 = movieFile(moviePath,'HaSp_dx6.0m_eps12.5_++er0_5.0_h0.5mRLFLARX0_1.0m_dxRX0.20mTX-RLA.mp4')
movie9 = movieFile(moviePath,'HaSp_dx6.0m_eps5.0_--er0_12.5_h0.5mRLFLARX0_1.0m_dxRX0.20mTX-RLA.mp4')
# movie00 = movieFile(moviePath,'HaSp_dx6.0m_eps5.0_00RLFLARX0_1.0m_dxRX0.20mTX-RLARX-RLA.mp4')
# movie1 = movieFile(moviePath,'HaSp_dx6.0m_eps12.5_00er0_5.0RLFLAGoffset0.1mRX0_1.0m_dxRX0.20mTX-RLARX-RLA.mp4')
# movie2 = movieFile(moviePath,'HaSp_dx6.0m_eps12.5_++er0_5.0_h0.1mRLFLARX0_1.0m_dxRX0.20mTX-RLARX-RLA.mp4')
# movie3 = movieFile(moviePath,'HaSp_dx6.0m_eps5.0_--er0_12.5_h0.10mRLFLARX0_1.0m_dxRX0.20mTX-RLARX-RLA.mp4')
# movie4 = movieFile(moviePath,'HaSp_dx6.0m_eps12.5_00er0_5.0RLFLAGoffset0.2mRX0_1.0m_dxRX0.20mTX-RLARX-RLA.mp4')
# movie5 = movieFile(moviePath,'HaSp_dx6.0m_eps12.5_++er0_5.0_h0.2mRLFLARX0_1.0m_dxRX0.20mTX-RLARX-RLA.mp4')
# movie6 = movieFile(moviePath,'HaSp_dx6.0m_eps5.0_--er0_12.5_h0.25mRLFLARX0_1.0m_dxRX0.20mTX-RLARX-RLA.mp4')
# movie7 = movieFile(moviePath,'HaSp_dx6.0m_eps12.5_00er0_5.0RLFLAGoffset0.5mRX0_1.0m_dxRX0.20mTX-RLARX-RLA.mp4')
# movie8 = movieFile(moviePath,'HaSp_dx6.0m_eps12.5_++er0_5.0_h0.5mRLFLARX0_1.0m_dxRX0.20mTX-RLARX-RLA.mp4')
# movie9 = movieFile(moviePath,'HaSp_dx6.0m_eps5.0_--er0_12.5_h0.50mRLFLARX0_1.0m_dxRX0.20mTX-RLARX-RLA.mp4')







clip00 = movie00.create_VideoFileClip()
# clip01 = movie01.create_VideoFileClip()
clip1  = movie1.create_VideoFileClip() 
clip2  = movie2.create_VideoFileClip()
clip3  = movie3.create_VideoFileClip()
clip4  = movie4.create_VideoFileClip()
clip5  = movie5.create_VideoFileClip()
clip6  = movie6.create_VideoFileClip()
clip7  = movie7.create_VideoFileClip()
clip8  = movie8.create_VideoFileClip()
clip9  = movie9.create_VideoFileClip()
# clip10 = movie10.create_VideoFileClip()
# clip11 = movie11.create_VideoFileClip()
# clip12 = movie12.create_VideoFileClip()


combined = clips_array([
    [clip00,clip1,clip2,clip3],
    [clip00,clip4,clip5,clip6],
    [clip00,clip7,clip8,clip9]
      ])

combined.write_videofile(os.path.join(moviePath,fileName))

# Strong Contrast - No Bottom Reflector
# movie00 = movieFile(moviePath,'HaSp_dx10.0m_eps5.0_00InfDi200MHzRX0_0.5m_dxRX0.20m.mp4')
# movie01 = movieFile(moviePath,'HaSp_dx10.0m_eps12.5_00InfDi200MHzRX0_0.5m_dxRX0.20m.mp4')
# movie8  = movieFile(moviePath,'HaSp_dx10.0m_eps12.5_00er0_5.0InfDi200MHzGoffset0.1mRX0_0.5m_dxRX0.20m.mp4')
# movie9  = movieFile(moviePath,'HaSp_dx10.0m_eps12.5_00er0_5.0InfDi200MHzGoffset0.2mRX0_0.5m_dxRX0.20m.mp4')
# movie10 = movieFile(moviePath,'HaSp_dx10.0m_eps12.5_00er0_5.0InfDi200MHzGoffset0.5mRX00.5m_dxRX0.20m.mp4')
# movie2 = movieFile(moviePath,'HaSp_dx10.0m_eps12.5_++er0_5.0_h0.1mInfDi200MHzRX0_0.5m_dxRX0.20m.mp4')
# movie3 = movieFile(moviePath,'HaSp_dx10.0m_eps12.5_++er0_5.0_h0.2mInfDi200MHzRX0_0.5m_dxRX0.20m.mp4')
# movie4 = movieFile(moviePath,'HaSp_dx10.0m_eps12.5_++er0_5.0_h0.5mInfDi200MHzRX00.5m_dxRX0.20m.mp4')
# movie5 = movieFile(moviePath,'HaSp_dx10.0m_eps5.0_--er0_12.5_h0.1mInfDi200MHzRX0_0.5m_dxRX0.20m.mp4')
# movie6 = movieFile(moviePath,'HaSp_dx10.0m_eps5.0_--er0_12.5_h0.2mInfDi200MHzRX0_0.5m_dxRX0.20m.mp4')
# movie7 = movieFile(moviePath,'HaSp_dx10.0m_eps5.0_--er0_12.5_h0.5mInfDi200MHzRX00.5m_dxRX0.20m.mp4')
# movie11 = movieFile(moviePath,'HaSp_dx10.0m_eps5.0_00er0_12.5InfDi200MHzGoffset0.1mRX0_0.5m_dxRX0.20m.mp4')
# movie12 = movieFile(moviePath,'HaSp_dx10.0m_eps5.0_00er0_12.5InfDi200MHzGoffset0.2mRX0_0.5m_dxRX0.20m.mp4')
# movie13 = movieFile(moviePath,'HaSp_dx10.0m_eps5.0_00er0_12.5InfDi200MHzGoffset0.5mRX0_0.5m_dxRX0.20m.mp4')

# Weak Contrast - No Bottom Reflector
# movie2 = movieFile(moviePath,'HaSp_dx10.0m_eps6.0_++er0_5.0_h0.1mInfDi200MHzRX0_0.5m_dxRX0.20m.mp4')
# movie3 = movieFile(moviePath,'HaSp_dx10.0m_eps6.0_++er0_5.0_h0.2mInfDi200MHzRX0_0.5m_dxRX0.20m.mp4')
# movie4 = movieFile(moviePath,'HaSp_dx10.0m_eps6.0_++er0_5.0_h0.5mInfDi200MHzRX0_0.5m_dxRX0.20m.mp4')
# movie5 = movieFile(moviePath,'HaSp_dx10.0m_eps5.0_--er0_6.0_h0.1mInfDi200MHzRX0_0.5m_dxRX0.20m.mp4')
# movie6 = movieFile(moviePath,'HaSp_dx10.0m_eps5.0_--er0_6.0_h0.2mInfDi200MHzRX0_0.5m_dxRX0.20m.mp4')
# movie7 = movieFile(moviePath,'HaSp_dx10.0m_eps5.0_--er0_6.0_h0.5mInfDi200MHzRX0_0.5m_dxRX0.20m.mp4')
# movie8 = movieFile(moviePath,'HaSp_dx10.0m_eps6.0_00er0_5.0InfDi200MHzGoffset0.1mRX0_0.5m_dxRX0.20m.mp4')
# movie9 = movieFile(moviePath,'HaSp_dx10.0m_eps6.0_00er0_5.0InfDi200MHzGoffset0.2mRX0_0.5m_dxRX0.20m.mp4')
# movie10 = movieFile(moviePath,'HaSp_dx10.0m_eps6.0_00er0_5.0InfDi200MHzGoffset0.5mRX0_0.5m_dxRX0.20m.mp4')
# movie11 = movieFile(moviePath,'HaSp_dx10.0m_eps5.0_00er0_6.0InfDi200MHzGoffset0.1mRX0_0.5m_dxRX0.20m.mp4')
# movie12 = movieFile(moviePath,'HaSp_dx10.0m_eps5.0_00er0_6.0InfDi200MHzGoffset0.2mRX0_0.5m_dxRX0.20m.mp4')
# movie13 = movieFile(moviePath,'HaSp_dx10.0m_eps5.0_00er0_6.0InfDi200MHzGoffset0.5mRX0_0.5m_dxRX0.20m.mp4')



# Strong Contrast - Bottom Reflector
# movie1  = movieFile(moviePath,'HaSp_dx10.0m_eps5.0_00er0_12.5InfDi200MHz_br_Goffset0.1mRX0_0.5m_dxRX0.20m.mp4')
# movie2  = movieFile(moviePath,'HaSp_dx10.0m_eps5.0_00er0_12.5InfDi200MHz_br_Goffset0.2mRX0_0.5m_dxRX0.20m.mp4')
# movie3  = movieFile(moviePath,'HaSp_dx10.0m_eps5.0_00er0_12.5InfDi200MHz_br_Goffset0.5mRX0_0.5m_dxRX0.20m.mp4')
# movie4  = movieFile(moviePath,'HaSp_dx10.0m_eps12.5_00er0_5.0InfDi200MHz_br_Goffset0.1mRX0_0.5m_dxRX0.20m.mp4')
# movie5  = movieFile(moviePath,'HaSp_dx10.0m_eps12.5_00er0_5.0InfDi200MHz_br_Goffset0.2mRX0_0.5m_dxRX0.20m.mp4')
# movie6  = movieFile(moviePath,'HaSp_dx10.0m_eps12.5_00er0_5.0InfDi200MHz_br_Goffset0.5mRX0_0.5m_dxRX0.20m.mp4')
# movie7  = movieFile(moviePath,'HaSp_dx10.0m_eps12.5_++er0_5.0_h0.10mInfDi200MHz_br_RX0_0.5m_dxRX0.20m.mp4')
# movie8  = movieFile(moviePath,'HaSp_dx10.0m_eps12.5_++er0_5.0_h0.25mInfDi200MHz_br_RX0_0.5m_dxRX0.20m.mp4')
# movie9  = movieFile(moviePath,'HaSp_dx10.0m_eps12.5_++er0_5.0_h0.50mInfDi200MHz_br_RX0_0.5m_dxRX0.20m.mp4')
# movie10 = movieFile(moviePath,'HaSp_dx10.0m_eps5.0_--er0_12.5_h0.10mInfDi200MHz_br_RX0_0.5m_dxRX0.20m.mp4')
# movie11 = movieFile(moviePath,'HaSp_dx10.0m_eps5.0_--er0_12.5_h0.25mInfDi200MHz_br_RX0_0.5m_dxRX0.20m.mp4')
# movie12 = movieFile(moviePath,'HaSp_dx10.0m_eps5.0_--er0_12.5_h0.50mInfDi200MHz_br_RX0_0.5m_dxRX0.20m.mp4')

# Weak Contrast - Bottom Reflector
# movie1  = movieFile(moviePath,'HaSp_dx10.0m_eps5.0_00er0_6.0InfDi200MHz_br_Goffset0.1mRX0_0.5m_dxRX0.20m.mp4')
# movie2  = movieFile(moviePath,'HaSp_dx10.0m_eps5.0_00er0_6.0InfDi200MHz_br_Goffset0.2mRX0_0.5m_dxRX0.20m.mp4')
# movie3  = movieFile(moviePath,'HaSp_dx10.0m_eps5.0_00er0_6.0InfDi200MHz_br_Goffset0.5mRX0_0.5m_dxRX0.20m.mp4')
# movie4  = movieFile(moviePath,'HaSp_dx10.0m_eps6.0_00er0_5.0InfDi200MHz_br_Goffset0.1mRX0_0.5m_dxRX0.20m.mp4')
# movie5  = movieFile(moviePath,'HaSp_dx10.0m_eps6.0_00er0_5.0InfDi200MHz_br_Goffset0.2mRX0_0.5m_dxRX0.20m.mp4')
# movie6  = movieFile(moviePath,'HaSp_dx10.0m_eps6.0_00er0_5.0InfDi200MHz_br_Goffset0.5mRX0_0.5m_dxRX0.20m.mp4')
# movie7  = movieFile(moviePath,'HaSp_dx10.0m_eps6.0_++er0_5.0_h0.10mInfDi200MHz_br_RX0_0.5m_dxRX0.20m.mp4')
# movie8  = movieFile(moviePath,'HaSp_dx10.0m_eps6.0_++er0_5.0_h0.25mInfDi200MHz_br_RX0_0.5m_dxRX0.20m.mp4')
# movie9  = movieFile(moviePath,'HaSp_dx10.0m_eps6.0_++er0_5.0_h0.50mInfDi200MHz_br_RX0_0.5m_dxRX0.20m.mp4')
# movie10 = movieFile(moviePath,'HaSp_dx10.0m_eps5.0_--er0_6.0_h0.10mInfDi200MHz_br_RX0_0.5m_dxRX0.20m.mp4')
# movie11 = movieFile(moviePath,'HaSp_dx10.0m_eps5.0_--er0_6.0_h0.25mInfDi200MHz_br_RX0_0.5m_dxRX0.20m.mp4')
# movie12 = movieFile(moviePath,'HaSp_dx10.0m_eps5.0_--er0_6.0_h0.50mInfDi200MHz_br_RX0_0.5m_dxRX0.20m.mp4')