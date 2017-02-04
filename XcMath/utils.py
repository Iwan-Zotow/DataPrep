# -*- coding: utf-8 -*-

def squared(v):
    """
    Computes squared value

    Parameters
    ----------

        v: any type with __mul__ defined
            value to be squared

    returns: something
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

    returns: something
        result of cubing
    """

    return v*v*v

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

    returns: something
        clamped value
    """

    return vmin if v < vmin else vmax if v > vmax else v
