import re
r = re.compile("JSR\s+\[")
funcs = set()

prev_line_jsr = False
with open(r"K:\Emulation\MAME\mappy.tr") as f:
    for line in f:
        if prev_line_jsr:
            prev_line_jsr = False
            addr = int(line.split(":")[0],0x10)
            funcs.add(addr)
        if r.search(line):
            prev_line_jsr = True

# add the addresses of the table at d020
funcs.update([0xA098,0xC000,0xC013,0xC029,0xC04B,
0xC0EA,0xC108,0xC123,0xC1E1,0xC328,0xC395,0xC57B,
0xC5DB,0xC638,0xC6DB,0xCE19,0xC81A,0xCA00,0xCAD6,
0xCBBA,0xCE80,0xCCD3,0xCD22,0xC7E5,0xCF81,0xCFD0])


table = [0]*(0x10000-0xA000)
for f in funcs:
    table[f-0xA000] = f"l_{f:04x}"

with open("../src/jump_table.68k","w") as f:
    for i,t in enumerate(table,0xA000):
        if t==0:
            f.write(f"\t.long\t0   | ${i:04x}\n")
        else:
            f.write(f"\t.long\t{t}   | valid\n")

found = set()
with open("../src/mappy_6809.asm") as f, open("mappy_6809.asm","w") as fw:
    for line in f:
        addr = line.split(":")[0]
        if len(addr)==4:
            v = int(addr,16)-0xA000
            if table[v]:
                line = table[v] + ":\n" + line
                found.add(table[v])
        fw.write(line)

not_found = set(table)-found-{0}
print("entries not found: ",not_found)
