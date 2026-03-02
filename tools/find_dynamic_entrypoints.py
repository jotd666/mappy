import re

imm = re.compile("#\$(\w\w\w\w)")

found = set()
with open("../src/mappy_6809.asm") as f, open("../src/mappy_6809_x.asm","w") as fw:
    lines = list(f)
    address_set = set()
    for line in lines:
        addr = line.split(":")[0]
        if len(addr)==4:
            v = int(addr,16)
            address_set.add(v)

    for line in lines:
        if "function_address" not in line:

            m = imm.search(line)
            if m:
                imm_target = int(m.group(1),16)
                # filter out A000, C000, E000 which are addresses but just for checksum
                if "000" not in m.group(1) and imm_target in address_set:
                    line = line.rstrip() + " ; [function_address]\n"
        fw.write(line)