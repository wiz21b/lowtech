# ;;; This code is (c) 2019 Stéphane Champailler
# ;;; It is published under the terms of the
# ;;; GUN GPL License Version 3.

# The "before it's too late" demo
# By Wiz/Imphobia!
# In memory of my scene years and its seasons.

# 617D draw hline full

import sys
import xxhash
from PIL import Image
import numpy as np
from collections import OrderedDict
import io
import math
import random
random.seed(125)

from utils import *


#SHAPE = "Ogon"
#SHAPE = "Tetrahedron"
#SHAPE = "Cube"
SHAPE = "Cube2"
DEBUG = False
TILE_SIZE = APPLE_HGR_PIXELS_PER_BYTE


# ; total 16 bytes for one line of a tile
# ; 8*16 = 128 bytes for a tile

# ; for 8 pixels tile size, I have 8+8+8+8=32 tiles, each of which is rolled on 8 positions => 8*32 = 256 tiles
# ; A tile needs max 2*8 bytes => tile date = 16*256 = 4096 bytes

# ; given the number of tiles, precalc the code is not possible.

# -----------------------------------------------------------------

# Other way
# Tak a mostly vertical line
# split it into parts of 8 pixels tall
# dtermine the x1 where the line enter a tile and the x2 where it leaves it
# locate a tile with an index (x1, x2)


def enumerate_x( x1 : int, y1 : int, x2 : int, y2 : int):
    assert is_int(x1) and is_int(x2) and is_int(y1) and is_int(y2)

    dx,dy = x2 - x1, y2 - y1
    slope = dx/dy

    xs = []
    x = x1
    for i in range( dy+1):
        rx = int(round(x))
        assert x1 <= rx <= x2 or x1 >= rx >= x2
        xs.append( rx)
        x += slope

    return xs






def draw_vline( npa, x1, y1, x2, y2, color):
    # Draw a mostly vertical line

    assert 0 <= x1 < npa.shape[1], "bad x1: 0 <= {} < {}".format(x1, npa.shape[1])
    assert 0 <= x2 < npa.shape[1]
    assert 0 <= y1 < npa.shape[0]
    assert 0 <= y2 < npa.shape[0]

    dx,dy = x2 - x1, y2 - y1
    slope = dx/dy

    assert abs(slope) <= 1, "The line is not mostly vertical"


    a = Vertex( x1, y1)
    b = Vertex( x2, y2)
    points = full_enum(a,b)
    for p in points:
        npa[ int(p.y) ][ int(p.x) ] = 1
    return

    # xs = enumerate_x(x1, y1, x2, y2)

    # y = y1
    # for i in range( dy+1):
    #     npa[y][xs[i]] = 1
    #     y += 1


def draw_hline( npa, x1, y1, x2, y2, color):

     a = Vertex( x1, y1)
     b = Vertex( x2, y2)

     points = full_enum(a,b)
     for p in points:
          npa[ int(p.y) ][ int(p.x) ] = 1





import pygame
pygame.init()

speed = [2, 2]
black = 0, 0, 0


# https://www.youtube.com/watch?v=juXlFqhKrEM
# 255 images en 13 secondes => 19 fps
# my engine : 29*2 in 2.39s => 24 fps (zoom factor = 250)
# zoom factor = 500 : 29*2 in 4.22s => 13fps
# 45 / 4 = 11 fps
# 70/8.3 = 8.4



Vtx = Vertex
faces = []

if SHAPE == "Tetrahedron":

    HIDDEN_FACES = True
    if HIDDEN_FACES:
        NB_FRAMES = 160
    else:
        NB_FRAMES = 240

    ATTENUATION = math.pi
    ZOOM=300
    axis = [3,2,0.5]
    ta = Vtx(-1,-1,0)
    tb = Vtx(+1,-1,0)
    tc = Vtx(0,+1,-1)
    td = Vtx(0,+1,+1)
    faces += [ Face(ta,tb,tc, hidden=HIDDEN_FACES),
               Face(ta,td,tb, hidden=HIDDEN_FACES),
               Face( tc,tb,td, hidden=HIDDEN_FACES),
               Face( tc,td,ta, hidden=HIDDEN_FACES)  ]

# Cube ---------------------------------------------------------------

if SHAPE == "Cube":
    NB_FRAMES = 140
    ATTENUATION = math.pi
    ZOOM=250
    HIDDEN_FACES = True

    if HIDDEN_FACES:
        NB_FRAMES = 140
    else:
        NB_FRAMES = 110

    axis = [3,2,0.5]

    ap = Vtx(-1,-1,-1)
    bp = Vtx(+1,-1,-1)
    cp = Vtx(+1,+1,-1)
    dp = Vtx(-1,+1,-1)

    app = Vtx(-1,-1,1)
    bpp = Vtx(+1,-1,1)
    cpp = Vtx(+1,+1,1)
    dpp = Vtx(-1,+1,1)

    faces += [ Face( ap,bp,cp,dp,hidden=HIDDEN_FACES), # front
              Face( dpp,cpp,bpp,app,hidden=HIDDEN_FACES),

              Face( cp,cpp,dpp,dp,hidden=HIDDEN_FACES),
              Face( bp,bpp,cpp,cp,hidden=HIDDEN_FACES),
              Face( ap,app,bpp,bp,hidden=HIDDEN_FACES),
              Face( dp,dpp,app,ap,hidden=HIDDEN_FACES),
             ]


if SHAPE == "Cube2":
    ATTENUATION = math.pi / 2
    ZOOM=250
    HIDDEN_FACES = True

    if HIDDEN_FACES:
        NB_FRAMES = 70
    else:
        NB_FRAMES = 40

    axis = [3,2,0.5]

    ap = Vtx(-1,-1,-1)
    bp = Vtx(+1,-1,-1)
    cp = Vtx(+1,+1,-1)
    dp = Vtx(-1,+1,-1)

    app = Vtx(-1,-1,1)
    bpp = Vtx(+1,-1,1)
    cpp = Vtx(+1,+1,1)
    dpp = Vtx(-1,+1,1)

    faces += [ Face( ap,bp,cp,dp,hidden=HIDDEN_FACES), # front
              Face( dpp,cpp,bpp,app,hidden=HIDDEN_FACES),

              Face( cp,cpp,dpp,dp,hidden=HIDDEN_FACES),
              Face( bp,bpp,cpp,cp,hidden=HIDDEN_FACES),
              Face( ap,app,bpp,bp,hidden=HIDDEN_FACES),
              Face( dp,dpp,app,ap,hidden=HIDDEN_FACES),
             ]

    t = Vtx(0,0,-1.7)
    ap = Vtx(-1,-1,-1)*0.5 + t
    bp = Vtx(+1,-1,-1)*0.5 + t
    cp = Vtx(+1,+1,-1)*0.5 + t
    dp = Vtx(-1,+1,-1)*0.5 + t

    app = Vtx(-1,-1,1)*0.5 + t
    bpp = Vtx(+1,-1,1)*0.5 + t
    cpp = Vtx(+1,+1,1)*0.5 + t
    dpp = Vtx(-1,+1,1)*0.5 + t

    faces += [ Face( ap,bp,cp,dp,hidden=HIDDEN_FACES), # front
              Face( dpp,cpp,bpp,app,hidden=HIDDEN_FACES),

              Face( cp,cpp,dpp,dp,hidden=HIDDEN_FACES),
              Face( bp,bpp,cpp,cp,hidden=HIDDEN_FACES),
              Face( ap,app,bpp,bp,hidden=HIDDEN_FACES),
              Face( dp,dpp,app,ap,hidden=HIDDEN_FACES),
             ]
# Ogon ---------------------------------------------------------------

if SHAPE == "Ogon":
    NB_FRAMES = 80
    ATTENUATION = math.pi / 2
    ZOOM = 250 # 170
    HIDDEN_FACES = True

    if HIDDEN_FACES:
        NB_FRAMES = 80
    else:
        NB_FRAMES = 40

    axis = [3,2,0.5]
    a = Vtx(-0.75,-0.75,-1)
    b = Vtx(+0.75,-0.75,-1)
    c = Vtx(+0.75,+0.75,-1)
    d = Vtx(-0.75,+0.75,-1)

    ap = Vtx(-1,-1,0)
    bp = Vtx(+1,-1,0)
    cp = Vtx(+1,+1,0)
    dp = Vtx(-1,+1,0)

    app = Vtx(-1,-1,1)
    bpp = Vtx(+1,-1,1)
    cpp = Vtx(+1,+1,1)
    dpp = Vtx(-1,+1,1)

    appp = Vtx(-0.5,-0.5,2)
    bppp = Vtx(+0.5,-0.5,2)
    cppp = Vtx(+0.5,+0.5,2)
    dppp = Vtx(-0.5,+0.5,2)

    faces = [ Face(a,b,c,d, hidden=HIDDEN_FACES), # front
              Face( d,c,cp,dp, hidden=HIDDEN_FACES), # top
              Face( b,a,ap,bp, hidden=HIDDEN_FACES), # bottom
              Face( a,d,dp,ap, hidden=HIDDEN_FACES), # left
              Face( b,bp,cp,c, hidden=HIDDEN_FACES), # right

              Face(ap,app,bpp,bp, hidden=HIDDEN_FACES),
              Face(bp,bpp,cpp,cp, hidden=HIDDEN_FACES),
              Face(dp,cp,cpp,dpp, hidden=HIDDEN_FACES),
              Face(ap,dp,dpp,app, hidden=HIDDEN_FACES),

              Face(app,appp,bppp,bpp, hidden=HIDDEN_FACES),
              Face(bpp,bppp,cppp,cpp, hidden=HIDDEN_FACES),
              Face(dpp,cpp,cppp,dppp, hidden=HIDDEN_FACES),
              Face(app,dpp,dppp,appp, hidden=HIDDEN_FACES),

              Face(dppp,cppp,bppp,appp, hidden=HIDDEN_FACES), #rear
             ]

# Grid ------------------------------------------------------

# NB_FRAMES = 60
# ATTENUATION = 0.5
# ZOOM = 300
# faces = []
# ty=0.5

# N=4
# for i in range(0,+N+1):
#     if i < 4:
#         a = Vtx(-5,i*0.3 + ty,0)
#         b = Vtx(+5,i*0.3 + ty,0)
#         faces.append( Face( a,b, hidden=False))

#     if i != 100:
#         a = Vtx((i-N//2 - 1)*0.5,+ty,0)
#         b = Vtx((i-N//2 - 1)*3,+10.5+ty,0)
#         faces.append( Face( a,b, hidden=False))

# axis = [0,0,1]

# -----------------------------------------------------------


# Animate

def persp( v, zoom = 350):
    # Z points away from us

    d = (v.z + 5) / zoom
    return Vtx( v.x / d + APPLE_XRES / 2,
                v.y / d + APPLE_YRES / 2,
                v.z*100) # see Vertex construtor and round operation

recorded_lines = []
theta = 0


screen = pygame.display.set_mode( (APPLE_XRES*4, APPLE_YRES*4))
zscreen = ZBuffer( APPLE_XRES, APPLE_YRES)

RUNNING, PAUSE = 0, 1
state = RUNNING


for i,face in enumerate(faces):
    face.number = (i+1)*8 # will be a color

for frame_ndx in range(NB_FRAMES):
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            sys.exit()

        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_p:
                for event in pygame.event.get():
                    if event.type == pygame.KEYDOWN:
                        if event.key == pygame.K_r:
                            break


    #screen.fill(black)

    theta = math.sin(frame_ndx * 2*math.pi / NB_FRAMES)*ATTENUATION
    rot = angle_axis_quat(theta, axis)

    drawn_edges = set()

    frame_lines = []

    xv = dict()

    t_y = -0
    for face in faces:


        vp = []
        for v in face.vertices:
            if v.vid not in xv:
                xv[v.vid] = persp( Vtx( *rotate_quat( rot, [v.x,v.y,v.z])), ZOOM).grab_id(v)
            vp.append( xv[v.vid])

        # print(len(xv))
        # print([v.vid for v in vp])

        # vp = [ persp( Vtx( *rotate_quat( rot, [v.x,v.y,v.z])), ZOOM).grab_id(v)
        #        for v in face.vertices ]
        face.xformed_vertices = vp

        if face.hidden:
            v1 = vp[0] - vp[1]
            v2 = vp[0] - vp[2]
            if v1.cross(v2).z < 0:
                #pass
                continue

        zscreen.draw_face( face)

        for i in range( face.edges):
            a,b = vp[i], vp[(i+1)%len(face.vertices)]

            k = min( a.vid, b.vid), max( a.vid, b.vid)
            if k not in drawn_edges:
                drawn_edges.add( k)
                # pygame.draw.line( screen, (255,255,255),
                #                   (a.x,a.y + t_y),
                #                   (b.x,b.y + t_y), 1)

                # frame_lines.append( (a.x,a.y + t_y,
                #                      b.x,b.y + t_y) )



    edge_cache = dict()

    for face in faces:
        for i in range( len(face.xformed_vertices)):
            a = face.xformed_vertices[i]
            b = face.xformed_vertices[i-1]

            if a.vid < b.vid:
                edge_id = (a.vid, b.vid)
            else:
                edge_id = (b.vid, a.vid)

            if edge_id not in edge_cache:
                edge_cache[edge_id] = set([face])
            else:
                edge_cache[edge_id].add( face)

    segments = []
    for key, sup_faces in edge_cache.items():
        assert len(sup_faces) == 2
        #print([f.number for f in sup_faces])
        segments.extend( zscreen.draw_line( xv[key[0]], xv[key[1]], 255, [f.number for f in sup_faces]))

    recorded_lines.append( frame_lines)

    zscreen.show_pygame( screen)
    #print(segments)
    for a,b in segments:
        pygame.draw.line( screen, (0,0,255),
                          (a.x,a.y),
                          (b.x,b.y), 1)

        print("{} - {}".format( str(a), str(b)))
        frame_lines.append( (a.x,a.y,
                             b.x,b.y) )


    zscreen.clear()
    pygame.display.flip()





pygame.quit()

# def draw_triangle_edges( scren, v1, v2, v3, color):
#      vert = [ v1, v2, v3]

#      left = full_enum( vert[0], vert[1])
#      right = full_enum( vert[0], vert[2])
#      bottom = full_enum( vert[1], vert[2])

#      for i in range( len(left)):
#           screen.draw_pixel( left[i], color, offset=1)

#      for i in range( len(right)):
#           screen.draw_pixel( right[i], color, offset=1)

#      for i in range( len( bottom)):
#           screen.draw_pixel( bottom[i], color, offset=1)




# def cross(a, b):
#     c = [a[1]*b[2] - a[2]*b[1],
#          a[2]*b[0] - a[0]*b[2],
#          a[0]*b[1] - a[1]*b[0]]

#     return c




def seven_bits_split(t):
    # t is a double tile

    assert (TILE_SIZE + 1) % 8 == 0, "This works only with 7 bits wide tiles"
    assert t.shape[0] == TILE_SIZE, "The tiles' height is not right"
    assert t.shape[1] == 2*TILE_SIZE, "I need 2 tiles side by side"

    # Split the "double tile" in two tiles
    t1, t2 = np.hsplit(t, 2)

    # The most significant bit is the one for the color selection in
    # Apple 2's HGR, we leave it at zero.

    column = np.zeros( (TILE_SIZE,1,), dtype=np.bool_)
    t1 = np.concatenate( (column, t1), axis=1)
    t2 = np.concatenate( (column, t2), axis=1)

    #image_to_ascii( np.concatenate( (t1, t2), axis=1), grid_size=8)

    bm1 = np.packbits( t1, axis=1).flatten()
    bm2 = np.packbits( t2, axis=1).flatten()

    return bm1, bm2


def gen_code_vertical_tile_draw( fo, page):
    labels = []
    nops_labels = []

    early_out_count  = 1

    fo.write("""
; Optimizing the BPL away is not worth it.
; A branch takes 2 or 3 cycles, but setting it up with self modifying code
; is at least 10 times that. So it's worth only for tall lines.
""")


    for y in range(0,APPLE_YRES):

        code = ""

        if y % 6 == 0:
            eo_label = f"early_out_p{page}_{early_out_count}"

            code += f"""
        BVC {eo_label}_skip    ; always taken
{eo_label}:
        RTS
{eo_label}_skip:
"""
            early_out_count += 1

        if page == 1:
            prefix = ""
            line_base = hgr_address(y)
        else:
            prefix = "p2_"
            line_base = hgr_address(y, page=0x4000)

        nop_label = f"{prefix}pcsm{y}"
        labels.append( "{}line{}".format(prefix, y))
        nops_labels.append( nop_label)

        # The self modified NOP will be replaced by DEX or INX.

        # When BPL is self mod to soething else, remember
        # that the INY before is increased but it is not tested
        # So testing Y on being 0 doesn't work ('cos you might
        # skip that 0). So one has to use a test that is a bit
        # stronger (BMI/BPL).

        # DEY approach
        # DEY works well with BPL : 6,5,4..,1,0 : once at zero, addr+Y still wroks fine

        # INY approach with BPL :
        # 254,255,0,1 => problem, once at zero,
        # addr+Y wraps by 256 bytes !  So we need to prevent 0. So we
        # could use BEQ.  Problem with BEQ is because self mod. If BEQ
        # is self modded when Y reaches 0, the next iteration will be
        # Y = 1 and BEQ won't trigger... Solution 1, join BPL and BEQ,
        # but that's two instructions instead of one Solution 2,
        # ensure that the BEQ is never self modded at the wrong
        # position.

        if y > 0:
            nop_label_code = ""
        else:
            nop_label_code = f"{nop_label}:\n"

        code += f"""
{prefix}line{y}:
        LDA (tile_ptr),Y \t; 5+ (+ = page boundary)
        ROR              \t; 2
        AND {line_base},X\t; 4+
        STA {line_base},X\t; 5
        DEY              \t; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
{nop_label_code}
        BMI {eo_label}\t; 2/3+
        BCC @skip        \t; 2/3+
        TXA              \t; 2
        ADC x_shift      \t; 3 (zero page)
        TAX              \t; 2
        CLC              \t; 2
                         \t; total = 23 (no break) or 32 (break)
@skip:
"""
        if y > 0:
            code = strip_asm_comments( code)

        fo.write( code)


    fo.write("\tRTS\n")
    make_lo_hi_ptr_table( fo, prefix + "line_ptrs", labels)
    # make_lo_hi_ptr_table( fo, "nops_ptrs", nops_labels)


def gen_code_vertical_tile_draw_no_tilebreaks( fo, page):
    labels = []
    nops_labels = []

    early_out_count  = 1

    if page == 1:
        prefix = "notb_"
    else:
        prefix = "notb_p2_"

    for y in range(0,APPLE_YRES):

        code = ""

        if y % 11 == 0:
            eo_label = f"{prefix}early_out_p{page}_{early_out_count}"
            code += f"""
        BVC {eo_label}_skip    ; always taken
{eo_label}:
        RTS
{eo_label}_skip:
"""
            early_out_count += 1


        if page == 1:
            line_base = hgr_address(y)
        else:
            line_base = hgr_address(y, page=0x4000)

        nop_label = f"{prefix}pcsm{y}"
        labels.append( f"{prefix}line{y}")
        nops_labels.append( nop_label)

        if y > 0:
            nop_label_code = ""
        else:
            nop_label_code = f"{nop_label}:\n"

        code += f"""
{prefix}line{y}:
        LDA (tile_ptr),Y\t; 5+ (+ = page boundary)
        AND {line_base},X\t; 4+
        STA {line_base},X\t; 5
        DEY\t; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
{nop_label_code}
        BMI {eo_label}\t; 2/3
"""
        if y > 0:
            code = strip_asm_comments(code)

        fo.write( code)


    fo.write("\tRTS\n")
    make_lo_hi_ptr_table( fo, prefix + "line_ptrs", labels)
    # make_lo_hi_ptr_table( fo, "nops_ptrs", nops_labels)


def gen_code_vertical_tile_blank( fo, page):
    labels = []
    nops_labels = []
    early_out_count  = 1

    fo.write("""
; Optimizing the BPL away is not worth it.
; A branch takes 2 or 3 cycles, but setting it up with self modifying code
; is at least 10 times that. So it's worth only for tall lines.
""")

    for y in range(0,APPLE_YRES):

        if y % 6 == 0:
            eo_label = f"blank_early_out_p{page}_{early_out_count}"
            #fo.write(f"\tCLV\n")
            fo.write(f"\tBVC {eo_label}_skip\t; always taken\n")
            fo.write(f"{eo_label}:\n\tRTS\n")
            fo.write(f"{eo_label}_skip:\n")
            early_out_count += 1

        if page == 1:
            prefix = ""
            line_base = hgr_address(y)
        else:
            prefix = "p2_"
            line_base = hgr_address(y, page=0x4000)

        labels.append( "{}blank_line{}".format(prefix, y))
        nops_labels.append( "{}blank_pcsm{}".format(prefix, y))

        # 13 bytes * 192 = 2496 bytes
        fo.write(f"""
{prefix}blank_line{y}:
	STA {line_base},X
	DEY
{prefix}blank_pcsm{y}:
        BMI {eo_label}
""")
        # .format( prefix, y,
        #                           line_base,
        #                           prefix, y,
        #                           prefix, y,
        #                           prefix, y ))


    fo.write("\tRTS\n")
    make_lo_hi_ptr_table( fo, prefix + "blank_line_ptrs", labels)
    # make_lo_hi_ptr_table( fo, "nops_ptrs", nops_labels)


def make_tiles_pairs( fo, bm1, bm2):
     # bm1 = left side of the tile (as bits in an integer)
     # bm2 = right side of the tile

     tile_break = None
     tss = None # Tile split shape
     result = []

     fo.write( "\t; The vertical order is reversed !\n") # Because it allows a DEY ; BPL xxx construct in the assembler code
     for i in reversed(range(TILE_SIZE)):

          # to better understand, imagine that bm1 and bm2 are side by
          # side.  We look at each row of them together.

          m1 = bm1[i]
          m2 = bm2[i]

          if DEBUG:
              print(f"{i}: {m1}\t{m2}")

          assert (m1 == 0 and m2 != 0) or (m1 != 0 and m2 == 0), "both tiles' parts can't be 'lit' together"

          # The following code works regardless of the i enumeration
          # order.

          if tss is None:
              tss = (m1   != 0, m2   != 0)
          elif tile_break is None:
              tss_new = (m1   != 0, m2   != 0)
              if tss != tss_new:
                  assert tile_break is None, "Tile's sides change can occur only once"
                  tile_break = i

                  # tile_break == i means that we draw lines 0..i-1
                  # then we break the tile and then draw lines i to
                  # TILE_SIZE-1.  FIXME i-1 or i ?

                  if DEBUG:
                      print(f"TB! {tile_break}")

          # We store only the non zero part of tiles.  There's only
          # one of these part in each tile (that is a tile is split in
          # two : the zero part and the non zero part; one of these
          # part starts at the top of the tile, the other ends at the
          # end of the tile).

          # logical or is the shortcut one : if m1 then m1 else m2
          # rememeber one and only one of m1,m2 is zero
          # (see assert above)

          result.append( ( bits_to_hgr( invert( logical_or( m1, m2), 7)),
                           f"{m1:08b} {m2:08b} {m1}|{m2}"))



     for i, r in enumerate(result):
         bits, original_bits = r

         # Now we mark this tile's line to indicate the tile change.
         # We can't do it in the previous loop because we're one line
         # too far when we detect the change.
         # Remember i order is reversed.

         if tile_break is not None and TILE_SIZE - 1 -i == tile_break:
             bits = bits | 0x80
             original_bits = original_bits + " TB!"

         # We heavily rely on the fact that on Apple HGR the most
         # significant bit is "not" used (for pixels at least)

         rbits = rol(bits)

         if DEBUG:
             print(f"{i}/{TILE_SIZE}\t.byte {rbits:3}\t; {original_bits}\n")

         fo.write( f"\t.byte {rbits:3}\t; {original_bits}\n")

     return tile_break

def compute_vertical_tiles():
     with open("build/tiles.s","w") as fo:
          labels = []
          tile_breaks = []
          blank_tile_breaks = []

          tile_breaks_indices = []

          for ndx in range( TILE_SIZE): # there was a +1 here
               # Off by one protection
               i = min( ndx, TILE_SIZE - 1)

               # tiles are actually two tiles set side by side.
               t = np.zeros( (TILE_SIZE,TILE_SIZE*2), np.uint8)

               # We draw in the left tile of those two tiles
               # Note that at ndx = 0, we draw a line of slope 0
               # and at ndx = TILE_SIZE - 1 we draw a line of slope 1

               draw_vline( t, 0,0, i, TILE_SIZE-1, 1)

               #draw_vline( t, 1,0, min(TILE_SIZE-1,i+1), TILE_SIZE-1, 1)

               # + 1 because ??? (code seems to need that, many bugs without !)
               for rol_ndx in range( TILE_SIZE +1):

                    n = "T_{}_{}".format(ndx, rol_ndx)
                    # print("{}:".format(n))
                    labels.append(n)
                    fo.write("{}:\n".format(n))
                    tile_left, tile_right = seven_bits_split(t)
                    tile_break_ndx = make_tiles_pairs( fo, tile_left, tile_right)
                    # Precompute the right offset for sef modifying code

                    if tile_break_ndx is not None:
                         tile_breaks.append( "((line1-line0)*{} + (pcsm0-line0) )".format(tile_break_ndx))
                         blank_tile_breaks.append( "((blank_line1-blank_line0)*{} + (blank_pcsm0-blank_line0) )".format(tile_break_ndx))
                         tile_breaks_indices.append(tile_break_ndx)
                    else:
                         tile_breaks.append( "$FFFF")
                         blank_tile_breaks.append( "$FFFF")
                         tile_breaks_indices.append("$7F")

                    # prepare next iteration by rotating the tile
                    # one bit to the right
                    t = np.roll(t,1,axis=1)


               # Align things for quicker access (8 bytes align)
               # labels.append("$FFFF")
               # tile_breaks.append("$FFFF")

          make_lo_hi_ptr_table( fo, "tiles_ptrs", labels)
          #make_lo_hi_ptr_table( fo, "tiles_breaks", tile_breaks)
          make_lo_hi_ptr_table( fo, "blank_tiles_breaks", blank_tile_breaks)
          array_to_asm( fo, tile_breaks_indices, ".byte", "tiles_breaks_indices")

def compute_vertical_tiles_right_left():
     global DEBUG
     with open("build/tiles_lr.s","w") as fo:
          labels = []
          tile_breaks = []
          blank_tile_breaks = []
          tile_breaks_indices = []

          for ndx in range( TILE_SIZE):
               # Off by one protection
               i = min( ndx, TILE_SIZE - 1)

               t = np.zeros( (TILE_SIZE,TILE_SIZE*2), np.uint8)
               draw_vline( t,
                           TILE_SIZE,   0,
                           TILE_SIZE-i, TILE_SIZE-1,
                           1)

               for rol_ndx in range( TILE_SIZE + 1):
                    rol = min( rol_ndx, TILE_SIZE - 1)
                    n = "TLR_{}_{}".format(rol_ndx, ndx)

                    if n == "TLR_0_3":
                        image_to_ascii( t, grid_size=TILE_SIZE)
                        DEBUG = True
                    else:
                        DEBUG=False

                    #print("{}:".format(n))
                    labels.append( n)
                    fo.write("{}:\n".format(n))
                    tile_left, tile_right = seven_bits_split(t)
                    tile_break_ndx = make_tiles_pairs( fo, tile_left, tile_right)
                    # Precompute the right offset for sef modifying code

                    if tile_break_ndx is not None:
                         tile_breaks.append( "((line1-line0)*{} + (pcsm0-line0) )".format(tile_break_ndx))
                         blank_tile_breaks.append( "((blank_line1-blank_line0)*{} + (blank_pcsm0-blank_line0) )".format(tile_break_ndx))

                         tile_breaks_indices.append(tile_break_ndx)
                    else:
                         tile_breaks.append( "$FFFF")
                         blank_tile_breaks.append( "$FFFF")
                         tile_breaks_indices.append( "$7F")

                    # prepare next iteration by rotating the tile
                    # one bit to the right
                    t = np.roll(t,1,axis=1)


               # Align things for quicker access (8 bytes align)
               # labels.append("0")
               # tile_breaks.append(0)

          make_lo_hi_ptr_table( fo, "tiles_lr_ptrs", labels)
          #make_lo_hi_ptr_table( fo, "tiles_lr_breaks", tile_breaks)
          make_lo_hi_ptr_table( fo, "blank_tiles_lr_breaks", blank_tile_breaks)
          array_to_asm( fo, tile_breaks_indices, ".byte", "tiles_lr_breaks_indices")



def compute_horizontal_clipping_masks( fo):
    fo.write("hline_masks_left:\n")
    fo.write("; 1 means keep\n")
    for m in range(7):

        mask = (2**7-1) >> m
        fo.write( "\t.byte %{:08b}\t; {:07b}\n".format(
            bits_to_hgr( mask), mask))

    fo.write("hline_masks_right:\n")
    #for m in rotate_array(reversed(range(7)),-1):
    for m in reversed(range(7)):
        mask = ((2**7-1) << m) & 127
        fo.write( "\t.byte %{:08b}\t; {:07b}\n".format(
            bits_to_hgr(mask), mask))

def compute_horizontal_tiles(fo):
    # Down direction

    column = np.zeros( (TILE_SIZE,1,), dtype=np.bool_)

    # For TILE_SIZE+1, see remark below
    for ndx in range( TILE_SIZE+1):
        # Off by one protection
        i = min( ndx, TILE_SIZE - 1)

        t = np.zeros( (i+1,TILE_SIZE), np.uint8)

        # We draw from left edge to right edge
        # From y=0 to y=i (both inclusive, so i ranges
        # from 0 to TILE_SIZE - 1 inclusive)
        draw_hline( t, 0,0, TILE_SIZE-1, i, 1)

        #draw_hline( t, 0,min(i,1), TILE_SIZE-2, i, 1)

        # image_to_ascii( t, grid_size=TILE_SIZE)


        bm1 = [(b >> 1 ) for b in np.packbits( t, axis=1).flatten()]
        # print(bm1)
        rb = [ bits_to_hgr( invert(row,7)) for row in bm1]

        # We reverse because we count with DEY
        # We padd to have 8 bytes (instead of 7). We pad
        # with 255 to make off by one errors more apparent

        if ndx != TILE_SIZE:
            rb = list(reversed(rb)) + [255]*(8-len(rb))
        else:
            # This is a special case. Most of the time
            # we deal with tiles which have 0-TILE-SIZE
            # rows. But when the line is close to being mostly
            # vertical, we need a tile with TILE_SIZE rows
            # Because of the way we iterate, we iterate
            # over the tile_size+1 => 8 times instead of
            # TILE_SIZE. This little hack here allows this
            # to work without clipping the count value (which
            # would complexify the code)

            rb = list(reversed(rb)) + [invert(1,7)]

        fo.write("HTILE_{}:\t.byte {}\n".format( ndx, ",".join(["${:02X}".format(x) for x in rb]) ))



def compute_horizontal_tiles_up(fo):
    fo.write("HTILE_UP:\n")

    for ndx in range( TILE_SIZE+1):

        # Off by one protection
        i = min( ndx, TILE_SIZE - 1)

        t = np.zeros( (TILE_SIZE,TILE_SIZE), np.uint8)
        draw_hline( t, 0,i, TILE_SIZE-1, 0, 1)

        #draw_hline( t, 0,max(0,i-1), TILE_SIZE-2, 0, 1)
        #image_to_ascii( t, grid_size=TILE_SIZE)

        #bm1 = np.packbits( t, axis=1).flatten()
        bm1 = [(b >> 1 ) for b in np.packbits( t, axis=1).flatten()]
        #print(bm1)

        # Order bits per Apple2 HGR convention
        # (bit2hgr won't work here)
        rb = [ bits_to_hgr( invert(row,7)) for row in bm1]

        # Each tile is stored as 8 bytes, although it only
        # has TILE_SIZE significant rows.
        if ndx != TILE_SIZE:
            rb = list(reversed(rb[0:i+1])) + [0]*(TILE_SIZE - i)
        else:
            rb = list(reversed(rb)) + [invert(64,7)]

        assert( len(rb) == 8)


        # rb += [0] # Make sure we have 8 bytes rows (instead of 7); 8 is easier to use in assembly
        # print(rb)

        fo.write("\t.byte {}\n".format( ",".join(["${:02X}".format(x) for x in rb]) ))

        # for rol in range( TILE_SIZE):
        #      image_to_ascii( t, grid_size=TILE_SIZE)
        #      # prepare next iteration by rotating the tile
        #      # one byte to the right
        #      t = np.roll(t,1,axis=0)


def compute_hgr_offsets(fo):
    make_lo_hi_ptr_table( fo, "hgr2_offsets", [hgr_address(y,page=0x2000,format=1) for y in range(APPLE_YRES)])
    fo.write("\n")
    make_lo_hi_ptr_table( fo, "hgr4_offsets", [hgr_address(y,page=0x4000,format=1) for y in range(APPLE_YRES)])

LIMY = TILE_SIZE
BOTY = APPLE_YRES - TILE_SIZE
LIMX = TILE_SIZE
BOTX = APPLE_XRES - TILE_SIZE

def clip( a, b):


    if a.y > b.y:
        a,b = b,a

    if a.y > BOTY:
        return None, None

    if b.y < LIMY:
        return None, None

    d = b-a
    assert d.y >= 0
    ca, cb = a, b

    if abs(d.y) > 0:
        s = d.x/d.y
        if a.y < LIMY:
            ca = Vertex( a.x + s*abs(LIMY - a.y), LIMY)

        if b.y > BOTY:
            cb = Vertex( b.x - s*abs(BOTY - b.y), BOTY)

    return ca, cb

def hclip( a, b):

    if a is None or b is None:
        return None, None

    if a.x > b.x:
        a,b = b,a

    if a.x > BOTX:
        return None, None

    if b.x < LIMX:
        return None, None

    d = b-a
    assert d.x >= 0
    ca, cb = a, b

    if abs(d.x) > 0:
        s = d.y/d.x
        if a.x < LIMX:
            ca = Vertex( LIMX, a.y + s*abs(LIMX - a.x))
            assert ca.y >= LIMY, f"{ca.y}"

        if b.x > BOTX:
            cb = Vertex( BOTX, b.y - s*abs(b.x - BOTX))

    return ca, cb

def gen_data_line( fo, a, b):
    #print( f"ORG : {a.x},{a.y} -- {b.x},{b.y}")
    a,b = hclip( *clip(a,b) )

    # if a:
    #     print( f"{a.x},{a.y} -- {b.x},{b.y}")
    # else:
    #     print("---")

    if a == None:
        return


    dx, dy = (b - a).x, (b - a).y

    if abs(dx) < 1 and abs(dy) < 1:
        return

    # print(b-a)
    if dx*dx > dy*dy:
        #return

        # mostly horizontal line
        if a.x > b.x:
            a,b = b,a
            dx, dy = (b - a).x, (b - a).y

        assert -256*TILE_SIZE < int(256.0*TILE_SIZE*dy/dx) < 256*TILE_SIZE, "{} / {}".format(int(256.0*TILE_SIZE*dy/dx), 256*6)
        assert dx > 0

        slope = TILE_SIZE * dy/dx

        # The difficult part of mostly horizontal lines is the edges.
        # The idea is this. We imagine the line goes from a tile aligned
        # boundary (left) to another (right). That is, screen X position
        # which are multiple of TILE_SIZE. Doing that we extend an actual
        # line a bit in both directions. To compensate for that, we'll mask
        # those extension sot that they are not drawn

        # We do all of this because we draw the line tile by tile
        # and have to use full tiles. We must also avoid the
        # difficulty of computing intersection between the lines and
        # the modulo TILE_SIZE x position (because this implies multiplication
        # by slope which is 16 bits => hard to do)

        # left part
        lx = int(a.x)
        if lx % TILE_SIZE > 0:
            # we must extend to the left to have a complete tile
            a = Vertex( int(a.x - (lx % TILE_SIZE)),
                        int(a.y - (lx % TILE_SIZE) * dy/dx))
            left_mask = lx % TILE_SIZE
        else:
            left_mask = 0

        rx = int(b.x)
        if rx % TILE_SIZE <= TILE_SIZE-1:
            f = TILE_SIZE - 1 - (rx % TILE_SIZE)
            # we must extend to the left to have a complete tile
            b = Vertex( int(b.x + f),
                        int(b.y + f * dy/dx))
            right_mask = rx % TILE_SIZE
        else:
            right_mask = 0

        dx, dy = (b - a).x, (b - a).y

        if abs(dx) < 2*TILE_SIZE:
            return

        # In case the slope is 45° (possible) or
        # more (clearly an rror somewhere), I fix
        # it a little. This is hackish but allows
        #to avoir more special case handling here
        # and there

        if int_to_16( abs(slope)) == TILE_SIZE*256:
            m = TILE_SIZE*256
            slope = slope * ((m-1)/m)

        # Make sure the slope is less than 45 degrees (horziontal
        # dominant)

        assert abs(slope) < TILE_SIZE, f"{slope} is too big : {dy}/{dx}"
        assert int_to_16( abs(slope)) < TILE_SIZE*256, "16bits slope too big : {} !< {}, {}/{}".format( int_to_16( abs(slope)), TILE_SIZE*256, dy, dx)

        # Of no use ...
        # if abs(slope) == 1:
        #     slope *= 1-2/255

        dx_int = (int(b.x) // TILE_SIZE) - (int(a.x) // TILE_SIZE) + 1

        # Note that dx is stored over 5 bits => the maximum width
        # we can handle is 32*7 = 224 pixels (out of 270)
        if slope >= 0:
            d = [ 0 + (right_mask << 5),
                  int(a.x), int(a.y),
                  (dx_int << 2) + (left_mask >> 1),
                  int_to_16( slope)]
        else:
            d = [ 0 + (right_mask << 5),
                  int(a.x), int(a.y),
                  (dx_int << 2) + (left_mask >> 1),
                  int_to_16( abs(slope)) | 0x8000]

    else:
        #return
        # mostly vertical line ( |dx| < |dy|)
        if a.y > b.y:
            a,b = b,a
            dx, dy = (b - a).x, (b - a).y

        assert not math.isnan(dx)
        assert not math.isnan(dy)
        assert dy >= 0
        assert not math.isnan(dx/dy), "{}/{} is NaN!".format(dx,dy)
        assert -256*TILE_SIZE <= int(256.0*TILE_SIZE*dx/dy) <= 256*TILE_SIZE, "dx/dy == {}".format(dx/dy)

        # # hack ! should be removed

        if dx*dx == dy*dy:
            dx = int(dx * 0.99)

        slope = dx/dy
        assert int( abs( TILE_SIZE*dx/dy)) <= TILE_SIZE - 1

        d = [ 1,
              int(a.x), int(a.y),
              max(1, int(dy )), #  // TILE_SIZE
              int_to_16( TILE_SIZE*dx/dy)]

    #print(d)
    fo.write("\t.byte {}\n".format(",".join(map(str,d[0:-1]))))
    fo.write("\t.word {}\t;{}\n".format(d[4],slope))


compute_vertical_tiles()
compute_vertical_tiles_right_left()

delta = 0
# with open("lines.s","w") as fo:

#     STEPS = 220
#     CENTER = Vertex( 270//2, 192//2)

#     for i in range(STEPS):
#         x = math.cos( math.pi*i/STEPS)*62
#         y = math.sin( math.pi*i/STEPS)*62
#         gen_data_line( fo, CENTER + Vertex(x,y), CENTER + Vertex(-x,-y))

print("Recorded {} lines".format( len(recorded_lines)))
with open("build/lines.s","w") as fo:

    fo.write("; generated \n")
    fo.write("; line type (0=horiz/1=verti), X start, Y start, length, slope (word) \n")

    # 5:

    total_pixels = 0


    for i,frame in enumerate(recorded_lines):
        if i == 0:
            fo.write("line_data_frame1:\t;Beginning of first frame\n")

        npixels = 0
        win_x_min, win_x_max = 1000,0
        win_y_min, win_y_max = 1000,0

        def update_win_boundaries(a):
            global win_x_min, win_x_max, win_y_min, win_y_max
            win_x_min = min( win_x_min, a.x)
            win_x_max = max( win_x_max, a.x)
            win_y_min = min( win_y_min, a.y)
            win_y_max = max( win_y_max, a.y)

        for li,l in enumerate(frame):
            # if i > 0 or 10 <= li <= 12:

            a = Vertex( l[0],l[1])
            b = Vertex( l[2],l[3])
            gen_data_line( fo, a, b)

            update_win_boundaries(a)
            update_win_boundaries(b)

            dx, dy = (b - a).x, (b - a).y
            total_pixels += int(max( abs(dx), abs(dy)))

            # if dx*dx > dy*dy:
            #     npixels += int(abs(dx)) * 15
            # else:
            #     npixels += int(abs(dy)) * 20


        win_w = int(win_x_max - win_x_min)
        win_h = int(win_y_max - win_y_min)
        surf = int(win_w*win_h * APPLE_XRES*APPLE_YRES/40000)
        nb_segments = len(frame)
        print(f"Frame draws {npixels} cycles; {nb_segments} segments. Clearing woud cost {surf} cycles ({win_w}x{win_h}).")

        if frame != recorded_lines[-1]:
            fo.write("\t.byte 3\t;; end of block\n")
        else:
            fo.write("\t.byte 4\t;; end of animation\n")

        if i == 0:
            fo.write("line_data_frame2:\t;Beginning of second frame\n")


    TOTAL_ANIM_SECONDS = 6.74/2 # 14.6 with player
    ONE_MHZ = 1000000

    cycles_per_pixel = ONE_MHZ * TOTAL_ANIM_SECONDS / total_pixels
    print("Total pixels drawn : {} in {} frames => {:.1f} cycles/pixel".format(total_pixels, len(recorded_lines), cycles_per_pixel))


with open("build/precalc.s","w") as fo:
    for page in [1,2]:
        gen_code_vertical_tile_draw( fo, page)
        gen_code_vertical_tile_blank( fo, page)
        gen_code_vertical_tile_draw_no_tilebreaks( fo, page)

with open("build/htiles.s","w") as fo:
    compute_horizontal_clipping_masks(fo)
    compute_horizontal_tiles(fo)
    compute_horizontal_tiles_up(fo)
    compute_hgr_offsets(fo)



"""

Compute vertical lines in one tile :

T01 = line from (x=0,y=0) to (x=0,y=7)
T02 = (x=0,y=0) - (x=1,7)
T03 = (x=0,y=0) - (2,7)
...
T08 = (x=0,y=0) - (7,7)

Then, slide each of these tiles from left to right, one pixel at a
time, this leads to pair of tiles. => T1n, T2n,..., T8n.

in the end, we have 8 lines in a tile + 7 rotations * 8 lines * 2 tiles = 120 tiles, 8 bytes each => 960 bytes

We want to draw : (x1, y), (x2,y+8)

we assume x1 < x2 and x2 - x1 < 8

d = x2 - x1 ( d < 8 => 3 bits)
r = x1 & 7 (r < 8 => 3 bits)

=> we draw Tdr at x1 >> 3




Compute tile pairs : (A,B). Two horizontally consecutive tiles.




"""
# import PIL
# PIL.

"""
screen = ZBuffer( TILE_SIZE*5,TILE_SIZE*5)
draw_triangle( screen, Vtx(13,13,0), Vtx(5,4,100), Vtx(1,20,100), 2)

draw_triangle_edges( screen, Vtx(13,13,0), Vtx(5,4,100), Vtx(1,20,100), 1)

draw_triangle( screen, Vtx(5,18), Vtx(8,5,120), Vtx(15,10), 0)
draw_triangle_edges( screen, Vtx(5,18), Vtx(8,5,120), Vtx(15,10), 1)
screen.show()
"""

"""
6*256 + 64   :  6
12*256 + 128 : 12 ( 12-6 = 6)
18*256 + 192 : 18 ( 18-12 = 6)
24*256 + 256 : 25 ( 25-18 = 7)

\..
.\.
..\
   \..
   .\.
   ..\


"""
