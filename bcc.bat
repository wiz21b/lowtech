@echo off

\PORT-STC\opt\cc65\bin\ca65 -o build/checkdisk.o checkdisk.s
\PORT-STC\opt\cc65\bin\ld65 -o CHKDSK build/checkdisk.o -C link.cfg

del NEW.DSK
copy data\BLANK_PRODOS2.DSK NEW.DSK

java -jar ..\bad_apple\AppleCommander-1.3.5.13-ac.jar -p NEW.DSK CHKDSK  BIN 0x6000  < CHKDSK

dsk2woz.exe NEW.DSK NEW.WOZ

REM -speed 40
REM c:\port-stc\opt\mame\mame64 apple2p -skip_gameinfo -window -nomax -flop1 NEW.WOZ -rp bios

\PORT-STC\opt\applewin\Applewin.exe -d1 NEW.WOZ
