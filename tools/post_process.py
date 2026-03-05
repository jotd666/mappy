from shared import *
import re

# post-conversion automatic patches, allowing not to change the asm file by hand

sound_mem_regex = re.compile("\w+_(40[45]\w)")

input_dict = {"system_3300":"read_system_inputs",
"watchdog_8000":"",
"video_stuff_5009" : "",
"video_stuff_5008" : "",
"video_stuff_5002" : "",
"video_stuff_5003" : "",
"video_stuff_5004" : "",
"video_stuff_500b" : "",
"video_stuff_500a" : ""


}




def get_line_address(line):
    try:
        toks = line.split("|")
        address = toks[1].strip(" [$").split(":")[0]
        return int(address,16)
    except (ValueError,IndexError):
        return None

write_to_48xx = {0xFFA4,
0xAA87,0xFC87,
0xFC8A,
0xFC8D,
0xFF0A,


}
context_save = {0xc322,
0xc575,
0xcad0,
0xcbb4,
0xcdea,
0xd08a,
0xd096,
0xf042
}
# various dirty but at least automatic patches applying on the specific track and field code
equates_re = re.compile("(\w+)\s*=\s*(\S+)")
with open(source_dir / "conv.s") as f:
    lines = list(f)
    i = 0

    while i < len(lines):
        line = lines[i]
        m = equates_re.match(line)
        if m:
            equates.append(line)
            line = ""

##        # remove code for rom checks, watchdog, ...
##        for p in ("[rom_check_code]","coin_","watchdog_3300"):
##            line = remove_code(p,lines,i)

        # pre-add video_address tag if we find a store instruction to an explicit 3000-3FFF address
        if store_to_video.search(line):
            line = line.rstrip() + " [video_address]\n"


        if "[unchecked_address" in line:
            line = line.replace("_ADDRESS","_UNCHECKED_ADDRESS")
        if "[video_address" in line:
            # give me the original instruction
            line = line.replace("_ADDRESS","_UNCHECKED_ADDRESS")
            # if it's a write, insert a "VIDEO_DIRTY" macro after the write
            for j in range(i+1,len(lines)):
                next_line = lines[j]
                if "[...]" not in next_line:
                    break
                if ",(a0)" in next_line or "clr" in next_line or "MOVE_W_FROM_REG" in next_line:
                    if any(x in next_line for x in ["address_word","MOVE_W_FROM_REG"]):
                        lines[j] = next_line+"\tVIDEO_WORD_DIRTY | [...]\n"
                    else:
                        lines[j] = next_line+"\tVIDEO_BYTE_DIRTY | [...]\n"
                    break


        line = re.sub(tablere,subt,line)

        address = get_line_address(line)

        if address in context_save:
            # code does a PULS D to get caller address
            line = change_instruction("POP_ENCODED_CALLER_ADDRESS\td1",lines,i)
##        elif address in write_to_48xx:
##            line = remove_instruction(lines,i)
        elif address in [0xf80d,0xf80f,0xF812]:
            # remove write to read location of dip switches. We're not an emulator
            # we don't handle read/writes on I/O
            line = remove_instruction(lines,i)
        elif address == 0xa04a:
            # encode address before writing to 1400
            line = "\tmove.l\t#l_aa7e,d2\n\tENCODE_ADDRESS\td2,d2  | encode the address else it's wrongly decoded!\n"
        elif address == 0xA96B:
            # code does a PULS D to get caller address
            line = change_instruction("POP_ENCODED_CALLER_ADDRESS\td4",lines,i)
        elif address == 0xd08f:
            # remove the MAKE_D that destroys D1 value
            if "MAKE_D" in lines[i-1]:
                lines[i-1] = ""
        if address == 0xD01F:
            # add mid-code label
            line = "mid_code_base:\n"+line
        elif address in [0xF7E5,0xF7F8]:
            # remove I/O tests that lead to fatal errors
            line = remove_instruction(lines,1)

        elif address == 0xf285:
            lines[i-1]=""  # remove subq
            # make up for subq, without changing carry/x flag
            line = change_instruction("GET_REG_ADDRESS\t-1,d2",lines,i,continuing_lines=False)
            lines[i+2] = remove_error(lines[i+2])
        elif address == 0xf28a:
            lines[i-1]=""  # remove subq
            # make up for subq, without changing carry/x flag
            line = change_instruction("GET_REG_ADDRESS\t-2,d2",lines,i,continuing_lines=False)
            lines[i+3] = remove_error(lines[i+3])
        elif address == 0xf28f:
            line = change_instruction("subq\t#2,d2",lines,i)
        ################# fix the stray C test ###########
        if address in [0xe32c,0xe342,0xe356,0x0f33b]:
            # save C
            line = "\tscs\td6\n"+line
        elif address in [0xC276,0xC4E6,0xC1DE]:
            # grunts & boss & timeout boss have separate tests
            line = "\ttst.b\tinvincible_flag\n\tjeq\t0f\n\trts\n0:\n"+line
        elif address == 0xbc5b:
            line = "\tGET_DP_ADDRESS\tlevel_number_31\n\tmove.b\tstart_level,(a0)\n"+line
        elif address == 0xe32e:
            # test C
            line = "\ttst.b\td6\n"+change_instruction("jeq\tl_e331",lines,i)
            lines[i+1] = remove_error(lines[i+1])
        elif address == 0xe344:
            # test C
            line = "\ttst.b\td6\n"+change_instruction("jne\tl_e35c",lines,i)
            lines[i+1] = remove_error(lines[i+1])
        if address == 0xe358:
            # test C
            line = "\ttst.b\td6\n"+change_instruction("jeq\tl_e348",lines,i)
            lines[i+1] = remove_error(lines[i+1])
        if address == 0xf33d:
            # test C
            line = "\ttst.b\td6\n"+change_instruction("jeq\tl_f346",lines,i)
            lines[i+1] = remove_error(lines[i+1])
        ###################################################
        if address == 0xA05F:
            # replace stack push by target stack push, game needs that and changes that
            line = change_instruction("GET_REG_ADDRESS\t0,d5",lines,i) + "\tmove.w\td2,-(a0)  | pushing on target stack\n"
        if address == 0xa063:
            # replace stack pull by target stack pull, game needs that and changes that
            line = change_instruction("GET_REG_ADDRESS\t0,d5",lines,i) + "\tmove.w\t(-2,a0),d2  | pulling from target stack\n"
        if address in [0xfa4e,0xe94b]:
            line = line.replace("move.w\t#","lea\t")
            line = line.replace(",d",",a")
        if "indirect jsr" in line:
            # decode original argument again (dirty!!)
            offset,register = line.split(":")[1].split()[1].strip("[]$").split(",")
            if not offset:
                offset = "0"
            m68k_reg = "d4" if register == "u" else "d2"  # only u and x
            line = change_instruction(f"JSR_INDIRECT\t0x{offset},{m68k_reg}",lines,i)

        # address E4D8 is written several times to resume context here, we have to encode the real address there!

        if "[function_address]" in line:
            # we have to patch this code as it takes an immediate value which
            # is actually an address
            inst,arg = line.split("|")[1].strip().strip("[]").split(":")[1].split("]")[0].split()
            if inst!="ldd" or ",d1" in line:
                dest_reg = {"d":"d1","u":"d4","x":"d2","y":"d3"}[inst[2]]  # d,u,x
                dest_addr = arg[2:]
                line = change_instruction(f"move.l\t#l_{dest_addr},{dest_reg}",lines,i)
                line += f"\tENCODE_ADDRESS\t{dest_reg},{dest_reg}\n"
                if inst=="ldd" and "MAKE_D" in lines[i+1]:
                    lines[i+1] = ""

##        if address in [0xA5A2,0xBD63] and ",d1" in line:
##            line = change_instruction("move.l\t#l_e4d8,d1",lines,i)+"\tENCODE_ADDRESS    D1,D1\n"
##            if :
##                lines[i+1] = ""
##        elif address in [0xBD23,0xCAC9] and ",d1" in line:
##            line = change_instruction("move.l\t#l_ca3c,d1",lines,i)+"\tENCODE_ADDRESS    D1,D1\n"
##            if "MAKE_D" in lines[i+1]:
##                lines[i+1] = ""
##
##        elif address in [0xBCF7,0xBDF9]:
##            line = change_instruction("move.l\t#l_e4d8,d4",lines,i)+"\tENCODE_ADDRESS    D4,D4\n"
##        elif address in [0xAB41]:
##            line = change_instruction("move.l\t#l_e4d8,d2",lines,i)+"\tENCODE_ADDRESS    D2,D2\n"

        if "GET_ADDRESS" in line:
            val = line.split()[1]
            osd_call = input_dict.get(val)
            if osd_call is not None:
                if osd_call:
                    line = change_instruction(f"jbsr\tosd_{osd_call}",lines,i)
                else:
                    line = remove_instruction(lines,i)
                lines[i+1] = remove_instruction(lines,i+1)

            # remove all writes into namco register area
##            if val[-5:-2] == "_48" and "|" in line:
##                orig = line.split("|")[1].split()
##                if orig[1] in ["sta","clr"]:  # write operation
##                    line = remove_instruction(lines,i)




        elif "unsupported instruction rti" in line:
            line = change_instruction("rts",lines,i)

        elif    ".long" in line:
            # check if it's not a parameter of function_and_args_table_d020
            toks = line.split()
            if toks[1].startswith("l_1"):
                # it's a parameter
                v = toks[1][2:]
                line = f"\t.word\t0x{v}\n"
        elif "[indirect_jump]" in line:
            m = jmpre.search(line)
            if m:
                ireg = m.group(2).upper()  # A or B
                inst = m.group(1).upper()
                reg = {"x":"A2","y":"A3","u":"A4"}[m.group(3)]
                rest = re.sub(".*\"","",line)
                nb_cases = int(line.split("nb_entries=")[1].strip(']\n'))
                line = f"\t{inst}_{ireg}_INDEXED\t{reg},{nb_cases}{rest}"

        m = sound_mem_regex.search(line)
        if m:
            toks = line.split()
            if "inc" in toks:
                # INC sound_44xx: enabling sfx
                lines[i+1] += "\tjbsr\tplay_sound\n"
            elif "sta" in toks or "stb" in toks:
                # STA sound_44xx: enabling or disabling sfx
                lines[i+1] += "\tjbsr\tsound_control\n"
        if "ERROR" in line:
            print(line,end="")
        lines[i] = line
        i+=1




with open(source_dir / "data.inc","w") as fw:
    fw.writelines(equates)

with open(source_dir / "mappy.68k","w") as fw:
    fw.write("""\t.include "data.inc"
\t.global\tirq_ff01
\t.global\tself_tests_over_f768

.global    l_a098
.global    l_c000
.global    l_c013
.global    l_c029
.global    l_c04b
.global    l_c0ea
.global    l_c108
.global    l_c123
.global    l_c1e1
.global    l_c328
.global    l_c395
.global    l_c57b
.global    l_c5db
.global    l_c638
.global    l_c6db
.global    l_ce19
.global    l_c81a
.global    l_ca00
.global    l_cad6
.global    l_cbba
.global    l_ce80
.global    l_ccd3
.global    l_cd22
.global    l_c7e5
.global    l_cf81
.global    animate_hurry_up_cfd0
.global mid_code_base

play_sound:
    move.l  d0,-(a7)
    move.l  a0,d0
    sub.l   a6,d0
    sub.w   #0x4040,d0
    jbsr    osd_sound_start
    move.l  (a7)+,d0
    rts

sound_control:
    tst.b   d0
    jeq     0f
    jbsr    play_sound
0:
    rts

""")
    fw.writelines(lines)