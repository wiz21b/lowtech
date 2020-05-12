#!/bin/bash

python3 precalc.py

echo "Assembling the code"

ca65 -o td.o td.s
ld65 -o THREED td.o  -C link.cfg
rm td.o
ls -l THREED

rm NEW.DSK
cp data/BLANK_PRODOS2.DSK NEW.DSK

java -jar ../bad_apple/AppleCommander-1.3.5.13-ac.jar -p NEW.DSK START    BIN 0x6000 < THREED
java -jar ../bad_apple/AppleCommander-1.3.5.13-ac.jar -p NEW.DSK PRORWTS  BIN 0x0800 < prorwts2#060800

# Generate listing (you can print in firefox, 2 pages side by side)
source-highlight --src-lang asm -f html --doc -c=asm-style.css  --lang-def asm.lang vline.s


# \PORT-STC\opt\applewin\Applewin.exe -d1 NEW.DSK
mame apple2e -skip_gameinfo -window -nomax -flop1 NEW.DSK -rp ../bad_apple/bios -sound none -speed 1

#/opt/wine-staging/bin/wine ~/AppleWin1.29.10.0/Applewin.exe -d1 \\home\\stefan\\Dropbox\\demo2\\NEW.DSK
