# -*- coding: utf-8 -*-

import os
import numpy as np

from XcCore.OCPparam      import OCPparam
from XcIO.write_OCP       import write_OCP
from XcIO.print_OCPparam  import print_OCPparam

from XcMath          import utils
from XcMath.point2d  import point2d
from XcMath.point3d  import point3d
from XcMath          import disc_2d
from XcMath          import disc_3d
from XcMath.idx      import X, Y, Z
from rdp             import rdp

def convert_to_OCP(xiw, yiw, xow, yow, xf, yf, zf):
    """
    Take digitized curves and convert then to .OCP format

    Parameters
    ----------

        xiw: array of floats
            X inner wall

        yiw: array of floats
            Y inner wall

        xow: array of floats
            X outer wall

        yow: array of floats
            Y outer wall

        xf: array of floats
            X fiducial curve

        yf: array of floats
            Y fiducial curve

        yf: array of floats
            Y fiducial curve

        zf: array of floats
            Z fiducial curve

    Return value
    ------------

        r: tuple(array of floats, array of floats, array of floats, array of floats, array of floats, array of floats, array of floats)
            X inner wall, Y inner wall, X outer wall, Y outer wall, X fiducial, Y fiducial, Z fiducial
            all in OCP format/CS
    """

    yo = yiw[0]

    xxiw = - (yiw - yo)
    yyiw = xiw[:]

    xxow = - (yow - yo)
    yyow = xow[:]

    xfc = -zf
    yfc =  xf[:]
    zfc = -(yf - yo)

    return (xxiw, yyiw, xxow, yyow, xfc, yfc, zfc)

def MakeOCP(RadUnit, OuterCup):
    """
    Make OCP from OCPparam
    """

    fname_is = os.path.join("CADCups", "OuterCups", "In", "R" + "{0}O{1}.ocpparam".format(RadUnit, OuterCup))

    ocprm = OCPparam(fname_is)

    # print_OCPparam(ocprm)

    xiw, yiw, xciw, yciw = disc_2d.disc_2d(ocprm.InnerWall, 3.0)
    xow, yow, xcow, ycow = disc_2d.disc_2d(ocprm.OuterWall, 3.0)

    # all data we have is of type 1
    # no chenches to outer wall
    if ocprm.WallType == 2:
        xow = xow - ocprm.Origin[X]
        yow = yow - ocprm.Origin[Y]

        xcow = xcow - ocprm.Origin[X]
        ycow = ycow - ocprm.Origin[Y]

    xf, yf, zf, xcf, ycf, zcf = disc_3d.disc_fiducial(ocprm.FiducialCurve, 0.05)

    xxiw, yyiw, xxow, yyow, xxcf, yycf, zzcf = convert_to_OCP(xiw, yiw, xow, yow, xf, yf, zf)

#    for k in range(len(xcf)):
#        print("{0}  {1}  {2}".format(xxcf[k], yycf[k], zzcf[k]))

    iw = [point2d(np.float32(x), np.float32(y)) for x, y in zip(xxiw, yyiw)]
    iw = point2d.remove_dupes(iw, 0.5)

    ow = [point2d(np.float32(x), np.float32(y)) for x, y in zip(xxow, yyow)]
    ow = point2d.remove_dupes(ow, 0.5)

    fc = list(zip(xxcf, yycf, zzcf))
    fc = point3d.cvt2array(rdp(fc, 0.01))

    write_OCP(RadUnit, OuterCup, ocprm.DistanceBottomToCouch, iw, ow, fc)

def main(RadUnit, OuterCup):
    """
    Main function, reads and process one OCPparam file

    Parameters
    ----------

        RadUnit: int
            radiation unit

        OuterCup

    Return value
    ------------

        r: int
            return code
    """

    MakeOCP(RadUnit, OuterCup)

    return 0

if __name__ == "__main__":

    import sys

    rc = main(8, 1)

    print("The end")

    sys.exit(rc)
