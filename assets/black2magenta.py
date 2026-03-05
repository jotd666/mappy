from PIL import Image,ImageOps
import pathlib

# MAME gfx save edition is cool but cannot differentiate background color from black.
# this is pretty f**ing annoying, fortunately, there's always a CLUT in the set which makes the difference
# here it's monochrome palette index 0xD that saves us.

# here there's actually no problem, as there are no real black color used for sprites
# dark colors are (0,17,0) and (17,0,17)

this_dir = pathlib.Path(__file__).absolute().parent

src_sprite_dir = this_dir / "sheets" / "sprites_black"
dst_sprite_dir = this_dir / "sheets" / "sprites"

tile_width = 16
tile_height = 16

##class ImageForestFireFill:
##    def __init__(self,image,fill_color):
##        self.image = image
##    def set_color(x,y)
##    def fill(self, x, y, t):
##        if self.cells[(x,y)] is None:  # cannot use not: there are 0 values
##            to_fill = [(x,y)]
##            while to_fill:
##                # pick a point from the queue
##                x,y = to_fill.pop()
##                # change color if possible
##                self.cells[(x,y)] = t
##
##                # now the neighbours x,y +- 1
##                for delta_x in range(-1,2):
##                    xdx = x+delta_x
##                    if xdx > 0 and xdx < self.columns+1:
##                        for delta_y in range(-1,2):
##                            ydy = y+delta_y
##                            # avoid diagonals
##                            if (delta_x == 0) ^ (delta_y == 0):
##                                if ydy > 0 and ydy < self.rows+1:
##                                    # valid x+delta_x,y+delta_y
##                                    # push in queue if no color
##                                    if self.cells[(xdx,ydy)] == None:
##                                        to_fill.append((xdx,ydy))

magenta = (254,0,254)
black = (0,0,0)

def transform(dst_image,x,y,nonblack_met):
    p = dst_image.getpixel((x,y))
    if not nonblack_met:
        if p == black or p == magenta:  # X/Y pass, second time there's already magenta
            p = magenta  # black => magenta but not full magenta to avoid conflicts
        else:
            nonblack_met = True
        dst_image.putpixel((x,y),p)
    return nonblack_met

for i in range(16):
    imgname = f"pal_{i:02X}.png"
    src = src_sprite_dir / imgname
    dst = dst_sprite_dir / imgname

    src_image = Image.open(src)
    dst_image = Image.new("RGB",src_image.size)
    dst_image.paste(src_image)

    for y in range(dst_image.size[1]):
        # first pass left to right, stop at the first non-black
        for xstart in range(0,dst_image.size[0],tile_width):
            nonblack_met = False
            for x in range(xstart,xstart+tile_width):
                nonblack_met = transform(dst_image,x,y,nonblack_met)
            nonblack_met = False
            for x in reversed(range(xstart,xstart+tile_width)):
                nonblack_met = transform(dst_image,x,y,nonblack_met)

    for x in range(dst_image.size[0]):
        for ystart in range(0,dst_image.size[1],tile_height):
            nonblack_met = False
            for y in range(ystart,ystart+tile_height):
                nonblack_met = transform(dst_image,x,y,nonblack_met)
            nonblack_met = False
            for y in reversed(range(ystart,ystart+tile_height)):
                nonblack_met = transform(dst_image,x,y,nonblack_met)

    # now scan the whole picture and "forest fire" the image if we encounter magenta (not black!)
    # it means that some edge reached magenta. Now only closed surfaces can remain black
    # also some black in the edges have to be reworked

    # pass 1 get black pixels
    black_pixels = set()
    for y in range(dst_image.size[1]):
        for x in range(dst_image.size[0]):
            p = dst_image.getpixel((x,y))
            if p==black:
                black_pixels.add((x,y))

    # pass 2 if magenta somewhere change to black, iterate

    while True:
        new_blacks = black_pixels.copy()
        found = False
        for x,y in black_pixels:
            for dx in [-1,0,1]:
                for dy in [-1,0,1]:
                    if dx ^ dy: # avoid diagonals
                        if 0 <= x+dx < dst_image.size[0] and 0 <= y+dy < dst_image.size[1]:
                            # within image bounds
                            p = dst_image.getpixel((x+dx,y+dy))
                            if p==magenta:
                                # this pixel becomes transparent as it was beside a magenta pixel
                                dst_image.putpixel((x,y),magenta)
                                new_blacks.discard((x,y))
                                found = True
        if not found:
            # didn't find any more candidates
            break
        # start again with reduced list
        black_pixels = new_blacks


    dst_image.save(dst)
