from PIL import Image,ImageOps
import os,sys,bitplanelib,subprocess,json,pathlib

this_dir = pathlib.Path(__file__).absolute().parent

data_dir = this_dir / ".." / ".."
src_dir = this_dir / ".." / ".." / "src" / "amiga"
aga_src_dir = src_dir / "aga"
ecs_src_dir = src_dir / "ecs"
ocs_src_dir = src_dir / "ocs"

sheets_path = this_dir / ".." / "sheets"
dump_dir = this_dir / "dumps"

used_sprite_cluts_file = this_dir / "used_sprite_cluts.json"
used_tile_cluts_file = this_dir / "used_tile_cluts.json"
used_graphics_dir = this_dir / "used_graphics"


plane_orientations = [("standard",lambda x:x),
("flip",ImageOps.flip),
("mirror",ImageOps.mirror),
("flip_mirror",lambda x:ImageOps.flip(ImageOps.mirror(x)))]

sprite_cluts = {}
tile_cluts = {}



def get_double_size_y_sprites():
    return {0x32:False,0x7c:False}
def get_double_size_x_sprites():
    return {0x34:True,0x35:True}


def get_double_size_xy_sprites():
    return {0x50:False,0x54:False,0x64:False,0x68:False,0x6c:False,0x70:False,0x74:False}

def get_mirror_sprites():
    """ return the index of the sprites that need mirroring
"""
    rval = set(range(0,0x200))
    return rval

def set_names(rval,start,end,name):
    rval.update({i:name for i in range(start,end)})

def get_sprite_names():

    rval = dict()

    set_names(rval,0x0,0x8,"mouse")
    set_names(rval,0x18,0x1C,"mouse")
    set_names(rval,0x58,0x60,"mouse")
    set_names(rval,0x8,0x10,"nyamco")
    set_names(rval,0x10,0x18,"cat")
    set_names(rval,0x7E,0x80,"nyamco")
    set_names(rval,0x38,0x40,"boss")
    set_names(rval,0x28,0x32,"score")
    set_names(rval,0x20,0x25,"loot")
    set_names(rval,0x40,0x4C,"big_score")
    set_names(rval,0x4C,0x4E,"baloon")
    set_names(rval,0x50,0x55,"nyamco_baloon")
    set_names(rval,0x25,0x27,"bell")
    rval[0x4e] = "music_note"
    rval[0x27] = "nyamco_hiding"
    rval[0x4f] = "score_1000"
    rval[0x7B] = "cat"
    rval[0x32] = "microwave"
    rval[0x34] = "hurry"
    rval[0x35] = "game_over"



    return rval

def print_unused_sprites(sprite_cluts):
    known_unused = {0x3E,0x36,0X51,0x52,0x53,0x55,0x56,0x57,0x33,0x37,0x1c,0x1d,0x1e,0x1f,
                0x60,0x61,0x62,0x63,0x66,0x67,0x6a,0x6b,0x6d,0x6e,0x64,0x65,0x68,0x69,0x6c,0x70,0x74,0x78,0x7c,
                0x6f,0x71,0x72,0x73,0x75,0x76,0x77,0x79,0x7a,0x7d}
    unused_sprite_codes = {i for i in range(0,0x80) if not sprite_cluts.get(i) and i not in known_unused}
    # includes double width/height
    if unused_sprite_codes:
        print("unused sprite codes:")
        print(",".join(f"0x{x:02x}" for x in sorted(unused_sprite_codes)))

def get_possible_hw_sprites():

    dsy_sprites = get_double_size_y_sprites()
    dsx_sprites = get_double_size_x_sprites()
    dsxy_sprites = get_double_size_xy_sprites()
    possible_hw_sprites = set()
    sprite_names = get_sprite_names()
    for i in range(0,0x80):
        if i not in dsx_sprites and i not in dsxy_sprites:
            name = sprite_names.get(i,"unknown")
            # nyamco hiding must be behind loot BOBs, can't use a HW sprite
            if name != "nyamco_hiding" and any(x in name for x in ("cat","mouse","nyamco")):
                possible_hw_sprites.add(i)
    return possible_hw_sprites


def dump_asm_bytes(*args,**kwargs):
    bitplanelib.dump_asm_bytes(*args,**kwargs,mit_format=True)


def ensure_empty(d):
    if os.path.exists(d):
        for f in os.listdir(d):
            os.remove(os.path.join(d,f))
    else:
        os.makedirs(d)

def palette_pad(palette,pad_nb):
    palette += (pad_nb-len(palette)) * [(0x10,0x20,0x30)]

def ensure_empty(d):
    if os.path.exists(d):
        for f in os.listdir(d):
            x = os.path.join(d,f)
            if os.path.isfile(x):
                os.remove(x)
    else:
        os.makedirs(d)

def ensure_exists(d):
    if os.path.exists(d):
        pass
    else:
        os.makedirs(d)

sr2 = lambda a,b : set(range(a,b,2))

player_sprite_pairs = ()
player_single_sprites = {}

group_sprite_pairs = ()
# most sprites are eligible to hw sprites except X-sized (>16)
# we have to include them all for priority reasons. Hoses can be an exception as they're mostly behind
possible_hw_sprites = get_possible_hw_sprites()
#{i for i in range(0,0x100) if i not in dsx_sprites and i not in dsxy_sprites and not i in range(0x70,0x7C)}



def add_tile(table,index,cluts=[0]):
    if isinstance(index,range):
        pass
    elif not isinstance(index,(list,tuple)):
        index = [index]
    for idx in index:
        table[idx] = cluts

def split_bitplane_data(bitplane_data,actual_nb_planes,cache,width,height,y_start,next_cache_id):
    plane_size = len(bitplane_data) // actual_nb_planes
    bitplane_plane_ids = []
    for j in range(actual_nb_planes):
        offset = j*plane_size
        bitplane = bitplane_data[offset:offset+plane_size]

        cache_id = cache.get(bitplane)
        if cache_id is not None:
            bitplane_plane_ids.append(cache_id)
        else:
            if any(bitplane):
                cache[bitplane] = next_cache_id
                bitplane_plane_ids.append(next_cache_id)
                next_cache_id += 1
            else:
                bitplane_plane_ids.append(0)  # blank
    return {"width":width,"height":height,"y_start":y_start,"bitplanes":bitplane_plane_ids},next_cache_id

def load_tileset(image_name,palette_index,width,height,tileset_name,dumpdir,
dump=False,name_dict=None,cluts=None,tile_number=0,is_bob=False):

##    if isinstance(image_name,str):
##        full_image_path = os.path.join(this_dir,os.path.pardir,"sheets",
##                            tile_type,image_name)
##        tiles_1 = Image.open(full_image_path)
##    else:
    tiles_1 = image_name
    nb_rows = tiles_1.size[1] // height
    nb_cols = tiles_1.size[0] // width


    tileset_1 = []
    tileset_xsize = []
    if dump:
        dump_subdir = os.path.join(dumpdir,tileset_name)
        if palette_index == 0 and tile_number == 0:
            ensure_empty(dump_subdir)

    palette = set()

    # first read ALL data
    for j in range(nb_rows):
        for i in range(nb_cols):
            img = Image.new("RGB",(width,height))
            img.paste(tiles_1,(-i*width,-j*height))
            tileset_1.append(img)
            tileset_xsize.append(None)

    other_tile_failure = False
    # now we can rework it
    if not is_bob:
        for tile_number,img in enumerate(tileset_1):
            if cluts is not None and (tile_number not in cluts or palette_index not in cluts[tile_number]):
                # no clut declared for that tile
                tileset_1[tile_number] = None
            else:

                # only consider colors of used tiles
                palette.update(set(bitplanelib.palette_extract(img)))

                # dump tiles not bobs (must group by size first)
                if dump:
                    img = ImageOps.scale(img,5,resample=Image.Resampling.NEAREST)
                    if name_dict:
                        name = name_dict.get(tile_number,"unknown")
                    else:
                        name = "unknown"

                    img.save(os.path.join(dump_subdir,f"{name}_{tile_number:02x}_{palette_index:02x}.png"))

    else:
        # rework & dump grouped / non grouped sprites
        # rework tiles which are grouped
        #
        # special case for horiz grouped tiles
        # do not display grouped unless

        for tile_number,wtile in enumerate(tileset_1):

            # special case for X-grouped:
            # 1) some tiles can be displayed X-grouped or not
            # (not the case with Y-grouped or XY-grouped) so we have to
            # create another tileset array for those
            if wtile and tile_number in dsx_sprites:
                new_tile = Image.new("RGB",(wtile.size[0]*2,wtile.size[1]))
                from_game = dsx_sprites[tile_number]
                if from_game:
                    # change wtile, fetch code +2
                    other_tile_index = tile_number+2
                else:
                    # extra grouping, helps faster display too
                    other_tile_index = tile_number+1

                other_tile = tileset_1[other_tile_index]

                if from_game:
                    new_tile.paste(wtile,(wtile.size[1],0))
                    new_tile.paste(other_tile)

                    tileset_xsize[tile_number] = new_tile
                else:
                    # normal grouping with next tile (artificial, not coded by graphic driver)
                    new_tile.paste(wtile)
                    new_tile.paste(other_tile,(wtile.size[1],0))

                    tileset_1[tile_number] = new_tile
                    tileset_1[other_tile_index] = None  # discard
                wtile = new_tile

            if wtile and tile_number in dsy_sprites:
                # change wtile, fetch code +1
                other_tile_index = tile_number+1
                other_tile = tileset_1[other_tile_index]
                if not other_tile:
                    print(f"warn: other tile index 0x{other_tile_index:02x} not found (palette ${palette_index:x})")
                    other_tile_failure = True
                new_tile = Image.new("RGB",(wtile.size[0],wtile.size[1]*2))

                new_tile.paste(wtile)
                if other_tile:
                    new_tile.paste(other_tile,(0,wtile.size[1]))
                tileset_1[tile_number] = new_tile
                tileset_1[other_tile_index] = None  # discard
                wtile = new_tile
            if wtile and tile_number in dsxy_sprites:
                # change wtile, fetch code +1
                new_tile = Image.new("RGB",(wtile.size[0]*2,wtile.size[1]*2))

                new_tile.paste(wtile,(wtile.size[0],0))
                new_tile.paste(tileset_1[tile_number+1],(wtile.size[0],wtile.size[1]))
                new_tile.paste(tileset_1[tile_number+2],(0,0))
                new_tile.paste(tileset_1[tile_number+3],(0,wtile.size[1]))

                tileset_1[tile_number] = new_tile
                tileset_1[tile_number+1] = None  # discard
                tileset_1[tile_number+2] = None  # discard
                tileset_1[tile_number+3] = None  # discard
                wtile = new_tile

            if wtile:
                palette.update(set(bitplanelib.palette_extract(wtile)))

            if cluts is not None and (tile_number not in cluts or palette_index not in cluts[tile_number]):
                # no clut declared for that tile: cancel it
                tileset_1[tile_number] = None
                wtile = None

            if dump_it and wtile:
                img = ImageOps.scale(wtile,5,resample=Image.Resampling.NEAREST)
                if sprite_names:
                    name = sprite_names.get(tile_number,"unknown")
                else:
                    name = "unknown"

                img.save(os.path.join(dump_subdir,f"{name}_{tile_number:02x}_{palette_index:02x}.png"))


    return sorted(set(palette)),tileset_1,tileset_xsize


def read_tileset(img_set_list,palette,plane_orientation_flags,cache,is_bob,next_cache_id=1):
    tile_table = []
    for n,img_set in enumerate(img_set_list):
        tile_entry = []
        for i,tile in enumerate(img_set):
            entry = dict()
            if tile:

                for b,(plane_name,plane_func) in zip(plane_orientation_flags,plane_orientations):
                    if b:

                        bitplane_sprite_data = None
                        actual_nb_planes = nb_planes


                        wtile = plane_func(tile)

                        if is_bob:
                            actual_nb_planes += 1


                            # only 4 planes + mask => 5 planes
                            orig_wtile = wtile
                            y_start,wtile = bitplanelib.autocrop_y(wtile,mask_color=magenta)

                            height = wtile.size[1]
                            width = wtile.size[0]//8 + 2
                            bitplane_data = bitplanelib.palette_image2raw(wtile,None,palette,generate_mask=True,mask_color=magenta)

                            if i in possible_hw_sprites:
                                # using original, uncropped bitplane data to create 16x16 or 16x32 hw sprite
                                bitplane_sprite_data = bitplanelib.palette_image2attached_sprites(orig_wtile,None,palette,with_control_words=True)

                        else:
                            # 4 planes, no mask
                            height = 8
                            width = 1
                            y_start = 0
                            bitplane_data = bitplanelib.palette_image2raw(wtile,None,palette)

                        e,next_cache_id = split_bitplane_data(bitplane_data,actual_nb_planes,cache,width,height,y_start,next_cache_id)

                        entry[plane_name] = e
                        if bitplane_sprite_data:
                            entry[plane_name]["sprdat"] = bitplane_sprite_data

            tile_entry.append(entry)

        tile_table.append(tile_entry)

    # transpose
    new_tile_table = [[[] for _ in range(NB_SPRITE_CLUTS if is_bob else NB_TILE_CLUTS)] for _ in range(len(tile_table[0]))]

    # reorder/transpose. We have 16 * 256 we need 256 * 16
    for i,u in enumerate(tile_table):
        for j,v in enumerate(u):
            new_tile_table[j][i] = v

    return new_tile_table,next_cache_id


def write_output(src_dir,tile_table,sprite_table,sprite_table_x_size,bob_plane_cache,tile_plane_cache,full_title):

    loot = [0]*0x80
    for k,v in get_sprite_names().items():
        if "loot" in v:
            loot[k] = 1

    with open(src_dir/"loot_sprites.68k","w") as f:
        bitplanelib.dump_asm_bytes(loot,f,mit_format=True)

    with open(src_dir/"graphics.68k","w") as f:
        f.write("\t.global\tcharacter_table\n")
        f.write("\t.global\ttitle_pic\n")
        f.write("\t.global\thws_table\n")
        f.write("\t.global\tbob_table\n")
        f.write("\t.global\tbob_table_x_size\n")

        f.write("character_table:\n")

        for i,tile_entry in enumerate(tile_table):
            f.write("\t.long\t")
            if tile_entry and any(tile_entry):
                f.write(f"tile_{i:02x}")
            else:
                f.write("0")
            f.write("\n")

        for i,tile_entry in enumerate(tile_table):
            if tile_entry and any(tile_entry):
                f.write(f"tile_{i:02x}:\n")
                for j,t in enumerate(tile_entry):
                    f.write("\t.long\t")
                    if t:
                        f.write(f"tile_{i:02x}_{j:02x}")
                    else:
                        f.write("0")
                    f.write("\n")


        for i,tile_entry in enumerate(tile_table):
            if tile_entry and any(tile_entry):
                for j,t in enumerate(tile_entry):
                    if t:
                        name = f"tile_{i:02x}_{j:02x}"

                        f.write(f"{name}:\n")
                        for orientation,_ in plane_orientations:
                            f.write("* orientation={}\n".format(orientation))
                            if orientation in t:
                                data = t[orientation]
                                for bitplane_id in data["bitplanes"]:
                                    f.write("\t.long\t")
                                    if bitplane_id:
                                        f.write(f"tile_plane_{bitplane_id:02d}")
                                    else:
                                        f.write("0")
                                    f.write("\n")
                                if len(t)==1:
                                    # optim: only standard
                                    break
                            else:
                                for _ in range(nb_planes):
                                    f.write("\t.long\t0\n")



        for k,v in tile_plane_cache.items():
            f.write(f"tile_plane_{v:02d}:")
            dump_asm_bytes(k,f)

        sprite_table_no_size = sprite_table
        for sprite_table,suffix in [(sprite_table_no_size,""),(sprite_table_x_size,"_x_size")]:
            f.write(f"bob_table{suffix}:\n")
            for i,tile_entry in enumerate(sprite_table):
                f.write("\t.long\t")
                if any(tile_entry):
                    prefix = sprite_names.get(i,"bob")
                    f.write(f"{prefix}_{i:02x}{suffix}")
                else:
                    f.write("0")
                f.write("\n")


            for i,tile_entry in enumerate(sprite_table):
                if any(tile_entry):
                    prefix = sprite_names.get(i,"bob")
                    f.write(f"{prefix}_{i:02x}{suffix}:\n")
                    for j,t in enumerate(tile_entry):
                        f.write("\t.long\t")
                        if t:
                            f.write(f"{prefix}_{i:02x}_{j:02x}{suffix}")
                        else:
                            f.write("0")
                        f.write("\n")


            for i,tile_entry in enumerate(sprite_table):
                if tile_entry:
                    prefix = sprite_names.get(i,"bob")
                    for j,t in enumerate(tile_entry):
                        if t:
                            name = f"{prefix}_{i:02x}_{j:02x}{suffix}"

                            f.write(f"{name}:\n")
                            height = 0

                            offset = 0
                            for orientation,_ in plane_orientations:
                                if orientation in t:
                                    width = t[orientation]["width"]
                                    height = t[orientation]["height"]
                                    offset = t[orientation]["y_start"]
                                    break
                            else:
                                raise Exception(f"height not found for {name}!!")
                            for orientation,_ in plane_orientations:
                                if orientation in t:
                                    f.write("* orientation={}\n".format(orientation))
                                    active_planes = 0
                                    bitplanes = t[orientation]["bitplanes"]

                                    for j,bitplane_id in enumerate(bitplanes):
                                        if bitplane_id:
                                            active_planes |= 1<<j

                                    f.write(f"\t.word\t{height},{width},{offset},0x{active_planes:x}\n")
                                    for bitplane_id in bitplanes:
                                        f.write("\t.long\t")
                                        if bitplane_id:
                                            f.write(f"bob_plane_{bitplane_id:02d}")
                                        else:
                                            f.write("0")
                                        f.write("\n")
                                elif orientation == "mirror":
                                    f.write(f"\t.word\t-1  | no mirror declared\n")


        f.write("hws_table:\n")
        for i,tile_entry in enumerate(sprite_table_no_size):
            for orientation in ['standard','mirror']:
                f.write("\t.long\t")
                if possible_hw_sprites and any(t and "sprdat" in t[orientation] for t in tile_entry):
                    prefix = sprite_names.get(i,"bob")
                    prefix = f"hws_{prefix}_{i:02x}_{orientation}"
                    f.write(prefix)
                else:
                    f.write("0")
                f.write("\n")

        # HW sprites clut declaration
        for i,tile_entry in enumerate(sprite_table_no_size):
            for orientation in ['standard','mirror']:
                if any(t and "sprdat" in t[orientation] for t in tile_entry):
                    prefix = sprite_names.get(i,"bob")
                    f.write(f"hws_{prefix}_{i:02x}_{orientation}:\n")
                    for j,t in enumerate(tile_entry):
                        f.write("\t.long\t")
                        if t:
                            z = f"hws_{prefix}_{i:02x}_{j:02x}_{orientation}"
                            f.write(f"{z}_0,{z}_1")
                        else:
                            f.write("0,0")
                        f.write("\n")

        # special case title pic
        f.write("\n* special case:\ntitle_pic:\n")
        offset = full_title["y_start"]
        height = full_title["height"]
        width = full_title["width"]
        active_planes = 0x1F
        f.write(f"\t.word\t{height},{width},{offset},0x{active_planes:x}\n")
        for bitplane_id in full_title["bitplanes"]:
            f.write("\t.long\t")
            if bitplane_id:
                f.write(f"bob_plane_{bitplane_id:02d}")
            else:
                f.write("0")
            f.write("\n")

        f.write("\n\t.section\t.datachip\n")

        for k,v in bob_plane_cache.items():
            f.write(f"bob_plane_{v:02d}:")
            dump_asm_bytes(k,f)

        if possible_hw_sprites:
            for i,tile_entry in enumerate(sprite_table_no_size):
                for orientation in ['standard','mirror']:
                    if any(t and "sprdat" in t[orientation] for t in tile_entry):
                        prefix = sprite_names.get(i,"bob")
                        for j,t in enumerate(tile_entry):

                            if t:
                                data = t[orientation]["sprdat"]
                                for k,d in enumerate(data):
                                    f.write(f"hws_{prefix}_{i:02x}_{j:02x}_{orientation}_{k}:")
                                    bitplanelib.dump_asm_bytes(d,f,mit_format=True)
                                f.write("\n")

def add_hw_sprite(index,name,cluts=[0]):
    if isinstance(index,range):
        pass
    elif not isinstance(index,(list,tuple)):
        index = [index]
    for idx in index:
        sprite_names[idx] = name
        hw_sprite_cluts[idx] = cluts

sprite_names = get_sprite_names()

mirror_sprites = get_mirror_sprites()

magenta = (254,0,254)

NB_SPRITES = 0x100
NB_TILES = 0x100


NB_SPRITE_CLUTS = 16
NB_TILE_CLUTS = 64

nb_planes = 4

dsy_sprites = get_double_size_y_sprites()
dsx_sprites = get_double_size_x_sprites()
dsxy_sprites = get_double_size_xy_sprites()

dump_it = True

if dump_it:
    if not os.path.exists(dump_dir):
        os.mkdir(dump_dir)
        with open(os.path.join(dump_dir,".gitignore"),"w") as f:
            f.write("*")

if __name__ == "__main__":
    raise Exception("no main!")