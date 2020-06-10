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

# Inspiration for my big scroller font
https://www.dafont.com/alien-android.font?text=LOW+TECH

"""
import sys
import numpy as np
from PIL import Image, ImageFilter, ImageFont, ImageDraw
from utils import *

from bigscroll.make_logo import make_all



PUSAB_ALPHABET="ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-,.!"
new_blocs = make_bitmap_font("data/8-bit-pusab.ttf", PUSAB_ALPHABET, 7)

MESSAGE = ["IN 2020, 50M TONS",
           "OF E-WASTE WERE",
           "PRODUCED.",
           "",
           "STOP THAT MADNESS,",
           "PROTECT NATURE !",
           "",
           "HAIL THE AGE OF..."]

with open("data/alphabet2.s","w") as fout:
    generate_font_data( fout, "f2", new_blocs, PUSAB_ALPHABET, nb_ROLs=1)
    message_to_font( fout, "m2_", MESSAGE, PUSAB_ALPHABET)


#show_bitmap_font( new_blocs)
# exit()

# Alphabeta here : https://fontmeme.com/pixel-fonts/
# https://fontmeme.com/fonts/little-conquest-font/

#new_blocs = font_split("data/Alphabeta 7 pixels font.png")

LITTLE_CONQUEST_ALPHABET= "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
new_blocs = make_bitmap_font("data/Little Conquest.ttf", LITTLE_CONQUEST_ALPHABET)
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
           "",
           "   Vince Weaver",
           "",
           "RWTS",
           "",
           "   Peter Ferrie",
           "",
           "Fonts",
           "",
           "   Little Conquest",
           "   by Brixdee",
           "",
           "   Alien Android",
           "   by Darrell Flood",
           "",
           "Iceberg",
           "",
           "   iStock free",
           "",
           "",
           "",
           "",
           "",
           "",
]

with open("data/alphabet.s","w") as fout:
    generate_font_data( fout, "f1", new_blocs, LITTLE_CONQUEST_ALPHABET, nb_ROLs=4)
    message_to_font( fout, "", MESSAGE, LITTLE_CONQUEST_ALPHABET)




#append_images( [Image.fromarray(b).convert( mode="RGB") for b in new_blocs]).show()

# im = im.filter(ImageFilter.FIND_EDGES)
# im.show()
#Image.fromarray(ar).show()
#exit()

# https://www.istockphoto.com/be/vectoriel/iceberg-main-illustration-dessin%C3%A9e-convertie-au-vecteur-gm1038069650-277863881
# libre de droit

im = Image.open("data/black_ice2.bmp")
im = im.resize( (APPLE_XRES,APPLE_YRES) )
# https://pillow.readthedocs.io/en/stable/handbook/concepts.html#modes

# add some black horizontal lines for underwater part of the iceberg
ar = np.array(im)
for i in range( 85, APPLE_YRES, 2):
    ar[i,:] = 0
im = Image.fromarray(ar)

hgr = image_to_hgr( im)

with open("data/TITLEPIC.BIN","wb") as f_out:
    f_out.write( bytearray(hgr))

#im.show()
im.close()


im = Image.open("data/earth.png")
im = im.resize( (APPLE_XRES,APPLE_YRES) )
with open("build/earth.bin","wb") as f_out:
    f_out.write( bytearray( image_to_hgr( im)))




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
parser.add_argument("--build", action="store_true")
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

    size = os.path.getsize(f"{BUILD_DIR}/BSCROLL")
    print(f"Big scroller : {size} bytes")
    fout.write(f"BSCROLL_SIZE = {size}\n")

    size = os.path.getsize(f"{BUILD_DIR}/earth.bin")
    print(f"Earth : {size} bytes")
    fout.write(f"EARTH_SIZE = {size}\n")

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

with open(f"{BUILD_DIR}/earth.bin") as stdin :
    run(f"{ACMDER} -p {BUILD_DIR}/NEW.DSK EARTH BIN 0x2000", stdin=stdin)

# big scroller

with open(f"{BUILD_DIR}/BSCROLL") as stdin :
    run(f"{ACMDER} -p {BUILD_DIR}/NEW.DSK BSCROLL BIN 0x6000", stdin=stdin)

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

if args.build:
    exit()

print("Running emulator")
if args.mame:
    # -resolution 1200x900
    run(f"{MAME} apple2e -sound none -window -switchres -speed 1 -skip_gameinfo -rp bios -flop1 {BUILD_DIR}/NEW.DSK")
else:
    dsk = os.path.join( BUILD_DIR_ABSOLUTE, "NEW.DSK")
    if platform.system() == "Linux":
        dsk = dsk.replace("/",r"\\")
    run(f"{APPLEWIN} -d1 {dsk}")
