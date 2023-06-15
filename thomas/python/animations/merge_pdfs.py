from pdf2image import convert_from_path
import os
from PIL import Image




def create_pngImages(path,input_files):
    images = list()
    for file in input_files:
        if file.endswith('.pdf'):
            temp = convert_from_path(os.path.join(path,file))
        else:
            temp = os.path.join(path,file)
            images.append(temp)
    return images

def combine_images(columns, space, images, outputFile):
    #https://stackoverflow.com/questions/72723928/how-to-combine-several-images-to-one-image-in-a-grid-structure-in-python
    rows = len(images) // columns
    if len(images) % columns:
        rows += 1

    isString = True
    for element in images:
        if type(element) != str:
            isString = False
            width_max = max([image[0].width for image in images])
            height_max = max([image[0].height for image in images])
            break
        else:
            width_max = max([Image.open(image).width for image in images])
            height_max = max([Image.open(image).height for image in images])
    
    background_width = width_max*columns + (space*columns)-space
    background_height = height_max*rows + (space*rows)-space
    background = Image.new('RGBA', (background_width, background_height), (255, 255, 255, 255))
    x = 0
    y = 0
    for i, image in enumerate(images):
        if isString:
            img = Image.open(image)
        else: 
            img = image[0]
        x_offset = int((width_max-img.width)/2)
        y_offset = int((height_max-img.height)/2)
        background.paste(img, (x+x_offset, y+y_offset))
        x += width_max + space
        if (i+1) % columns == 0:
            y += height_max + space
            x = 0
    background.save(outputFile)


if __name__ == '__main__':

    outputName = 'Frames_Increasing_5_125_050_2D.png' #'WeakGradientRLFLABScans-Merged.png'
    pathRoot        = "C:\\OneDrive - Delft University of Technology\\4. Semester - Thesis"
    figureFolder    = "OutputgprMax\Figures"
    path            = os.path.join(pathRoot, figureFolder)
    output_filename =  os.path.join(path, outputName)
    nColumns = 7
    space = 10
    path = "C:\OneDrive - Delft University of Technology\\3. Semester - Studienunterlagen\Thesis\gprMaxFolder\gprMax\ProcessedFiles\\3_IncreasingGradient\HaSp_dx10.0m_eps12.5_++er0_5.0_h0.5mInfDi200MHzRX00.5m_dxRX0.20m_snaps"

    input_files = [
'Frame0.00_ns.png',
'Frame2.00_ns.png',
'Frame4.00_ns.png',
'Frame6.00_ns.png',
'Frame8.00_ns.png',
'Frame10.00_ns.png',
'Frame12.00_ns.png',
'Frame14.00_ns.png',
'Frame16.00_ns.png',
'Frame18.00_ns.png',
'Frame20.00_ns.png',
'Frame22.00_ns.png',
'Frame24.00_ns.png',
'Frame26.00_ns.png',
'Frame28.00_ns.png',
'Frame30.00_ns.png',
'Frame32.00_ns.png',
'Frame34.00_ns.png',
'Frame36.00_ns.png',
'Frame38.00_ns.png',
'Frame40.00_ns.png',
'Frame42.00_ns.png',
'Frame44.00_ns.png',
'Frame46.00_ns.png',
'Frame48.00_ns.png',
'Frame50.00_ns.png',
'Frame52.00_ns.png',
'Frame54.00_ns.png',
'Frame56.00_ns.png',
'Frame58.00_ns.png',
'Frame60.00_ns.png',
'Frame62.00_ns.png',
'Frame64.00_ns.png',
'Frame66.00_ns.png',
'Frame68.00_ns.png'
    ]


    images = create_pngImages(path,input_files)
    combine_images(nColumns, space, images, output_filename)


#Strong Gradient - No bottom reflector
    # input_files = [
    # 'HaSp_dx10.0m_eps5.0_00InfDi200MHzRX0_0.5m_dxRX0.20m.out.pdf' ,
    # 'HaSp_dx10.0m_eps12.5_00er0_5.0InfDi200MHzGoffset0.1mRX0_0.5m_dxRX0.20m.out.pdf' ,
    # 'HaSp_dx10.0m_eps12.5_++er0_5.0_h0.1mInfDi200MHzRX0_0.5m_dxRX0.20m.out.pdf' ,
    # 'HaSp_dx10.0m_eps5.0_00er0_12.5InfDi200MHzGoffset0.1mRX0_0.5m_dxRX0.20m.out.pdf' ,
    # 'HaSp_dx10.0m_eps5.0_--er0_12.5_h0.1mInfDi200MHzRX0_0.5m_dxRX0.20m.out.pdf' ,
    # 'HaSp_dx10.0m_eps12.5_00InfDi200MHzRX0_0.5m_dxRX0.20m.out.pdf' ,
    # 'HaSp_dx10.0m_eps12.5_00er0_5.0InfDi200MHzGoffset0.2mRX0_0.5m_dxRX0.20m.out.pdf' ,
    # 'HaSp_dx10.0m_eps12.5_++er0_5.0_h0.2mInfDi200MHzRX0_0.5m_dxRX0.20m.out.pdf' ,
    # 'HaSp_dx10.0m_eps5.0_00er0_12.5InfDi200MHzGoffset0.2mRX0_0.5m_dxRX0.20m.out.pdf' ,
    # 'HaSp_dx10.0m_eps5.0_--er0_12.5_h0.2mInfDi200MHzRX0_0.5m_dxRX0.20m.out.pdf' ,
    # 'HaSp_dx10.0m_eps5.0_00InfDi200MHzRX0_0.5m_dxRX0.20m.out.pdf' ,
    # 'HaSp_dx10.0m_eps12.5_00er0_5.0InfDi200MHzGoffset0.5mRX00.5m_dxRX0.20m.out.pdf' ,
    # 'HaSp_dx10.0m_eps12.5_++er0_5.0_h0.5mInfDi200MHzRX00.5m_dxRX0.20m.out.pdf' ,
    # 'HaSp_dx10.0m_eps5.0_00er0_12.5InfDi200MHzGoffset0.5mRX0_0.5m_dxRX0.20m.out.pdf' ,
    # 'HaSp_dx10.0m_eps5.0_--er0_12.5_h0.5mInfDi200MHzRX00.5m_dxRX0.20m.out.pdf' 
    # ]

#Weak Gradient - No bottom reflector
    # input_files = [
#      'HaSp_dx10.0m_eps5.0_00InfDi200MHzRX0_0.5m_dxRX0.20m.out.pdf' ,
# 'HaSp_dx10.0m_eps6.0_00er0_5.0InfDi200MHzGoffset0.1mRX0_0.5m_dxRX0.20m.out.pdf',
# 'HaSp_dx10.0m_eps6.0_++er0_5.0_h0.1mInfDi200MHzRX0_0.5m_dxRX0.20m.out.pdf',
# 'HaSp_dx10.0m_eps5.0_00er0_6.0InfDi200MHzGoffset0.1mRX0_0.5m_dxRX0.20m.out.pdf',
# 'HaSp_dx10.0m_eps5.0_--er0_6.0_h0.1mInfDi200MHzRX0_0.5m_dxRX0.20m.out.pdf',
#  'HaSp_dx10.0m_eps5.0_00InfDi200MHzRX0_0.5m_dxRX0.20m.out.pdf' ,
# 'HaSp_dx10.0m_eps6.0_00er0_5.0InfDi200MHzGoffset0.2mRX0_0.5m_dxRX0.20m.out.pdf',
# 'HaSp_dx10.0m_eps6.0_++er0_5.0_h0.2mInfDi200MHzRX0_0.5m_dxRX0.20m.out.pdf',
# 'HaSp_dx10.0m_eps5.0_00er0_6.0InfDi200MHzGoffset0.2mRX0_0.5m_dxRX0.20m.out.pdf',
# 'HaSp_dx10.0m_eps5.0_--er0_6.0_h0.2mInfDi200MHzRX0_0.5m_dxRX0.20m.out.pdf',
#  'HaSp_dx10.0m_eps5.0_00InfDi200MHzRX0_0.5m_dxRX0.20m.out.pdf' ,
# 'HaSp_dx10.0m_eps6.0_00er0_5.0InfDi200MHzGoffset0.5mRX0_0.5m_dxRX0.20m.out.pdf',
# 'HaSp_dx10.0m_eps6.0_++er0_5.0_h0.5mInfDi200MHzRX0_0.5m_dxRX0.20m.out.pdf',
# 'HaSp_dx10.0m_eps5.0_00er0_6.0InfDi200MHzGoffset0.5mRX0_0.5m_dxRX0.20m.out.pdf',
# 'HaSp_dx10.0m_eps5.0_--er0_6.0_h0.5mInfDi200MHzRX0_0.5m_dxRX0.20m.out.pdf']

#Strong Gradient -  bottom reflector
#     input_files = [
# 'HaSp_dx10.0m_eps5.0_00InfDi200MHz_br_RX0_0.5m_dxRX0.20m.out.pdf',
# 'HaSp_dx10.0m_eps12.5_00er0_5.0InfDi200MHz_br_Goffset0.1mRX0_0.5m_dxRX0.20m.out.pdf',
# 'HaSp_dx10.0m_eps12.5_++er0_5.0_h0.10mInfDi200MHz_br_RX0_0.5m_dxRX0.20m.out.pdf',
# 'HaSp_dx10.0m_eps5.0_00er0_12.5InfDi200MHz_br_Goffset0.1mRX0_0.5m_dxRX0.20m.out.pdf',
# 'HaSp_dx10.0m_eps5.0_--er0_12.5_h0.10mInfDi200MHz_br_RX0_0.5m_dxRX0.20m.out.pdf',
# 'HaSp_dx10.0m_eps12.5_00InfDi200MHz_br_RX0_0.5m_dxRX0.20m.out.pdf',
# 'HaSp_dx10.0m_eps12.5_00er0_5.0InfDi200MHz_br_Goffset0.2mRX0_0.5m_dxRX0.20m.out.pdf',
# 'HaSp_dx10.0m_eps12.5_++er0_5.0_h0.25mInfDi200MHz_br_RX0_0.5m_dxRX0.20m.out.pdf',
# 'HaSp_dx10.0m_eps5.0_00er0_12.5InfDi200MHz_br_Goffset0.2mRX0_0.5m_dxRX0.20m.out.pdf',
# 'HaSp_dx10.0m_eps5.0_--er0_12.5_h0.25mInfDi200MHz_br_RX0_0.5m_dxRX0.20m.out.pdf',
# 'HaSp_dx10.0m_eps12.5_00InfDi200MHz_br_RX0_0.5m_dxRX0.20m.out.pdf',
# 'HaSp_dx10.0m_eps12.5_00er0_5.0InfDi200MHz_br_Goffset0.5mRX0_0.5m_dxRX0.20m.out.pdf',
# 'HaSp_dx10.0m_eps12.5_++er0_5.0_h0.50mInfDi200MHz_br_RX0_0.5m_dxRX0.20m.out.pdf',
# 'HaSp_dx10.0m_eps5.0_00er0_12.5InfDi200MHz_br_Goffset0.5mRX0_0.5m_dxRX0.20m.out.pdf',
# 'HaSp_dx10.0m_eps5.0_--er0_12.5_h0.50mInfDi200MHz_br_RX0_0.5m_dxRX0.20m.out.pdf']   

#Weak Gradient -  bottom reflector
#     input_files = [
# 'HaSp_dx10.0m_eps5.0_00InfDi200MHz_br_RX0_0.5m_dxRX0.20m.out.pdf',
# 'HaSp_dx10.0m_eps6.0_00er0_5.0InfDi200MHz_br_Goffset0.1mRX0_0.5m_dxRX0.20m.out.pdf',
# 'HaSp_dx10.0m_eps6.0_++er0_5.0_h0.10mInfDi200MHz_br_RX0_0.5m_dxRX0.20m.out.pdf',
# 'HaSp_dx10.0m_eps5.0_00er0_6.0InfDi200MHz_br_Goffset0.1mRX0_0.5m_dxRX0.20m.out.pdf',
# 'HaSp_dx10.0m_eps5.0_--er0_6.0_h0.10mInfDi200MHz_br_RX0_0.5m_dxRX0.20m.out.pdf',
# 'HaSp_dx10.0m_eps12.5_00InfDi200MHz_br_RX0_0.5m_dxRX0.20m.out.pdf',
# 'HaSp_dx10.0m_eps6.0_00er0_5.0InfDi200MHz_br_Goffset0.2mRX0_0.5m_dxRX0.20m.out.pdf',
# 'HaSp_dx10.0m_eps6.0_++er0_5.0_h0.25mInfDi200MHz_br_RX0_0.5m_dxRX0.20m.out.pdf',
# 'HaSp_dx10.0m_eps5.0_00er0_6.0InfDi200MHz_br_Goffset0.2mRX0_0.5m_dxRX0.20m.out.pdf',
# 'HaSp_dx10.0m_eps5.0_--er0_6.0_h0.25mInfDi200MHz_br_RX0_0.5m_dxRX0.20m.out.pdf',
# 'HaSp_dx10.0m_eps5.0_00InfDi200MHz_br_RX0_0.5m_dxRX0.20m.out.pdf',
# 'HaSp_dx10.0m_eps6.0_00er0_5.0InfDi200MHz_br_Goffset0.5mRX0_0.5m_dxRX0.20m.out.pdf',
# 'HaSp_dx10.0m_eps6.0_++er0_5.0_h0.50mInfDi200MHz_br_RX0_0.5m_dxRX0.20m.out.pdf',
# 'HaSp_dx10.0m_eps5.0_00er0_6.0InfDi200MHz_br_Goffset0.5mRX0_0.5m_dxRX0.20m.out.pdf',
# 'HaSp_dx10.0m_eps5.0_--er0_6.0_h0.50mInfDi200MHz_br_RX0_0.5m_dxRX0.20m.out.pdf']


#Strong Gradient -  RLFLA TX
#     input_files = [
#     'HaSp_dx6.0m_eps5.0_00RLFLARX0_1.0m_dxRX0.20mTX-RLA.out.pdf',
#     'HaSp_dx6.0m_eps12.5_00er0_5.0RLFLAGoffset0.1mRX0_1.0m_dxRX0.20mTX-RLA.out.pdf',
#     'HaSp_dx6.0m_eps12.5_++er0_5.0_h0.1mRLFLARX0_1.0m_dxRX0.20mTX-RLA.out.pdf',
#     'HaSp_dx6.0m_eps5.0_--er0_12.5_h0.1mRLFLARX0_1.0m_dxRX0.20mTX-RLA.out.pdf',
#     'HaSp_dx6.0m_eps5.0_00RLFLARX0_1.0m_dxRX0.20mTX-RLA.out.pdf',
#     'HaSp_dx6.0m_eps12.5_00er0_5.0RLFLAGoffset0.2mRX0_1.0m_dxRX0.20mTX-RLA.out.pdf',
#     'HaSp_dx6.0m_eps12.5_++er0_5.0_h0.2mRLFLARX0_1.0m_dxRX0.20mTX-RLA.out.pdf',
#     'HaSp_dx6.0m_eps5.0_--er0_12.5_h0.5mRLFLARX0_1.0m_dxRX0.20mTX-RLA.out.pdf',
#     'HaSp_dx6.0m_eps5.0_00RLFLARX0_1.0m_dxRX0.20mTX-RLA.out.pdf',
#     'HaSp_dx6.0m_eps12.5_00er0_5.0RLFLAGoffset0.5mRX0_1.0m_dxRX0.20mTX-RLA.out.pdf',
#     'HaSp_dx6.0m_eps12.5_++er0_5.0_h0.5mRLFLARX0_1.0m_dxRX0.20mTX-RLA.out.pdf',
#     'HaSp_dx6.0m_eps5.0_--er0_12.5_h0.2mRLFLARX0_1.0m_dxRX0.20mTX-RLA.out.pdf'
# ]

#RLFLA Strong Gradient RX-RLFLA
#     input_files = [
# 'HaSp_dx6.0m_eps5.0_00RLFLARX0_1.0m_dxRX0.20mTX-RLARX-RLA.out.pdf',
# 'HaSp_dx6.0m_eps12.5_00er0_5.0RLFLAGoffset0.1mRX0_1.0m_dxRX0.20mTX-RLARX-RLA.out.pdf',
# 'HaSp_dx6.0m_eps12.5_++er0_5.0_h0.1mRLFLARX0_1.0m_dxRX0.20mTX-RLARX-RLA.out.pdf',
# 'HaSp_dx6.0m_eps5.0_--er0_12.5_h0.10mRLFLARX0_1.0m_dxRX0.20mTX-RLARX-RLA.out.pdf',
# 'HaSp_dx6.0m_eps5.0_00RLFLARX0_1.0m_dxRX0.20mTX-RLARX-RLA.out.pdf',
# 'HaSp_dx6.0m_eps12.5_00er0_5.0RLFLAGoffset0.2mRX0_1.0m_dxRX0.20mTX-RLARX-RLA.out.pdf',
# 'HaSp_dx6.0m_eps12.5_++er0_5.0_h0.2mRLFLARX0_1.0m_dxRX0.20mTX-RLARX-RLA.out.pdf',
# 'HaSp_dx6.0m_eps5.0_--er0_12.5_h0.25mRLFLARX0_1.0m_dxRX0.20mTX-RLARX-RLA.out.pdf',
# 'HaSp_dx6.0m_eps5.0_00RLFLARX0_1.0m_dxRX0.20mTX-RLARX-RLA.out.pdf',
# 'HaSp_dx6.0m_eps12.5_00er0_5.0RLFLAGoffset0.5mRX0_1.0m_dxRX0.20mTX-RLARX-RLA.out.pdf',
# 'HaSp_dx6.0m_eps12.5_++er0_5.0_h0.5mRLFLARX0_1.0m_dxRX0.20mTX-RLARX-RLA.out.pdf',
# 'HaSp_dx6.0m_eps5.0_--er0_12.5_h0.50mRLFLARX0_1.0m_dxRX0.20mTX-RLARX-RLA.out.pdf']

# RLFLA - Weak Gradient 3D
#     input_files = [
# 'HaSp_dx6.0m_eps6.0_00er0_5.0RLFLAGoffset0.10mRX0_1.0m_dxRX0.20m3D.out.pdf',
# 'HaSp_dx6.0m_eps6.0_00er0_5.0RLFLAGoffset0.20mRX0_1.0m_dxRX0.20m3D.out.pdf',
# 'HaSp_dx6.0m_eps6.0_00er0_5.0RLFLAGoffset0.30mRX0_1.0m_dxRX0.20m3D.out.pdf',
# 'HaSp_dx6.0m_eps6.0_00er0_5.0RLFLAGoffset0.40mRX0_1.0m_dxRX0.20m3D.out.pdf',
# 'HaSp_dx6.0m_eps6.0_00er0_5.0RLFLAGoffset0.50mRX0_1.0m_dxRX0.20m3D.out.pdf',
# 'HaSp_dx6.0m_eps6.0_00er0_5.0RLFLAGoffset0.70mRX0_1.0m_dxRX0.20m3D.out.pdf',
# 'HaSp_dx6.0m_eps6.0_00er0_5.0RLFLAGoffset1.00mRX0_1.0m_dxRX0.20m3D.out.pdf',
# 'HaSp_dx6.0m_eps6.0_++er0_5.0_h0.10mRLFLARX0_1.0m_dxRX0.20m3D.out.pdf',
# 'HaSp_dx6.0m_eps6.0_++er0_5.0_h0.20mRLFLARX0_1.0m_dxRX0.20m3D.out.pdf',
# 'HaSp_dx6.0m_eps6.0_++er0_5.0_h0.30mRLFLARX0_1.0m_dxRX0.20m3D.out.pdf',
# 'HaSp_dx6.0m_eps6.0_++er0_5.0_h0.40mRLFLARX0_1.0m_dxRX0.20m3D.out.pdf',
# 'HaSp_dx6.0m_eps6.0_++er0_5.0_h0.50mRLFLARX0_1.0m_dxRX0.20m3D.out.pdf',
# 'HaSp_dx6.0m_eps6.0_++er0_5.0_h0.70mRLFLARX0_1.0m_dxRX0.20m3D.out.pdf',
# 'HaSp_dx6.0m_eps6.0_++er0_5.0_h1.00mRLFLARX0_1.0m_dxRX0.20m3D.out.pdf',
# 'HaSp_dx6.0m_eps5.0_00er0_6.0RLFLAGoffset0.10mRX0_1.0m_dxRX0.20m3D.out.pdf',
# 'HaSp_dx6.0m_eps5.0_00er0_6.0RLFLAGoffset0.20mRX0_1.0m_dxRX0.20m3D.out.pdf',
# 'HaSp_dx6.0m_eps5.0_00er0_6.0RLFLAGoffset0.30mRX0_1.0m_dxRX0.20m3D.out.pdf',
# 'HaSp_dx6.0m_eps5.0_00er0_6.0RLFLAGoffset0.40mRX0_1.0m_dxRX0.20m3D.out.pdf',
# 'HaSp_dx6.0m_eps5.0_00er0_6.0RLFLAGoffset0.50mRX0_1.0m_dxRX0.20m3D.out.pdf',
# 'HaSp_dx6.0m_eps5.0_00er0_6.0RLFLAGoffset0.70mRX0_1.0m_dxRX0.20m3D.out.pdf',
# 'HaSp_dx6.0m_eps5.0_00er0_6.0RLFLAGoffset1.00mRX0_1.0m_dxRX0.20m3D.out.pdf',
# 'HaSp_dx6.0m_eps5.0_--er0_6.0_h0.10mRLFLARX0_1.0m_dxRX0.20m3D.out.pdf',
# 'HaSp_dx6.0m_eps5.0_--er0_6.0_h0.20mRLFLARX0_1.0m_dxRX0.20m3D.out.pdf',
# 'HaSp_dx6.0m_eps5.0_--er0_6.0_h0.30mRLFLARX0_1.0m_dxRX0.20m3D.out.pdf',
# 'HaSp_dx6.0m_eps5.0_--er0_6.0_h0.40mRLFLARX0_1.0m_dxRX0.20m3D.out.pdf',
# 'HaSp_dx6.0m_eps5.0_--er0_6.0_h0.50mRLFLARX0_1.0m_dxRX0.20m3D.out.pdf',
# 'HaSp_dx6.0m_eps5.0_--er0_6.0_h0.70mRLFLARX0_1.0m_dxRX0.20m3D.out.pdf',
# 'HaSp_dx6.0m_eps5.0_--er0_6.0_h1.00mRLFLARX0_1.0m_dxRX0.20m3D.out.pdf',
# ]