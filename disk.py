from enum import Enum
import pygame

WHITE = (255,255,255)
BLACK = (0,0,0)
RED = (255,64,64)
BLUE = (0,0,255)

print(pygame.font.get_default_font())

pygame.font.init()
FONT = pygame.font.Font("/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf",32)

SMALL_FONT = pygame.font.Font("/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf",16)

class Commands(Enum):
    READ_SECTOR = 1
    MUSIC_REGULAR = 2
    MUSIC_LONG = 3
    MUSIC_SHORT = 4

commands = []


def x_y( s):
    return s % 16 + 0.1, (s // 16) * 200 + 150

def rx_to_x( rx):
    return (rx/16)*1600

top_num = 1
def top( screen, rx_top, y):
    global top_num

    # Draw an IRQ
    pygame.draw.line( screen, RED, (rx_top,y), (rx_top,y+50), 8 )

    snum = SMALL_FONT.render( str(top_num) + commands[-1].name.replace("MUSIC_",""), True, BLACK, WHITE)
    screen.blit(snum, (rx_top,y+50) )

    top_num += 1

def draw_vert( screen, s, base_sector, c = BLACK ):
    rx, y = x_y(s)
    x = rx_to_x(rx)

    snum = FONT.render( f"{s}/{base_sector:02X}", True, BLACK, WHITE)
    screen.blit(snum, (x,y-60) )
    #print(f"{s} x={x} rx={rx} y={y}")
    pygame.draw.line( screen, c, (x,y), (x,y-60) )


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

    pygame.draw.rect( screen, (205,205,205), (rx,y-20,rx_end-rx,20) )
    #pygame.draw.line( screen, RED, (rx_top,y), (rx_top,y+50), 4 )
    top(screen,rx_top,y)

    pygame.draw.line( screen, BLUE, (rx_plan,y-20), (rx_plan,y+50),2 )
    pygame.draw.line( screen, BLUE, (rx_plan,y+50), (rx_plan_next,y+20),2 )

def music( screen, s):
    global commands
    commands.append( Commands.MUSIC_SHORT)

    s, y = x_y(s)

    rx = rx_to_x(s+0.1)
    rx_end = rx_to_x( s+0.1+0.2 )
    rx_plan = rx_to_x( s+1-0.1)

    pygame.draw.rect( screen, BLACK, (rx,y-20,rx_end-rx,20) )
    #pygame.draw.line( screen, RED, (rx,y), (rx,y+50),4 )
    top(screen,rx,y)
    pygame.draw.line( screen, BLUE, (rx,y+50), (rx_plan,y+20),2 )

def music_far( screen, s):
    global commands
    commands.append( Commands.MUSIC_LONG)
    s, y = x_y(s)

    rx = rx_to_x(s+0.1)
    rx_end = rx_to_x( s+0.1+0.2 )
    rx_plan = rx_to_x( s+2+0.1)

    pygame.draw.rect( screen, BLACK, (rx,y-20,rx_end-rx,20) )
    #pygame.draw.line( screen, RED, (rx,y), (rx,y+50),4 )
    top(screen,rx,y)
    pygame.draw.line( screen, BLUE, (rx,y+50), (rx_plan,y+20),2 )


def music_half( screen, s):
    global commands
    commands.append( Commands.MUSIC_REGULAR)

    s, y = x_y(s)

    rx = rx_to_x(s+0.1)
    rx_end = rx_to_x( s+0.1+0.2 )
    rx_plan = rx_to_x( s+1+0.1)

    pygame.draw.rect( screen, BLACK, (rx,y-20,rx_end-rx,20) )
    #pygame.draw.line( screen, RED, (rx,y), (rx,y+50),4 )
    top(screen,rx,y)
    pygame.draw.line( screen, BLUE, (rx,y+50), (rx_plan,y+20),2 )

pygame.init()
screen = pygame.display.set_mode((1600,900))
screen.fill( WHITE)

for s in range( 64):
    draw_vert( screen, s, (0x6 + s) % 16)

for s in range(0,64,16):
    rx, y = x_y(s)
    print(f"{s} {y}")
    pygame.draw.line( screen, BLACK, (0,y), (1600,y) )


read_sect(screen,0)
music_far(screen, 1)
music(screen, 3)
read_sect(screen,4)
music_far(screen, 5)
music(screen, 7)
read_sect(screen,8)
music_far(screen, 9)
music(screen, 11)
read_sect(screen,12)
music_half(screen, 13)
music(screen, 14)
read_sect(screen,15)

music_far(screen, 16+0)
music(screen, 16+2)
read_sect(screen, 16+3)
music_far(screen, 16+4)
music(screen, 16+6)
read_sect(screen, 16+7)
music_far(screen, 16+8)
music(screen, 16+10)
read_sect(screen, 16+11)
music_half(screen, 16+12)
music(screen, 16+13)
read_sect(screen, 16+14)
music_far(screen, 16+15)

music(screen, 32+1)
read_sect(screen, 32+2)
music_far(screen, 32+3)
music(screen, 32+5)
read_sect(screen, 32+6)
music_far(screen, 32+7)
music(screen, 32+9)
read_sect(screen, 32+10)
music_half(screen, 32+11)
music(screen, 32+12)
read_sect(screen, 32+13)
music_far(screen, 32+14)


music(screen, 48+0)
read_sect(screen, 48+1)
music_far(screen, 48+2)
music(screen, 48+4)
read_sect(screen, 48+5)
music_far(screen, 48+6)
music(screen, 48+8)
read_sect(screen, 48+9)

music_far(screen, 48+10)
music_far(screen, 48+12)
music_far(screen, 48+14)

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

for c in commands:
    print( f"    .byte {c.name}")
