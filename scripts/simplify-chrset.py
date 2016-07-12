#!/usr/bin/env python3

import sys

def read_tile(b):
    assert len(b) == 16

    def t(x, y):
        assert x < 8
        assert y < 8
        x = 7-x
        lo = 1 if (b[y+0] & (1<<x)) != 0 else 0
        hi = 2 if (b[y+8] & (1<<x)) != 0 else 0
        return hi + lo

    return tuple([tuple([t(x,y) for x in range(0, 8)]) for y in range(0, 8)])

def bytes_to_tiles(b):
    assert len(b) % 16 == 0
    return [read_tile(b[i*16:(i+1)*16]) for i in range(0, len(b)//16)]

def read_tiles(filename):
    with open(filename, "rb") as f:
        return bytes_to_tiles(f.read())

def tile_to_bytes(tile):
    plane_lo = []
    plane_hi = []
    for row in tile:
        lo = 0
        hi = 0
        for pixel in row:
            lo = (lo << 1) | ((pixel & 1))
            hi = (hi << 1) | ((pixel & 2)>>1)
        plane_lo += [lo]
        plane_hi += [hi]
    return bytearray(plane_lo + plane_hi)

def write_tiles(filename, tiles):
    with open(filename, 'wb') as f:
        for tile in tiles:
            f.write(tile_to_bytes(tile))

def short_name(filename):
    return filename.split('/')[-1]

BLANK_TILE = tuple([tuple([0 for _ in range(8)]) for _ in range(8)])

def run(out_filename, in_filenames):
    t = {short_name(filename): read_tiles(filename) for filename in in_filenames}

    tiles = []
    for k in t:
        tiles += t[k]

    tiles_nonblank = [tile for tile in tiles if tile != BLANK_TILE]
    tiles_set = [BLANK_TILE] + list(set(tiles_nonblank))
    num_tiles_before = len(tiles_nonblank) + 1
    num_tiles_after = len(tiles_set)
    print("Number of tiles before: {}".format(num_tiles_before))
    print("Number of tiles after:  {}".format(num_tiles_after))
    print("% of original: {:.0f}%".format(num_tiles_after / num_tiles_before * 100))

    with open("{}.asm".format(out_filename), "w") as f:
        for name in t:
            for old_index, tile in enumerate(t[name]):
                new_index = tiles_set.index(tile)
                # print("{:02x} <- {:02x}".format(new_index, old_index))
                print("{}_{:02x}=${:02x}".format(name, old_index, new_index), file=f)
    write_tiles("{}".format(out_filename), tiles_set)

run(sys.argv[1], sys.argv[2:])
