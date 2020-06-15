import re
import math
import colorama
import numpy as np
import pygame
from PIL import Image, ImageFilter, ImageFont, ImageDraw


APPLE_YRES = 64*3 # 192
APPLE_XRES = 40*7 # 280
APPLE_HGR_PIXELS_PER_BYTE = 7
TRACKS_PER_DISK = 35
SECTORS_PER_TRACK = 16
DISK_SIZE = TRACKS_PER_DISK*SECTORS_PER_TRACK*256

def np_append_row( a, v = 0):
    return np.append( a, [ [v] * a.shape[1] ], axis=0)


fsbt_sectors_read_order = [  (1,2),  (1,4),  (1,6),  (1,8),  (1,10), (1,12), (1,14),
                             (1,1),  (1,3),  (1,5),  (1,7),   (1,9), (1,11), (1,13), (1,15),
                             (2,0),  (2,2),  (2,4),  (2,6),  (2,8),  (2,10), (2,12), (2,14),
                             (2,1),  (2,3),  (2,5),  (2,7),   (2,9), (2,11), (2,13), (2,15) ]


def configure_boot_code( fout, loader_size, page_base):

    pages = (loader_size + 255) // 256
    assert 0 < pages <= 15+16, f"FSTBT.S supports up to 31 sectors, no more. You asked {pages} pages"
    page_map = [0] * len(fsbt_sectors_read_order)

    for page in range( pages):
        if page <= 14:
            # First sector is the boot sector
            track,sector = 1, 1 + page
        else:
            track,sector = 2, page - 15

        for i,disk_pos in enumerate(fsbt_sectors_read_order):
            if (track, sector) == disk_pos:
                page_map[ i] = page + page_base
                break

    i = len(page_map)
    while not page_map[i-1]:
        i -= 1

    page_map = page_map[0:i]

    # for i,disk_pos in enumerate(fsbt_sectors_read_order):
    #     if i < len(page_map):
    #         print( "{:0X}\t{}".format( page_map[i], disk_pos))
    #     else:
    #         print( "--\t{}".format( disk_pos))


    fout.write("!byte {}\n".format(
        ",".join(
            [ f"${p:X}" for p in page_map] )))
    fout.write("!byte $C0\n")


class AppleDisk:
    DOS_SECTORS_MAP = [0x0, 0x7, 0xe, 0x6, 0xd, 0x5, 0xc, 0x4,
                       0xb, 0x3, 0xa, 0x2, 0x9, 0x1, 0x8, 0xf]

    def __init__( self, filename = None):
        self.filename = filename

        self.set_track_sector( 0,0)

        self.toc = 0

        self.sector_map = [   [0] * SECTORS_PER_TRACK for i in range(TRACKS_PER_DISK)]
        self.nb_writes = 0

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


    def set_track_sector( self, track, sector):
        self._track, self._sector = track, sector

    def write_data( self, data, load_page):
        assert data


        first_sector = self._track, self._sector
        sectors_written = 0
        data = bytearray(data)

        #print( "Writing {} bytes from T:{} S:{}".format(len(data), self._track, self._sector))

        for offset in range( 0, len(data), 256 ):

            if len(data) - offset  >=  256:
                s = data[offset:offset+256]
            else:
                s = data[offset:len(data)]
                s.extend( [0] * (256 - len(s)))

            assert len(s) == 256
            #print(f"Writing  {self._track}/{self._sector}, offset {offset:x}")
            last_sector = self._track, self._sector
            self.set_sector( self._track, self._sector, bytearray(s))
            sectors_written += 1

            self.sector_map[self._track][self._sector] = 1 + self.nb_writes

            #if len(data) - offset > 256:
            if self._sector < 15:
                self._sector += 1
            else:
                self._sector = 0
                self._track += 1

        # self.toc.append( (first_sector[0],first_sector[1],
        #                   last_sector[0],last_sector[1],
        #                   load_page, label) )

        #print("init_track_read {},{},{},{},${:x}\t; {} bytes, {} pages".format( first_sector[0],first_sector[1],last_sector[0],last_sector[1], load_page, len(data), (len(data) + 255)//256))
        #print(f"{sectors_written} sectors written")
        self.nb_writes += 1

        return (first_sector[0],first_sector[1],
                last_sector[0],last_sector[1],
                load_page)

    def save(self):
        assert self.filename

        with open( self.filename,"wb") as fout:
            fout.write( self._disk)

        for s in range( SECTORS_PER_TRACK):
            all_sect = [self.sector_map[t][s] for t in range(TRACKS_PER_DISK)]
            print("".join([ ".ABCDEFGHIJKLMNOPQRSTUVWXYZ"[s] for s in all_sect  ]))



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


def bool_array_to_stripes( d):
    # d is an array of booleans
    # d == True belongs to stripe, d == False doesn't.

    # in_stripe = ( first_index, last_index )

    in_stripe = None
    stripes = []

    for i in range(len(d)):
        if d[i] and in_stripe:
            # Extend stripe
            in_stripe = (in_stripe[0], i)
        elif d[i] and not in_stripe:
            # Begin new stripe
            in_stripe = (i,i)
        elif not d[i] and in_stripe:
            stripes.append( in_stripe)
            in_stripe = None
        elif not d[i] and not in_stripe:
            pass

    if in_stripe:
        stripes.append( in_stripe)

    return stripes


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


def image_to_hgr( image):
    """ image : a Pillow image
    """
    im = image.convert( mode="1").convert( mode="L")

    width, height = im.size

    hgr = bytearray( 8192)

    for y in range(height):
        row = np.array(im)[y,:]

        # for x in range(40):
        #     hgr_line.append( 0x80 + bits_to_hgr( (np.packbits( row[x*7:(x+1)*7])[0] >> 1)))

        def merge_pixel( a,b):
            if a and b:
                return 3 # white
            elif a == 0 and b == 0:
                return 0 # black
            else:
                return 1 # blue

        def merge(a):
            r = int( 4*a/256 + 0.5)
            return [(0,0),(1,0),(1,1),(3,1),(3,3)][r]

        # 7 pixels becomes 3

        ofs = 0
        px = row
        hgr_line = []
        hgr_line2 = []

        while ofs < len(px) - 7:

            msb = 0
            lsb = 0

            msb += merge_pixel( px[ofs],    px[ofs+1]) << 0     # AA
            msb += merge_pixel( px[ofs+2],  px[ofs+2+1]) << 2   # BB
            msb += merge_pixel( px[ofs+4],  px[ofs+4+1]) << 4   # CC

            p = merge_pixel( px[ofs+6],  px[ofs+6+1])
            msb += (p & 1) << 6

            lsb += ((p & 2) >> 1)
            lsb += merge_pixel( px[ofs+8],  px[ofs+8+1]) << 1
            lsb += merge_pixel( px[ofs+10],  px[ofs+10+1]) << 3
            lsb += merge_pixel( px[ofs+12], px[ofs+12+1]) << 5

            hgr_line.append( 0x80 | msb)
            hgr_line.append( 0x80 | lsb)
            hgr_line2.append( 0x80 | msb)
            hgr_line2.append( 0x80 | lsb)

            ofs += 14


        assert len(hgr_line) == 40, "{}".format(len(hgr_line))

        # for x in range(20):
        #     px = row[x*7:(x+1)*7]
        #     b = 0
        #     for i in range(3):
        #         b += merge_pixel( px[i*2], px[i*2+1]) << ((2 - i)*2)

        #     hgr_line.append( 0x80 | (bits_to_hgr(b) << (x%2)))





        ofs = hgr_address( y, 0, format=2)
        hgr[ ofs : ofs + 40] = hgr_line

    return hgr

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



def append_images(images, direction='horizontal',
                  bg_color=(255,255,255), aligment='center'):
    """
    Appends images in horizontal/vertical direction.

    Args:
        images: List of PIL images
        direction: direction of concatenation, 'horizontal' or 'vertical'
        bg_color: Background color (default: white)
        aligment: alignment mode if images need padding;
           'left', 'right', 'top', 'bottom', or 'center'

    Returns:
        Concatenated image as a new PIL image object.
    """
    widths, heights = zip(*(i.size for i in images))

    if direction=='horizontal':
        new_width = sum(widths)
        new_height = max(heights)
    else:
        new_width = max(widths)
        new_height = sum(heights)

    new_im = Image.new('RGB', (new_width, new_height), color=bg_color)


    offset = 0
    for im in images:
        if direction=='horizontal':
            y = 0
            if aligment == 'center':
                y = int((new_height - im.size[1])/2)
            elif aligment == 'bottom':
                y = new_height - im.size[1]
            new_im.paste(im, (offset, y))
            offset += im.size[0]
        else:
            x = 0
            if aligment == 'center':
                x = int((new_width - im.size[0])/2)
            elif aligment == 'right':
                x = new_width - im.size[0]
            new_im.paste(im, (x, offset))
            offset += im.size[1]

    return new_im


def generate_font_data( fout, prefix, new_blocs, alphabet, nb_ROLs=4):

    hgr_blocks = []

    # To send these pixels (2 bits per pixel) on the screen ABCDEFGH

    # Byte 2*n Byte 2*n+1
                        # 76543210 76543210
                        # -------- --------
                        # For letter starting on pair byte, we need 4 ROL :
                        # xDCCBBAA xGGFFEED
                        # xCBBAA.. xFFEEDDC
                        # xBAA.... xEEDDCCB
                        # xA...... xDDCCBBA

    # For letter starting on odd byte, we need 3 ROL :
                        # -------- xCCBBAA. x.FFEEDD x........
                        # -------- xBBAA... xFEEDDCC x.......F
                        # -------- xAA..... xEDDCCBB x.....FFE

    # So, if we draw on odd byte we take data of even bytes and ROL
                        # each of them once (and transferring the 7th (not 8th!) bit to
                        # the first bit of the next byte)

    # x-pos  : 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14
                        # offset : 0,0,0,0,1,1,1,2,2,2, 2, 3, 3, 3, 3

    for rol in range( nb_ROLs):

        labels = []
        for i,b in enumerate(new_blocs):

            data = []
            for row in b:
                # All rows have same length

                # From 255 to 3 (white in HGR)
                row_a2 = [z & 3 for z in row]

                # print( len( row_a2))
                # if len( row_a2) in (3,5,10):

                # Append a blank column to the left. That's for
                # spacing but also to make sure that "half bits" don't
                # exist (FIXME shouldn't we add that only when the
                # width of the letter is 3 color-pixels ?)
                row_a2.append( 0 )


                if rol:
                    row_a2 = ([0] * rol) + row_a2

                bytes_a2 = bits_to_color_hgr2( row_a2)

                if not data:
                    data = [ len(bytes_a2), len(row) + 1 ]
                data.extend( bytes_a2)


            letter = alphabet[i]
            if letter == "-":
                letter = "MINUS"
            elif letter == ".":
                letter = "DOT"
            elif letter == ",":
                letter = "COMA"
            elif letter == "!":
                letter = "EXCLAM"

            label = "letter_{}_{}_{}".format( prefix, letter, rol)
            labels.append( label)
            array_to_asm( fout, data, ".byte", label)

        make_lo_hi_ptr_table( fout, f"{prefix}_letter_ptrs_rol{rol}", labels)


def message_to_font( fout, prefix, message, alphabet):
    text = []

    for line in message:
        for c in line:
            if c == " ":
                text.append(253)
            else:
                text.append( alphabet.index(c))
        text.append(254) # end string
    text.append(255) # end text

    array_to_asm( fout, text, ".byte", f"{prefix}the_message")


def font_split( filename_or_image, mod_width = None):

    """ expecting a black on white font sheet
    the pixels of the fonts are expected to be
    exact squares.

    all letters' widths will be adjusted so that
    with % mod_width = 0

    """

    if type(filename_or_image) == str:
        im = Image.open( filename_or_image)
    else:
        im = filename_or_image

    # Make it white on black
    im = im.point(lambda p: p < 128 and 255)

    im = im.convert( mode="L")
    width, height = im.size

    # im = im.resize( (width // 7, height // 7) )
    # width, height = im.size

    t = 0 # height*255
    print(f"{width}, {height}, {t}")
    ar = np.array(im)

    # Now we autodetect the pixel widths.

    vstripes = bool_array_to_stripes( [np.sum( ar[y,:] ) != t for y in range(height)])
    hstripes = bool_array_to_stripes( [np.sum( ar[:,x] ) != t for x in range(width)])

    # print("-"*80)
    # print( vstripes)
    # print( hstripes)

    pixel_widths = dict()

    all_blocs = []

    for vstripe in vstripes:

        # ar [vstripe[0]-1, :] = 128
        # ar [vstripe[1]+1, :] = 128

        row = ar[ vstripe[0]:vstripe[1]+1, : ]

        #hstripes = bool_array_to_stripes( [np.sum( row[:,x] ) != t for x in range(width)])
        print( "For v-stripe {}, we have {} h-stripes".format( vstripe, len(hstripes)))

        for hstripe in hstripes:
            # ar [vstripe[0]-1:vstripe[1]+1, hstripe[0]] = 128
            # ar [vstripe[0]-1:vstripe[1]+1, hstripe[1]] = 128

            bloc = ar[ vstripe[0]:vstripe[1]+1, hstripe[0]:hstripe[1]+1 ].copy()

            # with np.printoptions(threshold=np.inf):
            #     print(bloc)

            if np.sum(bloc) == 0:
                # We skip empty blocks
                print("Skipped a block !")
                continue

            # "strip" the block horizontally
            while np.sum( bloc[:,0]) == 0:
                bloc = bloc[:,1:]

            while np.sum( bloc[:,-1]) == 0:
                bloc = bloc[:,0:-1]

            all_blocs.append( bloc)

            # Analyse columns
            for bx in range( bloc.shape[1]):
                widths =  [ s[1]-s[0]+1 for s in bool_array_to_stripes( bloc[:,bx] )]

                for w in widths:
                    if w not in pixel_widths:
                        pixel_widths[w] = 1
                    else:
                        pixel_widths[w] += 1


            for by in range( vstripe[1] - vstripe[0] + 1):
                widths =  [ s[1]-s[0]+1 for s in bool_array_to_stripes( bloc[by,:] )]

                for w in widths:
                    if w not in pixel_widths:
                        pixel_widths[w] = 1
                    else:
                        pixel_widths[w] += 1

            #print(s)

    # Image.fromarray(ar).show()
    # zzz = []
    # for b in all_blocs:
    #     zzz.append(Image.fromarray(b).convert( mode="RGB"))
    #     zzz.append(Image.fromarray( np.ones( (100,2) )*128).convert( mode="RGB"))
    # append_images( zzz).show()

    for pw,cnt in reversed(sorted( pixel_widths.items(), key=lambda t:t[1])):
        print( f"width:{pw}\tcnt:{cnt}")

    l = list( sorted( pixel_widths.items(), key=lambda t:t[0]))
    for i in range( len( l)):
        if abs(l[i][0] - l[i-1][0]) < 2:
            l[i] = ( l[i][0], l[i][1] +  l[i-1][1])
            l[i-1] = None
    l = list(filter(lambda f:f is not None, l))

    pixel_width = l[0][0]
    #pixel_width = next(reversed(sorted( pixel_widths.items(), key=lambda t:t[1])))[0]
    print(f"Best pixel size is {pixel_width}")

    new_blocs = []

    for ndx, bloc in enumerate( all_blocs):

        h,w = bloc.shape

        nh,nw = (h+(pixel_width//2))//pixel_width, (w+(pixel_width//2))//pixel_width

        if mod_width and  nw % mod_width > 0:
            # -1 compensate for the add one zero later on
            # in HGR data generator
            adjusted_width = ((nw // mod_width)  + 1) * mod_width - 1
        else:
            adjusted_width = nw

        new_bloc = np.zeros( ( nh, adjusted_width), dtype=np.uint8 )

        print(f"Block #{ndx} {h}x{w} with pixel size is {pixel_width} ->  {new_bloc.shape[1]}x{nh} pixels character")
        for x in range( nw): # pixel_width//2, w - pixel_width//2 + 1, pixel_width):
            for y in range( nh): #pixel_width//2, h - pixel_width//2 + 1, pixel_width):
                #print( bloc[x][y])
                new_bloc[ y][x ] = bloc[ y*pixel_width + (pixel_width//2)][x*pixel_width + (pixel_width//2)]

        new_blocs.append(new_bloc)
        # if np.sum(new_bloc) > 0:
        #     new_blocs.append(new_bloc)
        # else:
        #     print("!"*100)

        #print( new_bloc)

    im.close()
    return new_blocs


def make_bitmap_font( font_path, alphabet, mod_width=None, base_size=64):

    # Take a base_size big enough to avoid rounding error
    # in Pillow's font rendering

    font = ImageFont.truetype(font_path, base_size)
    (width, baseline), (offset_x, offset_y) = font.font.getsize(alphabet)

    ascent, descent = font.getmetrics()

    print(f"{ascent}, {descent}")
    image = Image.new('L', ( width, ascent + descent), color = 255)
    draw = ImageDraw.Draw(image)

    draw.text((0, 0), alphabet, font=font, color=0)
    #image.show()

    return font_split(image, mod_width)


def show_bitmap_font( blocks):
    height = max( [ b.shape[0] for b in blocks ])

    zzz = []
    for b in blocks:
        zzz.append( Image.fromarray(b).convert( mode="1"))
        #zzz.append( Image.new('1', (2,height), color=0))

    #zzz = [ Image.new('L', (8,height)) ] + zzz + [ Image.new('L', (8,height)) ]

    im = append_images( zzz)
    im = im.resize( (im.size[0]*4,im.size[1]*2 ))

    s = im.size
    im2 = Image.new( "1", ( s[0]+10, s[1]+10))
    im2.paste( im, (5,5) )
    im2.show()



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
