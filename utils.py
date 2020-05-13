import math
import colorama

APPLE_YRES = 64*3 # 192
APPLE_XRES = 40*7 # 280
APPLE_HGR_PIXELS_PER_BYTE = 7

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
