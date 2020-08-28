#!/bin/bash

echo "Assembling the code"

python3 textscreen.py

echo version_txt: .byte \"CHKDSK VERSION : `date +"%d %B %Y %H:%M"| tr [:lower:] [:upper:]`\",0 > build/version.inc

#cat build/version.inc
#exit

#ca65 -o build/checkdisk.o -D MUSIC -D DEBUG -D APPLEWIN_FIX checkdisk.s
ca65 -o build/checkdisk.o -D MUSIC -D DEBUG checkdisk.s

retVal=$?
if [ $retVal -ne 0 ]; then
    exit 1;
fi

ld65 -o CHKDSK build/checkdisk.o -C link.cfg
ls -l CHKDSK

echo "Making DSK"

rm NEW.DSK
cp data/BLANK_PRODOS2.DSK NEW.DSK

java -jar ../bad_apple/AppleCommander-1.3.5.13-ac.jar -p NEW.DSK CHKDSK BIN 0x6000 < CHKDSK

# Generate listing (you can print in firefox, 2 pages side by side)
#source-highlight --src-lang asm -f html --doc -c=asm-style.css  --lang-def asm.lang vline.s

echo "Making WOZ"
./dsk2woz_wiggles NEW.DSK NEW.WOZ

# \PORT-STC\opt\applewin\Applewin.exe -d1 NEW.DSK
mame apple2e -skip_gameinfo -window -flop1 NEW.WOZ -rp ../bad_apple/bios -speed 1

# Only WOZ disk emulation seems to have correct timings.
#/opt/wine-staging/bin/wine ~/AppleWin1.29.13.0/Applewin.exe -d1 \\home\\stefan\\Dropbox\\demo2\\NEW.WOZ -conf ~/applewin.ini
