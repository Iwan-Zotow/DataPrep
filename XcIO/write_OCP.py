# coding: utf-8

import os
import numpy as np

from XcMath.point2d import point2d
from XcMath.point3d import point3d

def write2d(f, points):
    """
    Given the list of 2D points, write them to file f
    """

    if len(points) == 0:
        return

    f.write("{0}\n".format(len(points)))

    for pt in points:
        f.write("{0:13.6e} {1:13.6e}\n".format(pt.x, pt.y))

def write3dcon(f, l):
    """
    Given length l write connectivity string to f
    """

    if l <= 1: # at least 2
        return

    f.write("{0:d}\n".format(l-1))
    for k in range(0, l-1):
        f.write("{0:<d} {1:<d}\n".format(k, k+1))

def write3d(f, points):
    """
    Given the list of 3D points, write them to file f
    """

    l = len(points)
    if l == 1:
        return

    f.write("{0}\n".format(l))

    for pt in points:
        f.write("{0:13.6e} {1:13.6e} {2:13.6e}\n".format(pt.x, pt.y, pt.z))
    write3dcon(f, l)

def write_OCP(RadUnit, OuterCup, xiw, yiw, xow, yow, xf, yf, zf):

    fname = os.path.join(".",  "RR" + "{0}O{1}.ocp".format(RadUnit, OuterCup))

    with open(fname, 'w', encoding='utf-8') as f:
        # inner cup
        points = [point2d(np.float32(x), np.float32(y)) for x, y in zip(xiw, yiw)]
        write2d(f, points)

        # outer cup
        points = [point2d(np.float32(x), np.float32(y)) for x, y in zip(xow, yow)]
        write2d(f, points)

        # fiducial
        points = [point3d(np.float32(x), np.float32(y), np.float32(z)) for x, y, z in zip(xf, yf, zf)]
        write3d(f, points)

if __name__ == "__main__":

    pts2d = list()
    pts2d.append(point2d(1.0, 2.0))
    pts2d.append(point2d(2.0, 1.0))

    pts3d = list()
    pts3d.append(point3d(1.0, 2.0, 3.0))
    pts3d.append(point3d(1.0, 3.0, 2.0))
    pts3d.append(point3d(5.0, 2.0, 3.0))

    fname = "T.ocp"
    with open(fname, 'w+') as f:
        write2d(f, pts2d)
        write3d(f, pts3d)
