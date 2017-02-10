# -*- coding: utf-8 -*-

import math

def squared(v):
    """
    Computes squared value

    Parameters
    ----------

        v: any type with __mul__ defined
            value to be squared

    Return value
    ------------

        r: same type as v
            result of squaring
    """

    return v*v

def cubed(v):
    """
    Computes cubed value

    Parameters
    ----------

        v: any type with __mul__ defined
            value to be cubed

    Return value
    ------------

        r: same type as v
            result of cubing
    """

    return v*v*v

def hypot(x, y, z):
    """
    Computes hypotenuse in 3D
    """
    return math.sqrt(x*x + y*y + z*z)

def clamp(v, vmin, vmax):
    """
    Clamps value between vmin and vmax

    Parameters
    ----------

        v: any type with __lt__  and __gt__ defined
            value to be clamped

        vmin: convertible to the type of v
            clamp minimum value

        vmin: convertible to the type of v
            clamp maximum value

    Return value
    ------------

        r: same type as v
            clamped value
    """

    return vmin if v < vmin else vmax if v > vmax else v
