# -*- coding: utf-8 -*-

import os

from XcCore.OCPparam      import OCPparam
from XcIO.write_OCP       import write_OCP
from XcIO.print_OCPparam  import print_OCPparam

from XcMath       import utils
from XcMath       import point2d
from XcMath       import disc_2d
from XcMath       import disc_3d
from XcMath.idx   import X, Y, Z

def convert_to_OCP(xiw, yiw, xow, yow):
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

    Return value
    ------------

        r: tuple(array of floats, array of floats, array of floats, array of floats)
            X inner wall, Y inner wall, X outer wall, Y outer wall
            all in OCP format
    """

    yo = yiw[0]

    xxiw = - (yiw - yo)
    yyiw = xiw[:]

    xxow = - (yow - yo)
    yyow = xow[:]

    return (xxiw, yyiw, xxow, yyow)

def MakeOCP(RadUnit, OuterCup):
    """
    Make OCP from OCPparam
    """

    fname_is = os.path.join("CADCups", "OuterCups", "In", "R" + "{0}O{1}.ocpparam".format(RadUnit, OuterCup))

    ocprm = OCPparam(fname_is)

    print_OCPparam(ocprm)

    xiw, yiw, xciw, yciw = disc_2d.disc_2d(ocprm.InnerWall, 0.6)
    xow, yow, xcow, ycow = disc_2d.disc_2d(ocprm.OuterWall, 0.6)

    # all data we have is of type 1
    # no chenches to outer wall
    if ocprm.WallType == 2:
        xow = xow - ocprm.Origin[X]
        yow = yow - ocprm.Origin[Y]

        xcow = xcow - ocprm.Origin[X]
        ycow = ycow - ocprm.Origin[Y]

    xxiw, yyiw, xxow, yyow = convert_to_OCP(xiw, yiw, xow, yow)

    xf, yf, zf, xcf, ycf, zcf = disc_3d.disc_fiducial(ocprm.FiducialCurve, 0.6)

    write_OCP(RadUnit, OuterCup, xxiw, yyiw, xxow, yyow, xcf, ycf, zcf)

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

    rc = main(8, 3)

    print("The end")

    sys.exit(rc)
