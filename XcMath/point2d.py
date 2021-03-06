# -*- coding: utf-8 -*-

import math
import numpy as np

from XcMath.utils  import squared
from XcMath.idx    import X, Y

r"""
This module implements 2D FP point
"""

class point2d(object):
    """
    2D point made from two floats
    """

    def __init__(self, x = np.float32(0.0), y = np.float32(0.0)):
        """
        Constructor. Build point from x and y

        Parameters
        ----------

        x: float
            point X position
        y: float
            point Y position
        """

        self._x = np.float32( x )
        self._y = np.float32( y )

    @property
    def x(self):
        """
        returns: float
            point X position
        """
        return self._x

    @property
    def y(self):
        """
        returns: float
            point Y position
        """
        return self._y

    def __str__(self):
        """
        returns: string
            default string representation
        """
        return "({0}, {1})".format(self._x, self._y)

    def __repr__(self):
        """
        returns: string
            default representation
        """
        return "{0} {1}".format(self._x, self._y)

    def __getitem__(self, i):
        """
        Given the index i, returns the proper item
        """
        if i < X:
            raise IndexError("point2d::__getitem__: negative index {0}".format(i))
        if i == X:
            return self._x
        if i == Y:
            return self._y
        # beyond Y
        raise IndexError("point2d::__getitem__: index too large {0}".format(i))

    def __setitem__(self, i, value):
        """
        Given the index i, set proper item to value
        """
        if i < X:
            raise IndexError("point2d::__setitem__: negative index {0}".format(i))
        if i == X:
            self._x = value
            return
        if i == Y:
            self._y = value
            return
        # beyond Y
        raise IndexError("point2d::__setitem__: index too large {0}".format(i))

    def __add__(self, other):
        """
        Addition operator
        """
        return point2d(self._x + other._x, self._y + other._y)

    def __sub__(self, other):
        """
        Substraction operator
        """
        return point2d(self._x - other._x, self._y - other._y)

    @staticmethod
    def distance(pa, pb):
        return math.hypot(pa._x - pb._x, pa._y - pb._y)

    @staticmethod
    def distance2(pa, pb):
        return squared(pa._x - pb._x) + squared(pa._y - pb._y)

    @staticmethod
    def remove_dupes(pts, tol):
        """
        Given list of points, remove duplicates
        """

        l = len(pts)
        rc = []
        pt_prev = pts[0]
        rc.append(pt_prev)
        for k in range(1, l):
            pt = pts[k]
            if point2d.distance(pt_prev, pt) > tol:
                rc.append(pt)

            pt_prev = pt

        return rc

if __name__ == "__main__":

    p = point2d(12.0, 11.0)
    y = point2d(11.0, 12.0)

    print("X = {0}".format(p.x))
    print("Y = {0}".format(p.y))
    print(str(p))
    print(repr(p))
    print(p[0])
    print(p[1])
    print(point2d.distance(p, y))
    print(point2d.distance2(p, y))
