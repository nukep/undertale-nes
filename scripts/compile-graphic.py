#!/usr/bin/env python3

import sys
import os

def read_graphic_file(filename, chrset):
    macroname = "graphic_"+os.path.basename('.'.join(filename.split('.')[:-1]))
    with open(filename, 'r') as f:
        str = f.read().strip()
        data = [[[int(z, 16) for z in y.split('-')] for y in x.split()] for x in str.strip().split('\n')]
        print("macro {} x y".format(macroname))
        y = 0
        for line in data:
            print("lda #>($2000+y*32+x+{})".format(y))
            print("sta $2006")
            print("lda #<($2000+y*32+x+{})".format(y))
            print("sta $2006")
            for attribute, tile in line:
                print("lda #{}_{:02x}".format(chrset, tile))
                print("sta $2007")
            y += 32
        print("endm")

read_graphic_file(sys.argv[1], sys.argv[2])
