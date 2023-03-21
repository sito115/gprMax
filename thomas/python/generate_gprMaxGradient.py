
import time
import numpy as np 
from gprMax.input_cmd_funcs import *

def generateGradientDomain(dimensions:tuple, dxdydz:tuple ,srPos:tuple, recConfig:tuple, z_end:float, nDepths:int, h_scaling:float,
                           permitivities:dict, conductivities:dict, geomScale:int, nSnaps:int):
    '''
    Generates a domain with Free_Space, Followed by a Gradient and Halfspace in gprMax.

    dimension        : tuple [1x3] of x,y,z coordiantes of domain size
    dxdydz           : tuple [1x3] of x,y,z spatial discretization
    srPos            : tuple [1x3] of x,y,z coordiantes of source
    recConfig        : tuple [1x6] containing x,y,z and step size of receivers for rx_array
    z_end            : start of gradient, gradient/freespace interface
    nDepths          : number of discretizations in gradient layer
    h_scaling        : scaling of gradient layer, which has a thickness of dominant wavelength
    permitivies      : dictionary containing 'halfspace', 'er_0', 'er_h'
    conductivities   : dictionary containing 'halfspace', 'gradient'
    geomScale        : number of scaling step size for geometry file, negative for no file
    nSnaps           : number of snapshots, negative for no snapshot
    '''

    # Define Domain
    spatial_step    = dx_dy_dz(dxdydz[0], dxdydz[1], dxdydz[2])
    dim             = domain(x=dimensions[0], y=dimensions[1], z=dimensions[2])
    hFreeSpace      = 0.2

    # simulation time 3*maximum one way travel time
    tSim = (3* dim.y*np.sqrt(max(permitivities.values()))/(3e8))                   
    time_window(tSim)


    # source and receiver
    srcFc    = 200e6                # center freq of source

    # Gradient
    er_0      = permitivities['er_0']         # eps_r at gradient/halfspace interface
    er_h      = permitivities['er_h']         # eps_r at free_space/gradient interface
    #h         = 3e8 / (np.sqrt(0.5* (er_0 + er_h)) * srcFc) * h_scaling   # gradient thickness as thick as wavelength
    h         = 0.4
    z_0       = z_end - h                     # start of gradient


    # print title
    titleString = 'Permittivity Gradient:er_0 = %.1f, er_h = %.1f, thickness = %.1f, tSim = %.1e' %(permitivities['er_0'], permitivities['er_h'], h, tSim)
    command('title', titleString)

    # source waveform
    SrcIdentifier = waveform('ricker', amplitude = 1,
                            frequency  = srcFc,
                            identifier = 'my_ricker')

    # define materials
    material(permittivity=er_0, conductivity=conductivities['halfspace'],
            permeability=1, magconductivity=0, name='half_space')

    depths = np.linspace(z_0, z_end, num = nDepths)
    assert (depths[1] - depths[0]) > spatial_step[1], "Gradient discretization %f is smaller than spatial discretization %f" %(depths[1] - depths[0],  spatial_step[1])

    for count,z in enumerate(depths[1:]):
        e_r = er_0 + (er_h - er_0)/(z_end - z_0) * (z-z_0)
        material(permittivity=e_r, conductivity=conductivities['gradient'],
                permeability=1, magconductivity=0, name='er'+str(count))

    # Geomtry
    box(0, 0, 0, dim.x, z_0, dim.z , 'half_space')

    for i in range(len(depths[:-1])):
        box(0, depths[i], 0, dim.x, depths[i+1], dim.z,'er'+str(i))

    box(0, z_end, 0, dim.x, dim.y, dim.z, 'free_space')

    # TX and RX
    tx = hertzian_dipole('y',
                        srPos[0], srPos[1], srPos[2], 
                        SrcIdentifier)

    rxString = ' '.join(str(value) for value in (recConfig))
    command('rx_array', rxString)

    geometryFileName = 'geometryGradient_er0_%derh_%dh_%.2ftSim_%.2enDepths_%d-' % (er_0, er_h, h, tSim, nDepths)


    # Logicals
    if nSnaps > 0:
        for i in range(1, nSnaps+1):
            snapshot(0, 0, 0,
                    dim.x, dim.y, dim.z,
                    spatial_step.x, spatial_step.y, spatial_step.z,
                    i*(tSim/nSnaps), 'snapshot' + str(i))

    if geomScale > 0:
        # save geometry file with suffix
        timestr          = time.strftime("%y%m%d-%H%M")
        geometry_view(0, 0, 0, dim.x, dim.y, dim.z,spatial_step.x * geomScale, spatial_step.y * geomScale,
                      geomScale * spatial_step.z, geometryFileName, 'n')

    return geometryFileName                          


 