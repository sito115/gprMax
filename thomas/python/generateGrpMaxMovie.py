import os
from tkinter.filedialog import askdirectory
from readVTK import convertSnap2Numpy 
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import matplotlib.colors as colors
import numpy as np
from natsort import natsorted

folder = 'C:/Users/thomas/Downloads/HalfSpace_dx6.0m_eps_5.0_i3D1_er0_12.5_h0.5mDecreaseRLFLA_snaps'
if not folder:
    folder = askdirectory()

files       = os.listdir(folder)
filesSorted = natsorted(files)


def createFullPath(path,file):
    return os.path.join(path,file)

field     = 'E-field'
component = 1
inter     = 300
alphaValue = 0.7
absoluteScaling = 1e-5

firstData = convertSnap2Numpy(field, component,
            createFullPath(folder,filesSorted[0]))[:,0,:]



fig, ax = plt.subplots()
im      = ax.imshow(firstData,
                    cmap='jet',
                    origin='upper',
                    alpha=alphaValue,
                    vmin=-absoluteScaling,
                    vmax=absoluteScaling)
text = ax.text(0.02, 0.95, '', transform=ax.transAxes)



def animationUpdate(i):
    data = convertSnap2Numpy(field, component,
                             createFullPath(folder,filesSorted[i]))[:,0,:]
    im.set_data(data)
    text.set_text('Iteration Number: {}'.format(i))
    return [im]

ani = animation.FuncAnimation(fig, animationUpdate, frames=range(len(filesSorted)),
                              blit=False, interval=inter)

# Add a colorbar to the plot
cbar = plt.colorbar(im)


plt.show()