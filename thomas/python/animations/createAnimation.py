import os
from tkinter.filedialog import askdirectory
from readVTK import get_2D_VTKarray 
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import numpy as np
from natsort import natsorted
from displayGeometry import get_material2DArray

def createAnimation(fileGeom,folderSnaps,
                    field, plane,idx, inter, alphaValue,
                    absoluteScaling, title,dt, ax, fig):
    '''
    fileGeom: absolute path of geometry file or None
    folderSnaps: absolute path of folder containing snaps
    displayFile: name to be displayed
    field: 'E-field' or 'H-field'
    plane: 'x','y','z'
    idx: index of direction perpendicular to plane, if 2D idx is 0
    inter: interval of animation in ms
    alphaValue: transparency of animation
    absoluteScaling: symmetric scaling for colormap 
    title : titleString
    dt : time step
    ax : axis object
    fig : figure object
    '''

    def createFullPath(path,file):
        return os.path.join(path,file)

    files       = os.listdir(folderSnaps)
    # filesSorted = natsorted(files)
    filesSorted = sorted(files, key=lambda x:int(x.split('_')[1].split('.')[0].split('snap')[1]))

    planeComMappingTable = {'x':2, 'y':1, 'z':0}
    component            = planeComMappingTable[plane]

    # fig, ax = plt.subplots()
    if fileGeom is not None:
        geometry2D = get_material2DArray(fileGeom, plane, idx)
        # display geometry
        ax.imshow(geometry2D,
                origin='lower',
                cmap = 'binary',
                alpha = 0.6)

              # binary, Greens

    # create animation
    firstData = get_2D_VTKarray(field, component,plane,idx,
                createFullPath(folderSnaps,filesSorted[0]))
    im      = ax.imshow(firstData,
                        cmap='jet',
                        origin='lower',
                        alpha=alphaValue,
                        vmin=-absoluteScaling,
                        vmax=absoluteScaling)
    text = ax.text(0.02, 0.95, '', transform=ax.transAxes)



    def animationUpdate(i):
        data = get_2D_VTKarray(field, component,plane,idx,
                                createFullPath(folderSnaps,filesSorted[i]))
        im.set_data(data)
        text.set_text('Time: %.3e s' %(i*dt))
        return im

    ani = animation.FuncAnimation(fig, animationUpdate, frames=range(len(filesSorted)),
                                blit=False, interval=inter)

    im_ratio = firstData.shape[0]/firstData.shape[1]
    # Add a colorbar to the plot
    fig.colorbar(im,ax=ax, fraction=0.047*im_ratio)

    # Set plot title and axes labels
    ax.set(
        xlabel = "[cm]",
        ylabel = "[cm]")

    ax.set_title(title)
    return ani


if __name__ == '__main__':
    folderGeo       = r"C:\\OneDrive - Delft University of Technology\\3. Semester - Studienunterlagen\\Thesis\\gprMaxFolder\\gprMax\\ProcessedFiles"
    snapFile        = askdirectory()
    snapFolderName  = os.path.basename(snapFile)
    #geomFile        = os.path.join(folderGeo,'',snapFolderName.replace('_snaps','.vti'))
    field           = 'E-field'
    inter           = 400
    alphaValue      = 0.5
    absoluteScaling = 1e-5
    plane           = 'y'
    idx             = 0
    isSave          = True
    dt              = 1                        

    fig, ax = plt.subplots()

    anim = createAnimation(None,snapFile,
                    field, plane,idx, inter, alphaValue,
                    absoluteScaling, snapFolderName,dt, ax, fig)
    
    plt.show()
