from vtkmodules.util.numpy_support import  vtk_to_numpy
import vtk
from selectSlice import get_2DSlice
import numpy as np
from tkinter import filedialog
import matplotlib.pyplot as plt
# <?xml version="1.0"?>
# <VTKFile type="ImageData" version="1.0" byte_order="LittleEndian">
# <ImageData WholeExtent="0 720 91 92 0 340" Origin="0 0 0" Spacing="0.01 0.01 0.01">
# <Piece Extent="0 720 91 92 0 340">
# <CellData Scalars="Material">
# <DataArray type="UInt32" Name="Material" format="appended" offset="0" />
# <DataArray type="Int8" Name="Sources_PML" format="appended" offset="979204" />
# <DataArray type="Int8" Name="Receivers" format="appended" offset="1224008" />
# </CellData>
# </Piece>
# </ImageData>
# <AppendedData encoding="raw">

def get_material2DArray(file, plane, idx):
    '''
    file: absolute path of geometry file
    plane, idx input for get_2DSlice
    '''
    reader = vtk.vtkXMLImageDataReader()
    reader.SetFileName(file)
    reader.Update()
    data        = reader.GetOutput()

    extent      = data.GetExtent()
    dimension   = data.GetDimensions()
  
    dimension   = data.GetDimensions()
    # get domain for matrix
    domainSize = np.zeros((len(dimension)), dtype=int)
    for iDim, index in enumerate(np.arange(0,len(extent),2)):
        domainSize[iDim] = extent[index+1] - extent[index]

    # flip it because i do not know why it works like this
    domainSize = np.flip(domainSize)

    cell_data   = data.GetCellData()
    materials   = cell_data.GetArray('Material')

    material1D = vtk_to_numpy(materials)

    material3D = material1D.reshape(domainSize)

    material2D = get_2DSlice(material3D, plane, idx)

    return material2D


if __name__ == '__main__':
    file_path = filedialog.askopenfilename()
    plane = 'z' #'y'
    idx = 0
    result2D = get_material2DArray(file_path, plane, idx)
    plt.imshow(result2D, origin='upper')
    plt.show()
