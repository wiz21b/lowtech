import re
import math
import colorama
import numpy as np
import pygame


APPLE_YRES = 64*3 # 192
APPLE_XRES = 40*7 # 280
APPLE_HGR_PIXELS_PER_BYTE = 7
TRACKS_PER_DISK = 35
SECTORS_PER_TRACK = 16
DISK_SIZE = TRACKS_PER_DISK*SECTORS_PER_TRACK*256

class AppleDisk:
    DOS_SECTORS_MAP = [0x0, 0x7, 0xe, 0x6, 0xd, 0x5, 0xc, 0x4,
                       0xb, 0x3, 0xa, 0x2, 0x9, 0x1, 0x8, 0xf]

    def __init__( self, filename = None):
        self.filename = filename

        if not filename:
            self._disk = bytearray( DISK_SIZE)
        else:
            with open(filename,"rb") as fin:
                self._disk = bytearray(fin.read( DISK_SIZE))

    def set_sector(self, track : int, logical_sector : int, data : bytearray):
        assert len(data) == 256
        assert type(data) == bytearray
        assert 0 <= track < TRACKS_PER_DISK
        assert 0 <= logical_sector < SECTORS_PER_TRACK

        sector = self.DOS_SECTORS_MAP[logical_sector]
        track_offset = track * SECTORS_PER_TRACK * 256
        dsk_ofs = track_offset + sector*256
        self._disk[dsk_ofs:dsk_ofs+256] = data

    def save(self):
        assert self.filename

        with open( self.filename,"wb") as fout:
            fout.write( self._disk)



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
    def vid(self):
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

    def z_cleared(self):
        return Vertex( self.x, self.y, 0)

    def cross( self, other):
        v = np.cross( self._vec, other._vec)
        return Vertex( v[0], v[1], v[2] )

    def round( self):
        v = self
        r = lambda n: int( round( n))
        return Vertex( r(v.x), r(v.y), v.z)

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
        return "{:.1f},{:.1f},{:.1f}".format(self.x, self.y, self.z)

class Edge:
    def __init__( self, v1, v2):
        self.v1, self.v2 = v1, v2


def special_points( v):
    top = v[0]
    top_ndx = 0
    for i,p in enumerate( v[1:]):
        if p.y < top.y:
            top = p
            top_ndx = i+1

    # Find left and right vectors
    v_left = v[top_ndx - 1]
    v_right = v[top_ndx - 2]

    if (v_left - top).z_cleared().cross((v_right - top).z_cleared()).z > 0:
        v_left, v_right = v_right, v_left

    return top, v_left, v_right

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
        self.number = None

    def topmost_point(self):

        top = self.xformed_vertices[0]
        top_ndx = 0
        for i,p in enumerate(self.xformed_vertices[1:]):
            if p.y < top.y:
                top = p
                top_ndx = i+1
        return top, top_ndx


    def compute_z_slope_along_x( self, v = None):

        if v is None:
            assert self.xformed_vertices
            v = self.xformed_vertices

        top, v1, v2 = special_points(v)

        # print("Compute")
        # print( str( top))
        # print( str( v1))
        # print( str( v2))

        y = min( v1.y, v2.y) - top.y

        # Compute intersection of line Y=y with left and right vectors
        # (coordinates relative to top of the triangle)

        # for i in range(10):
        #     y = (min( v1.y, v2.y) - top.y) * (i+1) / 10
        d1 = v1 - top
        x_left = y * d1.x / d1.y
        z_left = y * d1.z / d1.y

        d2 = v2 - top
        x_right = y * d2.x / d2.y
        z_right = y * d2.z / d2.y

        self.zx_slope = (z_left - z_right) / (x_left - x_right)
        #print(self.zx_slope)

        return self.zx_slope

def cube( size=1, translate = Vertex(0,0,0), hidden=True):
    Vtx = Vertex

    ap = Vtx(-size,-size,-size) + translate
    bp = Vtx(+size,-size,-size) + translate
    cp = Vtx(+size,+size,-size) + translate
    dp = Vtx(-size,+size,-size) + translate

    app = Vtx(-size,-size,size) + translate
    bpp = Vtx(+size,-size,size) + translate
    cpp = Vtx(+size,+size,size) + translate
    dpp = Vtx(-size,+size,size) + translate

    faces = [ Face( ap,bp,cp,dp,hidden), # front
              Face( dpp,cpp,bpp,app,hidden),

              Face( cp,cpp,dpp,dp,hidden),
              Face( bp,bpp,cpp,cp,hidden),
              Face( ap,app,bpp,bp,hidden),
              Face( dp,dpp,app,ap,hidden),
             ]

    return faces


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
         for i in range( int(delta.y)+1):
              points.append( Vertex( x, y,  z) )
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
         for i in range( int(delta.x)+1):
              points.append( Vertex( x, y,  z) )
              #points.append( Vertex( x, y, z))
              x += 1
              y += slope_y
              z += slope_z

    return points


def enumerate_x2( v1, v2):

    assert abs(v1.y - int(v1.y)) < 0.00001, "Expecting integer Y"
    assert abs(v2.y - int(v2.y)) < 0.00001, "Expecting integer Y"

    if v1.y == v2.y:
        return []

    assert v1.y < v2.y

    delta = v2 - v1

    # if delta.y*delta.y > delta.x*delta.x:
    #     return full_enum(v1,v2)

    slope_x = delta.x / delta.y
    slope_z = delta.z / delta.y

    points = []
    x = v1.x
    y = v1.y
    z = v1.z
    for i in range( int(delta.y)+1): # int is a type cast, not a  rounding.
        points.append( Vertex( x, y, z))
        x += slope_x
        y += 1
        z += slope_z

    return points


def draw_triangle( screen, face, v1, v2, v3, color):
     vert = [ v1, v2, v3]

     # # Find the highest vertex and put in it front of the list
     # vert = list( sorted( vert, key=lambda v:v.y))

     # # put the second vertex on the lefthand side of the third one
     # if vert[1].x > vert[2].x:
     #      vert[1], vert[2] = vert[2], vert[1]

     vert = special_points( vert)

     # The triangle is now cut in two triangles, each of which having an horizontal edge

     left = enumerate_x2( vert[0], vert[1])
     right = enumerate_x2( vert[0], vert[2])

     # print( [str(v) for v in vert])
     # print("Left : {} / {} items".format(left, len(left)))
     # print("Right : {} / {} items".format(right, len(right)))

     if vert[1].y < vert[2].y:
          # We cut at vert[1] (on the left)

          for i in range( int((vert[1] - vert[0]).y)):

              #print("1[{}] Left: X={:.1f}, Z={:.1f} | Right: X={:.1f}, Z={:.1f}".format( i, left[i].x, left[i].z, right[i].x, right[i].z))

              screen.draw_hline( left[i], right[i], color, face.zx_slope)

          bottom = enumerate_x2( vert[1], vert[2])
          # print("Bottom : {} / {} items".format(bottom, len(bottom)))

          assert vert[2].y >= vert[1].y
          skipped = int(vert[1].y - vert[0].y)
          # print("bottom height : {}, v1.y = {}".format((vert[2] - vert[1]).y, vert[1].y))

          for i in range( len(bottom)):
              #print("2[{}] Left: X={:.1f}, Z={:.1f} | Right: X={:.1f}, Z={:.1f}".format( i, bottom[i].x, bottom[i].z, right[skipped+i].x, right[skipped+i].z))
              screen.draw_hline( bottom[i], right[skipped + i], color, face.zx_slope)

     else:
          # we cut at vert[2]
          for i in range( int((vert[2] - vert[0]).y)):
              #print("XX 1[{}] Left: X={:.1f}, Z={:.1f} | Right: X={:.1f}, Z={:.1f}".format( i, left[i].x, left[i].z, right[i].x, right[i].z))
              screen.draw_hline( left[i], right[i], color, face.zx_slope)

          bottom = enumerate_x2( vert[2], vert[1])
          # print("Bottom : {} / {} items".format(bottom, len(bottom)))

          assert vert[1].y >= vert[2].y
          skipped = int(vert[2].y - vert[0].y)
          # print("bottom height : {}, v1.y = {}".format((vert[2] - vert[1]).y, vert[1].y))

          for i in range( len(bottom)):
              #print("XX 2[{}] Left: X={:.1f}, Z={:.1f} | Right: X={:.1f}, Z={:.1f}".format( i, left[skipped+i].x, left[skipped+i].z, bottom[i].x, bottom[i].z))
              screen.draw_hline( left[skipped + i], bottom[i], color, face.zx_slope)



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


    def draw_line( self, a, b, color, supporting_faces = ()):
        #return

        pts = full_enum(a.round(),b.round())

        prev_visibility = None
        prev_point = None
        segments = []

        for p in pts:
            # print(p)
            # print(supporting_faces)

            x,y = int(p.x), int(p.y)
            if 0 <= x < self.width and 0 <= y < self.height:

                if self.pixels[x][y] in supporting_faces:
                    pt_visibility = True
                    self.pixels[x][y] = color
                else:
                    pt_visibility = p.z <= self.zbuffer[x][y]
                    if pt_visibility:
                        self.draw_pixel( p, color)


                if pt_visibility and prev_visibility == None:
                    prev_visibility = pt_visibility
                    prev_point = p

                elif (p == pts[-1] and prev_visibility) or (pt_visibility != prev_visibility) :

                    if prev_visibility:
                        segments.append( (prev_point,p) )
                    prev_visibility = pt_visibility
                    prev_point = p

                elif not pt_visibility:
                    prev_visibility = False
                    prev_point = p
            else:
                if prev_visibility == True:
                    segments.append( (prev_point,p) )
                    prev_visibility = False
                    prev_point = p

        return segments


        # delta = b-a

        # if abs(delta.x) > abs(delta.y):

        #     if a.y > b.y:
        #         a,b = b,a
        #         delta = b - a

        #     if abs(delta.y) < 1:
        #         return

        #     pts = enumerate_x2( a, b)

        #     for i in range(len(pts)-1):
        #         self.draw_hline( pts[i],
        #                          Vertex( pts[i+1].x, pts[i].y, pts[i+1].z),
        #                          color)


    def draw_hline( self, v1, v2, color, zslope=None):
        """
        Big idea : an edge is not a triangle.
        So if a point counts as being "on th edge", is it on the "triangle" ?
        That's even more true when the edge is between two triangles : to which triangle
        does it belong ?
        """
        assert abs(v1.y- v2.y) < 0.01, "Expected horizontal line ({:.1f} !={:.1f})".format(v1.y,v2.y)

        if v1.x > v2.x:
            v1,v2 = v2,v1

        if True or zslope is None:
            z_slope = (v2.z - v1.z) / ( (v2.x - v1.x) or 1)
        else:
            z_slope = zslope

        #print("{} -- {}".format((v2.z - v1.z) / ( (v2.x - v1.x) or 1), zslope))
        y = v1.y
        z = v1.z

        # Left side of the hline
        dx = v1.x - int(v1.x)

        if dx < 0:
            # because v1.x is negative...
            dx = - dx

        assert dx>=0
        #print(f"{v1.x} > {dx} -- z={z} slope={z_slope}")
        x = int(v1.x)
        z = v1.z - z_slope * dx
        # Draw leftmost pixel
        self.draw_pixel( Vertex(x,y,z), color)

        z += z_slope
        x += 1

        # Rightmost pixel
        dx = v2.x - int(v2.x)
        #assert dx>=0, f"dx:{dx} not >= 0, v2.x={v2.x}"
        z_end = v2.z - z_slope * dx
        x_end = int(v2.x)
        self.draw_pixel( Vertex(x_end,y,z_end), color)
        x_end -= 1

        # Inner pixels

        if x <= x_end:
            for xi in range( x, x_end + 1):
                self.draw_pixel( Vertex(xi,y,z), color)
                z += z_slope


    def draw_face( self, face):
        color = face.number
        vert = face.xformed_vertices

        # for i in range(len( vert)):
        #     a,b = vert[i-1].round(), vert[i].round()
        #     self.draw_line(a,b,color)


        for i in range(len(vert) - 3 + 1):
            v = [vert[0].round(), vert[i+1].round(), vert[i+2].round()]
            face.compute_z_slope_along_x(v)

            draw_triangle( self,
                           face,
                           v[0], v[1], v[2],
                           color)


        # for i in range(len( vert)):
        #     a,b = vert[i-1].round(), vert[i].round()

        #     if a.y > b.y:
        #         a,b=b,a

        #     for p in enumerate_x2(a,b):
        #         self.draw_pixel( p, color, offset=5)


    def show(self):
        image_to_ascii( self.pixels, TILE_SIZE)

    def show_pygame(self, screen):
        # Normalize Z
        a = np.ma.masked_invalid(self.zbuffer) # Mask "NAN"s
        a = np.ma.filled( a, np.max(a)) # Replace maske NAN by max(a)


        # ptp = find range
        int_range = np.max(a) - np.min(a)
        print("Int range = {}".format(int_range))
        if int_range:
            r  = (a - np.min(a)) / int_range
            print(np.max(r) - np.min(r))
            z_norm = 254 - 8*((31*r).astype(int))
        else:
            z_norm = a

        # Z is the blue channel in a RGB image
        stacked_img = np.stack((z_norm,)*3, axis=-1)

        # Draw graphics in white, over the zbuffer picture
        # s = np.argwhere( self.pixels > 0)
        # stacked_img[s[:,0], s[:,1], :] = 255

        stacked_img[:,:,0] = self.pixels
        #stacked_img[:,:,1] = 0
        stacked_img[:,:,2] = self.pixels

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

def bits_to_color_hgr2( b):

    bytes = []

    while b:
        msb = lsb = 0

        if len(b) <= 3:
            for i in range( len( b)):
                msb += b[i] << (2*i)
            bytes.append(msb)
            break

        p = b[3]

        if len(b) >= 4:
            msb += b[0] << 0     # AA
            msb += b[1] << 2   # BB
            msb += b[2] << 4   # CC
            msb += (p & 1) << 6
            lsb += ((p & 2) >> 1)

        if len(b) >= 5:
            for i in range( min(7, len(b)) - 5 +1):
                lsb += b[4+i] << (2*i+1)

        bytes.extend([msb, lsb])

        if len(b) > 7:
            b = b[7:]
        else:
            break

        # if len(b) >= 7:
        #     msb = 0
        #     msb += b[0] << 0     # AA
        #     msb += b[1] << 2   # BB
        #     msb += b[2] << 4   # CC

        #     lsb = 0
        #     p = b[3]
        #     msb += (p & 1) << 6

        #     lsb += ((p & 2) >> 1)
        #     lsb += b[4] << 1
        #     lsb += b[5] << 3
        #     lsb += b[6] << 5

        #     bytes.append(msb)
        #     bytes.append(lsb)
        #     b = b[7:]

        # elif len(b) >= 3:
        #     msb = 0
        #     msb += b[0] << 0     # AA
        #     msb += b[1] << 2   # BB
        #     msb += b[2] << 4   # CC
        #     bytes.append(msb)
        #     b = b[3:]

        # else:

    return bytes


def bits_to_color_hgr( b):
    """ b = [ left most pixel, ..., right most pixel]
    returns msb, lsb : in HGR : mem[x] = msb and mem[x+1] = lsb
    or returns msb, None
    """
    assert len(b) == 7 or len(b) == 3
    for x in b:
        assert 0 <= x <= 3

    msb = 0
    msb += b[0] << 0     # AA
    msb += b[1] << 2   # BB
    msb += b[2] << 4   # CC

    if len(b) == 3:
        return msb, None

    lsb = 0
    p = b[3]
    msb += (p & 1) << 6

    lsb += ((p & 2) >> 1)
    lsb += b[4] << 1
    lsb += b[5] << 3
    lsb += b[6] << 5

    return msb, lsb


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
    #assert page == 0x2000 or page == 0x4000, "I'll work only for legal pages"
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
    elif format == 1:
        return "${:X}".format( page + ofs + 0x80*i + 0x400*j)
    else:
        return page + ofs + 0x80*i + 0x400*j

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
        fo.write("{}:".format(label))

    if len(a) > 3:
        fo.write("\t; {} values\n".format(len(a)))

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

    a,b,c = Vertex(0,-1,0), Vertex(-1,0,0), Vertex(+1,0,0)
    f = Face( a,b,c)
    f.xformed_vertices =  [a,b,c]
    assert f.topmost_point() == (a,0), "{}".format(f.topmost_point()[0])
    assert f.compute_z_slope_along_x() == 0

    a,b,c = Vertex(0,-1,0), Vertex(-1,0,2), Vertex(+1,0,0)
    f = Face( a,b,c)
    f.xformed_vertices =  [a,b,c]
    assert f.topmost_point() == (a,0), "{}".format(f.topmost_point()[0])
    assert f.compute_z_slope_along_x() == -1, "slope = {}".format(f.compute_z_slope_along_x())

    print( [s for s in map( str, special_points([Vertex(0,-1,0), Vertex(-1,0,2), Vertex(+1,0,0)]))])
    print( [s for s in map( str, special_points([Vertex(-1,0,2), Vertex(0,-1,0),  Vertex(+1,0,0)]))])

    print( ".".join( [ "{:08b}".format(s) for s in bits_to_color_hgr2( [1,3,3,3,3,3,2] )]))
    print( ".".join( [ "{:08b}".format(s) for s in bits_to_color_hgr2( [1,3,3,3,3,3,2]*2 )]))
