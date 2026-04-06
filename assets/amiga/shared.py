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

def get_double_size_y_sprites():
    return {0x32:False,0x7c:False}
def get_double_size_x_sprites():
    return {0x34:True,0x35:True}

    game_grouped = {0X59,0x5D,0x64,0x5c,0x61,0x65,0x60,0x75}  # fire spitting dragon, flame, hose
    extra_grouped = {0x3C,0xE0,0xE2,0xE6,0xE8,0xEA}  # will speed up display
    rval = {x:True for x in game_grouped}
    rval.update({x:False for x in extra_grouped})
    return rval

def get_double_size_xy_sprites():
    return {0x50:False,0x54:False,0x64:False,0x68:False,0x6c:False,0x70:False,0x74:False}

def get_mirror_sprites():
    """ return the index of the sprites that need mirroring
"""
    rval = set(range(0,0x200))
    return rval


def add_tile(table,index,cluts=[0]):
    if isinstance(index,range):
        pass
    elif not isinstance(index,(list,tuple)):
        index = [index]
    for idx in index:
        table[idx] = cluts

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


if __name__ == "__main__":
    raise Exception("no main!")