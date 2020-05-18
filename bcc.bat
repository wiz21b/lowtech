@echo off
python precalc.py

\PORT-STC\opt\cc65\bin\ca65 -o td.o td.s
\PORT-STC\opt\cc65\bin\ld65 -o THREED td.o  -C link.cfg
del td.o

\PORT-STC\opt\cc65\bin\ca65 -o loader.o loader.s
\PORT-STC\opt\cc65\bin\ld65 -o LOADER loader.o  -C link_loader.cfg

del NEW.DSK
copy data\BLANK_PRODOS2.DSK NEW.DSK

java -jar ..\bad_apple\AppleCommander-1.3.5.13-ac.jar -p NEW.DSK START  BIN 0x0C00  < LOADER
java -jar ..\bad_apple\AppleCommander-1.3.5.13-ac.jar -p NEW.DSK THREED  BIN 0x6000  < THREED

dir THREED

REM -speed 40
REM c:\port-stc\opt\mame\mame64 apple2p -skip_gameinfo -window -nomax -flop1 BAD_APPLE.DSK -flop2 BAD_APPLE_DATA.DSK -rp bios

\PORT-STC\opt\applewin\Applewin.exe -d1 NEW.DSK
