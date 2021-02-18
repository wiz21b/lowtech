import re
from PIL import Image
import numpy


def read_godot_tiles( godot_path, show_tiles=False):

    # Read the single image where all tiles are

    im = Image.open(f"{godot_path}/tileset/tiles.png")
    im = Image.fromarray(
        numpy.uint8(
            numpy.logical_not( numpy.asarray( im, dtype=numpy.bool)))*255).convert("1")


    REGION_RE = re.compile( r"^(\d+)/region = Rect2\( (\d+), (\d+), (\d+), (\d+) \)$")


    # The tile image above is split in indvidual tiles according to tiles
    # coordinates

    unsorted_tiles = dict()

    with open(f"{godot_path}/new_tileset.tres") as fin:

        for line in fin.readlines():

            line = line.strip()

            #print( line)
            m = REGION_RE.match( line)
            if m:
                tid, x, y, w, h = [int(i) for i in m.groups()]

                unsorted_tiles[tid] = im.crop( (x,y,x+w,y+h) )


    tiles = [None] * len( unsorted_tiles)
    replacements = dict()

    custom_tiles_id = 2
    for tid, tile in unsorted_tiles.items():

        # Distinguish the completely white, completely black
        # tiles from other tiles.

        a = numpy.asarray( tile)
        counts = dict(zip( *numpy.unique(a, return_counts=True)))

        if True in counts and False not in counts:
            print("White")
            tiles[1] = tile
            replacements[tid] = 1
        elif False in counts and True not in counts:
            print("black")
            tiles[0] = tile
            replacements[tid] = 0
        else:
            tiles[custom_tiles_id] = tile
            replacements[tid] = custom_tiles_id

            custom_tiles_id += 1




    TILE_DATA_RE = re.compile( r"^tile_data = PoolIntArray\( (.*) \)$")

    points = []

    with open(f"{godot_path}/TileMap.tscn") as fin:
        for line in fin.readlines():
            m = TILE_DATA_RE.match(line)

            if m:
                a = [int(i) for i in m.groups()[0].split(', ')]
                #print(a)

                min_x, max_x = 10000, 0
                min_y, max_y = 10000, 0

                for i in range( 0, len(a), 3):

                    y,x,tid = a[i] >> 16, a[i] & 65535, a[i+1]
                    points.append( (x,y,replacements[tid]) )

                    min_x = min( min_x, x)
                    max_x = max( max_x, x)
                    min_y = min( min_y, y)
                    max_y = max( max_y, y)

                    # print( "x:{}, y:{} = {}".format( a[i] >> 16, a[i] & 65535, a[i+1]))

                print(f"{min_x}- {max_x} {min_y}, {max_y}")
                w = max_x - min_x + 1
                h = max_y - min_y + 1

                pic = numpy.zeros( (h,w), dtype=numpy.int)

                image = Image.new('1', (w*8, h*8))

                for  x,y,tid in points:
                    pic[y,x] = tid
                    image.paste( tiles[tid], (x*8, y*8))

                if show_tiles:
                    image.show()

                print( pic)

        return tiles, pic

if __name__ == '__main__':
    #read_godot_tiles( r"c:/Users/stc/Dropbox/demo2/bigscroll/data/Tiles", show_tiles=True)
    read_godot_tiles( r"/home/stefan/Dropbox/demo2/bigscroll/data/Tiles", show_tiles=True)
