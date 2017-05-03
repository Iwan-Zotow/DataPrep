# -*- coding: utf-8 -*-

from __future__ import print_function

import os
import sys

r"""
converts calculation array to ICP format
"""

if __name__ == "__main__":

    if len(sys.argv) == 1:
        print("Gimme me a file name")
        sys.exit(1)

    shift = 0.0
    if len(sys.argv) >= 3:
        shift = float(sys.argv[2])

    with open(sys.argv[1]) as f:
        # RU
        line = f.readline().rstrip('\n')
        print(line)

        # Outer cup
        line = f.readline().rstrip('\n')
        print(line)

        # Inner cup
        line = f.readline().rstrip('\n')
        print(line)

        # nof points in the inner wall
        line = f.readline().rstrip('\n')
        niw = int(line)
        print(line)

        # inner wall
        for k in range(niw):
            line = f.readline().rstrip('\n')
            s = line.split(' ')
            z = float(s[0]) - shift
            r = float(s[1])
            print("{0:13.6e} {1:13.6e}".format(z, r))

        # nof points in the outer wall
        line = f.readline().rstrip('\n')
        now = int(line)
        print(line)

        # inner wall
        for k in range(now):
            line = f.readline().rstrip('\n')
            s = line.split(' ')
            z = float(s[0]) - shift
            r = float(s[1])
            print("{0:13.6e} {1:13.6e}".format(z, r))

    sys.exit(0)
