def get_2DSlice(array, plane, idx):
    '''
    array (3D)
    plane (x,y,z)
    idx
    '''
    if plane == 'x':
        array = array[idx,:,:]
    elif plane == 'y':
        array = array[:,idx,:]
    elif plane == 'z':
        array = array[idx,:,:]
    else:
        print('Wrong syntax for plane')
    return array

