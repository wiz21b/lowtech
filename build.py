import argparse
import subprocess
import os
import shutil
import os.path

import precalc
import platform


def run(cmd, stdin=None):
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
    APPLEWIN=r"/opt/wine-staging/bin/wine /home/stefan/AppleWin1.29.10.0/Applewin.exe -d1 \\home\\stefan\\Dropbox\\demo2\\build\\NEW.DSK"
    MAME = "mame"
else:
    raise Exception("Unsupported system : {}".format(platform.system()))

BUILD_DIR = "build"
TUNE = "data/FR.PT3"

parser = argparse.ArgumentParser()
parser.add_argument("--mame", action="store_true")
args = parser.parse_args()


if not os.path.isdir( BUILD_DIR):
    os.makedirs(BUILD_DIR)
    pass

print("Builing demo")

run(f"{CA65} -o {BUILD_DIR}/td.o td.s")
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

with open(TUNE) as stdin :
    run(f"{ACMDER} -p {BUILD_DIR}/NEW.DSK MUSIC BIN 0x0C00", stdin=stdin)

print("Additional tasks")
if platform.system() == "Linux":
    run(f"source-highlight --src-lang asm -f html --doc -c=asm-style.css  --lang-def asm.lang --output-dir={BUILD_DIR} vline.s")

print("Running emulator")
if args.mame:
    run(f"{MAME} apple2p -window  -switchres -resolution 800x600 -speed 1 -skip_gameinfo -rp bios -flop1 {BUILD_DIR}/NEW.DSK")
else:
    run(f"{APPLEWIN} -d1 {BUILD_DIR}\\NEW.DSK")
