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
            line = change_instruction("POP_ENCODED_CALLER_ADDRESS_IN_D",lines,i)

        if address == 0xD01F:
            # add mid-code label
            line = "mid_code_base:\n"+line

        ################# fix the stray C test ###########
        if address in [0xe32c,0xe342,0xe356,0x0f33b]:
            # save C
            line = "\tscs\td6\n"+line
        if address == 0xe32e:
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

        if "GET_ADDRESS" in line:
            val = line.split()[1]
            osd_call = input_dict.get(val)
            if osd_call is not None:
                if osd_call:
                    line = change_instruction(f"jbsr\tosd_{osd_call}",lines,i)
                else:
                    line = remove_instruction(lines,i)
                lines[i+1] = remove_instruction(lines,i+1)


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

play_sound:
    move.l  d0,-(a7)
    move.l  a0,d0
    sub.l   a6,d0
    sub.w   #0x403F,d0
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