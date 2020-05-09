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
import colorama
import io
import math
import random
random.seed(125)


APPLE_YRES = 64*3 # 192
APPLE_XRES = 40*7 # 280

TILE_SIZE = 7

def is_int(val):
    if type(val) == int:
        return True
    else:
        if val.is_integer():
            return True
        else:
            return False


def int_to_16(x : float):
    assert -128 <= x <= 127, f"{x} is not representable as signed 8 bit value"

    x = int( round(x * 256))

    if x >= 0:
        return x
    else:
        # remember, 0xFFFF == -1
        return 65536 + x

def reverse_bits(num,bitSize=8):

    assert num == 0 or math.log( num, 2) < bitSize

    # 100 -> 001 -> 00100000 (bitsize bits)

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
    assert len(reverse) <= bitSize
    reverse = reverse + (bitSize - len(reverse))*'0'

    # converts reversed binary string into integer
    return int(reverse,2)

def rotate_array(arr,numOfRotations = 1):
    arr = list(arr)
    return arr[numOfRotations:]+arr[:numOfRotations]

def logical_or(a,b):
    if a > 0:
        return a
    else:
        return b



def bits_to_hgr(b):
    """ Reorder bits from natural order (MSB is rightmost, LSB is leftmost)
    into Apple's HGR order
    """
    assert 0 <= b < 128
    return reverse_bits(b) >> 1

def hgr_address( y, page=0x2000, format=0):
    assert page == 0x2000 or page == 0x4000, "I'll work only for legal pages"
    assert 0 <= y < APPLE_YRES, "You're outside Apple's veritcal resolution"

    if 0 <= y < 64:
        ofs = 0
    elif 64 <= y < 128:
        ofs = 0x28
    else:
        ofs = 0x50

    i = (y % 64) // 8
    j = (y % 64) % 8

    if format == 0:
         return "${:X} + ${:X}".format( page + ofs + 0x80*i, 0x400*j)
    else:
         return "${:X}".format( page + ofs + 0x80*i + 0x400*j)

def image_to_ascii( pic, grid_size = TILE_SIZE):
    data = []
    sym = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

    with colorama.colorama_text() as ctx:
        for y in range( pic.shape[0]):
            r= []
            for x in range( pic.shape[1]):
                if pic[ y][ x] == 0:
                    if y % grid_size == 0 and x % grid_size == 0:
                        r += "+-"
                    elif y % grid_size == 0:
                        r += "--"
                    elif x % grid_size == 0:
                        r += "| "
                    elif (y+x)%2 == 0:
                        r += ".."
                    else:
                        r += "  "
                elif pic[ y][ x] == 1:
                    r += "\u2588\u2588"
                elif pic[ y][ x] == 2:
                    r += "##"
                elif pic[ y][ x] == 3:
                    r += "//"

            data.append("".join(r))

        for l in data:
            print(l)
    print()

    return data


def array_to_asm( fo, a, line_prefix, label = ""):

    if type(a[0]) == str:
        fmt = "{}"
    elif line_prefix in ('!word','.word'):
        fmt = "${:04x}"
    elif line_prefix in ('!byte','.byte'):
        fmt = "${:02x}"
    else:
        raise Exception("Unknown format {}".format( line_prefix))

    if label:
        label = "{}:".format(label)
    else:
        label = ""

    fo.write("{}\t; {} values\n".format(label, len(a)))
    for i in range( 0, len( a), 10):
        end = min( i + 10, len( a))
        fo.write("\t{} {}\n".format( line_prefix, ", ".join( [ fmt.format(x) for x in a[i:end]])))


def make_lo_hi_ptr_table( fo, name, items):
     lo_ptrs = [ "<{}".format(i) for i in items]
     hi_ptrs = [ ">{}".format(i) for i in items]

     # fo.write("\n")
     # fo.write("{}_lo:\t.byte {}\n".format( name, ", ".join(lo_ptrs)))
     # fo.write("{}_hi:\t.byte {}\n".format( name, ", ".join(hi_ptrs)))

     fo.write("{}_lo:\n".format( name ))
     ndx=0
     for lo in lo_ptrs:
          fo.write("\t.byte {}\t; {}\n".format( lo, ndx))
          ndx+=1

     fo.write("{}_hi:\n".format( name ))
     ndx=0
     for hi in hi_ptrs:
          fo.write("\t.byte {}\t; {}\n".format( hi, ndx))
          ndx+=1


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


        if y % 11 == 0:
            eo_label = f"early_out_p{page}_{early_out_count}"
            #fo.write(f"\tCLV\n")
            fo.write(f"\n\tBVC {eo_label}_skip\t; always taken\n")
            fo.write(f"{eo_label}:\n\tRTS\n")
            fo.write(f"{eo_label}_skip:\n\n")
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

        fo.write(f"""
{prefix}line{y}:
        LDA (tile_ptr),Y\t; 5+ (+ = page boundary)
        ORA {line_base},X\t; 4+
        STA {line_base},X\t; 5
        DEY\t; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
{nop_label_code}        BMI {eo_label}
""")
        # .format( prefix, y,
        #        line_base, line_base,
        #        prefix, y,
        #        prefix, y,
        #        prefix, y ))

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

        if y % 11 == 0:
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

class FixedPoint:
    def __init__(self, x = 0):
        if x >= 0:
            self.x = x
        else:
            self.x = 65536 + x

    def add( self, fp : "FixedPoint"):
        return FixedPoint( (self.x + fp.x) & 65535)

    def __str__( self):
        if self.x & 32768 == 0:
            f = self.x / 256
        else:
            f = - (65536-self.x) / 256

        return str(f)


print( FixedPoint(123 * 256 + 128))
print( FixedPoint(- 123 * 256 - 128))
print( FixedPoint(- 123 * 256 - 128).add(FixedPoint(123 * 256 + 128)))

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


def full_enum( v1, v2):
    xs = []
    delta = v2 - v1

    if delta.y*delta.y > delta.x*delta.x:

         if delta.y < 0:
              v1, v2 = v2, v1
              delta = v2 - v1

         slope_x = delta.x / delta.y
         slope_z = delta.z / delta.y

         x = v1.x
         z = v1.z
         y = v1.y
         for i in range( delta.y+1):
              xs.append( Vertex( int(round(x)), y,  z) )
              y += 1
              x += slope_x
              z += slope_z

    else:
         if delta.x < 0:
              v1, v2 = v2, v1
              delta = v2 - v1

         slope_y = delta.y / delta.x
         slope_z = delta.z / delta.x

         x = v1.x
         z = v1.z
         y = v1.y
         for i in range( delta.x+1):
              xs.append( Vertex( x, int(round(y)),  z) )
              x += 1
              y += slope_y
              z += slope_z

    return xs


def enumerate_x2( v1, v2):
    assert v1.y < v2.y

    delta = v2 - v1
    slope_x = delta.x / delta.y
    slope_z = delta.z / delta.y

    xs = []
    x = v1.x
    z = v1.z
    y = v1.y
    for i in range( delta.y+1):
        xs.append( Vertex( int(round(x)), y,  z) )
        y += 1
        x += slope_x
        z += slope_z

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

    xs = enumerate_x(x1, y1, x2, y2)

    y = y1
    for i in range( dy+1):
        npa[y][xs[i]] = 1
        y += 1


def draw_hline( npa, x1, y1, x2, y2, color):

     a = Vertex( x1, y1)
     b = Vertex( x2, y2)

     points = full_enum(a,b)

     for p in points:
          npa[ int(p.y) ][ int(p.x) ] = 1

vertex_id = 1

class Vertex:
    def __init__(self,x,y,z=0):
        global vertex_id

        self._vec = np.array( [x,y,z] )
        self._id = vertex_id
        vertex_id += 1

    def grab_id( self, other):
        self._id = other._id
        return self

    @property
    def id(self):
        return self._id

    @property
    def x(self):
        return self._vec[0]

    @property
    def y(self):
        return self._vec[1]

    @property
    def z(self):
        return self._vec[2]

    def cross( self, other):
        v = np.cross( self._vec, other._vec)
        return Vertex( v[0], v[1], v[2] )

    def __mul__(self,other):
        return np.dot( self._vec, other._vec)

    def __add__(self,other):
        v = self._vec + other._vec
        return Vertex( v[0], v[1], v[2] )

    def __sub__(self,other):
        v = self._vec - other._vec
        return Vertex( v[0], v[1], v[2] )

    def __str__(self):
        return "{},{},{}".format(self.x, self.y, self.z)

class Edge:
    def __init__( self, v1, v2):
        self.v1, self.v2 = v1, v2

class Face:
    def __init__( self, a, b, c, z = None):
        if z:
            self.vertices = [a,b,c,z]
        else:
            self.vertices = [a,b,c]
        self.normal = (b-a).cross(c-a)


def angle_axis_quat(theta, axis):
    """
    Given an angle and an axis, it returns a quaternion.
    """
    axis = np.array(axis) / np.linalg.norm(axis)
    return np.append([np.cos(theta/2)],np.sin(theta/2) * axis)

def mult_quat(q1, q2):
    """
    Quaternion multiplication.
    """
    q3 = np.copy(q1)
    q3[0] = q1[0]*q2[0] - q1[1]*q2[1] - q1[2]*q2[2] - q1[3]*q2[3]
    q3[1] = q1[0]*q2[1] + q1[1]*q2[0] + q1[2]*q2[3] - q1[3]*q2[2]
    q3[2] = q1[0]*q2[2] - q1[1]*q2[3] + q1[2]*q2[0] + q1[3]*q2[1]
    q3[3] = q1[0]*q2[3] + q1[1]*q2[2] - q1[2]*q2[1] + q1[3]*q2[0]
    return q3

def rotate_quat(quat, vect):
    """
    Rotate a vector with the rotation defined by a quaternion.
    """
    # Transfrom vect into an quaternion
    vect = np.append([0],vect)
    # Normalize it
    norm_vect = np.linalg.norm(vect)
    vect = vect/norm_vect
    # Computes the conjugate of quat
    quat_ = np.append(quat[0],-quat[1:])
    # The result is given by: quat * vect * quat_
    res = mult_quat(quat, mult_quat(vect,quat_)) * norm_vect
    return res[1:]


import pygame
pygame.init()

size = width, height = 7*40, APPLE_YRES
speed = [2, 2]
black = 0, 0, 0

screen = pygame.display.set_mode(size)

# https://www.youtube.com/watch?v=juXlFqhKrEM
# 255 images en 13 secondes => 19 fps
# my engine : 29*2 in 2.39s => 24 fps (zoom factor = 250)
# zoom factor = 500 : 29*2 in 4.22s => 13fps
# 45 / 4 = 11 fps
# 70/8.3 = 8.4

def persp( v):
    zoom = 250 # 250 is the ref, 590 is max for tetrahedron
    d = (v.z + 5) / zoom
    return Vtx( v.x / d + APPLE_XRES / 2, v.y / d + APPLE_YRES / 2, 0 )

recorded_lines = []
NB_FRAMES = 80
axis = [3,2,0.5]
theta = 0


Vtx = Vertex

# Tetrahedron
# a = Vtx(-1,-1,0)
# b = Vtx(+1,-1,0)
# c = Vtx(0,+1,-1)
# d = Vtx(0,+1,+1)
# faces = [ Face(a,b,c), Face(a,d,b), Face( c,b,d), Face( c,d,a)  ]

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

faces = [ Face(a,b,c,d), # front
          Face( d,c,cp,dp), # top
          Face( b,a,ap,bp), # bottom
          Face( a,d,dp,ap), # left
          Face( b,bp,cp,c), # right

          Face(ap,app,bpp,bp),
          Face(bp,bpp,cpp,cp),
          Face(dp,cp,cpp,dpp),
          Face(ap,dp,dpp,app),

          Face(app,appp,bppp,bpp),
          Face(bpp,bppp,cppp,cpp),
          Face(dpp,cpp,cppp,dppp),
          Face(app,dpp,dppp,appp),

          Face(dppp,cppp,bppp,appp), #rear
         ]





# Animate

for frame_ndx in range(NB_FRAMES):
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            sys.exit()

    screen.fill(black)

    theta = frame_ndx * 2*math.pi / NB_FRAMES
    rot = angle_axis_quat(theta, axis)

    drawn_edges = set()

    frame_lines = []

    t_y = -0
    for face in faces:

        vp = [ persp( Vtx( *rotate_quat( rot, [v.x,v.y,v.z]))).grab_id(v)
               for v in face.vertices ]

        v1 = vp[0] - vp[1]
        v2 = vp[0] - vp[2]
        if v1.cross(v2).z < 0:
            #pass
            continue

        for i in range( len( face.vertices)):
            a,b = vp[i], vp[(i+1)%len(face.vertices)]

            k = min( a.id, b.id), max( a.id, b.id)
            if k not in drawn_edges:
                drawn_edges.add( k)
                pygame.draw.line( screen, (255,255,255),
                                  (a.x,a.y + t_y),
                                  (b.x,b.y + t_y), 1)

                frame_lines.append( (a.x,a.y + t_y,
                                     b.x,b.y + t_y) )

    recorded_lines.append( frame_lines)

    pygame.display.flip()




def draw_triangle_edges( scren, v1, v2, v3, color):
     vert = [ v1, v2, v3]

     left = full_enum( vert[0], vert[1])
     right = full_enum( vert[0], vert[2])
     bottom = full_enum( vert[1], vert[2])

     for i in range( len(left)):
          screen.draw_pixel( left[i], color, offset=1)

     for i in range( len(right)):
          screen.draw_pixel( right[i], color, offset=1)

     for i in range( len( bottom)):
          screen.draw_pixel( bottom[i], color, offset=1)

def draw_triangle( scren, v1, v2, v3, color):
     vert = [ v1, v2, v3]

     # Find the highest vertex and put in it front of the list
     vert = list( sorted( vert, key=lambda v:v.y))

     # put the second vertex on the lefthand side of the third one
     if vert[1].x > vert[2].x:
          vert[1], vert[2] = vert[2], vert[1]

     # The triangle is now cut in two triangles, each of which having an horizontal edge

     left = enumerate_x2( vert[0], vert[1])
     right = enumerate_x2( vert[0], vert[2])

     print( [str(v) for v in vert])
     print("Left : {} / {} items".format(left, len(left)))
     print("Right : {} / {} items".format(right, len(right)))

     if vert[1].y < vert[2].y:
          # We cut at vert[1] (on the left)

          for i in range( (vert[1] - vert[0]).y):
               screen.draw_hline( left[i], right[i], color)

          bottom = enumerate_x2( vert[1], vert[2])
          print("Bottom : {} / {} items".format(bottom, len(bottom)))

          assert vert[2].y >= vert[1].y
          skipped = vert[1].y - vert[0].y
          print("bottom height : {}, v1.y = {}".format((vert[2] - vert[1]).y, vert[1].y))

          for i in range( len(bottom)):
               screen.draw_hline( bottom[i], right[skipped + i], color)

     else:
          # we cut at vert[2]
          for i in range( (vert[2] - vert[0]).y):
               screen.draw_hline( left[i], right[i], color)

          bottom = enumerate_x2( vert[2], vert[1])
          print("Bottom : {} / {} items".format(bottom, len(bottom)))

          assert vert[1].y >= vert[2].y
          skipped = vert[2].y - vert[0].y
          print("bottom height : {}, v1.y = {}".format((vert[2] - vert[1]).y, vert[1].y))

          for i in range( len(bottom)):
               screen.draw_hline( left[skipped + i], bottom[i], color)



# def cross(a, b):
#     c = [a[1]*b[2] - a[2]*b[1],
#          a[2]*b[0] - a[0]*b[2],
#          a[0]*b[1] - a[1]*b[0]]

#     return c


class ZBuffer:
     def __init__( self, w,h):
          self.width, self.height = int(w), int(h)

          dim = ( self.width, self.height )
          self.zbuffer = np.ones( dim ) * 1000
          self.pixels =  np.zeros( dim, dtype=np.uint8 )

     def draw_pixel( self, v, color, offset = 0):
          if v.z < self.zbuffer[v.y][v.x] + offset:
               self.zbuffer[v.y][v.x] = v.z
               self.pixels[v.y][v.x] = color


     def draw_hline( self, v1, v2, color):
          assert v1.y == v2.y, "({}) ({})".format(v1,v2)

          if v1.x > v2.x:
               v1,v2 = v2,v1

          z_slope = (v2.z - v1.z) / ( (v2.x - v1.x) or 1)
          z = v1.z
          y = v1.y

          for xi in range( v1.x, v2.x+1):
               print("{} {} {}".format(y,xi,self.zbuffer[y][xi]))
               if z < self.zbuffer[y][xi]:
                    self.pixels[y][xi] = color
                    self.zbuffer[y][xi] = z
               z += z_slope

     def show(self):
         image_to_ascii( self.pixels)


def seven_bits_split(t):
     assert (TILE_SIZE + 1) % 8 == 0
     assert t.shape[0] == TILE_SIZE
     assert t.shape[1] == 2*TILE_SIZE

     t1, t2 = np.hsplit(t, 2)

     # The MSB is the one for the color selection in HGR, we live it zero.
     column = np.zeros( (TILE_SIZE,1,), dtype=np.bool_)
     t1 = np.concatenate( (column, t1), axis=1)
     t2 = np.concatenate( (column, t2), axis=1)

     image_to_ascii( np.concatenate( (t1, t2), axis=1), grid_size=8)

     bm1 = np.packbits( t1, axis=1).flatten()
     bm2 = np.packbits( t2, axis=1).flatten()

     return bm1, bm2


def make_tiles_pairs( fo, bm1, bm2):
     # bm1 = left side of the tile (as bits in an integer)
     # bm2 = right side of the tile

     old_m1, old_m2 = None, None
     tile_break = None

     tss = None # Tile split shape

     fo.write( "\t; The vertical order is reversed !\n") # Because it allows a DEY ; BPL xxx construct in the assembler code
     for i in reversed(range(TILE_SIZE)):

          # to better understand, imagine that bm1 and bm2 are side by side.
          # We look at each row of them together.

          m1 = bm1[i]
          m2 = bm2[i]

          assert (m1 == 0 and m2 != 0) or (m1 != 0 and m2 == 0), "both tiles' parts can't be 'lit' together"

          # The following code works regardless of the i enumeration
          # order.

          if tss is None:
              tss = (bm1[i]   > 0, bm2[i]   > 0)
          else:
              tss_new = (bm1[i]   > 0, bm2[i]   > 0)
              if tss != tss_new:
                  assert tile_break is None, "Tile's sides change can occur only once"
                  tb = i
                  print("     tile break {}".format(tb))
                  tile_break = i
              tss = tss_new

          # We store only the non zero part of tiles.
          # There's only one of these part in each tile (that is
          # a tile is split in two : the zero part and the non zero part;
          # one of these part starts at the top of the tile, the other
          # ends at the end of the tile).

          # logical or is the shortcut one : if m1 then m1 else m2
          # rememeber one and only one of m1,m2 is zero
          # (see assert above)

          bits = bits_to_hgr( logical_or( m1, m2))

          fo.write( "\t.byte {:3}\t; {:08b}\n".format( bits, logical_or( m1, m2)))

          old_m1, old_m2 = m1, m2

     return tile_break

def compute_vertical_tiles():
     with open("tiles.s","w") as fo:
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

               # + 1 because ??? (code seems to need that, many bugs without !)
               for rol_ndx in range( TILE_SIZE +1):
                    rol = min( rol_ndx, TILE_SIZE - 1)
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
     with open("tiles_lr.s","w") as fo:
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
                    print("{}:".format(n))
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
                         tile_breaks_indices.append( "$FF")

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



def compute_horizontal_masks( fo):
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
    column = np.zeros( (TILE_SIZE,1,), dtype=np.bool_)

    for ndx in range( TILE_SIZE+1):
        # Off by one protection
        i = min( ndx, TILE_SIZE - 1)

        t = np.zeros( (TILE_SIZE,TILE_SIZE), np.uint8)
        draw_hline( t, 0,0, TILE_SIZE-1, i, 1)
        image_to_ascii( t, grid_size=TILE_SIZE)


        t1 = np.concatenate( (column, t), axis=1)
        t1 = t

        bm1 = np.packbits( t1, axis=1).flatten()
        rb = [ reverse_bits( row) for row in bm1]

        rb = list(reversed(rb[0:i+1])) + [0]*(TILE_SIZE - i)

        # rb += [0] # Make sure we have 8 bytes rows (instead of 7); 8 is easier to use in assembly
        # print(rb)

        fo.write("HTILE_{}:\t.byte {}\n".format( ndx, ",".join(["${:02X}".format(x) for x in rb]) ))

        # for rol in range( TILE_SIZE):
        #      image_to_ascii( t, grid_size=TILE_SIZE)
        #      # prepare next iteration by rotating the tile
        #      # one byte to the right
        #      t = np.roll(t,1,axis=0)


def compute_horizontal_tiles_up(fo):
    fo.write("HTILE_UP:\n")

    for i in range( TILE_SIZE):

        # Off by one protection
        i = min( i, TILE_SIZE - 1)

        t = np.zeros( (TILE_SIZE,TILE_SIZE), np.uint8)
        draw_hline( t, 0,i, TILE_SIZE-1, 0, 1)
        image_to_ascii( t, grid_size=TILE_SIZE)

        bm1 = np.packbits( t, axis=1).flatten()

        # Order bits per Apple2 HGR convention
        rb = [ reverse_bits( row) for row in bm1]

        rb = list(reversed(rb[0:i+1])) + [0]*(TILE_SIZE - i)
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

def clip( a, b):

    LIMY = TILE_SIZE
    BOTY = APPLE_YRES - TILE_SIZE

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
            assert ca.x >= 0

        if b.y > BOTY:
            cb = Vertex( a.x + s*abs(BOTY - a.y), BOTY)

    return ca, cb

def hclip( a, b):

    if a is None or b is None:
        return None, None

    LIMX = 8
    BOTX = 255 - TILE_SIZE

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
            assert ca.y >= 0

        if b.x > BOTX:
            cb = Vertex( BOTX, a.y + s*abs(BOTX - a.x))

    return ca, cb

def gen_data_line( fo, a, b):
    a,b = hclip( *clip(a,b) )

    if a == None:
        return


    dx, dy = (b - a).x, (b - a).y

    # print(b-a)
    if dx*dx > dy*dy:
        #return

        # mostly horizontal line
        if a.x > b.x:
            a,b = b,a
            dx, dy = (b - a).x, (b - a).y

        assert -256*TILE_SIZE < int(256.0*TILE_SIZE*dy/dx) < 256*TILE_SIZE, "{} / {}".format(int(256.0*TILE_SIZE*dy/dx), 256*6)
        assert dx > 0

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
        if rx % TILE_SIZE < TILE_SIZE-1:
            f = TILE_SIZE - 1 - (rx % TILE_SIZE)
            # we must extend to the left to have a complete tile
            b = Vertex( int(b.x + f),
                        int(b.y + f * dy/dx))
            right_mask = rx % TILE_SIZE
        else:
            right_mask = 0

        dx, dy = (b - a).x, (b - a).y

        slope = TILE_SIZE * dy/dx
        dx_int = (int(b.x) // TILE_SIZE) - (int(a.x) // TILE_SIZE) + 1
        d = [ 0 + (right_mask << 5),
              int(a.x), int(a.y),
              (dx_int << 3) + left_mask,
              int_to_16( TILE_SIZE*dy/dx)]

    else:
        #return
        # mostly vertical line ( |dx| < |dy|)
        if a.y > b.y:
            a,b = b,a
            dx, dy = (b - a).x, (b - a).y

        assert dy >= 0
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
with open("lines.s","w") as fo:

    fo.write("; generated \n")
    fo.write("; line type (0=horiz/1=verti), X start, Y start, length, slope (word) \n")

    # 5:
    for i,frame in enumerate(recorded_lines):
        if i == 0:
            fo.write("line_data_frame1:\t;Beginning of first frame\n")

        for li,l in enumerate(frame):
            # if i > 0 or 10 <= li <= 12:
            gen_data_line( fo, Vertex( l[0],l[1]), Vertex(l[2],l[3]))

        if frame != recorded_lines[-1]:
            fo.write("\t.byte 3\t;; end of block\n")
        else:
            fo.write("\t.byte 4\t;; end of animation\n")

        if i == 0:
            fo.write("line_data_frame2:\t;Beginning of second frame\n")


with open("precalc.s","w") as fo:
    gen_code_vertical_tile_draw( fo, page=1)
    gen_code_vertical_tile_blank( fo, page=1)
    gen_code_vertical_tile_draw( fo, page=2)
    gen_code_vertical_tile_blank( fo, page=2)

with open("htiles.s","w") as fo:
    compute_horizontal_masks(fo)
    compute_horizontal_tiles(fo)
    compute_horizontal_tiles_up(fo)
    compute_hgr_offsets(fo)


exit();





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

screen = ZBuffer( TILE_SIZE*5,TILE_SIZE*5)
draw_triangle( screen, Vtx(13,13,0), Vtx(5,4,100), Vtx(1,20,100), 2)

draw_triangle_edges( screen, Vtx(13,13,0), Vtx(5,4,100), Vtx(1,20,100), 1)

draw_triangle( screen, Vtx(5,18), Vtx(8,5,120), Vtx(15,10), 0)
draw_triangle_edges( screen, Vtx(5,18), Vtx(8,5,120), Vtx(15,10), 1)
screen.show()

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
