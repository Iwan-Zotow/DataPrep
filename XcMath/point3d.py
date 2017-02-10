# -*- coding: utf-8 -*-

import numpy as np

from XcMath.idx   import X, Y, Z
from XcMath.utils import hypot
from XcMath.utils import squared

r"""This module implements 3D FP point"""

class point3d(object):
    """
    3D point made from three floats
    """

    def __init__(self, x = np.float32(0.0), y = np.float32(0.0), z = np.float32(0.0)):
        """
        Constructor. Build point from x and y and z

        Parameters
        ----------

        x: float
            point X position
        y: float
            point Y position
        z: float
            point Z position
        """

        self._x = np.float32( x )
        self._y = np.float32( y )
        self._z = np.float32( z )

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

    @property
    def z(self):
        """
        returns: float
            point Z position
        """
        return self._z

    def __str__(self):

        """
        returns: string
            default string representation
        """
        return "({0}, {1}, {2})".format(self._x, self._y, self._z)

    def __repr__(self):
        """
        returns: string
            default representation
        """
        return "{0} {1} {2}".format(self._x, self._y, self._z)

    def __getitem__(self, i):
        """
        Given the index i, returns the proper item
        """
        if i < X:
            raise IndexError("point3d::__getitem__: negative index {0}".format(i))
        if i == X:
            return self._x
        if i == Y:
            return self._y
        if i == Z:
            return self._z
        # beyond Z
        raise IndexError("point3d::__getitem__: index too large {0}".format(i))

    def __setitem__(self, i, value):
        """
        Given the index i, set proper item to value
        """
        if i < X:
            raise IndexError("point3d::__setitem__: negative index {0}".format(i))
        if i == X:
            self._x = value
            return
        if i == Y:
            self._y = value
            return
        if i == Z:
            self._z = value
            return
        # beyond Z
        raise IndexError("point3d::__setitem__: index too large {0}".format(i))

    def __add__(self, other):
        """
        Addition operator
        """
        return point3d(self._x + other._x, self._y + other._y, self._z + other._z)

    def __sub__(self, other):
        """
        Substraction operator
        """
        return point3d(self._x - other._x, self._y - other._y, self._z - other._z)

    @staticmethod
    def distance(pa, pb):
        return hypot(pa._x - pb._x, pa._y - pb._y, pa._z - pb._z)

    @staticmethod
    def distance2(pa, pb):
        return squared(pa._x - pb._x) + squared(pa._y - pb._y) + squared(pa._z - pb._z)

if __name__ == "__main__":

    p = point3d(12.0, 11.0, 10.0)
    y = point3d(10.0, 11.0, 12.0)

    print("X = {0}".format(p.x))
    print("Y = {0}".format(p.y))
    print("Z = {0}".format(p.z))
    print(str(p))
    print(repr(p))
    print(p[Z])
    print(p[Y])
    print(p[X])

    print(point3d.distance(p, y))
    print(point3d.distance(y, p))
    print(point3d.distance2(p, y))
