; mappy is the exact same hw as dig dug 2!!
;	map(0x0000, 0x0fff).ram().w(FUNC(mappy_state::mappy_videoram_w)).share("videoram");
;	map(0x1000, 0x27ff).ram().share("spriteram");   // work RAM with embedded sprite RAM
;   sprites start at stack_top_1780 with 3 buffers of $800 bytes that hold attributes, code and coords
;   64 sprites can be displayed total
;	map(0x3800, 0x3fff).w(FUNC(mappy_state::mappy_scroll_w));   // scroll
;	map(0x4000, 0x43ff).rw(m_namco_15xx, FUNC(namco_15xx_device::sharedram_r), FUNC(namco_15xx_device::sharedram_w));   // shared RAM with the sound CPU
;	map(0x4800, 0x480f).rw("namcoio_1", FUNC(namcoio_device::read), FUNC(namcoio_device::write));   // custom I/O chips interface
;	map(0x4810, 0x481f).rw("namcoio_2", FUNC(namcoio_device::read), FUNC(namcoio_device::write));   // custom I/O chips interface
;	map(0x5000, 0x500f).w("mainlatch", FUNC(ls259_device::write_a0));   // various control bits
;	map(0x8000, 0x8000).w("watchdog", FUNC(watchdog_timer_device::reset_w));
;	map(0x8000, 0xffff).rom();  // only a000-ffff in Mappy

stack_top_1780 = $1780
watchdog_8000 = $8000
video_stuff_5009 = $5009
video_stuff_5008 = $5008
video_stuff_5002 = $5002
video_stuff_5003 = $5003
video_stuff_5004 = $5004
video_stuff_500b = $500B
video_stuff_500a = $500A
function_and_args_table_d020 = $d020
scroll_registers_3800 = $3800
scroll_value_1389 = $1389

; set by namco chip when enough credits, 0: none, 1: 1 player, 2: 2 players
number_of_players_4801 = $4801
credits_tens_4802 = $4802
credits_unit_4803 = $4803
; bit 3 bot both
start_1p_4805 = $4805
start_2p_4807 = $4807
joystick_directions_4804 = $4804
joystick_button_1_4805 = $4805
joystick_button_2_4815 = $4815
io_register_4818 = $4818
namco_io_4800 = $4800

A000: 10 CE 17 80 LDS    #stack_top_1780
A004: CC 00 00    LDD    #$0000
A007: FD 13 E4    STD    $13E4
; install jump table in ram
A00A: 8E D0 20    LDX    #function_and_args_table_d020
A00D: CE 14 00    LDU    #$1400
A010: EC 81       LDD    ,X++
A012: 27 06       BEQ    $A01A
A014: EE 81       LDU    ,X++
A016: ED C4       STD    ,U
A018: 20 F6       BRA    $A010
A01A: 7F 48 09    CLR    $4809
A01D: 4F          CLRA
A01E: B7 13 82    STA    $1382
A021: B6 13 82    LDA    $1382
A024: 27 FB       BEQ    $A021
A026: B6 13 7E    LDA    $137E
A029: 85 08       BITA   #$08
A02B: 10 26 55 47 LBNE   $F576
A02F: 4F          CLRA
A030: B7 13 82    STA    $1382
A033: B6 48 14    LDA    $4814
A036: 85 04       BITA   #$04
A038: 27 02       BEQ    $A03C
A03A: 0C 32       INC    <$32
A03C: B6 13 60    LDA    $1360
A03F: B4 13 81    ANDA   $1381
A042: B7 13 93    STA    $1393
A045: B6 13 71    LDA    $1371
A048: 27 0C       BEQ    $A056
A04A: 8E AA 7E    LDX    #$AA7E
A04D: BF 14 00    STX    $1400
A050: 7F 40 4D    CLR    $404D
A053: 7F 40 4E    CLR    $404E
A056: 8E D0 20    LDX    #function_and_args_table_d020
; call function chain in a loop
A059: EC 81       LDD    ,X++
A05B: 27 0A       BEQ    $A067		; zero: stop calling functions
A05D: EE 81       LDU    ,X++
A05F: 34 10       PSHS   X
; indirect_jump to the value contained in argument (14xx)
; which is equal to value of X, but maybe not all the time
A061: AD D4       JSR    [,U]		
A063: 35 10       PULS   X
A065: 20 F2       BRA    $A059
A067: 7C 10 15    INC    $1015
A06A: B6 10 15    LDA    $1015
A06D: 81 3C       CMPA   #$3C
A06F: 25 0B       BCS    $A07C
A071: 7F 10 15    CLR    $1015
A074: 8E 10 0E    LDX    #$100E
A077: C6 03       LDB    #$03
A079: BD E3 27    JSR    $E327
A07C: B6 10 14    LDA    $1014
A07F: 27 A0       BEQ    $A021
A081: 7C 10 16    INC    $1016
A084: B6 10 16    LDA    $1016
A087: 81 3C       CMPA   #$3C
A089: 25 96       BCS    $A021
A08B: 7F 10 16    CLR    $1016
A08E: 8E 10 0B    LDX    #$100B
A091: C6 03       LDB    #$03
A093: BD E3 27    JSR    $E327
A096: 20 89       BRA    $A021
l_a098:
A098: 86 20       LDA    #$20
A09A: 1F 8B       TFR    A,DP
A09C: BD F3 76    JSR    $F376
A09F: 8E 0F 80    LDX    #$0F80
A0A2: 86 00       LDA    #$00
A0A4: A7 80       STA    ,X+
A0A6: 8C 0F C0    CMPX   #$0FC0
A0A9: 26 F9       BNE    $A0A4
A0AB: 86 43       LDA    #$43
A0AD: A7 80       STA    ,X+
A0AF: 8C 0F E0    CMPX   #$0FE0
A0B2: 26 F9       BNE    $A0AD
A0B4: 86 49       LDA    #$49
A0B6: A7 80       STA    ,X+
A0B8: 8C 10 00    CMPX   #$1000
A0BB: 26 F9       BNE    $A0B6
A0BD: 8E A1 7A    LDX    #$A17A
A0C0: CE 07 D4    LDU    #$07D4
A0C3: BD F3 C3    JSR    $F3C3
A0C6: B6 07 D0    LDA    $07D0
A0C9: B7 07 C0    STA    $07C0
A0CC: B6 07 D1    LDA    $07D1
A0CF: B7 07 C1    STA    $07C1
A0D2: 86 20       LDA    #$20
A0D4: B7 13 86    STA    $1386
A0D7: 7F 13 85    CLR    $1385
A0DA: 7F 13 87    CLR    $1387
A0DD: 8E 07 ED    LDX    #$07ED
A0E0: 6F 80       CLR    ,X+
A0E2: 8C 07 F0    CMPX   #$07F0
A0E5: 26 F9       BNE    $A0E0
A0E7: 4F          CLRA
A0E8: B7 07 E0    STA    $07E0
A0EB: 86 02       LDA    #$02
A0ED: B7 07 E1    STA    $07E1
A0F0: 4F          CLRA
A0F1: B7 07 ED    STA    $07ED
A0F4: B7 07 EE    STA    $07EE
A0F7: B7 07 F7    STA    $07F7
A0FA: B7 07 F8    STA    $07F8
A0FD: 8E C8 12    LDX    #$C812
A100: CE 07 DA    LDU    #$07DA
A103: BD F3 C3    JSR    $F3C3
A106: 8E A1 52    LDX    #$A152
A109: CE 14 60    LDU    #$1460
A10C: 10 8E 00 14 LDY    #$0014
A110: EC 81       LDD    ,X++
A112: ED C1       STD    ,U++
A114: 31 3F       LEAY   -$1,Y
A116: 26 F8       BNE    $A110
A118: B6 48 14    LDA    $4814
A11B: 84 02       ANDA   #$02
A11D: B7 13 A5    STA    $13A5
A120: 8E D2 F3    LDX    #$D2F3
A123: B6 13 63    LDA    $1363
A126: 48          ASLA
A127: AE 86       LDX    A,X
A129: BF 13 AA    STX    $13AA
A12C: BD BC 3A    JSR    $BC3A
A12F: B6 13 72    LDA    $1372
A132: BB 13 73    ADDA   $1373
A135: 27 03       BEQ    $A13A
A137: 7E A9 94    JMP    $A994
A13A: 8E 07 80    LDX    #$0780
A13D: 86 20       LDA    #$20
A13F: A7 80       STA    ,X+
A141: 8C 07 C0    CMPX   #$07C0
A144: 26 F9       BNE    $A13F
A146: BD E0 00    JSR    $E000
A149: B6 13 A5    LDA    $13A5
A14C: B7 41 0C    STA    $410C
A14F: 7E A1 85    JMP    $A185

A185: BD D0 8A    JSR    $D08A                                       
l_a188:
A188: 4F          CLRA
A189: B7 14 02    STA    $1402
A18C: 86 0A       LDA    #$0A
A18E: BD D0 93    JSR    $D093
l_a191:
A191: 86 47       LDA    #$47
A193: BD F3 69    JSR    $F369
A196: 8E 00 00    LDX    #$0000
A199: CC 5D 5D    LDD    #$5D5D
A19C: ED 81       STD    ,X++
A19E: 8C 07 80    CMPX   #$0780
A1A1: 25 F9       BCS    $A19C
A1A3: 86 FF       LDA    #$FF
A1A5: B7 13 89    STA    scroll_value_1389
A1A8: BD D0 8A    JSR    $D08A
l_a1ab:
A1AB: 8E A2 5C    LDX    #$A25C
A1AE: CE 06 83    LDU    #$0683
A1B1: C6 07       LDB    #$07
A1B3: BD F3 D0    JSR    $F3D0
A1B6: 86 1E       LDA    #$1E
A1B8: BD A9 6B    JSR    $A96B
l_a1bb:
A1BB: 8E A2 75    LDX    #$A275
A1BE: CE 11 52    LDU    #$1152
A1C1: EC 81       LDD    ,X++
A1C3: 27 12       BEQ    $A1D7
A1C5: ED C4       STD    ,U
A1C7: EC 81       LDD    ,X++
A1C9: ED C9 00 80 STD    $0080,U
A1CD: A6 80       LDA    ,X+
A1CF: A7 C9 01 00 STA    $0100,U
A1D3: 33 42       LEAU   $2,U
A1D5: 20 EA       BRA    $A1C1
A1D7: 86 07       LDA    #$07
A1D9: BD F3 69    JSR    $F369
A1DC: 86 3C       LDA    #$3C
A1DE: BD A9 6B    JSR    $A96B
l_a1e1:
A1E1: 8E A2 33    LDX    #$A233
A1E4: CE 06 76    LDU    #$0676
A1E7: C6 07       LDB    #$07
A1E9: BD F3 D0    JSR    $F3D0
A1EC: 8E A2 40    LDX    #$A240
A1EF: CE 06 D8    LDU    #$06D8
A1F2: C6 07       LDB    #$07
A1F4: BD F3 D0    JSR    $F3D0
A1F7: 8E A2 54    LDX    #$A254
A1FA: CE 06 1C    LDU    #$061C
A1FD: C6 03       LDB    #$03
A1FF: BD F3 D0    JSR    $F3D0
A202: 8E A2 6C    LDX    #$A26C
A205: CE 02 21    LDU    #$0221
A208: C6 40       LDB    #$40
A20A: BD F3 D0    JSR    $F3D0
A20D: 86 78       LDA    #$78
A20F: BD A9 6B    JSR    $A96B
l_a212:
A212: BD D0 8A    JSR    $D08A
l_a215:
A215: B6 13 89    LDA    scroll_value_1389
A218: 80 02       SUBA   #$02
A21A: B7 13 89    STA    scroll_value_1389
A21D: 81 01       CMPA   #$01
A21F: 10 22 07 62 LBHI   $A985
A223: 7E A2 AE    JMP    $A2AE
A226: C6 16       LDB    #$16
A228: 86 07       LDA    #$07
A22A: A7 84       STA    ,X
A22C: 30 88 E0    LEAX   -$20,X
A22F: 5A          DECB
A230: 26 F8       BNE    $A22A
A232: 39          RTS

A2AE: 86 3C       LDA    #$3C
A2B0: BD A9 6B    JSR    $A96B
l_a2b3:
A2B3: BD A4 2D    JSR    $A42D
A2B6: B6 11 D3    LDA    $11D3
A2B9: 81 7A       CMPA   #$7A
A2BB: 10 25 06 C6 LBCS   $A985
A2BF: 8E 11 1A    LDX    #$111A
A2C2: 86 07       LDA    #$07
A2C4: A7 84       STA    ,X
A2C6: 6F 01       CLR    $1,X
A2C8: 86 79       LDA    #$79
A2CA: A7 89 00 80 STA    $0080,X
A2CE: 86 84       LDA    #$84
A2D0: A7 89 00 81 STA    $0081,X
A2D4: 6F 89 01 00 CLR    $0100,X
A2D8: 6F 89 01 01 CLR    $0101,X
A2DC: 8E FE BA    LDX    #$FEBA
A2DF: CE 02 0C    LDU    #$020C
A2E2: C6 07       LDB    #$07
A2E4: BD F3 D0    JSR    $F3D0
A2E7: BD D0 8A    JSR    $D08A
l_a2ea:
A2EA: BD A4 2D    JSR    $A42D
A2ED: B6 11 D3    LDA    $11D3
A2F0: 81 A0       CMPA   #$A0
A2F2: 10 25 06 8F LBCS   $A985
A2F6: 8E A4 49    LDX    #$A449
A2F9: CE 02 AE    LDU    #$02AE
A2FC: C6 09       LDB    #$09
A2FE: BD F3 D0    JSR    $F3D0
A301: 8E A4 5D    LDX    #$A45D
A304: 33 C8 E0    LEAU   -$20,U
A307: C6 01       LDB    #$01
A309: BD F3 D0    JSR    $F3D0
A30C: 86 3C       LDA    #$3C
A30E: BD A9 6B    JSR    $A96B
l_a311:
A311: BD A4 2D    JSR    $A42D
A314: B6 11 D3    LDA    $11D3
A317: 81 B2       CMPA   #$B2
A319: 10 25 06 68 LBCS   $A985
A31D: 8E 11 1C    LDX    #$111C
A320: 86 0F       LDA    #$0F
A322: A7 84       STA    ,X
A324: 6F 01       CLR    $1,X
A326: 86 7A       LDA    #$7A
A328: A7 89 00 80 STA    $0080,X
A32C: 86 C2       LDA    #$C2
A32E: A7 89 00 81 STA    $0081,X
A332: 6F 89 01 00 CLR    $0100,X
A336: 6F 89 01 01 CLR    $0101,X
A33A: 8E A4 78    LDX    #$A478
A33D: CE 01 F4    LDU    #$01F4
A340: C6 02       LDB    #$02
A342: BD F3 D0    JSR    $F3D0
A345: 86 3C       LDA    #$3C
A347: BD A9 6B    JSR    $A96B
l_a34a:
A34A: BD A4 2D    JSR    $A42D
A34D: B6 11 D3    LDA    $11D3
A350: 81 E0       CMPA   #$E0
A352: 10 25 06 2F LBCS   $A985
A356: 8E A4 49    LDX    #$A449
A359: CE 02 F6    LDU    #$02F6
A35C: C6 09       LDB    #$09
A35E: BD F3 D0    JSR    $F3D0
A361: 8E A4 4C    LDX    #$A44C
A364: 33 C8 E0    LEAU   -$20,U
A367: C6 03       LDB    #$03
A369: BD F3 D0    JSR    $F3D0
A36C: 86 3C       LDA    #$3C
A36E: BD A9 6B    JSR    $A96B
l_a371:
A371: BD A4 2D    JSR    $A42D
A374: B6 11 D3    LDA    $11D3
A377: 81 F2       CMPA   #$F2
A379: 10 26 06 08 LBNE   $A985
A37D: 8E 11 1E    LDX    #$111E
A380: 86 17       LDA    #$17
A382: A7 84       STA    ,X
A384: 6F 01       CLR    $1,X
A386: 86 78       LDA    #$78
A388: A7 89 00 80 STA    $0080,X
A38C: 86 02       LDA    #$02
A38E: A7 89 00 81 STA    $0081,X
A392: 6F 89 01 00 CLR    $0100,X
A396: 86 01       LDA    #$01
A398: A7 89 01 01 STA    $0101,X
A39C: 8E A4 7F    LDX    #$A47F
A39F: CE 02 1C    LDU    #$021C
A3A2: C6 0B       LDB    #$0B
A3A4: BD F3 D0    JSR    $F3D0
A3A7: 86 3C       LDA    #$3C
A3A9: BD A9 6B    JSR    $A96B
l_a3ac:
A3AC: BD A4 2D    JSR    $A42D
A3AF: B6 11 D3    LDA    $11D3
A3B2: 81 22       CMPA   #$22
A3B4: 10 26 05 CD LBNE   $A985
A3B8: 8E A4 49    LDX    #$A449
A3BB: CE 02 BE    LDU    #$02BE
A3BE: C6 09       LDB    #$09
A3C0: BD F3 D0    JSR    $F3D0
A3C3: 8E A4 6A    LDX    #$A46A
A3C6: 33 C8 E0    LEAU   -$20,U
A3C9: C6 0C       LDB    #$0C
A3CB: BD F3 D0    JSR    $F3D0
A3CE: 86 3C       LDA    #$3C
A3D0: BD A9 6B    JSR    $A96B
A3D3: 8D 58       BSR    $A42D
A3D5: B6 11 D3    LDA    $11D3
A3D8: 81 42       CMPA   #$42
A3DA: 10 26 05 A7 LBNE   $A985
A3DE: 86 3C       LDA    #$3C
A3E0: BD A9 6B    JSR    $A96B
A3E3: 8E 11 D3    LDX    #$11D3
A3E6: A6 84       LDA    ,X
A3E8: 8B C2       ADDA   #$C2
A3EA: A7 81       STA    ,X++
A3EC: 6F 88 7E    CLR    $7E,X
A3EF: 8C 11 E9    CMPX   #$11E9
A3F2: 26 F2       BNE    $A3E6
A3F4: BD D0 8A    JSR    $D08A
A3F7: 8D 34       BSR    $A42D
A3F9: B6 11 D3    LDA    $11D3
A3FC: 81 48       CMPA   #$48
A3FE: 10 26 05 83 LBNE   $A985
A402: 86 D2       LDA    #$D2
A404: BD A9 6B    JSR    $A96B
A407: 7F 11 9A    CLR    $119A
A40A: 7F 11 9C    CLR    $119C
A40D: 7F 11 9E    CLR    $119E
A410: BD F3 5B    JSR    $F35B
A413: 4F          CLRA
A414: BD F3 69    JSR    $F369
A417: BD D0 8A    JSR    $D08A
A41A: 8D 11       BSR    $A42D
A41C: B6 11 D3    LDA    $11D3
A41F: 81 78       CMPA   #$78
A421: 10 26 05 60 LBNE   $A985
A425: 86 1E       LDA    #$1E
A427: BD A9 6B    JSR    $A96B
A42A: 7E A4 96    JMP    $A496
A42D: 8E 11 D3    LDX    #$11D3
A430: C6 0B       LDB    #$0B
A432: 34 04       PSHS   B
A434: E6 84       LDB    ,X
A436: A6 89 00 80 LDA    $0080,X
A43A: C3 00 02    ADDD   #$0002
A43D: A7 89 00 80 STA    $0080,X
A441: E7 81       STB    ,X++
A443: 35 04       PULS   B
A445: 5A          DECB
A446: 26 EA       BNE    $A432
A448: 39          RTS

A496: 7F 13 80    CLR    $1380                                      
A499: B7 50 04    STA    $5004                                      
A49C: 86 FF       LDA    #$FF                                       
A49E: B7 13 89    STA    scroll_value_1389                                      
A4A1: BD BC 49    JSR    $BC49                                      
A4A4: BD BC B1    JSR    $BCB1                                      
A4A7: CC 00 28    LDD    #$0028                                     
A4AA: DD 01       STD    <$01                                       
A4AC: 86 A0       LDA    #$A0
A4AE: 97 04       STA    <$04
A4B0: CC 01 00    LDD    #$0100
A4B3: DD 06       STD    <$06
A4B5: CC 02 00    LDD    #$0200
A4B8: DD 08       STD    <$08
A4BA: 86 01       LDA    #$01
A4BC: B7 14 40    STA    $1440
A4BF: 86 00       LDA    #$00
A4C1: B7 14 05    STA    $1405
A4C4: 86 01       LDA    #$01
A4C6: B7 14 41    STA    $1441
A4C9: 86 00       LDA    #$00
A4CB: B7 14 08    STA    $1408
A4CE: 86 01       LDA    #$01
A4D0: BD A9 6B    JSR    $A96B
A4D3: 0F 31       CLR    <$31
A4D5: BD E1 79    JSR    $E179
A4D8: 10 8E D7 12 LDY    #$D712
A4DC: BD E1 D5    JSR    $E1D5
A4DF: BD E2 78    JSR    $E278
A4E2: BD E2 CD    JSR    $E2CD
A4E5: 86 3C       LDA    #$3C
A4E7: BD A9 6B    JSR    $A96B
A4EA: 7C 14 42    INC    $1442
A4ED: 7C 14 48    INC    $1448
A4F0: 86 01       LDA    #$01
A4F2: B7 14 40    STA    $1440
A4F5: 86 08       LDA    #$08
A4F7: B7 14 05    STA    $1405
A4FA: BD D0 8A    JSR    $D08A
A4FD: 96 00       LDA    <$00
A4FF: 81 06       CMPA   #$06
A501: 10 26 04 80 LBNE   $A985
A505: 8E A7 60    LDX    #$A760
A508: CE 06 D1    LDU    #$06D1
A50B: C6 07       LDB    #$07
A50D: BD F3 D0    JSR    $F3D0
A510: 7F 14 42    CLR    $1442
A513: 86 2D       LDA    #$2D
A515: BD A9 6B    JSR    $A96B
A518: 86 01       LDA    #$01
A51A: B7 14 40    STA    $1440
A51D: 86 02       LDA    #$02
A51F: B7 14 05    STA    $1405
A522: 7C 14 42    INC    $1442
A525: BD D0 8A    JSR    $D08A
A528: 96 00       LDA    <$00
A52A: 81 02       CMPA   #$02
A52C: 10 22 04 55 LBHI   $A985
A530: 86 01       LDA    #$01
A532: B7 14 40    STA    $1440
A535: 86 00       LDA    #$00
A537: B7 14 05    STA    $1405
A53A: 8E A7 5B    LDX    #$A75B
A53D: CE 05 D3    LDU    #$05D3
A540: C6 00       LDB    #$00
A542: BD F3 D0    JSR    $F3D0
A545: 7F 06 13    CLR    $0613
A548: C6 02       LDB    #$02
A54A: F7 0E 13    STB    $0E13
A54D: 86 01       LDA    #$01
A54F: B7 06 33    STA    $0633
A552: F7 0E 33    STB    $0E33
A555: 86 5A       LDA    #$5A
A557: BD A9 6B    JSR    $A96B
A55A: 8E A7 60    LDX    #$A760
A55D: CE 06 D1    LDU    #$06D1
A560: BD FE AA    JSR    $FEAA
A563: 8E A7 60    LDX    #$A760
A566: CE 06 33    LDU    #$0633
A569: BD FE AA    JSR    $FEAA
A56C: 86 1E       LDA    #$1E
A56E: BD A9 6B    JSR    $A96B
A571: 8E A7 32    LDX    #$A732
A574: CE 06 D1    LDU    #$06D1
A577: C6 07       LDB    #$07
A579: BD F3 D0    JSR    $F3D0
A57C: 7C 14 49    INC    $1449
A57F: 86 1E       LDA    #$1E
A581: BD A9 6B    JSR    $A96B
A584: 8E 22 30    LDX    #$2230
A587: 6F 80       CLR    ,X+
A589: 8C 22 60    CMPX   #$2260
A58C: 26 F9       BNE    $A587
A58E: 86 FE       LDA    #$FE
A590: A7 84       STA    ,X
A592: CE 22 30    LDU    #$2230
A595: 86 10       LDA    #$10
A597: A7 C8 18    STA    $18,U
A59A: A7 4A       STA    $A,U
A59C: CC 11 1E    LDD    #$111E
A59F: ED C8 19    STD    $19,U
A5A2: CC E4 D8    LDD    #$E4D8
A5A5: ED 4E       STD    $E,U
A5A7: CC C2 28    LDD    #$C228
A5AA: ED C8 21    STD    $21,U
A5AD: CC 00 90    LDD    #$0090
A5B0: ED 41       STD    $1,U
A5B2: 86 E0       LDA    #$E0
A5B4: A7 44       STA    $4,U
A5B6: CC 01 00    LDD    #$0100
A5B9: ED 46       STD    $6,U
A5BB: C3 00 E0    ADDD   #$00E0
A5BE: ED 48       STD    $8,U
A5C0: 86 08       LDA    #$08
A5C2: A7 4D       STA    $D,U
A5C4: 86 F0       LDA    #$F0
A5C6: B7 13 DD    STA    $13DD
A5C9: 7C 14 44    INC    $1444
A5CC: BD D0 8A    JSR    $D08A
A5CF: B6 22 30    LDA    $2230
A5D2: 81 0B       CMPA   #$0B
A5D4: 27 06       BEQ    $A5DC
A5D6: 81 0C       CMPA   #$0C
A5D8: 10 26 03 A9 LBNE   $A985
A5DC: 86 0A       LDA    #$0A
A5DE: BD A9 6B    JSR    $A96B
A5E1: 86 35       LDA    #$35
A5E3: B7 06 33    STA    $0633
A5E6: C6 02       LDB    #$02
A5E8: F7 0E 33    STB    $0E33
A5EB: 86 30       LDA    #$30
A5ED: B7 06 13    STA    $0613
A5F0: F7 0E 13    STB    $0E13
A5F3: 8E A7 5B    LDX    #$A75B
A5F6: CE 05 D3    LDU    #$05D3
A5F9: C6 00       LDB    #$00
A5FB: BD F3 D0    JSR    $F3D0
A5FE: 86 5A       LDA    #$5A
A600: BD A9 6B    JSR    $A96B
A603: 8E A7 32    LDX    #$A732
A606: CE 06 D1    LDU    #$06D1
A609: BD FE AA    JSR    $FEAA
A60C: 8E A7 60    LDX    #$A760
A60F: CE 06 33    LDU    #$0633
A612: BD FE AA    JSR    $FEAA
A615: 86 01       LDA    #$01
A617: B7 14 40    STA    $1440
A61A: 86 02       LDA    #$02
A61C: B7 14 05    STA    $1405
A61F: BD D0 8A    JSR    $D08A
A622: DC 01       LDD    <$01
A624: 10 83 00 8D CMPD   #$008D
A628: 10 23 03 59 LBLS   $A985
A62C: 86 01       LDA    #$01
A62E: B7 14 40    STA    $1440
A631: 86 00       LDA    #$00
A633: B7 14 05    STA    $1405
A636: 7C 14 4A    INC    $144A
A639: BD D0 8A    JSR    $D08A
A63C: 86 01       LDA    #$01
A63E: B7 14 41    STA    $1441
A641: 86 01       LDA    #$01
A643: B7 14 08    STA    $1408
A646: BD D0 8A    JSR    $D08A
A649: 9E 12       LDX    <$12
A64B: A6 84       LDA    ,X
A64D: 10 26 03 34 LBNE   $A985
A651: 8E A7 43    LDX    #$A743
A654: CE 05 B1    LDU    #$05B1
A657: C6 07       LDB    #$07
A659: BD F3 D0    JSR    $F3D0
A65C: 86 01       LDA    #$01
A65E: B7 14 40    STA    $1440
A661: 86 08       LDA    #$08
A663: B7 14 05    STA    $1405
A666: BD D0 8A    JSR    $D08A
A669: 86 01       LDA    #$01
A66B: B7 14 40    STA    $1440
A66E: 86 00       LDA    #$00
A670: B7 14 05    STA    $1405
A673: BD D0 8A    JSR    $D08A
A676: B6 12 80    LDA    $1280
A679: 81 05       CMPA   #$05
A67B: 10 25 03 06 LBCS   $A985
A67F: 7F 14 4A    CLR    $144A
A682: 8E A7 4D    LDX    #$A74D
A685: CE 05 F3    LDU    #$05F3
A688: C6 00       LDB    #$00
A68A: BD F3 D0    JSR    $F3D0
A68D: 7F 14 44    CLR    $1444
A690: BD D0 8A    JSR    $D08A
A693: 7F 11 9E    CLR    $119E
A696: 86 5A       LDA    #$5A
A698: BD A9 6B    JSR    $A96B
A69B: 8E A7 43    LDX    #$A743
A69E: CE 05 B1    LDU    #$05B1
A6A1: BD FE AA    JSR    $FEAA
A6A4: 8E A7 4D    LDX    #$A74D
A6A7: CE 05 F3    LDU    #$05F3
A6AA: BD FE AA    JSR    $FEAA
A6AD: 86 1E       LDA    #$1E
A6AF: BD A9 6B    JSR    $A96B
A6B2: 7C 14 46    INC    $1446
A6B5: 7C 14 47    INC    $1447
A6B8: 86 14       LDA    #$14
A6BA: BD A9 6B    JSR    $A96B
A6BD: 8E 20 40    LDX    #$2040
A6C0: 9F 27       STX    <$27
A6C2: 86 01       LDA    #$01
A6C4: B7 14 40    STA    $1440
A6C7: 86 02       LDA    #$02
A6C9: B7 14 05    STA    $1405
A6CC: BD D0 8A    JSR    $D08A
A6CF: 96 00       LDA    <$00
A6D1: 81 06       CMPA   #$06
A6D3: 10 26 02 AE LBNE   $A985
A6D7: 86 01       LDA    #$01
A6D9: B7 14 40    STA    $1440
A6DC: 86 00       LDA    #$00
A6DE: B7 14 05    STA    $1405
A6E1: BD D0 8A    JSR    $D08A
A6E4: 96 04       LDA    <$04
A6E6: 81 C0       CMPA   #$C0
A6E8: 10 22 02 99 LBHI   $A985
A6EC: 86 01       LDA    #$01
A6EE: B7 14 40    STA    $1440
A6F1: 86 08       LDA    #$08
A6F3: B7 14 05    STA    $1405
A6F6: BD D0 8A    JSR    $D08A
A6F9: 96 32       LDA    <$32
A6FB: 10 27 02 86 LBEQ   $A985
A6FF: 7F 14 42    CLR    $1442
A702: 86 1E       LDA    #$1E
A704: BD A9 6B    JSR    $A96B
A707: 8E A2 33    LDX    #$A233
A70A: CE 04 F0    LDU    #$04F0
A70D: C6 07       LDB    #$07
A70F: BD F3 D0    JSR    $F3D0
A712: 8E A2 40    LDX    #$A240
A715: CE 05 52    LDU    #$0552
A718: C6 07       LDB    #$07
A71A: BD F3 D0    JSR    $F3D0
A71D: 8E A2 54    LDX    #$A254
A720: CE 04 94    LDU    #$0494
A723: C6 03       LDB    #$03
A725: BD F3 D0    JSR    $F3D0
A728: 86 B4       LDA    #$B4
A72A: BD A9 6B    JSR    $A96B
A72D: 0F 32       CLR    <$32
A72F: 7E A7 73    JMP    $A773

 ;  WHEN HIT BY DOOR
 ;  /MICROWAVE/MYSTE
 ;  RY SCORE/PTS_/JU
 ;  MP ON TRAMPOLINE
 ;
A773: 86 10       LDA    #$10                                         
A775: B7 14 02    STA    $1402                                        
A778: BD F3 5B    JSR    $F35B
A77B: BD F3 AA    JSR    $F3AA
A77E: 4F          CLRA
A77F: BD F3 69    JSR    $F369
A782: 86 01       LDA    #$01
A784: B7 14 40    STA    $1440
A787: 86 00       LDA    #$00
A789: B7 14 05    STA    $1405
A78C: 86 01       LDA    #$01
A78E: B7 14 41    STA    $1441
A791: 86 00       LDA    #$00
A793: B7 14 08    STA    $1408
A796: 86 05       LDA    #$05
A798: BD A9 6B    JSR    $A96B
A79B: 86 18       LDA    #$18
A79D: B7 13 89    STA    scroll_value_1389
A7A0: BD BC 49    JSR    $BC49
A7A3: FE 13 AA    LDU    $13AA
A7A6: 34 40       PSHS   U
A7A8: CE D3 03    LDU    #$D303
A7AB: FF 13 AA    STU    $13AA
A7AE: BD BC AC    JSR    $BCAC
A7B1: 35 40       PULS   U
A7B3: FF 13 AA    STU    $13AA
A7B6: CC 01 9C    LDD    #$019C
A7B9: DD 01       STD    <$01
A7BB: BD D0 8A    JSR    $D08A
A7BE: BD E1 01    JSR    $E101
A7C1: BD E0 68    JSR    $E068
A7C4: 8E 11 72    LDX    #$1172
A7C7: 86 35       LDA    #$35
A7C9: 5F          CLRB
A7CA: ED 84       STD    ,X
A7CC: CC 72 D3    LDD    #$72D3
A7CF: ED 89 00 80 STD    $0080,X
A7D3: CC 08 00    LDD    #$0800
A7D6: ED 89 01 00 STD    $0100,X
A7DA: 86 1E       LDA    #$1E
A7DC: BD A9 6B    JSR    $A96B
A7DF: 7C 14 46    INC    $1446
A7E2: 86 1E       LDA    #$1E
A7E4: BD A9 6B    JSR    $A96B
A7E7: 7C 14 44    INC    $1444
A7EA: 7C 14 45    INC    $1445
A7ED: BD D0 8A    JSR    $D08A
A7F0: 7A 14 44    DEC    $1444
A7F3: 7A 14 45    DEC    $1445
A7F6: 86 1E       LDA    #$1E
A7F8: BD A9 6B    JSR    $A96B
A7FB: 7C 14 42    INC    $1442
A7FE: 86 1E       LDA    #$1E
A800: BD A9 6B    JSR    $A96B
A803: BD BC 34    JSR    $BC34
A806: 7F 14 4C    CLR    $144C
A809: 7F 14 4D    CLR    $144D
A80C: 8E A8 8E    LDX    #$A88E
A80F: BF 13 A3    STX    $13A3
A812: A6 01       LDA    $1,X
A814: B7 13 A2    STA    $13A2
A817: BD D0 8A    JSR    $D08A
A81A: 7A 13 A2    DEC    $13A2
A81D: 26 21       BNE    $A840
A81F: BE 13 A3    LDX    $13A3
A822: 30 02       LEAX   $2,X
A824: BF 13 A3    STX    $13A3
A827: A6 84       LDA    ,X
A829: 81 FF       CMPA   #$FF
A82B: 10 27 00 C8 LBEQ   $A8F7
A82F: 85 01       BITA   #$01
A831: 26 05       BNE    $A838
A833: B7 14 05    STA    $1405
A836: 20 03       BRA    $A83B
A838: B7 14 08    STA    $1408
A83B: A6 01       LDA    $1,X
A83D: B7 13 A2    STA    $13A2
A840: 96 33       LDA    <$33
A842: 10 27 01 3F LBEQ   $A985
A846: 86 19       LDA    #$19
A848: B7 11 1A    STA    $111A
A84B: BD BC 3A    JSR    $BC3A
A84E: 86 64       LDA    #$64
A850: BD A9 6B    JSR    $A96B
A853: BD F3 83    JSR    $F383
A856: 0F 17       CLR    <$17
A858: BD D0 8A    JSR    $D08A
A85B: 0C 17       INC    <$17
A85D: 96 17       LDA    <$17
A85F: 81 48       CMPA   #$48
A861: 22 09       BHI    $A86C
A863: 44          LSRA
A864: 84 07       ANDA   #$07
A866: 8B 58       ADDA   #$58
A868: B7 11 1A    STA    $111A
A86B: 39          RTS
A86C: BD D0 8A    JSR    $D08A
A86F: C6 1A       LDB    #$1A
A871: 0C 17       INC    <$17
A873: 96 17       LDA    <$17
A875: 81 68       CMPA   #$68
A877: 22 09       BHI    $A882
A879: 85 02       BITA   #$02
A87B: 26 01       BNE    $A87E
A87D: 5C          INCB
A87E: F7 11 1A    STB    $111A
A881: 39          RTS
A882: BD D0 8A    JSR    $D08A
A885: 86 3C       LDA    #$3C
A887: BD A9 6B    JSR    $A96B
A88A: 0F 33       CLR    <$33
A88C: 20 69       BRA    $A8F7

A8F7: BD F3 5B    JSR    $F35B
A8FA: BD F3 AA    JSR    $F3AA
A8FD: 86 FF       LDA    #$FF
A8FF: B7 13 89    STA    scroll_value_1389
A902: BD E3 83    JSR    $E383
A905: 86 1E       LDA    #$1E
A907: 8D 62       BSR    $A96B
A909: BD D0 8A    JSR    $D08A
A90C: B6 13 89    LDA    scroll_value_1389
A90F: 80 02       SUBA   #$02
A911: B7 13 89    STA    scroll_value_1389
A914: 81 13       CMPA   #$13
A916: 26 6D       BNE    $A985
A918: 8E 0B 4F    LDX    #$0B4F
A91B: BF 14 8C    STX    $148C
A91E: 86 01       LDA    #$01
A920: B7 13 98    STA    $1398
A923: 7F 13 B5    CLR    $13B5
A926: 86 4B       LDA    #$4B
A928: B7 13 B2    STA    $13B2
A92B: BD D0 8A    JSR    $D08A
A92E: BD BB E8    JSR    $BBE8
A931: B6 13 B2    LDA    $13B2
A934: 26 4F       BNE    $A985
A936: BE 14 8C    LDX    $148C
A939: CC 02 17    LDD    #$0217
A93C: A7 84       STA    ,X
A93E: 30 88 E0    LEAX   -$20,X
A941: 5A          DECB
A942: 26 F8       BNE    $A93C
A944: BE 14 8C    LDX    $148C
A947: 30 03       LEAX   $3,X
A949: BF 14 8C    STX    $148C
A94C: 8C 0B 5E    CMPX   #$0B5E
A94F: 25 CA       BCS    $A91B
A951: 86 3C       LDA    #$3C
A953: 8D 16       BSR    $A96B
A955: BD D0 8A    JSR    $D08A
A958: B6 13 89    LDA    scroll_value_1389
A95B: 8B 02       ADDA   #$02
A95D: B7 13 89    STA    scroll_value_1389
A960: 81 FF       CMPA   #$FF
A962: 26 21       BNE    $A985
A964: 86 3C       LDA    #$3C
A966: 8D 03       BSR    $A96B
A968: 7E A1 85    JMP    $A185
A96B: 35 40       PULS   U
A96D: FF 13 99    STU    $1399
A970: B7 13 B2    STA    $13B2
A973: BD D0 8A    JSR    $D08A
l_a976:
A976: B6 13 B2    LDA    $13B2
A979: 26 0A       BNE    $A985
A97B: FE 17 7E    LDU    $177E
A97E: FC 13 99    LDD    $1399
A981: ED D8 FE    STD    [-$02,U]
A984: 39          RTS
A985: B6 48 03    LDA    credits_unit_4803
A988: 84 0F       ANDA   #$0F
A98A: 26 08       BNE    $A994
A98C: B6 48 02    LDA    credits_tens_4802
A98F: 84 0F       ANDA   #$0F
A991: 26 01       BNE    $A994
A993: 39          RTS
A994: BD BC 3A    JSR    $BC3A
A997: BD D0 8A    JSR    $D08A
l_a99a:
A99A: 86 20       LDA    #$20
A99C: B7 14 02    STA    $1402
A99F: 7F 41 0C    CLR    $410C
A9A2: B7 50 04    STA    $5004
A9A5: BD F3 AA    JSR    $F3AA
A9A8: BD F3 5B    JSR    $F35B
A9AB: 86 00       LDA    #$00
A9AD: BD F3 69    JSR    $F369
A9B0: 86 FF       LDA    #$FF
A9B2: B7 13 89    STA    scroll_value_1389
A9B5: BD D0 8A    JSR    $D08A
l_a9b8:
A9B8: 86 05       LDA    #$05
A9BA: BD E1 0D    JSR    $E10D
A9BD: 8E AA 36    LDX    #$AA36
A9C0: CE 03 09    LDU    #$0309
A9C3: C6 00       LDB    #$00
A9C5: BD F3 D0    JSR    $F3D0
A9C8: 8E AA 48    LDX    #$AA48
A9CB: CE 02 CC    LDU    #$02CC
A9CE: C6 02       LDB    #$02
A9D0: BD F3 D0    JSR    $F3D0
A9D3: 8E D4 03    LDX    #$D403
A9D6: F6 13 65    LDB    $1365
A9D9: 58          ASLB
A9DA: AE 85       LDX    B,X
A9DC: A6 84       LDA    ,X
A9DE: 27 1C       BEQ    $A9FC
A9E0: CE 03 90    LDU    #$0390
A9E3: BD F3 EB    JSR    $F3EB
A9E6: A6 01       LDA    $1,X
A9E8: 27 18       BEQ    $AA02
A9EA: CE 03 92    LDU    #$0392
A9ED: BD F3 F9    JSR    $F3F9
A9F0: A6 80       LDA    ,X+
A9F2: 27 0E       BEQ    $AA02
A9F4: CE 03 94    LDU    #$0394
A9F7: BD F4 30    JSR    $F430
A9FA: 20 06       BRA    $AA02
A9FC: CE 03 90    LDU    #$0390
A9FF: BD F3 E2    JSR    $F3E2
AA02: 8E A2 33    LDX    #$A233
AA05: CE 02 D8    LDU    #$02D8
AA08: C6 09       LDB    #$09
AA0A: BD F3 D0    JSR    $F3D0
AA0D: 8E A2 40    LDX    #$A240
AA10: CE 03 3A    LDU    #$033A
AA13: C6 09       LDB    #$09
AA15: BD F3 D0    JSR    $F3D0
AA18: 8E A2 54    LDX    #$A254
AA1B: CE 02 7C    LDU    #$027C
AA1E: C6 03       LDB    #$03
AA20: BD F3 D0    JSR    $F3D0
AA23: BD D0 8A    JSR    $D08A
l_aa26:
AA26: BD E0 00    JSR    $E000
AA29: B6 13 89    LDA    scroll_value_1389
AA2C: 80 04       SUBA   #$04
AA2E: B7 13 89    STA    scroll_value_1389
AA31: 81 13       CMPA   #$13
AA33: 27 21       BEQ    $AA56
AA35: 39          RTS

AA56: 86 30       LDA    #$30                                        
AA58: B7 14 02    STA    $1402                                       
AA5B: B6 13 72    LDA    $1372                                       
AA5E: 26 0D       BNE    $AA6D                                       
AA60: BD D0 8A    JSR    $D08A
l_aa63:
AA63: BD E0 00    JSR    $E000
AA66: B6 13 73    LDA    $1373
AA69: 81 02       CMPA   #$02
AA6B: 25 11       BCS    $AA7E
AA6D: 8E AA 90    LDX    #$AA90
AA70: CE 02 CC    LDU    #$02CC
AA73: C6 02       LDB    #$02
AA75: BD F3 D0    JSR    $F3D0
AA78: BD D0 8A    JSR    $D08A
l_aa7b:
AA7B: BD E0 00    JSR    $E000
l_aa7e:
AA7E: B6 13 71    LDA    $1371
AA81: 26 01       BNE    $AA84
AA83: 39          RTS
AA84: 7C 48 09    INC    $4809
AA87: 7F 48 01    CLR    number_of_players_4801
AA8A: 81 01       CMPA   #$01
AA8C: 27 37       BEQ    $AAC5
AA8E: 20 0F       BRA    $AA9F

AA9F: 86 01       LDA    #$01                                        
AAA1: B7 13 80    STA    $1380                                       
AAA4: 86 40       LDA    #$40                                        
AAA6: B7 14 02    STA    $1402
AAA9: 8E C8 16    LDX    #$C816
AAAC: CE 07 C7    LDU    #$07C7
AAAF: BD F3 C3    JSR    $F3C3
AAB2: 4F          CLRA
AAB3: 8E 07 E4    LDX    #$07E4
AAB6: A7 80       STA    ,X+
AAB8: A7 80       STA    ,X+
AABA: 86 20       LDA    #$20
AABC: C6 05       LDB    #$05
AABE: A7 80       STA    ,X+
AAC0: 5A          DECB
AAC1: 26 FB       BNE    $AABE
AAC3: 20 1D       BRA    $AAE2
AAC5: 7F 13 80    CLR    $1380
AAC8: 86 40       LDA    #$40
AACA: B7 14 02    STA    $1402
AACD: 86 20       LDA    #$20
AACF: 8E 07 C5    LDX    #$07C5
AAD2: A7 80       STA    ,X+
AAD4: A7 80       STA    ,X+
AAD6: A7 84       STA    ,X
AAD8: 8E 07 E4    LDX    #$07E4
AADB: C6 07       LDB    #$07
AADD: A7 80       STA    ,X+
AADF: 5A          DECB
AAE0: 26 FB       BNE    $AADD
AAE2: 8E 07 F8    LDX    #$07F8
AAE5: C6 06       LDB    #$06
AAE7: A7 80       STA    ,X+
AAE9: 5A          DECB
AAEA: 26 FB       BNE    $AAE7
AAEC: F7 07 F8    STB    $07F8
AAEF: BD BC 49    JSR    $BC49
AAF2: BD D0 8A    JSR    $D08A
l_aaf5:
AAF5: 86 50       LDA    #$50
AAF7: B7 14 02    STA    $1402
AAFA: 7F 13 92    CLR    $1392
AAFD: 8E 20 40    LDX    #$2040
AB00: 6F 03       CLR    $3,X
AB02: 6F 02       CLR    $2,X
AB04: A6 84       LDA    ,X
AB06: 81 02       CMPA   #$02
AB08: 26 02       BNE    $AB0C
AB0A: 6C 84       INC    ,X
AB0C: 30 09       LEAX   $9,X
AB0E: 8C 20 9A    CMPX   #$209A
AB11: 26 ED       BNE    $AB00
AB13: 8E 20 9A    LDX    #$209A
AB16: BF 20 9A    STX    $209A
AB19: 7F 13 50    CLR    $1350
AB1C: BD BC 3A    JSR    $BC3A
AB1F: BD D0 8A    JSR    $D08A
l_ab22:
AB22: 8E 07 93    LDX    #$0793
AB25: 86 20       LDA    #$20
AB27: A7 88 20    STA    $20,X
AB2A: A7 80       STA    ,X+
AB2C: 8C 07 9E    CMPX   #$079E
AB2F: 26 F6       BNE    $AB27
AB31: 0A 30       DEC    <$30
AB33: BD D0 AB    JSR    $D0AB
AB36: 7C 13 96    INC    $1396
AB39: BD D0 8A    JSR    $D08A
l_ab3c:
AB3C: 86 60       LDA    #$60
AB3E: B7 14 02    STA    $1402
AB41: 8E E4 D8    LDX    #$E4D8
AB44: 9F 0E       STX    <$0E
AB46: 0F 29       CLR    <$29
AB48: BD E0 68    JSR    $E068
AB4B: 86 01       LDA    #$01
AB4D: B7 14 40    STA    $1440
AB50: 86 00       LDA    #$00
AB52: B7 14 05    STA    $1405
AB55: BD D0 8A    JSR    $D08A
l_ab58:
AB58: 7E B7 34    JMP    $B734
AB5B: BD F3 AA    JSR    $F3AA
AB5E: BD F3 5B    JSR    $F35B
AB61: BD D0 8A    JSR    $D08A
l_ab64:
AB64: BD BC AC    JSR    $BCAC
AB67: 8E 20 E0    LDX    #$20E0
AB6A: 6F 84       CLR    ,X
AB6C: 6F 01       CLR    $1,X
AB6E: A6 07       LDA    $7,X
AB70: 81 FF       CMPA   #$FF
AB72: 27 04       BEQ    $AB78
AB74: 30 08       LEAX   $8,X
AB76: 20 F2       BRA    $AB6A
AB78: 86 FF       LDA    #$FF
AB7A: B7 13 89    STA    scroll_value_1389
AB7D: BD D0 8A    JSR    $D08A
l_ab80:
AB80: B6 13 96    LDA    $1396
AB83: 27 1B       BEQ    $ABA0
AB85: 7F 13 96    CLR    $1396
AB88: 8E AC 26    LDX    #$AC26
AB8B: CE 06 8B    LDU    #$068B
AB8E: C6 00       LDB    #$00
AB90: BD F3 D0    JSR    $F3D0
AB93: B6 13 81    LDA    $1381
AB96: 4C          INCA
AB97: A7 C9 01 20 STA    $0120,U
AB9B: 86 3C       LDA    #$3C
AB9D: BD D0 93    JSR    $D093
l_aba0:
ABA0: 96 31       LDA    <$31
ABA2: 4C          INCA
ABA3: B7 13 8C    STA    $138C
ABA6: BD F4 C7    JSR    $F4C7
ABA9: 8E AC 20    LDX    #$AC20
ABAC: CE 06 0F    LDU    #$060F
ABAF: C6 09       LDB    #$09
ABB1: BD F3 D0    JSR    $F3D0
ABB4: 33 C8 E0    LEAU   -$20,U
ABB7: B6 13 8D    LDA    $138D
ABBA: 27 12       BEQ    $ABCE
ABBC: A7 C4       STA    ,U
ABBE: E7 C9 08 00 STB    $0800,U
ABC2: 33 C8 E0    LEAU   -$20,U
ABC5: B6 13 8E    LDA    $138E
ABC8: 44          LSRA
ABC9: 44          LSRA
ABCA: 44          LSRA
ABCB: 44          LSRA
ABCC: 20 0B       BRA    $ABD9
ABCE: B6 13 8E    LDA    $138E
ABD1: 84 F0       ANDA   #$F0
ABD3: 27 0D       BEQ    $ABE2
ABD5: 44          LSRA
ABD6: 44          LSRA
ABD7: 44          LSRA
ABD8: 44          LSRA
ABD9: A7 C4       STA    ,U
ABDB: E7 C9 08 00 STB    $0800,U
ABDF: 33 C8 E0    LEAU   -$20,U
ABE2: B6 13 8E    LDA    $138E
ABE5: 84 0F       ANDA   #$0F
ABE7: A7 C4       STA    ,U
ABE9: E7 C9 08 00 STB    $0800,U
ABED: 86 3C       LDA    #$3C
ABEF: BD D0 93    JSR    $D093
ABF2: 8E F4 5F    LDX    #$F45F
ABF5: CE 06 AB    LDU    #$06AB
ABF8: BD FE AA    JSR    $FEAA
ABFB: 8E F4 5F    LDX    #$F45F
ABFE: CE 06 2F    LDU    #$062F
AC01: BD FE AA    JSR    $FEAA
AC04: 86 18       LDA    #$18
AC06: B7 13 89    STA    scroll_value_1389
AC09: 4F          CLRA
AC0A: BD F3 69    JSR    $F369
AC0D: BD E1 01    JSR    $E101
AC10: 0F 0C       CLR    <$0C
AC12: 7C 14 46    INC    $1446
AC15: 7C 14 4E    INC    $144E
AC18: 86 3C       LDA    #$3C
AC1A: BD D0 93    JSR    $D093
AC1D: 7E AC 37    JMP    $AC37

AC37: 7C 14 44    INC    $1444
AC3A: 7C 14 45    INC    $1445
AC3D: 86 70       LDA    #$70
AC3F: B7 14 02    STA    $1402
AC42: BD D0 8A    JSR    $D08A
l_ac45:
AC45: 7F 14 44    CLR    $1444
AC48: 7F 14 45    CLR    $1445
AC4B: 86 3C       LDA    #$3C
AC4D: BD D0 93    JSR    $D093
l_ac50:
AC50: 0F 33       CLR    <$33
AC52: 86 00       LDA    #$00
AC54: B7 14 40    STA    $1440
AC57: 86 00       LDA    #$00
AC59: B7 14 05    STA    $1405
AC5C: 86 00       LDA    #$00
AC5E: B7 14 41    STA    $1441
AC61: 86 00       LDA    #$00
AC63: B7 14 08    STA    $1408
AC66: BD D0 8A    JSR    $D08A
l_ac69:
AC69: BD BC 34    JSR    $BC34
AC6C: 7F 14 40    CLR    $1440
AC6F: 7F 13 B0    CLR    $13B0
AC72: BE 13 AC    LDX    $13AC
AC75: A6 03       LDA    $3,X
AC77: B7 13 B8    STA    $13B8
AC7A: BD D0 8A    JSR    $D08A
l_ac7d:
AC7D: B6 13 B8    LDA    $13B8
AC80: 10 26 01 07 LBNE   $AD8B
AC84: BD BC 3A    JSR    $BC3A
AC87: 7F 40 42    CLR    $4042
AC8A: 7C 14 4C    INC    $144C
AC8D: 7C 13 DE    INC    $13DE
AC90: 86 01       LDA    #$01
AC92: B7 14 40    STA    $1440
AC95: 86 00       LDA    #$00
AC97: B7 14 05    STA    $1405
AC9A: 86 01       LDA    #$01
AC9C: B7 14 41    STA    $1441
AC9F: 86 00       LDA    #$00
ACA1: B7 14 08    STA    $1408
ACA4: 8E 13 40    LDX    #$1340
ACA7: FC 13 CE    LDD    $13CE
ACAA: 83 00 04    SUBD   #$0004
ACAD: ED 01       STD    $1,X
ACAF: 96 04       LDA    <$04
ACB1: 80 0A       SUBA   #$0A
ACB3: A7 04       STA    $4,X
ACB5: 86 01       LDA    #$01
ACB7: B7 13 40    STA    $1340
ACBA: B7 40 49    STA    $4049
ACBD: BD D0 8A    JSR    $D08A
ACC0: B6 13 40    LDA    $1340
ACC3: 27 01       BEQ    $ACC6
ACC5: 39          RTS
ACC6: BD D0 8A    JSR    $D08A
ACC9: B6 40 49    LDA    $4049
ACCC: 27 01       BEQ    $ACCF
ACCE: 39          RTS
ACCF: 8E 22 30    LDX    #$2230
ACD2: A6 84       LDA    ,X
ACD4: 81 FE       CMPA   #$FE
ACD6: 24 05       BCC    $ACDD
ACD8: 30 88 30    LEAX   $30,X
ACDB: 20 F5       BRA    $ACD2
ACDD: C6 03       LDB    #$03
ACDF: F7 13 D9    STB    $13D9
ACE2: 5A          DECB
ACE3: 7C 13 D9    INC    $13D9
ACE6: B6 13 D9    LDA    $13D9
ACE9: A7 88 17    STA    $17,X
ACEC: 86 12       LDA    #$12
ACEE: A7 84       STA    ,X
ACF0: CE 00 DC    LDU    #$00DC
ACF3: EF 01       STU    $1,X
ACF5: 6F 04       CLR    $4,X
ACF7: CE ED AA    LDU    #$EDAA
ACFA: EF 0E       STU    $E,X
ACFC: 30 88 30    LEAX   $30,X
ACFF: 5A          DECB
AD00: 26 E1       BNE    $ACE3
AD02: 8E 22 30    LDX    #$2230
AD05: A6 84       LDA    ,X
AD07: 81 FE       CMPA   #$FE
AD09: 24 16       BCC    $AD21
AD0B: 8C 24 10    CMPX   #$2410
AD0E: 27 11       BEQ    $AD21
AD10: EC 06       LDD    $6,X
AD12: C3 00 30    ADDD   #$0030
AD15: ED 06       STD    $6,X
AD17: 30 88 30    LEAX   $30,X
AD1A: 20 E9       BRA    $AD05
AD1C: 86 3C       LDA    #$3C
AD1E: BD D0 93    JSR    $D093
AD21: BD BC 34    JSR    $BC34
AD24: 86 03       LDA    #$03
AD26: B7 40 E2    STA    $40E2
AD29: BE 13 AC    LDX    $13AC
AD2C: A6 04       LDA    $4,X
AD2E: B7 13 B8    STA    $13B8
AD31: 86 00       LDA    #$00
AD33: B7 14 40    STA    $1440
AD36: 86 00       LDA    #$00
AD38: B7 14 05    STA    $1405
AD3B: 86 00       LDA    #$00
AD3D: B7 14 41    STA    $1441
AD40: 86 00       LDA    #$00
AD42: B7 14 08    STA    $1408
AD45: BD D0 8A    JSR    $D08A
AD48: B6 13 B8    LDA    $13B8
AD4B: 10 26 00 3C LBNE   $AD8B
AD4F: 8E 14 C0    LDX    #$14C0
AD52: CC 00 00    LDD    #$0000
AD55: ED 81       STD    ,X++
AD57: 8C 14 F0    CMPX   #$14F0
AD5A: 25 F9       BCS    $AD55
AD5C: 8E 14 C0    LDX    #$14C0
AD5F: CC 00 DC    LDD    #$00DC
AD62: ED 01       STD    $1,X
AD64: 6F 04       CLR    $4,X
AD66: FC 22 06    LDD    $2206
AD69: C3 00 20    ADDD   #$0020
AD6C: ED 06       STD    $6,X
AD6E: FC 22 08    LDD    $2208
AD71: C3 00 20    ADDD   #$0020
AD74: ED 08       STD    $8,X
AD76: 86 38       LDA    #$38
AD78: A7 0A       STA    $A,X
AD7A: A7 88 18    STA    $18,X
AD7D: CE E8 2D    LDU    #$E82D
AD80: EF 0E       STU    $E,X
AD82: 7C 14 53    INC    $1453
AD85: 7C 40 4F    INC    $404F
AD88: BD D0 8A    JSR    $D08A
AD8B: 86 01       LDA    #$01
AD8D: B7 40 42    STA    $4042
AD90: 96 32       LDA    <$32
AD92: 10 26 00 07 LBNE   $AD9D
AD96: 96 33       LDA    <$33
AD98: 10 26 00 93 LBNE   $AE2F
AD9C: 39          RTS
AD9D: 7C 14 02    INC    $1402
ADA0: 7F 40 42    CLR    $4042
ADA3: 86 04       LDA    #$04
ADA5: B7 40 E2    STA    $40E2
ADA8: 7F 14 42    CLR    $1442
ADAB: 7F 14 49    CLR    $1449
ADAE: A6 9F 20 1C LDA    [$201C]
ADB2: 27 2D       BEQ    $ADE1
ADB4: CE ED 50    LDU    #$ED50
ADB7: FF 22 0E    STU    $220E
ADBA: 8E 22 30    LDX    #$2230
ADBD: 8C 24 10    CMPX   #$2410
ADC0: 27 15       BEQ    $ADD7
ADC2: A6 84       LDA    ,X
ADC4: 81 FF       CMPA   #$FF
ADC6: 27 0F       BEQ    $ADD7
ADC8: 81 10       CMPA   #$10
ADCA: 25 04       BCS    $ADD0
ADCC: 81 12       CMPA   #$12
ADCE: 23 02       BLS    $ADD2
ADD0: EF 0E       STU    $E,X
ADD2: 30 88 30    LEAX   $30,X
ADD5: 20 E6       BRA    $ADBD
ADD7: BD D0 8A    JSR    $D08A
ADDA: A6 9F 20 1C LDA    [$201C]
ADDE: 27 01       BEQ    $ADE1
ADE0: 39          RTS
ADE1: BD D0 8A    JSR    $D08A
ADE4: DE 1C       LDU    <$1C
ADE6: A6 C8 10    LDA    $10,U
ADE9: AA C8 20    ORA    $20,U
ADEC: 27 01       BEQ    $ADEF
ADEE: 39          RTS
ADEF: BD BC 3A    JSR    $BC3A
ADF2: 7C 14 4C    INC    $144C
ADF5: 86 5A       LDA    #$5A
ADF7: BD D0 93    JSR    $D093
ADFA: BD F3 83    JSR    $F383
ADFD: 7F 40 4F    CLR    $404F
AE00: 86 0A       LDA    #$0A
AE02: BD D0 93    JSR    $D093
AE05: 7C 40 45    INC    $4045
AE08: BD D0 8A    JSR    $D08A
AE0B: B6 40 45    LDA    $4045
AE0E: 27 01       BEQ    $AE11
AE10: 39          RTS
AE11: 86 14       LDA    #$14
AE13: BD D0 93    JSR    $D093
AE16: 0F 32       CLR    <$32
AE18: 0F 33       CLR    <$33
AE1A: 0F 3E       CLR    <$3E
AE1C: 0C 31       INC    <$31
AE1E: 96 31       LDA    <$31
AE20: 4C          INCA
AE21: 84 03       ANDA   #$03
AE23: 81 03       CMPA   #$03
AE25: 10 27 02 0F LBEQ   $B038
AE29: BD BE 0D    JSR    $BE0D
AE2C: 7E AB 3C    JMP    $AB3C
AE2F: 86 72       LDA    #$72
AE31: B7 14 02    STA    $1402
AE34: 7F 40 42    CLR    $4042
AE37: 86 04       LDA    #$04
AE39: B7 40 E2    STA    $40E2
AE3C: 7F 14 42    CLR    $1442
AE3F: 7F 14 49    CLR    $1449
AE42: 86 19       LDA    #$19
AE44: B7 11 1A    STA    $111A
AE47: A6 9F 20 1C LDA    [$201C]
AE4B: 27 25       BEQ    $AE72
AE4D: CE ED 50    LDU    #$ED50
AE50: FF 22 0E    STU    $220E
AE53: 8E 22 30    LDX    #$2230
AE56: 8C 24 10    CMPX   #$2410
AE59: 27 0D       BEQ    $AE68
AE5B: A6 84       LDA    ,X
AE5D: 81 FF       CMPA   #$FF
AE5F: 27 07       BEQ    $AE68
AE61: EF 0E       STU    $E,X
AE63: 30 88 30    LEAX   $30,X
AE66: 20 EE       BRA    $AE56
AE68: BD D0 8A    JSR    $D08A
AE6B: A6 9F 20 1C LDA    [$201C]
AE6F: 27 01       BEQ    $AE72
AE71: 39          RTS
AE72: BD D0 8A    JSR    $D08A
l_ae75:
AE75: DE 1C       LDU    <$1C
AE77: A6 C8 10    LDA    $10,U
AE7A: AA C8 20    ORA    $20,U
AE7D: 27 01       BEQ    $AE80
AE7F: 39          RTS
AE80: BD BC 3A    JSR    $BC3A
AE83: BD E3 0D    JSR    $E30D
AE86: 86 64       LDA    #$64
AE88: BD D0 93    JSR    $D093
l_ae8b:
AE8B: BD F3 83    JSR    $F383
AE8E: 0F 17       CLR    <$17
AE90: 7C 40 46    INC    $4046
AE93: BD D0 8A    JSR    $D08A
l_ae96:
AE96: 0C 17       INC    <$17
AE98: 96 17       LDA    <$17
AE9A: 81 48       CMPA   #$48
AE9C: 22 09       BHI    $AEA7
AE9E: 44          LSRA
AE9F: 84 07       ANDA   #$07
AEA1: 8B 58       ADDA   #$58
AEA3: B7 11 1A    STA    $111A
AEA6: 39          RTS
AEA7: BD D0 8A    JSR    $D08A
l_aeaa:
AEAA: C6 1A       LDB    #$1A
AEAC: 0C 17       INC    <$17
AEAE: 96 17       LDA    <$17
AEB0: 81 68       CMPA   #$68
AEB2: 22 09       BHI    $AEBD
AEB4: 85 02       BITA   #$02
AEB6: 26 01       BNE    $AEB9
AEB8: 5C          INCB
AEB9: F7 11 1A    STB    $111A
AEBC: 39          RTS
AEBD: BD D0 8A    JSR    $D08A
l_aec0:
AEC0: B6 40 46    LDA    $4046
AEC3: 27 01       BEQ    $AEC6
AEC5: 39          RTS
AEC6: 86 3C       LDA    #$3C
AEC8: BD D0 93    JSR    $D093
l_aecb:
AECB: 0F 33       CLR    <$33
AECD: 86 73       LDA    #$73
AECF: B7 14 02    STA    $1402
AED2: 96 30       LDA    <$30
AED4: 27 55       BEQ    $AF2B
AED6: 86 80       LDA    #$80
AED8: B7 14 02    STA    $1402
AEDB: BD D0 8A    JSR    $D08A
l_aede:
AEDE: B6 13 81    LDA    $1381
AEE1: 26 08       BNE    $AEEB
AEE3: 8E 1A 00    LDX    #$1A00
AEE6: CE 18 00    LDU    #$1800
AEE9: 20 06       BRA    $AEF1
AEEB: 8E 18 00    LDX    #$1800
AEEE: CE 1A 00    LDU    #$1A00
AEF1: A6 88 30    LDA    $30,X
AEF4: 26 03       BNE    $AEF9
AEF6: 7E AA F5    JMP    $AAF5
AEF9: 86 90       LDA    #$90
AEFB: B7 14 02    STA    $1402
AEFE: 34 10       PSHS   X
AF00: 8E 20 00    LDX    #$2000
AF03: 10 8E 00 F0 LDY    #$00F0
AF07: EC 81       LDD    ,X++
AF09: ED C1       STD    ,U++
AF0B: 31 3F       LEAY   -$1,Y
AF0D: 26 F8       BNE    $AF07
AF0F: 35 10       PULS   X
AF11: CE 20 00    LDU    #$2000
AF14: 10 8E 00 F0 LDY    #$00F0
AF18: EC 81       LDD    ,X++
AF1A: ED C1       STD    ,U++
AF1C: 31 3F       LEAY   -$1,Y
AF1E: 26 F8       BNE    $AF18
AF20: B6 13 81    LDA    $1381
AF23: 88 01       EORA   #$01
AF25: B7 13 81    STA    $1381
AF28: 7E AA F5    JMP    $AAF5
AF2B: 86 A0       LDA    #$A0
AF2D: B7 14 02    STA    $1402
AF30: BD E3 0D    JSR    $E30D
AF33: BD D0 8A    JSR    $D08A
AF36: BD F3 5B    JSR    $F35B
AF39: BD F3 AA    JSR    $F3AA
AF3C: 86 8C       LDA    #$8C
AF3E: B7 13 89    STA    scroll_value_1389
AF41: BD D0 8A    JSR    $D08A
AF44: 8E B0 27    LDX    #$B027
AF47: CE 04 50    LDU    #$0450
AF4A: C6 00       LDB    #$00
AF4C: BD F3 D0    JSR    $F3D0
AF4F: 8E B0 31    LDX    #$B031
AF52: CE 04 4E    LDU    #$044E
AF55: BD F3 D0    JSR    $F3D0
AF58: B6 13 81    LDA    $1381
AF5B: 8B 01       ADDA   #$01
AF5D: 33 C8 E0    LEAU   -$20,U
AF60: A7 C4       STA    ,U
AF62: 86 F0       LDA    #$F0
AF64: 97 04       STA    <$04
AF66: 8E 22 36    LDX    #$2236
AF69: CC 01 80    LDD    #$0180
AF6C: ED 84       STD    ,X
AF6E: 30 88 30    LEAX   $30,X
AF71: 8C 24 16    CMPX   #$2416
AF74: 26 F6       BNE    $AF6C
AF76: 7C 14 44    INC    $1444
AF79: 86 01       LDA    #$01
AF7B: B7 40 43    STA    $4043
AF7E: BD D0 8A    JSR    $D08A
AF81: 96 31       LDA    <$31
AF83: 4C          INCA
AF84: B7 13 8C    STA    $138C
AF87: BD F4 C7    JSR    $F4C7
AF8A: FC 13 8D    LDD    $138D
AF8D: FD 14 8A    STD    $148A
AF90: 8E 13 8F    LDX    #$138F
AF93: C6 02       LDB    #$02
AF95: BD E3 60    JSR    $E360
AF98: 8E 13 8F    LDX    #$138F
AF9B: CE 10 14    LDU    #$1014
AF9E: C6 02       LDB    #$02
AFA0: BD E3 37    JSR    $E337
AFA3: 8E 20 36    LDX    #$2036
AFA6: CE 10 17    LDU    #$1017
AFA9: EC 81       LDD    ,X++
AFAB: ED C1       STD    ,U++
AFAD: A6 84       LDA    ,X
AFAF: A7 C4       STA    ,U
AFB1: 8E 10 1A    LDX    #$101A
AFB4: C6 03       LDB    #$03
AFB6: BD E3 60    JSR    $E360
AFB9: 8E 10 1A    LDX    #$101A
AFBC: CE 10 08    LDU    #$1008
AFBF: C6 03       LDB    #$03
AFC1: BD E3 37    JSR    $E337
AFC4: BD D0 8A    JSR    $D08A
AFC7: B6 40 43    LDA    $4043
AFCA: 27 01       BEQ    $AFCD
AFCC: 39          RTS
AFCD: B6 13 81    LDA    $1381
AFD0: 26 05       BNE    $AFD7
AFD2: 8E 1A 00    LDX    #$1A00
AFD5: 20 03       BRA    $AFDA
AFD7: 8E 18 00    LDX    #$1800
AFDA: A6 88 30    LDA    $30,X
AFDD: 26 03       BNE    $AFE2
AFDF: 7F 48 09    CLR    $4809
AFE2: BD F3 5B    JSR    $F35B
AFE5: 86 FF       LDA    #$FF
AFE7: B7 13 89    STA    scroll_value_1389
AFEA: 7F 14 44    CLR    $1444
AFED: BD F3 AA    JSR    $F3AA
AFF0: 86 1E       LDA    #$1E
AFF2: BD D0 93    JSR    $D093
AFF5: 7E B9 5D    JMP    $B95D
AFF8: B6 13 81    LDA    $1381
AFFB: 26 08       BNE    $B005
AFFD: 8E 1A 00    LDX    #$1A00
B000: CE 18 00    LDU    #$1800
B003: 20 06       BRA    $B00B
B005: 8E 18 00    LDX    #$1800
B008: CE 1A 00    LDU    #$1A00
B00B: A6 88 30    LDA    $30,X
B00E: 27 03       BEQ    $B013
B010: 7E AE F9    JMP    $AEF9
B013: 86 B0       LDA    #$B0
B015: B7 14 02    STA    $1402
B018: BD D0 8A    JSR    $D08A
B01B: BD F3 5B    JSR    $F35B
B01E: B7 50 04    STA    $5004
B021: 7F 10 14    CLR    $1014
B024: 7E A1 2C    JMP    $A12C

B038: 86 60       LDA    #$60                                       
B03A: B7 14 02    STA    $1402                                      
B03D: 86 01       LDA    #$01                                       
B03F: B7 14 40    STA    $1440                                      
B042: 86 00       LDA    #$00
B044: B7 14 05    STA    $1405
B047: BD D0 8A    JSR    $D08A
B04A: BD F3 AA    JSR    $F3AA
B04D: BD F3 5B    JSR    $F35B
B050: BD D0 8A    JSR    $D08A
B053: 4F          CLRA
B054: BD F3 69    JSR    $F369
B057: 86 FF       LDA    #$FF
B059: B7 13 89    STA    scroll_value_1389
B05C: BD D0 8A    JSR    $D08A
B05F: BD E0 68    JSR    $E068
B062: 8E B6 93    LDX    #$B693
B065: CE 06 46    LDU    #$0646
B068: BD F3 B5    JSR    $F3B5
B06B: 86 01       LDA    #$01
B06D: B7 40 4C    STA    $404C
B070: 86 2D       LDA    #$2D
B072: BD D0 93    JSR    $D093
B075: 8E B6 CB    LDX    #$B6CB
B078: CE 06 2E    LDU    #$062E
B07B: C6 07       LDB    #$07
B07D: BD F3 D0    JSR    $F3D0
B080: BD D0 8A    JSR    $D08A
B083: 8E 24 00    LDX    #$2400
B086: CC 00 00    LDD    #$0000
B089: ED 81       STD    ,X++
B08B: 8C 24 10    CMPX   #$2410
B08E: 25 F9       BCS    $B089
B090: 8E 24 00    LDX    #$2400
B093: 86 4C       LDA    #$4C
B095: A7 01       STA    $1,X
B097: CC 00 7F    LDD    #$007F
B09A: ED 03       STD    $3,X
B09C: 86 6C       LDA    #$6C
B09E: A7 05       STA    $5,X
B0A0: 86 FF       LDA    #$FF
B0A2: A7 07       STA    $7,X
B0A4: 7C 14 52    INC    $1452
B0A7: BD D0 8A    JSR    $D08A
B0AA: 86 53       LDA    #$53
B0AC: B7 05 2E    STA    $052E
B0AF: 86 07       LDA    #$07
B0B1: B7 0D 2E    STA    $0D2E
B0B4: 86 2D       LDA    #$2D
B0B6: BD D0 93    JSR    $D093
B0B9: 8E B6 8C    LDX    #$B68C
B0BC: CE 06 71    LDU    #$0671
B0BF: C6 0C       LDB    #$0C
B0C1: BD F3 D0    JSR    $F3D0
B0C4: BD D0 8A    JSR    $D08A
B0C7: 8E 11 54    LDX    #$1154
B0CA: 86 4E       LDA    #$4E
B0CC: A7 84       STA    ,X
B0CE: 6F 01       CLR    $1,X
B0D0: B6 13 93    LDA    $1393
B0D3: 26 09       BNE    $B0DE
B0D5: CC 84 B9    LDD    #$84B9
B0D8: ED 89 00 80 STD    $0080,X
B0DC: 20 07       BRA    $B0E5
B0DE: CC 6E A7    LDD    #$6EA7
B0E1: ED 89 00 80 STD    $0080,X
B0E5: 6F 89 01 00 CLR    $0100,X
B0E9: 6F 89 01 01 CLR    $0101,X
B0ED: BD D0 8A    JSR    $D08A
B0F0: 8E B6 9F    LDX    #$B69F
B0F3: CE 05 51    LDU    #$0551
B0F6: C6 0C       LDB    #$0C
B0F8: BD F3 D0    JSR    $F3D0
B0FB: BD D0 8A    JSR    $D08A
B0FE: B6 40 4C    LDA    $404C
B101: 27 1D       BEQ    $B120
B103: 86 02       LDA    #$02
B105: BD D0 93    JSR    $D093
B108: 8E 0E 46    LDX    #$0E46
B10B: A6 84       LDA    ,X
B10D: 4C          INCA
B10E: 84 07       ANDA   #$07
B110: CE B6 93    LDU    #$B693
B113: A7 84       STA    ,X
B115: 30 88 E0    LEAX   -$20,X
B118: E6 C0       LDB    ,U+
B11A: C1 2F       CMPB   #$2F
B11C: 26 F5       BNE    $B113
B11E: 20 DB       BRA    $B0FB
B120: 86 3C       LDA    #$3C
B122: BD D0 93    JSR    $D093
B125: 7F 14 52    CLR    $1452
B128: BD F3 5B    JSR    $F35B
B12B: BD F3 AA    JSR    $F3AA
B12E: 4F          CLRA
B12F: BD F3 69    JSR    $F369
B132: BD D0 8A    JSR    $D08A
B135: 86 18       LDA    #$18
B137: B7 13 89    STA    scroll_value_1389
B13A: BD D0 8A    JSR    $D08A
B13D: 8E 00 7C    LDX    #$007C
B140: 86 1E       LDA    #$1E
B142: C6 04       LDB    #$04
B144: A7 80       STA    ,X+
B146: 5A          DECB
B147: 26 FB       BNE    $B144
B149: 30 01       LEAX   $1,X
B14B: 86 5B       LDA    #$5B
B14D: A7 80       STA    ,X+
B14F: 86 1D       LDA    #$1D
B151: C6 19       LDB    #$19
B153: A7 80       STA    ,X+
B155: 5A          DECB
B156: 26 FB       BNE    $B153
B158: 86 AC       LDA    #$AC
B15A: A7 80       STA    ,X+
B15C: 86 5C       LDA    #$5C
B15E: C6 04       LDB    #$04
B160: A7 80       STA    ,X+
B162: 5A          DECB
B163: 26 FB       BNE    $B160
B165: 30 88 1C    LEAX   $1C,X
B168: 86 1F       LDA    #$1F
B16A: C6 04       LDB    #$04
B16C: A7 80       STA    ,X+
B16E: 5A          DECB
B16F: 26 FB       BNE    $B16C
B171: 8C 07 80    CMPX   #$0780
B174: 24 05       BCC    $B17B
B176: 30 88 7C    LEAX   $7C,X
B179: 20 C5       BRA    $B140
B17B: 86 A7       LDA    #$A7
B17D: B7 00 81    STA    >$0081
B180: 4C          INCA
B181: B7 07 41    STA    $0741
B184: 8E 00 A1    LDX    #$00A1
B187: 86 19       LDA    #$19
B189: C6 05       LDB    #$05
B18B: A7 84       STA    ,X
B18D: 30 88 20    LEAX   $20,X
B190: 5A          DECB
B191: 26 F8       BNE    $B18B
B193: 30 88 20    LEAX   $20,X
B196: 8C 07 40    CMPX   #$0740
B199: 25 EE       BCS    $B189
B19B: 8E D9 EA    LDX    #$D9EA
B19E: A6 84       LDA    ,X
B1A0: 81 FF       CMPA   #$FF
B1A2: 27 24       BEQ    $B1C8
B1A4: 44          LSRA
B1A5: 44          LSRA
B1A6: 44          LSRA
B1A7: 44          LSRA
B1A8: C6 C0       LDB    #$C0
B1AA: 3D          MUL
B1AB: FD 13 9C    STD    $139C
B1AE: E6 80       LDB    ,X+
B1B0: C4 0F       ANDB   #$0F
B1B2: 58          ASLB
B1B3: 58          ASLB
B1B4: 4F          CLRA
B1B5: F3 13 9C    ADDD   $139C
B1B8: CE 01 46    LDU    #$0146
B1BB: 33 CB       LEAU   D,U
B1BD: CC 20 20    LDD    #$2020
B1C0: ED C1       STD    ,U++
B1C2: ED C1       STD    ,U++
B1C4: A7 C4       STA    ,U
B1C6: 20 D6       BRA    $B19E
B1C8: BD BE 64    JSR    $BE64
B1CB: BD E2 78    JSR    $E278
B1CE: 8E 20 E0    LDX    #$20E0
B1D1: EE 05       LDU    $5,X
B1D3: 86 AC       LDA    #$AC
B1D5: A7 C8 1F    STA    $1F,U
B1D8: A7 C9 FF 5F STA    -$00A1,U
B1DC: 86 A9       LDA    #$A9
B1DE: A7 C8 20    STA    $20,U
B1E1: A7 C9 FF 60 STA    -$00A0,U
B1E5: A6 07       LDA    $7,X
B1E7: 81 FF       CMPA   #$FF
B1E9: 27 04       BEQ    $B1EF
B1EB: 30 08       LEAX   $8,X
B1ED: 20 E2       BRA    $B1D1
B1EF: BD D0 8A    JSR    $D08A
B1F2: 8E 20 00    LDX    #$2000
B1F5: CC 00 00    LDD    #$0000
B1F8: ED 81       STD    ,X++
B1FA: 8C 20 30    CMPX   #$2030
B1FD: 26 F9       BNE    $B1F8
B1FF: CC 01 9C    LDD    #$019C
B202: DD 01       STD    <$01
B204: 86 50       LDA    #$50
B206: 97 04       STA    <$04
B208: CC 02 00    LDD    #$0200
B20B: DD 08       STD    <$08
B20D: 8E 11 1A    LDX    #$111A
B210: 9F 19       STX    <$19
B212: 8E E8 2D    LDX    #$E82D
B215: 9F 0E       STX    <$0E
B217: 86 01       LDA    #$01
B219: 97 29       STA    <$29
B21B: BD D0 8A    JSR    $D08A
B21E: 8E 22 00    LDX    #$2200
B221: CC 00 00    LDD    #$0000
B224: ED 81       STD    ,X++
B226: 8C 22 30    CMPX   #$2230
B229: 26 F9       BNE    $B224
B22B: 8E 22 00    LDX    #$2200
B22E: CC 00 1C    LDD    #$001C
B231: ED 01       STD    $1,X
B233: 86 C2       LDA    #$C2
B235: A7 04       STA    $4,X
B237: CC 02 00    LDD    #$0200
B23A: ED 08       STD    $8,X
B23C: 86 08       LDA    #$08
B23E: A7 88 18    STA    $18,X
B241: CE 11 1C    LDU    #$111C
B244: A7 C4       STA    ,U
B246: EF 88 19    STU    $19,X
B249: 6F 0D       CLR    $D,X
B24B: CE E4 DE    LDU    #$E4DE
B24E: EF 0E       STU    $E,X
B250: 6F 88 1B    CLR    $1B,X
B253: 7C 14 45    INC    $1445
B256: BD D0 8A    JSR    $D08A
B259: 8E 24 00    LDX    #$2400
B25C: CC 00 00    LDD    #$0000
B25F: ED 81       STD    ,X++
B261: 8C 24 80    CMPX   #$2480
B264: 25 F9       BCS    $B25F
B266: 8E B6 E9    LDX    #$B6E9
B269: CE 24 00    LDU    #$2400
B26C: EC 81       LDD    ,X++
B26E: 81 FF       CMPA   #$FF
B270: 27 0E       BEQ    $B280
B272: ED 43       STD    $3,U
B274: A6 80       LDA    ,X+
B276: A7 45       STA    $5,U
B278: 86 4C       LDA    #$4C
B27A: A7 41       STA    $1,U
B27C: 33 48       LEAU   $8,U
B27E: 20 EC       BRA    $B26C
B280: 86 0C       LDA    #$0C
B282: B7 24 06    STA    $2406
B285: 86 50       LDA    #$50
B287: B7 24 01    STA    $2401
B28A: 96 31       LDA    <$31
B28C: 4C          INCA
B28D: 85 0C       BITA   #$0C
B28F: 27 05       BEQ    $B296
B291: 8E B7 02    LDX    #$B702
B294: 20 03       BRA    $B299
B296: 8E B7 1B    LDX    #$B71B
B299: EC 81       LDD    ,X++
B29B: 81 FF       CMPA   #$FF
B29D: 27 0E       BEQ    $B2AD
B29F: ED 43       STD    $3,U
B2A1: A6 80       LDA    ,X+
B2A3: A7 45       STA    $5,U
B2A5: 86 4D       LDA    #$4D
B2A7: A7 41       STA    $1,U
B2A9: 33 48       LEAU   $8,U
B2AB: 20 EC       BRA    $B299
B2AD: A7 5F       STA    -$1,U
B2AF: 96 31       LDA    <$31
B2B1: 4C          INCA
B2B2: 85 08       BITA   #$08
B2B4: 27 0C       BEQ    $B2C2
B2B6: 8E 24 18    LDX    #$2418
B2B9: CC 00 DC    LDD    #$00DC
B2BC: ED 03       STD    $3,X
B2BE: 86 28       LDA    #$28
B2C0: A7 05       STA    $5,X
B2C2: 86 2D       LDA    #$2D
B2C4: BD D0 93    JSR    $D093
B2C7: 7F 13 9E    CLR    $139E
B2CA: 7F 13 9F    CLR    $139F
B2CD: 7C 14 52    INC    $1452
B2D0: 86 2D       LDA    #$2D
B2D2: BD D0 93    JSR    $D093
B2D5: 86 70       LDA    #$70
B2D7: B7 14 02    STA    $1402
B2DA: 7C 14 42    INC    $1442
B2DD: 7C 14 48    INC    $1448
B2E0: 86 00       LDA    #$00
B2E2: B7 14 40    STA    $1440
B2E5: 86 00       LDA    #$00
B2E7: B7 14 05    STA    $1405
B2EA: BD D0 8A    JSR    $D08A
B2ED: 7A 14 42    DEC    $1442
B2F0: 86 3C       LDA    #$3C
B2F2: BD D0 93    JSR    $D093
B2F5: 7C 14 42    INC    $1442
B2F8: 86 01       LDA    #$01
B2FA: B7 40 4B    STA    $404B
B2FD: 7F 15 15    CLR    $1515
B300: BD D0 8A    JSR    $D08A
B303: B6 15 15    LDA    $1515
B306: 81 03       CMPA   #$03
B308: 25 16       BCS    $B320
B30A: 81 06       CMPA   #$06
B30C: 25 09       BCS    $B317
B30E: 81 09       CMPA   #$09
B310: 22 26       BHI    $B338
B312: B6 13 77    LDA    $1377
B315: 20 03       BRA    $B31A
B317: B6 13 75    LDA    $1375
B31A: 85 04       BITA   #$04
B31C: 27 0E       BEQ    $B32C
B31E: 20 07       BRA    $B327
B320: B6 13 75    LDA    $1375
B323: 85 01       BITA   #$01
B325: 27 05       BEQ    $B32C
B327: 7C 15 15    INC    $1515
B32A: 20 0F       BRA    $B33B
B32C: B6 13 75    LDA    $1375
B32F: 84 01       ANDA   #$01
B331: BA 13 77    ORA    $1377
B334: 84 05       ANDA   #$05
B336: 27 03       BEQ    $B33B
B338: 7F 15 15    CLR    $1515
B33B: 96 32       LDA    <$32
B33D: 26 0A       BNE    $B349
B33F: 96 33       LDA    <$33
B341: 26 06       BNE    $B349
B343: B6 40 4B    LDA    $404B
B346: 27 01       BEQ    $B349
B348: 39          RTS
B349: 7F 14 42    CLR    $1442
B34C: 7F 14 48    CLR    $1448
B34F: 7F 14 52    CLR    $1452
B352: 7F 40 4B    CLR    $404B
B355: 96 32       LDA    <$32
B357: 10 27 00 A1 LBEQ   $B3FC
B35B: B6 13 9F    LDA    $139F
B35E: 10 27 00 9A LBEQ   $B3FC
B362: CE EA 25    LDU    #$EA25
B365: FF 22 0E    STU    $220E
B368: 96 31       LDA    <$31
B36A: 4C          INCA
B36B: 85 0C       BITA   #$0C
B36D: 27 46       BEQ    $B3B5
B36F: 85 08       BITA   #$08
B371: 27 2F       BEQ    $B3A2
B373: 85 04       BITA   #$04
B375: 27 18       BEQ    $B38F
B377: 86 02       LDA    #$02
B379: B7 22 0D    STA    $220D
B37C: 86 01       LDA    #$01
B37E: B7 40 50    STA    $4050
B381: BD D0 8A    JSR    $D08A
B384: B6 40 50    LDA    $4050
B387: 27 01       BEQ    $B38A
B389: 39          RTS
B38A: 86 0A       LDA    #$0A
B38C: BD D0 93    JSR    $D093
B38F: 86 01       LDA    #$01
B391: B7 40 50    STA    $4050
B394: BD D0 8A    JSR    $D08A
B397: B6 40 50    LDA    $4050
B39A: 27 01       BEQ    $B39D
B39C: 39          RTS
B39D: 86 0A       LDA    #$0A
B39F: BD D0 93    JSR    $D093
B3A2: 86 01       LDA    #$01
B3A4: B7 40 50    STA    $4050
B3A7: BD D0 8A    JSR    $D08A
B3AA: B6 40 50    LDA    $4050
B3AD: 27 01       BEQ    $B3B0
B3AF: 39          RTS
B3B0: 86 0A       LDA    #$0A
B3B2: BD D0 93    JSR    $D093
B3B5: 86 01       LDA    #$01
B3B7: B7 40 50    STA    $4050
B3BA: BD D0 8A    JSR    $D08A
B3BD: B6 22 04    LDA    $2204
B3C0: 81 18       CMPA   #$18
B3C2: 22 32       BHI    $B3F6
B3C4: B6 13 9E    LDA    $139E
B3C7: 81 10       CMPA   #$10
B3C9: 27 31       BEQ    $B3FC
B3CB: 96 31       LDA    <$31
B3CD: 4C          INCA
B3CE: 84 0C       ANDA   #$0C
B3D0: 27 2A       BEQ    $B3FC
B3D2: 81 0C       CMPA   #$0C
B3D4: 26 0C       BNE    $B3E2
B3D6: 8E 24 38    LDX    #$2438
B3D9: A6 84       LDA    ,X
B3DB: 26 1F       BNE    $B3FC
B3DD: 7F 11 E0    CLR    $11E0
B3E0: 20 0A       BRA    $B3EC
B3E2: 8E 24 30    LDX    #$2430
B3E5: A6 84       LDA    ,X
B3E7: 26 13       BNE    $B3FC
B3E9: 7F 11 DE    CLR    $11DE
B3EC: 6C 84       INC    ,X
B3EE: 7C 13 9E    INC    $139E
B3F1: 7C 40 48    INC    $4048
B3F4: 20 06       BRA    $B3FC
B3F6: B6 40 50    LDA    $4050
B3F9: 27 01       BEQ    $B3FC
B3FB: 39          RTS
B3FC: 7F 14 45    CLR    $1445
B3FF: 86 2D       LDA    #$2D
B401: BD D0 93    JSR    $D093
B404: BD F3 5B    JSR    $F35B
B407: BD F3 AA    JSR    $F3AA
B40A: 4F          CLRA
B40B: BD F3 69    JSR    $F369
B40E: BD D0 8A    JSR    $D08A
B411: 86 FF       LDA    #$FF
B413: B7 13 89    STA    scroll_value_1389
B416: BD D0 8A    JSR    $D08A
B419: 8E B6 A4    LDX    #$B6A4
B41C: CE 06 24    LDU    #$0624
B41F: C6 0C       LDB    #$0C
B421: BD F3 D0    JSR    $F3D0
B424: 86 78       LDA    #$78
B426: B7 40 51    STA    $4051
B429: BD D0 93    JSR    $D093
B42C: 8E 24 00    LDX    #$2400
B42F: CC 00 00    LDD    #$0000
B432: ED 81       STD    ,X++
B434: 8C 24 10    CMPX   #$2410
B437: 25 F9       BCS    $B432
B439: 8E 24 00    LDX    #$2400
B43C: 86 4C       LDA    #$4C
B43E: A7 01       STA    $1,X
B440: CC 00 2C    LDD    #$002C
B443: ED 03       STD    $3,X
B445: 86 42       LDA    #$42
B447: A7 05       STA    $5,X
B449: 86 FF       LDA    #$FF
B44B: A7 07       STA    $7,X
B44D: 86 EE       LDA    #$EE
B44F: B7 14 52    STA    $1452
B452: BD D0 8A    JSR    $D08A
B455: 8E B6 DA    LDX    #$B6DA
B458: CE 06 89    LDU    #$0689
B45B: C6 07       LDB    #$07
B45D: BD F3 D0    JSR    $F3D0
B460: 86 14       LDA    #$14
B462: BD D0 93    JSR    $D093
B465: B6 13 9E    LDA    $139E
B468: F6 13 9F    LDB    $139F
B46B: 27 01       BEQ    $B46E
B46D: 4A          DECA
B46E: B7 13 9E    STA    $139E
B471: 81 0A       CMPA   #$0A
B473: 25 0C       BCS    $B481
B475: C6 01       LDB    #$01
B477: F7 05 A9    STB    $05A9
B47A: C6 02       LDB    #$02
B47C: F7 0D A9    STB    $0DA9
B47F: 80 0A       SUBA   #$0A
B481: B7 05 89    STA    $0589
B484: C6 02       LDB    #$02
B486: F7 0D 89    STB    $0D89
B489: 86 AB       LDA    #$AB
B48B: B7 05 49    STA    $0549
B48E: C6 07       LDB    #$07
B490: F7 0D 49    STB    $0D49
B493: 86 14       LDA    #$14
B495: BD D0 93    JSR    $D093
B498: B6 13 9E    LDA    $139E
B49B: 48          ASLA
B49C: B7 13 8C    STA    $138C
B49F: BD F4 C7    JSR    $F4C7
B4A2: CE 05 09    LDU    #$0509
B4A5: C6 03       LDB    #$03
B4A7: B6 13 8E    LDA    $138E
B4AA: 84 F0       ANDA   #$F0
B4AC: 27 0A       BEQ    $B4B8
B4AE: 44          LSRA
B4AF: 44          LSRA
B4B0: 44          LSRA
B4B1: 44          LSRA
B4B2: A7 C4       STA    ,U
B4B4: E7 C9 08 00 STB    $0800,U
B4B8: 33 C8 E0    LEAU   -$20,U
B4BB: B6 13 8E    LDA    $138E
B4BE: 84 0F       ANDA   #$0F
B4C0: A7 C4       STA    ,U
B4C2: E7 C9 08 00 STB    $0800,U
B4C6: 33 C8 E0    LEAU   -$20,U
B4C9: 6F C4       CLR    ,U
B4CB: E7 C9 08 00 STB    $0800,U
B4CF: 6F C8 E0    CLR    -$20,U
B4D2: E7 C9 07 E0 STB    $07E0,U
B4D6: 79 13 8E    ROL    $138E
B4D9: 79 13 8D    ROL    $138D
B4DC: 79 13 8E    ROL    $138E
B4DF: 79 13 8D    ROL    $138D
B4E2: 79 13 8E    ROL    $138E
B4E5: 79 13 8D    ROL    $138D
B4E8: 79 13 8E    ROL    $138E
B4EB: 79 13 8D    ROL    $138D
B4EE: 86 3C       LDA    #$3C
B4F0: BD D0 93    JSR    $D093
B4F3: 8E 24 08    LDX    #$2408
B4F6: 6F 1F       CLR    -$1,X
B4F8: 86 50       LDA    #$50
B4FA: A7 01       STA    $1,X
B4FC: CC 00 20    LDD    #$0020
B4FF: ED 03       STD    $3,X
B501: 86 60       LDA    #$60
B503: A7 05       STA    $5,X
B505: 86 0C       LDA    #$0C
B507: A7 06       STA    $6,X
B509: 86 FF       LDA    #$FF
B50B: A7 07       STA    $7,X
B50D: 86 0A       LDA    #$0A
B50F: BD D0 93    JSR    $D093
B512: 8E B6 E1    LDX    #$B6E1
B515: CE 06 8E    LDU    #$068E
B518: C6 07       LDB    #$07
B51A: BD F3 D0    JSR    $F3D0
B51D: 86 14       LDA    #$14
B51F: BD D0 93    JSR    $D093
B522: B6 13 9F    LDA    $139F
B525: 27 0A       BEQ    $B531
B527: 86 02       LDA    #$02
B529: BB 13 8D    ADDA   $138D
B52C: B7 13 8D    STA    $138D
B52F: 86 01       LDA    #$01
B531: B7 05 8E    STA    $058E
B534: C6 02       LDB    #$02
B536: F7 0D 8E    STB    $0D8E
B539: 86 AB       LDA    #$AB
B53B: B7 05 4E    STA    $054E
B53E: C6 07       LDB    #$07
B540: F7 0D 4E    STB    $0D4E
B543: 86 14       LDA    #$14
B545: BD D0 93    JSR    $D093
B548: CE 05 0E    LDU    #$050E
B54B: C6 01       LDB    #$01
B54D: B6 13 9F    LDA    $139F
B550: 27 08       BEQ    $B55A
B552: 86 02       LDA    #$02
B554: A7 C4       STA    ,U
B556: E7 C9 08 00 STB    $0800,U
B55A: 33 C8 E0    LEAU   -$20,U
B55D: 6F C4       CLR    ,U
B55F: E7 C9 08 00 STB    $0800,U
B563: 6F C8 E0    CLR    -$20,U
B566: E7 C9 07 E0 STB    $07E0,U
B56A: 6F C8 C0    CLR    -$40,U
B56D: E7 C9 07 C0 STB    $07C0,U
B571: 86 3C       LDA    #$3C
B573: BD D0 93    JSR    $D093
B576: 8E B6 BD    LDX    #$B6BD
B579: CE 06 F3    LDU    #$06F3
B57C: C6 07       LDB    #$07
B57E: BD F3 D0    JSR    $F3D0
B581: 86 AB       LDA    #$AB
B583: A7 C4       STA    ,U
B585: C6 07       LDB    #$07
B587: E7 C9 08 00 STB    $0800,U
B58B: 86 14       LDA    #$14
B58D: BD D0 93    JSR    $D093
B590: CE 05 13    LDU    #$0513
B593: C6 02       LDB    #$02
B595: B6 13 9E    LDA    $139E
B598: 81 0F       CMPA   #$0F
B59A: 27 03       BEQ    $B59F
B59C: 4F          CLRA
B59D: 20 16       BRA    $B5B5
B59F: B6 13 9F    LDA    $139F
B5A2: 27 11       BEQ    $B5B5
B5A4: 86 05       LDA    #$05
B5A6: BB 13 8D    ADDA   $138D
B5A9: 19          DAA
B5AA: B7 13 8D    STA    $138D
B5AD: 86 05       LDA    #$05
B5AF: A7 C4       STA    ,U
B5B1: E7 C9 08 00 STB    $0800,U
B5B5: 33 C8 E0    LEAU   -$20,U
B5B8: 6F C4       CLR    ,U
B5BA: E7 C9 08 00 STB    $0800,U
B5BE: 6F C8 E0    CLR    -$20,U
B5C1: E7 C9 07 E0 STB    $07E0,U
B5C5: 6F C8 C0    CLR    -$40,U
B5C8: E7 C9 07 C0 STB    $07C0,U
B5CC: 86 3C       LDA    #$3C
B5CE: BD D0 93    JSR    $D093
B5D1: 8E B6 D1    LDX    #$B6D1
B5D4: CE 06 19    LDU    #$0619
B5D7: C6 0B       LDB    #$0B
B5D9: BD F3 D0    JSR    $F3D0
B5DC: 86 AB       LDA    #$AB
B5DE: A7 C4       STA    ,U
B5E0: C6 07       LDB    #$07
B5E2: E7 C9 08 00 STB    $0800,U
B5E6: 86 14       LDA    #$14
B5E8: BD D0 93    JSR    $D093
B5EB: CE 05 19    LDU    #$0519
B5EE: B6 13 8D    LDA    $138D
B5F1: 84 10       ANDA   #$10
B5F3: 27 12       BEQ    $B607
B5F5: 86 01       LDA    #$01
B5F7: A7 C4       STA    ,U
B5F9: 6F C8 E0    CLR    -$20,U
B5FC: 6F C8 C0    CLR    -$40,U
B5FF: 6F C8 A0    CLR    -$60,U
B602: 6F C8 80    CLR    -$80,U
B605: 20 1B       BRA    $B622
B607: B6 13 8D    LDA    $138D
B60A: 84 0F       ANDA   #$0F
B60C: 27 02       BEQ    $B610
B60E: A7 C4       STA    ,U
B610: 33 C8 E0    LEAU   -$20,U
B613: B6 13 8E    LDA    $138E
B616: 44          LSRA
B617: 44          LSRA
B618: 44          LSRA
B619: 44          LSRA
B61A: A7 C4       STA    ,U
B61C: 6F C8 E0    CLR    -$20,U
B61F: 6F C8 C0    CLR    -$40,U
B622: 86 28       LDA    #$28
B624: BD D0 93    JSR    $D093
B627: 8E 13 8D    LDX    #$138D
B62A: BD F2 63    JSR    $F263
B62D: BD D0 8A    JSR    $D08A
B630: B6 15 15    LDA    $1515
B633: 81 09       CMPA   #$09
B635: 26 3C       BNE    $B673
B637: 96 31       LDA    <$31
B639: 81 0A       CMPA   #$0A
B63B: 26 36       BNE    $B673
B63D: 8E 43 00    LDX    #$4300
B640: CE 06 9D    LDU    #$069D
B643: C6 07       LDB    #$07
B645: A6 80       LDA    ,X+
B647: 80 31       SUBA   #$31
B649: 81 2F       CMPA   #$2F
B64B: 27 0B       BEQ    $B658
B64D: A7 C4       STA    ,U
B64F: E7 C9 08 00 STB    $0800,U
B653: 33 C8 E0    LEAU   -$20,U
B656: 20 ED       BRA    $B645
B658: CE 06 FF    LDU    #$06FF
B65B: C6 07       LDB    #$07
B65D: A6 80       LDA    ,X+
B65F: 81 2F       CMPA   #$2F
B661: 27 10       BEQ    $B673
B663: A7 C4       STA    ,U
B665: E7 C9 08 00 STB    $0800,U
B669: 33 C8 E0    LEAU   -$20,U
B66C: 20 EF       BRA    $B65D
B66E: 86 5A       LDA    #$5A
B670: BD D0 93    JSR    $D093
B673: 7F 15 15    CLR    $1515
B676: 86 5A       LDA    #$5A
B678: BD D0 93    JSR    $D093
B67B: 0C 31       INC    <$31
B67D: 0F 33       CLR    <$33
B67F: 0F 3E       CLR    <$3E
B681: 0F 32       CLR    <$32
B683: 7F 14 52    CLR    $1452
B686: BD BE 0D    JSR    $BE0D
B689: 7E AB 3C    JMP    $AB3C

B734: B6 13 93    LDA    $1393                                      
B737: 27 05       BEQ    $B73E                                      
B739: B7 50 05    STA    $5005                                      
B73C: 20 03       BRA    $B741                                      
B73E: B7 50 04    STA    $5004                                      
B741: 96 3E       LDA    <$3E                                       
B743: 27 03       BEQ    $B748                                      
B745: 7E AB 5B    JMP    $AB5B
B748: 96 31       LDA    <$31
B74A: 10 26 F4 0D LBNE   $AB5B
B74E: 86 FF       LDA    #$FF
B750: B7 13 89    STA    scroll_value_1389
B753: B7 40 40    STA    $4040
B756: BD B9 38    JSR    $B938
B759: BD D0 8A    JSR    $D08A
l_b75c:
B75C: 8E 04 1E    LDX    #$041E
B75F: CC 5C 5C    LDD    #$5C5C
B762: ED 84       STD    ,X
B764: 30 88 20    LEAX   $20,X
B767: 8C 07 80    CMPX   #$0780
B76A: 25 F6       BCS    $B762
B76C: 8E B9 49    LDX    #$B949
B76F: CE 06 EB    LDU    #$06EB
B772: C6 02       LDB    #$02
B774: BD F3 D0    JSR    $F3D0
B777: 8E AC 26    LDX    #$AC26
B77A: CE 06 AF    LDU    #$06AF
B77D: C6 00       LDB    #$00
B77F: BD F3 D0    JSR    $F3D0
B782: B6 13 81    LDA    $1381
B785: 4C          INCA
B786: A7 C9 01 20 STA    $0120,U
B78A: B6 13 63    LDA    $1363
B78D: 34 02       PSHS   A
B78F: 7F 13 63    CLR    $1363
B792: BD BC AC    JSR    $BCAC
B795: 35 02       PULS   A
B797: B7 13 63    STA    $1363
B79A: 86 FE       LDA    #$FE
B79C: B7 22 F0    STA    $22F0
B79F: 8E 22 00    LDX    #$2200
B7A2: 86 E0       LDA    #$E0
B7A4: 97 04       STA    <$04
B7A6: A7 04       STA    $4,X
B7A8: A7 88 34    STA    $34,X
B7AB: A7 88 64    STA    $64,X
B7AE: A7 89 00 94 STA    $0094,X
B7B2: CC 00 C8    LDD    #$00C8
B7B5: DD 01       STD    <$01
B7B7: CC 00 40    LDD    #$0040
B7BA: ED 89 00 91 STD    $0091,X
B7BE: CC 00 58    LDD    #$0058
B7C1: ED 88 61    STD    $61,X
B7C4: CC 00 70    LDD    #$0070
B7C7: ED 88 31    STD    $31,X
B7CA: CC 00 A8    LDD    #$00A8
B7CD: ED 01       STD    $1,X
B7CF: 86 08       LDA    #$08
B7D1: A7 0D       STA    $D,X
B7D3: A7 88 3D    STA    $3D,X
B7D6: A7 88 6D    STA    $6D,X
B7D9: A7 89 00 9D STA    $009D,X
B7DD: 86 01       LDA    #$01
B7DF: B7 14 40    STA    $1440
B7E2: 86 08       LDA    #$08
B7E4: B7 14 05    STA    $1405
B7E7: BD D0 8A    JSR    $D08A
l_b7ea:
B7EA: 7C 14 42    INC    $1442
B7ED: 7C 14 45    INC    $1445
B7F0: 7C 14 44    INC    $1444
B7F3: BD D0 8A    JSR    $D08A
l_b7f6:
B7F6: 8E 22 90    LDX    #$2290
B7F9: A6 88 26    LDA    $26,X
B7FC: 26 01       BNE    $B7FF
B7FE: 39          RTS
B7FF: 86 FE       LDA    #$FE
B801: A7 84       STA    ,X
B803: BD D0 8A    JSR    $D08A
l_b806:
B806: 8E 22 60    LDX    #$2260
B809: A6 88 26    LDA    $26,X
B80C: 26 01       BNE    $B80F
B80E: 39          RTS
B80F: 86 FE       LDA    #$FE
B811: A7 84       STA    ,X
B813: BD D0 8A    JSR    $D08A
l_b816:
B816: 8E 22 30    LDX    #$2230
B819: A6 88 26    LDA    $26,X
B81C: 26 01       BNE    $B81F
B81E: 39          RTS
B81F: 7F 14 44    CLR    $1444
B822: BD D0 8A    JSR    $D08A
l_b825:
B825: 8E 22 00    LDX    #$2200
B828: A6 88 26    LDA    $26,X
B82B: 26 01       BNE    $B82E
B82D: 39          RTS
B82E: 7F 14 45    CLR    $1445
B831: BD D0 8A    JSR    $D08A
l_b834:
B834: DC 01       LDD    <$01
B836: 2B 01       BMI    $B839
B838: 39          RTS
B839: 10 83 FF E8 CMPD   #$FFE8
B83D: 23 01       BLS    $B840
B83F: 39          RTS
B840: 7F 14 42    CLR    $1442
B843: 7F 11 9A    CLR    $119A
B846: BD D0 8A    JSR    $D08A
l_b849:
B849: B6 40 40    LDA    $4040
B84C: 27 01       BEQ    $B84F
B84E: 39          RTS
B84F: BD F3 5B    JSR    $F35B
B852: 4F          CLRA
B853: BD F3 69    JSR    $F369
B856: BD BC AC    JSR    $BCAC
B859: CC 01 C8    LDD    #$01C8
B85C: DD 01       STD    <$01
B85E: 7F 13 89    CLR    scroll_value_1389
B861: BD D0 8A    JSR    $D08A
l_b864:
B864: BD E1 01    JSR    $E101
B867: 86 20       LDA    #$20
B869: B7 00 7B    STA    >$007B
B86C: B7 00 7C    STA    >$007C
B86F: B7 00 7D    STA    >$007D
B872: BD D0 8A    JSR    $D08A
l_b875:
B875: 86 01       LDA    #$01
B877: B7 14 46    STA    $1446
B87A: B7 14 49    STA    $1449
B87D: B7 14 4C    STA    $144C
B880: BD D0 8A    JSR    $D08A
l_b883:
B883: 86 1E       LDA    #$1E
B885: BD D0 93    JSR    $D093
l_b888:
B888: 86 01       LDA    #$01
B88A: B7 14 42    STA    $1442
B88D: 86 01       LDA    #$01
B88F: B7 40 41    STA    $4041
B892: 86 01       LDA    #$01
B894: B7 14 40    STA    $1440
B897: 86 08       LDA    #$08
B899: B7 14 05    STA    $1405
B89C: BD D0 8A    JSR    $D08A
l_b89f:
B89F: B6 40 41    LDA    $4041
B8A2: 27 01       BEQ    $B8A5
B8A4: 39          RTS
B8A5: 86 01       LDA    #$01
B8A7: B7 14 40    STA    $1440
B8AA: 86 00       LDA    #$00
B8AC: B7 14 05    STA    $1405
B8AF: BD D0 8A    JSR    $D08A
l_b8b2:
B8B2: 96 00       LDA    <$00
B8B4: 27 01       BEQ    $B8B7
B8B6: 39          RTS
B8B7: 8E 00 7B    LDX    #$007B
B8BA: 86 1D       LDA    #$1D
B8BC: A7 80       STA    ,X+
B8BE: A7 80       STA    ,X+
B8C0: A7 84       STA    ,X
B8C2: 86 18       LDA    #$18
B8C4: B7 13 B2    STA    $13B2
B8C7: BD D0 8A    JSR    $D08A
l_b8ca:
B8CA: 7C 13 89    INC    scroll_value_1389
B8CD: 0C 02       INC    <$02
B8CF: B6 13 B2    LDA    $13B2
B8D2: 27 01       BEQ    $B8D5
B8D4: 39          RTS
B8D5: 86 02       LDA    #$02
B8D7: 97 0C       STA    <$0C
B8D9: 86 3F       LDA    #$3F
B8DB: B7 00 BC    STA    >$00BC
B8DE: 86 09       LDA    #$09
B8E0: B7 08 BC    STA    $08BC
B8E3: 86 14       LDA    #$14
B8E5: BD D0 93    JSR    $D093
l_b8e8:
B8E8: 7C 14 48    INC    $1448
B8EB: 86 1E       LDA    #$1E
B8ED: BD D0 93    JSR    $D093
l_b8f0:
B8F0: 9E 15       LDX    <$15
B8F2: EE 05       LDU    $5,X
B8F4: 33 C9 08 00 LEAU   $0800,U
B8F8: 86 00       LDA    #$00
B8FA: C6 05       LDB    #$05
B8FC: A7 C4       STA    ,U
B8FE: 33 C8 E0    LEAU   -$20,U
B901: 5A          DECB
B902: 26 F8       BNE    $B8FC
B904: 33 C9 00 81 LEAU   $0081,U
B908: C6 03       LDB    #$03
B90A: A7 C4       STA    ,U
B90C: 33 C8 E0    LEAU   -$20,U
B90F: 5A          DECB
B910: 26 F8       BNE    $B90A
B912: 86 1E       LDA    #$1E
B914: BD D0 93    JSR    $D093
l_b917:
B917: 86 20       LDA    #$20
B919: B7 00 BC    STA    >$00BC
B91C: 0F 0C       CLR    <$0C
B91E: DC 01       LDD    <$01
B920: 83 00 17    SUBD   #$0017
B923: DD 01       STD    <$01
B925: 86 70       LDA    #$70
B927: B7 14 02    STA    $1402
B92A: 9E 15       LDX    <$15
B92C: 6F 02       CLR    $2,X
B92E: 0C 3E       INC    <$3E
B930: 0C 3F       INC    <$3F
B932: 7F 13 96    CLR    $1396
B935: 7E AC 37    JMP    $AC37
B938: 86 FF       LDA    #$FF
B93A: B7 13 89    STA    scroll_value_1389
B93D: BD F3 AA    JSR    $F3AA
B940: BD F3 5B    JSR    $F35B
B943: 86 00       LDA    #$00
B945: BD F3 69    JSR    $F369
B948: 39          RTS

B95D: 8E 20 36    LDX    #$2036                                      
B960: CE 14 80    LDU    #$1480
B963: EC 84       LDD    ,X
B965: A3 C4       SUBD   ,U
B967: 22 0B       BHI    $B974
B969: 25 06       BCS    $B971
B96B: A6 02       LDA    $2,X
B96D: A0 42       SUBA   $2,U
B96F: 24 03       BCC    $B974
B971: 7E AF F8    JMP    $AFF8
B974: 10 8E 00 04 LDY    #$0004
B978: EC 81       LDD    ,X++
B97A: ED C1       STD    ,U++
B97C: 31 3F       LEAY   -$1,Y
B97E: 26 F8       BNE    $B978
B980: 86 04       LDA    #$04
B982: B7 13 97    STA    $1397
B985: 8E 14 78    LDX    #$1478
B988: CE 14 80    LDU    #$1480
B98B: 34 10       PSHS   X
B98D: EC C4       LDD    ,U
B98F: A3 84       SUBD   ,X
B991: 22 08       BHI    $B99B
B993: 25 3B       BCS    $B9D0
B995: A6 42       LDA    $2,U
B997: A0 02       SUBA   $2,X
B999: 25 35       BCS    $B9D0
B99B: 10 8E 00 04 LDY    #$0004
B99F: EC 81       LDD    ,X++
B9A1: ED C1       STD    ,U++
B9A3: 31 3F       LEAY   -$1,Y
B9A5: 26 F8       BNE    $B99F
B9A7: 35 40       PULS   U
B9A9: 34 40       PSHS   U
B9AB: 8E 20 36    LDX    #$2036
B9AE: 10 8E 00 04 LDY    #$0004
B9B2: EC 81       LDD    ,X++
B9B4: ED C1       STD    ,U++
B9B6: 31 3F       LEAY   -$1,Y
B9B8: 26 F8       BNE    $B9B2
B9BA: 35 40       PULS   U
B9BC: 11 83 14 60 CMPU   #$1460
B9C0: 26 05       BNE    $B9C7
B9C2: 7F 13 97    CLR    $1397
B9C5: 20 0D       BRA    $B9D4
B9C7: 1F 31       TFR    U,X
B9C9: 30 18       LEAX   -$8,X
B9CB: 7A 13 97    DEC    $1397
B9CE: 20 BB       BRA    $B98B
B9D0: 35 40       PULS   U
B9D2: 33 48       LEAU   $8,U
B9D4: FC 14 8A    LDD    $148A
B9D7: ED 43       STD    $3,U
B9D9: CC 5F 5F    LDD    #$5F5F
B9DC: ED 45       STD    $5,U
B9DE: A7 47       STA    $7,U
B9E0: 33 45       LEAU   $5,U
B9E2: FF 14 88    STU    $1488
B9E5: BD D0 8A    JSR    $D08A
B9E8: 8E 20 A0    LDX    #$20A0
B9EB: 6F 80       CLR    ,X+
B9ED: 8C 20 A7    CMPX   #$20A7
B9F0: 26 F9       BNE    $B9EB
B9F2: 86 FF       LDA    #$FF
B9F4: A7 84       STA    ,X
B9F6: BD E3 83    JSR    $E383
B9F9: B6 13 97    LDA    $1397
B9FC: 48          ASLA
B9FD: BB 13 97    ADDA   $1397
BA00: 8E 0B 4F    LDX    #$0B4F
BA03: 30 86       LEAX   A,X
BA05: 86 02       LDA    #$02
BA07: A7 84       STA    ,X
BA09: 30 88 E0    LEAX   -$20,X
BA0C: 8C 08 CF    CMPX   #$08CF
BA0F: 22 F6       BHI    $BA07
BA11: 8E 22 00    LDX    #$2200
BA14: CC 01 54    LDD    #$0154
BA17: ED 01       STD    $1,X
BA19: 86 20       LDA    #$20
BA1B: A7 04       STA    $4,X
BA1D: CC 01 00    LDD    #$0100
BA20: ED 06       STD    $6,X
BA22: 6F 0D       CLR    $D,X
BA24: CE E4 DE    LDU    #$E4DE
BA27: EF 0E       STU    $E,X
BA29: 6F 88 1B    CLR    $1B,X
BA2C: 7C 14 45    INC    $1445
BA2F: 7C 40 4D    INC    $404D
BA32: BD D0 8A    JSR    $D08A
BA35: BD BC 06    JSR    $BC06
BA38: B6 13 89    LDA    scroll_value_1389
BA3B: 80 02       SUBA   #$02
BA3D: B7 13 89    STA    scroll_value_1389
BA40: 81 13       CMPA   #$13
BA42: 27 01       BEQ    $BA45
BA44: 39          RTS
BA45: 86 6C       LDA    #$6C
BA47: BD D0 93    JSR    $D093
BA4A: 8E BC 1F    LDX    #$BC1F
BA4D: CE 03 48    LDU    #$0348
BA50: C6 00       LDB    #$00
BA52: BD F3 D0    JSR    $F3D0
BA55: 86 08       LDA    #$08
BA57: B7 22 0D    STA    $220D
BA5A: BD BC 06    JSR    $BC06
BA5D: B6 13 97    LDA    $1397
BA60: 48          ASLA
BA61: BB 13 97    ADDA   $1397
BA64: 8E 01 2F    LDX    #$012F
BA67: 30 86       LEAX   A,X
BA69: BF 14 8C    STX    $148C
BA6C: 86 0D       LDA    #$0D
BA6E: A7 89 08 00 STA    $0800,X
BA72: 7F 13 98    CLR    $1398
BA75: 86 00       LDA    #$00
BA77: B7 14 40    STA    $1440
BA7A: 86 00       LDA    #$00
BA7C: B7 14 05    STA    $1405
BA7F: 86 00       LDA    #$00
BA81: B7 14 41    STA    $1441
BA84: 86 00       LDA    #$00
BA86: B7 14 08    STA    $1408
BA89: BD D0 8A    JSR    $D08A
BA8C: BD BC 06    JSR    $BC06
BA8F: B6 40 4D    LDA    $404D
BA92: 26 0B       BNE    $BA9F
BA94: A6 9F 14 8C LDA    [$148C]
BA98: A7 9F 14 88 STA    [$1488]
BA9C: 7E BB 27    JMP    $BB27
BA9F: B6 13 B2    LDA    $13B2
BAA2: 85 08       BITA   #$08
BAA4: 26 15       BNE    $BABB
BAA6: B6 13 98    LDA    $1398
BAA9: 88 01       EORA   #$01
BAAB: B7 13 98    STA    $1398
BAAE: 8E 0B 48    LDX    #$0B48
BAB1: A7 84       STA    ,X
BAB3: 30 88 E0    LEAX   -$20,X
BAB6: 8C 08 88    CMPX   #$0888
BAB9: 26 F6       BNE    $BAB1
BABB: 96 3D       LDA    <$3D
BABD: 85 01       BITA   #$01
BABF: 27 27       BEQ    $BAE8
BAC1: BE 14 8C    LDX    $148C
BAC4: FE 14 88    LDU    $1488
BAC7: A6 84       LDA    ,X
BAC9: A7 C4       STA    ,U
BACB: 33 41       LEAU   $1,U
BACD: FF 14 88    STU    $1488
BAD0: 86 02       LDA    #$02
BAD2: A7 89 08 00 STA    $0800,X
BAD6: 30 88 E0    LEAX   -$20,X
BAD9: 8C 00 EF    CMPX   #$00EF
BADC: 25 49       BCS    $BB27
BADE: BF 14 8C    STX    $148C
BAE1: C6 0D       LDB    #$0D
BAE3: E7 89 08 00 STB    $0800,X
BAE7: 39          RTS
BAE8: B6 13 B5    LDA    $13B5
BAEB: 85 10       BITA   #$10
BAED: 27 01       BEQ    $BAF0
BAEF: 39          RTS
BAF0: 96 0D       LDA    <$0D
BAF2: 26 01       BNE    $BAF5
BAF4: 39          RTS
BAF5: 7F 13 B5    CLR    $13B5
BAF8: BE 14 8C    LDX    $148C
BAFB: 85 08       BITA   #$08
BAFD: 26 14       BNE    $BB13
BAFF: A6 84       LDA    ,X
BB01: 4C          INCA
BB02: 81 5B       CMPA   #$5B
BB04: 26 04       BNE    $BB0A
BB06: 86 5F       LDA    #$5F
BB08: 20 06       BRA    $BB10
BB0A: 81 60       CMPA   #$60
BB0C: 26 02       BNE    $BB10
BB0E: 86 41       LDA    #$41
BB10: A7 84       STA    ,X
BB12: 39          RTS
BB13: A6 84       LDA    ,X
BB15: 4A          DECA
BB16: 81 40       CMPA   #$40
BB18: 26 04       BNE    $BB1E
BB1A: 86 5F       LDA    #$5F
BB1C: 20 06       BRA    $BB24
BB1E: 81 5E       CMPA   #$5E
BB20: 26 02       BNE    $BB24
BB22: 86 5A       LDA    #$5A
BB24: A7 84       STA    ,X
BB26: 39          RTS
BB27: BD BC 06    JSR    $BC06
BB2A: 7F 40 4D    CLR    $404D
BB2D: 8E 03 48    LDX    #$0348
BB30: 86 20       LDA    #$20
BB32: A7 84       STA    ,X
BB34: 30 88 E0    LEAX   -$20,X
BB37: 8C 00 C8    CMPX   #$00C8
BB3A: 22 F6       BHI    $BB32
BB3C: 7F 13 98    CLR    $1398
BB3F: B6 13 97    LDA    $1397
BB42: 48          ASLA
BB43: BB 13 97    ADDA   $1397
BB46: 8E 0B 4F    LDX    #$0B4F
BB49: 30 86       LEAX   A,X
BB4B: BF 14 8C    STX    $148C
BB4E: 86 01       LDA    #$01
BB50: B7 13 98    STA    $1398
BB53: BD D0 8A    JSR    $D08A
BB56: BD BC 06    JSR    $BC06
BB59: BD BB E8    JSR    $BBE8
BB5C: 86 01       LDA    #$01
BB5E: B7 40 4E    STA    $404E
BB61: 86 E0       LDA    #$E0
BB63: B7 13 B2    STA    $13B2
BB66: BD D0 8A    JSR    $D08A
BB69: BD BC 06    JSR    $BC06
BB6C: FC 22 01    LDD    $2201
BB6F: 83 01 54    SUBD   #$0154
BB72: C3 00 01    ADDD   #$0001
BB75: 10 83 00 02 CMPD   #$0002
BB79: 25 08       BCS    $BB83
BB7B: 8D 6B       BSR    $BBE8
BB7D: B6 13 B2    LDA    $13B2
BB80: 27 01       BEQ    $BB83
BB82: 39          RTS
BB83: 7F 22 0D    CLR    $220D
BB86: BD D0 8A    JSR    $D08A
BB89: 8D 5D       BSR    $BBE8
BB8B: B6 13 B2    LDA    $13B2
BB8E: 27 01       BEQ    $BB91
BB90: 39          RTS
BB91: 86 B4       LDA    #$B4
BB93: B7 13 B2    STA    $13B2
BB96: BD D0 8A    JSR    $D08A
BB99: 8D 4D       BSR    $BBE8
BB9B: B6 13 B2    LDA    $13B2
BB9E: 27 01       BEQ    $BBA1
BBA0: 39          RTS
BBA1: 86 08       LDA    #$08
BBA3: B7 22 0D    STA    $220D
BBA6: CC 02 80    LDD    #$0280
BBA9: FD 22 08    STD    $2208
BBAC: BD D0 8A    JSR    $D08A
BBAF: 8D 37       BSR    $BBE8
BBB1: B6 13 89    LDA    scroll_value_1389
BBB4: 8B 01       ADDA   #$01
BBB6: B7 13 89    STA    scroll_value_1389
BBB9: B6 22 04    LDA    $2204
BBBC: 81 E8       CMPA   #$E8
BBBE: 22 01       BHI    $BBC1
BBC0: 39          RTS
BBC1: 7F 14 45    CLR    $1445
BBC4: 7F 11 9C    CLR    $119C
BBC7: 7F 11 80    CLR    $1180
BBCA: BD D0 8A    JSR    $D08A
BBCD: 8D 19       BSR    $BBE8
BBCF: B6 13 89    LDA    scroll_value_1389
BBD2: 8B 01       ADDA   #$01
BBD4: B7 13 89    STA    scroll_value_1389
BBD7: 81 FF       CMPA   #$FF
BBD9: 27 01       BEQ    $BBDC
BBDB: 39          RTS
BBDC: BD D0 8A    JSR    $D08A
BBDF: B6 40 4E    LDA    $404E
BBE2: 27 01       BEQ    $BBE5
BBE4: 39          RTS
BBE5: 7E AF F8    JMP    $AFF8
BBE8: B6 13 B5    LDA    $13B5
BBEB: 85 08       BITA   #$08
BBED: 27 01       BEQ    $BBF0
BBEF: 39          RTS
BBF0: B6 13 98    LDA    $1398
BBF3: 88 01       EORA   #$01
BBF5: B7 13 98    STA    $1398
BBF8: BE 14 8C    LDX    $148C
BBFB: A7 84       STA    ,X
BBFD: 30 88 E0    LEAX   -$20,X
BC00: 8C 08 CF    CMPX   #$08CF
BC03: 22 F6       BHI    $BBFB
BC05: 39          RTS
BC06: FC 22 01    LDD    $2201
BC09: 10 83 01 10 CMPD   #$0110
BC0D: 23 07       BLS    $BC16
BC0F: 10 83 01 98 CMPD   #$0198
BC13: 24 01       BCC    $BC16
BC15: 39          RTS
BC16: B6 22 0D    LDA    $220D
BC19: 88 0A       EORA   #$0A
BC1B: B7 22 0D    STA    $220D
BC1E: 39          RTS

BC34: 86 01       LDA    #$01                                       
BC36: C6 0F       LDB    #$0F                                       
BC38: 20 03       BRA    $BC3D                                      
BC3A: 4F          CLRA                                                
BC3B: C6 12       LDB    #$12
BC3D: 8E 14 42    LDX    #$1442
BC40: A7 80       STA    ,X+
BC42: 5A          DECB
BC43: 26 FB       BNE    $BC40
BC45: 7F 14 53    CLR    $1453
BC48: 39          RTS
BC49: 7F 13 81    CLR    $1381
BC4C: 8E 20 30    LDX    #$2030
BC4F: B6 13 64    LDA    $1364
BC52: A7 80       STA    ,X+
BC54: 6F 80       CLR    ,X+
BC56: 8C 20 40    CMPX   #$2040
BC59: 26 F9       BNE    $BC54
BC5B: CE D4 03    LDU    #$D403
BC5E: F6 13 65    LDB    $1365
BC61: 58          ASLB
BC62: A6 D5       LDA    [B,U]
BC64: 26 06       BNE    $BC6C
BC66: 86 FF       LDA    #$FF
BC68: 97 39       STA    <$39
BC6A: 20 06       BRA    $BC72
BC6C: C6 01       LDB    #$01
BC6E: D7 39       STB    <$39
BC70: 97 3B       STA    <$3B
BC72: BD BE 0D    JSR    $BE0D
BC75: B6 13 80    LDA    $1380
BC78: 27 1E       BEQ    $BC98
BC7A: 8E 20 30    LDX    #$2030
BC7D: CE 1A 30    LDU    #$1A30
BC80: 10 8E 00 90 LDY    #$0090
BC84: EC 81       LDD    ,X++
BC86: ED C1       STD    ,U++
BC88: 31 3F       LEAY   -$1,Y
BC8A: 26 F8       BNE    $BC84
BC8C: 8E 10 04    LDX    #$1004
BC8F: C6 02       LDB    #$02
BC91: BD E3 27    JSR    $E327
BC94: 8D 05       BSR    $BC9B
BC96: 20 03       BRA    $BC9B
BC98: 7F 1A 30    CLR    $1A30
BC9B: B6 14 02    LDA    $1402
BC9E: 27 0B       BEQ    $BCAB
BCA0: 8E 10 02    LDX    #$1002
BCA3: C6 02       LDB    #$02
BCA5: BD E3 27    JSR    $E327
BCA8: 7C 10 14    INC    $1014
BCAB: 39          RTS
BCAC: 8D 03       BSR    $BCB1
BCAE: 7E BD 42    JMP    $BD42
BCB1: 8E 20 00    LDX    #$2000
BCB4: CC 00 00    LDD    #$0000
BCB7: ED 81       STD    ,X++
BCB9: 8C 20 30    CMPX   #$2030
BCBC: 26 F9       BNE    $BCB7
BCBE: 96 31       LDA    <$31
BCC0: 81 1F       CMPA   #$1F
BCC2: 23 02       BLS    $BCC6
BCC4: 86 1F       LDA    #$1F
BCC6: B7 13 94    STA    $1394
BCC9: FE 13 AA    LDU    $13AA
BCCC: E6 C6       LDB    A,U
BCCE: 58          ASLB
BCCF: EB C6       ADDB   A,U
BCD1: 4F          CLRA
BCD2: 58          ASLB
BCD3: 49          ROLA
BCD4: 8E D1 73    LDX    #$D173
BCD7: 30 8B       LEAX   D,X
BCD9: BF 13 AC    STX    $13AC
BCDC: CC 01 80    LDD    #$0180
BCDF: DD 01       STD    <$01
BCE1: 86 E0       LDA    #$E0
BCE3: 97 04       STA    <$04
BCE5: E6 84       LDB    ,X
BCE7: 4F          CLRA
BCE8: C3 00 E0    ADDD   #$00E0
BCEB: DD 06       STD    <$06
BCED: C3 01 00    ADDD   #$0100
BCF0: DD 08       STD    <$08
BCF2: CE 11 1A    LDU    #$111A
BCF5: DF 19       STU    <$19
BCF7: CE E4 D8    LDU    #$E4D8
BCFA: DF 0E       STU    <$0E
BCFC: CE 12 80    LDU    #$1280
BCFF: DF 1C       STU    <$1C
BD01: CE 12 80    LDU    #$1280
BD04: DF 1C       STU    <$1C
BD06: CC 00 00    LDD    #$0000
BD09: ED C1       STD    ,U++
BD0B: 11 83 13 40 CMPU   #$1340
BD0F: 26 F8       BNE    $BD09
BD11: CE 12 80    LDU    #$1280
BD14: 10 8E C8 72 LDY    #$C872
BD18: 4F          CLRA
BD19: E6 84       LDB    ,X
BD1B: C3 01 20    ADDD   #$0120
BD1E: ED 45       STD    $5,U
BD20: 10 AF 4E    STY    $E,U
BD23: CC CA 3C    LDD    #$CA3C
BD26: ED C8 1E    STD    $1E,U
BD29: CC CB 12    LDD    #$CB12
BD2C: ED C8 2E    STD    $2E,U
BD2F: CC 03 00    LDD    #$0300
BD32: ED C8 15    STD    $15,U
BD35: ED C8 25    STD    $25,U
BD38: 33 C8 30    LEAU   $30,U
BD3B: 11 83 13 40 CMPU   #$1340
BD3F: 26 D7       BNE    $BD18
BD41: 39          RTS
BD42: CE 22 00    LDU    #$2200
BD45: 6F C0       CLR    ,U+
BD47: 11 83 24 10 CMPU   #$2410
BD4B: 26 F8       BNE    $BD45
BD4D: CE 22 30    LDU    #$2230
BD50: 7F 13 D1    CLR    $13D1
BD53: 86 10       LDA    #$10
BD55: A7 C8 18    STA    $18,U
BD58: A7 4A       STA    $A,U
BD5A: CC 11 1E    LDD    #$111E
BD5D: FB 13 D1    ADDB   $13D1
BD60: ED C8 19    STD    $19,U
BD63: CC E4 D8    LDD    #$E4D8
BD66: ED 4E       STD    $E,U
BD68: CC C2 28    LDD    #$C228
BD6B: ED C8 21    STD    $21,U
BD6E: 7C 13 D1    INC    $13D1
BD71: 7C 13 D1    INC    $13D1
BD74: 33 C8 30    LEAU   $30,U
BD77: 11 83 24 10 CMPU   #$2410
BD7B: 26 D6       BNE    $BD53
BD7D: A6 05       LDA    $5,X
BD7F: C6 30       LDB    #$30
BD81: 3D          MUL
BD82: CE 22 30    LDU    #$2230
BD85: 33 CB       LEAU   D,U
BD87: C6 FE       LDB    #$FE
BD89: 11 83 24 10 CMPU   #$2410
BD8D: 27 07       BEQ    $BD96
BD8F: E7 C4       STB    ,U
BD91: 33 C8 30    LEAU   $30,U
BD94: 20 F3       BRA    $BD89
BD96: 10 8E D4 DE LDY    #$D4DE
BD9A: CE 22 30    LDU    #$2230
BD9D: A6 C4       LDA    ,U
BD9F: 81 FE       CMPA   #$FE
BDA1: 24 0D       BCC    $BDB0
BDA3: EC A1       LDD    ,Y++
BDA5: ED 41       STD    $1,U
BDA7: A6 A0       LDA    ,Y+
BDA9: A7 44       STA    $4,U
BDAB: 33 C8 30    LEAU   $30,U
BDAE: 20 ED       BRA    $BD9D
BDB0: CE 22 30    LDU    #$2230
BDB3: 10 8E 22 00 LDY    #$2200
BDB7: 4F          CLRA
BDB8: E6 01       LDB    $1,X
BDBA: C3 01 00    ADDD   #$0100
BDBD: ED 26       STD    $6,Y
BDBF: C3 01 00    ADDD   #$0100
BDC2: ED 28       STD    $8,Y
BDC4: 11 83 24 10 CMPU   #$2410
BDC8: 24 12       BCC    $BDDC
BDCA: 4F          CLRA
BDCB: E6 01       LDB    $1,X
BDCD: C3 00 E0    ADDD   #$00E0
BDD0: ED 46       STD    $6,U
BDD2: C3 01 00    ADDD   #$0100
BDD5: ED 48       STD    $8,U
BDD7: 33 C8 30    LEAU   $30,U
BDDA: 20 E8       BRA    $BDC4
BDDC: CC 01 80    LDD    #$0180
BDDF: ED 21       STD    $1,Y
BDE1: 86 40       LDA    #$40
BDE3: A7 24       STA    $4,Y
BDE5: 86 08       LDA    #$08
BDE7: A7 2A       STA    $A,Y
BDE9: A7 A8 18    STA    $18,Y
BDEC: 86 0C       LDA    #$0C
BDEE: A7 2D       STA    $D,Y
BDF0: A7 A8 23    STA    $23,Y
BDF3: CE 11 1C    LDU    #$111C
BDF6: EF A8 19    STU    $19,Y
BDF9: CE E4 D8    LDU    #$E4D8
BDFC: EF 2E       STU    $E,Y
BDFE: CE C3 F3    LDU    #$C3F3
BE01: EF A8 21    STU    $21,Y
BE04: A6 02       LDA    $2,X
BE06: B7 13 DD    STA    $13DD
BE09: 7F 14 54    CLR    $1454
BE0C: 39          RTS
BE0D: 8D 05       BSR    $BE14
BE0F: 8D 53       BSR    $BE64
BE11: 7E BE A4    JMP    $BEA4
BE14: 8E 20 40    LDX    #$2040
BE17: CC 00 00    LDD    #$0000
BE1A: ED 81       STD    ,X++
BE1C: 8C 20 9A    CMPX   #$209A
BE1F: 26 F9       BNE    $BE1A
BE21: CE 20 40    LDU    #$2040
BE24: 7F 13 92    CLR    $1392
BE27: B6 14 02    LDA    $1402
BE2A: 26 05       BNE    $BE31
BE2C: 8E D4 FD    LDX    #$D4FD
BE2F: 20 03       BRA    $BE34
BE31: 8E D4 DE    LDX    #$D4DE
BE34: 7F 13 9B    CLR    $139B
BE37: EC 81       LDD    ,X++
BE39: 81 FF       CMPA   #$FF
BE3B: 27 1B       BEQ    $BE58
BE3D: ED 45       STD    $5,U
BE3F: A6 80       LDA    ,X+
BE41: A7 47       STA    $7,U
BE43: B6 13 9B    LDA    $139B
BE46: 44          LSRA
BE47: 8B 20       ADDA   #$20
BE49: A7 41       STA    $1,U
BE4B: 6F C4       CLR    ,U
BE4D: 6F 43       CLR    $3,U
BE4F: 6F 42       CLR    $2,U
BE51: 33 49       LEAU   $9,U
BE53: 7C 13 9B    INC    $139B
BE56: 20 DF       BRA    $BE37
BE58: A7 5F       STA    -$1,U
BE5A: 8E 20 9A    LDX    #$209A
BE5D: BF 20 9A    STX    $209A
BE60: 7F 13 50    CLR    $1350
BE63: 39          RTS
BE64: 8E 20 A0    LDX    #$20A0
BE67: CC 00 00    LDD    #$0000
BE6A: ED 81       STD    ,X++
BE6C: 8C 21 00    CMPX   #$2100
BE6F: 26 F9       BNE    $BE6A
BE71: B6 14 02    LDA    $1402
BE74: 26 05       BNE    $BE7B
BE76: 8E D8 BC    LDX    #$D8BC
BE79: 20 0A       BRA    $BE85
BE7B: 8E D8 05    LDX    #$D805
BE7E: 96 31       LDA    <$31
BE80: 84 0F       ANDA   #$0F
BE82: 48          ASLA
BE83: AE 86       LDX    A,X
BE85: CE 20 A0    LDU    #$20A0
BE88: A6 80       LDA    ,X+
BE8A: 81 FF       CMPA   #$FF
BE8C: 27 13       BEQ    $BEA1
BE8E: C6 03       LDB    #$03
BE90: 6F C0       CLR    ,U+
BE92: 5A          DECB
BE93: 26 FB       BNE    $BE90
BE95: A7 C0       STA    ,U+
BE97: 6F C0       CLR    ,U+
BE99: EC 81       LDD    ,X++
BE9B: ED C1       STD    ,U++
BE9D: 6F C0       CLR    ,U+
BE9F: 20 E7       BRA    $BE88
BEA1: A7 5F       STA    -$1,U
BEA3: 39          RTS
BEA4: 8E 20 E0    LDX    #$20E0
BEA7: CC 00 00    LDD    #$0000
BEAA: ED 81       STD    ,X++
BEAC: 8C 21 A0    CMPX   #$21A0
BEAF: 26 F9       BNE    $BEAA
BEB1: B6 14 02    LDA    $1402
BEB4: 26 05       BNE    $BEBB
BEB6: 8E D9 5B    LDX    #$D95B
BEB9: 20 0A       BRA    $BEC5
BEBB: 8E D8 DC    LDX    #$D8DC
BEBE: 96 31       LDA    <$31
BEC0: 84 0F       ANDA   #$0F
BEC2: 48          ASLA
BEC3: AE 86       LDX    A,X
BEC5: CE 20 E0    LDU    #$20E0
BEC8: A6 84       LDA    ,X
BECA: 81 FF       CMPA   #$FF
BECC: 27 44       BEQ    $BF12
BECE: 84 0F       ANDA   #$0F
BED0: C6 C0       LDB    #$C0
BED2: 3D          MUL
BED3: ED 42       STD    $2,U
BED5: A6 80       LDA    ,X+
BED7: 44          LSRA
BED8: 44          LSRA
BED9: 44          LSRA
BEDA: 44          LSRA
BEDB: C6 04       LDB    #$04
BEDD: 3D          MUL
BEDE: E3 42       ADDD   $2,U
BEE0: C3 00 E7    ADDD   #$00E7
BEE3: ED 42       STD    $2,U
BEE5: A6 84       LDA    ,X
BEE7: 85 30       BITA   #$30
BEE9: 27 12       BEQ    $BEFD
BEEB: 85 10       BITA   #$10
BEED: 27 07       BEQ    $BEF6
BEEF: EC 42       LDD    $2,U
BEF1: C3 00 20    ADDD   #$0020
BEF4: 20 05       BRA    $BEFB
BEF6: EC 42       LDD    $2,U
BEF8: 83 00 20    SUBD   #$0020
BEFB: ED 42       STD    $2,U
BEFD: A6 84       LDA    ,X
BEFF: 84 01       ANDA   #$01
BF01: A7 44       STA    $4,U
BF03: A6 80       LDA    ,X+
BF05: 44          LSRA
BF06: 84 07       ANDA   #$07
BF08: A7 45       STA    $5,U
BF0A: 6F C4       CLR    ,U
BF0C: 6F 41       CLR    $1,U
BF0E: 33 48       LEAU   $8,U
BF10: 20 B6       BRA    $BEC8
BF12: A7 5F       STA    -$1,U
BF14: 96 31       LDA    <$31
BF16: 84 0F       ANDA   #$0F
BF18: 81 07       CMPA   #$07
BF1A: 25 3B       BCS    $BF57
BF1C: 81 09       CMPA   #$09
BF1E: 22 37       BHI    $BF57
BF20: 8E 21 A0    LDX    #$21A0
BF23: CC 00 00    LDD    #$0000
BF26: ED 81       STD    ,X++
BF28: 8C 21 C0    CMPX   #$21C0
BF2B: 26 F9       BNE    $BF26
BF2D: 8E 21 A0    LDX    #$21A0
BF30: CE 01 AB    LDU    #$01AB
BF33: EF 01       STU    $1,X
BF35: CE 00 0B    LDU    #$000B
BF38: EF 88 11    STU    $11,X
BF3B: 86 20       LDA    #$20
BF3D: A7 03       STA    $3,X
BF3F: A7 88 13    STA    $13,X
BF42: 86 25       LDA    #$25
BF44: A7 04       STA    $4,X
BF46: A7 88 14    STA    $14,X
BF49: CE CD 78    LDU    #$CD78
BF4C: EF 07       STU    $7,X
BF4E: EF 88 17    STU    $17,X
BF51: 86 FF       LDA    #$FF
BF53: A7 88 19    STA    $19,X
BF56: 39          RTS
BF57: 96 31       LDA    <$31
BF59: 84 0F       ANDA   #$0F
BF5B: 81 0B       CMPA   #$0B
BF5D: 24 01       BCC    $BF60
BF5F: 39          RTS
BF60: 81 0D       CMPA   #$0D
BF62: 23 01       BLS    $BF65
BF64: 39          RTS
BF65: 8E 21 C0    LDX    #$21C0
BF68: CC 00 00    LDD    #$0000
BF6B: ED 81       STD    ,X++
BF6D: 8C 21 E0    CMPX   #$21E0
BF70: 25 F9       BCS    $BF6B
BF72: 8E 21 C0    LDX    #$21C0
BF75: CE BF 94    LDU    #$BF94
BF78: 96 31       LDA    <$31
BF7A: 84 0F       ANDA   #$0F
BF7C: 80 0B       SUBA   #$0B
BF7E: 48          ASLA
BF7F: 48          ASLA
BF80: 33 C6       LEAU   A,U
BF82: EC C1       LDD    ,U++
BF84: ED 01       STD    $1,X
BF86: EC C4       LDD    ,U
BF88: ED 88 11    STD    $11,X
BF8B: CE CE 3C    LDU    #$CE3C
BF8E: EF 0E       STU    $E,X
BF90: EF 88 1E    STU    $1E,X
BF93: 39          RTS

l_c000:
C000: B6 14 40    LDA    $1440
C003: 26 01       BNE    $C006
C005: 39          RTS
C006: 8E 13 74    LDX    #$1374
C009: B6 13 93    LDA    $1393
C00C: 48          ASLA
C00D: F6 14 05    LDB    $1405
C010: E7 86       STB    A,X
C012: 39          RTS
l_c013:
C013: B6 14 41    LDA    $1441
C016: 26 01       BNE    $C019
C018: 39          RTS
C019: 8E 13 75    LDX    #$1375
C01C: B6 13 93    LDA    $1393
C01F: 48          ASLA
C020: F6 14 08    LDB    $1408
C023: E7 86       STB    A,X
C025: 7F 14 08    CLR    $1408
C028: 39          RTS
l_c029:
C029: B6 13 60    LDA    $1360
C02C: 26 0A       BNE    $C038
C02E: B6 13 75    LDA    $1375
C031: 97 3D       STA    <$3D
C033: B6 13 74    LDA    $1374
C036: 20 0E       BRA    $C046
C038: 8E 13 74    LDX    #$1374
C03B: F6 13 81    LDB    $1381
C03E: 58          ASLB
C03F: 3A          ABX
C040: A6 01       LDA    $1,X
C042: 97 3D       STA    <$3D
C044: A6 84       LDA    ,X
C046: 84 0A       ANDA   #$0A
C048: 97 0D       STA    <$0D
C04A: 39          RTS
l_c04b:
C04B: B6 14 42    LDA    $1442
C04E: 26 01       BNE    $C051
C050: 39          RTS
C051: 8E 20 00    LDX    #$2000
C054: A6 88 1E    LDA    $1E,X
C057: 27 0C       BEQ    $C065
C059: FE 13 DA    LDU    $13DA
C05C: A6 C4       LDA    ,U
C05E: 26 08       BNE    $C068
C060: 6F 88 1E    CLR    $1E,X
C063: 20 03       BRA    $C068
C065: BD EF 03    JSR    $EF03
C068: AD 98 0E    JSR    [$0E,X]
C06B: 96 00       LDA    <$00
C06D: 81 02       CMPA   #$02
C06F: 22 03       BHI    $C074
C071: BD F0 0D    JSR    $F00D
C074: B6 14 02    LDA    $1402
C077: 44          LSRA
C078: 44          LSRA
C079: 44          LSRA
C07A: 44          LSRA
C07B: 81 06       CMPA   #$06
C07D: 27 10       BEQ    $C08F
C07F: DC 01       LDD    <$01
C081: 10 83 00 69 CMPD   #$0069
C085: 25 2E       BCS    $C0B5
C087: 10 83 01 51 CMPD   #$0151
C08B: 25 3A       BCS    $C0C7
C08D: 20 13       BRA    $C0A2
C08F: B6 13 93    LDA    $1393
C092: 27 07       BEQ    $C09B
C094: CC 01 E0    LDD    #$01E0
C097: 93 01       SUBD   <$01
C099: 20 29       BRA    $C0C4
C09B: DC 01       LDD    <$01
C09D: 83 00 EE    SUBD   #$00EE
C0A0: 20 22       BRA    $C0C4
C0A2: B6 13 93    LDA    $1393
C0A5: 27 07       BEQ    $C0AE
C0A7: CC 01 CA    LDD    #$01CA
C0AA: 93 01       SUBD   <$01
C0AC: 20 16       BRA    $C0C4
C0AE: DC 01       LDD    <$01
C0B0: 83 00 D8    SUBD   #$00D8
C0B3: 20 0F       BRA    $C0C4
C0B5: B6 13 93    LDA    $1393
C0B8: 27 06       BEQ    $C0C0
C0BA: C6 E1       LDB    #$E1
C0BC: D0 02       SUBB   <$02
C0BE: 20 04       BRA    $C0C4
C0C0: D6 02       LDB    <$02
C0C2: CB 11       ADDB   #$11
C0C4: F7 11 9A    STB    $119A
C0C7: D6 04       LDB    <$04
C0C9: B6 13 93    LDA    $1393
C0CC: 27 08       BEQ    $C0D6
C0CE: 4F          CLRA
C0CF: 83 01 29    SUBD   #$0129
C0D2: 43          COMA
C0D3: 53          COMB
C0D4: 20 03       BRA    $C0D9
C0D6: C3 00 38    ADDD   #$0038
C0D9: F7 11 9B    STB    $119B
C0DC: B7 12 1B    STA    $121B
C0DF: 96 0A       LDA    <$0A
C0E1: B7 11 1A    STA    $111A
C0E4: 96 0C       LDA    <$0C
C0E6: B7 12 1A    STA    $121A
C0E9: 39          RTS
l_c0ea:
C0EA: B6 14 47    LDA    $1447
C0ED: 26 01       BNE    $C0F0
C0EF: 39          RTS
C0F0: 8E 20 40    LDX    #$2040
C0F3: A6 84       LDA    ,X
C0F5: 26 01       BNE    $C0F8
C0F7: 39          RTS
C0F8: A6 08       LDA    $8,X
C0FA: 81 FF       CMPA   #$FF
C0FC: 27 04       BEQ    $C102
C0FE: 30 09       LEAX   $9,X
C100: 20 F1       BRA    $C0F3
C102: 0C 32       INC    <$32
C104: 7F 14 47    CLR    $1447
C107: 39          RTS
l_c108:
C108: F6 13 89    LDB    scroll_value_1389
C10B: 53          COMB
C10C: 4F          CLRA
C10D: C3 00 E0    ADDD   #$00E0
C110: FD 13 CE    STD    $13CE
C113: F6 13 89    LDB    scroll_value_1389
C116: 53          COMB
C117: 26 05       BNE    $C11E
C119: CC 00 01    LDD    #$0001
C11C: 20 01       BRA    $C11F
C11E: 4F          CLRA
C11F: FD 13 CC    STD    $13CC
C122: 39          RTS
l_c123:
C123: B6 14 53    LDA    $1453
C126: 26 01       BNE    $C129
C128: 39          RTS
C129: 8E 14 C0    LDX    #$14C0
C12C: A6 88 1B    LDA    $1B,X
C12F: 81 FF       CMPA   #$FF
C131: 26 05       BNE    $C138
C133: 6F 88 1B    CLR    $1B,X
C136: 20 4A       BRA    $C182
C138: E6 84       LDB    ,X
C13A: 27 33       BEQ    $C16F
C13C: C1 02       CMPB   #$02
C13E: 23 21       BLS    $C161
C140: BD C1 C5    JSR    $C1C5
C143: E6 84       LDB    ,X
C145: C1 07       CMPB   #$07
C147: 26 39       BNE    $C182
C149: A6 88 1B    LDA    $1B,X
C14C: 85 08       BITA   #$08
C14E: 27 09       BEQ    $C159
C150: A6 04       LDA    $4,X
C152: A1 88 1F    CMPA   $1F,X
C155: 26 2B       BNE    $C182
C157: 20 1B       BRA    $C174
C159: 96 04       LDA    <$04
C15B: A0 04       SUBA   $4,X
C15D: 2B 23       BMI    $C182
C15F: 20 13       BRA    $C174
C161: 96 04       LDA    <$04
C163: A0 04       SUBA   $4,X
C165: 8B 02       ADDA   #$02
C167: 81 04       CMPA   #$04
C169: 22 17       BHI    $C182
C16B: 8D 63       BSR    $C1D0
C16D: 20 05       BRA    $C174
C16F: 6A 88 17    DEC    $17,X
C172: 26 0E       BNE    $C182
C174: DC 01       LDD    <$01
C176: A3 01       SUBD   $1,X
C178: 2A 04       BPL    $C17E
C17A: 86 08       LDA    #$08
C17C: 20 02       BRA    $C180
C17E: 86 02       LDA    #$02
C180: A7 0D       STA    $D,X
C182: AD 98 0E    JSR    [$0E,X]
C185: CE 11 70    LDU    #$1170
C188: EC 01       LDD    $1,X
C18A: C3 00 11    ADDD   #$0011
C18D: 2B 2C       BMI    $C1BB
C18F: 10 B3 13 CC CMPD   $13CC
C193: 25 26       BCS    $C1BB
C195: EC 01       LDD    $1,X
C197: 2B 06       BMI    $C19F
C199: 10 B3 13 CE CMPD   $13CE
C19D: 22 1C       BHI    $C1BB
C19F: A6 04       LDA    $4,X
C1A1: B7 13 E3    STA    $13E3
C1A4: EC 01       LDD    $1,X
C1A6: BD F2 34    JSR    $F234
C1A9: A6 0A       LDA    $A,X
C1AB: A7 C4       STA    ,U
C1AD: A6 0B       LDA    $B,X
C1AF: A7 41       STA    $1,U
C1B1: A6 0C       LDA    $C,X
C1B3: A7 C9 01 00 STA    $0100,U
C1B7: 6F 88 26    CLR    $26,X
C1BA: 39          RTS
C1BB: 6F C9 00 80 CLR    $0080,U
C1BF: 86 01       LDA    #$01
C1C1: A7 88 26    STA    $26,X
C1C4: 39          RTS
C1C5: 96 04       LDA    <$04
C1C7: A0 04       SUBA   $4,X
C1C9: 8B 04       ADDA   #$04
C1CB: 81 08       CMPA   #$08
C1CD: 23 01       BLS    $C1D0
C1CF: 39          RTS
C1D0: DC 01       LDD    <$01
C1D2: A3 01       SUBD   $1,X
C1D4: C3 00 04    ADDD   #$0004
C1D7: 10 83 00 08 CMPD   #$0008
C1DB: 23 01       BLS    $C1DE
C1DD: 39          RTS
C1DE: 0C 33       INC    <$33
C1E0: 39          RTS
l_c1e1:
C1E1: B6 14 4F    LDA    $144F
C1E4: 26 01       BNE    $C1E7
C1E6: 39          RTS
C1E7: 8E 22 30    LDX    #$2230
C1EA: 7F 13 E1    CLR    $13E1
C1ED: A6 84       LDA    ,X
C1EF: 81 FE       CMPA   #$FE
C1F1: 25 01       BCS    $C1F4
C1F3: 39          RTS
C1F4: A6 88 1B    LDA    $1B,X
C1F7: 81 FF       CMPA   #$FF
C1F9: 26 0E       BNE    $C209
C1FB: CE C2 28    LDU    #$C228
C1FE: EF 88 21    STU    $21,X
C201: 6F 88 1B    CLR    $1B,X
C204: 6F 88 20    CLR    $20,X
C207: 20 10       BRA    $C219
C209: 4D          TSTA
C20A: 27 0D       BEQ    $C219
C20C: A1 88 20    CMPA   $20,X
C20F: 27 08       BEQ    $C219
C211: A7 88 20    STA    $20,X
C214: BD C2 A0    JSR    $C2A0
C217: 20 03       BRA    $C21C
C219: AD 98 21    JSR    [$21,X]
C21C: 7C 13 E1    INC    $13E1
C21F: 30 88 30    LEAX   $30,X
C222: 8C 24 10    CMPX   #$2410
C225: 26 C6       BNE    $C1ED
C227: 39          RTS
l_c228:
C228: A6 84       LDA    ,X
C22A: 27 4D       BEQ    $C279
C22C: 81 02       CMPA   #$02
C22E: 23 0C       BLS    $C23C
C230: 81 07       CMPA   #$07
C232: 27 01       BEQ    $C235
C234: 39          RTS
C235: A6 04       LDA    $4,X
C237: 91 04       CMPA   <$04
C239: 23 55       BLS    $C290
C23B: 39          RTS
C23C: A6 04       LDA    $4,X
C23E: 91 04       CMPA   <$04
C240: 27 01       BEQ    $C243
C242: 39          RTS
C243: A6 84       LDA    ,X
C245: 81 02       CMPA   #$02
C247: 23 05       BLS    $C24E
C249: 81 0B       CMPA   #$0B
C24B: 24 01       BCC    $C24E
C24D: 39          RTS
C24E: EC 01       LDD    $1,X
C250: 93 01       SUBD   <$01
C252: C3 00 04    ADDD   #$0004
C255: 10 83 00 08 CMPD   #$0008
C259: 23 01       BLS    $C25C
C25B: 39          RTS
C25C: 96 00       LDA    <$00
C25E: 81 0B       CMPA   #$0B
C260: 27 09       BEQ    $C26B
C262: 81 0C       CMPA   #$0C
C264: 26 10       BNE    $C276
C266: CE EC 76    LDU    #$EC76
C269: 20 03       BRA    $C26E
C26B: CE EC 66    LDU    #$EC66
C26E: EF 0E       STU    $E,X
C270: 86 01       LDA    #$01
C272: A7 88 2B    STA    $2B,X
C275: 39          RTS
C276: 0C 33       INC    <$33
C278: 39          RTS
C279: B6 13 E1    LDA    $13E1
C27C: 27 12       BEQ    $C290
C27E: A6 0D       LDA    $D,X
C280: 27 01       BEQ    $C283
C282: 39          RTS
C283: C6 01       LDB    #$01
C285: 59          ROLB
C286: 4A          DECA
C287: 26 FC       BNE    $C285
C289: F4 13 E4    ANDB   $13E4
C28C: 27 0D       BEQ    $C29B
C28E: 20 06       BRA    $C296
C290: DC 01       LDD    <$01
C292: A3 01       SUBD   $1,X
C294: 24 05       BCC    $C29B
C296: 86 08       LDA    #$08
C298: A7 0D       STA    $D,X
C29A: 39          RTS
C29B: 86 02       LDA    #$02
C29D: A7 0D       STA    $D,X
C29F: 39          RTS
C2A0: A6 88 1B    LDA    $1B,X
C2A3: 85 08       BITA   #$08
C2A5: 26 46       BNE    $C2ED
C2A7: BD C3 22    JSR    $C322
l_c2aa:
C2AA: A6 84       LDA    ,X
C2AC: 81 02       CMPA   #$02
C2AE: 22 04       BHI    $C2B4
C2B0: 8D 8A       BSR    $C23C
C2B2: A6 84       LDA    ,X
C2B4: 81 07       CMPA   #$07
C2B6: 27 01       BEQ    $C2B9
C2B8: 39          RTS
C2B9: 96 00       LDA    <$00
C2BB: 81 02       CMPA   #$02
C2BD: 23 04       BLS    $C2C3
C2BF: 81 0B       CMPA   #$0B
C2C1: 25 52       BCS    $C315
C2C3: E6 88 1F    LDB    $1F,X
C2C6: C1 90       CMPB   #$90
C2C8: 22 04       BHI    $C2CE
C2CA: CB 20       ADDB   #$20
C2CC: 20 02       BRA    $C2D0
C2CE: C0 20       SUBB   #$20
C2D0: E7 88 1F    STB    $1F,X
C2D3: BD C3 22    JSR    $C322
l_c2d6:
C2D6: A6 04       LDA    $4,X
C2D8: A1 88 1F    CMPA   $1F,X
C2DB: 23 01       BLS    $C2DE
C2DD: 39          RTS
C2DE: CE C2 28    LDU    #$C228
C2E1: EF 88 21    STU    $21,X
C2E4: A6 88 1B    LDA    $1B,X
C2E7: 85 01       BITA   #$01
C2E9: 26 AB       BNE    $C296
C2EB: 20 AE       BRA    $C29B
C2ED: BD C3 22    JSR    $C322
C2F0: A6 84       LDA    ,X
C2F2: 81 06       CMPA   #$06
C2F4: 27 01       BEQ    $C2F7
C2F6: 39          RTS
C2F7: BD C3 22    JSR    $C322
C2FA: A6 84       LDA    ,X
C2FC: 81 07       CMPA   #$07
C2FE: 27 01       BEQ    $C301
C300: 39          RTS
C301: BD C3 22    JSR    $C322
C304: A6 04       LDA    $4,X
C306: A1 88 1F    CMPA   $1F,X
C309: 23 01       BLS    $C30C
C30B: 39          RTS
C30C: CE C2 28    LDU    #$C228
C30F: EF 88 21    STU    $21,X
C312: 7E C2 90    JMP    $C290
C315: 6F 88 1B    CLR    $1B,X
C318: 6F 88 20    CLR    $20,X
C31B: CE C2 28    LDU    #$C228
C31E: EF 88 21    STU    $21,X
C321: 39          RTS

save_context_c322:
C322: 35 06       PULS   D
C324: ED 88 21    STD    $21,X
C327: 39          RTS
l_c328:
C328: B6 14 44    LDA    $1444
C32B: 26 01       BNE    $C32E
C32D: 39          RTS
C32E: 8E 22 30    LDX    #$2230
C331: A6 84       LDA    ,X
C333: 81 FE       CMPA   #$FE
C335: 25 01       BCS    $C338
C337: 39          RTS
C338: A6 88 1E    LDA    $1E,X
C33B: 27 0C       BEQ    $C349
C33D: EE 88 12    LDU    $12,X
C340: A6 C4       LDA    ,U
C342: 26 08       BNE    $C34C
C344: 6F 88 1E    CLR    $1E,X
C347: 20 03       BRA    $C34C
C349: BD EF D5    JSR    $EFD5
C34C: AD 98 0E    JSR    [$0E,X]
C34F: EE 88 19    LDU    $19,X
C352: EC 01       LDD    $1,X
C354: C3 00 11    ADDD   #$0011
C357: 2B 2D       BMI    $C386
C359: 10 B3 13 CC CMPD   $13CC
C35D: 25 27       BCS    $C386
C35F: EC 01       LDD    $1,X
C361: 2B 06       BMI    $C369
C363: 10 B3 13 CE CMPD   $13CE
C367: 22 1D       BHI    $C386
C369: A6 04       LDA    $4,X
C36B: B7 13 E3    STA    $13E3
C36E: EC 01       LDD    $1,X
C370: BD F2 34    JSR    $F234
C373: A6 0A       LDA    $A,X
C375: A7 C4       STA    ,U
C377: A6 0B       LDA    $B,X
C379: A7 41       STA    $1,U
C37B: A6 0C       LDA    $C,X
C37D: A7 C9 01 00 STA    $0100,U
C381: 6F 88 26    CLR    $26,X
C384: 20 09       BRA    $C38F
C386: 6F C9 00 80 CLR    $0080,U
C38A: 86 01       LDA    #$01
C38C: A7 88 26    STA    $26,X
C38F: 30 88 30    LEAX   $30,X
C392: 7E C3 31    JMP    $C331
l_c395:
C395: B6 14 4F    LDA    $144F
C398: 26 01       BNE    $C39B
C39A: 39          RTS
C39B: 8E 22 00    LDX    #$2200
C39E: A6 88 1B    LDA    $1B,X
C3A1: 81 FF       CMPA   #$FF
C3A3: 26 3B       BNE    $C3E0
C3A5: CE C3 F3    LDU    #$C3F3
C3A8: EF 88 21    STU    $21,X
C3AB: 6F 88 1B    CLR    $1B,X
C3AE: 6F 88 20    CLR    $20,X
C3B1: E6 04       LDB    $4,X
C3B3: 96 31       LDA    <$31
C3B5: 4C          INCA
C3B6: 84 0F       ANDA   #$0F
C3B8: 81 03       CMPA   #$03
C3BA: 24 08       BCC    $C3C4
C3BC: C1 48       CMPB   #$48
C3BE: 24 0C       BCC    $C3CC
C3C0: 86 04       LDA    #$04
C3C2: 20 15       BRA    $C3D9
C3C4: C1 28       CMPB   #$28
C3C6: 24 04       BCC    $C3CC
C3C8: 86 04       LDA    #$04
C3CA: 20 0D       BRA    $C3D9
C3CC: C1 E0       CMPB   #$E0
C3CE: 27 07       BEQ    $C3D7
C3D0: A6 88 23    LDA    $23,X
C3D3: 84 05       ANDA   #$05
C3D5: 20 02       BRA    $C3D9
C3D7: 86 01       LDA    #$01
C3D9: AA 0D       ORA    $D,X
C3DB: A7 88 23    STA    $23,X
C3DE: 20 0F       BRA    $C3EF
C3E0: 4D          TSTA
C3E1: 27 0C       BEQ    $C3EF
C3E3: A1 88 20    CMPA   $20,X
C3E6: 27 07       BEQ    $C3EF
C3E8: A7 88 20    STA    $20,X
C3EB: BD C4 E9    JSR    $C4E9
C3EE: 39          RTS
C3EF: AD 98 21    JSR    [$21,X]
C3F2: 39          RTS
l_c3f3:
C3F3: A6 84       LDA    ,X
C3F5: 81 02       CMPA   #$02
C3F7: 23 15       BLS    $C40E
C3F9: 81 07       CMPA   #$07
C3FB: 27 01       BEQ    $C3FE
C3FD: 39          RTS
C3FE: A6 04       LDA    $4,X
C400: A1 88 1F    CMPA   $1F,X
C403: 23 01       BLS    $C406
C405: 39          RTS
C406: E6 88 23    LDB    $23,X
C409: C4 0A       ANDB   #$0A
C40B: E7 0D       STB    $D,X
C40D: 39          RTS
C40E: BD C5 37    JSR    $C537
C411: 81 01       CMPA   #$01
C413: 10 26 00 95 LBNE   $C4AC
C417: EE 88 19    LDU    $19,X
C41A: 6F C9 00 80 CLR    $0080,U
C41E: CE 11 00    LDU    #$1100
C421: EF 88 19    STU    $19,X
C424: BD C5 75    JSR    $C575
l_c427:
C427: BD C5 37    JSR    $C537
C42A: 81 02       CMPA   #$02
C42C: 27 01       BEQ    $C42F
C42E: 39          RTS
C42F: A6 88 23    LDA    $23,X
C432: 84 05       ANDA   #$05
C434: AA 0D       ORA    $D,X
C436: A7 88 23    STA    $23,X
C439: 6F 0D       CLR    $D,X
C43B: EC 45       LDD    $5,U
C43D: ED 01       STD    $1,X
C43F: 86 78       LDA    #$78
C441: A7 88 25    STA    $25,X
C444: BD C5 75    JSR    $C575
l_c447:
C447: A6 04       LDA    $4,X
C449: 91 04       CMPA   <$04
C44B: 26 2B       BNE    $C478
C44D: EC 01       LDD    $1,X
C44F: 93 01       SUBD   <$01
C451: C3 00 04    ADDD   #$0004
C454: 10 83 00 08 CMPD   #$0008
C458: 22 1E       BHI    $C478
C45A: 34 10       PSHS   X
C45C: 8E D4 74    LDX    #$D474
C45F: BD F2 63    JSR    $F263
C462: 35 10       PULS   X
C464: 86 5A       LDA    #$5A
C466: A7 88 25    STA    $25,X
C469: B7 14 51    STA    $1451
C46C: B7 14 FD    STA    $14FD
C46F: CE C6 0A    LDU    #$C60A
C472: FF 14 FE    STU    $14FE
C475: BD C5 75    JSR    $C575
C478: 6A 88 25    DEC    $25,X
C47B: 27 01       BEQ    $C47E
C47D: 39          RTS
C47E: 7F 11 82    CLR    $1182
C481: A6 88 23    LDA    $23,X
C484: 84 0A       ANDA   #$0A
C486: A7 0D       STA    $D,X
C488: BD C5 75    JSR    $C575
l_c48b:
C48B: BD C5 37    JSR    $C537
C48E: 4D          TSTA
C48F: 27 01       BEQ    $C492
C491: 39          RTS
C492: EE 88 19    LDU    $19,X
C495: 6F C9 00 80 CLR    $0080,U
C499: CE 11 1C    LDU    #$111C
C49C: EF 88 19    STU    $19,X
C49F: CE C3 F3    LDU    #$C3F3
C4A2: EF 88 21    STU    $21,X
C4A5: 6F 88 1B    CLR    $1B,X
C4A8: 6F 88 20    CLR    $20,X
C4AB: 39          RTS
C4AC: A6 04       LDA    $4,X
C4AE: 91 04       CMPA   <$04
C4B0: 27 01       BEQ    $C4B3
C4B2: 39          RTS
C4B3: A6 84       LDA    ,X
C4B5: 81 02       CMPA   #$02
C4B7: 23 05       BLS    $C4BE
C4B9: 81 0B       CMPA   #$0B
C4BB: 24 01       BCC    $C4BE
C4BD: 39          RTS
C4BE: EC 01       LDD    $1,X
C4C0: 93 01       SUBD   <$01
C4C2: C3 00 04    ADDD   #$0004
C4C5: 10 83 00 08 CMPD   #$0008
C4C9: 23 01       BLS    $C4CC
C4CB: 39          RTS
C4CC: 96 00       LDA    <$00
C4CE: 81 0B       CMPA   #$0B
C4D0: 27 09       BEQ    $C4DB
C4D2: 81 0C       CMPA   #$0C
C4D4: 26 10       BNE    $C4E6
C4D6: CE EC 76    LDU    #$EC76
C4D9: 20 03       BRA    $C4DE
C4DB: CE EC 66    LDU    #$EC66
C4DE: EF 0E       STU    $E,X
C4E0: 86 01       LDA    #$01
C4E2: A7 88 2B    STA    $2B,X
C4E5: 39          RTS
C4E6: 0C 33       INC    <$33
C4E8: 39          RTS
C4E9: BD C5 75    JSR    $C575
l_c4ec:
C4EC: A6 84       LDA    ,X
C4EE: 81 07       CMPA   #$07
C4F0: 27 01       BEQ    $C4F3
C4F2: 39          RTS
C4F3: A6 88 1B    LDA    $1B,X
C4F6: 85 32       BITA   #$32
C4F8: 27 08       BEQ    $C502
C4FA: A6 88 23    LDA    $23,X
C4FD: 88 0A       EORA   #$0A
C4FF: A7 88 23    STA    $23,X
C502: BD C5 75    JSR    $C575
l_c505:
C505: A6 88 1F    LDA    $1F,X
C508: E6 88 1B    LDB    $1B,X
C50B: C5 08       BITB   #$08
C50D: 27 07       BEQ    $C516
C50F: 8B 20       ADDA   #$20
C511: E6 88 23    LDB    $23,X
C514: 20 11       BRA    $C527
C516: E6 88 23    LDB    $23,X
C519: C5 04       BITB   #$04
C51B: 26 04       BNE    $C521
C51D: 80 20       SUBA   #$20
C51F: 20 06       BRA    $C527
C521: 8B 20       ADDA   #$20
C523: 24 02       BCC    $C527
C525: 86 E0       LDA    #$E0
C527: A1 04       CMPA   $4,X
C529: 24 01       BCC    $C52C
C52B: 39          RTS
C52C: C4 0A       ANDB   #$0A
C52E: E7 0D       STB    $D,X
C530: CE C3 F3    LDU    #$C3F3
C533: EF 88 21    STU    $21,X
C536: 39          RTS
C537: CE 20 40    LDU    #$2040
C53A: A6 C4       LDA    ,U
C53C: 26 28       BNE    $C566
C53E: A6 04       LDA    $4,X
C540: A1 47       CMPA   $7,U
C542: 26 22       BNE    $C566
C544: EC 01       LDD    $1,X
C546: A3 45       SUBD   $5,U
C548: C3 00 02    ADDD   #$0002
C54B: 10 83 00 04 CMPD   #$0004
C54F: 23 0F       BLS    $C560
C551: C3 00 0E    ADDD   #$000E
C554: 10 83 00 20 CMPD   #$0020
C558: 22 0C       BHI    $C566
C55A: 86 01       LDA    #$01
C55C: A7 88 24    STA    $24,X
C55F: 39          RTS
C560: 86 02       LDA    #$02
C562: A7 88 24    STA    $24,X
C565: 39          RTS
C566: A6 48       LDA    $8,U
C568: 81 FF       CMPA   #$FF
C56A: 27 04       BEQ    $C570
C56C: 33 49       LEAU   $9,U
C56E: 20 CA       BRA    $C53A
C570: 4F          CLRA
C571: A7 88 24    STA    $24,X
C574: 39          RTS
save_context_c575:
C575: 35 06       PULS   D
C577: ED 88 21    STD    $21,X
C57A: 39          RTS
l_c57b:
C57B: B6 14 45    LDA    $1445
C57E: 26 01       BNE    $C581
C580: 39          RTS
C581: 8E 22 00    LDX    #$2200
C584: A6 88 1E    LDA    $1E,X
C587: 27 0C       BEQ    $C595
C589: EE 88 12    LDU    $12,X
C58C: A6 C4       LDA    ,U
C58E: 26 08       BNE    $C598
C590: 6F 88 1E    CLR    $1E,X
C593: 20 03       BRA    $C598
C595: BD EF D5    JSR    $EFD5
C598: AD 98 0E    JSR    [$0E,X]
C59B: EE 88 19    LDU    $19,X
C59E: EC 01       LDD    $1,X
C5A0: C3 00 11    ADDD   #$0011
C5A3: 2B 2C       BMI    $C5D1
C5A5: 10 B3 13 CC CMPD   $13CC
C5A9: 25 26       BCS    $C5D1
C5AB: EC 01       LDD    $1,X
C5AD: 2B 06       BMI    $C5B5
C5AF: 10 B3 13 CE CMPD   $13CE
C5B3: 22 1C       BHI    $C5D1
C5B5: A6 04       LDA    $4,X
C5B7: B7 13 E3    STA    $13E3
C5BA: EC 01       LDD    $1,X
C5BC: BD F2 34    JSR    $F234
C5BF: A6 0A       LDA    $A,X
C5C1: A7 C4       STA    ,U
C5C3: A6 0B       LDA    $B,X
C5C5: A7 41       STA    $1,U
C5C7: A6 0C       LDA    $C,X
C5C9: A7 C9 01 00 STA    $0100,U
C5CD: 6F 88 26    CLR    $26,X
C5D0: 39          RTS
C5D1: 6F C9 00 80 CLR    $0080,U
C5D5: 86 01       LDA    #$01
C5D7: A7 88 26    STA    $26,X
C5DA: 39          RTS
l_c5db:
C5DB: B6 14 51    LDA    $1451
C5DE: 26 01       BNE    $C5E1
C5E0: 39          RTS
C5E1: 8E 14 F0    LDX    #$14F0
C5E4: CE 11 02    LDU    #$1102
C5E7: 10 8E 22 00 LDY    #$2200
C5EB: AD 98 0E    JSR    [$0E,X]
C5EE: 6A 0D       DEC    $D,X
C5F0: 27 0B       BEQ    $C5FD
C5F2: A6 04       LDA    $4,X
C5F4: B7 13 E3    STA    $13E3
C5F7: EC 01       LDD    $1,X
C5F9: BD F2 34    JSR    $F234
C5FC: 39          RTS
C5FD: 6F C9 00 80 CLR    $0080,U
C601: 7F 14 51    CLR    $1451
C604: CE C6 0A    LDU    #$C60A
C607: EF 0E       STU    $E,X
C609: 39          RTS
C60A: A6 A4       LDA    ,Y
C60C: 26 1E       BNE    $C62C
C60E: EC 21       LDD    $1,Y
C610: 83 00 08    SUBD   #$0008
C613: ED 01       STD    $1,X
C615: A6 24       LDA    $4,Y
C617: 80 08       SUBA   #$08
C619: A7 04       STA    $4,X
C61B: EE A8 19    LDU    $19,Y
C61E: 86 7E       LDA    #$7E
C620: A7 C4       STA    ,U
C622: CE 11 02    LDU    #$1102
C625: 86 7F       LDA    #$7F
C627: A7 C4       STA    ,U
C629: 6F 41       CLR    $1,U
C62B: 39          RTS
C62C: 86 3C       LDA    #$3C
C62E: 97 0D       STA    <$0D
C630: 86 03       LDA    #$03
C632: A7 41       STA    $1,U
C634: BD F0 42    JSR    $F042
C637: 39          RTS
l_c638:
C638: B6 14 48    LDA    $1448
C63B: 26 01       BNE    $C63E
C63D: 39          RTS
C63E: 8E 20 A0    LDX    #$20A0
C641: A6 84       LDA    ,X
C643: 26 09       BNE    $C64E
C645: A6 07       LDA    $7,X
C647: 27 01       BEQ    $C64A
C649: 39          RTS
C64A: 30 08       LEAX   $8,X
C64C: 20 F3       BRA    $C641
C64E: A6 01       LDA    $1,X
C650: 81 03       CMPA   #$03
C652: 26 03       BNE    $C657
C654: B7 40 47    STA    $4047
C657: CE C6 CA    LDU    #$C6CA
C65A: E6 C6       LDB    A,U
C65C: 58          ASLB
C65D: 58          ASLB
C65E: 58          ASLB
C65F: EE 05       LDU    $5,X
C661: A6 03       LDA    $3,X
C663: 34 10       PSHS   X
C665: 8E DE 09    LDX    #$DE09
C668: 48          ASLA
C669: AE 86       LDX    A,X
C66B: 3A          ABX
C66C: C6 05       LDB    #$05
C66E: A6 80       LDA    ,X+
C670: A7 C4       STA    ,U
C672: 33 C8 E0    LEAU   -$20,U
C675: 5A          DECB
C676: 26 F6       BNE    $C66E
C678: 33 C9 00 81 LEAU   $0081,U
C67C: C6 03       LDB    #$03
C67E: A6 80       LDA    ,X+
C680: A7 C4       STA    ,U
C682: 33 C8 E0    LEAU   -$20,U
C685: 5A          DECB
C686: 26 F6       BNE    $C67E
C688: 35 10       PULS   X
C68A: A6 01       LDA    $1,X
C68C: 81 0A       CMPA   #$0A
C68E: 25 35       BCS    $C6C5
C690: E6 84       LDB    ,X
C692: C1 01       CMPB   #$01
C694: 26 28       BNE    $C6BE
C696: 6C 02       INC    $2,X
C698: EE 05       LDU    $5,X
C69A: 33 C9 08 00 LEAU   $0800,U
C69E: 10 8E C6 D6 LDY    #$C6D6
C6A2: A6 02       LDA    $2,X
C6A4: A6 A6       LDA    A,Y
C6A6: C6 05       LDB    #$05
C6A8: A7 C4       STA    ,U
C6AA: 33 C8 E0    LEAU   -$20,U
C6AD: 5A          DECB
C6AE: 26 F8       BNE    $C6A8
C6B0: 33 C9 00 81 LEAU   $0081,U
C6B4: C6 03       LDB    #$03
C6B6: A7 C4       STA    ,U
C6B8: 33 C8 E0    LEAU   -$20,U
C6BB: 5A          DECB
C6BC: 26 F8       BNE    $C6B6
C6BE: 6F 01       CLR    $1,X
C6C0: 6F 84       CLR    ,X
C6C2: 7E C6 45    JMP    $C645
C6C5: 6C 01       INC    $1,X
C6C7: 7E C6 45    JMP    $C645

l_c6db:
C6DB: B6 14 49    LDA    $1449                                       
C6DE: 26 01       BNE    $C6E1
C6E0: 39          RTS
C6E1: B6 13 B3    LDA    $13B3
C6E4: 84 07       ANDA   #$07
C6E6: 81 05       CMPA   #$05
C6E8: 27 01       BEQ    $C6EB
C6EA: 39          RTS
C6EB: 7F 13 B3    CLR    $13B3
C6EE: 7C 13 A6    INC    $13A6
C6F1: 8E 20 E0    LDX    #$20E0
C6F4: A6 84       LDA    ,X
C6F6: 26 24       BNE    $C71C
C6F8: A6 05       LDA    $5,X
C6FA: 27 15       BEQ    $C711
C6FC: B6 13 A6    LDA    $13A6
C6FF: 84 07       ANDA   #$07
C701: 8B 10       ADDA   #$10
C703: EE 02       LDU    $2,X
C705: A7 C9 08 00 STA    $0800,U
C709: A7 C9 08 01 STA    $0801,U
C70D: A7 C9 08 02 STA    $0802,U
C711: A6 07       LDA    $7,X
C713: 81 FF       CMPA   #$FF
C715: 26 01       BNE    $C718
C717: 39          RTS
C718: 30 08       LEAX   $8,X
C71A: 20 D8       BRA    $C6F4
C71C: A6 04       LDA    $4,X
C71E: 27 0B       BEQ    $C72B
C720: 10 8E DE F1 LDY    #$DEF1
C724: 86 1D       LDA    #$1D
C726: B7 13 DF    STA    $13DF
C729: 20 09       BRA    $C734
C72B: 10 8E DF 15 LDY    #$DF15
C72F: 86 DD       LDA    #$DD
C731: B7 13 DF    STA    $13DF
C734: E6 05       LDB    $5,X
C736: 27 5E       BEQ    $C796
C738: 86 0E       LDA    #$0E
C73A: B7 13 E0    STA    $13E0
C73D: B6 13 DF    LDA    $13DF
C740: 2B 06       BMI    $C748
C742: 10 8E DF 39 LDY    #$DF39
C746: 20 04       BRA    $C74C
C748: 10 8E DF 5D LDY    #$DF5D
C74C: A6 01       LDA    $1,X
C74E: 81 02       CMPA   #$02
C750: 26 49       BNE    $C79B
C752: CE 12 80    LDU    #$1280
C755: C4 03       ANDB   #$03
C757: 86 30       LDA    #$30
C759: 3D          MUL
C75A: 33 CB       LEAU   D,U
C75C: EC 02       LDD    $2,X
C75E: C4 E0       ANDB   #$E0
C760: FD 13 D7    STD    $13D7
C763: CC 07 60    LDD    #$0760
C766: B3 13 D7    SUBD   $13D7
C769: 44          LSRA
C76A: 56          RORB
C76B: 44          LSRA
C76C: 56          RORB
C76D: ED 41       STD    $1,U
C76F: B6 13 DF    LDA    $13DF
C772: 2B 0B       BMI    $C77F
C774: EC 41       LDD    $1,U
C776: 83 00 11    SUBD   #$0011
C779: ED 41       STD    $1,U
C77B: 86 01       LDA    #$01
C77D: 20 02       BRA    $C781
C77F: 86 02       LDA    #$02
C781: A7 C4       STA    ,U
C783: EC 02       LDD    $2,X
C785: C4 1F       ANDB   #$1F
C787: C0 07       SUBB   #$07
C789: 54          LSRB
C78A: 54          LSRB
C78B: 86 20       LDA    #$20
C78D: 3D          MUL
C78E: CB 30       ADDB   #$30
C790: E7 44       STB    $4,U
C792: 6F 05       CLR    $5,X
C794: 20 05       BRA    $C79B
C796: 86 0A       LDA    #$0A
C798: B7 13 E0    STA    $13E0
C79B: 6C 01       INC    $1,X
C79D: A6 01       LDA    $1,X
C79F: 81 03       CMPA   #$03
C7A1: 27 06       BEQ    $C7A9
C7A3: 81 06       CMPA   #$06
C7A5: 26 04       BNE    $C7AB
C7A7: 6F 01       CLR    $1,X
C7A9: 6F 84       CLR    ,X
C7AB: 34 10       PSHS   X
C7AD: 8E C7 DE    LDX    #$C7DE
C7B0: E6 86       LDB    A,X
C7B2: 58          ASLB
C7B3: 58          ASLB
C7B4: 58          ASLB
C7B5: EB 86       ADDB   A,X
C7B7: 35 10       PULS   X
C7B9: 31 A5       LEAY   B,Y
C7BB: EE 02       LDU    $2,X
C7BD: C6 03       LDB    #$03
C7BF: 34 04       PSHS   B
C7C1: C6 03       LDB    #$03
C7C3: A6 A0       LDA    ,Y+
C7C5: A7 C0       STA    ,U+
C7C7: B6 13 E0    LDA    $13E0
C7CA: A7 C9 07 FF STA    $07FF,U
C7CE: 5A          DECB
C7CF: 26 F2       BNE    $C7C3
C7D1: B6 13 DF    LDA    $13DF
C7D4: 33 C6       LEAU   A,U
C7D6: 35 04       PULS   B
C7D8: 5A          DECB
C7D9: 26 E4       BNE    $C7BF
C7DB: 7E C6 F8    JMP    $C6F8

l_c7e5:
C7E5: B6 14 4C    LDA    $144C                                        
C7E8: 26 01       BNE    $C7EB
C7EA: 39          RTS
C7EB: B6 13 81    LDA    $1381
C7EE: 27 08       BEQ    $C7F8
C7F0: 8E C8 16    LDX    #$C816
C7F3: CE 07 C7    LDU    #$07C7
C7F6: 20 06       BRA    $C7FE
C7F8: 8E C8 12    LDX    #$C812
C7FB: CE 07 DA    LDU    #$07DA
C7FE: B6 13 B0    LDA    $13B0
C801: 85 10       BITA   #$10
C803: 27 04       BEQ    $C809
C805: BD F3 C3    JSR    $F3C3
C808: 39          RTS
C809: 86 20       LDA    #$20
C80B: A7 C4       STA    ,U
C80D: A7 C2       STA    ,-U
C80F: A7 C2       STA    ,-U
C811: 39          RTS

l_c81a:
C81A: B6 14 4A    LDA    $144A                                       
C81D: 26 01       BNE    $C820
C81F: 39          RTS
C820: 8E 12 80    LDX    #$1280
C823: CE 11 32    LDU    #$1132
C826: A6 84       LDA    ,X
C828: 26 06       BNE    $C830
C82A: 6F C9 00 80 CLR    $0080,U
C82E: 20 37       BRA    $C867
C830: 34 40       PSHS   U
C832: AD 98 0E    JSR    [$0E,X]
C835: 35 40       PULS   U
C837: A6 08       LDA    $8,X
C839: A7 C4       STA    ,U
C83B: A6 09       LDA    $9,X
C83D: A7 41       STA    $1,U
C83F: A6 0A       LDA    $A,X
C841: A7 C9 01 00 STA    $0100,U
C845: A6 04       LDA    $4,X
C847: B7 13 E3    STA    $13E3
C84A: EC 01       LDD    $1,X
C84C: BD F2 34    JSR    $F234
C84F: B6 13 93    LDA    $1393
C852: 27 13       BEQ    $C867
C854: A6 C9 01 01 LDA    $0101,U
C858: E6 C9 00 81 LDB    $0081,U
C85C: 83 00 10    SUBD   #$0010
C85F: A7 C9 01 01 STA    $0101,U
C863: E7 C9 00 81 STB    $0081,U
C867: 33 42       LEAU   $2,U
C869: 30 88 30    LEAX   $30,X
C86C: 8C 13 40    CMPX   #$1340
C86F: 26 B5       BNE    $C826
C871: 39          RTS
l_c872:
C872: A6 84       LDA    ,X
C874: 8B 02       ADDA   #$02
C876: A7 84       STA    ,X
C878: 9F 1C       STX    <$1C
C87A: 86 32       LDA    #$32
C87C: A7 08       STA    $8,X
C87E: A6 0A       LDA    $A,X
C880: 8A 04       ORA    #$04
C882: A7 0A       STA    $A,X
C884: BD F0 42    JSR    $F042
l_c887:
C887: BD C9 D4    JSR    $C9D4
C88A: A6 84       LDA    ,X
C88C: 85 01       BITA   #$01
C88E: 26 06       BNE    $C896
C890: A6 0A       LDA    $A,X
C892: 8A 02       ORA    #$02
C894: A7 0A       STA    $A,X
C896: 86 01       LDA    #$01
C898: B7 40 4A    STA    $404A
C89B: EC 01       LDD    $1,X
C89D: 2B 55       BMI    $C8F4
C89F: C3 00 11    ADDD   #$0011
C8A2: 2B 50       BMI    $C8F4
C8A4: 10 B3 13 CC CMPD   $13CC
C8A8: 25 4A       BCS    $C8F4
C8AA: EC 01       LDD    $1,X
C8AC: 10 B3 13 CE CMPD   $13CE
C8B0: 22 42       BHI    $C8F4
C8B2: CE 22 00    LDU    #$2200
C8B5: 11 83 24 40 CMPU   #$2440
C8B9: 26 01       BNE    $C8BC
C8BB: 39          RTS
C8BC: A6 C8 26    LDA    $26,U
C8BF: 26 2E       BNE    $C8EF
C8C1: A6 C4       LDA    ,U
C8C3: 81 FE       CMPA   #$FE
C8C5: 25 01       BCS    $C8C8
C8C7: 39          RTS
C8C8: 81 10       CMPA   #$10
C8CA: 24 23       BCC    $C8EF
C8CC: A6 04       LDA    $4,X
C8CE: A0 44       SUBA   $4,U
C8D0: 8B 1C       ADDA   #$1C
C8D2: 81 28       CMPA   #$28
C8D4: 22 19       BHI    $C8EF
C8D6: EC 01       LDD    $1,X
C8D8: A3 41       SUBD   $1,U
C8DA: C3 00 0F    ADDD   #$000F
C8DD: 10 83 00 1E CMPD   #$001E
C8E1: 22 0C       BHI    $C8EF
C8E3: 86 10       LDA    #$10
C8E5: A7 C4       STA    ,U
C8E7: AF C8 1C    STX    $1C,U
C8EA: CC ED 58    LDD    #$ED58
C8ED: ED 4E       STD    $E,U
C8EF: 33 C8 30    LEAU   $30,U
C8F2: 20 C1       BRA    $C8B5
C8F4: BD F0 42    JSR    $F042
l_c8f7:
C8F7: A6 84       LDA    ,X
C8F9: 8B 02       ADDA   #$02
C8FB: A7 84       STA    ,X
C8FD: 6F 0B       CLR    $B,X
C8FF: CC 03 00    LDD    #$0300
C902: ED 05       STD    $5,X
C904: A6 04       LDA    $4,X
C906: 8B 06       ADDA   #$06
C908: A7 04       STA    $4,X
C90A: 7F 40 4A    CLR    $404A
C90D: 6F 0A       CLR    $A,X
C90F: BD F0 42    JSR    $F042
l_c912:
C912: A6 0B       LDA    $B,X
C914: 10 27 00 B4 LBEQ   $C9CC
C918: E6 0B       LDB    $B,X
C91A: 34 10       PSHS   X
C91C: B6 22 00    LDA    $2200
C91F: 81 12       CMPA   #$12
C921: 26 05       BNE    $C928
C923: 8E D4 B2    LDX    #$D4B2
C926: 20 03       BRA    $C92B
C928: 8E D4 9E    LDX    #$D49E
C92B: 58          ASLB
C92C: 3A          ABX
C92D: BD F2 63    JSR    $F263
C930: 35 10       PULS   X
C932: A6 84       LDA    ,X
C934: 85 01       BITA   #$01
C936: 26 4B       BNE    $C983
C938: 86 40       LDA    #$40
C93A: A7 88 18    STA    $18,X
C93D: AB 0B       ADDA   $B,X
C93F: A7 08       STA    $8,X
C941: 86 07       LDA    #$07
C943: A7 84       STA    ,X
C945: A7 88 10    STA    $10,X
C948: F6 22 00    LDB    $2200
C94B: C1 12       CMPB   #$12
C94D: 26 08       BNE    $C957
C94F: A7 88 20    STA    $20,X
C952: 86 4B       LDA    #$4B
C954: A7 88 28    STA    $28,X
C957: FC 13 CE    LDD    $13CE
C95A: 83 00 04    SUBD   #$0004
C95D: ED 01       STD    $1,X
C95F: A6 04       LDA    $4,X
C961: A7 88 14    STA    $14,X
C964: A7 88 24    STA    $24,X
C967: F6 13 93    LDB    $1393
C96A: 27 04       BEQ    $C970
C96C: 80 10       SUBA   #$10
C96E: A7 04       STA    $4,X
C970: BD F0 42    JSR    $F042
l_c973:
C973: 8D 5F       BSR    $C9D4
C975: EC 01       LDD    $1,X
C977: C3 00 11    ADDD   #$0011
C97A: 2B 50       BMI    $C9CC
C97C: 10 B3 13 CC CMPD   $13CC
C980: 25 4A       BCS    $C9CC
C982: 39          RTS
C983: 86 08       LDA    #$08
C985: A7 84       STA    ,X
C987: A7 88 10    STA    $10,X
C98A: F6 22 00    LDB    $2200
C98D: C1 12       CMPB   #$12
C98F: 26 13       BNE    $C9A4
C991: A7 88 20    STA    $20,X
C994: 86 40       LDA    #$40
C996: A7 88 18    STA    $18,X
C999: AB 0B       ADDA   $B,X
C99B: A7 88 28    STA    $28,X
C99E: 86 4B       LDA    #$4B
C9A0: A7 08       STA    $8,X
C9A2: 20 09       BRA    $C9AD
C9A4: 86 40       LDA    #$40
C9A6: A7 08       STA    $8,X
C9A8: AB 0B       ADDA   $B,X
C9AA: A7 88 18    STA    $18,X
C9AD: A6 04       LDA    $4,X
C9AF: A7 88 14    STA    $14,X
C9B2: A7 88 24    STA    $24,X
C9B5: F6 13 93    LDB    $1393
C9B8: 27 04       BEQ    $C9BE
C9BA: 80 10       SUBA   #$10
C9BC: A7 04       STA    $4,X
C9BE: BD F0 42    JSR    $F042
C9C1: 8D 11       BSR    $C9D4
C9C3: EC 01       LDD    $1,X
C9C5: 10 B3 13 CE CMPD   $13CE
C9C9: 22 01       BHI    $C9CC
C9CB: 39          RTS
C9CC: 6F 84       CLR    ,X
C9CE: CE C8 72    LDU    #$C872
C9D1: EF 0E       STU    $E,X
C9D3: 39          RTS
C9D4: A6 84       LDA    ,X
C9D6: 85 01       BITA   #$01
C9D8: 27 0A       BEQ    $C9E4
C9DA: EC 02       LDD    $2,X
C9DC: A3 05       SUBD   $5,X
C9DE: 24 0C       BCC    $C9EC
C9E0: 6A 01       DEC    $1,X
C9E2: 20 08       BRA    $C9EC
C9E4: EC 02       LDD    $2,X
C9E6: E3 05       ADDD   $5,X
C9E8: 24 02       BCC    $C9EC
C9EA: 6C 01       INC    $1,X
C9EC: ED 02       STD    $2,X
C9EE: 6C 07       INC    $7,X
C9F0: A6 07       LDA    $7,X
C9F2: 44          LSRA
C9F3: 44          LSRA
C9F4: 81 03       CMPA   #$03
C9F6: 25 03       BCS    $C9FB
C9F8: 4F          CLRA
C9F9: 6F 07       CLR    $7,X
C9FB: 84 03       ANDA   #$03
C9FD: A7 09       STA    $9,X
C9FF: 39          RTS
l_ca00:
CA00: B6 14 4A    LDA    $144A
CA03: 26 01       BNE    $CA06
CA05: 39          RTS
CA06: 8E 12 80    LDX    #$1280
CA09: CE 11 3A    LDU    #$113A
CA0C: AD 98 1E    JSR    [$1E,X]
CA0F: A6 88 10    LDA    $10,X
CA12: 81 08       CMPA   #$08
CA14: 23 17       BLS    $CA2D
CA16: A6 88 18    LDA    $18,X
CA19: A7 C4       STA    ,U
CA1B: A6 09       LDA    $9,X
CA1D: A7 41       STA    $1,U
CA1F: A6 88 14    LDA    $14,X
CA22: B7 13 E3    STA    $13E3
CA25: EC 88 11    LDD    $11,X
CA28: BD F2 34    JSR    $F234
CA2B: 20 04       BRA    $CA31
CA2D: 6F C9 00 80 CLR    $0080,U
CA31: 33 42       LEAU   $2,U
CA33: 30 88 30    LEAX   $30,X
CA36: 8C 13 40    CMPX   #$1340
CA39: 26 D1       BNE    $CA0C
CA3B: 39          RTS
l_ca3c:
CA3C: A6 88 10    LDA    $10,X
CA3F: 26 01       BNE    $CA42
CA41: 39          RTS
CA42: 85 01       BITA   #$01
CA44: 27 45       BEQ    $CA8B
CA46: BD CA D0    JSR    $CAD0
CA49: FC 13 CE    LDD    $13CE
CA4C: A3 01       SUBD   $1,X
CA4E: 10 83 00 0D CMPD   #$000D
CA52: 24 01       BCC    $CA55
CA54: 39          RTS
CA55: BD CA D0    JSR    $CAD0
CA58: A6 84       LDA    ,X
CA5A: 27 11       BEQ    $CA6D
CA5C: 86 09       LDA    #$09
CA5E: A7 88 10    STA    $10,X
CA61: EC 01       LDD    $1,X
CA63: C3 00 10    ADDD   #$0010
CA66: ED 88 11    STD    $11,X
CA69: 39          RTS
CA6A: BD CA D0    JSR    $CAD0
CA6D: EC 88 12    LDD    $12,X
CA70: A3 88 15    SUBD   $15,X
CA73: 24 03       BCC    $CA78
CA75: 6A 88 11    DEC    $11,X
CA78: ED 88 12    STD    $12,X
CA7B: EC 88 11    LDD    $11,X
CA7E: C3 00 11    ADDD   #$0011
CA81: 2B 43       BMI    $CAC6
CA83: 10 B3 13 CC CMPD   $13CC
CA87: 25 3D       BCS    $CAC6
CA89: 20 DF       BRA    $CA6A
CA8B: 8D 43       BSR    $CAD0
CA8D: EC 01       LDD    $1,X
CA8F: B3 13 CC    SUBD   $13CC
CA92: 10 83 00 0D CMPD   #$000D
CA96: 24 01       BCC    $CA99
CA98: 39          RTS
CA99: 8D 35       BSR    $CAD0
CA9B: A6 84       LDA    ,X
CA9D: 27 10       BEQ    $CAAF
CA9F: 86 0A       LDA    #$0A
CAA1: A7 88 10    STA    $10,X
CAA4: EC 01       LDD    $1,X
CAA6: 83 00 10    SUBD   #$0010
CAA9: ED 88 11    STD    $11,X
CAAC: 39          RTS
CAAD: 8D 21       BSR    $CAD0
CAAF: EC 88 12    LDD    $12,X
CAB2: E3 88 15    ADDD   $15,X
CAB5: 24 03       BCC    $CABA
CAB7: 6C 88 11    INC    $11,X
CABA: ED 88 12    STD    $12,X
CABD: EC 88 11    LDD    $11,X
CAC0: 10 B3 13 CE CMPD   $13CE
CAC4: 23 E7       BLS    $CAAD
CAC6: 6F 88 10    CLR    $10,X
CAC9: CC CA 3C    LDD    #$CA3C
CACC: ED 88 1E    STD    $1E,X
CACF: 39          RTS
save_context_cad0:
CAD0: 35 06       PULS   D
CAD2: ED 88 1E    STD    $1E,X
CAD5: 39          RTS
l_cad6:
CAD6: B6 14 4A    LDA    $144A
CAD9: 26 01       BNE    $CADC
CADB: 39          RTS
CADC: 8E 12 80    LDX    #$1280
CADF: CE 11 42    LDU    #$1142
CAE2: AD 98 2E    JSR    [$2E,X]
CAE5: A6 88 20    LDA    $20,X
CAE8: 81 08       CMPA   #$08
CAEA: 23 17       BLS    $CB03
CAEC: A6 88 28    LDA    $28,X
CAEF: A7 C4       STA    ,U
CAF1: A6 09       LDA    $9,X
CAF3: A7 41       STA    $1,U
CAF5: A6 88 24    LDA    $24,X
CAF8: B7 13 E3    STA    $13E3
CAFB: EC 88 21    LDD    $21,X
CAFE: BD F2 34    JSR    $F234
CB01: 20 04       BRA    $CB07
CB03: 6F C9 00 80 CLR    $0080,U
CB07: 33 42       LEAU   $2,U
CB09: 30 88 30    LEAX   $30,X
CB0C: 8C 13 40    CMPX   #$1340
CB0F: 26 D1       BNE    $CAE2
CB11: 39          RTS
l_cb12:
CB12: A6 88 20    LDA    $20,X
CB15: 26 01       BNE    $CB18
CB17: 39          RTS
CB18: E6 88 10    LDB    $10,X
CB1B: C1 08       CMPB   #$08
CB1D: 22 01       BHI    $CB20
CB1F: 39          RTS
CB20: 85 01       BITA   #$01
CB22: 27 48       BEQ    $CB6C
CB24: BD CB B4    JSR    $CBB4
CB27: FC 13 CE    LDD    $13CE
CB2A: A3 88 11    SUBD   $11,X
CB2D: 10 83 00 0D CMPD   #$000D
CB31: 24 01       BCC    $CB34
CB33: 39          RTS
CB34: BD CB B4    JSR    $CBB4
CB37: A6 88 10    LDA    $10,X
CB3A: 27 12       BEQ    $CB4E
CB3C: 86 09       LDA    #$09
CB3E: A7 88 20    STA    $20,X
CB41: EC 88 11    LDD    $11,X
CB44: C3 00 10    ADDD   #$0010
CB47: ED 88 21    STD    $21,X
CB4A: 39          RTS
CB4B: BD CB B4    JSR    $CBB4
CB4E: EC 88 22    LDD    $22,X
CB51: A3 88 25    SUBD   $25,X
CB54: 24 03       BCC    $CB59
CB56: 6A 88 21    DEC    $21,X
CB59: ED 88 22    STD    $22,X
CB5C: EC 88 21    LDD    $21,X
CB5F: C3 00 11    ADDD   #$0011
CB62: 2B 46       BMI    $CBAA
CB64: 10 B3 13 CC CMPD   $13CC
CB68: 25 40       BCS    $CBAA
CB6A: 20 DF       BRA    $CB4B
CB6C: 8D 46       BSR    $CBB4
CB6E: EC 88 11    LDD    $11,X
CB71: B3 13 CC    SUBD   $13CC
CB74: 10 83 00 0D CMPD   #$000D
CB78: 24 01       BCC    $CB7B
CB7A: 39          RTS
CB7B: 8D 37       BSR    $CBB4
CB7D: A6 88 10    LDA    $10,X
CB80: 27 11       BEQ    $CB93
CB82: 86 0A       LDA    #$0A
CB84: A7 88 20    STA    $20,X
CB87: EC 88 11    LDD    $11,X
CB8A: 83 00 10    SUBD   #$0010
CB8D: ED 88 21    STD    $21,X
CB90: 39          RTS
CB91: 8D 21       BSR    $CBB4
CB93: EC 88 22    LDD    $22,X
CB96: E3 88 25    ADDD   $25,X
CB99: 24 03       BCC    $CB9E
CB9B: 6C 88 21    INC    $21,X
CB9E: ED 88 22    STD    $22,X
CBA1: EC 88 21    LDD    $21,X
CBA4: 10 B3 13 CE CMPD   $13CE
CBA8: 23 E7       BLS    $CB91
CBAA: 6F 88 20    CLR    $20,X
CBAD: CC CB 12    LDD    #$CB12
CBB0: ED 88 2E    STD    $2E,X
CBB3: 39          RTS
save_context_cbb4:
CBB4: 35 06       PULS   D
CBB6: ED 88 2E    STD    $2E,X
CBB9: 39          RTS
l_cbba:
CBBA: B6 14 46    LDA    $1446
CBBD: 26 01       BNE    $CBC0
CBBF: 39          RTS
CBC0: 8E 20 40    LDX    #$2040
CBC3: CE 11 04    LDU    #$1104
CBC6: A6 84       LDA    ,X
CBC8: 26 1A       BNE    $CBE4
CBCA: A6 03       LDA    $3,X
CBCC: 10 27 00 CC LBEQ   $CC9C
CBD0: 6A 04       DEC    $4,X
CBD2: A6 04       LDA    $4,X
CBD4: 85 04       BITA   #$04
CBD6: 27 05       BEQ    $CBDD
CBD8: 6F 02       CLR    $2,X
CBDA: 7E CC 9C    JMP    $CC9C
CBDD: 86 0F       LDA    #$0F
CBDF: A7 02       STA    $2,X
CBE1: 7E CC 9C    JMP    $CC9C
CBE4: 81 01       CMPA   #$01
CBE6: 27 14       BEQ    $CBFC
CBE8: 81 02       CMPA   #$02
CBEA: 27 03       BEQ    $CBEF
CBEC: 7E CC C1    JMP    $CCC1
CBEF: 6A 04       DEC    $4,X
CBF1: 10 26 00 A7 LBNE   $CC9C
CBF5: 86 03       LDA    #$03
CBF7: A7 84       STA    ,X
CBF9: 7E CC 9C    JMP    $CC9C
CBFC: B6 13 50    LDA    $1350
CBFF: 26 08       BNE    $CC09
CC01: EC 05       LDD    $5,X
CC03: C3 00 1C    ADDD   #$001C
CC06: FD 13 55    STD    $1355
CC09: A6 03       LDA    $3,X
CC0B: 27 26       BEQ    $CC33
CC0D: 6F 02       CLR    $2,X
CC0F: E6 01       LDB    $1,X
CC11: 34 50       PSHS   U,X
CC13: 8E D4 56    LDX    #$D456
CC16: B6 13 50    LDA    $1350
CC19: 26 0D       BNE    $CC28
CC1B: B6 13 92    LDA    $1392
CC1E: 8B 2D       ADDA   #$2D
CC20: B7 13 51    STA    $1351
CC23: 86 01       LDA    #$01
CC25: B7 13 50    STA    $1350
CC28: 7C 13 92    INC    $1392
CC2B: B6 13 92    LDA    $1392
CC2E: 48          ASLA
CC2F: AE 86       LDX    A,X
CC31: 20 33       BRA    $CC66
CC33: 10 BE 20 9A LDY    $209A
CC37: 6F 23       CLR    $3,Y
CC39: 6F 22       CLR    $2,Y
CC3B: BF 20 9A    STX    $209A
CC3E: A6 0A       LDA    $A,X
CC40: A0 01       SUBA   $1,X
CC42: 27 06       BEQ    $CC4A
CC44: 81 08       CMPA   #$08
CC46: 26 0C       BNE    $CC54
CC48: 20 15       BRA    $CC5F
CC4A: 6C 0C       INC    $C,X
CC4C: FC 20 9A    LDD    $209A
CC4F: C3 00 09    ADDD   #$0009
CC52: 20 08       BRA    $CC5C
CC54: 6C 1A       INC    -$6,X
CC56: FC 20 9A    LDD    $209A
CC59: 83 00 09    SUBD   #$0009
CC5C: FD 20 9A    STD    $209A
CC5F: E6 01       LDB    $1,X
CC61: 34 50       PSHS   U,X
CC63: BE D4 56    LDX    $D456
CC66: C0 20       SUBB   #$20
CC68: 58          ASLB
CC69: 3A          ABX
CC6A: BD F2 63    JSR    $F263
CC6D: 35 50       PULS   X,U
CC6F: 86 02       LDA    #$02
CC71: A7 84       STA    ,X
CC73: 86 78       LDA    #$78
CC75: A7 04       STA    $4,X
CC77: EC 05       LDD    $5,X
CC79: C3 00 0C    ADDD   #$000C
CC7C: ED 05       STD    $5,X
CC7E: A6 07       LDA    $7,X
CC80: 80 0C       SUBA   #$0C
CC82: A7 07       STA    $7,X
CC84: F6 13 50    LDB    $1350
CC87: 27 0D       BEQ    $CC96
CC89: C1 01       CMPB   #$01
CC8B: 22 09       BHI    $CC96
CC8D: B7 13 57    STA    $1357
CC90: 7C 13 50    INC    $1350
CC93: BF 13 58    STX    $1358
CC96: A6 01       LDA    $1,X
CC98: 8B 08       ADDA   #$08
CC9A: A7 01       STA    $1,X
CC9C: EC 05       LDD    $5,X
CC9E: C3 00 11    ADDD   #$0011
CCA1: 10 B3 13 CC CMPD   $13CC
CCA5: 25 1A       BCS    $CCC1
CCA7: EC 05       LDD    $5,X
CCA9: 10 B3 13 CE CMPD   $13CE
CCAD: 22 12       BHI    $CCC1
CCAF: A6 07       LDA    $7,X
CCB1: B7 13 E3    STA    $13E3
CCB4: BD F2 34    JSR    $F234
CCB7: A6 01       LDA    $1,X
CCB9: A7 C4       STA    ,U
CCBB: A6 02       LDA    $2,X
CCBD: A7 41       STA    $1,U
CCBF: 20 04       BRA    $CCC5
CCC1: 6F C9 00 80 CLR    $0080,U
CCC5: A6 08       LDA    $8,X
CCC7: 81 FF       CMPA   #$FF
CCC9: 26 01       BNE    $CCCC
CCCB: 39          RTS
CCCC: 30 09       LEAX   $9,X
CCCE: 33 42       LEAU   $2,U
CCD0: 7E CB C6    JMP    $CBC6
l_ccd3:
CCD3: B6 14 46    LDA    $1446
CCD6: 26 01       BNE    $CCD9
CCD8: 39          RTS
CCD9: 8E 13 50    LDX    #$1350
CCDC: CE 11 18    LDU    #$1118
CCDF: A6 84       LDA    ,X
CCE1: 27 09       BEQ    $CCEC
CCE3: A6 98 08    LDA    [$08,X]
CCE6: 81 03       CMPA   #$03
CCE8: 25 07       BCS    $CCF1
CCEA: 6F 84       CLR    ,X
CCEC: 6F C9 00 80 CLR    $0080,U
CCF0: 39          RTS
CCF1: EC 05       LDD    $5,X
CCF3: C3 00 11    ADDD   #$0011
CCF6: 10 B3 13 CC CMPD   $13CC
CCFA: 25 F0       BCS    $CCEC
CCFC: EC 05       LDD    $5,X
CCFE: 10 B3 13 CE CMPD   $13CE
CD02: 22 E8       BHI    $CCEC
CD04: A6 07       LDA    $7,X
CD06: B7 13 E3    STA    $13E3
CD09: BD F2 34    JSR    $F234
CD0C: A6 01       LDA    $1,X
CD0E: A7 C4       STA    ,U
CD10: 6C 04       INC    $4,X
CD12: A6 04       LDA    $4,X
CD14: 44          LSRA
CD15: 44          LSRA
CD16: 81 03       CMPA   #$03
CD18: 25 03       BCS    $CD1D
CD1A: 4F          CLRA
CD1B: 6F 04       CLR    $4,X
CD1D: 84 03       ANDA   #$03
CD1F: A7 41       STA    $1,U
CD21: 39          RTS
l_cd22:
CD22: B6 14 4E    LDA    $144E
CD25: 26 01       BNE    $CD28
CD27: 39          RTS
CD28: 96 31       LDA    <$31
CD2A: 84 0F       ANDA   #$0F
CD2C: 81 07       CMPA   #$07
CD2E: 24 01       BCC    $CD31
CD30: 39          RTS
CD31: 81 09       CMPA   #$09
CD33: 23 07       BLS    $CD3C
CD35: 81 0D       CMPA   #$0D
CD37: 10 23 00 B4 LBLS   $CDEF
CD3B: 39          RTS
CD3C: 8E 21 A0    LDX    #$21A0
CD3F: CE 11 4C    LDU    #$114C
CD42: A6 84       LDA    ,X
CD44: 81 02       CMPA   #$02
CD46: 26 06       BNE    $CD4E
CD48: 6F C9 00 80 CLR    $0080,U
CD4C: 20 1B       BRA    $CD69
CD4E: 34 40       PSHS   U
CD50: AD 98 07    JSR    [$07,X]
CD53: 35 40       PULS   U
CD55: A6 04       LDA    $4,X
CD57: A7 C4       STA    ,U
CD59: 6F 41       CLR    $1,U
CD5B: 6F C9 01 00 CLR    $0100,U
CD5F: A6 03       LDA    $3,X
CD61: B7 13 E3    STA    $13E3
CD64: EC 01       LDD    $1,X
CD66: BD F2 34    JSR    $F234
CD69: A6 09       LDA    $9,X
CD6B: 81 FF       CMPA   #$FF
CD6D: 10 27 00 7E LBEQ   $CDEF
CD71: 33 42       LEAU   $2,U
CD73: 30 88 10    LEAX   $10,X
CD76: 20 CA       BRA    $CD42
CD78: 96 04       LDA    <$04
CD7A: 81 1C       CMPA   #$1C
CD7C: 22 0D       BHI    $CD8B
CD7E: DC 01       LDD    <$01
CD80: A3 01       SUBD   $1,X
CD82: C3 00 04    ADDD   #$0004
CD85: 10 83 00 08 CMPD   #$0008
CD89: 23 12       BLS    $CD9D
CD8B: 6C 05       INC    $5,X
CD8D: A6 05       LDA    $5,X
CD8F: 81 3C       CMPA   #$3C
CD91: 24 01       BCC    $CD94
CD93: 39          RTS
CD94: 6F 05       CLR    $5,X
CD96: A6 04       LDA    $4,X
CD98: 88 03       EORA   #$03
CD9A: A7 04       STA    $4,X
CD9C: 39          RTS
CD9D: 6C 84       INC    ,X
CD9F: 8D 49       BSR    $CDEA
CDA1: 86 04       LDA    #$04
CDA3: AB 03       ADDA   $3,X
CDA5: A7 03       STA    $3,X
CDA7: 81 FC       CMPA   #$FC
CDA9: 24 3A       BCC    $CDE5
CDAB: CE 22 00    LDU    #$2200
CDAE: 11 83 24 40 CMPU   #$2440
CDB2: 26 01       BNE    $CDB5
CDB4: 39          RTS
CDB5: A6 C4       LDA    ,U
CDB7: 81 FE       CMPA   #$FE
CDB9: 25 01       BCS    $CDBC
CDBB: 39          RTS
CDBC: 81 14       CMPA   #$14
CDBE: 24 20       BCC    $CDE0
CDC0: A6 03       LDA    $3,X
CDC2: A0 44       SUBA   $4,U
CDC4: 8B 0F       ADDA   #$0F
CDC6: 81 1E       CMPA   #$1E
CDC8: 22 16       BHI    $CDE0
CDCA: EC 01       LDD    $1,X
CDCC: A3 41       SUBD   $1,U
CDCE: C3 00 0F    ADDD   #$000F
CDD1: 10 83 00 1E CMPD   #$001E
CDD5: 22 09       BHI    $CDE0
CDD7: 86 14       LDA    #$14
CDD9: A7 C4       STA    ,U
CDDB: CC ED C1    LDD    #$EDC1
CDDE: ED 4E       STD    $E,U
CDE0: 33 C8 30    LEAU   $30,U
CDE3: 20 C9       BRA    $CDAE
CDE5: 6C 84       INC    ,X
CDE7: 8D 01       BSR    $CDEA
CDE9: 39          RTS
save_context_cdea:
CDEA: 35 06       PULS   D
CDEC: ED 07       STD    $7,X
CDEE: 39          RTS
CDEF: B6 14 54    LDA    $1454
CDF2: 26 01       BNE    $CDF5
CDF4: 39          RTS
CDF5: 8E 14 90    LDX    #$1490
CDF8: CE 11 52    LDU    #$1152
CDFB: A6 C4       LDA    ,U
CDFD: 26 06       BNE    $CE05
CDFF: 6F C9 00 80 CLR    $0080,U
CE03: 20 0A       BRA    $CE0F
CE05: A6 02       LDA    $2,X
CE07: B7 13 E3    STA    $13E3
CE0A: EC 84       LDD    ,X
CE0C: BD F2 34    JSR    $F234
CE0F: 33 42       LEAU   $2,U
CE11: 30 04       LEAX   $4,X
CE13: 8C 14 B8    CMPX   #$14B8
CE16: 25 E3       BCS    $CDFB
CE18: 39          RTS
l_ce19:
CE19: B6 14 50    LDA    $1450
CE1C: 26 01       BNE    $CE1F
CE1E: 39          RTS
CE1F: 96 31       LDA    <$31
CE21: 84 0F       ANDA   #$0F
CE23: 81 0B       CMPA   #$0B
CE25: 24 01       BCC    $CE28
CE27: 39          RTS
CE28: 81 0E       CMPA   #$0E
CE2A: 23 01       BLS    $CE2D
CE2C: 39          RTS
CE2D: 8E 21 C0    LDX    #$21C0
CE30: AD 98 0E    JSR    [$0E,X]
CE33: 30 88 10    LEAX   $10,X
CE36: 8C 21 E0    CMPX   #$21E0
CE39: 25 F5       BCS    $CE30
CE3B: 39          RTS
CE3C: A6 84       LDA    ,X
CE3E: 26 15       BNE    $CE55
CE40: 6C 03       INC    $3,X
CE42: A6 03       LDA    $3,X
CE44: 44          LSRA
CE45: 44          LSRA
CE46: 84 07       ANDA   #$07
CE48: 8B 10       ADDA   #$10
CE4A: EE 01       LDU    $1,X
CE4C: A7 C9 08 00 STA    $0800,U
CE50: A7 C9 08 20 STA    $0820,U
CE54: 39          RTS
CE55: EE 01       LDU    $1,X
CE57: 86 20       LDA    #$20
CE59: A7 C4       STA    ,U
CE5B: A7 C8 20    STA    $20,U
CE5E: 86 B4       LDA    #$B4
CE60: A7 03       STA    $3,X
CE62: BD F0 42    JSR    $F042
CE65: 6A 03       DEC    $3,X
CE67: 27 01       BEQ    $CE6A
CE69: 39          RTS
CE6A: EE 01       LDU    $1,X
CE6C: CC 19 00    LDD    #$1900
CE6F: A7 C4       STA    ,U
CE71: E7 C9 08 00 STB    $0800,U
CE75: A7 C8 20    STA    $20,U
CE78: E7 C9 08 20 STB    $0820,U
CE7C: BD F0 42    JSR    $F042
CE7F: 39          RTS
l_ce80:
CE80: B6 14 52    LDA    $1452
CE83: 26 01       BNE    $CE86
CE85: 39          RTS
CE86: 81 EE       CMPA   #$EE
CE88: 27 6F       BEQ    $CEF9
CE8A: 8E 24 00    LDX    #$2400
CE8D: A6 84       LDA    ,X
CE8F: 26 34       BNE    $CEC5
CE91: A6 05       LDA    $5,X
CE93: 90 04       SUBA   <$04
CE95: 8B 08       ADDA   #$08
CE97: 81 10       CMPA   #$10
CE99: 22 2A       BHI    $CEC5
CE9B: EC 03       LDD    $3,X
CE9D: 93 01       SUBD   <$01
CE9F: C3 00 10    ADDD   #$0010
CEA2: 10 83 00 20 CMPD   #$0020
CEA6: 25 27       BCS    $CECF
CEA8: 20 1B       BRA    $CEC5
CEAA: A6 84       LDA    ,X
CEAC: 26 17       BNE    $CEC5
CEAE: A6 05       LDA    $5,X
CEB0: 90 04       SUBA   <$04
CEB2: 8B 08       ADDA   #$08
CEB4: 81 10       CMPA   #$10
CEB6: 22 0D       BHI    $CEC5
CEB8: EC 03       LDD    $3,X
CEBA: 93 01       SUBD   <$01
CEBC: C3 00 08    ADDD   #$0008
CEBF: 10 83 00 10 CMPD   #$0010
CEC3: 25 0A       BCS    $CECF
CEC5: A6 07       LDA    $7,X
CEC7: 81 FF       CMPA   #$FF
CEC9: 27 2E       BEQ    $CEF9
CECB: 30 08       LEAX   $8,X
CECD: 20 DB       BRA    $CEAA
CECF: 86 01       LDA    #$01
CED1: A7 84       STA    ,X
CED3: B7 40 48    STA    $4048
CED6: 7C 13 9E    INC    $139E
CED9: A6 06       LDA    $6,X
CEDB: 27 11       BEQ    $CEEE
CEDD: CE 11 52    LDU    #$1152
CEE0: 6F C9 00 80 CLR    $0080,U
CEE4: 6F C9 01 00 CLR    $0100,U
CEE8: 0C 32       INC    <$32
CEEA: 7C 13 9F    INC    $139F
CEED: 39          RTS
CEEE: 96 00       LDA    <$00
CEF0: 81 07       CMPA   #$07
CEF2: 26 05       BNE    $CEF9
CEF4: 8E E8 2D    LDX    #$E82D
CEF7: 9F 0E       STX    <$0E
CEF9: 8E 24 00    LDX    #$2400
CEFC: CE 11 52    LDU    #$1152
CEFF: A6 84       LDA    ,X
CF01: 26 4D       BNE    $CF50
CF03: EC 03       LDD    $3,X
CF05: C3 00 11    ADDD   #$0011
CF08: 10 B3 13 CC CMPD   $13CC
CF0C: 25 42       BCS    $CF50
CF0E: EC 03       LDD    $3,X
CF10: 10 B3 13 CE CMPD   $13CE
CF14: 22 3A       BHI    $CF50
CF16: A6 05       LDA    $5,X
CF18: B7 13 E3    STA    $13E3
CF1B: BD F2 34    JSR    $F234
CF1E: A6 01       LDA    $1,X
CF20: A7 C4       STA    ,U
CF22: 6F 41       CLR    $1,U
CF24: A6 06       LDA    $6,X
CF26: A7 C9 01 00 STA    $0100,U
CF2A: 27 28       BEQ    $CF54
CF2C: B6 13 93    LDA    $1393
CF2F: 27 23       BEQ    $CF54
CF31: A6 C9 00 80 LDA    $0080,U
CF35: 80 10       SUBA   #$10
CF37: A7 C9 00 80 STA    $0080,U
CF3B: A6 C9 01 01 LDA    $0101,U
CF3F: E6 C9 00 81 LDB    $0081,U
CF43: 83 00 10    SUBD   #$0010
CF46: A7 C9 01 01 STA    $0101,U
CF4A: E7 C9 00 81 STB    $0081,U
CF4E: 20 04       BRA    $CF54
CF50: 6F C9 00 80 CLR    $0080,U
CF54: B6 40 4B    LDA    $404B
CF57: 27 1A       BEQ    $CF73
CF59: 6C 02       INC    $2,X
CF5B: A6 02       LDA    $2,X
CF5D: 81 28       CMPA   #$28
CF5F: 25 12       BCS    $CF73
CF61: 6F 02       CLR    $2,X
CF63: A6 01       LDA    $1,X
CF65: 81 50       CMPA   #$50
CF67: 24 04       BCC    $CF6D
CF69: 86 01       LDA    #$01
CF6B: 20 02       BRA    $CF6F
CF6D: 86 04       LDA    #$04
CF6F: A8 01       EORA   $1,X
CF71: A7 01       STA    $1,X
CF73: A6 07       LDA    $7,X
CF75: 81 FF       CMPA   #$FF
CF77: 26 01       BNE    $CF7A
CF79: 39          RTS
CF7A: 30 08       LEAX   $8,X
CF7C: 33 42       LEAU   $2,U
CF7E: 7E CE FF    JMP    $CEFF
l_cf81:
CF81: B6 14 4D    LDA    $144D
CF84: 26 01       BNE    $CF87
CF86: 39          RTS
CF87: 7F 14 4D    CLR    $144D
CF8A: B6 13 81    LDA    $1381
CF8D: 27 05       BEQ    $CF94
CF8F: CE 07 EB    LDU    #$07EB
CF92: 20 03       BRA    $CF97
CF94: CE 07 FE    LDU    #$07FE
CF97: 8E 20 36    LDX    #$2036
CF9A: C6 03       LDB    #$03
CF9C: A6 84       LDA    ,X
CF9E: 44          LSRA
CF9F: 44          LSRA
CFA0: 44          LSRA
CFA1: 44          LSRA
CFA2: 26 1E       BNE    $CFC2
CFA4: 86 20       LDA    #$20
CFA6: A7 C2       STA    ,-U
CFA8: A6 80       LDA    ,X+
CFAA: C1 01       CMPB   #$01
CFAC: 27 18       BEQ    $CFC6
CFAE: 84 0F       ANDA   #$0F
CFB0: 26 16       BNE    $CFC8
CFB2: 86 20       LDA    #$20
CFB4: A7 C2       STA    ,-U
CFB6: 5A          DECB
CFB7: 26 01       BNE    $CFBA
CFB9: 39          RTS
CFBA: 20 E0       BRA    $CF9C
CFBC: A6 84       LDA    ,X
CFBE: 44          LSRA
CFBF: 44          LSRA
CFC0: 44          LSRA
CFC1: 44          LSRA
CFC2: A7 C2       STA    ,-U
CFC4: A6 80       LDA    ,X+
CFC6: 84 0F       ANDA   #$0F
CFC8: A7 C2       STA    ,-U
CFCA: 5A          DECB
CFCB: 26 01       BNE    $CFCE
CFCD: 39          RTS
CFCE: 20 EC       BRA    $CFBC
l_cfd0:
CFD0: 8E 13 40    LDX    #$1340
CFD3: A6 84       LDA    ,X
CFD5: 26 01       BNE    $CFD8
CFD7: 39          RTS
CFD8: CE 11 4A    LDU    #$114A
CFDB: EC 02       LDD    $2,X
CFDD: 83 02 00    SUBD   #$0200
CFE0: 24 02       BCC    $CFE4
CFE2: 6A 01       DEC    $1,X
CFE4: ED 02       STD    $2,X
CFE6: EC 01       LDD    $1,X
CFE8: C3 00 21    ADDD   #$0021
CFEB: 2B 2C       BMI    $D019
CFED: 10 B3 13 CC CMPD   $13CC
CFF1: 25 26       BCS    $D019
CFF3: 86 34       LDA    #$34
CFF5: A7 C4       STA    ,U
CFF7: 6C 07       INC    $7,X
CFF9: A6 07       LDA    $7,X
CFFB: 44          LSRA
CFFC: 44          LSRA
CFFD: 81 03       CMPA   #$03
CFFF: 25 03       BCS    $D004
D001: 4F          CLRA
D002: 6F 07       CLR    $7,X
D004: 84 03       ANDA   #$03
D006: A7 41       STA    $1,U
D008: 86 08       LDA    #$08
D00A: A7 C9 01 00 STA    $0100,U
D00E: A6 04       LDA    $4,X
D010: B7 13 E3    STA    $13E3
D013: EC 01       LDD    $1,X
D015: BD F2 34    JSR    $F234
D018: 39          RTS
D019: 6F C9 01 00 CLR    $0100,U
D01D: 6F 84       CLR    ,X
D01F: 39          RTS

save_context_d08a:
D08A: 35 06       PULS   D  		; get return address                                        
D08C: FE 17 7E    LDU    $177E                                      
D08F: ED D8 FE    STD    [-$02,U]                                   
D092: 39          RTS                                               
D093: B7 13 B2    STA    $13B2

save_context_d096:
D096: 35 06       PULS   D
D098: FD 13 A0    STD    $13A0
D09B: BD D0 8A    JSR    $D08A
l_d09e:
D09E: B6 13 B2    LDA    $13B2
D0A1: 27 01       BEQ    $D0A4
D0A3: 39          RTS
D0A4: FE 13 A0    LDU    $13A0
D0A7: FF 14 00    STU    $1400
D0AA: 39          RTS
D0AB: D6 30       LDB    <$30
D0AD: 26 01       BNE    $D0B0
D0AF: 39          RTS
D0B0: C1 05       CMPB   #$05
D0B2: 23 02       BLS    $D0B6
D0B4: C6 05       LDB    #$05
D0B6: CE 07 9D    LDU    #$079D
D0B9: 34 04       PSHS   B
D0BB: C6 0F       LDB    #$0F
D0BD: 86 FC       LDA    #$FC
D0BF: A7 C4       STA    ,U
D0C1: E7 C9 08 00 STB    $0800,U
D0C5: 4C          INCA
D0C6: A7 5F       STA    -$1,U
D0C8: E7 C9 07 FF STB    $07FF,U
D0CC: 4C          INCA
D0CD: A7 C8 20    STA    $20,U
D0D0: E7 C9 08 20 STB    $0820,U
D0D4: 4C          INCA
D0D5: A7 C8 1F    STA    $1F,U
D0D8: E7 C9 08 1F STB    $081F,U
D0DC: 35 04       PULS   B
D0DE: 5A          DECB
D0DF: 26 01       BNE    $D0E2
D0E1: 39          RTS
D0E2: 33 5E       LEAU   -$2,U                                   
D0E4: 20 D3       BRA    $D0B9                                   

E000: CE 07 B0    LDU    #$07B0                                       
E003: CC 20 20    LDD    #$2020                                       
E006: ED C1       STD    ,U++                                         
E008: 11 83 07 C0 CMPU   #$07C0                                       
E00C: 26 F8       BNE    $E006
E00E: 8E 0F B3    LDX    #$0FB3
E011: 86 42       LDA    #$42
E013: A7 80       STA    ,X+
E015: 8C 0F BC    CMPX   #$0FBC
E018: 26 F9       BNE    $E013
E01A: B6 48 02    LDA    credits_tens_4802
E01D: 84 0F       ANDA   #$0F
E01F: 81 0F       CMPA   #$0F
E021: 26 0A       BNE    $E02D
E023: 8E E0 5E    LDX    #$E05E
E026: CE 07 BB    LDU    #$07BB
E029: BD F3 C3    JSR    $F3C3
E02C: 39          RTS
E02D: 8E E0 56    LDX    #$E056
E030: CE 07 BB    LDU    #$07BB
E033: BD F3 C3    JSR    $F3C3
E036: CE 07 B5    LDU    #$07B5
E039: B6 48 02    LDA    credits_tens_4802
E03C: 84 0F       ANDA   #$0F
E03E: 27 0A       BEQ    $E04A
E040: A7 C2       STA    ,-U
E042: B6 48 03    LDA    credits_unit_4803
E045: 84 0F       ANDA   #$0F
E047: A7 C2       STA    ,-U
E049: 39          RTS
E04A: B6 48 03    LDA    credits_unit_4803
E04D: 84 0F       ANDA   #$0F
E04F: A7 C2       STA    ,-U
E051: 86 20       LDA    #$20
E053: A7 C2       STA    ,-U
E055: 39          RTS

E068: 96 31       LDA    <$31                                        
E06A: 81 30       CMPA   #$30                                        
E06C: 23 01       BLS    $E06F                                       
E06E: 39          RTS                                                
E06F: 4C          INCA
E070: B7 13 8C    STA    $138C
E073: BD F4 C7    JSR    $F4C7
E076: CE 07 82    LDU    #$0782
E079: 86 20       LDA    #$20
E07B: A7 C8 20    STA    $20,U
E07E: A7 C0       STA    ,U+
E080: 11 83 07 90 CMPU   #$0790
E084: 26 F5       BNE    $E07B
E086: CE 07 82    LDU    #$0782
E089: F6 13 8E    LDB    $138E
E08C: 54          LSRB
E08D: 54          LSRB
E08E: 54          LSRB
E08F: 54          LSRB
E090: 27 26       BEQ    $E0B8
E092: 86 27       LDA    #$27
E094: A7 41       STA    $1,U
E096: 4C          INCA
E097: A7 C4       STA    ,U
E099: 4C          INCA
E09A: A7 C8 21    STA    $21,U
E09D: 4C          INCA
E09E: A7 C8 20    STA    $20,U
E0A1: 86 1A       LDA    #$1A
E0A3: A7 C9 08 00 STA    $0800,U
E0A7: A7 C9 08 01 STA    $0801,U
E0AB: A7 C9 08 20 STA    $0820,U
E0AF: A7 C9 08 21 STA    $0821,U
E0B3: 33 42       LEAU   $2,U
E0B5: 5A          DECB
E0B6: 26 DA       BNE    $E092
E0B8: F6 13 8E    LDB    $138E
E0BB: C4 0F       ANDB   #$0F
E0BD: C1 05       CMPB   #$05
E0BF: 25 25       BCS    $E0E6
E0C1: C0 05       SUBB   #$05
E0C3: 86 23       LDA    #$23
E0C5: A7 41       STA    $1,U
E0C7: 4C          INCA
E0C8: A7 C4       STA    ,U
E0CA: 4C          INCA
E0CB: A7 C8 21    STA    $21,U
E0CE: 4C          INCA
E0CF: A7 C8 20    STA    $20,U
E0D2: 86 19       LDA    #$19
E0D4: A7 C9 08 00 STA    $0800,U
E0D8: A7 C9 08 01 STA    $0801,U
E0DC: A7 C9 08 20 STA    $0820,U
E0E0: A7 C9 08 21 STA    $0821,U
E0E4: 33 42       LEAU   $2,U
E0E6: 5D          TSTB
E0E7: 26 01       BNE    $E0EA
E0E9: 39          RTS
E0EA: 86 21       LDA    #$21
E0EC: A7 C4       STA    ,U
E0EE: 4C          INCA
E0EF: A7 C8 20    STA    $20,U
E0F2: 86 18       LDA    #$18
E0F4: A7 C9 08 00 STA    $0800,U
E0F8: A7 C9 08 20 STA    $0820,U
E0FC: 33 41       LEAU   $1,U
E0FE: 5A          DECB
E0FF: 20 E5       BRA    $E0E6
E101: BD E1 79    JSR    $E179
E104: BD E1 C9    JSR    $E1C9
E107: BD E2 78    JSR    $E278
E10A: 7E E2 CD    JMP    $E2CD
E10D: B7 13 91    STA    $1391
E110: 10 8E D5 24 LDY    #$D524
E114: BD E1 91    JSR    $E191
E117: CE 00 66    LDU    #$0066
E11A: 86 A7       LDA    #$A7
E11C: A7 C4       STA    ,U
E11E: 5F          CLRB
E11F: E7 C9 08 00 STB    $0800,U
E123: 86 19       LDA    #$19
E125: 33 C8 20    LEAU   $20,U
E128: A7 C4       STA    ,U
E12A: E7 C9 08 00 STB    $0800,U
E12E: 33 C8 20    LEAU   $20,U
E131: 11 83 03 A6 CMPU   #$03A6
E135: 26 F1       BNE    $E128
E137: 86 A8       LDA    #$A8
E139: A7 C4       STA    ,U
E13B: E7 C9 08 00 STB    $0800,U
E13F: 8E 00 67    LDX    #$0067
E142: 86 1D       LDA    #$1D
E144: A7 80       STA    ,X+
E146: E7 89 07 FF STB    $07FF,X
E14A: 8C 00 80    CMPX   #$0080
E14D: 26 F5       BNE    $E144
E14F: 8E 03 A7    LDX    #$03A7
E152: A7 80       STA    ,X+
E154: E7 89 07 FF STB    $07FF,X
E158: 8C 03 C0    CMPX   #$03C0
E15B: 26 F5       BNE    $E152
E15D: 8E 00 7E    LDX    #$007E
E160: CC 5C 5C    LDD    #$5C5C
E163: ED 84       STD    ,X
E165: 30 88 20    LEAX   $20,X
E168: 8C 03 DE    CMPX   #$03DE
E16B: 26 F6       BNE    $E163
E16D: CC 1F 1F    LDD    #$1F1F
E170: ED 84       STD    ,X
E172: CC 1E 1E    LDD    #$1E1E
E175: FD 00 5E    STD    >$005E
E178: 39          RTS
E179: 96 31       LDA    <$31
E17B: 4C          INCA
E17C: 1F 89       TFR    A,B
E17E: 84 03       ANDA   #$03
E180: 8B 04       ADDA   #$04
E182: B7 13 91    STA    $1391
E185: 54          LSRB
E186: 54          LSRB
E187: C4 03       ANDB   #$03
E189: 58          ASLB
E18A: 10 8E D5 1C LDY    #$D51C
E18E: 10 AE A5    LDY    B,Y
E191: CE 00 00    LDU    #$0000
E194: C6 0A       LDB    #$0A
E196: 34 04       PSHS   B
E198: 8E D9 FB    LDX    #$D9FB
E19B: A6 A0       LDA    ,Y+
E19D: C6 06       LDB    #$06
E19F: 3D          MUL
E1A0: 30 8B       LEAX   D,X
E1A2: C6 06       LDB    #$06
E1A4: A6 80       LDA    ,X+
E1A6: A7 C4       STA    ,U
E1A8: B6 13 91    LDA    $1391
E1AB: 8B 40       ADDA   #$40
E1AD: A7 C9 08 00 STA    $0800,U
E1B1: 33 C8 20    LEAU   $20,U
E1B4: 5A          DECB
E1B5: 26 ED       BNE    $E1A4
E1B7: 35 04       PULS   B
E1B9: 5A          DECB
E1BA: 26 DA       BNE    $E196
E1BC: 33 C9 F8 81 LEAU   -$077F,U
E1C0: 11 83 00 06 CMPU   #$0006
E1C4: 26 01       BNE    $E1C7
E1C6: 39          RTS
E1C7: 20 CB       BRA    $E194
E1C9: 10 8E D6 50 LDY    #$D650
E1CD: 96 31       LDA    <$31
E1CF: 84 0F       ANDA   #$0F
E1D1: 48          ASLA
E1D2: 10 AE A6    LDY    A,Y
E1D5: CE 00 06    LDU    #$0006
E1D8: C6 0A       LDB    #$0A
E1DA: 34 04       PSHS   B
E1DC: 8E DD 3D    LDX    #$DD3D
E1DF: A6 A0       LDA    ,Y+
E1E1: C6 06       LDB    #$06
E1E3: 3D          MUL
E1E4: 30 8B       LEAX   D,X
E1E6: C6 06       LDB    #$06
E1E8: A6 80       LDA    ,X+
E1EA: A7 C4       STA    ,U
E1EC: 33 C8 20    LEAU   $20,U
E1EF: 5A          DECB
E1F0: 26 F6       BNE    $E1E8
E1F2: 35 04       PULS   B
E1F4: 5A          DECB
E1F5: 26 E3       BNE    $E1DA
E1F7: 33 C9 F8 84 LEAU   -$077C,U
E1FB: 11 83 00 1E CMPU   #$001E
E1FF: 27 02       BEQ    $E203
E201: 20 D5       BRA    $E1D8
E203: C6 0A       LDB    #$0A
E205: 34 04       PSHS   B
E207: 8E DD 3D    LDX    #$DD3D
E20A: A6 A0       LDA    ,Y+
E20C: 81 2F       CMPA   #$2F
E20E: 27 1C       BEQ    $E22C
E210: C6 06       LDB    #$06
E212: 3D          MUL
E213: 30 8B       LEAX   D,X
E215: C6 06       LDB    #$06
E217: A6 80       LDA    ,X+
E219: A7 C4       STA    ,U
E21B: 33 C8 20    LEAU   $20,U
E21E: 5A          DECB
E21F: 26 F6       BNE    $E217
E221: 35 04       PULS   B
E223: 5A          DECB
E224: 26 DF       BNE    $E205
E226: 33 C9 F8 81 LEAU   -$077F,U
E22A: 20 D7       BRA    $E203
E22C: 35 04       PULS   B
E22E: 8E 00 67    LDX    #$0067
E231: 86 1D       LDA    #$1D
E233: C6 20       LDB    #$20
E235: E1 80       CMPB   ,X+
E237: 26 02       BNE    $E23B
E239: A7 1F       STA    -$1,X
E23B: 8C 00 7E    CMPX   #$007E
E23E: 26 F5       BNE    $E235
E240: 8E 07 67    LDX    #$0767
E243: E1 80       CMPB   ,X+
E245: 26 02       BNE    $E249
E247: A7 1F       STA    -$1,X
E249: 8C 07 7E    CMPX   #$077E
E24C: 26 F5       BNE    $E243
E24E: 96 31       LDA    <$31
E250: 84 0F       ANDA   #$0F
E252: 81 0B       CMPA   #$0B
E254: 24 01       BCC    $E257
E256: 39          RTS
E257: 81 0E       CMPA   #$0E
E259: 23 01       BLS    $E25C
E25B: 39          RTS
E25C: 8E 21 C0    LDX    #$21C0
E25F: A6 84       LDA    ,X
E261: 26 0C       BNE    $E26F
E263: EE 01       LDU    $1,X
E265: 86 1B       LDA    #$1B
E267: A7 C9 08 00 STA    $0800,U
E26B: A7 C9 08 20 STA    $0820,U
E26F: 30 88 10    LEAX   $10,X
E272: 8C 21 E0    CMPX   #$21E0
E275: 25 E8       BCS    $E25F
E277: 39          RTS
E278: 8E 20 A0    LDX    #$20A0
E27B: 6F 84       CLR    ,X
E27D: EE 05       LDU    $5,X
E27F: A6 02       LDA    $2,X
E281: 81 04       CMPA   #$04
E283: 26 08       BNE    $E28D
E285: C6 03       LDB    #$03
E287: E7 04       STB    $4,X
E289: C6 30       LDB    #$30
E28B: 20 05       BRA    $E292
E28D: 6F 01       CLR    $1,X
E28F: 6F 02       CLR    $2,X
E291: 5F          CLRB
E292: A6 03       LDA    $3,X
E294: 10 8E DE 09 LDY    #$DE09
E298: 48          ASLA
E299: 10 AE A6    LDY    A,Y
E29C: 31 A5       LEAY   B,Y
E29E: C6 05       LDB    #$05
E2A0: A6 A0       LDA    ,Y+
E2A2: A7 C4       STA    ,U
E2A4: A6 04       LDA    $4,X
E2A6: A7 C9 08 00 STA    $0800,U
E2AA: 33 C8 E0    LEAU   -$20,U
E2AD: 5A          DECB
E2AE: 26 F0       BNE    $E2A0
E2B0: 33 C9 00 81 LEAU   $0081,U
E2B4: C6 03       LDB    #$03
E2B6: A6 A0       LDA    ,Y+
E2B8: A7 C4       STA    ,U
E2BA: A6 04       LDA    $4,X
E2BC: 33 C8 E0    LEAU   -$20,U
E2BF: 5A          DECB
E2C0: 26 F4       BNE    $E2B6
E2C2: A6 07       LDA    $7,X
E2C4: 81 FF       CMPA   #$FF
E2C6: 26 01       BNE    $E2C9
E2C8: 39          RTS
E2C9: 30 08       LEAX   $8,X
E2CB: 20 AE       BRA    $E27B
E2CD: 8E 20 E0    LDX    #$20E0
E2D0: EE 02       LDU    $2,X
E2D2: A6 05       LDA    $5,X
E2D4: 26 10       BNE    $E2E6
E2D6: A6 04       LDA    $4,X
E2D8: 27 06       BEQ    $E2E0
E2DA: 10 8E DE F1 LDY    #$DEF1
E2DE: 20 18       BRA    $E2F8
E2E0: 10 8E DF 15 LDY    #$DF15
E2E4: 20 12       BRA    $E2F8
E2E6: 86 5B       LDA    #$5B
E2E8: A7 5F       STA    -$1,U
E2EA: A6 04       LDA    $4,X
E2EC: 27 06       BEQ    $E2F4
E2EE: 10 8E DF 39 LDY    #$DF39
E2F2: 20 04       BRA    $E2F8
E2F4: 10 8E DF 5D LDY    #$DF5D
E2F8: EC A1       LDD    ,Y++
E2FA: ED C1       STD    ,U++
E2FC: A6 A4       LDA    ,Y
E2FE: A7 C4       STA    ,U
E300: 6F 84       CLR    ,X
E302: A6 07       LDA    $7,X
E304: 81 FF       CMPA   #$FF
E306: 26 01       BNE    $E309
E308: 39          RTS
E309: 30 08       LEAX   $8,X
E30B: 20 C3       BRA    $E2D0
E30D: B6 13 81    LDA    $1381
E310: 26 08       BNE    $E31A
E312: 8E C8 12    LDX    #$C812
E315: CE 07 DA    LDU    #$07DA
E318: 20 06       BRA    $E320
E31A: 8E C8 16    LDX    #$C816
E31D: CE 07 C7    LDU    #$07C7
E320: 7F 14 4C    CLR    $144C
E323: BD F3 C3    JSR    $F3C3
E326: 39          RTS
E327: 86 99       LDA    #$99
E329: AB 82       ADDA   ,-X
E32B: 19          DAA
E32C: A7 84       STA    ,X
E32E: 24 01       BCC    $E331
E330: 39          RTS
E331: 5A          DECB
E332: 26 01       BNE    $E335
E334: 39          RTS
E335: 20 F2       BRA    $E329
E337: A6 82       LDA    ,-X
E339: 26 04       BNE    $E33F
E33B: 33 5F       LEAU   -$1,U
E33D: 20 1D       BRA    $E35C
E33F: AB C2       ADDA   ,-U
E341: 19          DAA
E342: A7 C4       STA    ,U
E344: 25 16       BCS    $E35C
E346: 34 44       PSHS   U,B
E348: 11 83 10 05 CMPU   #$1005
E34C: 27 03       BEQ    $E351
E34E: 5A          DECB
E34F: 27 09       BEQ    $E35A
E351: 86 99       LDA    #$99
E353: AB C2       ADDA   ,-U
E355: 19          DAA
E356: A7 C4       STA    ,U
E358: 24 EE       BCC    $E348
E35A: 35 44       PULS   B,U
E35C: 5A          DECB
E35D: 26 D8       BNE    $E337
E35F: 39          RTS
E360: A6 82       LDA    ,-X
E362: 40          NEGA
E363: 80 66       SUBA   #$66
E365: A7 84       STA    ,X
E367: 84 0F       ANDA   #$0F
E369: 81 0A       CMPA   #$0A
E36B: 26 08       BNE    $E375
E36D: A6 84       LDA    ,X
E36F: 84 F0       ANDA   #$F0
E371: 8B 10       ADDA   #$10
E373: A7 84       STA    ,X
E375: A6 84       LDA    ,X
E377: 84 F0       ANDA   #$F0
E379: 81 A0       CMPA   #$A0
E37B: 26 02       BNE    $E37F
E37D: 6F 84       CLR    ,X
E37F: 5A          DECB
E380: 26 DE       BNE    $E360
E382: 39          RTS
E383: 86 04       LDA    #$04
E385: BD E1 0D    JSR    $E10D
E388: 8E E4 BB    LDX    #$E4BB
E38B: CE 02 AA    LDU    #$02AA
E38E: C6 03       LDB    #$03
E390: BD F3 D0    JSR    $F3D0
E393: 8E E4 C7    LDX    #$E4C7
E396: CE 02 CD    LDU    #$02CD
E399: C6 09       LDB    #$09
E39B: BD F3 D0    JSR    $F3D0
E39E: CE 03 4F    LDU    #$034F
E3A1: CC 01 07    LDD    #$0107
E3A4: A7 C4       STA    ,U
E3A6: E7 C9 08 00 STB    $0800,U
E3AA: 33 C8 C0    LEAU   -$40,U
E3AD: 8E 14 60    LDX    #$1460
E3B0: 8D 51       BSR    $E403
E3B2: CE 03 52    LDU    #$0352
E3B5: CC 02 07    LDD    #$0207
E3B8: A7 C4       STA    ,U
E3BA: E7 C9 08 00 STB    $0800,U
E3BE: 33 C8 C0    LEAU   -$40,U
E3C1: 8E 14 68    LDX    #$1468
E3C4: 8D 3D       BSR    $E403
E3C6: CE 03 55    LDU    #$0355
E3C9: CC 03 07    LDD    #$0307
E3CC: A7 C4       STA    ,U
E3CE: E7 C9 08 00 STB    $0800,U
E3D2: 33 C8 C0    LEAU   -$40,U
E3D5: 8E 14 70    LDX    #$1470
E3D8: 8D 29       BSR    $E403
E3DA: CE 03 58    LDU    #$0358
E3DD: CC 04 07    LDD    #$0407
E3E0: A7 C4       STA    ,U
E3E2: E7 C9 08 00 STB    $0800,U
E3E6: 33 C8 C0    LEAU   -$40,U
E3E9: 8E 14 78    LDX    #$1478
E3EC: 8D 15       BSR    $E403
E3EE: CE 03 5B    LDU    #$035B
E3F1: CC 05 07    LDD    #$0507
E3F4: A7 C4       STA    ,U
E3F6: E7 C9 08 00 STB    $0800,U
E3FA: 33 C8 C0    LEAU   -$40,U
E3FD: 8E 14 80    LDX    #$1480
E400: 8D 01       BSR    $E403
E402: 39          RTS
E403: A6 84       LDA    ,X
E405: 44          LSRA
E406: 44          LSRA
E407: 44          LSRA
E408: 44          LSRA
E409: 27 11       BEQ    $E41C
E40B: A7 C4       STA    ,U
E40D: 86 07       LDA    #$07
E40F: A7 C9 08 00 STA    $0800,U
E413: A6 80       LDA    ,X+
E415: 84 0F       ANDA   #$0F
E417: 33 C8 E0    LEAU   -$20,U
E41A: 20 09       BRA    $E425
E41C: 33 C8 E0    LEAU   -$20,U
E41F: A6 80       LDA    ,X+
E421: 84 0F       ANDA   #$0F
E423: 27 08       BEQ    $E42D
E425: A7 C4       STA    ,U
E427: 86 07       LDA    #$07
E429: A7 C9 08 00 STA    $0800,U
E42D: 33 C8 E0    LEAU   -$20,U
E430: 10 8E 00 02 LDY    #$0002
E434: A6 84       LDA    ,X
E436: 44          LSRA
E437: 44          LSRA
E438: 44          LSRA
E439: 44          LSRA
E43A: A7 C4       STA    ,U
E43C: 86 07       LDA    #$07
E43E: A7 C9 08 00 STA    $0800,U
E442: 33 C8 E0    LEAU   -$20,U
E445: A6 80       LDA    ,X+
E447: 84 0F       ANDA   #$0F
E449: A7 C4       STA    ,U
E44B: 86 07       LDA    #$07
E44D: A7 C9 08 00 STA    $0800,U
E451: 33 C8 E0    LEAU   -$20,U
E454: 31 3F       LEAY   -$1,Y
E456: 26 DC       BNE    $E434
E458: 6F C4       CLR    ,U
E45A: A7 C9 08 00 STA    $0800,U
E45E: 33 C8 A0    LEAU   -$60,U
E461: A6 80       LDA    ,X+
E463: 84 0F       ANDA   #$0F
E465: 27 1A       BEQ    $E481
E467: A7 C4       STA    ,U
E469: E7 C9 08 00 STB    $0800,U
E46D: 33 C8 E0    LEAU   -$20,U
E470: A6 84       LDA    ,X
E472: 44          LSRA
E473: 44          LSRA
E474: 44          LSRA
E475: 44          LSRA
E476: A7 C4       STA    ,U
E478: E7 C9 08 00 STB    $0800,U
E47C: 33 C8 E0    LEAU   -$20,U
E47F: 20 0E       BRA    $E48F
E481: 33 C8 E0    LEAU   -$20,U
E484: A6 84       LDA    ,X
E486: 44          LSRA
E487: 44          LSRA
E488: 44          LSRA
E489: 44          LSRA
E48A: 26 EA       BNE    $E476
E48C: 33 C8 E0    LEAU   -$20,U
E48F: A6 80       LDA    ,X+
E491: 84 0F       ANDA   #$0F
E493: A7 C4       STA    ,U
E495: E7 C9 08 00 STB    $0800,U
E499: 33 C8 80    LEAU   -$80,U
E49C: A6 80       LDA    ,X+
E49E: A7 C4       STA    ,U
E4A0: E7 C9 08 00 STB    $0800,U
E4A4: 33 C8 E0    LEAU   -$20,U
E4A7: A6 80       LDA    ,X+
E4A9: A7 C4       STA    ,U
E4AB: E7 C9 08 00 STB    $0800,U
E4AF: 33 C8 E0    LEAU   -$20,U
E4B2: A6 80       LDA    ,X+
E4B4: A7 C4       STA    ,U
E4B6: E7 C9 08 00 STB    $0800,U
E4BA: 39          RTS
E4BB: 7C 7C 20    INC    $7C20
E4BE: 54          LSRB
E4BF: 4F          CLRA
E4C0: 50          NEGB
E4C1: 20 35       BRA    $E4F8

l_e4d8:
E4D8: B6 14 42    LDA    $1442                                        
E4DB: 26 01       BNE    $E4DE
E4DD: 39          RTS
E4DE: A6 04       LDA    $4,X
E4E0: 84 F0       ANDA   #$F0
E4E2: 5F          CLRB
E4E3: ED 04       STD    $4,X
E4E5: BD F0 42    JSR    $F042
l_e4e8:
E4E8: A6 0D       LDA    $D,X
E4EA: 27 07       BEQ    $E4F3
E4EC: 84 08       ANDA   #$08
E4EE: 26 60       BNE    $E550
E4F0: 7E E6 BA    JMP    $E6BA
E4F3: 6F 84       CLR    ,X
E4F5: A6 88 18    LDA    $18,X
E4F8: 81 38       CMPA   #$38
E4FA: 26 07       BNE    $E503
E4FC: 86 27       LDA    #$27
E4FE: A7 89 11 00 STA    $1100,X
E502: 39          RTS
E503: A6 04       LDA    $4,X
E505: 81 20       CMPA   #$20
E507: 23 1D       BLS    $E526
E509: BD F0 47    JSR    $F047
E50C: BD F1 94    JSR    $F194
E50F: EE 88 12    LDU    $12,X
E512: A6 C4       LDA    ,U
E514: 27 10       BEQ    $E526
E516: A6 9F 13 C4 LDA    [$13C4]
E51A: 81 5D       CMPA   #$5D
E51C: 27 1E       BEQ    $E53C
E51E: 81 88       CMPA   #$88
E520: 25 04       BCS    $E526
E522: 81 9A       CMPA   #$9A
E524: 23 16       BLS    $E53C
E526: A6 88 18    LDA    $18,X
E529: 81 08       CMPA   #$08
E52B: 26 0B       BNE    $E538
E52D: 6F 0C       CLR    $C,X
E52F: E6 0A       LDB    $A,X
E531: C1 7E       CMPB   #$7E
E533: 26 01       BNE    $E536
E535: 39          RTS
E536: 86 26       LDA    #$26
E538: 4C          INCA
E539: A7 0A       STA    $A,X
E53B: 39          RTS
E53C: A6 0C       LDA    $C,X
E53E: 85 02       BITA   #$02
E540: 26 07       BNE    $E549
E542: A6 44       LDA    $4,U
E544: 26 E0       BNE    $E526
E546: 7E EC 52    JMP    $EC52
E549: A6 44       LDA    $4,U
E54B: 27 D9       BEQ    $E526
E54D: 7E EC 5D    JMP    $EC5D
E550: 86 01       LDA    #$01
E552: A7 84       STA    ,X
E554: B6 14 02    LDA    $1402
E557: 81 60       CMPA   #$60
E559: 10 27 00 93 LBEQ   $E5F0
E55D: 81 A0       CMPA   #$A0
E55F: 10 27 00 8D LBEQ   $E5F0
E563: A6 04       LDA    $4,X
E565: 81 20       CMPA   #$20
E567: 10 23 00 85 LBLS   $E5F0
E56B: BD F0 47    JSR    $F047
E56E: A6 C4       LDA    ,U
E570: 81 20       CMPA   #$20
E572: 27 7C       BEQ    $E5F0
E574: 81 1D       CMPA   #$1D
E576: 27 5B       BEQ    $E5D3
E578: BD F1 94    JSR    $F194
E57B: EE 88 12    LDU    $12,X
E57E: A6 88 18    LDA    $18,X
E581: 81 38       CMPA   #$38
E583: 27 36       BEQ    $E5BB
E585: A6 C4       LDA    ,U
E587: 26 14       BNE    $E59D
E589: A6 41       LDA    $1,U
E58B: 81 03       CMPA   #$03
E58D: 27 61       BEQ    $E5F0
E58F: A6 9F 13 C4 LDA    [$13C4]
E593: 81 8B       CMPA   #$8B
E595: 27 3C       BEQ    $E5D3
E597: 81 8A       CMPA   #$8A
E599: 27 38       BEQ    $E5D3
E59B: 20 4B       BRA    $E5E8
E59D: A6 88 18    LDA    $18,X
E5A0: 26 0A       BNE    $E5AC
E5A2: A6 41       LDA    $1,U
E5A4: 81 02       CMPA   #$02
E5A6: 25 04       BCS    $E5AC
E5A8: 81 04       CMPA   #$04
E5AA: 23 44       BLS    $E5F0
E5AC: A6 44       LDA    $4,U
E5AE: 10 27 06 A0 LBEQ   $EC52
E5B2: A6 41       LDA    $1,U
E5B4: 81 04       CMPA   #$04
E5B6: 25 38       BCS    $E5F0
E5B8: 7E EC 5D    JMP    $EC5D
E5BB: A6 9F 13 C4 LDA    [$13C4]
E5BF: 81 88       CMPA   #$88
E5C1: 25 2D       BCS    $E5F0
E5C3: 81 9A       CMPA   #$9A
E5C5: 22 29       BHI    $E5F0
E5C7: A6 41       LDA    $1,U
E5C9: 81 03       CMPA   #$03
E5CB: 24 23       BCC    $E5F0
E5CD: 86 01       LDA    #$01
E5CF: A7 C4       STA    ,U
E5D1: 20 1D       BRA    $E5F0
E5D3: A6 88 18    LDA    $18,X
E5D6: 27 10       BEQ    $E5E8
E5D8: 86 02       LDA    #$02
E5DA: A7 0D       STA    $D,X
E5DC: 86 03       LDA    #$03
E5DE: A7 88 1B    STA    $1B,X
E5E1: A6 04       LDA    $4,X
E5E3: A7 88 1F    STA    $1F,X
E5E6: 20 53       BRA    $E63B
E5E8: A6 02       LDA    $2,X
E5EA: 84 07       ANDA   #$07
E5EC: 81 06       CMPA   #$06
E5EE: 24 4B       BCC    $E63B
E5F0: EC 02       LDD    $2,X
E5F2: A3 06       SUBD   $6,X
E5F4: 24 02       BCC    $E5F8
E5F6: 6A 01       DEC    $1,X
E5F8: ED 02       STD    $2,X
E5FA: A6 88 18    LDA    $18,X
E5FD: 26 20       BNE    $E61F
E5FF: EC 01       LDD    $1,X
E601: 10 83 00 69 CMPD   #$0069
E605: 23 12       BLS    $E619
E607: 10 83 01 51 CMPD   #$0151
E60B: 24 12       BCC    $E61F
E60D: FC 13 89    LDD    scroll_value_1389
E610: E3 06       ADDD   $6,X
E612: 25 05       BCS    $E619
E614: FD 13 89    STD    scroll_value_1389
E617: 20 06       BRA    $E61F
E619: CC FF 00    LDD    #$FF00
E61C: FD 13 89    STD    scroll_value_1389
E61F: BD F0 9A    JSR    $F09A
E622: A6 C4       LDA    ,U
E624: 81 20       CMPA   #$20
E626: 27 4A       BEQ    $E672
E628: 81 A8       CMPA   #$A8
E62A: 27 2B       BEQ    $E657
E62C: 81 1A       CMPA   #$1A
E62E: 27 27       BEQ    $E657
E630: 81 60       CMPA   #$60
E632: 25 04       BCS    $E638
E634: 81 68       CMPA   #$68
E636: 25 1F       BCS    $E657
E638: BD F1 D3    JSR    $F1D3
E63B: 6C 88 17    INC    $17,X
E63E: A6 88 17    LDA    $17,X
E641: 85 02       BITA   #$02
E643: 26 01       BNE    $E646
E645: 39          RTS
E646: 8B 04       ADDA   #$04
E648: A7 88 17    STA    $17,X
E64B: 84 0C       ANDA   #$0C
E64D: 44          LSRA
E64E: 44          LSRA
E64F: AB 88 18    ADDA   $18,X
E652: A7 0A       STA    $A,X
E654: 6F 0C       CLR    $C,X
E656: 39          RTS
E657: A6 88 18    LDA    $18,X
E65A: 26 09       BNE    $E665
E65C: F6 40 41    LDB    $4041
E65F: 27 04       BEQ    $E665
E661: 86 18       LDA    #$18
E663: 20 02       BRA    $E667
E665: 8B 07       ADDA   #$07
E667: A7 0A       STA    $A,X
E669: CE D0 E6    LDU    #$D0E6
E66C: EF 88 10    STU    $10,X
E66F: 7E E7 E3    JMP    $E7E3
E672: 8D 10       BSR    $E684
E674: B6 13 E8    LDA    $13E8
E677: 27 C2       BEQ    $E63B
E679: 6C 88 2A    INC    $2A,X
E67C: A6 04       LDA    $4,X
E67E: A7 88 1F    STA    $1F,X
E681: 7E E8 2D    JMP    $E82D
E684: 7F 13 E8    CLR    $13E8
E687: 96 31       LDA    <$31
E689: 84 0F       ANDA   #$0F
E68B: 81 0B       CMPA   #$0B
E68D: 24 01       BCC    $E690
E68F: 39          RTS
E690: 81 0E       CMPA   #$0E
E692: 23 01       BLS    $E695
E694: 39          RTS
E695: 10 8E 21 C0 LDY    #$21C0
E699: 11 A3 21    CMPU   $1,Y
E69C: 27 18       BEQ    $E6B6
E69E: 34 40       PSHS   U
E6A0: 33 C8 E0    LEAU   -$20,U
E6A3: 11 A3 21    CMPU   $1,Y
E6A6: 27 0C       BEQ    $E6B4
E6A8: 35 40       PULS   U
E6AA: 31 A8 10    LEAY   $10,Y
E6AD: 10 8C 21 E0 CMPY   #$21E0
E6B1: 25 E6       BCS    $E699
E6B3: 39          RTS
E6B4: 35 40       PULS   U
E6B6: 7C 13 E8    INC    $13E8
E6B9: 39          RTS
E6BA: 86 02       LDA    #$02
E6BC: A7 84       STA    ,X
E6BE: B6 14 02    LDA    $1402
E6C1: 81 A0       CMPA   #$A0
E6C3: 10 27 00 96 LBEQ   $E75D
E6C7: A6 04       LDA    $4,X
E6C9: 81 20       CMPA   #$20
E6CB: 10 23 00 8E LBLS   $E75D
E6CF: BD F0 47    JSR    $F047
E6D2: A6 C4       LDA    ,U
E6D4: 81 20       CMPA   #$20
E6D6: 10 27 00 83 LBEQ   $E75D
E6DA: 81 1D       CMPA   #$1D
E6DC: 27 5B       BEQ    $E739
E6DE: BD F1 94    JSR    $F194
E6E1: EE 88 12    LDU    $12,X
E6E4: A6 88 18    LDA    $18,X
E6E7: 81 38       CMPA   #$38
E6E9: 27 36       BEQ    $E721
E6EB: A6 C4       LDA    ,U
E6ED: 26 14       BNE    $E703
E6EF: A6 41       LDA    $1,U
E6F1: 81 03       CMPA   #$03
E6F3: 27 68       BEQ    $E75D
E6F5: A6 9F 13 C4 LDA    [$13C4]
E6F9: 81 8B       CMPA   #$8B
E6FB: 27 3C       BEQ    $E739
E6FD: 81 8A       CMPA   #$8A
E6FF: 27 38       BEQ    $E739
E701: 20 52       BRA    $E755
E703: A6 88 18    LDA    $18,X
E706: 26 0A       BNE    $E712
E708: A6 41       LDA    $1,U
E70A: 81 02       CMPA   #$02
E70C: 25 04       BCS    $E712
E70E: 81 04       CMPA   #$04
E710: 23 4B       BLS    $E75D
E712: A6 44       LDA    $4,U
E714: 10 26 05 45 LBNE   $EC5D
E718: A6 41       LDA    $1,U
E71A: 81 04       CMPA   #$04
E71C: 25 3F       BCS    $E75D
E71E: 7E EC 52    JMP    $EC52
E721: A6 9F 13 C4 LDA    [$13C4]
E725: 81 88       CMPA   #$88
E727: 25 34       BCS    $E75D
E729: 81 9A       CMPA   #$9A
E72B: 22 30       BHI    $E75D
E72D: A6 41       LDA    $1,U
E72F: 81 03       CMPA   #$03
E731: 24 2A       BCC    $E75D
E733: 86 01       LDA    #$01
E735: A7 C4       STA    ,U
E737: 20 24       BRA    $E75D
E739: A6 88 18    LDA    $18,X
E73C: 27 17       BEQ    $E755
E73E: 86 08       LDA    #$08
E740: A7 0D       STA    $D,X
E742: 86 02       LDA    #$02
E744: A7 88 1B    STA    $1B,X
E747: A6 04       LDA    $4,X
E749: A7 88 1F    STA    $1F,X
E74C: 20 54       BRA    $E7A2
E74E: EE 88 12    LDU    $12,X
E751: 86 01       LDA    #$01
E753: A7 C4       STA    ,U
E755: A6 02       LDA    $2,X
E757: 84 07       ANDA   #$07
E759: 81 02       CMPA   #$02
E75B: 24 45       BCC    $E7A2
E75D: EC 02       LDD    $2,X
E75F: E3 06       ADDD   $6,X
E761: 24 02       BCC    $E765
E763: 6C 01       INC    $1,X
E765: ED 02       STD    $2,X
E767: A6 88 18    LDA    $18,X
E76A: 26 1E       BNE    $E78A
E76C: EC 01       LDD    $1,X
E76E: 10 83 00 69 CMPD   #$0069
E772: 23 16       BLS    $E78A
E774: 10 83 01 51 CMPD   #$0151
E778: 24 0A       BCC    $E784
E77A: FC 13 89    LDD    scroll_value_1389
E77D: A3 06       SUBD   $6,X
E77F: FD 13 89    STD    scroll_value_1389
E782: 20 06       BRA    $E78A
E784: CC 18 00    LDD    #$1800
E787: FD 13 89    STD    scroll_value_1389
E78A: BD F0 9A    JSR    $F09A
E78D: A6 C4       LDA    ,U
E78F: 81 20       CMPA   #$20
E791: 27 3D       BEQ    $E7D0
E793: 81 1B       CMPA   #$1B
E795: 27 29       BEQ    $E7C0
E797: 81 68       CMPA   #$68
E799: 25 04       BCS    $E79F
E79B: 81 70       CMPA   #$70
E79D: 25 21       BCS    $E7C0
E79F: BD F1 D3    JSR    $F1D3
E7A2: 6C 88 17    INC    $17,X
E7A5: A6 88 17    LDA    $17,X
E7A8: 85 02       BITA   #$02
E7AA: 26 01       BNE    $E7AD
E7AC: 39          RTS
E7AD: 8B 04       ADDA   #$04
E7AF: A7 88 17    STA    $17,X
E7B2: 84 0C       ANDA   #$0C
E7B4: 44          LSRA
E7B5: 44          LSRA
E7B6: AB 88 18    ADDA   $18,X
E7B9: A7 0A       STA    $A,X
E7BB: 86 02       LDA    #$02
E7BD: A7 0C       STA    $C,X
E7BF: 39          RTS
E7C0: 86 07       LDA    #$07
E7C2: AB 88 18    ADDA   $18,X
E7C5: A7 0A       STA    $A,X
E7C7: CE D0 E6    LDU    #$D0E6
E7CA: EF 88 10    STU    $10,X
E7CD: 7E E7 E3    JMP    $E7E3
E7D0: BD E6 84    JSR    $E684
E7D3: B6 13 E8    LDA    $13E8
E7D6: 27 CA       BEQ    $E7A2
E7D8: 6C 88 2A    INC    $2A,X
E7DB: A6 04       LDA    $4,X
E7DD: A7 88 1F    STA    $1F,X
E7E0: 7E E8 2D    JMP    $E82D
E7E3: A6 88 18    LDA    $18,X
E7E6: 81 08       CMPA   #$08
E7E8: 26 0D       BNE    $E7F7
E7EA: EE 88 19    LDU    $19,X
E7ED: 6F C9 00 80 CLR    $0080,U
E7F1: CE 11 1C    LDU    #$111C
E7F4: EF 88 19    STU    $19,X
E7F7: A6 84       LDA    ,X
E7F9: 8B 02       ADDA   #$02
E7FB: A7 84       STA    ,X
E7FD: 81 04       CMPA   #$04
E7FF: 26 06       BNE    $E807
E801: 86 02       LDA    #$02
E803: A7 0C       STA    $C,X
E805: 20 02       BRA    $E809
E807: 6F 0C       CLR    $C,X
E809: EE 88 10    LDU    $10,X
E80C: A6 42       LDA    $2,U
E80E: A7 88 17    STA    $17,X
E811: A6 88 18    LDA    $18,X
E814: 81 08       CMPA   #$08
E816: 26 05       BNE    $E81D
E818: A6 04       LDA    $4,X
E81A: A7 88 1F    STA    $1F,X
E81D: BD F0 42    JSR    $F042
l_e820:
E820: BD F1 1E    JSR    $F11E
E823: A6 C4       LDA    ,U
E825: 81 2F       CMPA   #$2F
E827: 27 01       BEQ    $E82A
E829: 39          RTS
E82A: 7E E8 2D    JMP    $E82D
E82D: 86 05       LDA    #$05
E82F: A7 84       STA    ,X
E831: 6F 0D       CLR    $D,X
E833: EC 04       LDD    $4,X
E835: 84 FE       ANDA   #$FE
E837: 5F          CLRB
E838: E3 08       ADDD   $8,X
E83A: ED 04       STD    $4,X
E83C: 86 04       LDA    #$04
E83E: AB 88 18    ADDA   $18,X
E841: A7 0A       STA    $A,X
E843: BD F0 42    JSR    $F042
l_e846:
E846: EC 04       LDD    $4,X
E848: E3 08       ADDD   $8,X
E84A: ED 04       STD    $4,X
E84C: 81 F0       CMPA   #$F0
E84E: 25 15       BCS    $E865
E850: A6 88 18    LDA    $18,X
E853: 10 27 00 A3 LBEQ   $E8FA
E857: CC 00 DC    LDD    #$00DC
E85A: ED 01       STD    $1,X
E85C: 86 10       LDA    #$10
E85E: A7 04       STA    $4,X
E860: 6F 84       CLR    ,X
E862: 7E E8 2D    JMP    $E82D
E865: BD F0 9A    JSR    $F09A
E868: CE 20 A0    LDU    #$20A0
E86B: EC 45       LDD    $5,U
E86D: C4 0F       ANDB   #$0F
E86F: F7 13 DC    STB    $13DC
E872: F6 13 C1    LDB    $13C1
E875: C4 0F       ANDB   #$0F
E877: F0 13 DC    SUBB   $13DC
E87A: 26 15       BNE    $E891
E87C: EC 45       LDD    $5,U
E87E: B3 13 C0    SUBD   $13C0
E881: C5 10       BITB   #$10
E883: 26 0C       BNE    $E891
E885: 46          RORA
E886: 56          RORB
E887: 46          RORA
E888: 56          RORB
E889: 46          RORA
E88A: 56          RORB
E88B: 46          RORA
E88C: 56          RORB
E88D: C1 06       CMPB   #$06
E88F: 23 0A       BLS    $E89B
E891: A6 47       LDA    $7,U
E893: 81 FF       CMPA   #$FF
E895: 27 10       BEQ    $E8A7
E897: 33 48       LEAU   $8,U
E899: 20 D0       BRA    $E86B
E89B: A6 42       LDA    $2,U
E89D: 81 04       CMPA   #$04
E89F: 24 06       BCC    $E8A7
E8A1: EF 88 15    STU    $15,X
E8A4: 7E E9 24    JMP    $E924
E8A7: A6 9F 13 C0 LDA    [$13C0]
E8AB: 81 19       CMPA   #$19
E8AD: 27 08       BEQ    $E8B7
E8AF: 81 1C       CMPA   #$1C
E8B1: 27 04       BEQ    $E8B7
E8B3: 81 5B       CMPA   #$5B
E8B5: 26 29       BNE    $E8E0
E8B7: A6 88 2A    LDA    $2A,X
E8BA: 27 11       BEQ    $E8CD
E8BC: A6 88 1F    LDA    $1F,X
E8BF: 8B 10       ADDA   #$10
E8C1: A0 04       SUBA   $4,X
E8C3: 24 1B       BCC    $E8E0
E8C5: A6 88 18    LDA    $18,X
E8C8: 27 30       BEQ    $E8FA
E8CA: 7E EE 56    JMP    $EE56
E8CD: E6 88 18    LDB    $18,X
E8D0: 27 28       BEQ    $E8FA
E8D2: C1 08       CMPB   #$08
E8D4: 27 2F       BEQ    $E905
E8D6: 6F 84       CLR    ,X
E8D8: 86 FF       LDA    #$FF
E8DA: A7 88 1B    STA    $1B,X
E8DD: 7E E4 DE    JMP    $E4DE
E8E0: 6A 88 17    DEC    $17,X
E8E3: A6 88 17    LDA    $17,X
E8E6: 85 02       BITA   #$02
E8E8: 26 01       BNE    $E8EB
E8EA: 39          RTS
E8EB: 84 04       ANDA   #$04
E8ED: 44          LSRA
E8EE: 44          LSRA
E8EF: 8B 04       ADDA   #$04
E8F1: AB 88 18    ADDA   $18,X
E8F4: A7 0A       STA    $A,X
E8F6: 4F          CLRA
E8F7: A7 0C       STA    $C,X
E8F9: 39          RTS
E8FA: 86 01       LDA    #$01
E8FC: 97 33       STA    <$33
E8FE: DE 15       LDU    <$15
E900: 6F 42       CLR    $2,U
E902: 7E E4 DE    JMP    $E4DE
E905: 6F 0C       CLR    $C,X
E907: C6 27       LDB    #$27
E909: E7 0A       STB    $A,X
E90B: 86 B4       LDA    #$B4
E90D: A7 88 25    STA    $25,X
E910: BD F0 42    JSR    $F042
E913: 0A 25       DEC    <$25
E915: 27 01       BEQ    $E918
E917: 39          RTS
E918: 86 FF       LDA    #$FF
E91A: A7 88 1B    STA    $1B,X
E91D: 86 08       LDA    #$08
E91F: A7 0D       STA    $D,X
E921: 7E E4 DE    JMP    $E4DE
E924: 86 06       LDA    #$06
E926: A7 84       STA    ,X
E928: A6 88 18    LDA    $18,X
E92B: 26 0A       BNE    $E937
E92D: 34 10       PSHS   X
E92F: 8E D4 52    LDX    #$D452
E932: BD F2 63    JSR    $F263
E935: 35 10       PULS   X
E937: EE 88 15    LDU    $15,X
E93A: A6 88 18    LDA    $18,X
E93D: 26 09       BNE    $E948
E93F: A6 42       LDA    $2,U
E941: 81 03       CMPA   #$03
E943: 26 03       BNE    $E948
E945: 7E EA 05    JMP    $EA05
E948: A6 41       LDA    $1,U
E94A: 48          ASLA
E94B: CE E9 50    LDU    #table_e950
E94E: 6E D6       JMP    [A,U]		 ; [indirect_jump] [nb_entries=12]
table_e950:
	.word	$e990
	.word	$e9d1
	.word	$e9d1
	.word	$e9b0
	.word	$e9dc
	.word	$e9e7
	.word	$e9e7
	.word	$e9f2
	.word	$e968
	.word	$e97c
	.word	$e990
	.word	$e990

E968: A6 04       LDA    $4,X
E96A: 8B 02       ADDA   #$02
E96C: A7 04       STA    $4,X
E96E: BD F0 42    JSR    $F042
E971: A6 04       LDA    $4,X
E973: 8B 02       ADDA   #$02
E975: A7 04       STA    $4,X
E977: BD F0 42    JSR    $F042
E97A: 20 34       BRA    $E9B0
E97C: A6 04       LDA    $4,X
E97E: 8B 02       ADDA   #$02
E980: A7 04       STA    $4,X
E982: BD F0 42    JSR    $F042
E985: A6 04       LDA    $4,X
E987: 8B 02       ADDA   #$02
E989: A7 04       STA    $4,X
E98B: BD F0 42    JSR    $F042
E98E: 20 20       BRA    $E9B0

E990: A6 04       LDA    $4,X
E992: 8A 01       ORA    #$01
E994: A7 04       STA    $4,X
E996: BD F0 42    JSR    $F042
l_e999:
E999: EE 88 15    LDU    $15,X
E99C: A6 41       LDA    $1,U
E99E: 26 31       BNE    $E9D1
E9A0: A6 04       LDA    $4,X
E9A2: 8B 02       ADDA   #$02
E9A4: A7 04       STA    $4,X
E9A6: BD F0 42    JSR    $F042
l_e9a9:
E9A9: EE 88 15    LDU    $15,X
E9AC: A6 41       LDA    $1,U
E9AE: 26 2C       BNE    $E9DC
E9B0: EE 88 15    LDU    $15,X
E9B3: E6 88 18    LDB    $18,X
E9B6: 26 04       BNE    $E9BC
E9B8: C6 01       LDB    #$01
E9BA: 20 0D       BRA    $E9C9
E9BC: A6 C4       LDA    ,U
E9BE: 26 1C       BNE    $E9DC
E9C0: A6 42       LDA    $2,U
E9C2: 81 04       CMPA   #$04
E9C4: 26 03       BNE    $E9C9
E9C6: 7E E8 2D    JMP    $E82D
E9C9: E7 C4       STB    ,U
E9CB: 86 01       LDA    #$01
E9CD: A7 41       STA    $1,U
E9CF: 20 0B       BRA    $E9DC
E9D1: A6 04       LDA    $4,X
E9D3: 8B 02       ADDA   #$02
E9D5: A7 04       STA    $4,X
E9D7: 8D 1E       BSR    $E9F7
E9D9: BD F0 42    JSR    $F042
E9DC: A6 04       LDA    $4,X
E9DE: 8B 02       ADDA   #$02
E9E0: A7 04       STA    $4,X
E9E2: 8D 13       BSR    $E9F7
E9E4: BD F0 42    JSR    $F042
l_e9e7:
E9E7: A6 04       LDA    $4,X
E9E9: 8B 02       ADDA   #$02
E9EB: A7 04       STA    $4,X
E9ED: 8D 08       BSR    $E9F7
E9EF: BD F0 42    JSR    $F042
l_e9f2:
E9F2: 8D 03       BSR    $E9F7
E9F4: 7E EA 25    JMP    $EA25
E9F7: A6 88 18    LDA    $18,X
E9FA: 27 01       BEQ    $E9FD
E9FC: 39          RTS
E9FD: EE 88 15    LDU    $15,X
EA00: 86 01       LDA    #$01
EA02: A7 C4       STA    ,U
EA04: 39          RTS
EA05: A6 04       LDA    $4,X
EA07: 8B 03       ADDA   #$03
EA09: A7 04       STA    $4,X
EA0B: BD F0 42    JSR    $F042
EA0E: A6 04       LDA    $4,X
EA10: 8B 02       ADDA   #$02
EA12: A7 04       STA    $4,X
EA14: EE 88 15    LDU    $15,X
EA17: 86 0B       LDA    #$0B
EA19: A7 41       STA    $1,U
EA1B: 86 01       LDA    #$01
EA1D: A7 C4       STA    ,U
EA1F: BD F0 42    JSR    $F042
EA22: 7E E8 2D    JMP    $E82D
EA25: 86 07       LDA    #$07
EA27: A7 84       STA    ,X
EA29: BD F0 42    JSR    $F042
l_ea2c:
EA2C: BD F0 ED    JSR    $F0ED
EA2F: A6 04       LDA    $4,X
EA31: 81 18       CMPA   #$18
EA33: 23 19       BLS    $EA4E
EA35: A6 C4       LDA    ,U
EA37: 81 19       CMPA   #$19
EA39: 27 13       BEQ    $EA4E
EA3B: E6 88 18    LDB    $18,X
EA3E: C1 08       CMPB   #$08
EA40: 26 04       BNE    $EA46
EA42: D6 29       LDB    <$29
EA44: 26 38       BNE    $EA7E
EA46: 81 60       CMPA   #$60
EA48: 25 34       BCS    $EA7E
EA4A: 81 87       CMPA   #$87
EA4C: 22 30       BHI    $EA7E
EA4E: 1F 30       TFR    U,D
EA50: CB 02       ADDB   #$02
EA52: C4 1F       ANDB   #$1F
EA54: 58          ASLB
EA55: 58          ASLB
EA56: 58          ASLB
EA57: E7 88 1F    STB    $1F,X
EA5A: 86 08       LDA    #$08
EA5C: A7 88 1B    STA    $1B,X
EA5F: CE EA E0    LDU    #$EAE0
EA62: EF 88 10    STU    $10,X
EA65: 20 03       BRA    $EA6A
EA67: BD F0 42    JSR    $F042
EA6A: EE 88 10    LDU    $10,X
EA6D: A6 C0       LDA    ,U+
EA6F: 81 80       CMPA   #$80
EA71: 10 27 FD B8 LBEQ   $E82D
EA75: AB 04       ADDA   $4,X
EA77: A7 04       STA    $4,X
EA79: EF 88 10    STU    $10,X
EA7C: 20 E9       BRA    $EA67
EA7E: A6 0D       LDA    $D,X
EA80: 26 20       BNE    $EAA2
EA82: EC 04       LDD    $4,X
EA84: A3 08       SUBD   $8,X
EA86: ED 04       STD    $4,X
EA88: 6A 88 17    DEC    $17,X
EA8B: A6 88 17    LDA    $17,X
EA8E: 85 02       BITA   #$02
EA90: 26 01       BNE    $EA93
EA92: 39          RTS
EA93: 84 04       ANDA   #$04
EA95: 44          LSRA
EA96: 44          LSRA
EA97: 8B 04       ADDA   #$04
EA99: AB 88 18    ADDA   $18,X
EA9C: A7 0A       STA    $A,X
EA9E: 4F          CLRA
EA9F: A7 0C       STA    $C,X
EAA1: 39          RTS
EAA2: D6 29       LDB    <$29
EAA4: 27 04       BEQ    $EAAA
EAA6: C1 D0       CMPB   #$D0
EAA8: 22 D8       BHI    $EA82
EAAA: 85 08       BITA   #$08
EAAC: 26 08       BNE    $EAB6
EAAE: 86 02       LDA    #$02
EAB0: A7 0C       STA    $C,X
EAB2: 86 0A       LDA    #$0A
EAB4: 20 05       BRA    $EABB
EAB6: 4F          CLRA
EAB7: A7 0C       STA    $C,X
EAB9: 86 09       LDA    #$09
EABB: A7 84       STA    ,X
EABD: A6 88 18    LDA    $18,X
EAC0: 26 09       BNE    $EACB
EAC2: F6 40 41    LDB    $4041
EAC5: 27 04       BEQ    $EACB
EAC7: 86 19       LDA    #$19
EAC9: 20 02       BRA    $EACD
EACB: 8B 07       ADDA   #$07
EACD: A7 0A       STA    $A,X
EACF: 96 29       LDA    <$29
EAD1: 27 05       BEQ    $EAD8
EAD3: CE D1 56    LDU    #$D156
EAD6: 20 03       BRA    $EADB
EAD8: CE D1 11    LDU    #$D111
EADB: EF 88 10    STU    $10,X
EADE: 20 0C       BRA    $EAEC

EAEC: 96 29       LDA    <$29
EAEE: 26 4C       BNE    $EB3C
EAF0: BD F0 42    JSR    $F042
l_eaf3:
EAF3: A6 04       LDA    $4,X
EAF5: D6 31       LDB    <$31
EAF7: C4 0F       ANDB   #$0F
EAF9: C1 03       CMPB   #$03
EAFB: 25 0D       BCS    $EB0A
EAFD: C1 0F       CMPB   #$0F
EAFF: 27 09       BEQ    $EB0A
EB01: 81 1D       CMPA   #$1D
EB03: 24 0E       BCC    $EB13
EB05: C6 20       LDB    #$20
EB07: 7E EA 57    JMP    $EA57
EB0A: 81 3D       CMPA   #$3D
EB0C: 24 05       BCC    $EB13
EB0E: C6 40       LDB    #$40
EB10: 7E EA 57    JMP    $EA57
EB13: 85 10       BITA   #$10
EB15: 27 0A       BEQ    $EB21
EB17: 84 0F       ANDA   #$0F
EB19: 81 0E       CMPA   #$0E
EB1B: 24 17       BCC    $EB34
EB1D: 81 0D       CMPA   #$0D
EB1F: 27 1B       BEQ    $EB3C
EB21: EC 04       LDD    $4,X
EB23: A3 08       SUBD   $8,X
EB25: ED 04       STD    $4,X
EB27: 81 10       CMPA   #$10
EB29: 23 01       BLS    $EB2C
EB2B: 39          RTS
EB2C: 86 20       LDA    #$20
EB2E: A7 88 1F    STA    $1F,X
EB31: 7E E8 2D    JMP    $E82D
EB34: A6 04       LDA    $4,X
EB36: 84 F0       ANDA   #$F0
EB38: 8A 0D       ORA    #$0D
EB3A: A7 04       STA    $4,X
EB3C: EE 88 10    LDU    $10,X
EB3F: A6 42       LDA    $2,U
EB41: A7 88 17    STA    $17,X
EB44: BD F0 42    JSR    $F042
l_eb47:
EB47: 96 29       LDA    <$29
EB49: 26 06       BNE    $EB51
EB4B: A6 04       LDA    $4,X
EB4D: 81 20       CMPA   #$20
EB4F: 23 7B       BLS    $EBCC
EB51: BD F0 47    JSR    $F047
EB54: A6 C4       LDA    ,U
EB56: 81 8C       CMPA   #$8C
EB58: 27 2B       BEQ    $EB85
EB5A: 81 1D       CMPA   #$1D
EB5C: 27 1A       BEQ    $EB78
EB5E: D6 29       LDB    <$29
EB60: 27 6A       BEQ    $EBCC
EB62: A6 41       LDA    $1,U
EB64: 81 1D       CMPA   #$1D
EB66: 27 10       BEQ    $EB78
EB68: 81 20       CMPA   #$20
EB6A: 27 60       BEQ    $EBCC
EB6C: 81 7F       CMPA   #$7F
EB6E: 27 08       BEQ    $EB78
EB70: 81 60       CMPA   #$60
EB72: 25 04       BCS    $EB78
EB74: 81 87       CMPA   #$87
EB76: 25 54       BCS    $EBCC
EB78: A6 84       LDA    ,X
EB7A: 84 01       ANDA   #$01
EB7C: 88 01       EORA   #$01
EB7E: 8A 20       ORA    #$20
EB80: A7 88 1B    STA    $1B,X
EB83: 20 09       BRA    $EB8E
EB85: A6 84       LDA    ,X
EB87: 84 01       ANDA   #$01
EB89: 8A 10       ORA    #$10
EB8B: A7 88 1B    STA    $1B,X
EB8E: A6 04       LDA    $4,X
EB90: 8B 08       ADDA   #$08
EB92: 84 F0       ANDA   #$F0
EB94: A7 88 1F    STA    $1F,X
EB97: A6 84       LDA    ,X
EB99: 88 01       EORA   #$01
EB9B: A7 84       STA    ,X
EB9D: 96 29       LDA    <$29
EB9F: 27 05       BEQ    $EBA6
EBA1: CE D1 69    LDU    #$D169
EBA4: 20 03       BRA    $EBA9
EBA6: CE D1 39    LDU    #$D139
EBA9: EF 88 10    STU    $10,X
EBAC: A6 42       LDA    $2,U
EBAE: A7 88 17    STA    $17,X
EBB1: BD F0 42    JSR    $F042
l_ebb4:
EBB4: BD F1 1E    JSR    $F11E
EBB7: A6 C4       LDA    ,U
EBB9: 81 2F       CMPA   #$2F
EBBB: 27 01       BEQ    $EBBE
EBBD: 39          RTS
EBBE: A6 88 18    LDA    $18,X
EBC1: 27 06       BEQ    $EBC9
EBC3: A6 0D       LDA    $D,X
EBC5: 88 0A       EORA   #$0A
EBC7: A7 0D       STA    $D,X
EBC9: 7E E8 2D    JMP    $E82D
EBCC: BD F1 94    JSR    $F194
EBCF: BD F1 1E    JSR    $F11E
EBD2: A6 C4       LDA    ,U
EBD4: 81 2F       CMPA   #$2F
EBD6: 27 0F       BEQ    $EBE7
EBD8: EC 01       LDD    $1,X
EBDA: 10 83 00 05 CMPD   #$0005
EBDE: 23 A5       BLS    $EB85
EBE0: 10 83 01 B3 CMPD   #$01B3
EBE4: 24 9F       BCC    $EB85
EBE6: 39          RTS
EBE7: 96 29       LDA    <$29
EBE9: 10 26 FC 40 LBNE   $E82D
EBED: 6F 84       CLR    ,X
EBEF: 86 FF       LDA    #$FF
EBF1: A7 88 1B    STA    $1B,X
EBF4: 6F 05       CLR    $5,X
EBF6: A6 88 18    LDA    $18,X
EBF9: A7 0A       STA    $A,X
EBFB: 27 03       BEQ    $EC00
EBFD: 7E E4 DE    JMP    $E4DE
EC00: 10 AE 88 15 LDY    $15,X
EC04: A6 23       LDA    $3,Y
EC06: 34 10       PSHS   X
EC08: 8E DE 09    LDX    #$DE09
EC0B: 48          ASLA
EC0C: AE 86       LDX    A,X
EC0E: EE 25       LDU    $5,Y
EC10: C6 05       LDB    #$05
EC12: A6 80       LDA    ,X+
EC14: A7 C4       STA    ,U
EC16: 33 C8 E0    LEAU   -$20,U
EC19: 5A          DECB
EC1A: 26 F6       BNE    $EC12
EC1C: 33 C8 7F    LEAU   $7F,U
EC1F: C6 03       LDB    #$03
EC21: A6 80       LDA    ,X+
EC23: A7 C4       STA    ,U
EC25: 33 C8 E0    LEAU   -$20,U
EC28: 5A          DECB
EC29: 26 F6       BNE    $EC21
EC2B: 6F 22       CLR    $2,Y
EC2D: EE 25       LDU    $5,Y
EC2F: 33 C9 08 00 LEAU   $0800,U
EC33: 86 00       LDA    #$00
EC35: C6 05       LDB    #$05
EC37: A7 C4       STA    ,U
EC39: 33 C8 E0    LEAU   -$20,U
EC3C: 5A          DECB
EC3D: 26 F8       BNE    $EC37
EC3F: 33 C9 00 81 LEAU   $0081,U
EC43: C6 03       LDB    #$03
EC45: A7 C4       STA    ,U
EC47: 33 C8 E0    LEAU   -$20,U
EC4A: 5A          DECB
EC4B: 26 F8       BNE    $EC45
EC4D: 35 10       PULS   X
EC4F: 7E E4 DE    JMP    $E4DE
EC52: EE 88 12    LDU    $12,X
EC55: A6 41       LDA    $1,U
EC57: 81 02       CMPA   #$02
EC59: 23 1B       BLS    $EC76
EC5B: 20 09       BRA    $EC66
EC5D: EE 88 12    LDU    $12,X
EC60: A6 41       LDA    $1,U
EC62: 81 02       CMPA   #$02
EC64: 22 10       BHI    $EC76
l_ec66:
EC66: 86 0B       LDA    #$0B
EC68: A7 84       STA    ,X
EC6A: 86 02       LDA    #$02
EC6C: A7 0C       STA    $C,X
EC6E: 86 08       LDA    #$08
EC70: A7 0D       STA    $D,X
EC72: 86 00       LDA    #$00
EC74: 20 0C       BRA    $EC82
l_ec76:
EC76: 86 0C       LDA    #$0C
EC78: 6F 0C       CLR    $C,X
EC7A: A7 84       STA    ,X
EC7C: 86 02       LDA    #$02
EC7E: A7 0D       STA    $D,X
EC80: 86 01       LDA    #$01
EC82: 8A 04       ORA    #$04
EC84: A7 88 1B    STA    $1B,X
EC87: A6 04       LDA    $4,X
EC89: A7 88 1F    STA    $1F,X
EC8C: A6 88 2B    LDA    $2B,X
EC8F: 27 0F       BEQ    $ECA0
EC91: A6 88 18    LDA    $18,X
EC94: 81 08       CMPA   #$08
EC96: 27 04       BEQ    $EC9C
EC98: 86 7B       LDA    #$7B
EC9A: 20 09       BRA    $ECA5
EC9C: 86 27       LDA    #$27
EC9E: 20 05       BRA    $ECA5
ECA0: A6 88 18    LDA    $18,X
ECA3: 8B 06       ADDA   #$06
ECA5: A7 0A       STA    $A,X
ECA7: CE D1 46    LDU    #$D146
ECAA: EF 88 10    STU    $10,X
ECAD: A6 42       LDA    $2,U
ECAF: A7 88 17    STA    $17,X
ECB2: A6 88 18    LDA    $18,X
ECB5: 27 1C       BEQ    $ECD3
ECB7: A6 88 2B    LDA    $2B,X
ECBA: 26 17       BNE    $ECD3
ECBC: 96 1E       LDA    <$1E
ECBE: 27 13       BEQ    $ECD3
ECC0: EE 88 12    LDU    $12,X
ECC3: 11 B3 13 DA CMPU   $13DA
ECC7: 26 0A       BNE    $ECD3
ECC9: 34 10       PSHS   X
ECCB: 8E D4 54    LDX    #$D454
ECCE: BD F2 63    JSR    $F263
ECD1: 35 10       PULS   X
ECD3: BD F0 42    JSR    $F042
l_ecd6:
ECD6: BD F1 1E    JSR    $F11E
ECD9: A6 C4       LDA    ,U
ECDB: 81 2F       CMPA   #$2F
ECDD: 27 1F       BEQ    $ECFE
ECDF: BD F0 9A    JSR    $F09A
ECE2: A6 C4       LDA    ,U
ECE4: 81 1A       CMPA   #$1A
ECE6: 27 53       BEQ    $ED3B
ECE8: 81 60       CMPA   #$60
ECEA: 25 04       BCS    $ECF0
ECEC: 81 68       CMPA   #$68
ECEE: 25 4B       BCS    $ED3B
ECF0: 81 1B       CMPA   #$1B
ECF2: 27 47       BEQ    $ED3B
ECF4: 81 68       CMPA   #$68
ECF6: 24 01       BCC    $ECF9
ECF8: 39          RTS
ECF9: 81 70       CMPA   #$70
ECFB: 25 01       BCS    $ECFE
ECFD: 39          RTS
ECFE: A6 88 18    LDA    $18,X
ED01: 27 30       BEQ    $ED33
ED03: B6 13 DD    LDA    $13DD
ED06: A7 88 17    STA    $17,X
ED09: BD F0 42    JSR    $F042
l_ed0c:
ED0C: 6A 88 17    DEC    $17,X
ED0F: 27 01       BEQ    $ED12
ED11: 39          RTS
ED12: A6 88 18    LDA    $18,X
ED15: 27 1C       BEQ    $ED33
ED17: 86 2D       LDA    #$2D
ED19: A7 88 17    STA    $17,X
ED1C: BD F0 42    JSR    $F042
l_ed1f:
ED1F: 6A 88 17    DEC    $17,X
ED22: 27 0F       BEQ    $ED33
ED24: A6 88 17    LDA    $17,X
ED27: 85 04       BITA   #$04
ED29: 26 05       BNE    $ED30
ED2B: 86 0F       LDA    #$0F
ED2D: A7 0B       STA    $B,X
ED2F: 39          RTS
ED30: 6F 0B       CLR    $B,X
ED32: 39          RTS
ED33: 6F 0B       CLR    $B,X
ED35: 6F 88 2B    CLR    $2B,X
ED38: 7E E4 DE    JMP    $E4DE
ED3B: 6F 88 2B    CLR    $2B,X
ED3E: A6 84       LDA    ,X
ED40: 84 01       ANDA   #$01
ED42: AB 88 18    ADDA   $18,X
ED45: A7 0A       STA    $A,X
ED47: CE D0 E6    LDU    #$D0E6
ED4A: EF 88 10    STU    $10,X
ED4D: 7E E7 E3    JMP    $E7E3
ED50: 86 0D       LDA    #$0D
ED52: A7 84       STA    ,X
ED54: BD F0 42    JSR    $F042
ED57: 39          RTS
l_ed58:
ED58: 86 11       LDA    #$11
ED5A: A7 84       STA    ,X
ED5C: 6F 0B       CLR    $B,X
ED5E: BD F0 42    JSR    $F042
l_ed61:
ED61: EE 88 1C    LDU    $1C,X
ED64: A6 C4       LDA    ,U
ED66: 81 05       CMPA   #$05
ED68: 24 19       BCC    $ED83
ED6A: 81 04       CMPA   #$04
ED6C: 27 0A       BEQ    $ED78
ED6E: EC 02       LDD    $2,X
ED70: A3 45       SUBD   $5,U
ED72: 24 0C       BCC    $ED80
ED74: 6F 01       CLR    $1,X
ED76: 20 08       BRA    $ED80
ED78: EC 02       LDD    $2,X
ED7A: E3 45       ADDD   $5,U
ED7C: 24 02       BCC    $ED80
ED7E: 6C 01       INC    $1,X
ED80: ED 02       STD    $2,X
ED82: 39          RTS
ED83: 86 12       LDA    #$12
ED85: A7 84       STA    ,X
ED87: EE 88 1C    LDU    $1C,X
ED8A: 6C 4B       INC    $B,U
ED8C: 86 03       LDA    #$03
ED8E: B7 13 D9    STA    $13D9
ED91: BD F0 42    JSR    $F042
l_ed94:
ED94: 7C 13 D9    INC    $13D9
ED97: B6 13 D9    LDA    $13D9
ED9A: A7 88 17    STA    $17,X
ED9D: CC 00 DC    LDD    #$00DC
EDA0: ED 01       STD    $1,X
EDA2: 6F 04       CLR    $4,X
EDA4: 7F 13 B6    CLR    $13B6
EDA7: BD F0 42    JSR    $F042
l_edaa:
EDAA: B6 13 B6    LDA    $13B6
EDAD: 85 20       BITA   #$20
EDAF: 27 01       BEQ    $EDB2
EDB1: 39          RTS
EDB2: 7F 13 B6    CLR    $13B6
EDB5: 6A 88 17    DEC    $17,X
EDB8: 27 01       BEQ    $EDBB
EDBA: 39          RTS
EDBB: 6F 88 1B    CLR    $1B,X
EDBE: 7E E8 2D    JMP    $E82D
EDC1: 86 1E       LDA    #$1E
EDC3: A7 88 17    STA    $17,X
EDC6: CE 14 90    LDU    #$1490
EDC9: EC 88 19    LDD    $19,X
EDCC: 83 11 1C    SUBD   #$111C
EDCF: FD 13 D1    STD    $13D1
EDD2: 58          ASLB
EDD3: 49          ROLA
EDD4: 33 CB       LEAU   D,U
EDD6: EF 88 27    STU    $27,X
EDD9: A6 88 18    LDA    $18,X
EDDC: 81 08       CMPA   #$08
EDDE: 26 0C       BNE    $EDEC
EDE0: 34 10       PSHS   X
EDE2: 8E D4 74    LDX    #$D474
EDE5: BD F2 63    JSR    $F263
EDE8: 86 4F       LDA    #$4F
EDEA: 20 0A       BRA    $EDF6
EDEC: 34 10       PSHS   X
EDEE: 8E D4 66    LDX    #$D466
EDF1: BD F2 63    JSR    $F263
EDF4: 86 2A       LDA    #$2A
EDF6: 35 10       PULS   X
EDF8: 34 02       PSHS   A
EDFA: CE 11 52    LDU    #$1152
EDFD: FC 13 D1    LDD    $13D1
EE00: 33 CB       LEAU   D,U
EE02: 35 02       PULS   A
EE04: A7 C4       STA    ,U
EE06: 6F 41       CLR    $1,U
EE08: 6F C9 01 00 CLR    $0100,U
EE0C: EE 88 27    LDU    $27,X
EE0F: A6 04       LDA    $4,X
EE11: A7 42       STA    $2,U
EE13: EC 01       LDD    $1,X
EE15: 10 83 00 80 CMPD   #$0080
EE19: 22 05       BHI    $EE20
EE1B: C3 00 10    ADDD   #$0010
EE1E: 20 03       BRA    $EE23
EE20: 83 00 10    SUBD   #$0010
EE23: ED C4       STD    ,U
EE25: 7C 14 54    INC    $1454
EE28: 7C 40 52    INC    $4052
EE2B: BD F0 42    JSR    $F042
EE2E: 6A 88 17    DEC    $17,X
EE31: 27 01       BEQ    $EE34
EE33: 39          RTS
EE34: EC 88 19    LDD    $19,X
EE37: C3 00 36    ADDD   #$0036
EE3A: 1F 03       TFR    D,U
EE3C: 6F C4       CLR    ,U
EE3E: 6F C9 00 80 CLR    $0080,U
EE42: 7A 14 54    DEC    $1454
EE45: 86 B4       LDA    #$B4
EE47: A7 88 17    STA    $17,X
EE4A: BD F0 42    JSR    $F042
EE4D: 6A 88 17    DEC    $17,X
EE50: 27 01       BEQ    $EE53
EE52: 39          RTS
EE53: 7E E8 2D    JMP    $E82D
EE56: 86 17       LDA    #$17
EE58: A7 84       STA    ,X
EE5A: A6 88 18    LDA    $18,X
EE5D: 81 38       CMPA   #$38
EE5F: 26 0A       BNE    $EE6B
EE61: 86 3C       LDA    #$3C
EE63: A7 88 17    STA    $17,X
EE66: 6F 84       CLR    ,X
EE68: 7E E4 DE    JMP    $E4DE
EE6B: CE 14 90    LDU    #$1490
EE6E: EC 88 19    LDD    $19,X
EE71: 83 11 1C    SUBD   #$111C
EE74: FD 13 D1    STD    $13D1
EE77: 58          ASLB
EE78: 49          ROLA
EE79: 33 CB       LEAU   D,U
EE7B: EF 88 27    STU    $27,X
EE7E: A6 88 18    LDA    $18,X
EE81: 81 08       CMPA   #$08
EE83: 26 0B       BNE    $EE90
EE85: CC C4 5A    LDD    #$C45A
EE88: ED 88 21    STD    $21,X
EE8B: 6F 84       CLR    ,X
EE8D: 7E E4 DE    JMP    $E4DE
EE90: 34 10       PSHS   X
EE92: 8E D4 66    LDX    #$D466
EE95: BD F2 63    JSR    $F263
EE98: 35 10       PULS   X
EE9A: 86 7B       LDA    #$7B
EE9C: A7 0A       STA    $A,X
EE9E: 86 2A       LDA    #$2A
EEA0: 34 02       PSHS   A
EEA2: CE 11 52    LDU    #$1152
EEA5: FC 13 D1    LDD    $13D1
EEA8: 33 CB       LEAU   D,U
EEAA: 35 02       PULS   A
EEAC: A7 C4       STA    ,U
EEAE: 6F 41       CLR    $1,U
EEB0: 6F C9 01 00 CLR    $0100,U
EEB4: EE 88 27    LDU    $27,X
EEB7: A6 04       LDA    $4,X
EEB9: A7 42       STA    $2,U
EEBB: EC 01       LDD    $1,X
EEBD: 10 83 00 80 CMPD   #$0080
EEC1: 22 05       BHI    $EEC8
EEC3: C3 00 10    ADDD   #$0010
EEC6: 20 03       BRA    $EECB
EEC8: 83 00 10    SUBD   #$0010
EECB: ED C4       STD    ,U
EECD: 7C 14 54    INC    $1454
EED0: 7C 40 52    INC    $4052
EED3: 86 1E       LDA    #$1E
EED5: A7 88 17    STA    $17,X
EED8: BD F0 42    JSR    $F042
EEDB: 6A 88 17    DEC    $17,X
EEDE: 27 01       BEQ    $EEE1
EEE0: 39          RTS
EEE1: EC 88 19    LDD    $19,X
EEE4: C3 00 36    ADDD   #$0036
EEE7: 1F 03       TFR    D,U
EEE9: 6F C4       CLR    ,U
EEEB: 6F C9 00 80 CLR    $0080,U
EEEF: 7A 14 54    DEC    $1454
EEF2: 86 B4       LDA    #$B4
EEF4: A7 88 17    STA    $17,X
EEF7: BD F0 42    JSR    $F042
EEFA: 6A 88 17    DEC    $17,X
EEFD: 27 01       BEQ    $EF00
EEFF: 39          RTS
EF00: 7E E4 DE    JMP    $E4DE
EF03: 96 00       LDA    <$00
EF05: 81 02       CMPA   #$02
EF07: 23 01       BLS    $EF0A
EF09: 39          RTS
EF0A: 96 3D       LDA    <$3D
EF0C: 85 01       BITA   #$01
EF0E: 26 01       BNE    $EF11
EF10: 39          RTS
EF11: 96 04       LDA    <$04
EF13: 44          LSRA
EF14: 44          LSRA
EF15: 44          LSRA
EF16: 4A          DECA
EF17: 97 14       STA    <$14
EF19: 96 0C       LDA    <$0C
EF1B: 85 02       BITA   #$02
EF1D: 27 56       BEQ    $EF75
EF1F: CE 21 98    LDU    #$2198
EF22: A6 47       LDA    $7,U
EF24: 81 FF       CMPA   #$FF
EF26: 27 0D       BEQ    $EF35
EF28: 33 58       LEAU   -$8,U
EF2A: 20 F6       BRA    $EF22
EF2C: 33 58       LEAU   -$8,U
EF2E: 11 83 20 D8 CMPU   #$20D8
EF32: 26 01       BNE    $EF35
EF34: 39          RTS
EF35: A6 43       LDA    $3,U
EF37: 84 1F       ANDA   #$1F
EF39: 91 14       CMPA   <$14
EF3B: 26 EF       BNE    $EF2C
EF3D: FF 13 DA    STU    $13DA
EF40: DC 01       LDD    <$01
EF42: C3 00 0B    ADDD   #$000B
EF45: C4 F8       ANDB   #$F8
EF47: 8D 74       BSR    $EFBD
EF49: FD 13 CA    STD    $13CA
EF4C: 4F          CLRA
EF4D: C6 FF       LDB    #$FF
EF4F: F0 13 89    SUBB   scroll_value_1389
EF52: C3 00 DF    ADDD   #$00DF
EF55: C4 F8       ANDB   #$F8
EF57: 8D 64       BSR    $EFBD
EF59: C3 00 1F    ADDD   #$001F
EF5C: FD 13 C8    STD    $13C8
EF5F: EC 42       LDD    $2,U
EF61: 10 B3 13 C8 CMPD   $13C8
EF65: 25 C5       BCS    $EF2C
EF67: 10 B3 13 CA CMPD   $13CA
EF6B: 22 BF       BHI    $EF2C
EF6D: 86 01       LDA    #$01
EF6F: A7 C4       STA    ,U
EF71: A7 88 1E    STA    $1E,X
EF74: 39          RTS
EF75: CE 20 D8    LDU    #$20D8
EF78: 33 48       LEAU   $8,U
EF7A: A6 43       LDA    $3,U
EF7C: 84 1F       ANDA   #$1F
EF7E: 91 14       CMPA   <$14
EF80: 27 07       BEQ    $EF89
EF82: A6 47       LDA    $7,U
EF84: 81 FF       CMPA   #$FF
EF86: 26 F0       BNE    $EF78
EF88: 39          RTS
EF89: FF 13 DA    STU    $13DA
EF8C: DC 01       LDD    <$01
EF8E: 83 00 05    SUBD   #$0005
EF91: C4 F8       ANDB   #$F8
EF93: 8D 28       BSR    $EFBD
EF95: FD 13 C8    STD    $13C8
EF98: 4F          CLRA
EF99: C6 FF       LDB    #$FF
EF9B: F0 13 89    SUBB   scroll_value_1389
EF9E: C4 F8       ANDB   #$F8
EFA0: 8D 1B       BSR    $EFBD
EFA2: C3 00 1F    ADDD   #$001F
EFA5: FD 13 CA    STD    $13CA
EFA8: EC 42       LDD    $2,U
EFAA: 10 B3 13 C8 CMPD   $13C8
EFAE: 25 D2       BCS    $EF82
EFB0: 10 B3 13 CA CMPD   $13CA
EFB4: 22 CC       BHI    $EF82
EFB6: 86 01       LDA    #$01
EFB8: A7 C4       STA    ,U
EFBA: 97 1E       STA    <$1E
EFBC: 39          RTS
EFBD: 85 01       BITA   #$01
EFBF: 26 05       BNE    $EFC6
EFC1: 86 04       LDA    #$04
EFC3: 3D          MUL
EFC4: 20 05       BRA    $EFCB
EFC6: 86 04       LDA    #$04
EFC8: 3D          MUL
EFC9: 8B 04       ADDA   #$04
EFCB: FD 13 C6    STD    $13C6
EFCE: CC 07 60    LDD    #$0760
EFD1: B3 13 C6    SUBD   $13C6
EFD4: 39          RTS
EFD5: BD F0 47    JSR    $F047
EFD8: A6 C4       LDA    ,U
EFDA: 81 89       CMPA   #$89
EFDC: 27 05       BEQ    $EFE3
EFDE: 81 88       CMPA   #$88
EFE0: 27 01       BEQ    $EFE3
EFE2: 39          RTS
EFE3: 33 5F       LEAU   -$1,U
EFE5: EF 88 12    STU    $12,X
EFE8: CE 20 E0    LDU    #$20E0
EFEB: EC 42       LDD    $2,U
EFED: 10 A3 88 12 CMPD   $12,X
EFF1: 27 0B       BEQ    $EFFE
EFF3: A6 47       LDA    $7,U
EFF5: 81 FF       CMPA   #$FF
EFF7: 26 01       BNE    $EFFA
EFF9: 39          RTS
EFFA: 33 48       LEAU   $8,U
EFFC: 20 ED       BRA    $EFEB
EFFE: A6 C4       LDA    ,U
F000: 81 01       CMPA   #$01
F002: 26 01       BNE    $F005
F004: 39          RTS
F005: 86 02       LDA    #$02
F007: A7 C4       STA    ,U
F009: A7 88 1E    STA    $1E,X
F00C: 39          RTS
F00D: B6 14 46    LDA    $1446
F010: 26 01       BNE    $F013
F012: 39          RTS
F013: CE 20 40    LDU    #$2040
F016: A6 C4       LDA    ,U
F018: 26 1D       BNE    $F037
F01A: 96 04       LDA    <$04
F01C: A1 47       CMPA   $7,U
F01E: 26 17       BNE    $F037
F020: DC 01       LDD    <$01
F022: A3 45       SUBD   $5,U
F024: C3 00 04    ADDD   #$0004
F027: 10 83 00 08 CMPD   #$0008
F02B: 22 0A       BHI    $F037
F02D: 86 01       LDA    #$01
F02F: A7 C4       STA    ,U
F031: B7 40 48    STA    $4048
F034: DF 27       STU    <$27
F036: 39          RTS
F037: A6 48       LDA    $8,U
F039: 81 FF       CMPA   #$FF
F03B: 26 01       BNE    $F03E
F03D: 39          RTS
F03E: 33 49       LEAU   $9,U
F040: 20 D4       BRA    $F016

save_context_f042:
F042: 35 06       PULS   D
F044: ED 0E       STD    $E,X
F046: 39          RTS
F047: A6 84       LDA    ,X
F049: 27 07       BEQ    $F052
F04B: 81 10       CMPA   #$10
F04D: 25 01       BCS    $F050
F04F: 39          RTS
F050: 20 08       BRA    $F05A
F052: A6 0C       LDA    $C,X
F054: 85 02       BITA   #$02
F056: 26 12       BNE    $F06A
F058: 20 0C       BRA    $F066
F05A: 81 01       CMPA   #$01
F05C: 27 08       BEQ    $F066
F05E: 81 02       CMPA   #$02
F060: 27 08       BEQ    $F06A
F062: 85 01       BITA   #$01
F064: 27 04       BEQ    $F06A
F066: EC 01       LDD    $1,X
F068: 20 05       BRA    $F06F
F06A: EC 01       LDD    $1,X
F06C: C3 00 0F    ADDD   #$000F
F06F: C4 F8       ANDB   #$F8
F071: 85 01       BITA   #$01
F073: 26 05       BNE    $F07A
F075: 86 04       LDA    #$04
F077: 3D          MUL
F078: 20 06       BRA    $F080
F07A: 86 04       LDA    #$04
F07C: 3D          MUL
F07D: C3 04 00    ADDD   #$0400
F080: FD 13 C4    STD    $13C4
F083: CC 07 60    LDD    #$0760
F086: B3 13 C4    SUBD   $13C4
F089: FD 13 C4    STD    $13C4
F08C: A6 04       LDA    $4,X
F08E: 44          LSRA
F08F: 44          LSRA
F090: 44          LSRA
F091: FE 13 C4    LDU    $13C4
F094: 33 C6       LEAU   A,U
F096: FF 13 C4    STU    $13C4
F099: 39          RTS
F09A: A6 84       LDA    ,X
F09C: 81 05       CMPA   #$05
F09E: 27 06       BEQ    $F0A6
F0A0: 85 01       BITA   #$01
F0A2: 26 09       BNE    $F0AD
F0A4: 20 0E       BRA    $F0B4
F0A6: EC 01       LDD    $1,X
F0A8: C3 00 08    ADDD   #$0008
F0AB: 20 0C       BRA    $F0B9
F0AD: EC 01       LDD    $1,X
F0AF: C3 00 0C    ADDD   #$000C
F0B2: 20 05       BRA    $F0B9
F0B4: EC 01       LDD    $1,X
F0B6: C3 00 03    ADDD   #$0003
F0B9: C4 F8       ANDB   #$F8
F0BB: 85 01       BITA   #$01
F0BD: 26 05       BNE    $F0C4
F0BF: 86 04       LDA    #$04
F0C1: 3D          MUL
F0C2: 20 06       BRA    $F0CA
F0C4: 86 04       LDA    #$04
F0C6: 3D          MUL
F0C7: C3 04 00    ADDD   #$0400
F0CA: FD 13 C0    STD    $13C0
F0CD: CC 07 60    LDD    #$0760
F0D0: B3 13 C0    SUBD   $13C0
F0D3: FD 13 C0    STD    $13C0
F0D6: A6 04       LDA    $4,X
F0D8: E6 84       LDB    ,X
F0DA: C1 04       CMPB   #$04
F0DC: 26 01       BNE    $F0DF
F0DE: 4A          DECA
F0DF: 44          LSRA
F0E0: 44          LSRA
F0E1: 44          LSRA
F0E2: 8B 02       ADDA   #$02
F0E4: FE 13 C0    LDU    $13C0
F0E7: 33 C6       LEAU   A,U
F0E9: FF 13 C0    STU    $13C0
F0EC: 39          RTS
F0ED: EC 01       LDD    $1,X
F0EF: C3 00 08    ADDD   #$0008
F0F2: C4 F8       ANDB   #$F8
F0F4: 85 01       BITA   #$01
F0F6: 26 05       BNE    $F0FD
F0F8: 86 04       LDA    #$04
F0FA: 3D          MUL
F0FB: 20 05       BRA    $F102
F0FD: 86 04       LDA    #$04
F0FF: 3D          MUL
F100: 8B 04       ADDA   #$04
F102: FD 13 C2    STD    $13C2
F105: CC 07 60    LDD    #$0760
F108: B3 13 C2    SUBD   $13C2
F10B: FD 13 C2    STD    $13C2
F10E: A6 04       LDA    $4,X
F110: 80 05       SUBA   #$05
F112: 44          LSRA
F113: 44          LSRA
F114: 44          LSRA
F115: FE 13 C2    LDU    $13C2
F118: 33 C6       LEAU   A,U
F11A: FF 13 C2    STU    $13C2
F11D: 39          RTS
F11E: EE 88 10    LDU    $10,X
F121: A6 84       LDA    ,X
F123: 85 01       BITA   #$01
F125: 27 2B       BEQ    $F152
F127: A6 02       LDA    $2,X
F129: A0 C0       SUBA   ,U+
F12B: 24 02       BCC    $F12F
F12D: 6F 01       CLR    $1,X
F12F: A7 02       STA    $2,X
F131: A6 88 18    LDA    $18,X
F134: 26 47       BNE    $F17D
F136: EC 01       LDD    $1,X
F138: 10 83 00 69 CMPD   #$0069
F13C: 23 0D       BLS    $F14B
F13E: 10 83 01 51 CMPD   #$0151
F142: 24 39       BCC    $F17D
F144: B6 13 89    LDA    scroll_value_1389
F147: AB 5F       ADDA   -$1,U
F149: 24 02       BCC    $F14D
F14B: 86 FF       LDA    #$FF
F14D: B7 13 89    STA    scroll_value_1389
F150: 20 2B       BRA    $F17D
F152: A6 02       LDA    $2,X
F154: AB C0       ADDA   ,U+
F156: 24 02       BCC    $F15A
F158: 6C 01       INC    $1,X
F15A: A7 02       STA    $2,X
F15C: A6 88 18    LDA    $18,X
F15F: 26 1C       BNE    $F17D
F161: EC 01       LDD    $1,X
F163: 10 83 00 69 CMPD   #$0069
F167: 23 14       BLS    $F17D
F169: 10 83 01 51 CMPD   #$0151
F16D: 25 04       BCS    $F173
F16F: 86 18       LDA    #$18
F171: 20 05       BRA    $F178
F173: B6 13 89    LDA    scroll_value_1389
F176: A0 5F       SUBA   -$1,U
F178: B7 13 89    STA    scroll_value_1389
F17B: 20 00       BRA    $F17D
F17D: A6 04       LDA    $4,X
F17F: AB C0       ADDA   ,U+
F181: A7 04       STA    $4,X
F183: 6A 88 17    DEC    $17,X
F186: 27 01       BEQ    $F189
F188: 39          RTS
F189: A6 43       LDA    $3,U
F18B: A7 88 17    STA    $17,X
F18E: 33 41       LEAU   $1,U
F190: EF 88 10    STU    $10,X
F193: 39          RTS
F194: FE 13 C4    LDU    $13C4
F197: A6 0C       LDA    $C,X
F199: 85 02       BITA   #$02
F19B: 26 04       BNE    $F1A1
F19D: C6 20       LDB    #$20
F19F: 20 02       BRA    $F1A3
F1A1: C6 E0       LDB    #$E0
F1A3: F7 13 D0    STB    $13D0
F1A6: A6 84       LDA    ,X
F1A8: 81 02       CMPA   #$02
F1AA: 22 02       BHI    $F1AE
F1AC: 33 5F       LEAU   -$1,U
F1AE: C6 03       LDB    #$03
F1B0: 10 8E 20 E0 LDY    #$20E0
F1B4: 11 A3 22    CMPU   $2,Y
F1B7: 27 15       BEQ    $F1CE
F1B9: A6 27       LDA    $7,Y
F1BB: 81 FF       CMPA   #$FF
F1BD: 27 04       BEQ    $F1C3
F1BF: 31 28       LEAY   $8,Y
F1C1: 20 F1       BRA    $F1B4
F1C3: 5A          DECB
F1C4: 26 01       BNE    $F1C7
F1C6: 39          RTS
F1C7: B6 13 D0    LDA    $13D0
F1CA: 33 C6       LEAU   A,U
F1CC: 20 E2       BRA    $F1B0
F1CE: 10 AF 88 12 STY    $12,X
F1D2: 39          RTS
F1D3: A6 88 18    LDA    $18,X
F1D6: 27 01       BEQ    $F1D9
F1D8: 39          RTS
F1D9: 96 31       LDA    <$31
F1DB: 84 0F       ANDA   #$0F
F1DD: 81 0B       CMPA   #$0B
F1DF: 24 01       BCC    $F1E2
F1E1: 39          RTS
F1E2: 81 0E       CMPA   #$0E
F1E4: 23 01       BLS    $F1E7
F1E6: 39          RTS
F1E7: 10 8E 21 C0 LDY    #$21C0
F1EB: A6 A4       LDA    ,Y
F1ED: 26 11       BNE    $F200
F1EF: 11 A3 21    CMPU   $1,Y
F1F2: 27 30       BEQ    $F224
F1F4: 34 40       PSHS   U
F1F6: 33 C8 E0    LEAU   -$20,U
F1F9: 11 A3 21    CMPU   $1,Y
F1FC: 27 2D       BEQ    $F22B
F1FE: 35 40       PULS   U
F200: 31 A8 10    LEAY   $10,Y
F203: 10 8C 21 E0 CMPY   #$21E0
F207: 25 E2       BCS    $F1EB
F209: 10 8E 21 C0 LDY    #$21C0
F20D: A6 24       LDA    $4,Y
F20F: 81 03       CMPA   #$03
F211: 27 0C       BEQ    $F21F
F213: 31 A8 10    LEAY   $10,Y
F216: A6 24       LDA    $4,Y
F218: 81 03       CMPA   #$03
F21A: 27 03       BEQ    $F21F
F21C: 6F 24       CLR    $4,Y
F21E: 39          RTS
F21F: 6C A4       INC    ,Y
F221: 6F 24       CLR    $4,Y
F223: 39          RTS
F224: A6 24       LDA    $4,Y
F226: 8A 01       ORA    #$01
F228: A7 24       STA    $4,Y
F22A: 39          RTS
F22B: 35 40       PULS   U
F22D: A6 24       LDA    $4,Y
F22F: 8A 02       ORA    #$02
F231: A7 24       STA    $4,Y
F233: 39          RTS
F234: B3 13 CC    SUBD   $13CC
F237: B6 13 93    LDA    $1393
F23A: 27 05       BEQ    $F241
F23C: C0 E1       SUBB   #$E1
F23E: 50          NEGB
F23F: 20 02       BRA    $F243
F241: CB 11       ADDB   #$11
F243: E7 C9 00 80 STB    $0080,U
F247: F6 13 E3    LDB    $13E3
F24A: B6 13 93    LDA    $1393
F24D: 27 08       BEQ    $F257
F24F: 4F          CLRA
F250: 83 01 29    SUBD   #$0129
F253: 43          COMA
F254: 53          COMB
F255: 20 03       BRA    $F25A
F257: C3 00 38    ADDD   #$0038
F25A: E7 C9 00 81 STB    $0081,U
F25E: A7 C9 01 01 STA    $0101,U
F262: 39          RTS
F263: B6 14 02    LDA    $1402
F266: 81 70       CMPA   #$70
F268: 24 01       BCC    $F26B
F26A: 39          RTS
F26B: 81 80       CMPA   #$80
F26D: 25 01       BCS    $F270
F26F: 39          RTS
F270: 86 01       LDA    #$01
F272: B7 14 4D    STA    $144D
F275: EC 84       LDD    ,X
F277: DD 34       STD    <$34
F279: 8E 20 39    LDX    #$2039
F27C: 96 35       LDA    <$35
F27E: AB 82       ADDA   ,-X
F280: 19          DAA
F281: A7 84       STA    ,X
F283: 96 34       LDA    <$34
F285: A9 82       ADCA   ,-X
F287: 19          DAA
F288: A7 84       STA    ,X
F28A: A6 82       LDA    ,-X
F28C: 89 00       ADCA   #$00
F28E: 19          DAA
F28F: A7 84       STA    ,X
F291: CE 13 85    LDU    #$1385
F294: EC 84       LDD    ,X
F296: A3 C4       SUBD   ,U
F298: 22 08       BHI    $F2A2
F29A: 25 59       BCS    $F2F5
F29C: A6 02       LDA    $2,X
F29E: A0 42       SUBA   $2,U
F2A0: 23 53       BLS    $F2F5
F2A2: A6 84       LDA    ,X
F2A4: A7 C0       STA    ,U+
F2A6: EC 01       LDD    $1,X
F2A8: ED C4       STD    ,U
F2AA: 34 50       PSHS   U,X
F2AC: 8E 13 85    LDX    #$1385
F2AF: CE 07 F4    LDU    #$07F4
F2B2: C6 03       LDB    #$03
F2B4: A6 84       LDA    ,X
F2B6: 44          LSRA
F2B7: 44          LSRA
F2B8: 44          LSRA
F2B9: 44          LSRA
F2BA: 26 1E       BNE    $F2DA
F2BC: 86 20       LDA    #$20
F2BE: A7 C2       STA    ,-U
F2C0: A6 80       LDA    ,X+
F2C2: C1 01       CMPB   #$01
F2C4: 27 18       BEQ    $F2DE
F2C6: 84 0F       ANDA   #$0F
F2C8: 26 16       BNE    $F2E0
F2CA: 86 20       LDA    #$20
F2CC: A7 C2       STA    ,-U
F2CE: 5A          DECB
F2CF: 26 01       BNE    $F2D2
F2D1: 39          RTS
F2D2: 20 E0       BRA    $F2B4
F2D4: A6 84       LDA    ,X
F2D6: 44          LSRA
F2D7: 44          LSRA
F2D8: 44          LSRA
F2D9: 44          LSRA
F2DA: A7 C2       STA    ,-U
F2DC: A6 80       LDA    ,X+
F2DE: 84 0F       ANDA   #$0F
F2E0: A7 C2       STA    ,-U
F2E2: 5A          DECB
F2E3: 27 02       BEQ    $F2E7
F2E5: 20 ED       BRA    $F2D4
F2E7: B6 07 F0    LDA    $07F0
F2EA: B7 07 E0    STA    $07E0
F2ED: B6 07 F1    LDA    $07F1
F2F0: B7 07 E1    STA    $07E1
F2F3: 35 50       PULS   X,U
F2F5: 96 39       LDA    <$39
F2F7: 81 FF       CMPA   #$FF
F2F9: 26 01       BNE    $F2FC
F2FB: 39          RTS
F2FC: CE 20 3A    LDU    #$203A
F2FF: EC 81       LDD    ,X++
F301: A3 C1       SUBD   ,U++
F303: 22 0A       BHI    $F30F
F305: 24 01       BCC    $F308
F307: 39          RTS
F308: A6 84       LDA    ,X
F30A: A0 C4       SUBA   ,U
F30C: 24 01       BCC    $F30F
F30E: 39          RTS
F30F: 8E D4 03    LDX    #$D403
F312: F6 13 65    LDB    $1365
F315: 58          ASLB
F316: AE 85       LDX    B,X
F318: D6 39       LDB    <$39
F31A: A6 85       LDA    B,X
F31C: 26 0B       BNE    $F329
F31E: 0C 30       INC    <$30
F320: 86 FF       LDA    #$FF
F322: 97 39       STA    <$39
F324: B7 40 44    STA    $4044
F327: 20 1D       BRA    $F346
F329: 81 FF       CMPA   #$FF
F32B: 26 04       BNE    $F331
F32D: 0A 39       DEC    <$39
F32F: A6 03       LDA    $3,X
F331: B7 40 44    STA    $4044
F334: 0C 39       INC    <$39
F336: 0C 30       INC    <$30
F338: 9B 3B       ADDA   <$3B
F33A: 19          DAA
F33B: 97 3B       STA    <$3B
F33D: 24 07       BCC    $F346
F33F: 86 01       LDA    #$01
F341: 9B 3A       ADDA   <$3A
F343: 19          DAA
F344: 97 3A       STA    <$3A
F346: C1 01       CMPB   #$01
F348: 27 05       BEQ    $F34F
F34A: 8E 10 12    LDX    #$1012
F34D: 20 03       BRA    $F352
F34F: 8E 10 10    LDX    #$1010
F352: C6 02       LDB    #$02
F354: BD E3 27    JSR    $E327
F357: BD D0 AB    JSR    $D0AB
F35A: 39          RTS
F35B: 8E 00 00    LDX    #$0000
F35E: CC 20 20    LDD    #$2020
F361: ED 81       STD    ,X++
F363: 8C 07 80    CMPX   #$0780
F366: 26 F9       BNE    $F361
F368: 39          RTS
F369: 8E 08 00    LDX    #$0800
F36C: 1F 89       TFR    A,B
F36E: ED 81       STD    ,X++
F370: 8C 0F 80    CMPX   #$0F80
F373: 26 F9       BNE    $F36E
F375: 39          RTS
F376: 8E 07 80    LDX    #$0780
F379: 86 20       LDA    #$20
F37B: A7 80       STA    ,X+
F37D: 8C 08 00    CMPX   #$0800
F380: 26 F9       BNE    $F37B
F382: 39          RTS
F383: FC 11 1A    LDD    $111A
F386: FD 13 D1    STD    $13D1
F389: FC 11 9A    LDD    $119A
F38C: FD 13 D3    STD    $13D3
F38F: FC 12 1A    LDD    $121A
F392: FD 13 D5    STD    $13D5
F395: 8D 13       BSR    $F3AA
F397: FC 13 D1    LDD    $13D1
F39A: FD 11 1A    STD    $111A
F39D: FC 13 D3    LDD    $13D3
F3A0: FD 11 9A    STD    $119A
F3A3: FC 13 D5    LDD    $13D5
F3A6: FD 12 1A    STD    $121A
F3A9: 39          RTS
F3AA: 8E 11 00    LDX    #$1100
F3AD: 6F 80       CLR    ,X+
F3AF: 8C 12 80    CMPX   #$1280
F3B2: 26 F9       BNE    $F3AD
F3B4: 39          RTS
F3B5: A6 80       LDA    ,X+
F3B7: 81 2F       CMPA   #$2F
F3B9: 26 01       BNE    $F3BC
F3BB: 39          RTS
F3BC: A7 C4       STA    ,U
F3BE: 33 C8 E0    LEAU   -$20,U
F3C1: 20 F2       BRA    $F3B5
F3C3: A6 80       LDA    ,X+
F3C5: 81 2F       CMPA   #$2F
F3C7: 26 01       BNE    $F3CA
F3C9: 39          RTS
F3CA: A7 C4       STA    ,U
F3CC: 33 5F       LEAU   -$1,U
F3CE: 20 F3       BRA    $F3C3
F3D0: A6 80       LDA    ,X+
F3D2: 81 2F       CMPA   #$2F
F3D4: 26 01       BNE    $F3D7
F3D6: 39          RTS
F3D7: A7 C4       STA    ,U
F3D9: E7 C9 08 00 STB    $0800,U
F3DD: 33 C8 E0    LEAU   -$20,U
F3E0: 20 EE       BRA    $F3D0
F3E2: 8E F4 5F    LDX    #$F45F
F3E5: C6 09       LDB    #$09
F3E7: BD F3 D0    JSR    $F3D0
F3EA: 39          RTS
F3EB: 34 10       PSHS   X
F3ED: 8E F4 79    LDX    #$F479
F3F0: C6 09       LDB    #$09
F3F2: BD F3 D0    JSR    $F3D0
F3F5: 35 10       PULS   X
F3F7: 20 43       BRA    $F43C
F3F9: AB 81       ADDA   ,X++
F3FB: B7 13 88    STA    $1388
F3FE: 34 10       PSHS   X
F400: 8E F4 93    LDX    #$F493
F403: C6 09       LDB    #$09
F405: BD F3 D0    JSR    $F3D0
F408: 35 10       PULS   X
F40A: B6 13 88    LDA    $1388
F40D: 80 A0       SUBA   #$A0
F40F: 25 08       BCS    $F419
F411: C6 01       LDB    #$01
F413: E7 C9 01 60 STB    $0160,U
F417: 20 03       BRA    $F41C
F419: B6 13 88    LDA    $1388
F41C: 44          LSRA
F41D: 44          LSRA
F41E: 44          LSRA
F41F: 44          LSRA
F420: 84 0F       ANDA   #$0F
F422: A7 C9 01 40 STA    $0140,U
F426: B6 13 88    LDA    $1388
F429: 84 0F       ANDA   #$0F
F42B: A7 C9 01 20 STA    $0120,U
F42F: 39          RTS
F430: 34 10       PSHS   X
F432: 8E F4 AD    LDX    #$F4AD
F435: C6 09       LDB    #$09
F437: BD F3 D0    JSR    $F3D0
F43A: 35 10       PULS   X
F43C: A6 84       LDA    ,X
F43E: 80 A0       SUBA   #$A0
F440: 25 08       BCS    $F44A
F442: C6 01       LDB    #$01
F444: E7 C9 01 60 STB    $0160,U
F448: 20 02       BRA    $F44C
F44A: A6 84       LDA    ,X
F44C: 44          LSRA
F44D: 44          LSRA
F44E: 44          LSRA
F44F: 44          LSRA
F450: 84 0F       ANDA   #$0F
F452: A7 C9 01 40 STA    $0140,U
F456: A6 84       LDA    ,X
F458: 84 0F       ANDA   #$0F
F45A: A7 C9 01 20 STA    $0120,U
F45E: 39          RTS


F4C7: CC 00 00    LDD    #$0000                                      
F4CA: FD 13 8D    STD    $138D
F4CD: CC 00 01    LDD    #$0001
F4D0: FD 13 8F    STD    $138F
F4D3: 74 13 8C    LSR    $138C
F4D6: 24 13       BCC    $F4EB
F4D8: B6 13 8E    LDA    $138E
F4DB: BB 13 90    ADDA   $1390
F4DE: 19          DAA
F4DF: B7 13 8E    STA    $138E
F4E2: B6 13 8D    LDA    $138D
F4E5: B9 13 8F    ADCA   $138F
F4E8: B7 13 8D    STA    $138D
F4EB: B6 13 90    LDA    $1390
F4EE: BB 13 90    ADDA   $1390
F4F1: 19          DAA
F4F2: B7 13 90    STA    $1390
F4F5: B6 13 8F    LDA    $138F
F4F8: B9 13 8F    ADCA   $138F
F4FB: B7 13 8F    STA    $138F
F4FE: B6 13 8C    LDA    $138C
F501: 26 D0       BNE    $F4D3
F503: 39          RTS

reset_f504:
F504: 1A FF       ORCC   #$FF
F506: B7 50 02    STA    video_stuff_5002
F509: B7 50 04    STA    video_stuff_5004
F50C: B7 50 0A    STA    video_stuff_500A
F50F: B7 50 08    STA    video_stuff_5008
; self tests (tiles, sprites, other?)
F512: 10 8E 00 10 LDY    #$0010
F516: 8E 10 00    LDX    #$1000
F519: 1F 20       TFR    Y,D
F51B: C5 90       BITB   #$90
F51D: 27 0B       BEQ    $F52A
F51F: 53          COMB
F520: C5 90       BITB   #$90
F522: 27 05       BEQ    $F529
F524: 53          COMB
F525: 1C FE       ANDCC  #$FE
F527: 20 03       BRA    $F52C
F529: 53          COMB
F52A: 1A 01       ORCC   #$01
F52C: 59          ROLB
F52D: E7 80       STB    ,X+
F52F: F7 80 00    STB    watchdog_8000
F532: 8C 11 00    CMPX   #$1100
F535: 26 E4       BNE    $F51B
F537: 8E 10 00    LDX    #$1000
F53A: 1F 20       TFR    Y,D
F53C: C5 90       BITB   #$90
F53E: 27 0B       BEQ    $F54B
F540: 53          COMB
F541: C5 90       BITB   #$90
F543: 27 05       BEQ    $F54A
F545: 53          COMB
F546: 1C FE       ANDCC  #$FE
F548: 20 03       BRA    $F54D
F54A: 53          COMB
F54B: 1A 01       ORCC   #$01
F54D: 59          ROLB
F54E: 1F 98       TFR    B,A
F550: A0 80       SUBA   ,X+
F552: 84 0F       ANDA   #$0F
F554: 10 26 00 CF LBNE   $F627
F558: 8C 11 00    CMPX   #$1100
F55B: 26 DF       BNE    $F53C
F55D: 31 3F       LEAY   -$1,Y
F55F: 26 B5       BNE    $F516
F561: 8E 10 00    LDX    #$1000
F564: CC 99 99    LDD    #$9999
F567: ED 81       STD    ,X++
F569: 8C 10 14    CMPX   #$1014
F56C: 26 F9       BNE    $F567
F56E: 6F 80       CLR    ,X+
F570: 6F 80       CLR    ,X+
F572: 6F 84       CLR    ,X
F574: 20 5E       BRA    $F5D4
F576: 1A FF       ORCC   #$FF
F578: B7 50 02    STA    video_stuff_5002
F57B: B7 50 04    STA    $5004
F57E: B7 50 0A    STA    $500A
F581: B7 50 08    STA    $5008
F584: B7 50 06    STA    $5006
F587: 10 8E 00 10 LDY    #$0010
F58B: 8E 10 20    LDX    #$1020
F58E: 1F 20       TFR    Y,D
F590: C5 90       BITB   #$90
F592: 27 0B       BEQ    $F59F
F594: 53          COMB
F595: C5 90       BITB   #$90
F597: 27 05       BEQ    $F59E
F599: 53          COMB
F59A: 1C FE       ANDCC  #$FE
F59C: 20 03       BRA    $F5A1
F59E: 53          COMB
F59F: 1A 01       ORCC   #$01
F5A1: 59          ROLB
F5A2: E7 80       STB    ,X+
F5A4: F7 80 00    STB    watchdog_8000
F5A7: 8C 11 00    CMPX   #$1100
F5AA: 26 E4       BNE    $F590
F5AC: 8E 10 20    LDX    #$1020
F5AF: 1F 20       TFR    Y,D
F5B1: C5 90       BITB   #$90
F5B3: 27 0B       BEQ    $F5C0
F5B5: 53          COMB
F5B6: C5 90       BITB   #$90
F5B8: 27 05       BEQ    $F5BF
F5BA: 53          COMB
F5BB: 1C FE       ANDCC  #$FE
F5BD: 20 03       BRA    $F5C2
F5BF: 53          COMB
F5C0: 1A 01       ORCC   #$01
F5C2: 59          ROLB
F5C3: 1F 98       TFR    B,A
F5C5: A0 80       SUBA   ,X+
F5C7: 84 0F       ANDA   #$0F
F5C9: 26 5C       BNE    $F627
F5CB: 8C 11 00    CMPX   #$1100
F5CE: 26 E1       BNE    $F5B1
F5D0: 31 3F       LEAY   -$1,Y
F5D2: 26 B7       BNE    $F58B
F5D4: 10 CE 11 00 LDS    #$1100
F5D8: 8E 08 00    LDX    #$0800
F5DB: CC 00 00    LDD    #$0000
F5DE: ED 81       STD    ,X++
F5E0: 8C 10 00    CMPX   #$1000
F5E3: 26 F9       BNE    $F5DE
F5E5: 8E 00 00    LDX    #$0000
F5E8: CC 08 00    LDD    #$0800
F5EB: BD FD 45    JSR    $FD45
F5EE: 27 07       BEQ    $F5F7
F5F0: 10 8E 00 01 LDY    #$0001
F5F4: 7E F6 A0    JMP    $F6A0
F5F7: 8E 08 00    LDX    #$0800
F5FA: CC 08 00    LDD    #$0800
F5FD: BD FD 45    JSR    $FD45
F600: 27 07       BEQ    $F609
F602: 10 8E 00 02 LDY    #$0002
F606: 7E F6 A0    JMP    $F6A0
F609: BD F3 5B    JSR    $F35B
F60C: BD F3 76    JSR    $F376
F60F: 8E 08 00    LDX    #$0800
F612: CC 09 09    LDD    #$0909
F615: ED 81       STD    ,X++
F617: 8C 10 00    CMPX   #$1000
F61A: 26 F9       BNE    $F615
F61C: 8E 11 00    LDX    #$1100
F61F: CC 07 00    LDD    #$0700
F622: BD FD 45    JSR    $FD45
F625: 27 07       BEQ    $F62E
F627: 10 8E 00 03 LDY    #$0003
F62B: 7E F6 A0    JMP    $F6A0
F62E: 8E 17 80    LDX    #stack_top_1780
F631: CC 00 00    LDD    #$0000
F634: ED 81       STD    ,X++
F636: 8C 18 00    CMPX   #$1800
F639: 26 F9       BNE    $F634
F63B: CC 08 00    LDD    #$0800
F63E: BD FD 45    JSR    $FD45
F641: 27 07       BEQ    $F64A
F643: 10 8E 00 04 LDY    #$0004
F647: 7E F6 A0    JMP    $F6A0
F64A: 8E 20 00    LDX    #$2000
F64D: CC 08 00    LDD    #$0800
F650: BD FD 45    JSR    $FD45
F653: 27 07       BEQ    $F65C
F655: 10 8E 00 05 LDY    #$0005
F659: 7E F6 A0    JMP    $F6A0
F65C: 8E 40 40    LDX    #$4040
F65F: CC 03 C0    LDD    #$03C0
F662: BD FD 45    JSR    $FD45
F665: 27 07       BEQ    $F66E
F667: 10 8E 00 06 LDY    #$0006
F66B: 7E F6 A0    JMP    $F6A0
F66E: 10 8E 00 10 LDY    #$0010
F672: 8E 48 00    LDX    #namco_io_4800
F675: 1F 20       TFR    Y,D
F677: BD FD 77    JSR    $FD77
F67A: E7 80       STB    ,X+
F67C: 8C 48 20    CMPX   #$4820
F67F: 26 F6       BNE    $F677
F681: 8E 48 00    LDX    #namco_io_4800
F684: 1F 20       TFR    Y,D
F686: BD FD 77    JSR    $FD77
F689: 1F 98       TFR    B,A
F68B: A0 80       SUBA   ,X+
F68D: 84 0F       ANDA   #$0F
F68F: 26 0B       BNE    $F69C
F691: 8C 48 20    CMPX   #$4820
F694: 26 F0       BNE    $F686
F696: 31 3F       LEAY   -$1,Y
F698: 26 D8       BNE    $F672
F69A: 20 04       BRA    $F6A0
F69C: 10 8E 00 07 LDY    #$0007
F6A0: B7 3F FF    STA    $3FFF
F6A3: 8E 00 00    LDX    #$0000
F6A6: CC 20 20    LDD    #$2020
F6A9: ED 81       STD    ,X++
F6AB: B7 80 00    STA    watchdog_8000
F6AE: 8C 08 00    CMPX   #$0800
F6B1: 26 F6       BNE    $F6A9
F6B3: CC 09 09    LDD    #$0909
F6B6: ED 81       STD    ,X++
F6B8: B7 80 00    STA    watchdog_8000
F6BB: 8C 10 00    CMPX   #$1000
F6BE: 26 F6       BNE    $F6B6
F6C0: 8E 1F 80    LDX    #$1F80
F6C3: CC 00 00    LDD    #$0000
F6C6: ED 81       STD    ,X++
F6C8: B7 80 00    STA    watchdog_8000
F6CB: 8C 20 00    CMPX   #$2000
F6CE: 26 F6       BNE    $F6C6
F6D0: 8E 27 80    LDX    #$2780
F6D3: CC 00 00    LDD    #$0000
F6D6: ED 81       STD    ,X++
F6D8: B7 80 00    STA    watchdog_8000
F6DB: 8C 28 00    CMPX   #$2800
F6DE: 26 F6       BNE    $F6D6
F6E0: 86 52       LDA    #$52
F6E2: B7 07 20    STA    $0720
F6E5: 86 4F       LDA    #$4F
F6E7: B7 06 A0    STA    $06A0
F6EA: 86 41       LDA    #$41
F6EC: B7 07 00    STA    $0700
F6EF: 86 4D       LDA    #$4D
F6F1: B7 06 E0    STA    $06E0
F6F4: 1F 20       TFR    Y,D
F6F6: 5D          TSTB
F6F7: 27 08       BEQ    $F701
F6F9: F7 06 A0    STB    $06A0
F6FC: F7 80 00    STB    watchdog_8000
F6FF: 20 FB       BRA    $F6FC
F701: 86 4B       LDA    #$4B
F703: B7 06 80    STA    $0680
F706: 86 52       LDA    #$52
F708: B7 07 22    STA    $0722
F70B: 86 4F       LDA    #$4F
F70D: B7 07 02    STA    $0702
F710: 86 4D       LDA    #$4D
F712: B7 06 E2    STA    $06E2
F715: C6 01       LDB    #$01
F717: 8E A0 00    LDX    #$A000
F71A: 4F          CLRA
F71B: AB 80       ADDA   ,X+
F71D: B7 80 00    STA    watchdog_8000
F720: 8C C0 00    CMPX   #$C000
F723: 26 F6       BNE    $F71B
F725: 81 11       CMPA   #$11
F727: 26 37       BNE    $F760
F729: 5C          INCB
F72A: 4F          CLRA
F72B: AB 80       ADDA   ,X+
F72D: B7 80 00    STA    watchdog_8000
F730: 8C E0 00    CMPX   #$E000
F733: 26 F6       BNE    $F72B
F735: 81 22       CMPA   #$22
F737: 26 27       BNE    $F760
F739: 5C          INCB
F73A: 4F          CLRA
F73B: AB 80       ADDA   ,X+
F73D: B7 80 00    STA    watchdog_8000
F740: 8C 00 00    CMPX   #$0000
F743: 26 F6       BNE    $F73B
F745: 81 33       CMPA   #$33
F747: 26 17       BNE    $F760
F749: 86 77       LDA    #$77
F74B: B7 40 40    STA    $4040
F74E: B7 50 0B    STA    $500B
F751: B7 80 00    STA    watchdog_8000
F754: B6 40 40    LDA    $4040
F757: 81 77       CMPA   #$77
F759: 27 F6       BEQ    $F751
F75B: 84 FF       ANDA   #$FF
F75D: 27 09       BEQ    $F768
F75F: 5C          INCB
F760: F7 06 A2    STB    $06A2
F763: F7 80 00    STB    watchdog_8000
F766: 20 FB       BRA    $F763
self_tests_over_f768:
F768: 86 4F       LDA    #$4F
F76A: B7 06 A2    STA    $06A2
F76D: 86 4B       LDA    #$4B
F76F: B7 06 82    STA    $0682
F772: 10 CE 17 80 LDS    #stack_top_1780
F776: 86 01       LDA    #$01
F778: B7 13 6D    STA    $136D
F77B: BD F3 AA    JSR    $F3AA
F77E: 7F 10 14    CLR    $1014
F781: 1C EF       ANDCC  #$EF
F783: B7 50 03    STA    video_stuff_5003
F786: 7F 13 83    CLR    $1383
F789: 7F 13 84    CLR    $1384
F78C: 86 FF       LDA    #$FF
F78E: B7 13 89    STA    scroll_value_1389
F791: B7 50 09    STA    video_stuff_5009
F794: 86 04       LDA    #$04
F796: B7 13 B1    STA    $13B1
F799: B6 13 B1    LDA    $13B1
F79C: 26 FB       BNE    $F799
F79E: 8E F8 51    LDX    #$F851
F7A1: CE 07 24    LDU    #$0724
F7A4: BD F3 B5    JSR    $F3B5
F7A7: 8E F8 55    LDX    #$F855
F7AA: CE 48 09    LDU    #$4809
F7AD: A6 80       LDA    ,X+
F7AF: A7 C0       STA    ,U+
F7B1: 11 83 48 10 CMPU   #$4810
F7B5: 26 F6       BNE    $F7AD
F7B7: 8E F8 55    LDX    #$F855
F7BA: CE 48 19    LDU    #$4819
F7BD: A6 80       LDA    ,X+
F7BF: A7 C0       STA    ,U+
F7C1: 11 83 48 20 CMPU   #$4820
F7C5: 26 F6       BNE    $F7BD
F7C7: 86 05       LDA    #$05
F7C9: B7 13 83    STA    $1383
F7CC: B7 13 84    STA    $1384
F7CF: 86 02       LDA    #$02
F7D1: B7 13 B1    STA    $13B1
F7D4: B6 13 B1    LDA    $13B1
F7D7: 26 FB       BNE    $F7D4
F7D9: 8E 48 01    LDX    #number_of_players_4801
F7DC: CE F8 5C    LDU    #$F85C
F7DF: A6 80       LDA    ,X+
F7E1: 84 0F       ANDA   #$0F
F7E3: A1 C0       CMPA   ,U+
F7E5: 26 5F       BNE    $F846
F7E7: 8C 48 08    CMPX   #$4808
F7EA: 26 F3       BNE    $F7DF
F7EC: 8E 48 11    LDX    #$4811
F7EF: CE F8 5C    LDU    #$F85C
F7F2: A6 80       LDA    ,X+
F7F4: 84 0F       ANDA   #$0F
F7F6: A1 C0       CMPA   ,U+
F7F8: 26 50       BNE    $F84A
F7FA: 8C 48 18    CMPX   #io_register_4818
F7FD: 26 F3       BNE    $F7F2
F7FF: 86 4F       LDA    #$4F
F801: B7 06 A4    STA    $06A4
F804: 86 4B       LDA    #$4B
F806: B7 06 84    STA    $0684
F809: 4F          CLRA
F80A: 8E 48 02    LDX    #credits_tens_4802
F80D: A7 80       STA    ,X+
F80F: 8C 48 20    CMPX   #$4820
F812: 26 F9       BNE    $F80D
F814: 7F 13 83    CLR    $1383
F817: 7F 13 84    CLR    $1384
F81A: 86 02       LDA    #$02
F81C: B7 13 B1    STA    $13B1
F81F: B6 13 B1    LDA    $13B1
F822: 26 FB       BNE    $F81F
F824: 8E 48 09    LDX    #$4809
F827: 86 FF       LDA    #$FF
F829: A7 80       STA    ,X+
F82B: 8C 48 10    CMPX   #$4810
F82E: 25 F9       BCS    $F829
F830: 86 01       LDA    #$01
F832: B7 13 83    STA    $1383
F835: 86 04       LDA    #$04
F837: B7 13 84    STA    $1384
F83A: 86 02       LDA    #$02
F83C: B7 13 B1    STA    $13B1
F83F: B6 13 B1    LDA    $13B1
F842: 26 FB       BNE    $F83F
F844: 20 1D       BRA    $F863
F846: 86 01       LDA    #$01
F848: 20 02       BRA    $F84C
F84A: 86 02       LDA    #$02
F84C: B7 06 A4    STA    $06A4
F84F: 20 FE       BRA    $F84F

F863: 8E 00 00    LDX    #$0000                                      
F866: 86 3A       LDA    #$3A
F868: C6 10       LDB    #$10
F86A: A7 81       STA    ,X++
F86C: 5A          DECB
F86D: 26 FB       BNE    $F86A
F86F: 30 88 20    LEAX   $20,X
F872: 8C 03 80    CMPX   #$0380
F875: 26 F1       BNE    $F868
F877: 8E 00 01    LDX    #$0001
F87A: 86 3B       LDA    #$3B
F87C: C6 10       LDB    #$10
F87E: A7 81       STA    ,X++
F880: 5A          DECB
F881: 26 FB       BNE    $F87E
F883: 30 88 20    LEAX   $20,X
F886: 8C 03 81    CMPX   #$0381
F889: 26 F1       BNE    $F87C
F88B: 8E 00 20    LDX    #$0020
F88E: 86 3C       LDA    #$3C
F890: C6 10       LDB    #$10
F892: A7 81       STA    ,X++
F894: 5A          DECB
F895: 26 FB       BNE    $F892
F897: 30 88 20    LEAX   $20,X
F89A: 8C 03 A0    CMPX   #$03A0
F89D: 26 F1       BNE    $F890
F89F: 8E 00 21    LDX    #$0021
F8A2: 86 3D       LDA    #$3D
F8A4: C6 10       LDB    #$10
F8A6: A7 81       STA    ,X++
F8A8: 5A          DECB
F8A9: 26 FB       BNE    $F8A6
F8AB: 30 88 20    LEAX   $20,X
F8AE: 8C 03 A1    CMPX   #$03A1
F8B1: 26 F1       BNE    $F8A4
F8B3: 8E FE C0    LDX    #$FEC0
F8B6: CE 07 DB    LDU    #$07DB
F8B9: BD F3 C3    JSR    $F3C3
F8BC: 8E FC B3    LDX    #$FCB3
F8BF: CE 06 E9    LDU    #$06E9
F8C2: BD F3 B5    JSR    $F3B5
F8C5: 8E FC B3    LDX    #$FCB3
F8C8: CE 06 EB    LDU    #$06EB
F8CB: BD F3 B5    JSR    $F3B5
F8CE: 8E FC C2    LDX    #$FCC2
F8D1: CE 07 2D    LDU    #$072D
F8D4: BD F3 B5    JSR    $F3B5
F8D7: 8E FE BA    LDX    #$FEBA
F8DA: CE 07 2F    LDU    #$072F
F8DD: BD F3 B5    JSR    $F3B5
F8E0: 8E FC CB    LDX    #$FCCB
F8E3: CE 07 31    LDU    #$0731
F8E6: BD F3 B5    JSR    $F3B5
F8E9: 4F          CLRA
F8EA: B7 06 31    STA    $0631
F8ED: B7 06 51    STA    $0651
F8F0: 86 1E       LDA    #$1E
F8F2: B7 13 66    STA    $1366
F8F5: 8E FC AF    LDX    #$FCAF
F8F8: CE 07 33    LDU    #$0733
F8FB: BD F3 B5    JSR    $F3B5
F8FE: 8E FC C7    LDX    #$FCC7
F901: CE 07 35    LDU    #$0735
F904: BD F3 B5    JSR    $F3B5
F907: 8E 13 60    LDX    #$1360
F90A: 86 FF       LDA    #$FF
F90C: A7 80       STA    ,X+
F90E: 8C 13 66    CMPX   #$1366
F911: 26 F9       BNE    $F90C
F913: 7F 13 82    CLR    $1382
F916: B6 13 82    LDA    $1382
F919: 27 FB       BEQ    $F916
F91B: 7F 13 82    CLR    $1382
F91E: 8E 10 1A    LDX    #$101A
F921: A6 01       LDA    $1,X
F923: A7 80       STA    ,X+
F925: A6 01       LDA    $1,X
F927: 43          COMA
F928: A7 80       STA    ,X+
F92A: A6 01       LDA    $1,X
F92C: A7 80       STA    ,X+
F92E: B6 48 04    LDA    joystick_directions_4804
F931: A7 84       STA    ,X
F933: A4 1F       ANDA   -$1,X
F935: A4 1E       ANDA   -$2,X
F937: A4 1D       ANDA   -$3,X
F939: 85 08       BITA   #$08
F93B: 10 27 00 7F LBEQ   $F9BE
F93F: B6 48 07    LDA    start_2p_4807
F942: 85 01       BITA   #$01
F944: 10 27 00 76 LBEQ   $F9BE
F948: 8E 10 00    LDX    #$1000
F94B: CE 07 3E    LDU    #$073E
F94E: 10 8E F9 8C LDY    #$F98C
F952: 8D 07       BSR    $F95B
F954: CE 07 3F    LDU    #$073F
F957: 8D 02       BSR    $F95B
F959: 20 63       BRA    $F9BE
F95B: E6 A0       LDB    ,Y+
F95D: C1 2F       CMPB   #$2F
F95F: 26 01       BNE    $F962
F961: 39          RTS
F962: C1 4C       CMPB   #$4C
F964: 26 04       BNE    $F96A
F966: 8D 16       BSR    $F97E
F968: 20 F1       BRA    $F95B
F96A: C1 55       CMPB   #$55
F96C: 26 04       BNE    $F972
F96E: 8D 06       BSR    $F976
F970: 20 E9       BRA    $F95B
F972: 8D 10       BSR    $F984
F974: 20 E5       BRA    $F95B
F976: A6 84       LDA    ,X
F978: 44          LSRA
F979: 44          LSRA
F97A: 44          LSRA
F97B: 44          LSRA
F97C: 20 08       BRA    $F986
F97E: A6 80       LDA    ,X+
F980: 84 0F       ANDA   #$0F
F982: 20 02       BRA    $F986
F984: 86 5F       LDA    #$5F
F986: A7 C4       STA    ,U
F988: 33 C8 E0    LEAU   -$20,U
F98B: 39          RTS

F9BE: B6 13 8B    LDA    $138B                                      
F9C1: 27 0D       BEQ    $F9D0                                      
F9C3: B6 13 89    LDA    scroll_value_1389                                      
F9C6: B7 13 8B    STA    $138B                                      
F9C9: 10 27 01 71 LBEQ   $FB3E                                      
F9CD: 7E FA 79    JMP    $FA79                                      
F9D0: B6 13 89    LDA    scroll_value_1389                                      
F9D3: B7 13 8B    STA    $138B                                      
F9D6: 10 26 00 A2 LBNE   $FA7C                                      
F9DA: 8E 07 80    LDX    #$0780                                     
F9DD: 86 3A       LDA    #$3A
F9DF: C6 10       LDB    #$10
F9E1: A7 81       STA    ,X++
F9E3: 5A          DECB
F9E4: 26 FB       BNE    $F9E1
F9E6: 30 88 20    LEAX   $20,X
F9E9: 8C 08 00    CMPX   #$0800
F9EC: 26 F1       BNE    $F9DF
F9EE: 8E 07 81    LDX    #$0781
F9F1: 86 3C       LDA    #$3C
F9F3: C6 10       LDB    #$10
F9F5: A7 81       STA    ,X++
F9F7: 5A          DECB
F9F8: 26 FB       BNE    $F9F5
F9FA: 30 88 20    LEAX   $20,X
F9FD: 8C 08 01    CMPX   #$0801
FA00: 26 F1       BNE    $F9F3
FA02: 8E 07 A0    LDX    #$07A0
FA05: 86 3B       LDA    #$3B
FA07: C6 10       LDB    #$10
FA09: A7 81       STA    ,X++
FA0B: 5A          DECB
FA0C: 26 FB       BNE    $FA09
FA0E: 30 88 20    LEAX   $20,X
FA11: 8C 08 20    CMPX   #$0820
FA14: 26 F1       BNE    $FA07
FA16: 8E 07 A1    LDX    #$07A1
FA19: 86 3D       LDA    #$3D
FA1B: C6 10       LDB    #$10
FA1D: A7 81       STA    ,X++
FA1F: 5A          DECB
FA20: 26 FB       BNE    $FA1D
FA22: 30 88 20    LEAX   $20,X
FA25: 8C 08 21    CMPX   #$0821
FA28: 26 F1       BNE    $FA1B
FA2A: 8E 15 00    LDX    #$1500
FA2D: B6 48 04    LDA    joystick_directions_4804
FA30: BD FB 26    JSR    $FB26
FA33: 8E 15 05    LDX    #$1505
FA36: B6 48 05    LDA    start_1p_4805
FA39: BD FB 26    JSR    $FB26
FA3C: 8E 15 0A    LDX    #$150A
FA3F: B6 48 06    LDA    $4806
FA42: BD FB 26    JSR    $FB26
FA45: 8E 15 0F    LDX    #$150F
FA48: B6 48 07    LDA    start_2p_4807
FA4B: BD FB 26    JSR    $FB26
FA4E: 8E FA 57    LDX    #table_fa57
FA51: B6 15 14    LDA    $1514
FA54: 48          ASLA
FA55: 6E 96       JMP    [A,X]		 ; [indirect_jump] [nb_entries=18]
table_fa57:
	.word	$fa85 
	.word	$fa85 
	.word	$fa85 
	.word	$fa92 
	.word	$fa92 
	.word	$fa92 
	.word	$fa92 
	.word	$faae
	.word	$faae 
	.word	$faae 
	.word	$faae 
	.word	$faae 
	.word	$faae 
	.word	$fa92 
	.word	$fa92 
	.word	$fa92
	.word	$fac9 

FA79: BD FD 99    JSR    $FD99
FA7C: BD FD 8D    JSR    $FD8D
FA7F: 7F 15 14    CLR    $1514
FA82: 7E FB 3E    JMP    $FB3E
FA85: B6 15 04    LDA    $1504
FA88: 84 0F       ANDA   #$0F
FA8A: 27 55       BEQ    $FAE1
FA8C: 81 08       CMPA   #$08
FA8E: 26 63       BNE    $FAF3
FA90: 20 32       BRA    $FAC4
FA92: B6 48 07    LDA    start_2p_4807
FA95: 84 0F       ANDA   #$0F
FA97: 27 48       BEQ    $FAE1
FA99: 81 01       CMPA   #$01
FA9B: 27 04       BEQ    $FAA1
FA9D: 81 05       CMPA   #$05
FA9F: 26 52       BNE    $FAF3
FAA1: B6 15 09    LDA    $1509
FAA4: 84 0F       ANDA   #$0F
FAA6: 27 39       BEQ    $FAE1
FAA8: 81 08       CMPA   #$08
FAAA: 26 47       BNE    $FAF3
FAAC: 20 16       BRA    $FAC4
FAAE: B6 48 07    LDA    start_2p_4807
FAB1: 84 0F       ANDA   #$0F
FAB3: 27 2C       BEQ    $FAE1
FAB5: 81 05       CMPA   #$05
FAB7: 26 28       BNE    $FAE1
FAB9: B6 15 13    LDA    $1513
FABC: 84 0E       ANDA   #$0E
FABE: 27 21       BEQ    $FAE1
FAC0: 81 04       CMPA   #$04
FAC2: 26 2F       BNE    $FAF3
FAC4: 7C 15 14    INC    $1514
FAC7: 20 75       BRA    $FB3E

FAC9: B6 48 07    LDA    start_2p_4807
FACC: 84 0F       ANDA   #$0F
FACE: 27 11       BEQ    $FAE1
FAD0: 81 09       CMPA   #$09
FAD2: 26 0D       BNE    $FAE1
FAD4: B6 15 13    LDA    $1513
FAD7: 84 0E       ANDA   #$0E
FAD9: 27 06       BEQ    $FAE1
FADB: 81 08       CMPA   #$08
FADD: 26 14       BNE    $FAF3
FADF: 20 21       BRA    $FB02
FAE1: B6 15 13    LDA    $1513
FAE4: 84 FE       ANDA   #$FE
FAE6: BA 15 04    ORA    $1504
FAE9: BA 15 09    ORA    $1509
FAEC: BA 15 0E    ORA    $150E
FAEF: 84 0F       ANDA   #$0F
FAF1: 27 4B       BEQ    $FB3E
FAF3: 8E 15 00    LDX    #$1500
FAF6: 6F 80       CLR    ,X+
FAF8: 8C 15 14    CMPX   #$1514
FAFB: 25 F9       BCS    $FAF6
FAFD: 7F 15 14    CLR    $1514
FB00: 20 3C       BRA    $FB3E
FB02: BD F3 5B    JSR    $F35B
FB05: BD F3 76    JSR    $F376
FB08: 8E FC D5    LDX    #$FCD5
FB0B: CE 00 00    LDU    #$0000
FB0E: C6 08       LDB    #$08
FB10: A6 80       LDA    ,X+
FB12: 48          ASLA
FB13: 24 04       BCC    $FB19
FB15: 6F C0       CLR    ,U+
FB17: 20 02       BRA    $FB1B
FB19: 33 41       LEAU   $1,U
FB1B: 5A          DECB
FB1C: 26 F4       BNE    $FB12
FB1E: 11 83 07 80 CMPU   #$0780
FB22: 25 EA       BCS    $FB0E
FB24: 20 FE       BRA    $FB24
FB26: E6 01       LDB    $1,X
FB28: E7 84       STB    ,X
FB2A: E6 02       LDB    $2,X
FB2C: 53          COMB
FB2D: E7 01       STB    $1,X
FB2F: E6 03       LDB    $3,X
FB31: E7 02       STB    $2,X
FB33: A7 03       STA    $3,X
FB35: A4 02       ANDA   $2,X
FB37: A4 01       ANDA   $1,X
FB39: A4 84       ANDA   ,X
FB3B: A7 04       STA    $4,X
FB3D: 39          RTS
FB3E: B6 13 7E    LDA    $137E
FB41: 44          LSRA
FB42: 44          LSRA
FB43: 84 01       ANDA   #$01
FB45: B1 13 60    CMPA   $1360
FB48: 27 06       BEQ    $FB50
FB4A: B7 13 60    STA    $1360
FB4D: BD FD AE    JSR    $FDAE
FB50: B6 13 78    LDA    $1378
FB53: 84 07       ANDA   #$07
FB55: B1 13 61    CMPA   $1361
FB58: 27 06       BEQ    $FB60
FB5A: B7 13 61    STA    $1361
FB5D: BD FD C2    JSR    $FDC2
FB60: F6 13 7C    LDB    $137C
FB63: B6 13 7A    LDA    $137A
FB66: 44          LSRA
FB67: 44          LSRA
FB68: 44          LSRA
FB69: 44          LSRA
FB6A: 59          ROLB
FB6B: C4 03       ANDB   #$03
FB6D: F1 13 62    CMPB   $1362
FB70: 27 06       BEQ    $FB78
FB72: F7 13 62    STB    $1362
FB75: BD FD D9    JSR    $FDD9
FB78: B6 13 7A    LDA    $137A
FB7B: 84 07       ANDA   #$07
FB7D: B1 13 63    CMPA   $1363
FB80: 27 06       BEQ    $FB88
FB82: B7 13 63    STA    $1363
FB85: BD FE 17    JSR    $FE17
FB88: B6 13 79    LDA    $1379
FB8B: 44          LSRA
FB8C: 44          LSRA
FB8D: 84 03       ANDA   #$03
FB8F: 8E FC D1    LDX    #$FCD1
FB92: A6 86       LDA    A,X
FB94: B1 13 64    CMPA   $1364
FB97: 27 06       BEQ    $FB9F
FB99: B7 13 64    STA    $1364
FB9C: BD FE 20    JSR    $FE20
FB9F: B6 13 79    LDA    $1379
FBA2: F6 13 78    LDB    $1378
FBA5: 54          LSRB
FBA6: 54          LSRB
FBA7: 54          LSRB
FBA8: 54          LSRB
FBA9: 49          ROLA
FBAA: 84 07       ANDA   #$07
FBAC: F6 13 64    LDB    $1364
FBAF: C1 05       CMPB   #$05
FBB1: 26 02       BNE    $FBB5
FBB3: 8B 08       ADDA   #$08
FBB5: B1 13 65    CMPA   $1365
FBB8: 27 06       BEQ    $FBC0
FBBA: B7 13 65    STA    $1365
FBBD: BD FE 27    JSR    $FE27
FBC0: B6 48 05    LDA    start_1p_4805
FBC3: 84 0A       ANDA   #$0A
FBC5: 27 17       BEQ    $FBDE
FBC7: F6 13 89    LDB    scroll_value_1389
FBCA: 84 08       ANDA   #$08
FBCC: 27 07       BEQ    $FBD5
FBCE: C0 02       SUBB   #$02
FBD0: 24 09       BCC    $FBDB
FBD2: 5F          CLRB
FBD3: 20 06       BRA    $FBDB
FBD5: CB 02       ADDB   #$02
FBD7: 24 02       BCC    $FBDB
FBD9: C6 FF       LDB    #$FF
FBDB: F7 13 89    STB    scroll_value_1389
FBDE: B6 48 04    LDA    joystick_directions_4804
FBE1: BA 48 06    ORA    $4806
FBE4: 84 0F       ANDA   #$0F
FBE6: 26 07       BNE    $FBEF
FBE8: BA 48 07    ORA    start_2p_4807
FBEB: 84 0F       ANDA   #$0F
FBED: 27 25       BEQ    $FC14
FBEF: B6 13 B4    LDA    $13B4
FBF2: 85 20       BITA   #$20
FBF4: 26 1E       BNE    $FC14
FBF6: 7F 13 B4    CLR    $13B4
FBF9: 8E 40 40    LDX    #$4040
FBFC: F6 13 66    LDB    $1366
FBFF: 6F 85       CLR    B,X
FC01: 7C 13 66    INC    $1366
FC04: F6 13 66    LDB    $1366
FC07: C1 17       CMPB   #$17
FC09: 25 04       BCS    $FC0F
FC0B: 7F 13 66    CLR    $1366
FC0E: 5F          CLRB
FC0F: 6C 85       INC    B,X
FC11: BD FE 69    JSR    $FE69
FC14: B6 13 7C    LDA    $137C
FC17: 84 02       ANDA   #$02
FC19: B1 13 6B    CMPA   $136B
FC1C: 27 06       BEQ    $FC24
FC1E: B7 13 6B    STA    $136B
FC21: BD FE 86    JSR    $FE86
FC24: B6 13 7C    LDA    $137C
FC27: 84 04       ANDA   #$04
FC29: B1 13 6C    CMPA   $136C
FC2C: 27 06       BEQ    $FC34
FC2E: B7 13 6C    STA    $136C
FC31: BD FE 98    JSR    $FE98
FC34: B6 13 7E    LDA    $137E
FC37: 85 08       BITA   #$08
FC39: 27 03       BEQ    $FC3E
FC3B: 7E F9 16    JMP    $F916
FC3E: 4F          CLRA
FC3F: B7 13 83    STA    $1383
FC42: B7 50 0A    STA    video_stuff_500a
FC45: 86 02       LDA    #$02
FC47: B7 13 B1    STA    $13B1
FC4A: B6 13 B1    LDA    $13B1
FC4D: 26 FB       BNE    $FC4A
FC4F: BD F3 5B    JSR    $F35B
FC52: 86 02       LDA    #$02
FC54: B7 13 B1    STA    $13B1
FC57: B6 13 B1    LDA    $13B1
FC5A: 26 FB       BNE    $FC57
FC5C: 8E 13 67    LDX    #$1367
FC5F: CE 48 09    LDU    #$4809
FC62: A6 80       LDA    ,X+
FC64: A7 C0       STA    ,U+
FC66: 8C 13 6B    CMPX   #$136B
FC69: 26 F7       BNE    $FC62
FC6B: 86 01       LDA    #$01
FC6D: A7 C0       STA    ,U+
FC6F: 6F C0       CLR    ,U+
FC71: 6F C4       CLR    ,U
FC73: 86 02       LDA    #$02
FC75: B7 13 83    STA    $1383
FC78: B7 50 0B    STA    video_stuff_500B
FC7B: 86 02       LDA    #$02
FC7D: B7 13 B1    STA    $13B1
FC80: B6 13 B1    LDA    $13B1
FC83: 26 FB       BNE    $FC80
FC85: 86 01       LDA    #$01
FC87: B7 48 09    STA    $4809
FC8A: B7 48 0A    STA    $480A
FC8D: B7 48 0A    STA    $480A
FC90: 86 03       LDA    #$03
FC92: B7 13 83    STA    $1383
FC95: 86 02       LDA    #$02
FC97: B7 13 B1    STA    $13B1
FC9A: B6 13 B1    LDA    $13B1
FC9D: 26 FB       BNE    $FC9A
FC9F: 8E 48 00    LDX    #namco_io_4800
FCA2: 6F 80       CLR    ,X+
FCA4: 8C 48 08    CMPX   #$4808
FCA7: 26 F9       BNE    $FCA2
FCA9: 7F 13 6D    CLR    $136D
FCAC: 7E A0 00    JMP    $A000

FD45: BF 10 20    STX    $1020                                      
FD48: 30 8B       LEAX   D,X                                        
FD4A: BF 10 22    STX    $1022
FD4D: 10 8E 00 10 LDY    #$0010
FD51: BE 10 20    LDX    $1020
FD54: 1F 20       TFR    Y,D
FD56: 8D 1F       BSR    $FD77
FD58: E7 80       STB    ,X+
FD5A: BC 10 22    CMPX   $1022
FD5D: 26 F7       BNE    $FD56
FD5F: BE 10 20    LDX    $1020
FD62: 1F 20       TFR    Y,D
FD64: 8D 11       BSR    $FD77
FD66: E1 80       CMPB   ,X+
FD68: 26 0A       BNE    $FD74
FD6A: BC 10 22    CMPX   $1022
FD6D: 26 F5       BNE    $FD64
FD6F: 31 3F       LEAY   -$1,Y
FD71: 26 DE       BNE    $FD51
FD73: 39          RTS
FD74: 86 01       LDA    #$01
FD76: 39          RTS
FD77: B7 80 00    STA    watchdog_8000
FD7A: C5 90       BITB   #$90
FD7C: 27 0B       BEQ    $FD89
FD7E: 53          COMB
FD7F: C5 90       BITB   #$90
FD81: 27 05       BEQ    $FD88
FD83: 53          COMB
FD84: 1C FE       ANDCC  #$FE
FD86: 20 03       BRA    $FD8B
FD88: 53          COMB
FD89: 1A 01       ORCC   #$01
FD8B: 59          ROLB
FD8C: 39          RTS
FD8D: BD F3 76    JSR    $F376
FD90: 8E FE C0    LDX    #$FEC0
FD93: CE 07 DB    LDU    #$07DB
FD96: BD F3 C3    JSR    $F3C3
FD99: B6 13 89    LDA    scroll_value_1389
FD9C: 43          COMA
FD9D: 34 02       PSHS   A
FD9F: 44          LSRA
FDA0: 44          LSRA
FDA1: 44          LSRA
FDA2: 44          LSRA
FDA3: B7 07 D4    STA    $07D4
FDA6: 35 02       PULS   A
FDA8: 84 0F       ANDA   #$0F
FDAA: B7 07 D3    STA    $07D3
FDAD: 39          RTS
FDAE: B6 13 60    LDA    $1360
FDB1: 27 05       BEQ    $FDB8
FDB3: 8E FE C7    LDX    #$FEC7
FDB6: 20 03       BRA    $FDBB
FDB8: 8E FE CF    LDX    #$FECF
FDBB: CE 07 26    LDU    #$0726
FDBE: BD F3 B5    JSR    $F3B5
FDC1: 39          RTS
FDC2: 8E D4 C6    LDX    #$D4C6
FDC5: CE 07 29    LDU    #$0729
FDC8: F6 13 61    LDB    $1361
FDCB: 58          ASLB
FDCC: 3A          ABX
FDCD: A6 84       LDA    ,X
FDCF: B7 13 67    STA    $1367
FDD2: A6 01       LDA    $1,X
FDD4: B7 13 68    STA    $1368
FDD7: 20 15       BRA    $FDEE
FDD9: 8E D4 D6    LDX    #$D4D6
FDDC: CE 07 2B    LDU    #$072B
FDDF: F6 13 62    LDB    $1362
FDE2: 58          ASLB
FDE3: 3A          ABX
FDE4: A6 84       LDA    ,X
FDE6: B7 13 69    STA    $1369
FDE9: A6 01       LDA    $1,X
FDEB: B7 13 6A    STA    $136A
FDEE: A6 80       LDA    ,X+
FDF0: 84 07       ANDA   #$07
FDF2: 81 01       CMPA   #$01
FDF4: 27 04       BEQ    $FDFA
FDF6: C6 53       LDB    #$53
FDF8: 20 02       BRA    $FDFC
FDFA: C6 20       LDB    #$20
FDFC: E7 C9 FF 40 STB    -$00C0,U
FE00: A7 C4       STA    ,U
FE02: A6 84       LDA    ,X
FE04: 81 01       CMPA   #$01
FE06: 27 04       BEQ    $FE0C
FE08: C6 53       LDB    #$53
FE0A: 20 02       BRA    $FE0E
FE0C: C6 20       LDB    #$20
FE0E: E7 C9 FE 00 STB    -$0200,U
FE12: A7 C9 FF 00 STA    -$0100,U
FE16: 39          RTS
FE17: B6 13 63    LDA    $1363
FE1A: 8B 41       ADDA   #$41
FE1C: B7 06 2D    STA    $062D
FE1F: 39          RTS
FE20: B6 13 64    LDA    $1364
FE23: B7 06 2F    STA    $062F
FE26: 39          RTS
FE27: 8E F4 5F    LDX    #$F45F
FE2A: CE 07 3A    LDU    #$073A
FE2D: BD FE AA    JSR    $FEAA
FE30: 8E F4 5F    LDX    #$F45F
FE33: CE 07 3C    LDU    #$073C
FE36: 8D 72       BSR    $FEAA
FE38: 8E D4 03    LDX    #$D403
FE3B: F6 13 65    LDB    $1365
FE3E: 58          ASLB
FE3F: AE 85       LDX    B,X
FE41: A6 84       LDA    ,X
FE43: 26 07       BNE    $FE4C
FE45: CE 07 38    LDU    #$0738
FE48: BD F3 E2    JSR    $F3E2
FE4B: 39          RTS
FE4C: CE 07 38    LDU    #$0738
FE4F: BD F3 EB    JSR    $F3EB
FE52: A6 01       LDA    $1,X
FE54: 26 01       BNE    $FE57
FE56: 39          RTS
FE57: CE 07 3A    LDU    #$073A
FE5A: BD F3 F9    JSR    $F3F9
FE5D: A6 80       LDA    ,X+
FE5F: 26 01       BNE    $FE62
FE61: 39          RTS
FE62: CE 07 3C    LDU    #$073C
FE65: BD F4 30    JSR    $F430
FE68: 39          RTS
FE69: B6 13 66    LDA    $1366
FE6C: 4C          INCA
FE6D: B7 13 8C    STA    $138C
FE70: BD F4 C7    JSR    $F4C7
FE73: B6 13 8E    LDA    $138E
FE76: 44          LSRA
FE77: 44          LSRA
FE78: 44          LSRA
FE79: 44          LSRA
FE7A: B7 06 51    STA    $0651
FE7D: B6 13 8E    LDA    $138E
FE80: 84 0F       ANDA   #$0F
FE82: B7 06 31    STA    $0631
FE85: 39          RTS
FE86: 4D          TSTA
FE87: 27 05       BEQ    $FE8E
FE89: 8E FE EA    LDX    #$FEEA
FE8C: 20 03       BRA    $FE91
FE8E: 8E FE E6    LDX    #$FEE6
FE91: CE 06 73    LDU    #$0673
FE94: BD F3 B5    JSR    $F3B5
FE97: 39          RTS
FE98: 4D          TSTA
FE99: 26 05       BNE    $FEA0
FE9B: 8E FE EA    LDX    #$FEEA
FE9E: 20 03       BRA    $FEA3
FEA0: 8E FE E6    LDX    #$FEE6
FEA3: CE 06 75    LDU    #$0675
FEA6: BD F3 B5    JSR    $F3B5
FEA9: 39          RTS
FEAA: C6 20       LDB    #$20
FEAC: A6 80       LDA    ,X+
FEAE: 81 2F       CMPA   #$2F
FEB0: 26 01       BNE    $FEB3
FEB2: 39          RTS
FEB3: E7 C4       STB    ,U
FEB5: 33 C8 E0    LEAU   -$20,U
FEB8: 20 F2       BRA    $FEAC

irq_ff01:
FF01: B7 80 00    STA    $8000                                        
FF04: B7 50 02    STA    video_stuff_5002
FF07: B6 13 83    LDA    $1383
FF0A: B7 48 08    STA    $4808
FF0D: B6 13 84    LDA    $1384
FF10: B7 48 18    STA    io_register_4818
FF13: B6 13 6D    LDA    $136D
FF16: 26 0B       BNE    $FF23
FF18: B6 48 14    LDA    $4814
FF1B: 85 08       BITA   #$08
FF1D: 27 04       BEQ    $FF23
FF1F: B7 50 03    STA    video_stuff_5003
FF22: 3B          RTI
FF23: F6 13 89    LDB    scroll_value_1389
FF26: 4F          CLRA
FF27: 58          ASLB
FF28: 49          ROLA
FF29: 58          ASLB
FF2A: 49          ROLA
FF2B: 58          ASLB
FF2C: 49          ROLA
FF2D: 8E 38 00    LDX    #scroll_registers_3800
FF30: 30 8B       LEAX   D,X
FF32: A7 84       STA    ,X
FF34: 8E 11 00    LDX    #$1100
FF37: CE 17 80    LDU    #stack_top_1780
FF3A: 10 8E 00 40 LDY    #$0040
FF3E: EC 81       LDD    ,X++
FF40: ED C1       STD    ,U++
FF42: 31 3F       LEAY   -$1,Y
FF44: 26 F8       BNE    $FF3E
FF46: CE 1F 80    LDU    #$1F80
FF49: 10 8E 00 40 LDY    #$0040
FF4D: EC 81       LDD    ,X++
FF4F: ED C1       STD    ,U++
FF51: 31 3F       LEAY   -$1,Y
FF53: 26 F8       BNE    $FF4D
FF55: CE 27 80    LDU    #$2780
FF58: 10 8E 00 40 LDY    #$0040
FF5C: EC 81       LDD    ,X++
FF5E: ED C1       STD    ,U++
FF60: 31 3F       LEAY   -$1,Y
FF62: 26 F8       BNE    $FF5C
FF64: 7C 13 B0    INC    $13B0
FF67: 26 03       BNE    $FF6C
FF69: 7A 13 B8    DEC    $13B8
FF6C: 8E 13 B1    LDX    #$13B1
FF6F: 6A 80       DEC    ,X+
FF71: 8C 13 B8    CMPX   #$13B8
FF74: 26 F9       BNE    $FF6F
FF76: 8E 48 00    LDX    #namco_io_4800
FF79: CE 13 70    LDU    #$1370
FF7C: C6 08       LDB    #$08
FF7E: A6 80       LDA    ,X+
FF80: 84 0F       ANDA   #$0F
FF82: A7 C0       STA    ,U+
FF84: 5A          DECB
FF85: 26 F7       BNE    $FF7E
FF87: 8E 48 10    LDX    #$4810
FF8A: CE 13 78    LDU    #$1378
FF8D: C6 08       LDB    #$08
FF8F: A6 80       LDA    ,X+
FF91: 84 0F       ANDA   #$0F
FF93: A7 C0       STA    ,U+
FF95: 5A          DECB
FF96: 26 F7       BNE    $FF8F
FF98: B6 48 08    LDA    $4808
FF9B: 84 0F       ANDA   #$0F
FF9D: 81 03       CMPA   #$03
FF9F: 26 0B       BNE    $FFAC
FFA1: B6 48 00    LDA    namco_io_4800
FFA4: 7F 48 00    CLR    namco_io_4800
FFA7: 84 0F       ANDA   #$0F
FFA9: B7 40 5E    STA    $405E
FFAC: B6 13 E4    LDA    $13E4
FFAF: 49          ROLA
FFB0: 49          ROLA
FFB1: 84 01       ANDA   #$01
FFB3: B7 13 E6    STA    $13E6
FFB6: B6 13 E4    LDA    $13E4
FFB9: 84 01       ANDA   #$01
FFBB: B8 13 E6    EORA   $13E6
FFBE: 27 03       BEQ    $FFC3
FFC0: 4F          CLRA
FFC1: 20 01       BRA    $FFC4
FFC3: 43          COMA
FFC4: 79 13 E5    ROL    $13E5
FFC7: 79 13 E4    ROL    $13E4
FFCA: 86 01       LDA    #$01
FFCC: B7 50 03    STA    video_stuff_5003
FFCF: B7 13 82    STA    $1382
FFD2: 3B          RTI

; entrypoint followed by argument
;function_and_args_table_d020:
;    .word	$A098 
;	.word	$1400 
;	.word	$C000 
;	.word	$1403 
;	.word	$C013 
;	.word	$1406 
;	.word	$C029 
;	.word	$1409
;    .word	$C04B 
;	.word	$140B
;	.word	$C0EA 
;	.word	$140D 
;	.word	$C108
;	.word	$140F
;	.word	$C123
;	.word	$1431
;    .word	$C1E1 
;	.word	$1411
;	.word	$C328
;	.word	$1413
;	.word	$C395
;	.word	$1415
;	.word	$C57B 
;	.word	$1417
;    .word	$C5DB
;	.word	$1433 
;	.word	$C638 
;	.word	$1425 
;	.word	$C6DB 
;	.word	$1427
;	.word	$CE19
;	.word	$1435
;    .word	$C81A
;	.word	$1419 
;	.word	$CA00 
;	.word	$141B
;	.word	$CAD6 
;	.word	$141D 
;	.word	$CBBA 
;	.word	$141F
;    .word	$CE80 
;	.word	$1421
;	.word	$CCD3 
;	.word	$1423
;	.word	$CD22
;	.word	$142F
;	.word	$C7E5 
;	.word	$1429
;    .word	$CF81 
;	.word	$142B
;	.word	$CFD0
;	.word	$142D
;	.word	$0000 