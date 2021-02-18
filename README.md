# Lowtech's dev notes

Below are some explanations of how Lowtech works. It might
be interesting for the curious reader.

I take the opportunity to thank all people who gave me
time and information when I was asking questions as well
as all of those who gave away the tools they wrote.
Without that generosity I would have taken years to
make that demo (which, for all practical situation, means
no demo at all).


# The scroller

The big scroll at the beginning of the demo is just an application of
delta drawing : I just draw and erase the part of the images that need
it. The whole point is to be clever about what parts.

Beyond that, the optimisation relies on the fact that the logo is made
of tiles. So, it reduces to a few very simple components.  The code is
quite optimized in that each tile is pre-ROLed and code for
drawing/clearing it is generated for each of them. So lots of code
generation.

One may have done better by observing that tiles are often surrounded
by the same set of other tiles. So you could maybe draw several
tiles at once, reducing the number of index lookups in the tile table
as well a JSR/RTS needed to call the tile drawing code.

# The disk I/O routine

The disk I/O routine is probably the part I'm most proud of because
without it that demo would not have been possible, especially the 3D part.

That routine allows the floppy disk to be
read while music is playing.  So the whole magic is to interleave
music and disk I/O in a seamless way. That's very tricky to achieve
and to this day I'm still not sure it is 100% optimized. As you may
know, reading disk on the Apple ][ requires the CPU fulltime (because
it reads nibble by nibble, so while you read, you can't draw, you
can't play music, you certainly can't be interrupted by IRQ).  So the
whole point is to make sure we start the reading when a sector is
available and not too much before, else the CPU will spend time
waiting for the sector to come below the read head.

Thanks to that disk I/O routine, I can load data while playing music
and doing demo effects.

# The 3D

The 3D part is built upon something that has nothing to do with 3D,
that is a disk I/O routine, see above.

Once we have a proper disk I/O, it is relatively easy to stream the 3D
data out of the disk. The next step is to make sure we read the less
possible so we can spend time drawing instead of streaming.

As you may now have guessed, the 3D is mostly precomputed.
However, it's not easy and you'll see that it's quite involved.

The first piece of code that is needed is something to import data
from Blender. I import the meshes as well as the camera
transformations. A bit of algebra is needed here :-)

Then computing hidden face removal on
simple vector graphics is not easy. Using z-buffer is riddled with
numerical issues so I actually compute the exact intersections between
each edges. So I basically check for intersection between edges and
triangles. This is n² but given that I have not many edges/faces
its bearable.

Once that is done I have a collection of edges. To reduce the number
of vertices to a minimum, I have to order the edges. For example, if
you have egde AB,CB,CD you can store : ABCD (avoiding to store B and C
twice). When you have 40 edges that problem becomes complicated as it
is akin to a travelling salesman problem which is NP complete. Even
with a few dozens of edge that problem is not practical in Python.  A
rewrite in a faster language was needed, I choose Julia.  Then I used
mostly brute force + some heuristics to find a close to optimal set of
paths covering all edges.

Finally, once all the edges are stored, I just have to draw them. This
implies a division which is quite common and efficient. Then we
proceed to actual drawing. This is special on the Apple ][. I
basically cut each line in 7x7 tiles and the line is drawn one tile at
a time. The key insight here is that you don't need many tiles
(precomputed, in memory) to draw all possible lines.  Finally, lots of
tricks are used to make sure the code goes as fast as possible. The
biggest problem is to draw the first/last tile of line because they
are never drawn in full; that's quite like clipping and leads to
tedioous computations (which still have bugs...)

# Vertical scroll

Nothing fancy except that I have to do double buffering and handling a
scroll like that is a bit complicated.  The memcopy routine is quite
optimized. I also had fun making sure the letter positionning is
proportional.

# Loading

I had to make a fast load (based on someone else's code), that is
using a bootloader which does the bare minimum.  I also use LZ4
compression (based on someone else's code).  In the end, I made a
complete disk building program to make sure to position the files
exactly where we need them in order to reduce read head movement.

# Technical notes

I used :

* Blender for drawing the 3D
* Godot to tile the big scroll
* ca65 and acme for assembly
* python to precompute lots of stuff and build the demo disk
* julia to precompute and optimize 3D
* Rgb2Hgr to quickly get pictures to Apple format
* grafx2 to pixel edit drawings
* AppleWin, AIPC, Mame emulators
* wine to run AppleWin on Linux
* emacs and Debian as my work environment
