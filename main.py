# -*- coding: utf-8 -*-

from XcCore.OCPparam import OCPparam

from XcMath       import utils
from XcMath       import point2d
from XcMath       import disc_2d

from XcMath.idx import X, Y

def print_OCPparam(ocprm):
    """
    Given the ocpparam object,
    print it contents
    """
    print("===== Print data =====")
    print(ocprm.RU)
    print(ocprm.OC)

    print(ocprm.DistanceBottomToCouch)

    print(ocprm.Origin)

    print(ocprm.WallType)

    print(ocprm.InnerWall)

    print(ocprm.OuterWall)

    print(ocprm.FiducialCurve)

def convert_to_OCP(xiw, yiw, xow, yow):
    """
    Take digitized curves and convert then to .OCP format
    """

    yo = yiw[0]

    xxiw = - (yiw - yo)
    yyiw = xiw[:]

    xxow = - (yow - yo)
    yyow = xow[:]

    return (xxiw, yyiw, xxow, yyow)

def main(fname):
    """
    Main function, reads and process one OCPparam file

    Parameters
    ----------

        fname: string
            input outer cup file name

    Return value
    ------------

        r: int
            return code
    """

    ocprm = OCPparam(fname)

    xiw, yiw, xciw, yciw = disc_2d.disc_2d(ocprm.InnerWall, 0.5)
    xow, yow, xcow, ycow = disc_2d.disc_2d(ocprm.OuterWall, 0.5)

    # all data we have is of type 1
    # no chenches to outer wall
    if ocprm.WallType == 2:
        xow = xow - ocprm.Origin[X]
        yow = yow - ocprm.Origin[Y]

        xcow = xcow - ocprm.Origin[X]
        ycow = ycow - ocprm.Origin[Y]

    xxiw, yyiw, xxow, yyow = convert_to_OCP(xiw, yiw, xow, yow)

    return 0

if __name__ == "__main__":

    import sys

    fname = "C:/Users/kriol/Documents/Python/DataPrep/Programs_n_Docs/OuterCups/In/R8O3.ocpparam"

    rc = main(fname)

    print("The end")

    sys.exit(rc)
