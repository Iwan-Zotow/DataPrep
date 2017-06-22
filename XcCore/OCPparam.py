# -*- coding: utf-8 -*-

import logging

from XcIO import ReadOCPparam

class OCPparam:
    """
    Class to hold OCP params data,

    Contains curves for both inner outer cup and outer outer cup,
    plus fiducial curve
    """

    def __init__(self, fname):
        """
        Inner OCPPARAM cup data constructor

        Parameters
        ----------

        fname: string
            OCPPARAM file name
        """

        self._fname = fname

        self._RadU = None
        self._OutC = None

        self._DistanceBottomOCToCouch = None
        self._OCOrigin                = None
        self._OCWallType              = None

        self._OCInnerWall   = None
        self._OCOuterWall   = None
        self._FiducialCurve = None

        self.init_from_file()

    def init_from_file(self):
        """
        Read cup data from CAD file
        """

        logging.info("OCPparam::init_from_file: {0}".format(self._fname))

        try:
            RadU, OutC, DistanceBottomToCouch, Origin, WallType, InnerWall, OuterWall, FiducialCurve = ReadOCPparam.ReadOCPparam(self._fname)
        except Exception as e:
            e.args += ("OCPparam::Bad read of outer cup {0}".format(self._fname),)
            raise

        self._RadU = RadU
        self._OutC = OutC

        self._DistanceBottomToCouch = DistanceBottomToCouch
        self._Origin                = Origin
        self._WallType              = WallType

        self._InnerWall     = InnerWall
        self._OuterWall     = OuterWall
        self._FiducialCurve = FiducialCurve

        logging.info("OCPparam::init_from_file done")

    @property
    def RU(self):
        return self._RadU

    @property
    def OC(self):
        return self._OutC

    @property
    def DistanceBottomToCouch(self):
        return self._DistanceBottomToCouch

    @property
    def Origin(self):
        return self._Origin

    @property
    def WallType(self):
        return self._WallType

    @property
    def InnerWall(self):
        return self._InnerWall

    @property
    def OuterWall(self):
        return self._OuterWall

    @property
    def FiducialCurve(self):
        return self._FiducialCurve

if __name__ == "__main__":

    import sys

    ocpp = OCPparam("C:/Users/oleg.krivosheev/Documents/Python/DataPrep/Programs_n_Docs/OuterCups/In/R8O1.ocpparam")

    sep = "========================"
    print(sep)
    print(ocpp.RU)
    print(sep)
    print(ocpp.OC)
    print(sep)
    print(ocpp.DistanceBottomToCouch)
    print(sep)
    print(ocpp.Origin)
    print(sep)
    print(ocpp.WallType)
    print(sep)
    print(ocpp.InnerWall)
    print(sep)
    print(ocpp.OuterWall)
    print(sep)
    print(ocpp.FiducialCurve)
    print(sep)

    # for x, y in map(lambda x, y: (x,y), ocpp._xxiw, ocpp._yyiw):
    #     print(x, y)
    # print("========================")
    # for x, y in map(lambda x, y: (x,y), ocpp._xxow, ocpp._yyow):
    #     print(x, y)
