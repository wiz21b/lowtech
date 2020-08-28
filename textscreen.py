TEST = """dear tester,

First of all thank you for accepting
to help me. It makes a difference.

the goal of the test is to validate
that it's possible to play some music
while reading the disk. So a _Disk ][_
and a _mockingboard_ are mandatory.

i'm mostly interested in a video
showing the program running, where
I can read the screen and, if possible
hear the sound.

you'll be presented with various
screens. You can go from one to the
next simply by hitting a key.

the most important test is the
"advanced irq + disk read replay".

        ,
Thx ! stephane    schampailler@skynet.be"""

OFFSETS = [ 0x400,0x480,0x500,0x580,0x600,0x680,0x700,0x780,
            0x428,0x4A8,0x528,0x5A8,0x628,0x6A8,0x728,0x7A8,
            0x450,0x4D0,0x550,0x5D0,0x650,0x6D0,0x750,0x7D0 ]

mem = bytearray( 0x400 )

for y, line in enumerate(TEST.split('\n')):


    start, end = None, None
    for i, c in enumerate(line):
        if c == '_':
            if start is None:
                start = i
            else:
                end = i - 1
                break

    line = line.replace('_','').ljust(40).upper()
    #line = f"{line:<40s}".upper()
    #print(f"{y+1:2d}|{line}|")


    bline = bytearray(line.encode("ASCII"))
    for i in range( len( bline)):
        bline[i] += 0x80

    if start and end:
        for i in range( start, end):
            if bline[i] >= 0xC0:
                bline[i] -= 0xC0
            else:
                bline[i] -= 0x80

    ofs = OFFSETS[y] - 0x400

    mem[ofs:ofs+len(line)] = bline


with open("build/introtext.bin","wb") as fout:
    fout.write( mem)
