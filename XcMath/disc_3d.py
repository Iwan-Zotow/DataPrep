#
# This module is about discretization of different 3d elements
# For a given element and tolerance it produces set of
# discretized (x,y) points
#

import math
import numpy as np

r"""
This module is about discretization of different 3d elements
For a given element and tolerance it produces set of
discretized (x,y) points
"""

def disc_line_segment(xs, ys, zs, xe, ye, ze, tol):
    """
    Given start (x,y,z) point and end (x,y,z) point
    return discretized array of points

    Parameter
    ---------

        xs: float
            start X

        ys: float
            start Y

        zs: float
            start Z

        xe: float
            end X

        ye: float
            end Y

        ze: float
            end Z

        tol: float
            tolerance

    Return value
    ------------
        r: tuple(numpy.array, numpy.array, numpy.array)
            discretized X and Y and Z coordinates
    """

    x = []
    y = []
    z = []

    if xs == None or ys == None or zs == None:
        return (None, None, None)
    if xe == None or ye == None or ze == None:
        return (None, None, None)

    d = math.hypot(xe - xs, math.hypot(ye - ys, ze - zs))
    K = int(d/tol) + 2

    return (np.linspace(xs, xe, num=K), np.linspace(ys, ye, num=K), np.linspace(zs, ze, num=K))

def disc_3d(commands, tol):
    """
    Given the array of commands  and the tolerance, produce discretized arrays
    """

    # discretized curve
    x = []
    y = []
    z = []
    # control points
    xc = []
    yc = []
    zc = []

    cur_x = None
    cur_y = None
    cur_z = None

    for command in commands:
        s = command.split(" ")
        s = [q for q in s if q] # remove empty strings

        cmd = s[0]

        if "newfcsegment" in cmd:
            px = float(s[1])
            py = float(s[2])
            pz = float(s[3])
            x.append(px)
            y.append(py)
            z.append(pz)
            xc.append(px)
            yc.append(py)
            zc.append(pz)
            cur_x = px
            cur_y = py
            cur_z = pz

        elif "lineto" in cmd:
            px = float(s[1])
            py = float(s[2])
            pz = float(s[3])

            xs, ys, zs = disc_line_segment(cur_x, cur_y, cur_z, px, py, pz, tol)
            x.extend(xs)
            y.extend(ys)
            z.extend(zs)
            xc.append(px)
            yc.append(py)
            zc.append(pz)
            cur_x = px
            cur_y = py
            cur_z = pz

        elif "arcto" in cmd:
            raise RuntimeError("Not Implemented")

        elif "spiralto" in cmd:
            raise RuntimeError("Not Implemented")

        elif "closefcsegment" in cmd:
            break

        else:
            raise RuntimeError("disc_3d::unknown command {0}".format(cmd))

    return (np.asarray(x), np.asarray(y), np.asarray(z),
            np.asarray(xc), np.asarray(yc), np.asarray(zc))

def disc_fiducial(curve, tol):
    """
    Given the curve and the tolerance, produce discretized arrays
    """

    commands = curve.split(";")

    first = commands[0]
    last  = commands[-1]

    if first != "newfc":
        raise RuntimeError("No newfc command in the fiducial curve")

    if last != "closefc":
        raise RuntimeError("No closefc command in the fiducial curve")

    del commands[-1]
    del commands[0]

    return disc_3d(commands, tol)
