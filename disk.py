from enum import Enum
import pygame

WHITE = (255,255,255)
BLACK = (0,0,0)
RED = (255,64,64)
BLUE = (0,0,255)
DARK_GREEN = (0,192,0)

#print(pygame.font.get_default_font())

pygame.font.init()

SCALE = 0.5
Y_OFS1 = 20*SCALE
Y_OFS2 = 50*SCALE
FONT = pygame.font.Font("/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf",24)
SMALL_FONT = pygame.font.Font("/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf",16)

class Commands(Enum):
    READ_SECTOR = 1
    MUSIC_REGULAR = 2
    MUSIC_LONG = 3
    MUSIC_SHORT = 4
    SHORT_SILENCE = 7

commands = []
tops = dict()


def x_y( s):
    return (s % 16 + 0.1), ((s // 16) * 220 + 150)*SCALE

def rx_to_x( rx):
    return (rx/16)*1600

top_num = 1
def top( screen, rx_top, y):
    global top_num, tops

    tops[top_num] = (rx_top,y)

    # Draw an IRQ
    pygame.draw.line( screen, RED, (rx_top,y), (rx_top,y+Y_OFS2), 8 )

    # snum = SMALL_FONT.render( f"{top_num:X}", True, BLACK, WHITE)
    # screen.blit(snum, (rx_top,y+50*SCALE) )

    # stype = SMALL_FONT.render( commands[-1].name.replace("MUSIC_",""), True, BLACK, WHITE)
    # screen.blit(stype, (rx_top,y+70*SCALE) )

    c_short = commands[-1].name.replace("MUSIC_","")[0:4]
    snum = SMALL_FONT.render( f"{top_num:X},{c_short}", True, BLACK, WHITE)
    screen.blit(snum, (rx_top,y+50*SCALE) )

    top_num += 1


def draw_exp_delay( screen, top, size, offset):
    global tops

    x, y = tops[ top]

    h = int(8*SCALE)
    o = offset * 10
    s = (size - 0x400) // h

    pygame.draw.line( screen, DARK_GREEN, (x,y-(60-o)*SCALE), (x + s,y-(60-o)*SCALE),h)

def draw_vert( screen, s, base_sector, c = BLACK ):
    rx, y = x_y(s)
    x = rx_to_x(rx)

    snum = FONT.render( f"{s}", True, BLACK, WHITE) # /{base_sector:02X}
    screen.blit(snum, (x,y-70*SCALE) )
    #print(f"{s} x={x} rx={rx} y={y}")
    pygame.draw.line( screen, c, (x,y), (x,y-70*SCALE) )



def read_sect( screen, s):
    global commands
    commands.append( Commands.READ_SECTOR)

    s, y = x_y(s)

    rx = rx_to_x(s-0.1)
    rx_end = rx_to_x( s+1 )
    rx_top = rx_to_x( s-0.1)

    #rx_plan = rx_to_x( s)
    rx_plan = rx_end
    rx_plan_next = rx_to_x( s+1+0.1)

    pygame.draw.rect( screen, (205,205,205), (rx,y-Y_OFS1,rx_end-rx,Y_OFS1) )
    #pygame.draw.line( screen, RED, (rx_top,y), (rx_top,y+50), 4 )
    top(screen,rx_top,y)


    pygame.draw.line( screen, BLUE, (rx_plan,y-Y_OFS1), (rx_plan,y+Y_OFS2),2 )
    pygame.draw.line( screen, BLUE, (rx_plan,y+Y_OFS2), (rx_plan_next,y+Y_OFS1),2 )

def music_short( screen, s):
    global commands
    commands.append( Commands.MUSIC_SHORT)

    s, y = x_y(s)

    rx = rx_to_x(s+0.1)
    rx_end = rx_to_x( s+0.1+0.2 )
    rx_plan = rx_to_x( s+1-0.1)

    pygame.draw.rect( screen, BLACK, (rx,y-Y_OFS1,rx_end-rx,Y_OFS1) )
    #pygame.draw.line( screen, RED, (rx,y), (rx,y+50),4 )
    top(screen,rx,y)
    pygame.draw.line( screen, BLUE, (rx,y+Y_OFS2), (rx_plan,y+Y_OFS1),2 )


def silence_short( screen, s):
    global commands
    commands.append( Commands.SHORT_SILENCE)

    s, y = x_y(s)

    rx = rx_to_x(s+0.1)
    rx_end = rx_to_x( s+0.1+0.2 )
    rx_plan = rx_to_x( s+1-0.1)

    top(screen,rx,y)
    pygame.draw.line( screen, BLUE, (rx,y+Y_OFS2), (rx_plan,y+Y_OFS1),2 )


def music_far( screen, s):
    global commands
    commands.append( Commands.MUSIC_LONG)
    s, y = x_y(s)

    rx = rx_to_x(s+0.1)
    rx_end = rx_to_x( s+0.1+0.2 )
    rx_plan = rx_to_x( s+2+0.1)

    pygame.draw.rect( screen, BLACK, (rx,y-Y_OFS1,rx_end-rx,Y_OFS1) )
    #pygame.draw.line( screen, RED, (rx,y), (rx,y+50),4 )
    top(screen,rx,y)
    pygame.draw.line( screen, BLUE, (rx,y+Y_OFS2), (rx_plan,y+Y_OFS1),2 )


def music_regular( screen, s):
    global commands
    commands.append( Commands.MUSIC_REGULAR)

    s, y = x_y(s)

    rx = rx_to_x(s+0.1)
    rx_end = rx_to_x( s+0.1+0.2 )
    rx_plan = rx_to_x( s+1+0.1)

    pygame.draw.rect( screen, BLACK, (rx,y-Y_OFS1,rx_end-rx,Y_OFS1) )
    #pygame.draw.line( screen, RED, (rx,y), (rx,y+50),4 )
    top(screen,rx,y)
    pygame.draw.line( screen, BLUE, (rx,y+Y_OFS2), (rx_plan,y+Y_OFS1),2 )


def make_fast_load_choregraphy(screen):

    for s in range( 64):
        draw_vert( screen, s, (0x6 + s) % 16)

    for s in range(0,64,16):
        rx, y = x_y(s)
        print(f"{s} {y}")
        pygame.draw.line( screen, BLACK, (0,y), (1600,y) )


    read_sect(screen,0) # 1
    music_far(screen, 1)
    music_short(screen, 3)
    read_sect(screen,4)
    music_far(screen, 5)
    music_short(screen, 7)
    read_sect(screen,8)
    music_far(screen, 9)
    music_short(screen, 11)
    read_sect(screen,12)
    music_regular(screen, 13)
    music_short(screen, 14)
    read_sect(screen,15) # D

    music_far(screen, 16+0) # E
    music_short(screen, 16+2)
    read_sect(screen, 16+3)
    music_far(screen, 16+4)
    music_short(screen, 16+6)
    read_sect(screen, 16+7)
    music_far(screen, 16+8)
    music_short(screen, 16+10)
    read_sect(screen, 16+11)
    music_regular(screen, 16+12) # 17

    #music_short(screen, 16+13)
    # This to make sure we have the right number
    # of "top's" for the music (that is 8 tops
    # every 16 IRQ, no more, no less).
    silence_short(screen, 16+13)

    read_sect(screen, 16+14)
    music_far(screen, 16+15)  # 20

    music_short(screen, 32+1)
    read_sect(screen, 32+2)
    music_far(screen, 32+3)
    music_short(screen, 32+5)
    read_sect(screen, 32+6)
    music_far(screen, 32+7)
    music_short(screen, 32+9)
    read_sect(screen, 32+10)
    music_regular(screen, 32+11)
    music_short(screen, 32+12)
    read_sect(screen, 32+13)
    music_far(screen, 32+14)


    music_short(screen, 48+0)
    read_sect(screen, 48+1)
    music_far(screen, 48+2)
    music_short(screen, 48+4)
    read_sect(screen, 48+5)
    music_far(screen, 48+6)
    music_short(screen, 48+8)
    read_sect(screen, 48+9)

    music_far(screen, 48+10)
    music_far(screen, 48+12)
    music_far(screen, 48+14)

    # Here I've recorded the time it takes to complete the rdadr16
    # subroutine on various execution.  We can see that it's rather
    # constant in function of the steps before it (short step, mid-step,
    # long step).

    # Especially, given those two steps, we have those wait times, very
    # constant :

    # mid-wait :
    #   (Tolerance) + (Sector) +     (Sector -2 x Tol.) = 2 x S - T
    #   => rdadr16 wait time is +/- $4E0

    # long wait :
    #   (Tolerance) + (2 x Sector) + (Sector -2 x Tol.) = 3 x S - T
    #   => rdadr16 wait time is +/- $550

    # => we're adding $550-$4E0=$70 cycle wait if we have an additional
    # sector wait. (remember, in both cases, we're meant to reach the same
    # point before the rdadr16 call. If we're not then either S or T is
    # too small)

    # So it means that we under evaluate the duration of a sector wait by
    # $70 cycles (with tolerance == $100)

    # In both cases, there are 2 interrupt calls to play the PT3.  So IRQ
    # processing should not have much incidence.

    # When we wait for 2 IRQ, we can count we add around $80 cycles for
    # entering the IRQ handler, doing some stuff, etc.  So say, $100
    # cycles. If T == $100, then we should be "late" by zero.

    # Calibration measures this :
    #
    # gap - ADDR - gap - DATA
    # |                     |
    # +---------------------+ == sector time
    # |        |
    # +--------+ == addr time
    #          |            |
    #          +------------+ == data time




    RDADR_DELAYS = [ [ (0x4, 0x7e0), (0x7, 0x550),
                       (0xa, 0x550), (0xd, 0x4e0),
                       (0x10, 0x550)],
                     [ (0x7, 0x7e0),
                       (0xa, 0x550), (0xd, 0x4e0),
                       (0x10, 0x550), (0x13,0x550)],
                     [ (0x16, 0x7e0), (0x19, 0x4e0),
                       (0x1c, 0x550), (0x1f, 0x550),
                       (0x22, 0x550)],
                     [ (0x19, 0x770), (0x1c, 0x556),
                       (0x1f, 0x558), (0x22, 0x550),
                       (0x25, 0x4e0)],
                     [ (0x1f, 0x7e0), (0x22, 0x550),
                       (0x25, 0x4E0), (0x28, 0x556),
                       (0x2B, 0x558)],
                     [ (0x22, 0x7e0), (0x25, 0x4f0),
                       (0x28, 0x550), (0x2b, 0x556),
                       (0x2e, 0x558)],
                    ]

    for offset, rdadr_delays in enumerate( RDADR_DELAYS):
        for top, size in rdadr_delays:
            draw_exp_delay( screen, top, size, offset)


def make_slow_load_choregraphy(screen):

    for s in range( 128):
        draw_vert( screen, s, (0x6 + s) % 16)

    for s in range(0,128,16):
        rx, y = x_y(s)
        print(f"{s} {y}")
        pygame.draw.line( screen, BLACK, (0,y), (1600,y) )

    def pattern1( base):
        read_sect(screen, base)
        music_far(screen, base+1)
        music_far(screen, base+3)
        music_far(screen, base+5)
        music_short(screen, base+7)

    def pattern2( base):
        read_sect(screen, base)
        music_far(screen, base+1)
        music_far(screen, base+3)
        music_regular(screen, base+5)
        silence_short(screen, base+6)


    pattern1( 0)
    pattern2( 8)
    pattern1( 15)
    pattern2( 23)

    pattern1( 30)
    pattern2( 38)
    pattern1( 45)
    pattern2( 53)

    pattern1( 60)
    pattern2( 68)
    pattern1( 75)
    pattern2( 83)

    pattern1( 90)
    pattern2( 98)
    pattern1( 105)
    read_sect( screen, 113)


pygame.init()
screen = pygame.display.set_mode((1600,900))
screen.fill( WHITE)

make_slow_load_choregraphy(screen)
#make_fast_load_choregraphy(screen)

pygame.display.flip()



# main loop
running = True
while running:
    # event handling, gets all event from the event queue
    for event in pygame.event.get():
        # only do something if the event is of type QUIT
        if event.type == pygame.QUIT:
            # change the value to False, to exit the main loop
            running = False

with open("build/choregraphy.inc","w") as fout:
    for i,c in enumerate(commands):
        fout.write( f"    .byte {c.name}\t;{i+1:X}\n")
