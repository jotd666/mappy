# crop full "mappy" title from snapshot, saves tile displaying
# solves transparent problem and solves corrupt tile problem on some
# tiles (super strange!)
from PIL import Image,ImageOps
import pathlib



this_dir = pathlib.Path(__file__).absolute().parent

sheets_dir = this_dir / "sheets"

img = Image.open(sheets_dir /"title_snap.png")
img = img.crop((9+16,64+8,201,64+48))
# no transparency, leave black
##for x in range(img.size[0]):
##    for y in range(img.size[1]):
##        p = img.getpixel((x,y))
##        if p == (0,0,0):
##            img.putpixel((x,y),(254,0,254))
img.save (sheets_dir / "title.png")
print(img.size)