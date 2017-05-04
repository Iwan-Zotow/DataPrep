# -*- coding: utf-8 -*-

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
        sys.stdout.write(line)
        sys.stdout.write("\n")

        # Outer cup
        line = f.readline().rstrip('\n')
        sys.stdout.write(line)
        sys.stdout.write("\n")

        # Inner cup
        line = f.readline().rstrip('\n')
        sys.stdout.write(line)
        sys.stdout.write("\n")

        # nof points in the inner wall
        line = f.readline().rstrip('\n')
        niw = int(line)
        sys.stdout.write(line)
        sys.stdout.write("\n")

        # inner wall
        for k in range(niw):
            line = f.readline().rstrip('\n')
            s = line.split(' ')
            s = [x for x in s if x] # remove empty lines
            z = float(s[0]) - shift
            r = float(s[1])
            sys.stdout.write("{0:13.6e} {1:13.6e}\n".format(z, r))

        # nof points in the outer wall
        line = f.readline().rstrip('\n')
        now = int(line)
        sys.stdout.write(line)
        sys.stdout.write("\n")

        # outer wall
        for k in range(now):
            line = f.readline().rstrip('\n')
            s = line.split(' ')
            s = [x for x in s if x] # remove empty lines
            z = float(s[0]) - shift
            r = float(s[1])
            sys.stdout.write("{0:13.6e} {1:13.6e}\n".format(z, r))

    sys.exit(0)
