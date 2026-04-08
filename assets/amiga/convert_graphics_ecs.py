from PIL import Image,ImageOps
import os,sys,bitplanelib

from shared import *










all_tile_cluts = False


nb_colors = 16





try:
    with open(used_graphics_dir / "used_sprites","rb") as f:
        for index in range(NB_SPRITES):
            d = f.read(NB_SPRITE_CLUTS)
            cluts = [i for i,c in enumerate(d) if c]
            if cluts:
                add_tile(sprite_cluts,index,cluts=cluts)

except OSError:
    print("Cannot find used_sprites")

# remove title tiles cluts
for i in range(0x64,0x7D):
    if i!=0x7B and sprite_cluts.get(i):
        sprite_cluts[i] = []

print_unused_sprites(sprite_cluts)

if all_tile_cluts:
    tile_cluts = None
else:
    try:
        with open(used_graphics_dir / "used_tiles","rb") as f:
            for index in range(NB_TILES):
                d = f.read(NB_TILE_CLUTS)
                cluts = [i for i,c in enumerate(d) if c]
                if cluts:
                    add_tile(tile_cluts,index,cluts=cluts)
    except OSError:
        pass

# add full letters & digits for 3 cluts
# missed some
used_cluts = set()

alphanum_tile_codes = list(range(0,10))+list(range(ord('A'),ord('Z')+1))
for atc in alphanum_tile_codes:
    cluts = tile_cluts.get(atc)
    if cluts:
        used_cluts.update(cluts)
for atc in alphanum_tile_codes:
    tile_cluts[atc] = sorted(used_cluts)





if dump_it:
    if not all_tile_cluts:
        with open(dump_dir / "used_sprites.json","w") as f:
            sprite_cluts_dict = {hex(k):[hex(x) for x in v] for k,v in sprite_cluts.items() if v}
            json.dump(sprite_cluts_dict,f,indent=2)
        with open(dump_dir / "used_tiles.json","w") as f:
            tile_cluts_dict = {hex(k):[hex(x) for x in v] for k,v in tile_cluts.items() if v}
            json.dump(tile_cluts_dict,f,indent=2)

def replace_colors(set_list,rep_dict):
    for ts in set_list:
        for i,t in enumerate(ts):
            if t:
                bitplanelib.replace_color_from_dict(ts[i],rep_dict)



title_pic = Image.open(sheets_path / "title.png")

sprite_sheet_dict = {i:Image.open(sheets_path / "sprites" / f"pal_{i:02x}.png") for i in range(NB_SPRITE_CLUTS)}
tile_sheet_dict = {i:Image.open(sheets_path / "tiles" / f"pal_{i:02x}.png") for i in range(0x1B)}

tile_palette = set()
tile_set_list = []

for i,tsd in tile_sheet_dict.items():
    tp,tile_set,_ = load_tileset(tsd,i,8,8,"tiles",dump_dir,dump=dump_it,
    cluts=tile_cluts,
    name_dict=None)
    tile_set_list.append(tile_set)
    tile_palette.update(tp)

# 5 tile colors aren't found in sprite colors, but there are very close
# colors, so we can replace them without anyone noticing and it means that the
# game can be 16 colors not 32!
tile_color_rep_dict = {(255,151,255):(222,104,255),
(16,32,48):(0,0,0),  # same as Dig Dug 2!
(255,222,174):(222,222,255),  #(255,151,174),
(0,255,0):(0,184,81),
(0,222,255):(33,104,255),
}

replace_colors(tile_set_list,tile_color_rep_dict)
# pad

sprite_palette = set()
sprite_set_list = [[] for _ in range(NB_SPRITE_CLUTS)]
sprite_set_list_x_size = [[] for _ in range(NB_SPRITE_CLUTS)]
hw_sprite_set_list = [[] for _ in range(NB_SPRITE_CLUTS)]

sprite_dump_dir = dump_dir / "sprites"

for p in sprite_dump_dir.glob("*"):
    p.unlink()
sprite_dump_dir.mkdir(exist_ok=True)

cluts = sprite_cluts

for clut_index,tsd in sprite_sheet_dict.items():
    # BOBs

    sp,sprite_set,sprite_set_x_size = load_tileset(tsd,clut_index,16,16,"sprites",dump_dir,dump=dump_it,
    name_dict=sprite_names,cluts=sprite_cluts,is_bob=True)
    sprite_set_list[clut_index] = sprite_set
    sprite_set_list_x_size[clut_index] = sprite_set_x_size
    sprite_palette.update(sp)

# no need to change anything in sprite colors
sprite_color_rep_dict = {}
replace_colors(sprite_set_list,sprite_color_rep_dict)
replace_colors(sprite_set_list_x_size,sprite_color_rep_dict)



sprite_palette = sorted([sprite_color_rep_dict.get(c,c) for c in sprite_palette])
magi = sprite_palette.index(magenta)
sprite_palette.pop(magi)
# temporary: put magenta as first color to be able to decode the frames properly
sprite_palette.insert(0,magenta)

print(f"Used sprite colors: {len(sprite_palette)}")
sprite_palette += (16-len(sprite_palette)) * [(0x10,0x20,0x30)]

# sprite_set_list is now a 16x512 matrix of sprite tiles

    # Hardware sprites
##    cluts = hw_sprite_cluts
##    _,hw_sprite_set = load_tileset(tsd,i,16,"hw_sprites",dump_dir,dump=dump_it,name_dict=sprite_names,cluts=cluts)
##    hw_sprite_set_list.append(hw_sprite_set)


full_palette = sprite_palette

nb_total = len(set(full_palette))

print(f"Number of unique total colors (tiles+sprites) {nb_total}")

# pad just in case we don't have 16 colors
full_palette += (nb_colors-len(full_palette)) * [(0x10,0x20,0x30)]





tile_plane_cache = {}
tile_table,_ = read_tileset(tile_set_list,sprite_palette,[True,False,False,False],cache=tile_plane_cache, is_bob=False)

bob_plane_cache = {}

sprite_table,next_cache_id = read_tileset(sprite_set_list,sprite_palette,[True,False,True,False],cache=bob_plane_cache, is_bob=True)
sprite_table_x_size,next_cache_id = read_tileset(sprite_set_list_x_size,sprite_palette,[True,False,True,False],cache=bob_plane_cache, is_bob=True,next_cache_id=next_cache_id)


title_bitplane_data = bitplanelib.palette_image2raw(title_pic,None,sprite_palette,generate_mask=True,mask_color=magenta)

full_title,next_cache_id = split_bitplane_data(title_bitplane_data,nb_planes+1,bob_plane_cache,title_pic.size[0]//8 + 2,title_pic.size[1],0,next_cache_id)




bitplanelib.palette_dump(tile_palette,dump_dir / "tile_palette.png",pformat=bitplanelib.PALETTE_FORMAT_PNG)
bitplanelib.palette_dump(sprite_palette,dump_dir / "sprite_palette.png",pformat=bitplanelib.PALETTE_FORMAT_PNG)

mixed_palette = sorted(set(tile_palette) | set(sprite_palette))
bitplanelib.palette_dump(sprite_palette,dump_dir / "mixed_palette.png",pformat=bitplanelib.PALETTE_FORMAT_PNG)

specific_tile_colors = sorted(set(tile_palette) - set(sprite_palette))
bitplanelib.palette_dump(specific_tile_colors,dump_dir / "tiles_only_palette.png",pformat=bitplanelib.PALETTE_FORMAT_PNG)
with open(os.path.join(ecs_src_dir,"palette.68k"),"w") as f:
    full_palette_black = [(0,0,0)]+full_palette[1:]
    bitplanelib.palette_dump(full_palette_black,f,bitplanelib.PALETTE_FORMAT_ASMGNU)
write_output(ecs_src_dir,tile_table,sprite_table,sprite_table_x_size,bob_plane_cache,tile_plane_cache,full_title)
