from PIL import Image,ImageOps
import pathlib

# MAME gfx save edition is cool but cannot differentiate background color from black.
# this is pretty f**ing annoying, fortunately, there's always a CLUT in the set which makes the difference
# here it's monochrome palette index 0xD that saves us.

# here there's actually no problem, as there are no real black color used for sprites
# dark colors are (0,17,0) and (17,0,17)

this_dir = pathlib.Path(__file__).absolute().parent

dst_sprite_dir = this_dir / "sheets" / "sprites"

tile_width = 16
tile_height = 16



magenta = (254,0,254)
black = (0,0,0)

src = dst_sprite_dir / "pal_00.png"

magenta_pixels = set()
# this image is fixed using auto & manual processing
src_image = Image.open(src)
for y in range(src_image.size[1]):
    for x in range(src_image.size[0]):
        p = src_image.getpixel((x,y))
        if p==magenta:
            magenta_pixels.add((x,y))

# now do the same to the others: if magenta, apply
for i in range(1,16):
    imgname = f"pal_{i:02X}.png"

    dst = dst_sprite_dir / imgname
    dst_image = Image.new("RGB",src_image.size)
    dst_image.paste(src_image)

    for x,y in magenta_pixels:
        dst_image.putpixel((x,y),magenta)


    dst_image.save(dst)
