from py65emu.cpu import CPU
from py65emu.mmu import MMU
from utils import array_to_asm, array_to_hilo_asm


def set_apple( page8):
    # define your blocks of memory.  Each tuple is
    # (start_address, length, readOnly=True, value=None, valueOffset=0)
    mmu = MMU([
        (0x00, 0x200), # Create RAM with 512 bytes
        (0x0800, len(f), True, f) # Create ROM starting at 0x1000 with your program.
    ])

    # Create the CPU with the MMU and the starting program counter
    # address You can also optionally pass in a value for stack_page,
    # which defaults to 1, meaning the stack will be from 0x100-0x1ff.
    # As far as I know this is true for all 6502s, but for instance in
    # the 6507 used by the Atari 2600 it is in the zero page,
    # stack_page=0.
    c = CPU(mmu, 0x800)

    return c, mmu


def test_div_tables():

    Y_MAX = 256

    good = 0
    errors = 0

    # FIXME This table is basically X :-)
    x_table = [int( round( 256 * x / Y_MAX)) for x in range(256)]

    # This table is basically 65536 / y
    y_table = [0] + [min( 0xFFFF, int( round( 256 * Y_MAX / y))) for y in range(1,256)]


    print("hello")
    with open("build/divtbl.s","w") as fo:
        #array_to_asm( fo, y_table, ".word")
        array_to_hilo_asm( fo, y_table, "one_over_x")


    for y in range(1,256):
        for x in range(1,y):

            s = int(256*7*x/y)

            # This can be precomputed in two tables
            # totalling 768 bytes.

            # Proper rounding improves things. Thanks to that,
            # I can use the slighlty less accurate version of the
            # multiplication by tile size later on.

            a = int( round( 256 * x / Y_MAX)) # a in 0-256 => 8 bits
            b = int( round( 256 * Y_MAX / y)) # b in 256..256*Y_MAX = 16 bits
            a = x_table[x]
            b = y_table[y]

            assert 0 <= a < 256, "a is not 8 bits"
            assert 256 <= b < 65536, "b is not 16 bits"

            # I compute a (8 bits, = x) * b (16 bits, = 1/y)

            # I just need the top 16 bits of a 24 bits result
            # So I may leave the multiplication early.

            # These are 2 8 bits multiply (8x8 bits to 16 bits) :
            # a * b = a*(b_hi + b_lo) = a*b_hi + a*b_lo
            mul_a_b = (a * (b >> 8))*256 + (a * (b & 0xFF))
            assert mul_a_b == a*b

            # Slightly less accurate than (mul_a_b * 7) >> 8, but avoids
            # to handle least signifcant byte during multplictaion.
            p = (mul_a_b >> 8) * 7

            # Pixel off after repeating the tiles y // 7 times
            # the rouding is pessimistic
            error = int( abs(s*(y//7) - p*(y//7))/256 + 0.5)

            good += 1
            if error > 1:
                print("256*7*{}/{}={} ~ {}*{}={} - err:{:.3f}".format(x,y,s,a,b,p,error))
                errors += 1

    print(f"Good {good}, errors {errors}")




def test_asm_div():
    f = open("div.o", "rb").read()  # Open your rom
    for divisor in range( 1,192,19):
        for dividend in range( 0,7*270,7*13):

            c, mmu = set_apple( f)

            # divisor = i
            # dividend = 1000

            mmu.writeWord(0xfb,dividend) # dividende
            mmu.writeWord(0x58,divisor) # divisor

            # Do this to execute one instruction

            while c.r.pc != 0x825:
                c.step()

            # You can check the registers and memory values to determine what has changed
            # print(f"A=${c.r.a:02X} X=${c.r.x:02X} Y=${c.r.y:02X} PC=${c.r.pc:04X} S=${c.r.s:04X}")     # A register
            # print( c.r.getFlag('C')) # Get the value of a flag from the flag register.

            """
            org  : x = 2 bytes, y = 1 byte
            dest : x = 2 bytes, y = 1 byte => total 6 bytes

            org  : x = 2 bytes(7 bits free), y = 1 byte
            delta: x = 1 bytes, y = 1 byte => total 5 bytes
            => 2 bits for dx and dy signs; 1 bit for div rounding.
               4 bits for command


            nb points where x < 256
            points : X=1 byte, y=1 byte
            nb points where x > 256
            points : X=1 byte, y=1 byte

            nb edges
            edge : origin, dest

            If 4 connected edges => 5 points:

            counters = 3 bytes
            5 x 2 bytes = 10 bytes
            4 x 2 bytes = 8 bytes
            total : 3+10+8 = 21 bytes
            right now : 6*4 = 24 bytes
            """
            expected = dividend / divisor
            print( "{}/{}={} ~ {:.1f} r:{}| {} cycles".format( dividend, divisor, mmu.readWord(0xfb),  expected, mmu.readWord(0xfd), c.cc)) # Read a value from memory


def test_multiplication():

    f = open("div.o", "rb").read()  # Open your rom
    for m1 in range(0,255,13):
        for m2 in range(0,255,17):
            c, mmu = set_apple( f)
            mmu.write( 0x80, m1)
            mmu.write( 0x81, m2)

            while c.r.pc != 0x803:
                #print(f"{c.r.pc:X}")
                c.step()

            print( "{}*{}={} ({}) {}:{}| {} cycles".format( m1, m2, m1*m2, c.r.a*256+mmu.read( 0x80), c.r.a, mmu.read( 0x80),  c.cc))

            assert m1*m2 == c.r.a*256+mmu.read( 0x80)



test_div_tables()


for n in range(0,256):
    for d in range( n+1,256):
        tbl = int(65536/d)
        t = n*(tbl>>8)*256 + n*(tbl & 0xFF)
        #t = int (65536*n/d)
        if t > 65530:
            print("{}/{}= 65536/d = {}, {}".format( n,d,int(65536/d), t ))
