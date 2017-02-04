# -*- coding: utf-8 -*-

from XcCore.OCPparam import OCPparam

def main(fname):
    """
    Main function, reads and process one OCPparam file

    Parameters
    ----------

        fname: string
            input outer cup file name

        returns: int
            return code
    """

    ocprm = OCPparam(fname)

    print("===== Print data =====")
    print(ocprm.RU)
    print(ocprm.OC)

    print(ocprm.DistanceBottomToCouch)

    print(ocprm.Origin)

    print(ocprm.WallType)

    print(ocprm.InnerWall)

    print(ocprm.OuterWall)

    print(ocprm.FiducialCurve)

    return 0

if __name__ == "__main__":

    import sys

    rc = main("C:/Users/kriol/Documents/Python/DataPrep/Programs_n_Docs/OuterCups/In/R8O3.ocpparam")

    sys.exit(rc)
