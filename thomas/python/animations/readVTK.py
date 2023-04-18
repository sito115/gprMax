import numpy as np
from vtkmodules.util.numpy_support import  vtk_to_numpy
import vtk
from selectSlice import get_2DSlice

# <?xml version="1.0"?>
# <VTKFile type="ImageData" version="1.0" byte_order="LittleEndian">
# <ImageData WholeExtent="0 720 91 92 0 340" Origin="0 0 0" Spacing="0.01 0.01 0.01">
# <Piece Extent="0 720 91 92 0 340">
# <CellData Vectors="E-field H-field">
# <DataArray type="Float32" Name="E-field" NumberOfComponents="3" format="appended" offset="0" />
# <DataArray type="Float32" Name="H-field" NumberOfComponents="3" format="appended" offset="2937604" />
# </CellData>
# </Piece>
# </ImageData>
# <AppendedData encoding="raw">
# _ Ó, O}"¥Ö´

def get_2D_VTKarray(field, component, plane, idx, filename=None):
    '''
    filename 
    field = 'E-field' or 'H-field'
    component = 0,1,2 for 'x','y','z'
    '''

    assert field == 'E-field' or field == 'H-field'
    assert component in (0,1,2) 

    if filename is None:
        filename = 'snapHalfSpace_dx6.0m_eps_5.0_i3D1_er0_12.5_h0.5mDecreaseRLFLAdt_1.00e-09_42.vti'
    # Create a reader for the VTI file

    reader = vtk.vtkXMLImageDataReader()
    reader.SetFileName(filename)
    reader.Update()
    data    = reader.GetOutput()

    # origin      = data.GetOrigin()
    # #  xs, xf, ys, yf, zs, zf
    # bounds      = data.GetBounds()
    # spacing     = data.GetSpacing()
    # scalarType  = data.GetScalarType()
    extent      = data.GetExtent()
    dimension   = data.GetDimensions()
  

    dimension   = data.GetDimensions()
    # get domain for matrix
    domainSize = np.zeros((len(dimension)), dtype=int)
    for iDim, index in enumerate(np.arange(0,len(extent),2)):
        domainSize[iDim] = extent[index+1] - extent[index]

    # flip it because i do not know why it works like this
    domainSize = np.flip(domainSize)

    # get E and H fields cell
    cell_data = data.GetCellData()
    fields  = cell_data.GetArray(field)

    result1D = vtk_to_numpy(fields)[:, component]
    result3D = result1D.reshape(domainSize)
    result2D = get_2DSlice(result3D, plane, idx)

    return result2D
