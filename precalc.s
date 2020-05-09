
; Optimizing the BPL away is not worth it.
; A branch takes 2 or 3 cycles, but setting it up with self modifying code
; is at least 10 times that. So it's worth only for tall lines.

	BVC early_out_p1_1_skip	; always taken
early_out_p1_1:
	RTS
early_out_p1_1_skip:


line0:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2000 + $0,X	; 4+
        STA $2000 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
pcsm0:
        BMI early_out_p1_1

line1:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2000 + $400,X	; 4+
        STA $2000 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_1

line2:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2000 + $800,X	; 4+
        STA $2000 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_1

line3:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2000 + $C00,X	; 4+
        STA $2000 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_1

line4:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2000 + $1000,X	; 4+
        STA $2000 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_1

line5:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2000 + $1400,X	; 4+
        STA $2000 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_1

line6:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2000 + $1800,X	; 4+
        STA $2000 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_1

line7:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2000 + $1C00,X	; 4+
        STA $2000 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_1

line8:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2080 + $0,X	; 4+
        STA $2080 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_1

line9:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2080 + $400,X	; 4+
        STA $2080 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_1

line10:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2080 + $800,X	; 4+
        STA $2080 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_1

	BVC early_out_p1_2_skip	; always taken
early_out_p1_2:
	RTS
early_out_p1_2_skip:


line11:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2080 + $C00,X	; 4+
        STA $2080 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_2

line12:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2080 + $1000,X	; 4+
        STA $2080 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_2

line13:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2080 + $1400,X	; 4+
        STA $2080 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_2

line14:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2080 + $1800,X	; 4+
        STA $2080 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_2

line15:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2080 + $1C00,X	; 4+
        STA $2080 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_2

line16:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2100 + $0,X	; 4+
        STA $2100 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_2

line17:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2100 + $400,X	; 4+
        STA $2100 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_2

line18:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2100 + $800,X	; 4+
        STA $2100 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_2

line19:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2100 + $C00,X	; 4+
        STA $2100 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_2

line20:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2100 + $1000,X	; 4+
        STA $2100 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_2

line21:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2100 + $1400,X	; 4+
        STA $2100 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_2

	BVC early_out_p1_3_skip	; always taken
early_out_p1_3:
	RTS
early_out_p1_3_skip:


line22:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2100 + $1800,X	; 4+
        STA $2100 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_3

line23:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2100 + $1C00,X	; 4+
        STA $2100 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_3

line24:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2180 + $0,X	; 4+
        STA $2180 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_3

line25:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2180 + $400,X	; 4+
        STA $2180 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_3

line26:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2180 + $800,X	; 4+
        STA $2180 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_3

line27:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2180 + $C00,X	; 4+
        STA $2180 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_3

line28:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2180 + $1000,X	; 4+
        STA $2180 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_3

line29:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2180 + $1400,X	; 4+
        STA $2180 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_3

line30:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2180 + $1800,X	; 4+
        STA $2180 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_3

line31:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2180 + $1C00,X	; 4+
        STA $2180 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_3

line32:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2200 + $0,X	; 4+
        STA $2200 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_3

	BVC early_out_p1_4_skip	; always taken
early_out_p1_4:
	RTS
early_out_p1_4_skip:


line33:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2200 + $400,X	; 4+
        STA $2200 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_4

line34:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2200 + $800,X	; 4+
        STA $2200 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_4

line35:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2200 + $C00,X	; 4+
        STA $2200 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_4

line36:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2200 + $1000,X	; 4+
        STA $2200 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_4

line37:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2200 + $1400,X	; 4+
        STA $2200 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_4

line38:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2200 + $1800,X	; 4+
        STA $2200 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_4

line39:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2200 + $1C00,X	; 4+
        STA $2200 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_4

line40:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2280 + $0,X	; 4+
        STA $2280 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_4

line41:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2280 + $400,X	; 4+
        STA $2280 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_4

line42:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2280 + $800,X	; 4+
        STA $2280 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_4

line43:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2280 + $C00,X	; 4+
        STA $2280 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_4

	BVC early_out_p1_5_skip	; always taken
early_out_p1_5:
	RTS
early_out_p1_5_skip:


line44:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2280 + $1000,X	; 4+
        STA $2280 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_5

line45:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2280 + $1400,X	; 4+
        STA $2280 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_5

line46:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2280 + $1800,X	; 4+
        STA $2280 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_5

line47:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2280 + $1C00,X	; 4+
        STA $2280 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_5

line48:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2300 + $0,X	; 4+
        STA $2300 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_5

line49:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2300 + $400,X	; 4+
        STA $2300 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_5

line50:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2300 + $800,X	; 4+
        STA $2300 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_5

line51:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2300 + $C00,X	; 4+
        STA $2300 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_5

line52:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2300 + $1000,X	; 4+
        STA $2300 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_5

line53:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2300 + $1400,X	; 4+
        STA $2300 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_5

line54:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2300 + $1800,X	; 4+
        STA $2300 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_5

	BVC early_out_p1_6_skip	; always taken
early_out_p1_6:
	RTS
early_out_p1_6_skip:


line55:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2300 + $1C00,X	; 4+
        STA $2300 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_6

line56:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2380 + $0,X	; 4+
        STA $2380 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_6

line57:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2380 + $400,X	; 4+
        STA $2380 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_6

line58:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2380 + $800,X	; 4+
        STA $2380 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_6

line59:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2380 + $C00,X	; 4+
        STA $2380 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_6

line60:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2380 + $1000,X	; 4+
        STA $2380 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_6

line61:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2380 + $1400,X	; 4+
        STA $2380 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_6

line62:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2380 + $1800,X	; 4+
        STA $2380 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_6

line63:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2380 + $1C00,X	; 4+
        STA $2380 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_6

line64:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2028 + $0,X	; 4+
        STA $2028 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_6

line65:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2028 + $400,X	; 4+
        STA $2028 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_6

	BVC early_out_p1_7_skip	; always taken
early_out_p1_7:
	RTS
early_out_p1_7_skip:


line66:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2028 + $800,X	; 4+
        STA $2028 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_7

line67:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2028 + $C00,X	; 4+
        STA $2028 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_7

line68:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2028 + $1000,X	; 4+
        STA $2028 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_7

line69:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2028 + $1400,X	; 4+
        STA $2028 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_7

line70:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2028 + $1800,X	; 4+
        STA $2028 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_7

line71:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2028 + $1C00,X	; 4+
        STA $2028 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_7

line72:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $20A8 + $0,X	; 4+
        STA $20A8 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_7

line73:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $20A8 + $400,X	; 4+
        STA $20A8 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_7

line74:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $20A8 + $800,X	; 4+
        STA $20A8 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_7

line75:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $20A8 + $C00,X	; 4+
        STA $20A8 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_7

line76:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $20A8 + $1000,X	; 4+
        STA $20A8 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_7

	BVC early_out_p1_8_skip	; always taken
early_out_p1_8:
	RTS
early_out_p1_8_skip:


line77:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $20A8 + $1400,X	; 4+
        STA $20A8 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_8

line78:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $20A8 + $1800,X	; 4+
        STA $20A8 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_8

line79:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $20A8 + $1C00,X	; 4+
        STA $20A8 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_8

line80:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2128 + $0,X	; 4+
        STA $2128 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_8

line81:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2128 + $400,X	; 4+
        STA $2128 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_8

line82:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2128 + $800,X	; 4+
        STA $2128 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_8

line83:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2128 + $C00,X	; 4+
        STA $2128 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_8

line84:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2128 + $1000,X	; 4+
        STA $2128 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_8

line85:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2128 + $1400,X	; 4+
        STA $2128 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_8

line86:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2128 + $1800,X	; 4+
        STA $2128 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_8

line87:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2128 + $1C00,X	; 4+
        STA $2128 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_8

	BVC early_out_p1_9_skip	; always taken
early_out_p1_9:
	RTS
early_out_p1_9_skip:


line88:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $21A8 + $0,X	; 4+
        STA $21A8 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_9

line89:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $21A8 + $400,X	; 4+
        STA $21A8 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_9

line90:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $21A8 + $800,X	; 4+
        STA $21A8 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_9

line91:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $21A8 + $C00,X	; 4+
        STA $21A8 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_9

line92:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $21A8 + $1000,X	; 4+
        STA $21A8 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_9

line93:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $21A8 + $1400,X	; 4+
        STA $21A8 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_9

line94:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $21A8 + $1800,X	; 4+
        STA $21A8 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_9

line95:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $21A8 + $1C00,X	; 4+
        STA $21A8 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_9

line96:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2228 + $0,X	; 4+
        STA $2228 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_9

line97:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2228 + $400,X	; 4+
        STA $2228 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_9

line98:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2228 + $800,X	; 4+
        STA $2228 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_9

	BVC early_out_p1_10_skip	; always taken
early_out_p1_10:
	RTS
early_out_p1_10_skip:


line99:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2228 + $C00,X	; 4+
        STA $2228 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_10

line100:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2228 + $1000,X	; 4+
        STA $2228 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_10

line101:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2228 + $1400,X	; 4+
        STA $2228 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_10

line102:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2228 + $1800,X	; 4+
        STA $2228 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_10

line103:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2228 + $1C00,X	; 4+
        STA $2228 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_10

line104:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $22A8 + $0,X	; 4+
        STA $22A8 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_10

line105:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $22A8 + $400,X	; 4+
        STA $22A8 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_10

line106:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $22A8 + $800,X	; 4+
        STA $22A8 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_10

line107:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $22A8 + $C00,X	; 4+
        STA $22A8 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_10

line108:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $22A8 + $1000,X	; 4+
        STA $22A8 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_10

line109:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $22A8 + $1400,X	; 4+
        STA $22A8 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_10

	BVC early_out_p1_11_skip	; always taken
early_out_p1_11:
	RTS
early_out_p1_11_skip:


line110:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $22A8 + $1800,X	; 4+
        STA $22A8 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_11

line111:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $22A8 + $1C00,X	; 4+
        STA $22A8 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_11

line112:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2328 + $0,X	; 4+
        STA $2328 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_11

line113:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2328 + $400,X	; 4+
        STA $2328 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_11

line114:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2328 + $800,X	; 4+
        STA $2328 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_11

line115:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2328 + $C00,X	; 4+
        STA $2328 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_11

line116:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2328 + $1000,X	; 4+
        STA $2328 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_11

line117:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2328 + $1400,X	; 4+
        STA $2328 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_11

line118:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2328 + $1800,X	; 4+
        STA $2328 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_11

line119:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2328 + $1C00,X	; 4+
        STA $2328 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_11

line120:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $23A8 + $0,X	; 4+
        STA $23A8 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_11

	BVC early_out_p1_12_skip	; always taken
early_out_p1_12:
	RTS
early_out_p1_12_skip:


line121:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $23A8 + $400,X	; 4+
        STA $23A8 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_12

line122:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $23A8 + $800,X	; 4+
        STA $23A8 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_12

line123:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $23A8 + $C00,X	; 4+
        STA $23A8 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_12

line124:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $23A8 + $1000,X	; 4+
        STA $23A8 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_12

line125:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $23A8 + $1400,X	; 4+
        STA $23A8 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_12

line126:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $23A8 + $1800,X	; 4+
        STA $23A8 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_12

line127:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $23A8 + $1C00,X	; 4+
        STA $23A8 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_12

line128:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2050 + $0,X	; 4+
        STA $2050 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_12

line129:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2050 + $400,X	; 4+
        STA $2050 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_12

line130:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2050 + $800,X	; 4+
        STA $2050 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_12

line131:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2050 + $C00,X	; 4+
        STA $2050 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_12

	BVC early_out_p1_13_skip	; always taken
early_out_p1_13:
	RTS
early_out_p1_13_skip:


line132:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2050 + $1000,X	; 4+
        STA $2050 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_13

line133:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2050 + $1400,X	; 4+
        STA $2050 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_13

line134:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2050 + $1800,X	; 4+
        STA $2050 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_13

line135:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2050 + $1C00,X	; 4+
        STA $2050 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_13

line136:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $20D0 + $0,X	; 4+
        STA $20D0 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_13

line137:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $20D0 + $400,X	; 4+
        STA $20D0 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_13

line138:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $20D0 + $800,X	; 4+
        STA $20D0 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_13

line139:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $20D0 + $C00,X	; 4+
        STA $20D0 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_13

line140:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $20D0 + $1000,X	; 4+
        STA $20D0 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_13

line141:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $20D0 + $1400,X	; 4+
        STA $20D0 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_13

line142:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $20D0 + $1800,X	; 4+
        STA $20D0 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_13

	BVC early_out_p1_14_skip	; always taken
early_out_p1_14:
	RTS
early_out_p1_14_skip:


line143:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $20D0 + $1C00,X	; 4+
        STA $20D0 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_14

line144:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2150 + $0,X	; 4+
        STA $2150 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_14

line145:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2150 + $400,X	; 4+
        STA $2150 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_14

line146:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2150 + $800,X	; 4+
        STA $2150 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_14

line147:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2150 + $C00,X	; 4+
        STA $2150 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_14

line148:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2150 + $1000,X	; 4+
        STA $2150 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_14

line149:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2150 + $1400,X	; 4+
        STA $2150 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_14

line150:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2150 + $1800,X	; 4+
        STA $2150 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_14

line151:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2150 + $1C00,X	; 4+
        STA $2150 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_14

line152:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $21D0 + $0,X	; 4+
        STA $21D0 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_14

line153:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $21D0 + $400,X	; 4+
        STA $21D0 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_14

	BVC early_out_p1_15_skip	; always taken
early_out_p1_15:
	RTS
early_out_p1_15_skip:


line154:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $21D0 + $800,X	; 4+
        STA $21D0 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_15

line155:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $21D0 + $C00,X	; 4+
        STA $21D0 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_15

line156:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $21D0 + $1000,X	; 4+
        STA $21D0 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_15

line157:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $21D0 + $1400,X	; 4+
        STA $21D0 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_15

line158:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $21D0 + $1800,X	; 4+
        STA $21D0 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_15

line159:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $21D0 + $1C00,X	; 4+
        STA $21D0 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_15

line160:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2250 + $0,X	; 4+
        STA $2250 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_15

line161:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2250 + $400,X	; 4+
        STA $2250 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_15

line162:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2250 + $800,X	; 4+
        STA $2250 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_15

line163:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2250 + $C00,X	; 4+
        STA $2250 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_15

line164:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2250 + $1000,X	; 4+
        STA $2250 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_15

	BVC early_out_p1_16_skip	; always taken
early_out_p1_16:
	RTS
early_out_p1_16_skip:


line165:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2250 + $1400,X	; 4+
        STA $2250 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_16

line166:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2250 + $1800,X	; 4+
        STA $2250 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_16

line167:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2250 + $1C00,X	; 4+
        STA $2250 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_16

line168:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $22D0 + $0,X	; 4+
        STA $22D0 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_16

line169:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $22D0 + $400,X	; 4+
        STA $22D0 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_16

line170:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $22D0 + $800,X	; 4+
        STA $22D0 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_16

line171:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $22D0 + $C00,X	; 4+
        STA $22D0 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_16

line172:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $22D0 + $1000,X	; 4+
        STA $22D0 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_16

line173:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $22D0 + $1400,X	; 4+
        STA $22D0 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_16

line174:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $22D0 + $1800,X	; 4+
        STA $22D0 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_16

line175:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $22D0 + $1C00,X	; 4+
        STA $22D0 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_16

	BVC early_out_p1_17_skip	; always taken
early_out_p1_17:
	RTS
early_out_p1_17_skip:


line176:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2350 + $0,X	; 4+
        STA $2350 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_17

line177:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2350 + $400,X	; 4+
        STA $2350 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_17

line178:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2350 + $800,X	; 4+
        STA $2350 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_17

line179:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2350 + $C00,X	; 4+
        STA $2350 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_17

line180:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2350 + $1000,X	; 4+
        STA $2350 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_17

line181:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2350 + $1400,X	; 4+
        STA $2350 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_17

line182:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2350 + $1800,X	; 4+
        STA $2350 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_17

line183:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $2350 + $1C00,X	; 4+
        STA $2350 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_17

line184:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $23D0 + $0,X	; 4+
        STA $23D0 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_17

line185:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $23D0 + $400,X	; 4+
        STA $23D0 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_17

line186:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $23D0 + $800,X	; 4+
        STA $23D0 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_17

	BVC early_out_p1_18_skip	; always taken
early_out_p1_18:
	RTS
early_out_p1_18_skip:


line187:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $23D0 + $C00,X	; 4+
        STA $23D0 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_18

line188:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $23D0 + $1000,X	; 4+
        STA $23D0 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_18

line189:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $23D0 + $1400,X	; 4+
        STA $23D0 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_18

line190:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $23D0 + $1800,X	; 4+
        STA $23D0 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_18

line191:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $23D0 + $1C00,X	; 4+
        STA $23D0 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p1_18
	RTS
line_ptrs_lo:
	.byte <line0	; 0
	.byte <line1	; 1
	.byte <line2	; 2
	.byte <line3	; 3
	.byte <line4	; 4
	.byte <line5	; 5
	.byte <line6	; 6
	.byte <line7	; 7
	.byte <line8	; 8
	.byte <line9	; 9
	.byte <line10	; 10
	.byte <line11	; 11
	.byte <line12	; 12
	.byte <line13	; 13
	.byte <line14	; 14
	.byte <line15	; 15
	.byte <line16	; 16
	.byte <line17	; 17
	.byte <line18	; 18
	.byte <line19	; 19
	.byte <line20	; 20
	.byte <line21	; 21
	.byte <line22	; 22
	.byte <line23	; 23
	.byte <line24	; 24
	.byte <line25	; 25
	.byte <line26	; 26
	.byte <line27	; 27
	.byte <line28	; 28
	.byte <line29	; 29
	.byte <line30	; 30
	.byte <line31	; 31
	.byte <line32	; 32
	.byte <line33	; 33
	.byte <line34	; 34
	.byte <line35	; 35
	.byte <line36	; 36
	.byte <line37	; 37
	.byte <line38	; 38
	.byte <line39	; 39
	.byte <line40	; 40
	.byte <line41	; 41
	.byte <line42	; 42
	.byte <line43	; 43
	.byte <line44	; 44
	.byte <line45	; 45
	.byte <line46	; 46
	.byte <line47	; 47
	.byte <line48	; 48
	.byte <line49	; 49
	.byte <line50	; 50
	.byte <line51	; 51
	.byte <line52	; 52
	.byte <line53	; 53
	.byte <line54	; 54
	.byte <line55	; 55
	.byte <line56	; 56
	.byte <line57	; 57
	.byte <line58	; 58
	.byte <line59	; 59
	.byte <line60	; 60
	.byte <line61	; 61
	.byte <line62	; 62
	.byte <line63	; 63
	.byte <line64	; 64
	.byte <line65	; 65
	.byte <line66	; 66
	.byte <line67	; 67
	.byte <line68	; 68
	.byte <line69	; 69
	.byte <line70	; 70
	.byte <line71	; 71
	.byte <line72	; 72
	.byte <line73	; 73
	.byte <line74	; 74
	.byte <line75	; 75
	.byte <line76	; 76
	.byte <line77	; 77
	.byte <line78	; 78
	.byte <line79	; 79
	.byte <line80	; 80
	.byte <line81	; 81
	.byte <line82	; 82
	.byte <line83	; 83
	.byte <line84	; 84
	.byte <line85	; 85
	.byte <line86	; 86
	.byte <line87	; 87
	.byte <line88	; 88
	.byte <line89	; 89
	.byte <line90	; 90
	.byte <line91	; 91
	.byte <line92	; 92
	.byte <line93	; 93
	.byte <line94	; 94
	.byte <line95	; 95
	.byte <line96	; 96
	.byte <line97	; 97
	.byte <line98	; 98
	.byte <line99	; 99
	.byte <line100	; 100
	.byte <line101	; 101
	.byte <line102	; 102
	.byte <line103	; 103
	.byte <line104	; 104
	.byte <line105	; 105
	.byte <line106	; 106
	.byte <line107	; 107
	.byte <line108	; 108
	.byte <line109	; 109
	.byte <line110	; 110
	.byte <line111	; 111
	.byte <line112	; 112
	.byte <line113	; 113
	.byte <line114	; 114
	.byte <line115	; 115
	.byte <line116	; 116
	.byte <line117	; 117
	.byte <line118	; 118
	.byte <line119	; 119
	.byte <line120	; 120
	.byte <line121	; 121
	.byte <line122	; 122
	.byte <line123	; 123
	.byte <line124	; 124
	.byte <line125	; 125
	.byte <line126	; 126
	.byte <line127	; 127
	.byte <line128	; 128
	.byte <line129	; 129
	.byte <line130	; 130
	.byte <line131	; 131
	.byte <line132	; 132
	.byte <line133	; 133
	.byte <line134	; 134
	.byte <line135	; 135
	.byte <line136	; 136
	.byte <line137	; 137
	.byte <line138	; 138
	.byte <line139	; 139
	.byte <line140	; 140
	.byte <line141	; 141
	.byte <line142	; 142
	.byte <line143	; 143
	.byte <line144	; 144
	.byte <line145	; 145
	.byte <line146	; 146
	.byte <line147	; 147
	.byte <line148	; 148
	.byte <line149	; 149
	.byte <line150	; 150
	.byte <line151	; 151
	.byte <line152	; 152
	.byte <line153	; 153
	.byte <line154	; 154
	.byte <line155	; 155
	.byte <line156	; 156
	.byte <line157	; 157
	.byte <line158	; 158
	.byte <line159	; 159
	.byte <line160	; 160
	.byte <line161	; 161
	.byte <line162	; 162
	.byte <line163	; 163
	.byte <line164	; 164
	.byte <line165	; 165
	.byte <line166	; 166
	.byte <line167	; 167
	.byte <line168	; 168
	.byte <line169	; 169
	.byte <line170	; 170
	.byte <line171	; 171
	.byte <line172	; 172
	.byte <line173	; 173
	.byte <line174	; 174
	.byte <line175	; 175
	.byte <line176	; 176
	.byte <line177	; 177
	.byte <line178	; 178
	.byte <line179	; 179
	.byte <line180	; 180
	.byte <line181	; 181
	.byte <line182	; 182
	.byte <line183	; 183
	.byte <line184	; 184
	.byte <line185	; 185
	.byte <line186	; 186
	.byte <line187	; 187
	.byte <line188	; 188
	.byte <line189	; 189
	.byte <line190	; 190
	.byte <line191	; 191
line_ptrs_hi:
	.byte >line0	; 0
	.byte >line1	; 1
	.byte >line2	; 2
	.byte >line3	; 3
	.byte >line4	; 4
	.byte >line5	; 5
	.byte >line6	; 6
	.byte >line7	; 7
	.byte >line8	; 8
	.byte >line9	; 9
	.byte >line10	; 10
	.byte >line11	; 11
	.byte >line12	; 12
	.byte >line13	; 13
	.byte >line14	; 14
	.byte >line15	; 15
	.byte >line16	; 16
	.byte >line17	; 17
	.byte >line18	; 18
	.byte >line19	; 19
	.byte >line20	; 20
	.byte >line21	; 21
	.byte >line22	; 22
	.byte >line23	; 23
	.byte >line24	; 24
	.byte >line25	; 25
	.byte >line26	; 26
	.byte >line27	; 27
	.byte >line28	; 28
	.byte >line29	; 29
	.byte >line30	; 30
	.byte >line31	; 31
	.byte >line32	; 32
	.byte >line33	; 33
	.byte >line34	; 34
	.byte >line35	; 35
	.byte >line36	; 36
	.byte >line37	; 37
	.byte >line38	; 38
	.byte >line39	; 39
	.byte >line40	; 40
	.byte >line41	; 41
	.byte >line42	; 42
	.byte >line43	; 43
	.byte >line44	; 44
	.byte >line45	; 45
	.byte >line46	; 46
	.byte >line47	; 47
	.byte >line48	; 48
	.byte >line49	; 49
	.byte >line50	; 50
	.byte >line51	; 51
	.byte >line52	; 52
	.byte >line53	; 53
	.byte >line54	; 54
	.byte >line55	; 55
	.byte >line56	; 56
	.byte >line57	; 57
	.byte >line58	; 58
	.byte >line59	; 59
	.byte >line60	; 60
	.byte >line61	; 61
	.byte >line62	; 62
	.byte >line63	; 63
	.byte >line64	; 64
	.byte >line65	; 65
	.byte >line66	; 66
	.byte >line67	; 67
	.byte >line68	; 68
	.byte >line69	; 69
	.byte >line70	; 70
	.byte >line71	; 71
	.byte >line72	; 72
	.byte >line73	; 73
	.byte >line74	; 74
	.byte >line75	; 75
	.byte >line76	; 76
	.byte >line77	; 77
	.byte >line78	; 78
	.byte >line79	; 79
	.byte >line80	; 80
	.byte >line81	; 81
	.byte >line82	; 82
	.byte >line83	; 83
	.byte >line84	; 84
	.byte >line85	; 85
	.byte >line86	; 86
	.byte >line87	; 87
	.byte >line88	; 88
	.byte >line89	; 89
	.byte >line90	; 90
	.byte >line91	; 91
	.byte >line92	; 92
	.byte >line93	; 93
	.byte >line94	; 94
	.byte >line95	; 95
	.byte >line96	; 96
	.byte >line97	; 97
	.byte >line98	; 98
	.byte >line99	; 99
	.byte >line100	; 100
	.byte >line101	; 101
	.byte >line102	; 102
	.byte >line103	; 103
	.byte >line104	; 104
	.byte >line105	; 105
	.byte >line106	; 106
	.byte >line107	; 107
	.byte >line108	; 108
	.byte >line109	; 109
	.byte >line110	; 110
	.byte >line111	; 111
	.byte >line112	; 112
	.byte >line113	; 113
	.byte >line114	; 114
	.byte >line115	; 115
	.byte >line116	; 116
	.byte >line117	; 117
	.byte >line118	; 118
	.byte >line119	; 119
	.byte >line120	; 120
	.byte >line121	; 121
	.byte >line122	; 122
	.byte >line123	; 123
	.byte >line124	; 124
	.byte >line125	; 125
	.byte >line126	; 126
	.byte >line127	; 127
	.byte >line128	; 128
	.byte >line129	; 129
	.byte >line130	; 130
	.byte >line131	; 131
	.byte >line132	; 132
	.byte >line133	; 133
	.byte >line134	; 134
	.byte >line135	; 135
	.byte >line136	; 136
	.byte >line137	; 137
	.byte >line138	; 138
	.byte >line139	; 139
	.byte >line140	; 140
	.byte >line141	; 141
	.byte >line142	; 142
	.byte >line143	; 143
	.byte >line144	; 144
	.byte >line145	; 145
	.byte >line146	; 146
	.byte >line147	; 147
	.byte >line148	; 148
	.byte >line149	; 149
	.byte >line150	; 150
	.byte >line151	; 151
	.byte >line152	; 152
	.byte >line153	; 153
	.byte >line154	; 154
	.byte >line155	; 155
	.byte >line156	; 156
	.byte >line157	; 157
	.byte >line158	; 158
	.byte >line159	; 159
	.byte >line160	; 160
	.byte >line161	; 161
	.byte >line162	; 162
	.byte >line163	; 163
	.byte >line164	; 164
	.byte >line165	; 165
	.byte >line166	; 166
	.byte >line167	; 167
	.byte >line168	; 168
	.byte >line169	; 169
	.byte >line170	; 170
	.byte >line171	; 171
	.byte >line172	; 172
	.byte >line173	; 173
	.byte >line174	; 174
	.byte >line175	; 175
	.byte >line176	; 176
	.byte >line177	; 177
	.byte >line178	; 178
	.byte >line179	; 179
	.byte >line180	; 180
	.byte >line181	; 181
	.byte >line182	; 182
	.byte >line183	; 183
	.byte >line184	; 184
	.byte >line185	; 185
	.byte >line186	; 186
	.byte >line187	; 187
	.byte >line188	; 188
	.byte >line189	; 189
	.byte >line190	; 190
	.byte >line191	; 191

; Optimizing the BPL away is not worth it.
; A branch takes 2 or 3 cycles, but setting it up with self modifying code
; is at least 10 times that. So it's worth only for tall lines.
	BVC blank_early_out_p1_1_skip	; always taken
blank_early_out_p1_1:
	RTS
blank_early_out_p1_1_skip:

blank_line0:
	STA $2000 + $0,X
	DEY
blank_pcsm0:
        BMI blank_early_out_p1_1

blank_line1:
	STA $2000 + $400,X
	DEY
blank_pcsm1:
        BMI blank_early_out_p1_1

blank_line2:
	STA $2000 + $800,X
	DEY
blank_pcsm2:
        BMI blank_early_out_p1_1

blank_line3:
	STA $2000 + $C00,X
	DEY
blank_pcsm3:
        BMI blank_early_out_p1_1

blank_line4:
	STA $2000 + $1000,X
	DEY
blank_pcsm4:
        BMI blank_early_out_p1_1

blank_line5:
	STA $2000 + $1400,X
	DEY
blank_pcsm5:
        BMI blank_early_out_p1_1

blank_line6:
	STA $2000 + $1800,X
	DEY
blank_pcsm6:
        BMI blank_early_out_p1_1

blank_line7:
	STA $2000 + $1C00,X
	DEY
blank_pcsm7:
        BMI blank_early_out_p1_1

blank_line8:
	STA $2080 + $0,X
	DEY
blank_pcsm8:
        BMI blank_early_out_p1_1

blank_line9:
	STA $2080 + $400,X
	DEY
blank_pcsm9:
        BMI blank_early_out_p1_1

blank_line10:
	STA $2080 + $800,X
	DEY
blank_pcsm10:
        BMI blank_early_out_p1_1
	BVC blank_early_out_p1_2_skip	; always taken
blank_early_out_p1_2:
	RTS
blank_early_out_p1_2_skip:

blank_line11:
	STA $2080 + $C00,X
	DEY
blank_pcsm11:
        BMI blank_early_out_p1_2

blank_line12:
	STA $2080 + $1000,X
	DEY
blank_pcsm12:
        BMI blank_early_out_p1_2

blank_line13:
	STA $2080 + $1400,X
	DEY
blank_pcsm13:
        BMI blank_early_out_p1_2

blank_line14:
	STA $2080 + $1800,X
	DEY
blank_pcsm14:
        BMI blank_early_out_p1_2

blank_line15:
	STA $2080 + $1C00,X
	DEY
blank_pcsm15:
        BMI blank_early_out_p1_2

blank_line16:
	STA $2100 + $0,X
	DEY
blank_pcsm16:
        BMI blank_early_out_p1_2

blank_line17:
	STA $2100 + $400,X
	DEY
blank_pcsm17:
        BMI blank_early_out_p1_2

blank_line18:
	STA $2100 + $800,X
	DEY
blank_pcsm18:
        BMI blank_early_out_p1_2

blank_line19:
	STA $2100 + $C00,X
	DEY
blank_pcsm19:
        BMI blank_early_out_p1_2

blank_line20:
	STA $2100 + $1000,X
	DEY
blank_pcsm20:
        BMI blank_early_out_p1_2

blank_line21:
	STA $2100 + $1400,X
	DEY
blank_pcsm21:
        BMI blank_early_out_p1_2
	BVC blank_early_out_p1_3_skip	; always taken
blank_early_out_p1_3:
	RTS
blank_early_out_p1_3_skip:

blank_line22:
	STA $2100 + $1800,X
	DEY
blank_pcsm22:
        BMI blank_early_out_p1_3

blank_line23:
	STA $2100 + $1C00,X
	DEY
blank_pcsm23:
        BMI blank_early_out_p1_3

blank_line24:
	STA $2180 + $0,X
	DEY
blank_pcsm24:
        BMI blank_early_out_p1_3

blank_line25:
	STA $2180 + $400,X
	DEY
blank_pcsm25:
        BMI blank_early_out_p1_3

blank_line26:
	STA $2180 + $800,X
	DEY
blank_pcsm26:
        BMI blank_early_out_p1_3

blank_line27:
	STA $2180 + $C00,X
	DEY
blank_pcsm27:
        BMI blank_early_out_p1_3

blank_line28:
	STA $2180 + $1000,X
	DEY
blank_pcsm28:
        BMI blank_early_out_p1_3

blank_line29:
	STA $2180 + $1400,X
	DEY
blank_pcsm29:
        BMI blank_early_out_p1_3

blank_line30:
	STA $2180 + $1800,X
	DEY
blank_pcsm30:
        BMI blank_early_out_p1_3

blank_line31:
	STA $2180 + $1C00,X
	DEY
blank_pcsm31:
        BMI blank_early_out_p1_3

blank_line32:
	STA $2200 + $0,X
	DEY
blank_pcsm32:
        BMI blank_early_out_p1_3
	BVC blank_early_out_p1_4_skip	; always taken
blank_early_out_p1_4:
	RTS
blank_early_out_p1_4_skip:

blank_line33:
	STA $2200 + $400,X
	DEY
blank_pcsm33:
        BMI blank_early_out_p1_4

blank_line34:
	STA $2200 + $800,X
	DEY
blank_pcsm34:
        BMI blank_early_out_p1_4

blank_line35:
	STA $2200 + $C00,X
	DEY
blank_pcsm35:
        BMI blank_early_out_p1_4

blank_line36:
	STA $2200 + $1000,X
	DEY
blank_pcsm36:
        BMI blank_early_out_p1_4

blank_line37:
	STA $2200 + $1400,X
	DEY
blank_pcsm37:
        BMI blank_early_out_p1_4

blank_line38:
	STA $2200 + $1800,X
	DEY
blank_pcsm38:
        BMI blank_early_out_p1_4

blank_line39:
	STA $2200 + $1C00,X
	DEY
blank_pcsm39:
        BMI blank_early_out_p1_4

blank_line40:
	STA $2280 + $0,X
	DEY
blank_pcsm40:
        BMI blank_early_out_p1_4

blank_line41:
	STA $2280 + $400,X
	DEY
blank_pcsm41:
        BMI blank_early_out_p1_4

blank_line42:
	STA $2280 + $800,X
	DEY
blank_pcsm42:
        BMI blank_early_out_p1_4

blank_line43:
	STA $2280 + $C00,X
	DEY
blank_pcsm43:
        BMI blank_early_out_p1_4
	BVC blank_early_out_p1_5_skip	; always taken
blank_early_out_p1_5:
	RTS
blank_early_out_p1_5_skip:

blank_line44:
	STA $2280 + $1000,X
	DEY
blank_pcsm44:
        BMI blank_early_out_p1_5

blank_line45:
	STA $2280 + $1400,X
	DEY
blank_pcsm45:
        BMI blank_early_out_p1_5

blank_line46:
	STA $2280 + $1800,X
	DEY
blank_pcsm46:
        BMI blank_early_out_p1_5

blank_line47:
	STA $2280 + $1C00,X
	DEY
blank_pcsm47:
        BMI blank_early_out_p1_5

blank_line48:
	STA $2300 + $0,X
	DEY
blank_pcsm48:
        BMI blank_early_out_p1_5

blank_line49:
	STA $2300 + $400,X
	DEY
blank_pcsm49:
        BMI blank_early_out_p1_5

blank_line50:
	STA $2300 + $800,X
	DEY
blank_pcsm50:
        BMI blank_early_out_p1_5

blank_line51:
	STA $2300 + $C00,X
	DEY
blank_pcsm51:
        BMI blank_early_out_p1_5

blank_line52:
	STA $2300 + $1000,X
	DEY
blank_pcsm52:
        BMI blank_early_out_p1_5

blank_line53:
	STA $2300 + $1400,X
	DEY
blank_pcsm53:
        BMI blank_early_out_p1_5

blank_line54:
	STA $2300 + $1800,X
	DEY
blank_pcsm54:
        BMI blank_early_out_p1_5
	BVC blank_early_out_p1_6_skip	; always taken
blank_early_out_p1_6:
	RTS
blank_early_out_p1_6_skip:

blank_line55:
	STA $2300 + $1C00,X
	DEY
blank_pcsm55:
        BMI blank_early_out_p1_6

blank_line56:
	STA $2380 + $0,X
	DEY
blank_pcsm56:
        BMI blank_early_out_p1_6

blank_line57:
	STA $2380 + $400,X
	DEY
blank_pcsm57:
        BMI blank_early_out_p1_6

blank_line58:
	STA $2380 + $800,X
	DEY
blank_pcsm58:
        BMI blank_early_out_p1_6

blank_line59:
	STA $2380 + $C00,X
	DEY
blank_pcsm59:
        BMI blank_early_out_p1_6

blank_line60:
	STA $2380 + $1000,X
	DEY
blank_pcsm60:
        BMI blank_early_out_p1_6

blank_line61:
	STA $2380 + $1400,X
	DEY
blank_pcsm61:
        BMI blank_early_out_p1_6

blank_line62:
	STA $2380 + $1800,X
	DEY
blank_pcsm62:
        BMI blank_early_out_p1_6

blank_line63:
	STA $2380 + $1C00,X
	DEY
blank_pcsm63:
        BMI blank_early_out_p1_6

blank_line64:
	STA $2028 + $0,X
	DEY
blank_pcsm64:
        BMI blank_early_out_p1_6

blank_line65:
	STA $2028 + $400,X
	DEY
blank_pcsm65:
        BMI blank_early_out_p1_6
	BVC blank_early_out_p1_7_skip	; always taken
blank_early_out_p1_7:
	RTS
blank_early_out_p1_7_skip:

blank_line66:
	STA $2028 + $800,X
	DEY
blank_pcsm66:
        BMI blank_early_out_p1_7

blank_line67:
	STA $2028 + $C00,X
	DEY
blank_pcsm67:
        BMI blank_early_out_p1_7

blank_line68:
	STA $2028 + $1000,X
	DEY
blank_pcsm68:
        BMI blank_early_out_p1_7

blank_line69:
	STA $2028 + $1400,X
	DEY
blank_pcsm69:
        BMI blank_early_out_p1_7

blank_line70:
	STA $2028 + $1800,X
	DEY
blank_pcsm70:
        BMI blank_early_out_p1_7

blank_line71:
	STA $2028 + $1C00,X
	DEY
blank_pcsm71:
        BMI blank_early_out_p1_7

blank_line72:
	STA $20A8 + $0,X
	DEY
blank_pcsm72:
        BMI blank_early_out_p1_7

blank_line73:
	STA $20A8 + $400,X
	DEY
blank_pcsm73:
        BMI blank_early_out_p1_7

blank_line74:
	STA $20A8 + $800,X
	DEY
blank_pcsm74:
        BMI blank_early_out_p1_7

blank_line75:
	STA $20A8 + $C00,X
	DEY
blank_pcsm75:
        BMI blank_early_out_p1_7

blank_line76:
	STA $20A8 + $1000,X
	DEY
blank_pcsm76:
        BMI blank_early_out_p1_7
	BVC blank_early_out_p1_8_skip	; always taken
blank_early_out_p1_8:
	RTS
blank_early_out_p1_8_skip:

blank_line77:
	STA $20A8 + $1400,X
	DEY
blank_pcsm77:
        BMI blank_early_out_p1_8

blank_line78:
	STA $20A8 + $1800,X
	DEY
blank_pcsm78:
        BMI blank_early_out_p1_8

blank_line79:
	STA $20A8 + $1C00,X
	DEY
blank_pcsm79:
        BMI blank_early_out_p1_8

blank_line80:
	STA $2128 + $0,X
	DEY
blank_pcsm80:
        BMI blank_early_out_p1_8

blank_line81:
	STA $2128 + $400,X
	DEY
blank_pcsm81:
        BMI blank_early_out_p1_8

blank_line82:
	STA $2128 + $800,X
	DEY
blank_pcsm82:
        BMI blank_early_out_p1_8

blank_line83:
	STA $2128 + $C00,X
	DEY
blank_pcsm83:
        BMI blank_early_out_p1_8

blank_line84:
	STA $2128 + $1000,X
	DEY
blank_pcsm84:
        BMI blank_early_out_p1_8

blank_line85:
	STA $2128 + $1400,X
	DEY
blank_pcsm85:
        BMI blank_early_out_p1_8

blank_line86:
	STA $2128 + $1800,X
	DEY
blank_pcsm86:
        BMI blank_early_out_p1_8

blank_line87:
	STA $2128 + $1C00,X
	DEY
blank_pcsm87:
        BMI blank_early_out_p1_8
	BVC blank_early_out_p1_9_skip	; always taken
blank_early_out_p1_9:
	RTS
blank_early_out_p1_9_skip:

blank_line88:
	STA $21A8 + $0,X
	DEY
blank_pcsm88:
        BMI blank_early_out_p1_9

blank_line89:
	STA $21A8 + $400,X
	DEY
blank_pcsm89:
        BMI blank_early_out_p1_9

blank_line90:
	STA $21A8 + $800,X
	DEY
blank_pcsm90:
        BMI blank_early_out_p1_9

blank_line91:
	STA $21A8 + $C00,X
	DEY
blank_pcsm91:
        BMI blank_early_out_p1_9

blank_line92:
	STA $21A8 + $1000,X
	DEY
blank_pcsm92:
        BMI blank_early_out_p1_9

blank_line93:
	STA $21A8 + $1400,X
	DEY
blank_pcsm93:
        BMI blank_early_out_p1_9

blank_line94:
	STA $21A8 + $1800,X
	DEY
blank_pcsm94:
        BMI blank_early_out_p1_9

blank_line95:
	STA $21A8 + $1C00,X
	DEY
blank_pcsm95:
        BMI blank_early_out_p1_9

blank_line96:
	STA $2228 + $0,X
	DEY
blank_pcsm96:
        BMI blank_early_out_p1_9

blank_line97:
	STA $2228 + $400,X
	DEY
blank_pcsm97:
        BMI blank_early_out_p1_9

blank_line98:
	STA $2228 + $800,X
	DEY
blank_pcsm98:
        BMI blank_early_out_p1_9
	BVC blank_early_out_p1_10_skip	; always taken
blank_early_out_p1_10:
	RTS
blank_early_out_p1_10_skip:

blank_line99:
	STA $2228 + $C00,X
	DEY
blank_pcsm99:
        BMI blank_early_out_p1_10

blank_line100:
	STA $2228 + $1000,X
	DEY
blank_pcsm100:
        BMI blank_early_out_p1_10

blank_line101:
	STA $2228 + $1400,X
	DEY
blank_pcsm101:
        BMI blank_early_out_p1_10

blank_line102:
	STA $2228 + $1800,X
	DEY
blank_pcsm102:
        BMI blank_early_out_p1_10

blank_line103:
	STA $2228 + $1C00,X
	DEY
blank_pcsm103:
        BMI blank_early_out_p1_10

blank_line104:
	STA $22A8 + $0,X
	DEY
blank_pcsm104:
        BMI blank_early_out_p1_10

blank_line105:
	STA $22A8 + $400,X
	DEY
blank_pcsm105:
        BMI blank_early_out_p1_10

blank_line106:
	STA $22A8 + $800,X
	DEY
blank_pcsm106:
        BMI blank_early_out_p1_10

blank_line107:
	STA $22A8 + $C00,X
	DEY
blank_pcsm107:
        BMI blank_early_out_p1_10

blank_line108:
	STA $22A8 + $1000,X
	DEY
blank_pcsm108:
        BMI blank_early_out_p1_10

blank_line109:
	STA $22A8 + $1400,X
	DEY
blank_pcsm109:
        BMI blank_early_out_p1_10
	BVC blank_early_out_p1_11_skip	; always taken
blank_early_out_p1_11:
	RTS
blank_early_out_p1_11_skip:

blank_line110:
	STA $22A8 + $1800,X
	DEY
blank_pcsm110:
        BMI blank_early_out_p1_11

blank_line111:
	STA $22A8 + $1C00,X
	DEY
blank_pcsm111:
        BMI blank_early_out_p1_11

blank_line112:
	STA $2328 + $0,X
	DEY
blank_pcsm112:
        BMI blank_early_out_p1_11

blank_line113:
	STA $2328 + $400,X
	DEY
blank_pcsm113:
        BMI blank_early_out_p1_11

blank_line114:
	STA $2328 + $800,X
	DEY
blank_pcsm114:
        BMI blank_early_out_p1_11

blank_line115:
	STA $2328 + $C00,X
	DEY
blank_pcsm115:
        BMI blank_early_out_p1_11

blank_line116:
	STA $2328 + $1000,X
	DEY
blank_pcsm116:
        BMI blank_early_out_p1_11

blank_line117:
	STA $2328 + $1400,X
	DEY
blank_pcsm117:
        BMI blank_early_out_p1_11

blank_line118:
	STA $2328 + $1800,X
	DEY
blank_pcsm118:
        BMI blank_early_out_p1_11

blank_line119:
	STA $2328 + $1C00,X
	DEY
blank_pcsm119:
        BMI blank_early_out_p1_11

blank_line120:
	STA $23A8 + $0,X
	DEY
blank_pcsm120:
        BMI blank_early_out_p1_11
	BVC blank_early_out_p1_12_skip	; always taken
blank_early_out_p1_12:
	RTS
blank_early_out_p1_12_skip:

blank_line121:
	STA $23A8 + $400,X
	DEY
blank_pcsm121:
        BMI blank_early_out_p1_12

blank_line122:
	STA $23A8 + $800,X
	DEY
blank_pcsm122:
        BMI blank_early_out_p1_12

blank_line123:
	STA $23A8 + $C00,X
	DEY
blank_pcsm123:
        BMI blank_early_out_p1_12

blank_line124:
	STA $23A8 + $1000,X
	DEY
blank_pcsm124:
        BMI blank_early_out_p1_12

blank_line125:
	STA $23A8 + $1400,X
	DEY
blank_pcsm125:
        BMI blank_early_out_p1_12

blank_line126:
	STA $23A8 + $1800,X
	DEY
blank_pcsm126:
        BMI blank_early_out_p1_12

blank_line127:
	STA $23A8 + $1C00,X
	DEY
blank_pcsm127:
        BMI blank_early_out_p1_12

blank_line128:
	STA $2050 + $0,X
	DEY
blank_pcsm128:
        BMI blank_early_out_p1_12

blank_line129:
	STA $2050 + $400,X
	DEY
blank_pcsm129:
        BMI blank_early_out_p1_12

blank_line130:
	STA $2050 + $800,X
	DEY
blank_pcsm130:
        BMI blank_early_out_p1_12

blank_line131:
	STA $2050 + $C00,X
	DEY
blank_pcsm131:
        BMI blank_early_out_p1_12
	BVC blank_early_out_p1_13_skip	; always taken
blank_early_out_p1_13:
	RTS
blank_early_out_p1_13_skip:

blank_line132:
	STA $2050 + $1000,X
	DEY
blank_pcsm132:
        BMI blank_early_out_p1_13

blank_line133:
	STA $2050 + $1400,X
	DEY
blank_pcsm133:
        BMI blank_early_out_p1_13

blank_line134:
	STA $2050 + $1800,X
	DEY
blank_pcsm134:
        BMI blank_early_out_p1_13

blank_line135:
	STA $2050 + $1C00,X
	DEY
blank_pcsm135:
        BMI blank_early_out_p1_13

blank_line136:
	STA $20D0 + $0,X
	DEY
blank_pcsm136:
        BMI blank_early_out_p1_13

blank_line137:
	STA $20D0 + $400,X
	DEY
blank_pcsm137:
        BMI blank_early_out_p1_13

blank_line138:
	STA $20D0 + $800,X
	DEY
blank_pcsm138:
        BMI blank_early_out_p1_13

blank_line139:
	STA $20D0 + $C00,X
	DEY
blank_pcsm139:
        BMI blank_early_out_p1_13

blank_line140:
	STA $20D0 + $1000,X
	DEY
blank_pcsm140:
        BMI blank_early_out_p1_13

blank_line141:
	STA $20D0 + $1400,X
	DEY
blank_pcsm141:
        BMI blank_early_out_p1_13

blank_line142:
	STA $20D0 + $1800,X
	DEY
blank_pcsm142:
        BMI blank_early_out_p1_13
	BVC blank_early_out_p1_14_skip	; always taken
blank_early_out_p1_14:
	RTS
blank_early_out_p1_14_skip:

blank_line143:
	STA $20D0 + $1C00,X
	DEY
blank_pcsm143:
        BMI blank_early_out_p1_14

blank_line144:
	STA $2150 + $0,X
	DEY
blank_pcsm144:
        BMI blank_early_out_p1_14

blank_line145:
	STA $2150 + $400,X
	DEY
blank_pcsm145:
        BMI blank_early_out_p1_14

blank_line146:
	STA $2150 + $800,X
	DEY
blank_pcsm146:
        BMI blank_early_out_p1_14

blank_line147:
	STA $2150 + $C00,X
	DEY
blank_pcsm147:
        BMI blank_early_out_p1_14

blank_line148:
	STA $2150 + $1000,X
	DEY
blank_pcsm148:
        BMI blank_early_out_p1_14

blank_line149:
	STA $2150 + $1400,X
	DEY
blank_pcsm149:
        BMI blank_early_out_p1_14

blank_line150:
	STA $2150 + $1800,X
	DEY
blank_pcsm150:
        BMI blank_early_out_p1_14

blank_line151:
	STA $2150 + $1C00,X
	DEY
blank_pcsm151:
        BMI blank_early_out_p1_14

blank_line152:
	STA $21D0 + $0,X
	DEY
blank_pcsm152:
        BMI blank_early_out_p1_14

blank_line153:
	STA $21D0 + $400,X
	DEY
blank_pcsm153:
        BMI blank_early_out_p1_14
	BVC blank_early_out_p1_15_skip	; always taken
blank_early_out_p1_15:
	RTS
blank_early_out_p1_15_skip:

blank_line154:
	STA $21D0 + $800,X
	DEY
blank_pcsm154:
        BMI blank_early_out_p1_15

blank_line155:
	STA $21D0 + $C00,X
	DEY
blank_pcsm155:
        BMI blank_early_out_p1_15

blank_line156:
	STA $21D0 + $1000,X
	DEY
blank_pcsm156:
        BMI blank_early_out_p1_15

blank_line157:
	STA $21D0 + $1400,X
	DEY
blank_pcsm157:
        BMI blank_early_out_p1_15

blank_line158:
	STA $21D0 + $1800,X
	DEY
blank_pcsm158:
        BMI blank_early_out_p1_15

blank_line159:
	STA $21D0 + $1C00,X
	DEY
blank_pcsm159:
        BMI blank_early_out_p1_15

blank_line160:
	STA $2250 + $0,X
	DEY
blank_pcsm160:
        BMI blank_early_out_p1_15

blank_line161:
	STA $2250 + $400,X
	DEY
blank_pcsm161:
        BMI blank_early_out_p1_15

blank_line162:
	STA $2250 + $800,X
	DEY
blank_pcsm162:
        BMI blank_early_out_p1_15

blank_line163:
	STA $2250 + $C00,X
	DEY
blank_pcsm163:
        BMI blank_early_out_p1_15

blank_line164:
	STA $2250 + $1000,X
	DEY
blank_pcsm164:
        BMI blank_early_out_p1_15
	BVC blank_early_out_p1_16_skip	; always taken
blank_early_out_p1_16:
	RTS
blank_early_out_p1_16_skip:

blank_line165:
	STA $2250 + $1400,X
	DEY
blank_pcsm165:
        BMI blank_early_out_p1_16

blank_line166:
	STA $2250 + $1800,X
	DEY
blank_pcsm166:
        BMI blank_early_out_p1_16

blank_line167:
	STA $2250 + $1C00,X
	DEY
blank_pcsm167:
        BMI blank_early_out_p1_16

blank_line168:
	STA $22D0 + $0,X
	DEY
blank_pcsm168:
        BMI blank_early_out_p1_16

blank_line169:
	STA $22D0 + $400,X
	DEY
blank_pcsm169:
        BMI blank_early_out_p1_16

blank_line170:
	STA $22D0 + $800,X
	DEY
blank_pcsm170:
        BMI blank_early_out_p1_16

blank_line171:
	STA $22D0 + $C00,X
	DEY
blank_pcsm171:
        BMI blank_early_out_p1_16

blank_line172:
	STA $22D0 + $1000,X
	DEY
blank_pcsm172:
        BMI blank_early_out_p1_16

blank_line173:
	STA $22D0 + $1400,X
	DEY
blank_pcsm173:
        BMI blank_early_out_p1_16

blank_line174:
	STA $22D0 + $1800,X
	DEY
blank_pcsm174:
        BMI blank_early_out_p1_16

blank_line175:
	STA $22D0 + $1C00,X
	DEY
blank_pcsm175:
        BMI blank_early_out_p1_16
	BVC blank_early_out_p1_17_skip	; always taken
blank_early_out_p1_17:
	RTS
blank_early_out_p1_17_skip:

blank_line176:
	STA $2350 + $0,X
	DEY
blank_pcsm176:
        BMI blank_early_out_p1_17

blank_line177:
	STA $2350 + $400,X
	DEY
blank_pcsm177:
        BMI blank_early_out_p1_17

blank_line178:
	STA $2350 + $800,X
	DEY
blank_pcsm178:
        BMI blank_early_out_p1_17

blank_line179:
	STA $2350 + $C00,X
	DEY
blank_pcsm179:
        BMI blank_early_out_p1_17

blank_line180:
	STA $2350 + $1000,X
	DEY
blank_pcsm180:
        BMI blank_early_out_p1_17

blank_line181:
	STA $2350 + $1400,X
	DEY
blank_pcsm181:
        BMI blank_early_out_p1_17

blank_line182:
	STA $2350 + $1800,X
	DEY
blank_pcsm182:
        BMI blank_early_out_p1_17

blank_line183:
	STA $2350 + $1C00,X
	DEY
blank_pcsm183:
        BMI blank_early_out_p1_17

blank_line184:
	STA $23D0 + $0,X
	DEY
blank_pcsm184:
        BMI blank_early_out_p1_17

blank_line185:
	STA $23D0 + $400,X
	DEY
blank_pcsm185:
        BMI blank_early_out_p1_17

blank_line186:
	STA $23D0 + $800,X
	DEY
blank_pcsm186:
        BMI blank_early_out_p1_17
	BVC blank_early_out_p1_18_skip	; always taken
blank_early_out_p1_18:
	RTS
blank_early_out_p1_18_skip:

blank_line187:
	STA $23D0 + $C00,X
	DEY
blank_pcsm187:
        BMI blank_early_out_p1_18

blank_line188:
	STA $23D0 + $1000,X
	DEY
blank_pcsm188:
        BMI blank_early_out_p1_18

blank_line189:
	STA $23D0 + $1400,X
	DEY
blank_pcsm189:
        BMI blank_early_out_p1_18

blank_line190:
	STA $23D0 + $1800,X
	DEY
blank_pcsm190:
        BMI blank_early_out_p1_18

blank_line191:
	STA $23D0 + $1C00,X
	DEY
blank_pcsm191:
        BMI blank_early_out_p1_18
	RTS
blank_line_ptrs_lo:
	.byte <blank_line0	; 0
	.byte <blank_line1	; 1
	.byte <blank_line2	; 2
	.byte <blank_line3	; 3
	.byte <blank_line4	; 4
	.byte <blank_line5	; 5
	.byte <blank_line6	; 6
	.byte <blank_line7	; 7
	.byte <blank_line8	; 8
	.byte <blank_line9	; 9
	.byte <blank_line10	; 10
	.byte <blank_line11	; 11
	.byte <blank_line12	; 12
	.byte <blank_line13	; 13
	.byte <blank_line14	; 14
	.byte <blank_line15	; 15
	.byte <blank_line16	; 16
	.byte <blank_line17	; 17
	.byte <blank_line18	; 18
	.byte <blank_line19	; 19
	.byte <blank_line20	; 20
	.byte <blank_line21	; 21
	.byte <blank_line22	; 22
	.byte <blank_line23	; 23
	.byte <blank_line24	; 24
	.byte <blank_line25	; 25
	.byte <blank_line26	; 26
	.byte <blank_line27	; 27
	.byte <blank_line28	; 28
	.byte <blank_line29	; 29
	.byte <blank_line30	; 30
	.byte <blank_line31	; 31
	.byte <blank_line32	; 32
	.byte <blank_line33	; 33
	.byte <blank_line34	; 34
	.byte <blank_line35	; 35
	.byte <blank_line36	; 36
	.byte <blank_line37	; 37
	.byte <blank_line38	; 38
	.byte <blank_line39	; 39
	.byte <blank_line40	; 40
	.byte <blank_line41	; 41
	.byte <blank_line42	; 42
	.byte <blank_line43	; 43
	.byte <blank_line44	; 44
	.byte <blank_line45	; 45
	.byte <blank_line46	; 46
	.byte <blank_line47	; 47
	.byte <blank_line48	; 48
	.byte <blank_line49	; 49
	.byte <blank_line50	; 50
	.byte <blank_line51	; 51
	.byte <blank_line52	; 52
	.byte <blank_line53	; 53
	.byte <blank_line54	; 54
	.byte <blank_line55	; 55
	.byte <blank_line56	; 56
	.byte <blank_line57	; 57
	.byte <blank_line58	; 58
	.byte <blank_line59	; 59
	.byte <blank_line60	; 60
	.byte <blank_line61	; 61
	.byte <blank_line62	; 62
	.byte <blank_line63	; 63
	.byte <blank_line64	; 64
	.byte <blank_line65	; 65
	.byte <blank_line66	; 66
	.byte <blank_line67	; 67
	.byte <blank_line68	; 68
	.byte <blank_line69	; 69
	.byte <blank_line70	; 70
	.byte <blank_line71	; 71
	.byte <blank_line72	; 72
	.byte <blank_line73	; 73
	.byte <blank_line74	; 74
	.byte <blank_line75	; 75
	.byte <blank_line76	; 76
	.byte <blank_line77	; 77
	.byte <blank_line78	; 78
	.byte <blank_line79	; 79
	.byte <blank_line80	; 80
	.byte <blank_line81	; 81
	.byte <blank_line82	; 82
	.byte <blank_line83	; 83
	.byte <blank_line84	; 84
	.byte <blank_line85	; 85
	.byte <blank_line86	; 86
	.byte <blank_line87	; 87
	.byte <blank_line88	; 88
	.byte <blank_line89	; 89
	.byte <blank_line90	; 90
	.byte <blank_line91	; 91
	.byte <blank_line92	; 92
	.byte <blank_line93	; 93
	.byte <blank_line94	; 94
	.byte <blank_line95	; 95
	.byte <blank_line96	; 96
	.byte <blank_line97	; 97
	.byte <blank_line98	; 98
	.byte <blank_line99	; 99
	.byte <blank_line100	; 100
	.byte <blank_line101	; 101
	.byte <blank_line102	; 102
	.byte <blank_line103	; 103
	.byte <blank_line104	; 104
	.byte <blank_line105	; 105
	.byte <blank_line106	; 106
	.byte <blank_line107	; 107
	.byte <blank_line108	; 108
	.byte <blank_line109	; 109
	.byte <blank_line110	; 110
	.byte <blank_line111	; 111
	.byte <blank_line112	; 112
	.byte <blank_line113	; 113
	.byte <blank_line114	; 114
	.byte <blank_line115	; 115
	.byte <blank_line116	; 116
	.byte <blank_line117	; 117
	.byte <blank_line118	; 118
	.byte <blank_line119	; 119
	.byte <blank_line120	; 120
	.byte <blank_line121	; 121
	.byte <blank_line122	; 122
	.byte <blank_line123	; 123
	.byte <blank_line124	; 124
	.byte <blank_line125	; 125
	.byte <blank_line126	; 126
	.byte <blank_line127	; 127
	.byte <blank_line128	; 128
	.byte <blank_line129	; 129
	.byte <blank_line130	; 130
	.byte <blank_line131	; 131
	.byte <blank_line132	; 132
	.byte <blank_line133	; 133
	.byte <blank_line134	; 134
	.byte <blank_line135	; 135
	.byte <blank_line136	; 136
	.byte <blank_line137	; 137
	.byte <blank_line138	; 138
	.byte <blank_line139	; 139
	.byte <blank_line140	; 140
	.byte <blank_line141	; 141
	.byte <blank_line142	; 142
	.byte <blank_line143	; 143
	.byte <blank_line144	; 144
	.byte <blank_line145	; 145
	.byte <blank_line146	; 146
	.byte <blank_line147	; 147
	.byte <blank_line148	; 148
	.byte <blank_line149	; 149
	.byte <blank_line150	; 150
	.byte <blank_line151	; 151
	.byte <blank_line152	; 152
	.byte <blank_line153	; 153
	.byte <blank_line154	; 154
	.byte <blank_line155	; 155
	.byte <blank_line156	; 156
	.byte <blank_line157	; 157
	.byte <blank_line158	; 158
	.byte <blank_line159	; 159
	.byte <blank_line160	; 160
	.byte <blank_line161	; 161
	.byte <blank_line162	; 162
	.byte <blank_line163	; 163
	.byte <blank_line164	; 164
	.byte <blank_line165	; 165
	.byte <blank_line166	; 166
	.byte <blank_line167	; 167
	.byte <blank_line168	; 168
	.byte <blank_line169	; 169
	.byte <blank_line170	; 170
	.byte <blank_line171	; 171
	.byte <blank_line172	; 172
	.byte <blank_line173	; 173
	.byte <blank_line174	; 174
	.byte <blank_line175	; 175
	.byte <blank_line176	; 176
	.byte <blank_line177	; 177
	.byte <blank_line178	; 178
	.byte <blank_line179	; 179
	.byte <blank_line180	; 180
	.byte <blank_line181	; 181
	.byte <blank_line182	; 182
	.byte <blank_line183	; 183
	.byte <blank_line184	; 184
	.byte <blank_line185	; 185
	.byte <blank_line186	; 186
	.byte <blank_line187	; 187
	.byte <blank_line188	; 188
	.byte <blank_line189	; 189
	.byte <blank_line190	; 190
	.byte <blank_line191	; 191
blank_line_ptrs_hi:
	.byte >blank_line0	; 0
	.byte >blank_line1	; 1
	.byte >blank_line2	; 2
	.byte >blank_line3	; 3
	.byte >blank_line4	; 4
	.byte >blank_line5	; 5
	.byte >blank_line6	; 6
	.byte >blank_line7	; 7
	.byte >blank_line8	; 8
	.byte >blank_line9	; 9
	.byte >blank_line10	; 10
	.byte >blank_line11	; 11
	.byte >blank_line12	; 12
	.byte >blank_line13	; 13
	.byte >blank_line14	; 14
	.byte >blank_line15	; 15
	.byte >blank_line16	; 16
	.byte >blank_line17	; 17
	.byte >blank_line18	; 18
	.byte >blank_line19	; 19
	.byte >blank_line20	; 20
	.byte >blank_line21	; 21
	.byte >blank_line22	; 22
	.byte >blank_line23	; 23
	.byte >blank_line24	; 24
	.byte >blank_line25	; 25
	.byte >blank_line26	; 26
	.byte >blank_line27	; 27
	.byte >blank_line28	; 28
	.byte >blank_line29	; 29
	.byte >blank_line30	; 30
	.byte >blank_line31	; 31
	.byte >blank_line32	; 32
	.byte >blank_line33	; 33
	.byte >blank_line34	; 34
	.byte >blank_line35	; 35
	.byte >blank_line36	; 36
	.byte >blank_line37	; 37
	.byte >blank_line38	; 38
	.byte >blank_line39	; 39
	.byte >blank_line40	; 40
	.byte >blank_line41	; 41
	.byte >blank_line42	; 42
	.byte >blank_line43	; 43
	.byte >blank_line44	; 44
	.byte >blank_line45	; 45
	.byte >blank_line46	; 46
	.byte >blank_line47	; 47
	.byte >blank_line48	; 48
	.byte >blank_line49	; 49
	.byte >blank_line50	; 50
	.byte >blank_line51	; 51
	.byte >blank_line52	; 52
	.byte >blank_line53	; 53
	.byte >blank_line54	; 54
	.byte >blank_line55	; 55
	.byte >blank_line56	; 56
	.byte >blank_line57	; 57
	.byte >blank_line58	; 58
	.byte >blank_line59	; 59
	.byte >blank_line60	; 60
	.byte >blank_line61	; 61
	.byte >blank_line62	; 62
	.byte >blank_line63	; 63
	.byte >blank_line64	; 64
	.byte >blank_line65	; 65
	.byte >blank_line66	; 66
	.byte >blank_line67	; 67
	.byte >blank_line68	; 68
	.byte >blank_line69	; 69
	.byte >blank_line70	; 70
	.byte >blank_line71	; 71
	.byte >blank_line72	; 72
	.byte >blank_line73	; 73
	.byte >blank_line74	; 74
	.byte >blank_line75	; 75
	.byte >blank_line76	; 76
	.byte >blank_line77	; 77
	.byte >blank_line78	; 78
	.byte >blank_line79	; 79
	.byte >blank_line80	; 80
	.byte >blank_line81	; 81
	.byte >blank_line82	; 82
	.byte >blank_line83	; 83
	.byte >blank_line84	; 84
	.byte >blank_line85	; 85
	.byte >blank_line86	; 86
	.byte >blank_line87	; 87
	.byte >blank_line88	; 88
	.byte >blank_line89	; 89
	.byte >blank_line90	; 90
	.byte >blank_line91	; 91
	.byte >blank_line92	; 92
	.byte >blank_line93	; 93
	.byte >blank_line94	; 94
	.byte >blank_line95	; 95
	.byte >blank_line96	; 96
	.byte >blank_line97	; 97
	.byte >blank_line98	; 98
	.byte >blank_line99	; 99
	.byte >blank_line100	; 100
	.byte >blank_line101	; 101
	.byte >blank_line102	; 102
	.byte >blank_line103	; 103
	.byte >blank_line104	; 104
	.byte >blank_line105	; 105
	.byte >blank_line106	; 106
	.byte >blank_line107	; 107
	.byte >blank_line108	; 108
	.byte >blank_line109	; 109
	.byte >blank_line110	; 110
	.byte >blank_line111	; 111
	.byte >blank_line112	; 112
	.byte >blank_line113	; 113
	.byte >blank_line114	; 114
	.byte >blank_line115	; 115
	.byte >blank_line116	; 116
	.byte >blank_line117	; 117
	.byte >blank_line118	; 118
	.byte >blank_line119	; 119
	.byte >blank_line120	; 120
	.byte >blank_line121	; 121
	.byte >blank_line122	; 122
	.byte >blank_line123	; 123
	.byte >blank_line124	; 124
	.byte >blank_line125	; 125
	.byte >blank_line126	; 126
	.byte >blank_line127	; 127
	.byte >blank_line128	; 128
	.byte >blank_line129	; 129
	.byte >blank_line130	; 130
	.byte >blank_line131	; 131
	.byte >blank_line132	; 132
	.byte >blank_line133	; 133
	.byte >blank_line134	; 134
	.byte >blank_line135	; 135
	.byte >blank_line136	; 136
	.byte >blank_line137	; 137
	.byte >blank_line138	; 138
	.byte >blank_line139	; 139
	.byte >blank_line140	; 140
	.byte >blank_line141	; 141
	.byte >blank_line142	; 142
	.byte >blank_line143	; 143
	.byte >blank_line144	; 144
	.byte >blank_line145	; 145
	.byte >blank_line146	; 146
	.byte >blank_line147	; 147
	.byte >blank_line148	; 148
	.byte >blank_line149	; 149
	.byte >blank_line150	; 150
	.byte >blank_line151	; 151
	.byte >blank_line152	; 152
	.byte >blank_line153	; 153
	.byte >blank_line154	; 154
	.byte >blank_line155	; 155
	.byte >blank_line156	; 156
	.byte >blank_line157	; 157
	.byte >blank_line158	; 158
	.byte >blank_line159	; 159
	.byte >blank_line160	; 160
	.byte >blank_line161	; 161
	.byte >blank_line162	; 162
	.byte >blank_line163	; 163
	.byte >blank_line164	; 164
	.byte >blank_line165	; 165
	.byte >blank_line166	; 166
	.byte >blank_line167	; 167
	.byte >blank_line168	; 168
	.byte >blank_line169	; 169
	.byte >blank_line170	; 170
	.byte >blank_line171	; 171
	.byte >blank_line172	; 172
	.byte >blank_line173	; 173
	.byte >blank_line174	; 174
	.byte >blank_line175	; 175
	.byte >blank_line176	; 176
	.byte >blank_line177	; 177
	.byte >blank_line178	; 178
	.byte >blank_line179	; 179
	.byte >blank_line180	; 180
	.byte >blank_line181	; 181
	.byte >blank_line182	; 182
	.byte >blank_line183	; 183
	.byte >blank_line184	; 184
	.byte >blank_line185	; 185
	.byte >blank_line186	; 186
	.byte >blank_line187	; 187
	.byte >blank_line188	; 188
	.byte >blank_line189	; 189
	.byte >blank_line190	; 190
	.byte >blank_line191	; 191

; Optimizing the BPL away is not worth it.
; A branch takes 2 or 3 cycles, but setting it up with self modifying code
; is at least 10 times that. So it's worth only for tall lines.

	BVC early_out_p2_1_skip	; always taken
early_out_p2_1:
	RTS
early_out_p2_1_skip:


p2_line0:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4000 + $0,X	; 4+
        STA $4000 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
p2_pcsm0:
        BMI early_out_p2_1

p2_line1:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4000 + $400,X	; 4+
        STA $4000 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_1

p2_line2:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4000 + $800,X	; 4+
        STA $4000 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_1

p2_line3:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4000 + $C00,X	; 4+
        STA $4000 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_1

p2_line4:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4000 + $1000,X	; 4+
        STA $4000 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_1

p2_line5:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4000 + $1400,X	; 4+
        STA $4000 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_1

p2_line6:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4000 + $1800,X	; 4+
        STA $4000 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_1

p2_line7:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4000 + $1C00,X	; 4+
        STA $4000 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_1

p2_line8:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4080 + $0,X	; 4+
        STA $4080 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_1

p2_line9:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4080 + $400,X	; 4+
        STA $4080 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_1

p2_line10:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4080 + $800,X	; 4+
        STA $4080 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_1

	BVC early_out_p2_2_skip	; always taken
early_out_p2_2:
	RTS
early_out_p2_2_skip:


p2_line11:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4080 + $C00,X	; 4+
        STA $4080 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_2

p2_line12:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4080 + $1000,X	; 4+
        STA $4080 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_2

p2_line13:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4080 + $1400,X	; 4+
        STA $4080 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_2

p2_line14:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4080 + $1800,X	; 4+
        STA $4080 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_2

p2_line15:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4080 + $1C00,X	; 4+
        STA $4080 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_2

p2_line16:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4100 + $0,X	; 4+
        STA $4100 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_2

p2_line17:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4100 + $400,X	; 4+
        STA $4100 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_2

p2_line18:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4100 + $800,X	; 4+
        STA $4100 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_2

p2_line19:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4100 + $C00,X	; 4+
        STA $4100 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_2

p2_line20:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4100 + $1000,X	; 4+
        STA $4100 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_2

p2_line21:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4100 + $1400,X	; 4+
        STA $4100 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_2

	BVC early_out_p2_3_skip	; always taken
early_out_p2_3:
	RTS
early_out_p2_3_skip:


p2_line22:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4100 + $1800,X	; 4+
        STA $4100 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_3

p2_line23:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4100 + $1C00,X	; 4+
        STA $4100 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_3

p2_line24:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4180 + $0,X	; 4+
        STA $4180 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_3

p2_line25:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4180 + $400,X	; 4+
        STA $4180 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_3

p2_line26:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4180 + $800,X	; 4+
        STA $4180 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_3

p2_line27:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4180 + $C00,X	; 4+
        STA $4180 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_3

p2_line28:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4180 + $1000,X	; 4+
        STA $4180 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_3

p2_line29:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4180 + $1400,X	; 4+
        STA $4180 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_3

p2_line30:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4180 + $1800,X	; 4+
        STA $4180 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_3

p2_line31:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4180 + $1C00,X	; 4+
        STA $4180 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_3

p2_line32:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4200 + $0,X	; 4+
        STA $4200 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_3

	BVC early_out_p2_4_skip	; always taken
early_out_p2_4:
	RTS
early_out_p2_4_skip:


p2_line33:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4200 + $400,X	; 4+
        STA $4200 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_4

p2_line34:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4200 + $800,X	; 4+
        STA $4200 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_4

p2_line35:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4200 + $C00,X	; 4+
        STA $4200 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_4

p2_line36:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4200 + $1000,X	; 4+
        STA $4200 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_4

p2_line37:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4200 + $1400,X	; 4+
        STA $4200 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_4

p2_line38:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4200 + $1800,X	; 4+
        STA $4200 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_4

p2_line39:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4200 + $1C00,X	; 4+
        STA $4200 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_4

p2_line40:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4280 + $0,X	; 4+
        STA $4280 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_4

p2_line41:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4280 + $400,X	; 4+
        STA $4280 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_4

p2_line42:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4280 + $800,X	; 4+
        STA $4280 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_4

p2_line43:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4280 + $C00,X	; 4+
        STA $4280 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_4

	BVC early_out_p2_5_skip	; always taken
early_out_p2_5:
	RTS
early_out_p2_5_skip:


p2_line44:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4280 + $1000,X	; 4+
        STA $4280 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_5

p2_line45:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4280 + $1400,X	; 4+
        STA $4280 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_5

p2_line46:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4280 + $1800,X	; 4+
        STA $4280 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_5

p2_line47:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4280 + $1C00,X	; 4+
        STA $4280 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_5

p2_line48:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4300 + $0,X	; 4+
        STA $4300 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_5

p2_line49:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4300 + $400,X	; 4+
        STA $4300 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_5

p2_line50:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4300 + $800,X	; 4+
        STA $4300 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_5

p2_line51:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4300 + $C00,X	; 4+
        STA $4300 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_5

p2_line52:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4300 + $1000,X	; 4+
        STA $4300 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_5

p2_line53:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4300 + $1400,X	; 4+
        STA $4300 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_5

p2_line54:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4300 + $1800,X	; 4+
        STA $4300 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_5

	BVC early_out_p2_6_skip	; always taken
early_out_p2_6:
	RTS
early_out_p2_6_skip:


p2_line55:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4300 + $1C00,X	; 4+
        STA $4300 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_6

p2_line56:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4380 + $0,X	; 4+
        STA $4380 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_6

p2_line57:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4380 + $400,X	; 4+
        STA $4380 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_6

p2_line58:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4380 + $800,X	; 4+
        STA $4380 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_6

p2_line59:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4380 + $C00,X	; 4+
        STA $4380 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_6

p2_line60:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4380 + $1000,X	; 4+
        STA $4380 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_6

p2_line61:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4380 + $1400,X	; 4+
        STA $4380 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_6

p2_line62:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4380 + $1800,X	; 4+
        STA $4380 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_6

p2_line63:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4380 + $1C00,X	; 4+
        STA $4380 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_6

p2_line64:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4028 + $0,X	; 4+
        STA $4028 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_6

p2_line65:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4028 + $400,X	; 4+
        STA $4028 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_6

	BVC early_out_p2_7_skip	; always taken
early_out_p2_7:
	RTS
early_out_p2_7_skip:


p2_line66:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4028 + $800,X	; 4+
        STA $4028 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_7

p2_line67:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4028 + $C00,X	; 4+
        STA $4028 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_7

p2_line68:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4028 + $1000,X	; 4+
        STA $4028 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_7

p2_line69:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4028 + $1400,X	; 4+
        STA $4028 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_7

p2_line70:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4028 + $1800,X	; 4+
        STA $4028 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_7

p2_line71:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4028 + $1C00,X	; 4+
        STA $4028 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_7

p2_line72:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $40A8 + $0,X	; 4+
        STA $40A8 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_7

p2_line73:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $40A8 + $400,X	; 4+
        STA $40A8 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_7

p2_line74:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $40A8 + $800,X	; 4+
        STA $40A8 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_7

p2_line75:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $40A8 + $C00,X	; 4+
        STA $40A8 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_7

p2_line76:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $40A8 + $1000,X	; 4+
        STA $40A8 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_7

	BVC early_out_p2_8_skip	; always taken
early_out_p2_8:
	RTS
early_out_p2_8_skip:


p2_line77:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $40A8 + $1400,X	; 4+
        STA $40A8 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_8

p2_line78:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $40A8 + $1800,X	; 4+
        STA $40A8 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_8

p2_line79:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $40A8 + $1C00,X	; 4+
        STA $40A8 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_8

p2_line80:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4128 + $0,X	; 4+
        STA $4128 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_8

p2_line81:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4128 + $400,X	; 4+
        STA $4128 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_8

p2_line82:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4128 + $800,X	; 4+
        STA $4128 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_8

p2_line83:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4128 + $C00,X	; 4+
        STA $4128 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_8

p2_line84:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4128 + $1000,X	; 4+
        STA $4128 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_8

p2_line85:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4128 + $1400,X	; 4+
        STA $4128 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_8

p2_line86:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4128 + $1800,X	; 4+
        STA $4128 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_8

p2_line87:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4128 + $1C00,X	; 4+
        STA $4128 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_8

	BVC early_out_p2_9_skip	; always taken
early_out_p2_9:
	RTS
early_out_p2_9_skip:


p2_line88:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $41A8 + $0,X	; 4+
        STA $41A8 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_9

p2_line89:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $41A8 + $400,X	; 4+
        STA $41A8 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_9

p2_line90:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $41A8 + $800,X	; 4+
        STA $41A8 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_9

p2_line91:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $41A8 + $C00,X	; 4+
        STA $41A8 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_9

p2_line92:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $41A8 + $1000,X	; 4+
        STA $41A8 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_9

p2_line93:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $41A8 + $1400,X	; 4+
        STA $41A8 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_9

p2_line94:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $41A8 + $1800,X	; 4+
        STA $41A8 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_9

p2_line95:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $41A8 + $1C00,X	; 4+
        STA $41A8 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_9

p2_line96:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4228 + $0,X	; 4+
        STA $4228 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_9

p2_line97:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4228 + $400,X	; 4+
        STA $4228 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_9

p2_line98:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4228 + $800,X	; 4+
        STA $4228 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_9

	BVC early_out_p2_10_skip	; always taken
early_out_p2_10:
	RTS
early_out_p2_10_skip:


p2_line99:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4228 + $C00,X	; 4+
        STA $4228 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_10

p2_line100:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4228 + $1000,X	; 4+
        STA $4228 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_10

p2_line101:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4228 + $1400,X	; 4+
        STA $4228 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_10

p2_line102:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4228 + $1800,X	; 4+
        STA $4228 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_10

p2_line103:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4228 + $1C00,X	; 4+
        STA $4228 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_10

p2_line104:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $42A8 + $0,X	; 4+
        STA $42A8 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_10

p2_line105:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $42A8 + $400,X	; 4+
        STA $42A8 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_10

p2_line106:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $42A8 + $800,X	; 4+
        STA $42A8 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_10

p2_line107:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $42A8 + $C00,X	; 4+
        STA $42A8 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_10

p2_line108:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $42A8 + $1000,X	; 4+
        STA $42A8 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_10

p2_line109:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $42A8 + $1400,X	; 4+
        STA $42A8 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_10

	BVC early_out_p2_11_skip	; always taken
early_out_p2_11:
	RTS
early_out_p2_11_skip:


p2_line110:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $42A8 + $1800,X	; 4+
        STA $42A8 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_11

p2_line111:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $42A8 + $1C00,X	; 4+
        STA $42A8 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_11

p2_line112:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4328 + $0,X	; 4+
        STA $4328 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_11

p2_line113:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4328 + $400,X	; 4+
        STA $4328 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_11

p2_line114:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4328 + $800,X	; 4+
        STA $4328 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_11

p2_line115:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4328 + $C00,X	; 4+
        STA $4328 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_11

p2_line116:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4328 + $1000,X	; 4+
        STA $4328 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_11

p2_line117:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4328 + $1400,X	; 4+
        STA $4328 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_11

p2_line118:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4328 + $1800,X	; 4+
        STA $4328 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_11

p2_line119:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4328 + $1C00,X	; 4+
        STA $4328 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_11

p2_line120:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $43A8 + $0,X	; 4+
        STA $43A8 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_11

	BVC early_out_p2_12_skip	; always taken
early_out_p2_12:
	RTS
early_out_p2_12_skip:


p2_line121:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $43A8 + $400,X	; 4+
        STA $43A8 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_12

p2_line122:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $43A8 + $800,X	; 4+
        STA $43A8 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_12

p2_line123:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $43A8 + $C00,X	; 4+
        STA $43A8 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_12

p2_line124:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $43A8 + $1000,X	; 4+
        STA $43A8 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_12

p2_line125:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $43A8 + $1400,X	; 4+
        STA $43A8 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_12

p2_line126:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $43A8 + $1800,X	; 4+
        STA $43A8 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_12

p2_line127:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $43A8 + $1C00,X	; 4+
        STA $43A8 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_12

p2_line128:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4050 + $0,X	; 4+
        STA $4050 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_12

p2_line129:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4050 + $400,X	; 4+
        STA $4050 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_12

p2_line130:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4050 + $800,X	; 4+
        STA $4050 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_12

p2_line131:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4050 + $C00,X	; 4+
        STA $4050 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_12

	BVC early_out_p2_13_skip	; always taken
early_out_p2_13:
	RTS
early_out_p2_13_skip:


p2_line132:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4050 + $1000,X	; 4+
        STA $4050 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_13

p2_line133:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4050 + $1400,X	; 4+
        STA $4050 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_13

p2_line134:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4050 + $1800,X	; 4+
        STA $4050 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_13

p2_line135:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4050 + $1C00,X	; 4+
        STA $4050 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_13

p2_line136:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $40D0 + $0,X	; 4+
        STA $40D0 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_13

p2_line137:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $40D0 + $400,X	; 4+
        STA $40D0 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_13

p2_line138:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $40D0 + $800,X	; 4+
        STA $40D0 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_13

p2_line139:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $40D0 + $C00,X	; 4+
        STA $40D0 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_13

p2_line140:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $40D0 + $1000,X	; 4+
        STA $40D0 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_13

p2_line141:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $40D0 + $1400,X	; 4+
        STA $40D0 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_13

p2_line142:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $40D0 + $1800,X	; 4+
        STA $40D0 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_13

	BVC early_out_p2_14_skip	; always taken
early_out_p2_14:
	RTS
early_out_p2_14_skip:


p2_line143:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $40D0 + $1C00,X	; 4+
        STA $40D0 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_14

p2_line144:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4150 + $0,X	; 4+
        STA $4150 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_14

p2_line145:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4150 + $400,X	; 4+
        STA $4150 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_14

p2_line146:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4150 + $800,X	; 4+
        STA $4150 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_14

p2_line147:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4150 + $C00,X	; 4+
        STA $4150 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_14

p2_line148:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4150 + $1000,X	; 4+
        STA $4150 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_14

p2_line149:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4150 + $1400,X	; 4+
        STA $4150 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_14

p2_line150:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4150 + $1800,X	; 4+
        STA $4150 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_14

p2_line151:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4150 + $1C00,X	; 4+
        STA $4150 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_14

p2_line152:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $41D0 + $0,X	; 4+
        STA $41D0 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_14

p2_line153:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $41D0 + $400,X	; 4+
        STA $41D0 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_14

	BVC early_out_p2_15_skip	; always taken
early_out_p2_15:
	RTS
early_out_p2_15_skip:


p2_line154:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $41D0 + $800,X	; 4+
        STA $41D0 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_15

p2_line155:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $41D0 + $C00,X	; 4+
        STA $41D0 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_15

p2_line156:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $41D0 + $1000,X	; 4+
        STA $41D0 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_15

p2_line157:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $41D0 + $1400,X	; 4+
        STA $41D0 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_15

p2_line158:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $41D0 + $1800,X	; 4+
        STA $41D0 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_15

p2_line159:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $41D0 + $1C00,X	; 4+
        STA $41D0 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_15

p2_line160:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4250 + $0,X	; 4+
        STA $4250 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_15

p2_line161:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4250 + $400,X	; 4+
        STA $4250 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_15

p2_line162:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4250 + $800,X	; 4+
        STA $4250 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_15

p2_line163:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4250 + $C00,X	; 4+
        STA $4250 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_15

p2_line164:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4250 + $1000,X	; 4+
        STA $4250 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_15

	BVC early_out_p2_16_skip	; always taken
early_out_p2_16:
	RTS
early_out_p2_16_skip:


p2_line165:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4250 + $1400,X	; 4+
        STA $4250 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_16

p2_line166:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4250 + $1800,X	; 4+
        STA $4250 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_16

p2_line167:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4250 + $1C00,X	; 4+
        STA $4250 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_16

p2_line168:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $42D0 + $0,X	; 4+
        STA $42D0 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_16

p2_line169:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $42D0 + $400,X	; 4+
        STA $42D0 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_16

p2_line170:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $42D0 + $800,X	; 4+
        STA $42D0 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_16

p2_line171:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $42D0 + $C00,X	; 4+
        STA $42D0 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_16

p2_line172:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $42D0 + $1000,X	; 4+
        STA $42D0 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_16

p2_line173:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $42D0 + $1400,X	; 4+
        STA $42D0 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_16

p2_line174:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $42D0 + $1800,X	; 4+
        STA $42D0 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_16

p2_line175:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $42D0 + $1C00,X	; 4+
        STA $42D0 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_16

	BVC early_out_p2_17_skip	; always taken
early_out_p2_17:
	RTS
early_out_p2_17_skip:


p2_line176:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4350 + $0,X	; 4+
        STA $4350 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_17

p2_line177:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4350 + $400,X	; 4+
        STA $4350 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_17

p2_line178:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4350 + $800,X	; 4+
        STA $4350 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_17

p2_line179:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4350 + $C00,X	; 4+
        STA $4350 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_17

p2_line180:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4350 + $1000,X	; 4+
        STA $4350 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_17

p2_line181:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4350 + $1400,X	; 4+
        STA $4350 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_17

p2_line182:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4350 + $1800,X	; 4+
        STA $4350 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_17

p2_line183:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $4350 + $1C00,X	; 4+
        STA $4350 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_17

p2_line184:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $43D0 + $0,X	; 4+
        STA $43D0 + $0,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_17

p2_line185:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $43D0 + $400,X	; 4+
        STA $43D0 + $400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_17

p2_line186:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $43D0 + $800,X	; 4+
        STA $43D0 + $800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_17

	BVC early_out_p2_18_skip	; always taken
early_out_p2_18:
	RTS
early_out_p2_18_skip:


p2_line187:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $43D0 + $C00,X	; 4+
        STA $43D0 + $C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_18

p2_line188:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $43D0 + $1000,X	; 4+
        STA $43D0 + $1000,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_18

p2_line189:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $43D0 + $1400,X	; 4+
        STA $43D0 + $1400,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_18

p2_line190:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $43D0 + $1800,X	; 4+
        STA $43D0 + $1800,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_18

p2_line191:
        LDA (tile_ptr),Y	; 5+ (+ = page boundary)
        ORA $43D0 + $1C00,X	; 4+
        STA $43D0 + $1C00,X	; 5
        DEY	; 2 (affects only flags N(egative) and Z(ero) (cleared or set), not overflow(N)
        BMI early_out_p2_18
	RTS
p2_line_ptrs_lo:
	.byte <p2_line0	; 0
	.byte <p2_line1	; 1
	.byte <p2_line2	; 2
	.byte <p2_line3	; 3
	.byte <p2_line4	; 4
	.byte <p2_line5	; 5
	.byte <p2_line6	; 6
	.byte <p2_line7	; 7
	.byte <p2_line8	; 8
	.byte <p2_line9	; 9
	.byte <p2_line10	; 10
	.byte <p2_line11	; 11
	.byte <p2_line12	; 12
	.byte <p2_line13	; 13
	.byte <p2_line14	; 14
	.byte <p2_line15	; 15
	.byte <p2_line16	; 16
	.byte <p2_line17	; 17
	.byte <p2_line18	; 18
	.byte <p2_line19	; 19
	.byte <p2_line20	; 20
	.byte <p2_line21	; 21
	.byte <p2_line22	; 22
	.byte <p2_line23	; 23
	.byte <p2_line24	; 24
	.byte <p2_line25	; 25
	.byte <p2_line26	; 26
	.byte <p2_line27	; 27
	.byte <p2_line28	; 28
	.byte <p2_line29	; 29
	.byte <p2_line30	; 30
	.byte <p2_line31	; 31
	.byte <p2_line32	; 32
	.byte <p2_line33	; 33
	.byte <p2_line34	; 34
	.byte <p2_line35	; 35
	.byte <p2_line36	; 36
	.byte <p2_line37	; 37
	.byte <p2_line38	; 38
	.byte <p2_line39	; 39
	.byte <p2_line40	; 40
	.byte <p2_line41	; 41
	.byte <p2_line42	; 42
	.byte <p2_line43	; 43
	.byte <p2_line44	; 44
	.byte <p2_line45	; 45
	.byte <p2_line46	; 46
	.byte <p2_line47	; 47
	.byte <p2_line48	; 48
	.byte <p2_line49	; 49
	.byte <p2_line50	; 50
	.byte <p2_line51	; 51
	.byte <p2_line52	; 52
	.byte <p2_line53	; 53
	.byte <p2_line54	; 54
	.byte <p2_line55	; 55
	.byte <p2_line56	; 56
	.byte <p2_line57	; 57
	.byte <p2_line58	; 58
	.byte <p2_line59	; 59
	.byte <p2_line60	; 60
	.byte <p2_line61	; 61
	.byte <p2_line62	; 62
	.byte <p2_line63	; 63
	.byte <p2_line64	; 64
	.byte <p2_line65	; 65
	.byte <p2_line66	; 66
	.byte <p2_line67	; 67
	.byte <p2_line68	; 68
	.byte <p2_line69	; 69
	.byte <p2_line70	; 70
	.byte <p2_line71	; 71
	.byte <p2_line72	; 72
	.byte <p2_line73	; 73
	.byte <p2_line74	; 74
	.byte <p2_line75	; 75
	.byte <p2_line76	; 76
	.byte <p2_line77	; 77
	.byte <p2_line78	; 78
	.byte <p2_line79	; 79
	.byte <p2_line80	; 80
	.byte <p2_line81	; 81
	.byte <p2_line82	; 82
	.byte <p2_line83	; 83
	.byte <p2_line84	; 84
	.byte <p2_line85	; 85
	.byte <p2_line86	; 86
	.byte <p2_line87	; 87
	.byte <p2_line88	; 88
	.byte <p2_line89	; 89
	.byte <p2_line90	; 90
	.byte <p2_line91	; 91
	.byte <p2_line92	; 92
	.byte <p2_line93	; 93
	.byte <p2_line94	; 94
	.byte <p2_line95	; 95
	.byte <p2_line96	; 96
	.byte <p2_line97	; 97
	.byte <p2_line98	; 98
	.byte <p2_line99	; 99
	.byte <p2_line100	; 100
	.byte <p2_line101	; 101
	.byte <p2_line102	; 102
	.byte <p2_line103	; 103
	.byte <p2_line104	; 104
	.byte <p2_line105	; 105
	.byte <p2_line106	; 106
	.byte <p2_line107	; 107
	.byte <p2_line108	; 108
	.byte <p2_line109	; 109
	.byte <p2_line110	; 110
	.byte <p2_line111	; 111
	.byte <p2_line112	; 112
	.byte <p2_line113	; 113
	.byte <p2_line114	; 114
	.byte <p2_line115	; 115
	.byte <p2_line116	; 116
	.byte <p2_line117	; 117
	.byte <p2_line118	; 118
	.byte <p2_line119	; 119
	.byte <p2_line120	; 120
	.byte <p2_line121	; 121
	.byte <p2_line122	; 122
	.byte <p2_line123	; 123
	.byte <p2_line124	; 124
	.byte <p2_line125	; 125
	.byte <p2_line126	; 126
	.byte <p2_line127	; 127
	.byte <p2_line128	; 128
	.byte <p2_line129	; 129
	.byte <p2_line130	; 130
	.byte <p2_line131	; 131
	.byte <p2_line132	; 132
	.byte <p2_line133	; 133
	.byte <p2_line134	; 134
	.byte <p2_line135	; 135
	.byte <p2_line136	; 136
	.byte <p2_line137	; 137
	.byte <p2_line138	; 138
	.byte <p2_line139	; 139
	.byte <p2_line140	; 140
	.byte <p2_line141	; 141
	.byte <p2_line142	; 142
	.byte <p2_line143	; 143
	.byte <p2_line144	; 144
	.byte <p2_line145	; 145
	.byte <p2_line146	; 146
	.byte <p2_line147	; 147
	.byte <p2_line148	; 148
	.byte <p2_line149	; 149
	.byte <p2_line150	; 150
	.byte <p2_line151	; 151
	.byte <p2_line152	; 152
	.byte <p2_line153	; 153
	.byte <p2_line154	; 154
	.byte <p2_line155	; 155
	.byte <p2_line156	; 156
	.byte <p2_line157	; 157
	.byte <p2_line158	; 158
	.byte <p2_line159	; 159
	.byte <p2_line160	; 160
	.byte <p2_line161	; 161
	.byte <p2_line162	; 162
	.byte <p2_line163	; 163
	.byte <p2_line164	; 164
	.byte <p2_line165	; 165
	.byte <p2_line166	; 166
	.byte <p2_line167	; 167
	.byte <p2_line168	; 168
	.byte <p2_line169	; 169
	.byte <p2_line170	; 170
	.byte <p2_line171	; 171
	.byte <p2_line172	; 172
	.byte <p2_line173	; 173
	.byte <p2_line174	; 174
	.byte <p2_line175	; 175
	.byte <p2_line176	; 176
	.byte <p2_line177	; 177
	.byte <p2_line178	; 178
	.byte <p2_line179	; 179
	.byte <p2_line180	; 180
	.byte <p2_line181	; 181
	.byte <p2_line182	; 182
	.byte <p2_line183	; 183
	.byte <p2_line184	; 184
	.byte <p2_line185	; 185
	.byte <p2_line186	; 186
	.byte <p2_line187	; 187
	.byte <p2_line188	; 188
	.byte <p2_line189	; 189
	.byte <p2_line190	; 190
	.byte <p2_line191	; 191
p2_line_ptrs_hi:
	.byte >p2_line0	; 0
	.byte >p2_line1	; 1
	.byte >p2_line2	; 2
	.byte >p2_line3	; 3
	.byte >p2_line4	; 4
	.byte >p2_line5	; 5
	.byte >p2_line6	; 6
	.byte >p2_line7	; 7
	.byte >p2_line8	; 8
	.byte >p2_line9	; 9
	.byte >p2_line10	; 10
	.byte >p2_line11	; 11
	.byte >p2_line12	; 12
	.byte >p2_line13	; 13
	.byte >p2_line14	; 14
	.byte >p2_line15	; 15
	.byte >p2_line16	; 16
	.byte >p2_line17	; 17
	.byte >p2_line18	; 18
	.byte >p2_line19	; 19
	.byte >p2_line20	; 20
	.byte >p2_line21	; 21
	.byte >p2_line22	; 22
	.byte >p2_line23	; 23
	.byte >p2_line24	; 24
	.byte >p2_line25	; 25
	.byte >p2_line26	; 26
	.byte >p2_line27	; 27
	.byte >p2_line28	; 28
	.byte >p2_line29	; 29
	.byte >p2_line30	; 30
	.byte >p2_line31	; 31
	.byte >p2_line32	; 32
	.byte >p2_line33	; 33
	.byte >p2_line34	; 34
	.byte >p2_line35	; 35
	.byte >p2_line36	; 36
	.byte >p2_line37	; 37
	.byte >p2_line38	; 38
	.byte >p2_line39	; 39
	.byte >p2_line40	; 40
	.byte >p2_line41	; 41
	.byte >p2_line42	; 42
	.byte >p2_line43	; 43
	.byte >p2_line44	; 44
	.byte >p2_line45	; 45
	.byte >p2_line46	; 46
	.byte >p2_line47	; 47
	.byte >p2_line48	; 48
	.byte >p2_line49	; 49
	.byte >p2_line50	; 50
	.byte >p2_line51	; 51
	.byte >p2_line52	; 52
	.byte >p2_line53	; 53
	.byte >p2_line54	; 54
	.byte >p2_line55	; 55
	.byte >p2_line56	; 56
	.byte >p2_line57	; 57
	.byte >p2_line58	; 58
	.byte >p2_line59	; 59
	.byte >p2_line60	; 60
	.byte >p2_line61	; 61
	.byte >p2_line62	; 62
	.byte >p2_line63	; 63
	.byte >p2_line64	; 64
	.byte >p2_line65	; 65
	.byte >p2_line66	; 66
	.byte >p2_line67	; 67
	.byte >p2_line68	; 68
	.byte >p2_line69	; 69
	.byte >p2_line70	; 70
	.byte >p2_line71	; 71
	.byte >p2_line72	; 72
	.byte >p2_line73	; 73
	.byte >p2_line74	; 74
	.byte >p2_line75	; 75
	.byte >p2_line76	; 76
	.byte >p2_line77	; 77
	.byte >p2_line78	; 78
	.byte >p2_line79	; 79
	.byte >p2_line80	; 80
	.byte >p2_line81	; 81
	.byte >p2_line82	; 82
	.byte >p2_line83	; 83
	.byte >p2_line84	; 84
	.byte >p2_line85	; 85
	.byte >p2_line86	; 86
	.byte >p2_line87	; 87
	.byte >p2_line88	; 88
	.byte >p2_line89	; 89
	.byte >p2_line90	; 90
	.byte >p2_line91	; 91
	.byte >p2_line92	; 92
	.byte >p2_line93	; 93
	.byte >p2_line94	; 94
	.byte >p2_line95	; 95
	.byte >p2_line96	; 96
	.byte >p2_line97	; 97
	.byte >p2_line98	; 98
	.byte >p2_line99	; 99
	.byte >p2_line100	; 100
	.byte >p2_line101	; 101
	.byte >p2_line102	; 102
	.byte >p2_line103	; 103
	.byte >p2_line104	; 104
	.byte >p2_line105	; 105
	.byte >p2_line106	; 106
	.byte >p2_line107	; 107
	.byte >p2_line108	; 108
	.byte >p2_line109	; 109
	.byte >p2_line110	; 110
	.byte >p2_line111	; 111
	.byte >p2_line112	; 112
	.byte >p2_line113	; 113
	.byte >p2_line114	; 114
	.byte >p2_line115	; 115
	.byte >p2_line116	; 116
	.byte >p2_line117	; 117
	.byte >p2_line118	; 118
	.byte >p2_line119	; 119
	.byte >p2_line120	; 120
	.byte >p2_line121	; 121
	.byte >p2_line122	; 122
	.byte >p2_line123	; 123
	.byte >p2_line124	; 124
	.byte >p2_line125	; 125
	.byte >p2_line126	; 126
	.byte >p2_line127	; 127
	.byte >p2_line128	; 128
	.byte >p2_line129	; 129
	.byte >p2_line130	; 130
	.byte >p2_line131	; 131
	.byte >p2_line132	; 132
	.byte >p2_line133	; 133
	.byte >p2_line134	; 134
	.byte >p2_line135	; 135
	.byte >p2_line136	; 136
	.byte >p2_line137	; 137
	.byte >p2_line138	; 138
	.byte >p2_line139	; 139
	.byte >p2_line140	; 140
	.byte >p2_line141	; 141
	.byte >p2_line142	; 142
	.byte >p2_line143	; 143
	.byte >p2_line144	; 144
	.byte >p2_line145	; 145
	.byte >p2_line146	; 146
	.byte >p2_line147	; 147
	.byte >p2_line148	; 148
	.byte >p2_line149	; 149
	.byte >p2_line150	; 150
	.byte >p2_line151	; 151
	.byte >p2_line152	; 152
	.byte >p2_line153	; 153
	.byte >p2_line154	; 154
	.byte >p2_line155	; 155
	.byte >p2_line156	; 156
	.byte >p2_line157	; 157
	.byte >p2_line158	; 158
	.byte >p2_line159	; 159
	.byte >p2_line160	; 160
	.byte >p2_line161	; 161
	.byte >p2_line162	; 162
	.byte >p2_line163	; 163
	.byte >p2_line164	; 164
	.byte >p2_line165	; 165
	.byte >p2_line166	; 166
	.byte >p2_line167	; 167
	.byte >p2_line168	; 168
	.byte >p2_line169	; 169
	.byte >p2_line170	; 170
	.byte >p2_line171	; 171
	.byte >p2_line172	; 172
	.byte >p2_line173	; 173
	.byte >p2_line174	; 174
	.byte >p2_line175	; 175
	.byte >p2_line176	; 176
	.byte >p2_line177	; 177
	.byte >p2_line178	; 178
	.byte >p2_line179	; 179
	.byte >p2_line180	; 180
	.byte >p2_line181	; 181
	.byte >p2_line182	; 182
	.byte >p2_line183	; 183
	.byte >p2_line184	; 184
	.byte >p2_line185	; 185
	.byte >p2_line186	; 186
	.byte >p2_line187	; 187
	.byte >p2_line188	; 188
	.byte >p2_line189	; 189
	.byte >p2_line190	; 190
	.byte >p2_line191	; 191

; Optimizing the BPL away is not worth it.
; A branch takes 2 or 3 cycles, but setting it up with self modifying code
; is at least 10 times that. So it's worth only for tall lines.
	BVC blank_early_out_p2_1_skip	; always taken
blank_early_out_p2_1:
	RTS
blank_early_out_p2_1_skip:

p2_blank_line0:
	STA $4000 + $0,X
	DEY
p2_blank_pcsm0:
        BMI blank_early_out_p2_1

p2_blank_line1:
	STA $4000 + $400,X
	DEY
p2_blank_pcsm1:
        BMI blank_early_out_p2_1

p2_blank_line2:
	STA $4000 + $800,X
	DEY
p2_blank_pcsm2:
        BMI blank_early_out_p2_1

p2_blank_line3:
	STA $4000 + $C00,X
	DEY
p2_blank_pcsm3:
        BMI blank_early_out_p2_1

p2_blank_line4:
	STA $4000 + $1000,X
	DEY
p2_blank_pcsm4:
        BMI blank_early_out_p2_1

p2_blank_line5:
	STA $4000 + $1400,X
	DEY
p2_blank_pcsm5:
        BMI blank_early_out_p2_1

p2_blank_line6:
	STA $4000 + $1800,X
	DEY
p2_blank_pcsm6:
        BMI blank_early_out_p2_1

p2_blank_line7:
	STA $4000 + $1C00,X
	DEY
p2_blank_pcsm7:
        BMI blank_early_out_p2_1

p2_blank_line8:
	STA $4080 + $0,X
	DEY
p2_blank_pcsm8:
        BMI blank_early_out_p2_1

p2_blank_line9:
	STA $4080 + $400,X
	DEY
p2_blank_pcsm9:
        BMI blank_early_out_p2_1

p2_blank_line10:
	STA $4080 + $800,X
	DEY
p2_blank_pcsm10:
        BMI blank_early_out_p2_1
	BVC blank_early_out_p2_2_skip	; always taken
blank_early_out_p2_2:
	RTS
blank_early_out_p2_2_skip:

p2_blank_line11:
	STA $4080 + $C00,X
	DEY
p2_blank_pcsm11:
        BMI blank_early_out_p2_2

p2_blank_line12:
	STA $4080 + $1000,X
	DEY
p2_blank_pcsm12:
        BMI blank_early_out_p2_2

p2_blank_line13:
	STA $4080 + $1400,X
	DEY
p2_blank_pcsm13:
        BMI blank_early_out_p2_2

p2_blank_line14:
	STA $4080 + $1800,X
	DEY
p2_blank_pcsm14:
        BMI blank_early_out_p2_2

p2_blank_line15:
	STA $4080 + $1C00,X
	DEY
p2_blank_pcsm15:
        BMI blank_early_out_p2_2

p2_blank_line16:
	STA $4100 + $0,X
	DEY
p2_blank_pcsm16:
        BMI blank_early_out_p2_2

p2_blank_line17:
	STA $4100 + $400,X
	DEY
p2_blank_pcsm17:
        BMI blank_early_out_p2_2

p2_blank_line18:
	STA $4100 + $800,X
	DEY
p2_blank_pcsm18:
        BMI blank_early_out_p2_2

p2_blank_line19:
	STA $4100 + $C00,X
	DEY
p2_blank_pcsm19:
        BMI blank_early_out_p2_2

p2_blank_line20:
	STA $4100 + $1000,X
	DEY
p2_blank_pcsm20:
        BMI blank_early_out_p2_2

p2_blank_line21:
	STA $4100 + $1400,X
	DEY
p2_blank_pcsm21:
        BMI blank_early_out_p2_2
	BVC blank_early_out_p2_3_skip	; always taken
blank_early_out_p2_3:
	RTS
blank_early_out_p2_3_skip:

p2_blank_line22:
	STA $4100 + $1800,X
	DEY
p2_blank_pcsm22:
        BMI blank_early_out_p2_3

p2_blank_line23:
	STA $4100 + $1C00,X
	DEY
p2_blank_pcsm23:
        BMI blank_early_out_p2_3

p2_blank_line24:
	STA $4180 + $0,X
	DEY
p2_blank_pcsm24:
        BMI blank_early_out_p2_3

p2_blank_line25:
	STA $4180 + $400,X
	DEY
p2_blank_pcsm25:
        BMI blank_early_out_p2_3

p2_blank_line26:
	STA $4180 + $800,X
	DEY
p2_blank_pcsm26:
        BMI blank_early_out_p2_3

p2_blank_line27:
	STA $4180 + $C00,X
	DEY
p2_blank_pcsm27:
        BMI blank_early_out_p2_3

p2_blank_line28:
	STA $4180 + $1000,X
	DEY
p2_blank_pcsm28:
        BMI blank_early_out_p2_3

p2_blank_line29:
	STA $4180 + $1400,X
	DEY
p2_blank_pcsm29:
        BMI blank_early_out_p2_3

p2_blank_line30:
	STA $4180 + $1800,X
	DEY
p2_blank_pcsm30:
        BMI blank_early_out_p2_3

p2_blank_line31:
	STA $4180 + $1C00,X
	DEY
p2_blank_pcsm31:
        BMI blank_early_out_p2_3

p2_blank_line32:
	STA $4200 + $0,X
	DEY
p2_blank_pcsm32:
        BMI blank_early_out_p2_3
	BVC blank_early_out_p2_4_skip	; always taken
blank_early_out_p2_4:
	RTS
blank_early_out_p2_4_skip:

p2_blank_line33:
	STA $4200 + $400,X
	DEY
p2_blank_pcsm33:
        BMI blank_early_out_p2_4

p2_blank_line34:
	STA $4200 + $800,X
	DEY
p2_blank_pcsm34:
        BMI blank_early_out_p2_4

p2_blank_line35:
	STA $4200 + $C00,X
	DEY
p2_blank_pcsm35:
        BMI blank_early_out_p2_4

p2_blank_line36:
	STA $4200 + $1000,X
	DEY
p2_blank_pcsm36:
        BMI blank_early_out_p2_4

p2_blank_line37:
	STA $4200 + $1400,X
	DEY
p2_blank_pcsm37:
        BMI blank_early_out_p2_4

p2_blank_line38:
	STA $4200 + $1800,X
	DEY
p2_blank_pcsm38:
        BMI blank_early_out_p2_4

p2_blank_line39:
	STA $4200 + $1C00,X
	DEY
p2_blank_pcsm39:
        BMI blank_early_out_p2_4

p2_blank_line40:
	STA $4280 + $0,X
	DEY
p2_blank_pcsm40:
        BMI blank_early_out_p2_4

p2_blank_line41:
	STA $4280 + $400,X
	DEY
p2_blank_pcsm41:
        BMI blank_early_out_p2_4

p2_blank_line42:
	STA $4280 + $800,X
	DEY
p2_blank_pcsm42:
        BMI blank_early_out_p2_4

p2_blank_line43:
	STA $4280 + $C00,X
	DEY
p2_blank_pcsm43:
        BMI blank_early_out_p2_4
	BVC blank_early_out_p2_5_skip	; always taken
blank_early_out_p2_5:
	RTS
blank_early_out_p2_5_skip:

p2_blank_line44:
	STA $4280 + $1000,X
	DEY
p2_blank_pcsm44:
        BMI blank_early_out_p2_5

p2_blank_line45:
	STA $4280 + $1400,X
	DEY
p2_blank_pcsm45:
        BMI blank_early_out_p2_5

p2_blank_line46:
	STA $4280 + $1800,X
	DEY
p2_blank_pcsm46:
        BMI blank_early_out_p2_5

p2_blank_line47:
	STA $4280 + $1C00,X
	DEY
p2_blank_pcsm47:
        BMI blank_early_out_p2_5

p2_blank_line48:
	STA $4300 + $0,X
	DEY
p2_blank_pcsm48:
        BMI blank_early_out_p2_5

p2_blank_line49:
	STA $4300 + $400,X
	DEY
p2_blank_pcsm49:
        BMI blank_early_out_p2_5

p2_blank_line50:
	STA $4300 + $800,X
	DEY
p2_blank_pcsm50:
        BMI blank_early_out_p2_5

p2_blank_line51:
	STA $4300 + $C00,X
	DEY
p2_blank_pcsm51:
        BMI blank_early_out_p2_5

p2_blank_line52:
	STA $4300 + $1000,X
	DEY
p2_blank_pcsm52:
        BMI blank_early_out_p2_5

p2_blank_line53:
	STA $4300 + $1400,X
	DEY
p2_blank_pcsm53:
        BMI blank_early_out_p2_5

p2_blank_line54:
	STA $4300 + $1800,X
	DEY
p2_blank_pcsm54:
        BMI blank_early_out_p2_5
	BVC blank_early_out_p2_6_skip	; always taken
blank_early_out_p2_6:
	RTS
blank_early_out_p2_6_skip:

p2_blank_line55:
	STA $4300 + $1C00,X
	DEY
p2_blank_pcsm55:
        BMI blank_early_out_p2_6

p2_blank_line56:
	STA $4380 + $0,X
	DEY
p2_blank_pcsm56:
        BMI blank_early_out_p2_6

p2_blank_line57:
	STA $4380 + $400,X
	DEY
p2_blank_pcsm57:
        BMI blank_early_out_p2_6

p2_blank_line58:
	STA $4380 + $800,X
	DEY
p2_blank_pcsm58:
        BMI blank_early_out_p2_6

p2_blank_line59:
	STA $4380 + $C00,X
	DEY
p2_blank_pcsm59:
        BMI blank_early_out_p2_6

p2_blank_line60:
	STA $4380 + $1000,X
	DEY
p2_blank_pcsm60:
        BMI blank_early_out_p2_6

p2_blank_line61:
	STA $4380 + $1400,X
	DEY
p2_blank_pcsm61:
        BMI blank_early_out_p2_6

p2_blank_line62:
	STA $4380 + $1800,X
	DEY
p2_blank_pcsm62:
        BMI blank_early_out_p2_6

p2_blank_line63:
	STA $4380 + $1C00,X
	DEY
p2_blank_pcsm63:
        BMI blank_early_out_p2_6

p2_blank_line64:
	STA $4028 + $0,X
	DEY
p2_blank_pcsm64:
        BMI blank_early_out_p2_6

p2_blank_line65:
	STA $4028 + $400,X
	DEY
p2_blank_pcsm65:
        BMI blank_early_out_p2_6
	BVC blank_early_out_p2_7_skip	; always taken
blank_early_out_p2_7:
	RTS
blank_early_out_p2_7_skip:

p2_blank_line66:
	STA $4028 + $800,X
	DEY
p2_blank_pcsm66:
        BMI blank_early_out_p2_7

p2_blank_line67:
	STA $4028 + $C00,X
	DEY
p2_blank_pcsm67:
        BMI blank_early_out_p2_7

p2_blank_line68:
	STA $4028 + $1000,X
	DEY
p2_blank_pcsm68:
        BMI blank_early_out_p2_7

p2_blank_line69:
	STA $4028 + $1400,X
	DEY
p2_blank_pcsm69:
        BMI blank_early_out_p2_7

p2_blank_line70:
	STA $4028 + $1800,X
	DEY
p2_blank_pcsm70:
        BMI blank_early_out_p2_7

p2_blank_line71:
	STA $4028 + $1C00,X
	DEY
p2_blank_pcsm71:
        BMI blank_early_out_p2_7

p2_blank_line72:
	STA $40A8 + $0,X
	DEY
p2_blank_pcsm72:
        BMI blank_early_out_p2_7

p2_blank_line73:
	STA $40A8 + $400,X
	DEY
p2_blank_pcsm73:
        BMI blank_early_out_p2_7

p2_blank_line74:
	STA $40A8 + $800,X
	DEY
p2_blank_pcsm74:
        BMI blank_early_out_p2_7

p2_blank_line75:
	STA $40A8 + $C00,X
	DEY
p2_blank_pcsm75:
        BMI blank_early_out_p2_7

p2_blank_line76:
	STA $40A8 + $1000,X
	DEY
p2_blank_pcsm76:
        BMI blank_early_out_p2_7
	BVC blank_early_out_p2_8_skip	; always taken
blank_early_out_p2_8:
	RTS
blank_early_out_p2_8_skip:

p2_blank_line77:
	STA $40A8 + $1400,X
	DEY
p2_blank_pcsm77:
        BMI blank_early_out_p2_8

p2_blank_line78:
	STA $40A8 + $1800,X
	DEY
p2_blank_pcsm78:
        BMI blank_early_out_p2_8

p2_blank_line79:
	STA $40A8 + $1C00,X
	DEY
p2_blank_pcsm79:
        BMI blank_early_out_p2_8

p2_blank_line80:
	STA $4128 + $0,X
	DEY
p2_blank_pcsm80:
        BMI blank_early_out_p2_8

p2_blank_line81:
	STA $4128 + $400,X
	DEY
p2_blank_pcsm81:
        BMI blank_early_out_p2_8

p2_blank_line82:
	STA $4128 + $800,X
	DEY
p2_blank_pcsm82:
        BMI blank_early_out_p2_8

p2_blank_line83:
	STA $4128 + $C00,X
	DEY
p2_blank_pcsm83:
        BMI blank_early_out_p2_8

p2_blank_line84:
	STA $4128 + $1000,X
	DEY
p2_blank_pcsm84:
        BMI blank_early_out_p2_8

p2_blank_line85:
	STA $4128 + $1400,X
	DEY
p2_blank_pcsm85:
        BMI blank_early_out_p2_8

p2_blank_line86:
	STA $4128 + $1800,X
	DEY
p2_blank_pcsm86:
        BMI blank_early_out_p2_8

p2_blank_line87:
	STA $4128 + $1C00,X
	DEY
p2_blank_pcsm87:
        BMI blank_early_out_p2_8
	BVC blank_early_out_p2_9_skip	; always taken
blank_early_out_p2_9:
	RTS
blank_early_out_p2_9_skip:

p2_blank_line88:
	STA $41A8 + $0,X
	DEY
p2_blank_pcsm88:
        BMI blank_early_out_p2_9

p2_blank_line89:
	STA $41A8 + $400,X
	DEY
p2_blank_pcsm89:
        BMI blank_early_out_p2_9

p2_blank_line90:
	STA $41A8 + $800,X
	DEY
p2_blank_pcsm90:
        BMI blank_early_out_p2_9

p2_blank_line91:
	STA $41A8 + $C00,X
	DEY
p2_blank_pcsm91:
        BMI blank_early_out_p2_9

p2_blank_line92:
	STA $41A8 + $1000,X
	DEY
p2_blank_pcsm92:
        BMI blank_early_out_p2_9

p2_blank_line93:
	STA $41A8 + $1400,X
	DEY
p2_blank_pcsm93:
        BMI blank_early_out_p2_9

p2_blank_line94:
	STA $41A8 + $1800,X
	DEY
p2_blank_pcsm94:
        BMI blank_early_out_p2_9

p2_blank_line95:
	STA $41A8 + $1C00,X
	DEY
p2_blank_pcsm95:
        BMI blank_early_out_p2_9

p2_blank_line96:
	STA $4228 + $0,X
	DEY
p2_blank_pcsm96:
        BMI blank_early_out_p2_9

p2_blank_line97:
	STA $4228 + $400,X
	DEY
p2_blank_pcsm97:
        BMI blank_early_out_p2_9

p2_blank_line98:
	STA $4228 + $800,X
	DEY
p2_blank_pcsm98:
        BMI blank_early_out_p2_9
	BVC blank_early_out_p2_10_skip	; always taken
blank_early_out_p2_10:
	RTS
blank_early_out_p2_10_skip:

p2_blank_line99:
	STA $4228 + $C00,X
	DEY
p2_blank_pcsm99:
        BMI blank_early_out_p2_10

p2_blank_line100:
	STA $4228 + $1000,X
	DEY
p2_blank_pcsm100:
        BMI blank_early_out_p2_10

p2_blank_line101:
	STA $4228 + $1400,X
	DEY
p2_blank_pcsm101:
        BMI blank_early_out_p2_10

p2_blank_line102:
	STA $4228 + $1800,X
	DEY
p2_blank_pcsm102:
        BMI blank_early_out_p2_10

p2_blank_line103:
	STA $4228 + $1C00,X
	DEY
p2_blank_pcsm103:
        BMI blank_early_out_p2_10

p2_blank_line104:
	STA $42A8 + $0,X
	DEY
p2_blank_pcsm104:
        BMI blank_early_out_p2_10

p2_blank_line105:
	STA $42A8 + $400,X
	DEY
p2_blank_pcsm105:
        BMI blank_early_out_p2_10

p2_blank_line106:
	STA $42A8 + $800,X
	DEY
p2_blank_pcsm106:
        BMI blank_early_out_p2_10

p2_blank_line107:
	STA $42A8 + $C00,X
	DEY
p2_blank_pcsm107:
        BMI blank_early_out_p2_10

p2_blank_line108:
	STA $42A8 + $1000,X
	DEY
p2_blank_pcsm108:
        BMI blank_early_out_p2_10

p2_blank_line109:
	STA $42A8 + $1400,X
	DEY
p2_blank_pcsm109:
        BMI blank_early_out_p2_10
	BVC blank_early_out_p2_11_skip	; always taken
blank_early_out_p2_11:
	RTS
blank_early_out_p2_11_skip:

p2_blank_line110:
	STA $42A8 + $1800,X
	DEY
p2_blank_pcsm110:
        BMI blank_early_out_p2_11

p2_blank_line111:
	STA $42A8 + $1C00,X
	DEY
p2_blank_pcsm111:
        BMI blank_early_out_p2_11

p2_blank_line112:
	STA $4328 + $0,X
	DEY
p2_blank_pcsm112:
        BMI blank_early_out_p2_11

p2_blank_line113:
	STA $4328 + $400,X
	DEY
p2_blank_pcsm113:
        BMI blank_early_out_p2_11

p2_blank_line114:
	STA $4328 + $800,X
	DEY
p2_blank_pcsm114:
        BMI blank_early_out_p2_11

p2_blank_line115:
	STA $4328 + $C00,X
	DEY
p2_blank_pcsm115:
        BMI blank_early_out_p2_11

p2_blank_line116:
	STA $4328 + $1000,X
	DEY
p2_blank_pcsm116:
        BMI blank_early_out_p2_11

p2_blank_line117:
	STA $4328 + $1400,X
	DEY
p2_blank_pcsm117:
        BMI blank_early_out_p2_11

p2_blank_line118:
	STA $4328 + $1800,X
	DEY
p2_blank_pcsm118:
        BMI blank_early_out_p2_11

p2_blank_line119:
	STA $4328 + $1C00,X
	DEY
p2_blank_pcsm119:
        BMI blank_early_out_p2_11

p2_blank_line120:
	STA $43A8 + $0,X
	DEY
p2_blank_pcsm120:
        BMI blank_early_out_p2_11
	BVC blank_early_out_p2_12_skip	; always taken
blank_early_out_p2_12:
	RTS
blank_early_out_p2_12_skip:

p2_blank_line121:
	STA $43A8 + $400,X
	DEY
p2_blank_pcsm121:
        BMI blank_early_out_p2_12

p2_blank_line122:
	STA $43A8 + $800,X
	DEY
p2_blank_pcsm122:
        BMI blank_early_out_p2_12

p2_blank_line123:
	STA $43A8 + $C00,X
	DEY
p2_blank_pcsm123:
        BMI blank_early_out_p2_12

p2_blank_line124:
	STA $43A8 + $1000,X
	DEY
p2_blank_pcsm124:
        BMI blank_early_out_p2_12

p2_blank_line125:
	STA $43A8 + $1400,X
	DEY
p2_blank_pcsm125:
        BMI blank_early_out_p2_12

p2_blank_line126:
	STA $43A8 + $1800,X
	DEY
p2_blank_pcsm126:
        BMI blank_early_out_p2_12

p2_blank_line127:
	STA $43A8 + $1C00,X
	DEY
p2_blank_pcsm127:
        BMI blank_early_out_p2_12

p2_blank_line128:
	STA $4050 + $0,X
	DEY
p2_blank_pcsm128:
        BMI blank_early_out_p2_12

p2_blank_line129:
	STA $4050 + $400,X
	DEY
p2_blank_pcsm129:
        BMI blank_early_out_p2_12

p2_blank_line130:
	STA $4050 + $800,X
	DEY
p2_blank_pcsm130:
        BMI blank_early_out_p2_12

p2_blank_line131:
	STA $4050 + $C00,X
	DEY
p2_blank_pcsm131:
        BMI blank_early_out_p2_12
	BVC blank_early_out_p2_13_skip	; always taken
blank_early_out_p2_13:
	RTS
blank_early_out_p2_13_skip:

p2_blank_line132:
	STA $4050 + $1000,X
	DEY
p2_blank_pcsm132:
        BMI blank_early_out_p2_13

p2_blank_line133:
	STA $4050 + $1400,X
	DEY
p2_blank_pcsm133:
        BMI blank_early_out_p2_13

p2_blank_line134:
	STA $4050 + $1800,X
	DEY
p2_blank_pcsm134:
        BMI blank_early_out_p2_13

p2_blank_line135:
	STA $4050 + $1C00,X
	DEY
p2_blank_pcsm135:
        BMI blank_early_out_p2_13

p2_blank_line136:
	STA $40D0 + $0,X
	DEY
p2_blank_pcsm136:
        BMI blank_early_out_p2_13

p2_blank_line137:
	STA $40D0 + $400,X
	DEY
p2_blank_pcsm137:
        BMI blank_early_out_p2_13

p2_blank_line138:
	STA $40D0 + $800,X
	DEY
p2_blank_pcsm138:
        BMI blank_early_out_p2_13

p2_blank_line139:
	STA $40D0 + $C00,X
	DEY
p2_blank_pcsm139:
        BMI blank_early_out_p2_13

p2_blank_line140:
	STA $40D0 + $1000,X
	DEY
p2_blank_pcsm140:
        BMI blank_early_out_p2_13

p2_blank_line141:
	STA $40D0 + $1400,X
	DEY
p2_blank_pcsm141:
        BMI blank_early_out_p2_13

p2_blank_line142:
	STA $40D0 + $1800,X
	DEY
p2_blank_pcsm142:
        BMI blank_early_out_p2_13
	BVC blank_early_out_p2_14_skip	; always taken
blank_early_out_p2_14:
	RTS
blank_early_out_p2_14_skip:

p2_blank_line143:
	STA $40D0 + $1C00,X
	DEY
p2_blank_pcsm143:
        BMI blank_early_out_p2_14

p2_blank_line144:
	STA $4150 + $0,X
	DEY
p2_blank_pcsm144:
        BMI blank_early_out_p2_14

p2_blank_line145:
	STA $4150 + $400,X
	DEY
p2_blank_pcsm145:
        BMI blank_early_out_p2_14

p2_blank_line146:
	STA $4150 + $800,X
	DEY
p2_blank_pcsm146:
        BMI blank_early_out_p2_14

p2_blank_line147:
	STA $4150 + $C00,X
	DEY
p2_blank_pcsm147:
        BMI blank_early_out_p2_14

p2_blank_line148:
	STA $4150 + $1000,X
	DEY
p2_blank_pcsm148:
        BMI blank_early_out_p2_14

p2_blank_line149:
	STA $4150 + $1400,X
	DEY
p2_blank_pcsm149:
        BMI blank_early_out_p2_14

p2_blank_line150:
	STA $4150 + $1800,X
	DEY
p2_blank_pcsm150:
        BMI blank_early_out_p2_14

p2_blank_line151:
	STA $4150 + $1C00,X
	DEY
p2_blank_pcsm151:
        BMI blank_early_out_p2_14

p2_blank_line152:
	STA $41D0 + $0,X
	DEY
p2_blank_pcsm152:
        BMI blank_early_out_p2_14

p2_blank_line153:
	STA $41D0 + $400,X
	DEY
p2_blank_pcsm153:
        BMI blank_early_out_p2_14
	BVC blank_early_out_p2_15_skip	; always taken
blank_early_out_p2_15:
	RTS
blank_early_out_p2_15_skip:

p2_blank_line154:
	STA $41D0 + $800,X
	DEY
p2_blank_pcsm154:
        BMI blank_early_out_p2_15

p2_blank_line155:
	STA $41D0 + $C00,X
	DEY
p2_blank_pcsm155:
        BMI blank_early_out_p2_15

p2_blank_line156:
	STA $41D0 + $1000,X
	DEY
p2_blank_pcsm156:
        BMI blank_early_out_p2_15

p2_blank_line157:
	STA $41D0 + $1400,X
	DEY
p2_blank_pcsm157:
        BMI blank_early_out_p2_15

p2_blank_line158:
	STA $41D0 + $1800,X
	DEY
p2_blank_pcsm158:
        BMI blank_early_out_p2_15

p2_blank_line159:
	STA $41D0 + $1C00,X
	DEY
p2_blank_pcsm159:
        BMI blank_early_out_p2_15

p2_blank_line160:
	STA $4250 + $0,X
	DEY
p2_blank_pcsm160:
        BMI blank_early_out_p2_15

p2_blank_line161:
	STA $4250 + $400,X
	DEY
p2_blank_pcsm161:
        BMI blank_early_out_p2_15

p2_blank_line162:
	STA $4250 + $800,X
	DEY
p2_blank_pcsm162:
        BMI blank_early_out_p2_15

p2_blank_line163:
	STA $4250 + $C00,X
	DEY
p2_blank_pcsm163:
        BMI blank_early_out_p2_15

p2_blank_line164:
	STA $4250 + $1000,X
	DEY
p2_blank_pcsm164:
        BMI blank_early_out_p2_15
	BVC blank_early_out_p2_16_skip	; always taken
blank_early_out_p2_16:
	RTS
blank_early_out_p2_16_skip:

p2_blank_line165:
	STA $4250 + $1400,X
	DEY
p2_blank_pcsm165:
        BMI blank_early_out_p2_16

p2_blank_line166:
	STA $4250 + $1800,X
	DEY
p2_blank_pcsm166:
        BMI blank_early_out_p2_16

p2_blank_line167:
	STA $4250 + $1C00,X
	DEY
p2_blank_pcsm167:
        BMI blank_early_out_p2_16

p2_blank_line168:
	STA $42D0 + $0,X
	DEY
p2_blank_pcsm168:
        BMI blank_early_out_p2_16

p2_blank_line169:
	STA $42D0 + $400,X
	DEY
p2_blank_pcsm169:
        BMI blank_early_out_p2_16

p2_blank_line170:
	STA $42D0 + $800,X
	DEY
p2_blank_pcsm170:
        BMI blank_early_out_p2_16

p2_blank_line171:
	STA $42D0 + $C00,X
	DEY
p2_blank_pcsm171:
        BMI blank_early_out_p2_16

p2_blank_line172:
	STA $42D0 + $1000,X
	DEY
p2_blank_pcsm172:
        BMI blank_early_out_p2_16

p2_blank_line173:
	STA $42D0 + $1400,X
	DEY
p2_blank_pcsm173:
        BMI blank_early_out_p2_16

p2_blank_line174:
	STA $42D0 + $1800,X
	DEY
p2_blank_pcsm174:
        BMI blank_early_out_p2_16

p2_blank_line175:
	STA $42D0 + $1C00,X
	DEY
p2_blank_pcsm175:
        BMI blank_early_out_p2_16
	BVC blank_early_out_p2_17_skip	; always taken
blank_early_out_p2_17:
	RTS
blank_early_out_p2_17_skip:

p2_blank_line176:
	STA $4350 + $0,X
	DEY
p2_blank_pcsm176:
        BMI blank_early_out_p2_17

p2_blank_line177:
	STA $4350 + $400,X
	DEY
p2_blank_pcsm177:
        BMI blank_early_out_p2_17

p2_blank_line178:
	STA $4350 + $800,X
	DEY
p2_blank_pcsm178:
        BMI blank_early_out_p2_17

p2_blank_line179:
	STA $4350 + $C00,X
	DEY
p2_blank_pcsm179:
        BMI blank_early_out_p2_17

p2_blank_line180:
	STA $4350 + $1000,X
	DEY
p2_blank_pcsm180:
        BMI blank_early_out_p2_17

p2_blank_line181:
	STA $4350 + $1400,X
	DEY
p2_blank_pcsm181:
        BMI blank_early_out_p2_17

p2_blank_line182:
	STA $4350 + $1800,X
	DEY
p2_blank_pcsm182:
        BMI blank_early_out_p2_17

p2_blank_line183:
	STA $4350 + $1C00,X
	DEY
p2_blank_pcsm183:
        BMI blank_early_out_p2_17

p2_blank_line184:
	STA $43D0 + $0,X
	DEY
p2_blank_pcsm184:
        BMI blank_early_out_p2_17

p2_blank_line185:
	STA $43D0 + $400,X
	DEY
p2_blank_pcsm185:
        BMI blank_early_out_p2_17

p2_blank_line186:
	STA $43D0 + $800,X
	DEY
p2_blank_pcsm186:
        BMI blank_early_out_p2_17
	BVC blank_early_out_p2_18_skip	; always taken
blank_early_out_p2_18:
	RTS
blank_early_out_p2_18_skip:

p2_blank_line187:
	STA $43D0 + $C00,X
	DEY
p2_blank_pcsm187:
        BMI blank_early_out_p2_18

p2_blank_line188:
	STA $43D0 + $1000,X
	DEY
p2_blank_pcsm188:
        BMI blank_early_out_p2_18

p2_blank_line189:
	STA $43D0 + $1400,X
	DEY
p2_blank_pcsm189:
        BMI blank_early_out_p2_18

p2_blank_line190:
	STA $43D0 + $1800,X
	DEY
p2_blank_pcsm190:
        BMI blank_early_out_p2_18

p2_blank_line191:
	STA $43D0 + $1C00,X
	DEY
p2_blank_pcsm191:
        BMI blank_early_out_p2_18
	RTS
p2_blank_line_ptrs_lo:
	.byte <p2_blank_line0	; 0
	.byte <p2_blank_line1	; 1
	.byte <p2_blank_line2	; 2
	.byte <p2_blank_line3	; 3
	.byte <p2_blank_line4	; 4
	.byte <p2_blank_line5	; 5
	.byte <p2_blank_line6	; 6
	.byte <p2_blank_line7	; 7
	.byte <p2_blank_line8	; 8
	.byte <p2_blank_line9	; 9
	.byte <p2_blank_line10	; 10
	.byte <p2_blank_line11	; 11
	.byte <p2_blank_line12	; 12
	.byte <p2_blank_line13	; 13
	.byte <p2_blank_line14	; 14
	.byte <p2_blank_line15	; 15
	.byte <p2_blank_line16	; 16
	.byte <p2_blank_line17	; 17
	.byte <p2_blank_line18	; 18
	.byte <p2_blank_line19	; 19
	.byte <p2_blank_line20	; 20
	.byte <p2_blank_line21	; 21
	.byte <p2_blank_line22	; 22
	.byte <p2_blank_line23	; 23
	.byte <p2_blank_line24	; 24
	.byte <p2_blank_line25	; 25
	.byte <p2_blank_line26	; 26
	.byte <p2_blank_line27	; 27
	.byte <p2_blank_line28	; 28
	.byte <p2_blank_line29	; 29
	.byte <p2_blank_line30	; 30
	.byte <p2_blank_line31	; 31
	.byte <p2_blank_line32	; 32
	.byte <p2_blank_line33	; 33
	.byte <p2_blank_line34	; 34
	.byte <p2_blank_line35	; 35
	.byte <p2_blank_line36	; 36
	.byte <p2_blank_line37	; 37
	.byte <p2_blank_line38	; 38
	.byte <p2_blank_line39	; 39
	.byte <p2_blank_line40	; 40
	.byte <p2_blank_line41	; 41
	.byte <p2_blank_line42	; 42
	.byte <p2_blank_line43	; 43
	.byte <p2_blank_line44	; 44
	.byte <p2_blank_line45	; 45
	.byte <p2_blank_line46	; 46
	.byte <p2_blank_line47	; 47
	.byte <p2_blank_line48	; 48
	.byte <p2_blank_line49	; 49
	.byte <p2_blank_line50	; 50
	.byte <p2_blank_line51	; 51
	.byte <p2_blank_line52	; 52
	.byte <p2_blank_line53	; 53
	.byte <p2_blank_line54	; 54
	.byte <p2_blank_line55	; 55
	.byte <p2_blank_line56	; 56
	.byte <p2_blank_line57	; 57
	.byte <p2_blank_line58	; 58
	.byte <p2_blank_line59	; 59
	.byte <p2_blank_line60	; 60
	.byte <p2_blank_line61	; 61
	.byte <p2_blank_line62	; 62
	.byte <p2_blank_line63	; 63
	.byte <p2_blank_line64	; 64
	.byte <p2_blank_line65	; 65
	.byte <p2_blank_line66	; 66
	.byte <p2_blank_line67	; 67
	.byte <p2_blank_line68	; 68
	.byte <p2_blank_line69	; 69
	.byte <p2_blank_line70	; 70
	.byte <p2_blank_line71	; 71
	.byte <p2_blank_line72	; 72
	.byte <p2_blank_line73	; 73
	.byte <p2_blank_line74	; 74
	.byte <p2_blank_line75	; 75
	.byte <p2_blank_line76	; 76
	.byte <p2_blank_line77	; 77
	.byte <p2_blank_line78	; 78
	.byte <p2_blank_line79	; 79
	.byte <p2_blank_line80	; 80
	.byte <p2_blank_line81	; 81
	.byte <p2_blank_line82	; 82
	.byte <p2_blank_line83	; 83
	.byte <p2_blank_line84	; 84
	.byte <p2_blank_line85	; 85
	.byte <p2_blank_line86	; 86
	.byte <p2_blank_line87	; 87
	.byte <p2_blank_line88	; 88
	.byte <p2_blank_line89	; 89
	.byte <p2_blank_line90	; 90
	.byte <p2_blank_line91	; 91
	.byte <p2_blank_line92	; 92
	.byte <p2_blank_line93	; 93
	.byte <p2_blank_line94	; 94
	.byte <p2_blank_line95	; 95
	.byte <p2_blank_line96	; 96
	.byte <p2_blank_line97	; 97
	.byte <p2_blank_line98	; 98
	.byte <p2_blank_line99	; 99
	.byte <p2_blank_line100	; 100
	.byte <p2_blank_line101	; 101
	.byte <p2_blank_line102	; 102
	.byte <p2_blank_line103	; 103
	.byte <p2_blank_line104	; 104
	.byte <p2_blank_line105	; 105
	.byte <p2_blank_line106	; 106
	.byte <p2_blank_line107	; 107
	.byte <p2_blank_line108	; 108
	.byte <p2_blank_line109	; 109
	.byte <p2_blank_line110	; 110
	.byte <p2_blank_line111	; 111
	.byte <p2_blank_line112	; 112
	.byte <p2_blank_line113	; 113
	.byte <p2_blank_line114	; 114
	.byte <p2_blank_line115	; 115
	.byte <p2_blank_line116	; 116
	.byte <p2_blank_line117	; 117
	.byte <p2_blank_line118	; 118
	.byte <p2_blank_line119	; 119
	.byte <p2_blank_line120	; 120
	.byte <p2_blank_line121	; 121
	.byte <p2_blank_line122	; 122
	.byte <p2_blank_line123	; 123
	.byte <p2_blank_line124	; 124
	.byte <p2_blank_line125	; 125
	.byte <p2_blank_line126	; 126
	.byte <p2_blank_line127	; 127
	.byte <p2_blank_line128	; 128
	.byte <p2_blank_line129	; 129
	.byte <p2_blank_line130	; 130
	.byte <p2_blank_line131	; 131
	.byte <p2_blank_line132	; 132
	.byte <p2_blank_line133	; 133
	.byte <p2_blank_line134	; 134
	.byte <p2_blank_line135	; 135
	.byte <p2_blank_line136	; 136
	.byte <p2_blank_line137	; 137
	.byte <p2_blank_line138	; 138
	.byte <p2_blank_line139	; 139
	.byte <p2_blank_line140	; 140
	.byte <p2_blank_line141	; 141
	.byte <p2_blank_line142	; 142
	.byte <p2_blank_line143	; 143
	.byte <p2_blank_line144	; 144
	.byte <p2_blank_line145	; 145
	.byte <p2_blank_line146	; 146
	.byte <p2_blank_line147	; 147
	.byte <p2_blank_line148	; 148
	.byte <p2_blank_line149	; 149
	.byte <p2_blank_line150	; 150
	.byte <p2_blank_line151	; 151
	.byte <p2_blank_line152	; 152
	.byte <p2_blank_line153	; 153
	.byte <p2_blank_line154	; 154
	.byte <p2_blank_line155	; 155
	.byte <p2_blank_line156	; 156
	.byte <p2_blank_line157	; 157
	.byte <p2_blank_line158	; 158
	.byte <p2_blank_line159	; 159
	.byte <p2_blank_line160	; 160
	.byte <p2_blank_line161	; 161
	.byte <p2_blank_line162	; 162
	.byte <p2_blank_line163	; 163
	.byte <p2_blank_line164	; 164
	.byte <p2_blank_line165	; 165
	.byte <p2_blank_line166	; 166
	.byte <p2_blank_line167	; 167
	.byte <p2_blank_line168	; 168
	.byte <p2_blank_line169	; 169
	.byte <p2_blank_line170	; 170
	.byte <p2_blank_line171	; 171
	.byte <p2_blank_line172	; 172
	.byte <p2_blank_line173	; 173
	.byte <p2_blank_line174	; 174
	.byte <p2_blank_line175	; 175
	.byte <p2_blank_line176	; 176
	.byte <p2_blank_line177	; 177
	.byte <p2_blank_line178	; 178
	.byte <p2_blank_line179	; 179
	.byte <p2_blank_line180	; 180
	.byte <p2_blank_line181	; 181
	.byte <p2_blank_line182	; 182
	.byte <p2_blank_line183	; 183
	.byte <p2_blank_line184	; 184
	.byte <p2_blank_line185	; 185
	.byte <p2_blank_line186	; 186
	.byte <p2_blank_line187	; 187
	.byte <p2_blank_line188	; 188
	.byte <p2_blank_line189	; 189
	.byte <p2_blank_line190	; 190
	.byte <p2_blank_line191	; 191
p2_blank_line_ptrs_hi:
	.byte >p2_blank_line0	; 0
	.byte >p2_blank_line1	; 1
	.byte >p2_blank_line2	; 2
	.byte >p2_blank_line3	; 3
	.byte >p2_blank_line4	; 4
	.byte >p2_blank_line5	; 5
	.byte >p2_blank_line6	; 6
	.byte >p2_blank_line7	; 7
	.byte >p2_blank_line8	; 8
	.byte >p2_blank_line9	; 9
	.byte >p2_blank_line10	; 10
	.byte >p2_blank_line11	; 11
	.byte >p2_blank_line12	; 12
	.byte >p2_blank_line13	; 13
	.byte >p2_blank_line14	; 14
	.byte >p2_blank_line15	; 15
	.byte >p2_blank_line16	; 16
	.byte >p2_blank_line17	; 17
	.byte >p2_blank_line18	; 18
	.byte >p2_blank_line19	; 19
	.byte >p2_blank_line20	; 20
	.byte >p2_blank_line21	; 21
	.byte >p2_blank_line22	; 22
	.byte >p2_blank_line23	; 23
	.byte >p2_blank_line24	; 24
	.byte >p2_blank_line25	; 25
	.byte >p2_blank_line26	; 26
	.byte >p2_blank_line27	; 27
	.byte >p2_blank_line28	; 28
	.byte >p2_blank_line29	; 29
	.byte >p2_blank_line30	; 30
	.byte >p2_blank_line31	; 31
	.byte >p2_blank_line32	; 32
	.byte >p2_blank_line33	; 33
	.byte >p2_blank_line34	; 34
	.byte >p2_blank_line35	; 35
	.byte >p2_blank_line36	; 36
	.byte >p2_blank_line37	; 37
	.byte >p2_blank_line38	; 38
	.byte >p2_blank_line39	; 39
	.byte >p2_blank_line40	; 40
	.byte >p2_blank_line41	; 41
	.byte >p2_blank_line42	; 42
	.byte >p2_blank_line43	; 43
	.byte >p2_blank_line44	; 44
	.byte >p2_blank_line45	; 45
	.byte >p2_blank_line46	; 46
	.byte >p2_blank_line47	; 47
	.byte >p2_blank_line48	; 48
	.byte >p2_blank_line49	; 49
	.byte >p2_blank_line50	; 50
	.byte >p2_blank_line51	; 51
	.byte >p2_blank_line52	; 52
	.byte >p2_blank_line53	; 53
	.byte >p2_blank_line54	; 54
	.byte >p2_blank_line55	; 55
	.byte >p2_blank_line56	; 56
	.byte >p2_blank_line57	; 57
	.byte >p2_blank_line58	; 58
	.byte >p2_blank_line59	; 59
	.byte >p2_blank_line60	; 60
	.byte >p2_blank_line61	; 61
	.byte >p2_blank_line62	; 62
	.byte >p2_blank_line63	; 63
	.byte >p2_blank_line64	; 64
	.byte >p2_blank_line65	; 65
	.byte >p2_blank_line66	; 66
	.byte >p2_blank_line67	; 67
	.byte >p2_blank_line68	; 68
	.byte >p2_blank_line69	; 69
	.byte >p2_blank_line70	; 70
	.byte >p2_blank_line71	; 71
	.byte >p2_blank_line72	; 72
	.byte >p2_blank_line73	; 73
	.byte >p2_blank_line74	; 74
	.byte >p2_blank_line75	; 75
	.byte >p2_blank_line76	; 76
	.byte >p2_blank_line77	; 77
	.byte >p2_blank_line78	; 78
	.byte >p2_blank_line79	; 79
	.byte >p2_blank_line80	; 80
	.byte >p2_blank_line81	; 81
	.byte >p2_blank_line82	; 82
	.byte >p2_blank_line83	; 83
	.byte >p2_blank_line84	; 84
	.byte >p2_blank_line85	; 85
	.byte >p2_blank_line86	; 86
	.byte >p2_blank_line87	; 87
	.byte >p2_blank_line88	; 88
	.byte >p2_blank_line89	; 89
	.byte >p2_blank_line90	; 90
	.byte >p2_blank_line91	; 91
	.byte >p2_blank_line92	; 92
	.byte >p2_blank_line93	; 93
	.byte >p2_blank_line94	; 94
	.byte >p2_blank_line95	; 95
	.byte >p2_blank_line96	; 96
	.byte >p2_blank_line97	; 97
	.byte >p2_blank_line98	; 98
	.byte >p2_blank_line99	; 99
	.byte >p2_blank_line100	; 100
	.byte >p2_blank_line101	; 101
	.byte >p2_blank_line102	; 102
	.byte >p2_blank_line103	; 103
	.byte >p2_blank_line104	; 104
	.byte >p2_blank_line105	; 105
	.byte >p2_blank_line106	; 106
	.byte >p2_blank_line107	; 107
	.byte >p2_blank_line108	; 108
	.byte >p2_blank_line109	; 109
	.byte >p2_blank_line110	; 110
	.byte >p2_blank_line111	; 111
	.byte >p2_blank_line112	; 112
	.byte >p2_blank_line113	; 113
	.byte >p2_blank_line114	; 114
	.byte >p2_blank_line115	; 115
	.byte >p2_blank_line116	; 116
	.byte >p2_blank_line117	; 117
	.byte >p2_blank_line118	; 118
	.byte >p2_blank_line119	; 119
	.byte >p2_blank_line120	; 120
	.byte >p2_blank_line121	; 121
	.byte >p2_blank_line122	; 122
	.byte >p2_blank_line123	; 123
	.byte >p2_blank_line124	; 124
	.byte >p2_blank_line125	; 125
	.byte >p2_blank_line126	; 126
	.byte >p2_blank_line127	; 127
	.byte >p2_blank_line128	; 128
	.byte >p2_blank_line129	; 129
	.byte >p2_blank_line130	; 130
	.byte >p2_blank_line131	; 131
	.byte >p2_blank_line132	; 132
	.byte >p2_blank_line133	; 133
	.byte >p2_blank_line134	; 134
	.byte >p2_blank_line135	; 135
	.byte >p2_blank_line136	; 136
	.byte >p2_blank_line137	; 137
	.byte >p2_blank_line138	; 138
	.byte >p2_blank_line139	; 139
	.byte >p2_blank_line140	; 140
	.byte >p2_blank_line141	; 141
	.byte >p2_blank_line142	; 142
	.byte >p2_blank_line143	; 143
	.byte >p2_blank_line144	; 144
	.byte >p2_blank_line145	; 145
	.byte >p2_blank_line146	; 146
	.byte >p2_blank_line147	; 147
	.byte >p2_blank_line148	; 148
	.byte >p2_blank_line149	; 149
	.byte >p2_blank_line150	; 150
	.byte >p2_blank_line151	; 151
	.byte >p2_blank_line152	; 152
	.byte >p2_blank_line153	; 153
	.byte >p2_blank_line154	; 154
	.byte >p2_blank_line155	; 155
	.byte >p2_blank_line156	; 156
	.byte >p2_blank_line157	; 157
	.byte >p2_blank_line158	; 158
	.byte >p2_blank_line159	; 159
	.byte >p2_blank_line160	; 160
	.byte >p2_blank_line161	; 161
	.byte >p2_blank_line162	; 162
	.byte >p2_blank_line163	; 163
	.byte >p2_blank_line164	; 164
	.byte >p2_blank_line165	; 165
	.byte >p2_blank_line166	; 166
	.byte >p2_blank_line167	; 167
	.byte >p2_blank_line168	; 168
	.byte >p2_blank_line169	; 169
	.byte >p2_blank_line170	; 170
	.byte >p2_blank_line171	; 171
	.byte >p2_blank_line172	; 172
	.byte >p2_blank_line173	; 173
	.byte >p2_blank_line174	; 174
	.byte >p2_blank_line175	; 175
	.byte >p2_blank_line176	; 176
	.byte >p2_blank_line177	; 177
	.byte >p2_blank_line178	; 178
	.byte >p2_blank_line179	; 179
	.byte >p2_blank_line180	; 180
	.byte >p2_blank_line181	; 181
	.byte >p2_blank_line182	; 182
	.byte >p2_blank_line183	; 183
	.byte >p2_blank_line184	; 184
	.byte >p2_blank_line185	; 185
	.byte >p2_blank_line186	; 186
	.byte >p2_blank_line187	; 187
	.byte >p2_blank_line188	; 188
	.byte >p2_blank_line189	; 189
	.byte >p2_blank_line190	; 190
	.byte >p2_blank_line191	; 191
