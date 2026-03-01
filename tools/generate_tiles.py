# pre-process for tiles, as I generally use the tile sheets that mame gfx save
# dumps. Here there are 64 cluts, and the gfx save features only saves 32 sheets
# so we have to rebuild them. It's not very difficult when the palette is properly dumped
import glob,shutil,os,re,pathlib
from PIL import Image
from shared import *

import gen_cluts

tilegen = gfx_dir / "tilegen"

ref_clut_index = 10
pal4_file = tilegen / f"pal_{ref_clut_index:02x}.png"


# theoritically: could generate 64 tilemaps (like in RallyX) but only 25 maps are non black (0->0x19 but not 8)
# and clut 8 is fully black (I have still included it for simplicity sake for the convert_graphics_xxx.py tool)
cluts = gen_cluts.doit()

source = Image.open(pal4_file)
# this reference clut has all 4 colors different. We can use that to generate
# the other cluts (mame gfx save only saves up to 32 cluts, we need 64)
ref_clut = cluts[ref_clut_index]
for i in range(0,64):
    this_clut = cluts[i]
    if len(set(this_clut))>1:
        dest = Image.new("RGB",source.size)
        # black becomes magenta
        rep_dict = {k:v for k,v in zip(ref_clut,this_clut)}

        dest_file = gfx_dir / "tiles" / f"pal_{i:02x}.png"
        if i==ref_clut_index:
            shutil.copy(pal4_file,dest_file)
        else:
            for x in range(source.size[0]):
                for y in range(source.size[1]):
                    pix = source.getpixel((x,y))
                    newpix = rep_dict[pix]

                    dest.putpixel((x,y),newpix)
            dest.save(dest_file)