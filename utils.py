import re
import math
import colorama
import numpy as np
import pygame


APPLE_YRES = 64*3 # 192
APPLE_XRES = 40*7 # 280
APPLE_HGR_PIXELS_PER_BYTE = 7

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

vertex_id = 1

class Vertex:
    def __init__(self,x,y,z=0):
        global vertex_id

        # NAsty !!!! The type of _vec will depend
        # on the type of its value ! if they(re all
        # ints, it'll bt np.int, else np.float !
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

    def round( self):
        v = self
        r = lambda n: int( round( n))
        return Vertex( r(v.x), r(v.y), r(v.z))

    def __mul__(self,other):
        if type(other) == Vertex:
            return np.dot( self._vec, other._vec)
        else:
            v = self._vec
            return Vertex( v[0]*other, v[1]*other, v[2]*other )

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
    def __init__( self, a, b, c = None, z = None, hidden=True):


        if z: # 4 sides
            self.vertices = [a,b,c,z]
            self.normal = (b-a).cross(c-a)
            self.edges = 4
        elif c: # 3 sides
            self.vertices = [a,b,c]
            self.normal = (b-a).cross(c-a)
            self.edges = 3
        else: # 1 side
            assert hidden == False
            self.vertices = [a,b]
            self.edges = 1

        self.hidden = hidden
        self.xformed_vertices = None


def full_enum( v1, v2):
    """ Emuerate points along the longest direction.
    In that direction the enumerate coordinates are
    inclusive. So, if Y is the longest direction
    we enumerate the closed interval [v1.x, v2.x].

    The enumeration returns int's coordinates.
    """
    points = []
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
              points.append( Vertex( int(round(x)), y,  z) )
              y += 1
              x += slope_x
              z += slope_z
         #points = enumerate_x2(v1, v2)

    else:
         if delta.x < 0:
              v1, v2 = v2, v1
              delta = v2 - v1
         elif delta.x == 0:
             points.append( v1)
             return points

         slope_y = delta.y / delta.x
         slope_z = delta.z / delta.x

         x = v1.x
         y = v1.y
         z = v1.z
         for i in range( delta.x+1):
              points.append( Vertex( x, int(round(y)),  z) )
              #points.append( Vertex( x, y, z))
              x += 1
              y += slope_y
              z += slope_z

    return points


def enumerate_x2( v1, v2):
    if v1.y == v2.y:
        return []

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


def draw_triangle( screen, v1, v2, v3, color):
     vert = [ v1, v2, v3]

     # Find the highest vertex and put in it front of the list
     vert = list( sorted( vert, key=lambda v:v.y))

     # put the second vertex on the lefthand side of the third one
     if vert[1].x > vert[2].x:
          vert[1], vert[2] = vert[2], vert[1]

     # The triangle is now cut in two triangles, each of which having an horizontal edge

     left = enumerate_x2( vert[0], vert[1])
     right = enumerate_x2( vert[0], vert[2])

     # print( [str(v) for v in vert])
     # print("Left : {} / {} items".format(left, len(left)))
     # print("Right : {} / {} items".format(right, len(right)))

     if vert[1].y < vert[2].y:
          # We cut at vert[1] (on the left)

          for i in range( (vert[1] - vert[0]).y):
               screen.draw_hline( left[i], right[i], color)

          bottom = enumerate_x2( vert[1], vert[2])
          # print("Bottom : {} / {} items".format(bottom, len(bottom)))

          assert vert[2].y >= vert[1].y
          skipped = vert[1].y - vert[0].y
          # print("bottom height : {}, v1.y = {}".format((vert[2] - vert[1]).y, vert[1].y))

          for i in range( len(bottom)):
               screen.draw_hline( bottom[i], right[skipped + i], color)

     else:
          # we cut at vert[2]
          for i in range( (vert[2] - vert[0]).y):
               screen.draw_hline( left[i], right[i], color)

          bottom = enumerate_x2( vert[2], vert[1])
          # print("Bottom : {} / {} items".format(bottom, len(bottom)))

          assert vert[1].y >= vert[2].y
          skipped = vert[2].y - vert[0].y
          # print("bottom height : {}, v1.y = {}".format((vert[2] - vert[1]).y, vert[1].y))

          for i in range( len(bottom)):
               screen.draw_hline( left[skipped + i], bottom[i], color)



class ZBuffer:
    def __init__( self, w,h):
        self.width, self.height = int(w), int(h)

        self.clear()

    def clear(self):
        dim = ( self.width, self.height )
        self.zbuffer = np.ones( dim ) * np.inf
        self.pixels = np.zeros( dim, dtype=np.uint8 )

    def draw_pixel( self, v, color, offset = 0):
        x = int(v.x)
        y = int(v.y)
        z = v.z

        if 0 <= x < self.width and 0 <= y < self.height:
            # print(f"{x}/{self.width}-{y}/{self.height}")
            # self.pixels[x][y] = color
            # return

            if z <= self.zbuffer[x][y] + offset:
                self.zbuffer[x][y] = z
                if color is not None:
                    self.pixels[x][y] = color


    def draw_hline( self, v1, v2, color):
        assert abs(v1.y- v2.y) < 1, "Expected horizontal line ({:.1f} !={:.1f})".format(v1.y,v2.y)

        if v1.x > v2.x:
            v1,v2 = v2,v1

        z_slope = (v2.z - v1.z) / ( (v2.x - v1.x) or 1)
        z = v1.z
        y = v1.y

        for xi in range( int(v1.x), int(v2.x)+1):
            #print("{} {} {}".format(y,xi,self.zbuffer[y][xi]))
            self.draw_pixel( Vertex(xi,y,z), color)
            z += z_slope

    def draw_face( self, face):
        color = 255
        vert = face.xformed_vertices

        for i in range(len(vert) - 3 + 1):
            draw_triangle( self,
                           vert[0].round(), vert[i+1].round(), vert[i+2].round(),
                           0)

        for i in range(len( vert)):
            a,b = vert[i-1].round(), vert[i].round()
            for p in full_enum(a,b):
                self.draw_pixel( p, color, offset=5)


    def show(self):
        image_to_ascii( self.pixels, TILE_SIZE)

    def show_pygame(self, screen):
        # Normalize Z
        a = np.ma.masked_invalid(self.zbuffer)

        # ptp = find range
        int_range = np.ptp(a)
        print(int_range)
        if int_range:
            z_norm = 256 - 255*(a - np.min(a)) / int_range
        else:
            z_norm = a

        # Z is the blue channel in a RGB image
        stacked_img = np.stack((z_norm,)*3, axis=-1)
        stacked_img[:,:,0] = 0
        stacked_img[:,:,1] = 0

        # Draw graphics in white, over the zbuffer picture
        s = np.argwhere( self.pixels > 0)
        stacked_img[s[:,0], s[:,1], :] = 255
        surface = pygame.Surface( (self.width, self.height) )
        pygame.surfarray.blit_array(surface, stacked_img)

        # Show on screen
        #w, h = pygame.display.get_surface().get_size()

        pygame.transform.scale (surface, screen.get_size(), screen)



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

    if norm_vect == 0:
        # Origin can't be rotated
        return vect[1:]
    #assert norm_vect > 0, f"{vect} norm is not good"

    #print(norm_vect)
    vect = vect/norm_vect
    # Computes the conjugate of quat
    quat_ = np.append(quat[0],-quat[1:])
    # The result is given by: quat * vect * quat_
    res = mult_quat(quat, mult_quat(vect,quat_)) * norm_vect
    return res[1:]

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

def ror( num, bits=8):
    assert bits == 8

    return (num >> 1) + ((num & 1) << (bits-1))

def rol( num, bits=8):
    assert bits == 8

    return ((num << 1) & 0xFF) + (num >> (bits-1))

def invert( num, bits=8):
    return num ^ (2**bits-1)

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
    """ Reorder bits from natural order (MSB is rightmost, LSB is
    leftmost) into Apple's HGR order

       x
    -  0  1  2  3  4  5  6  7  8

    original bits (only the first sevn count):
    0  1  0  0  1  1  1  1

    hgr bits:
    -  1  1  1  1  0  0  1

    The color selection bit is expected in the most significant
    bit and will be left there.
    """

    assert 0 <= b <= 255
    return reverse_bits(b & 0x7f,7) + (b & 0x80)



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

def image_to_ascii( pic, grid_size):
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

def strip_asm_comments( code):
    RE_COMMENT = re.compile("\s*;.*$")

    res = []
    for line in code.split("\n"):
        res.append( RE_COMMENT.sub( "", line))

    return "\n".join( res)

if __name__ == "__main__":
    print("Testing utils...")
    assert bits_to_hgr( 0b01001111) == 0b01111001, "order not preserved"
    assert bits_to_hgr( 0b11001111) == 0b11111001, "color select not preserved"

    assert ror(0) == 0
    assert ror(1) == 0x80
    assert ror(0x81) == 0xC0, "{:8b}".format(ror(0x81))

    assert rol(0) == 0
    assert rol(1) == 2
    assert rol(0x80) == 1

    for i in range(256):
        assert rol(ror(ror(rol(i)))) == i

    print( FixedPoint(123 * 256 + 128))
    print( FixedPoint(- 123 * 256 - 128))
    print( FixedPoint(- 123 * 256 - 128).add(FixedPoint(123 * 256 + 128)))

    assert invert(0,7) == 127
    assert invert(127,7) == 0
    assert invert(64,7) == 1+2+4+8+16+32
