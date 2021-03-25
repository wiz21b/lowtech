#!/bin/bash

# Demo lasts 3 minutes. = 3*60*60 = 10800 frames

SHAMUS=/mnt/data2/apple2/apple2/apple2

# Don't forget to record HGR files from shamus first !
# Capture 10800 frames = 3 minutes
$SHAMUS 1 10800

for f in /mnt/data2/tmp/shamus_t0*.dat; do
    /home/stefan/Dropbox/demo2/hgr2rgbntsc/bin/hgr2rgb.elf -bmp ${f} ;
    convert ${f}.bmp ${f}.png;
done

# # Record from mame

/mnt/data2/mame0228/mame64 apple2e -seconds_to_run 180 -volume -12 -window -switchres -speed 1 -skip_gameinfo -rp bios -aviwrite /mnt/data2/tmp/mame_capture.avi -flop1 /home/stefan/Dropbox/demo2/build/LOWTECH.WOZ
ffmpeg -r 1 /mnt/data2/tmp/mame_capture.avi -r 1 "/mnt/data2/tmp/mame%06d.png"

# hgr2rgb has produced 600x420 pictures but with border 50 horiz and 20 verti ...
# => 500 - 2*50 = 400; 420*2*20=380
for f in /mnt/data2/tmp/mame0*.png; do
    echo $f
    # bang means ignore aspect ratio
    convert ${f} -resize 500x380! -background black -gravity center -extent 600x420 ${f}
done


# First real image in Mame is number 620

for f in /mnt/data2/tmp/mame{000001..000619}.png ; do
    # echo $f ;
    n=`grep -o "mame[0-9]*" <<<  ${f} | sed s/mame//` ;
    cp $f /mnt/data2/tmp/final_${n}.png
done

# First real image in Shamus is number 821

for f in /mnt/data2/tmp/shamus_t{000821..010800}.dat.png ; do
    n=`grep -o "shamus_t[0-9]*" <<<  ${f} | sed s/shamus_t//` ;
    n=$((10#$n - 821 + 620)) ;
    n=`printf "%06d\n" ${n}` ;
    cp $f /mnt/data2/tmp/final_${n}.png
    echo $f "->" $n;
done

# Join picture and sound
# Maps ware well explained in ffmpeg official documentation

# This leads to a 100Mb video
# ffmpeg -y -i /mnt/data2/tmp/mame_capture.avi  -framerate 60 -i /mnt/data2/tmp/final_%06d.png -map 0:1 -map 1:0 -c:a aac -b:a 384k -pix_fmt yuv420p -vf "scale=1080:720"  -r 60 -profile:v baseline -preset slow -crf 1 -shortest /mnt/data2/tmp/lowtech.mp4

ffmpeg -y -i /mnt/data2/tmp/mame_capture.avi  -framerate 60 -i /mnt/data2/tmp/final_%06d.png -map 0:1 -map 1:0 -c:a aac -b:a 384k -pix_fmt yuv420p -vf "scale=1080:720"  -r 60 -profile:v baseline -preset slow -crf 10 -shortest /mnt/data2/tmp/lowtech.mp4

ffprobe /mnt/data2/tmp/lowtech.mp4
du -h /mnt/data2/tmp/lowtech.mp4
