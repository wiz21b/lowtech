# ;;; This code is (c) 2019 Stéphane Champailler
# ;;; It is published under the terms of the
# ;;; GUN GPL License Version 3.

# https://www.dafont.com/electric-toaster.font?text=LOW+TECH

"""
https://www.dafont.com/retrobound.font

In 2020, 50M
tons of e-waste
were created.

This is
madness.

Let's start
the age of ...
"""

import sys
import xxhash
from PIL import Image
import numpy as np
from collections import OrderedDict
import colorama
import io
import random

from bigscroll.godot import read_godot_tiles

# 131
random.seed(134) # Set for stars

VERTICAL_OFFSET = 5
TILE_SIZE = 8
ROL_SPEED = 1


def roller(tile, block_y, code_stream, roll_func, routine_base_name, page):
    """
    tile : the tile we're rolling
    block_y = y_position of the tile in the big letter

    """

    jump_table = []
    masks = [int(x) for x in np.packbits(tile)]
    for rol_factor in range(0, TILE_SIZE, ROL_SPEED):
        routine_name = f"{routine_base_name}_rol{rol_factor}_y{block_y}"
        jump_table.append(routine_name)

        code_stream.write(f"\n{routine_name}:\n")

        last_v = None
        for y, m in enumerate(masks):
            # There's a +ROL_SPEED. That's because we want the
            # last ROL of a tile to be the last thing to draw
            # on the screen. So if we want a full white/black tile
            # on the last ROL... So this way, we always end up
            # with the last ROL being 8 positions to the left.

            assert 0 <= m <= 255
            assert 0 <= rol_factor+ROL_SPEED <= TILE_SIZE
            rol_m = roll_func(m, rol_factor+ROL_SPEED)

            # Reverse bits because HGR is reversed
            v = reverseBits(rol_m, 8)

            # Remove redundant LDA's
            if v != last_v:
                code_stream.write(f"\tLDA #%{v:08b}\t;{rol_m:08b}\n")
                last_v = v

            code_stream.write("\tSTA {},Y\n".format(
                hgr_address((block_y+VERTICAL_OFFSET)*8 + y, page)))

            # LDA = 2 cycles
            # STA $MMMM, Y = 5 cycles => x8 = 40 cycles
            # RTS : 6 cycles
            # => 48 cycles

        code_stream.write("\tRTS\n")
    return jump_table


def opening_rol_head(tile, tile_ndx, block_y, code_stream, page):

    # .THIS..!.......!.......!
    #          ###############
    #        #################
    #      ###################

    # lambda : rols the tile to the left

    return roller(tile, block_y, code_stream,
                  lambda m, rol_factor: (m << (rol_factor)) >> 8,
                  f"open_head{tile_ndx}", page)


def opening_rol_tail(tile, tile_ndx, block_y, code_stream, page):

    # ........!..THIS.!.......
    #           ##############
    #         ################
    #       ##################

    # lambda : rols the tile and pad with white

    return roller(tile, block_y, code_stream,
                  lambda m, rol_factor: ((m << (rol_factor)) & 255) | (255 >> (8-(rol_factor))),
                  f"open_tail{tile_ndx}", page)


def closing_rol_head(tile, tile_ndx, block_y, code_stream, page):

    # .......!.THIS..!.......!
    # ##############
    # ################
    # ##################

    return roller(tile, block_y, code_stream,
                  lambda m, rol_factor: (((256*255+m) << rol_factor) >> 8) & 255,
                  f"close_head{tile_ndx}", page)


def closing_rol_tail(tile, tile_ndx, block_y, code_stream, page):

    # .......!.......!..THIS.!
    # ##############
    # ################
    # ##################

    # def bitrol(m, rol_factor):
    #     if rol_factor == 17:
    #         return 0
    #     else:
    #         return (m << (rol_factor)) & 255

    return roller(tile, block_y, code_stream,
                  lambda m, rol_factor: (m << (rol_factor)) & 255,
                  f"close_tail{tile_ndx}", page)


def npa_to_bytes(a):
    """ NumPy array to bytes.
    """

    s = ""
    for y in range( a.shape[0]):
        r = []
        for x in range( a.shape[1]):
            r.append( a[ y][ x])
        s += ".byte " + ",".join( ["${:02x}".format(n) for n in r]) + "\n"
    return s



def hash_npa( a):
    return xxhash.xxh64( a.tobytes()).hexdigest()

def show_tile(tile):
    for y in range( tile.shape[0]):
        r = ""
        for x in range( tile.shape[1]):
            if tile[ y][ x]:
                r += "#"
            else:
                r += "."
        print(r)
    print()


# def image_to_tiles(filename, tile_size):
#     # ndx = 0
#     # tmap = dict()
#     # for tile in tiles:
#     #     tmap[ hash_npa( tile.flatten()) ] = ndx
#     #     ndx += 1

#     img = Image.open(filename)
#     data1 = img.convert('L').tobytes()
#     img.close()
#     data = [x >> 7 for x in data1] # From grayscale to 2 bits per pixel

#     tiles = [ np.zeros( ( tile_size, tile_size, ), dtype=np.bool_ ),
#               np.ones(  ( tile_size, tile_size, ), dtype=np.bool_ ) ]

#     a = ( np.asarray(data, dtype=np.bool_).reshape( (img.height,img.width,) ))
#     a = np.logical_not(a)


#     assert img.height % tile_size == 0
#     assert img.width % tile_size == 0

#     pic = np.zeros( ( img.height // tile_size, img.width // tile_size ), dtype=np.int )

#     for y in range(0, img.height, tile_size):
#         for x in range(0, img.width, tile_size):
#             tile = a[y:y+tile_size,x:x+tile_size]

#             s = tile.sum() # number of True

#             if  0 < s < tile_size**2: # forget white and blacks
#                 show_tile(tile)
#                 pic[y // tile_size, x // tile_size] = len( tiles)
#                 tiles.append( tile )
#             elif s == 0:
#                 pic[y // tile_size, x // tile_size] = 0
#             elif s == tile_size**2:
#                 pic[y // tile_size, x // tile_size] = 1

#     return tiles, pic


def hgr_address(y, page=0x2000):
    assert 0 <= y < 3*64

    if 0 <= y < 64:
        ofs = 0
    elif 64 <= y < 128:
        ofs = 0x28
    else:
        ofs = 0x50

    i = (y % 64) // 8
    j = (y % 64) % 8

    return "${:X} + ${:X}".format(page + ofs + 0x80*i, 0x400*j)

def reverseBits(num,bitSize):

     # convert number into binary representation
     # output will be like bin(10) = '0b10101'
     binary = bin(num)

     # skip first two characters of binary
     # representation string and reverse
     # remaining string and then append zeros
     # after it. binary[-1:1:-1]  --> start
     # from last character and reverse it until
     # second last character from left
     reverse = binary[-1:1:-1]
     reverse = reverse + (bitSize - len(reverse))*'0'

     # converts reversed binary string into integer
     return int(reverse,2)


def image_to_ascii( pic, width, height):
    data = []
    sym = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

    max_width = 40
    max_cnt = 0
    for base_x in range(width - max_width):

        cnt = 0
        for x in range(base_x, base_x+max_width):
            for y in range(height):
                if pic[y][x] != 0:
                    cnt += 1

        max_cnt = max(max_cnt, cnt)

    print(f"Max non empty tile on a screen : {max_cnt}")

    with colorama.colorama_text() as ctx:
        for y in range( height):
            r= []
            for x in range( width):
                if pic[ y][ x] == 0:
                    r += "."
                elif pic[ y][ x] == 1:
                    r += "\u2588"
                elif pic[ y][ x] >= 1000 :
                    #print("{},{} = {}".format(y,x,pic[y][x]))
                    r += colorama.Fore.LIGHTGREEN_EX + sym[+pic[y][x] - 1000] + colorama.Fore.RESET
                elif pic[ y][ x] > 0:
                    #print("{},{} = {}".format(y,x,pic[y][x]))
                    r += colorama.Fore.LIGHTWHITE_EX + sym[+pic[y][x]] + colorama.Fore.RESET
                elif pic[ y][ x] < -1000:
                    #print("{},{} = {}".format(y,x,pic[y][x]))
                    r += colorama.Fore.LIGHTYELLOW_EX + sym[-pic[y][x]-1000] + colorama.Fore.RESET
                else:
                    #print("{},{} = {}".format(y,x,pic[y][x]))
                    r += colorama.Fore.LIGHTRED_EX + sym[-pic[y][x]] + colorama.Fore.RESET
                    pass

            data.append("".join(r))

        for l in data:
            print(l)
    print()

    return data


def unify_tiles(a, tiles):
    print("Finding unique tiles out of {} tiles".format(len(tiles)))

    # Maps tile hash to old tile number; index gives new tile number

    unique_tiles = OrderedDict()
    for tile in tiles:
        h = hash_npa(tile)
        # print(h)
        if h not in unique_tiles:
            unique_tiles[h] = tile
        else:
            assert np.array_equal(tile,  unique_tiles[h]), "Hash collision"

    simplified = np.zeros_like(a)

    hashes = list(unique_tiles.keys())
    for ndx_tile in range(len(tiles)):
        new_ndx = hashes.index(hash_npa(tiles[ndx_tile]))
        # print("replacing {} by {}".format(ndx_tile, new_ndx))

        np.putmask(simplified, a == ndx_tile, new_ndx)

    image_to_ascii(simplified, a.shape[1], a.shape[0])

    return simplified, unique_tiles




def optimize( a, tiles, tile_size=TILE_SIZE):
    white_adder = np.ones( ( tile_size, tile_size, ), dtype=np.bool_ )

    white_ndx = len(tiles)
    assert white_ndx not in tiles
    tiles[ white_ndx] = white_adder


    # white_ndx = list(tiles.keys()).index(hash_npa( white_adder))
    # black_ndx = list(tiles.keys()).index(hash_npa( black_adder))

    optimized = np.zeros_like( a)
    for line_num in range( a.shape[0]):
        line = a[line_num,:]

        for x in range( 1, a.shape[1] - 1):
            if line[x-1] == 1 and line[x] > 1 and line[x+1] == 0:
                # white - XXX - black (closing)
                optimized[line_num][x-1] = 1000 + line[x]
                optimized[line_num][x] = - 1000 - line[x]

            elif line[x-1] == 0 and line[x] > 1 and line[x+1] == 1:
                # black - XXX - white
                optimized[line_num][x] = - line[x]
                optimized[line_num][x-1] = + line[x]

            # Barre du L à droite est bonne (donc de blanc à noir)
            elif line[x] == 1 and line[x+1] == 0 :
                # A white line disappears
                optimized[line_num][x] =  -1000 - white_ndx

            elif line[x] == 0 and line[x+1] == 1 :
                # A white line arrives
                optimized[line_num][x] = white_ndx

            # elif optimized[line_num][x] == 0:
            #     optimized[line_num][x] = 1

    print("Optimized")
    image_to_ascii( optimized, optimized.shape[1], optimized.shape[0])
    return optimized


# def add_column(a, n=1):
#     col = np.zeros((a.shape[0], n), dtype=np.int)
#     return np.concatenate((a, col), axis=1)


def make_all(BUILD_DIR, DATA_DIR):

    # tiles, tiled_image = image_to_tiles( f"{DATA_DIR}/slomo2.png", TILE_SIZE)

    tiles, tiled_image = read_godot_tiles(DATA_DIR + "/Tiles")

    scroller_height_in_pixels = tiled_image.shape[0] * TILE_SIZE

    col = np.zeros((tiled_image.shape[0], 1), dtype=np.int)
    tiled_image = np.concatenate((col, col, tiled_image, col), axis=1)

    image_to_ascii(tiled_image, tiled_image.shape[1], tiled_image.shape[0])

    simplified, hashes = unify_tiles(tiled_image, tiles)
    optimized = optimize(simplified, hashes)

    tiles = list(hashes.values())
    tile_ndx = 1
    STEP = 8 // ROL_SPEED

    with open(f"{BUILD_DIR}/bs_precalc.s", "w") as fo:

        filler_code = io.StringIO()
        big_jump_table = [0] * STEP
        data = np.copy(optimized)

        for line_num in range(data.shape[0]):
            line = data[line_num, :]
            tiles_on_line = dict()

            page = 0x2000
            for x in range(data.shape[1]):
                t = line[x]

                # For each Y position, the tiles
                # code is repeated.

                if t != 0:
                    if t not in tiles_on_line:
                        tiles_on_line[t] = tile_ndx

                        if t > 1000:
                            big_jump_table.extend(
                                closing_rol_head(
                                    tiles[t-1000], tile_ndx,
                                    line_num, filler_code, page))

                        elif t < - 1000:
                            big_jump_table.extend(
                                closing_rol_tail(
                                    tiles[-t-1000], tile_ndx, line_num,
                                    filler_code, page))

                        elif t > 0:
                            big_jump_table.extend(
                                opening_rol_head(
                                    tiles[t], tile_ndx, line_num,
                                    filler_code, page))
                            # show_tile( tiles_on_line[t])

                        elif t < 0:
                            big_jump_table.extend(
                                opening_rol_tail(
                                    tiles[-t], tile_ndx, line_num,
                                    filler_code, page))

                        tile_ndx += 1

                    line[x] = tiles_on_line[t]
                # print( tiles_on_line.keys())

            # print("-"*200)
        #print( npa_to_bytes( simplified.transpose()))

        print("Jump table has {} entries ({} tiles)".format(len(big_jump_table), tile_ndx))

        for i in range(0, len(big_jump_table), STEP):
            fo.write(f"tile{i//STEP}_entry:\t.word ")
            fo.write(",".join(
                ["{}".format(s) for s in big_jump_table[i:i+STEP]]) + "\n")

        fo.write("\ntimes8hi:\n")
        for i in range(tile_ndx):
            fo.write(f"\t.byte >tile{i}_entry\n")

        fo.write("\ntimes8lo:\n")
        for i in range(tile_ndx):
            fo.write(f"\t.byte <tile{i}_entry\n")

        fo.write(filler_code.getvalue())

        #data = data.transpose()

    with open(f"{BUILD_DIR}/matrix.s","w") as fo:
        #fo.write("scroll_matrix:\n")
        trans = data.transpose()
        print("Matrix has {} lines".format(trans.shape[0]))
        # fo.write(
        #     npa_to_bytes(
        #         add_column( trans, 16-trans.shape[1]) ))

        row_id = 1
        labels = []

        # Attetnion ! Expecting row1 to be the empty row.

        for i in range(40):
            labels.append("matrix_row1")

        for row in trans:
            tiles = [t for t in filter(lambda t: t > 0, row)] + [0]
            label = "matrix_row{}".format(row_id)
            labels.append(label)
            fo.write("{}:\t.byte {}\n".format(
                label, ",".join([str(t) for t in tiles])))
            row_id += 1

        for i in range(40):
            labels.append("matrix_row1")

        fo.write("matrix_rows:\t.word {}\n".format(",".join(labels)))

        fo.write("matrix_row_count:\t.byte {}\n".format(len(labels) - 40))

    with open(f"{BUILD_DIR}/precalc_def.s", "w") as fo:
        fo.write("ROL_SPEED = {}\n".format(ROL_SPEED))


    # Starfield ------------------------------------------------------

    x_rnd_range = lambda : random.randrange(2, 2+((280-28) // 7) + 1)

    with open(f"{BUILD_DIR}/stars.s","w") as fo:
        # Stars "inside" the scroller
        for i in range(15):
            fo.write( "TXA\n")
            adr = hgr_address(
                VERTICAL_OFFSET*TILE_SIZE + random.randrange( scroller_height_in_pixels)) +\
                " + {}".format(x_rnd_range())
            fo.write( "ORA " + adr + "\n")
            fo.write( "STA " + adr + "\n")

    with open(f"{BUILD_DIR}/stars2.s","w") as fo:
        for i in range(20):

            s = (1+2) << (random.randrange(3)*2)
            fo.write( "LDA #{}\n".format(s))
            adr = hgr_address( random.randrange(VERTICAL_OFFSET*TILE_SIZE)) +\
                               " + {}".format(x_rnd_range())
            fo.write( "STA " + adr + "\n")

            v = VERTICAL_OFFSET*TILE_SIZE + scroller_height_in_pixels

            adr = hgr_address( v + random.randrange(192-v)) +\
                " + {}".format(x_rnd_range())
            fo.write( "STA " + adr + "\n")



if __name__ == "__main__":
    import os

    BUILD_DIR = "build"
    if not os.path.isdir( BUILD_DIR):
        os.makedirs(BUILD_DIR)

    make_all( BUILD_DIR, "data")
