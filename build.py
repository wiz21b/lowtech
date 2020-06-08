"""
White-white
White-blue
blue-blue
blue-black
black

Big scroll fonts :

https://www.dafont.com/cyberspace-raceway.font?text=LOW+TECH&psize=l&back=theme

https://www.dafont.com/scifi-adventure.font?text=LOW+TECH

https://www.dafont.com/electric-toaster.font?text=LOW+TECH

https://www.dafont.com/alien-android.font?text=LOW+TECH

"""
import sys
import numpy as np
from PIL import Image, ImageFilter
from utils import *

from bigscroll.make_logo import make_all


# Alphabeta here : https://fontmeme.com/pixel-fonts/
# https://fontmeme.com/fonts/little-conquest-font/

new_blocs = font_split("data/Alphabeta 7 pixels font.png")

def np_append_row( a, v = 0):
    return np.append( a, [ [v] * a.shape[1] ], axis=0)

# Fix some letters
for i in range(26):
    new_blocs[i] = np_append_row( new_blocs[i])

new_blocs = new_blocs[0:26+26+10]

letter_9 = 26+26+10-1
for i in range(3):
    new_blocs[letter_9] = np.delete( new_blocs[letter_9], 0, axis=0)
new_blocs[letter_9] = np.delete( new_blocs[letter_9], len(new_blocs[letter_9])-1, axis=0)


max_height = max( [ b.shape[0] for b in new_blocs] )
for i in range( len( new_blocs)):
    b = new_blocs[i]
    if b.shape[0] < max_height:
        for j in range(max_height - b.shape[0]):
            new_blocs[i] = np_append_row( new_blocs[i])

hgr_blocks = []
with open("data/alphabet.s","w") as fout:

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



    for rol in range(4):
        labels = []
        for i,b in enumerate(new_blocs):


            data = []

            for row in b:
                # All rows have same length

                # From 255 to 3 (white in HGR)
                row_a2 = [z & 3 for z in row]

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


            label = "letter_{}_{}".format("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"[i], rol)
            labels.append( label)
            array_to_asm( fout, data, ".byte", label)

        make_lo_hi_ptr_table( fout, f"letter_ptrs_rol{rol}", labels)

        text = []
        #           ##################
        MESSAGE = ["This demo was",
                   "written by Wiz of",
                   "Imphobia in 2020",
                   "",
                   "Keeping the spirit",
                   "alive",
                   "",
                   "Greetings go to",
                   "",
                   "   Imphobia",
                   "   Peter Ferrie",
                   "   Deater",
                   "   Fennarinarsa",
                   "",
                   "",
                   "Additional Credits",
                   "",
                   "PT3 player",
                   "   Vince Weaver",
                   "",
                   "RWTS",
                   "   Peter Ferrie",
                   "",
                   "Font",
                   "   Little Conquest",
                   "   by Brixdee",
                   "",
                   "Iceberg",
                   "   iStock free",
                   "",
                   "",
                   "",
                   "",
                   "",
                   "",
        ]

        for line in MESSAGE:
            for c in line:
                if c == " ":
                    text.append(253)
                else:
                    text.append( "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789".index(c))
            text.append(254) # end string
        text.append(255) # end text

    array_to_asm( fout, text, ".byte", "the_message")

#         a = row
#         if shape
#         bits_to_color_hgr( row)



#append_images( [Image.fromarray(b).convert( mode="RGB") for b in new_blocs]).show()

# im = im.filter(ImageFilter.FIND_EDGES)
# im.show()
#Image.fromarray(ar).show()
#exit()

im = Image.open("data/black_ice2.bmp")
im = im.resize( (APPLE_XRES,APPLE_YRES) )
# https://pillow.readthedocs.io/en/stable/handbook/concepts.html#modes

# add some black horizontal lines for underwater part of the iceberg
ar = np.array(im)
for i in range( 85, APPLE_YRES, 2):
    ar[i,:] = 0
im = Image.fromarray(ar)

im = im.convert( mode="1").convert( mode="L")

#im = im.resize( (APPLE_XRES//2,APPLE_YRES) ).convert( mode="L")


width, height = im.size

# px = im.load()
# for x in range(width):
#     px[x, 100] = 255

hgr = bytearray( 8192)
hgr2 = bytearray( 8192)

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

        bmsb=0
        blsb=0

        # t,b = merge(px[ofs])
        # msb += t << 0
        # bmsb += b << 0

        # t,b = merge(px[ofs+1])
        # msb += t << 2
        # bmsb += b << 2

        # t,b = merge(px[ofs+2])
        # msb += t << 4
        # bmsb += b << 4

        # t,b = merge( px[ofs+3])
        # msb += (t & 1) << 6
        # lsb += ((t & 2) >> 1)
        # bmsb += (b & 1) << 6
        # blsb += ((b & 2) >> 1)

        # t,b = merge(px[ofs+4])
        # lsb += t << 1
        # blsb += b << 1

        # t,b = merge(px[ofs+5])
        # lsb += t << 3
        # blsb += b << 3

        # t,b = merge(px[ofs+6])
        # lsb += t << 5
        # blsb += b << 5

        # hgr_line.append( 0x80 | msb)
        # hgr_line.append( 0x80 | lsb)
        # hgr_line2.append( 0x80 | bmsb)
        # hgr_line2.append( 0x80 | blsb)

        # ofs += 7

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
    hgr2[ ofs : ofs + 40] = hgr_line2
    print( hgr_address( y, 0, format=2))
    print(hgr_line)

print(np.array(im)[90,:])

# https://www.istockphoto.com/be/vectoriel/iceberg-main-illustration-dessin%C3%A9e-convertie-au-vecteur-gm1038069650-277863881
# libre de droit
with open("data/TITLEPIC.BIN","wb") as f_out:
    print( len( hgr))
    f_out.write( hgr)
    # hgr2[0] = 255
    # f_out.write( hgr2)

#im.show()
im.close()



def gen_code_vertical_scroll():


    with open("data/vscroll.s","w") as fo:
        code = ";; Generated code "
        for y in range(0,APPLE_YRES-2):

            line_base = hgr_address((y+2)% APPLE_YRES)
            line_base2 = hgr_address(y)

            code += f"""
        LDA {line_base},x
        STA {line_base2},x
"""
        code += "RTS"
        fo.write( code)

    with open("data/vscroll2.s","w") as fo:
        code = ";; Generated code "

        for y in range(0,APPLE_YRES-2):

            line_base  = hgr_address( (y+2) % APPLE_YRES, page=0x4000)
            line_base2 = hgr_address( y, page=0x4000)

            code += f"""
        LDA {line_base},x
        STA {line_base2},x
"""
        code += "RTS"
        fo.write( code)

    with open("data/vscroll3.s","w") as fo:
        code = ";; Generated code "
        for y in range(0,APPLE_YRES):

            line_base = hgr_address((y+1)% APPLE_YRES)
            line_base2 = hgr_address(y)

            code += f"""
        LDA {line_base},x
        STA {line_base2},x
"""
        code += "RTS"
        fo.write( code)

#exit()


import re
import argparse
import subprocess
import os
import shutil
import os.path
import platform
from utils import AppleDisk

memory_maps = dict()
segments = dict()


def memory_map():
    print("\nMEMORY MAP")
    print("----------")

    with open("link.cfg") as mo:
        LD65_MEMORY_MAP_RE = re.compile(r"\s*(\S+):.*start *= *\$([0-9A-F]+), *size *= *\$([0-9A-F]+)")
        LD65_SEGMENT_MAP_RE = re.compile(r"\s*(\S+):.*load *= *([A-Za-z0-9_]+)")

        for line in mo.readlines()[3:]:
            line = line.strip()
            match = LD65_MEMORY_MAP_RE.match(line)
            if match:
                seg_name, seg_size = match.groups()[0], int(match.groups()[2],16)
                mfrom = int(match.groups()[1],16)
                mto = mfrom + seg_size - 1
                print(f"Memory {seg_name:<12s} : {seg_size:5d} bytes (from:{mfrom:0{4}x} to: {mto:0{4}x})")
                memory_maps[seg_name] = seg_size


            match = LD65_SEGMENT_MAP_RE.match(line)
            if match:
                seg_name, mem_name = match.groups()[0], match.groups()[1]
                # print(f"Segment: {seg_name} -> memory: {mem_name}")

                segments[seg_name] = memory_maps[mem_name]


    with open("build/map.out") as mo:
        CC65_SEGMENT_MAP_RE = re.compile(r"\s*(\S+).*Size=([0-9A-F]+)")
        for line in mo.readlines()[3:]:
            line = line.strip()
            match = CC65_SEGMENT_MAP_RE.match(line)
            if match:
                seg_name, seg_size = match.groups()[0], int(match.groups()[1],16)
                seg_max_size = segments[seg_name]


                left = seg_max_size - seg_size
                print(f"{seg_name:<12s}\t{seg_size:5d}/{seg_max_size:5d} bytes ({left:5d} left)")

    print()


def run(cmd, stdin=None):
    print(cmd)
    r = subprocess.run(cmd, shell=True, stdin=stdin)
    r.check_returncode()
    return r

if platform.system() == "Windows":
    CA65 = r"\PORT-STC\opt\cc65\bin\ca65"
    LD65 = r"\PORT-STC\opt\cc65\bin\ld65"
    ACMDER = r"java -jar ..\bad_apple\AppleCommander-1.3.5.13-ac.jar"
    ACME = r"\PORT-STC\opt\acme\acme"
    APPLEWIN=r"\PORT-STC\opt\applewin\Applewin.exe"
    MAME = r"c:\port-stc\opt\mame\mame64"

elif platform.system() == "Linux":
    CA65 = r"ca65"
    LD65 = r"ld65"
    ACMDER = r"java -jar ../bad_apple/AppleCommander-1.3.5.13-ac.jar"
    ACME = r"acme"
    APPLEWIN=r"/opt/wine-staging/bin/wine /home/stefan/AppleWin1.29.10.0/Applewin.exe"
    MAME = "mame"
else:
    raise Exception("Unsupported system : {}".format(platform.system()))


BUILD_DIR = "build"
DATA_DIR = "data"
BUILD_DIR_ABSOLUTE = os.path.join( os.path.dirname(os.path.abspath(__file__)), BUILD_DIR)
TUNE = "data/FR.PT3"

parser = argparse.ArgumentParser()
parser.add_argument("--mame", action="store_true")
parser.add_argument("--no-precalc", action="store_true")
parser.add_argument("--precalc", action="store_true")
parser.add_argument("--music", action="store_true")
args = parser.parse_args()

if args.precalc:
    import precalc

if not os.path.isdir( BUILD_DIR):
    os.makedirs(BUILD_DIR)
    pass

print("Builing demo")

MUSIC_MEM = 'F700'

if args.music:
    additional_options = f"-D MUSIC" # -D PT3_LOC=\\${MUSIC_MEM}"
else:
    additional_options = ""

gen_code_vertical_scroll()
run(f"{CA65} -o {BUILD_DIR}/vscroll.o -t apple2 --listing {BUILD_DIR}/vscroll.txt {additional_options} vscroll.s")
run(f"{LD65} -o {BUILD_DIR}/VSCROLL {BUILD_DIR}/vscroll.o -C link.cfg --mapfile {BUILD_DIR}/map.out")


run(f"{CA65} -o {BUILD_DIR}/td.o -t apple2 --listing {BUILD_DIR}/td.txt {additional_options} td.s")
run(f"{LD65} -o {BUILD_DIR}/THREED {BUILD_DIR}/td.o -C link.cfg --mapfile {BUILD_DIR}/map.out")
memory_map()



make_all( BUILD_DIR, "bigscroll/data")
run(f"{CA65} -I . -o {BUILD_DIR}/big_scroll.o -t apple2 {additional_options} bigscroll/scroll.s")
run(f"{LD65} -o {BUILD_DIR}/BSCROLL {BUILD_DIR}/big_scroll.o -C bigscroll/link.cfg --mapfile {BUILD_DIR}/map.out")





print("Builing loader")

with open(f"{BUILD_DIR}/file_size.s","w") as fout:

    size = os.path.getsize(f"{BUILD_DIR}/THREED")
    print(f"Demo : {size} bytes")
    fout.write(f"THREED_SIZE = {size}\n")

    size = os.path.getsize(f"{BUILD_DIR}/datad000.o")
    print(f"Data : {size} bytes")
    fout.write(f"DATAD000_SIZE = {size}\n")

    size = os.path.getsize(TUNE)
    print(f"Music : {size} bytes")
    fout.write(f"MUSIC_SIZE = {size}\n")

    size = os.path.getsize(f"{DATA_DIR}/TITLEPIC.BIN")
    print(f"Pix : {size} bytes")
    fout.write(f"ICEBERG_SIZE = {size}\n")

    size = os.path.getsize(f"{BUILD_DIR}/VSCROLL")
    print(f"Scroller : {size} bytes")
    fout.write(f"VSCROLL_SIZE = {size}\n")

run(f"{ACME} -o {BUILD_DIR}/prorwts2.o PRORWTS2.S ")

print("Packaging DSK file")

if os.path.isfile( f"{BUILD_DIR}/NEW.DSK"):
    os.remove(f"{BUILD_DIR}/NEW.DSK")

shutil.copyfile("data/BLANK_PRODOS2.DSK",f"{BUILD_DIR}/NEW.DSK")

with open(f"{BUILD_DIR}/prorwts2.o") as stdin :
    run(f"{ACMDER} -p {BUILD_DIR}/NEW.DSK RWTS  BIN 0x0800", stdin=stdin)

with open(f"{BUILD_DIR}/VSCROLL") as stdin :
    run(f"{ACMDER} -p {BUILD_DIR}/NEW.DSK VSCROLL BIN 0x6000", stdin=stdin)

with open(f"{BUILD_DIR}/THREED") as stdin :
    run(f"{ACMDER} -p {BUILD_DIR}/NEW.DSK START BIN 0x6000", stdin=stdin)

with open(f"{BUILD_DIR}/datad000.o") as stdin :
    run(f"{ACMDER} -p {BUILD_DIR}/NEW.DSK LINES BIN 0xD000", stdin=stdin)

with open(f"{DATA_DIR}/TITLEPIC.BIN") as stdin :
    run(f"{ACMDER} -p {BUILD_DIR}/NEW.DSK PIX BIN 0x2000", stdin=stdin)


# big scroller

with open(f"{BUILD_DIR}/BSCROLL") as stdin :
    run(f"{ACMDER} -p {BUILD_DIR}/NEW.DSK BSCROLL BIN 0x0C00", stdin=stdin)

with open(f"{BUILD_DIR}/data6000.o") as stdin :
    run(f"{ACMDER} -p {BUILD_DIR}/NEW.DSK FILLER BIN 0x6000", stdin=stdin)

with open(f"{DATA_DIR}/FR.PT3") as stdin :
    run(f"{ACMDER} -p {BUILD_DIR}/NEW.DSK SONG BIN 0x4000", stdin=stdin)

# with open(TUNE) as stdin :
#     run(f"{ACMDER} -p {BUILD_DIR}/NEW.DSK MUSIC BIN 0x{MUSIC_MEM}", stdin=stdin)

run(f"{ACMDER} -l {BUILD_DIR}/NEW.DSK")


print("Additional tasks")
if platform.system() == "Linux":
    # Generate listing (you can print in firefox, 2 pages side by side)

    shutil.copyfile("asm-style.css",f"{BUILD_DIR}/asm-style.css")
    run(f"source-highlight --src-lang asm -f html --doc -c asm-style.css  --lang-def asm.lang --output-dir={BUILD_DIR} vline.s")
    run(f"source-highlight --src-lang asm -f html --doc -c asm-style.css  --lang-def asm.lang --output-dir={BUILD_DIR} hline.s")








# disk = AppleDisk(f"{BUILD_DIR}/NEW.DSK")
# track = 16
# for logical_sector in range(16):
#     disk.set_sector( track, logical_sector, bytearray([logical_sector]*256))
# disk.save()


print("Running emulator")
if args.mame:
    # -resolution 1200x900
    run(f"{MAME} apple2e -sound none -switchres -speed 1 -skip_gameinfo -rp bios -flop1 {BUILD_DIR}/NEW.DSK")
else:
    dsk = os.path.join( BUILD_DIR_ABSOLUTE, "NEW.DSK")
    if platform.system() == "Linux":
        dsk = dsk.replace("/",r"\\")
    run(f"{APPLEWIN} -d1 {dsk}")
