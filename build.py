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
BUILD_DIR_ABSOLUTE = os.path.join( os.path.dirname(os.path.abspath(__file__)), BUILD_DIR)
TUNE = "data/FR.PT3"

parser = argparse.ArgumentParser()
parser.add_argument("--mame", action="store_true")
parser.add_argument("--no-precalc", action="store_true")
parser.add_argument("--music", action="store_true")
args = parser.parse_args()

if not args.no_precalc:
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

run(f"{CA65} -o {BUILD_DIR}/td.o -t apple2 --listing {BUILD_DIR}/td.txt {additional_options} td.s")

run(f"{LD65} -o {BUILD_DIR}/THREED {BUILD_DIR}/td.o -C link.cfg --mapfile {BUILD_DIR}/map.out")

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


run(f"{ACME} -o {BUILD_DIR}/prorwts2.o PRORWTS2.S ")

print("Packaging DSK file")

if os.path.isfile( f"{BUILD_DIR}/NEW.DSK"):
    os.remove(f"{BUILD_DIR}/NEW.DSK")

shutil.copyfile("data/BLANK_PRODOS2.DSK",f"{BUILD_DIR}/NEW.DSK")

with open(f"{BUILD_DIR}/prorwts2.o") as stdin :
    run(f"{ACMDER} -p {BUILD_DIR}/NEW.DSK RWTS  BIN 0x0800", stdin=stdin)

with open(f"{BUILD_DIR}/THREED") as stdin :
    run(f"{ACMDER} -p {BUILD_DIR}/NEW.DSK START BIN 0x6000", stdin=stdin)

with open(f"{BUILD_DIR}/datad000.o") as stdin :
    run(f"{ACMDER} -p {BUILD_DIR}/NEW.DSK LINES BIN 0xD000", stdin=stdin)

# with open(TUNE) as stdin :
#     run(f"{ACMDER} -p {BUILD_DIR}/NEW.DSK MUSIC BIN 0x{MUSIC_MEM}", stdin=stdin)

print("Additional tasks")
if platform.system() == "Linux":
    # Generate listing (you can print in firefox, 2 pages side by side)

    shutil.copyfile("asm-style.css",f"{BUILD_DIR}/asm-style.css")
    run(f"source-highlight --src-lang asm -f html --doc -c asm-style.css  --lang-def asm.lang --output-dir={BUILD_DIR} vline.s")
    run(f"source-highlight --src-lang asm -f html --doc -c asm-style.css  --lang-def asm.lang --output-dir={BUILD_DIR} hline.s")



memory_map()



disk = AppleDisk(f"{BUILD_DIR}/NEW.DSK")
track = 16
for logical_sector in range(16):
    disk.set_sector( track, logical_sector, bytearray([logical_sector]*256))
disk.save()


print("Running emulator")
if args.mame:
    run(f"{MAME} apple2p -window  -switchres -resolution 1200x900 -speed 1 -skip_gameinfo -rp bios -flop1 {BUILD_DIR}/NEW.DSK")
else:
    dsk = os.path.join( BUILD_DIR_ABSOLUTE, "NEW.DSK")
    if platform.system() == "Linux":
        dsk = dsk.replace("/",r"\\")
    run(f"{APPLEWIN} -d1 {dsk}")
