;;; Most of the code below is a disassembly of the original Prodos
;;; So it's obviously not covered my the GPL license like the rest
;;; of this project.

;;; DiskII : 300 rpm
;;; 16 sectors per track
;;; 300 rpm => 5 rps => 80 sectors per seconds
;;; 35*16*256 = 143360 bytes per side

TRACKS_PER_SIDE		= 35
BYTES_PER_SECTOR 	= 256
SECTORS_PER_TRACK 	= 16

MOTOR_ON	= $C089
DRIVE_SELECT	= $0	; 0 == drive 1; $80 = drive 2
SLOT_SELECT	= $60	; 0 (drive 1) 110 (slot 6) 0000

; Prodos stuff

buf              =        $38
wtemp            =        $3a
midnib1          =        wtemp+1
midnib2          =        wtemp+2
lstnib           =        wtemp+3
slotz            =        wtemp + 4
yend             =        wtemp+5

phaseoff         =        $c080                     ;stepper phase off.
unitnum          =        $43


	;.export distance_to_next_sector, read_sector_status ;, sector_status
	.export rdadr16, seek, read16, buf, curtrk ; current_track,

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


drvindx: pha                                              ;preserve acc.
                lda          unitnum        ; for example : 0 (drive 1) 110 (slot 6) 0000
                lsr
                lsr
                lsr
                lsr
                cmp          #$8
                and          #$7 ; drive-slot -> slot-drives
                rol
                tax                                              ;into x for index to table
                pla                                              ;restore acc.
                rts

; ====================================================================

myseek: asl                                          ;assume two phase stepper.
                sta          track                            ;save destination track(*2)
                jsr          alloff                           ;turn all phases off to be sure.
                jsr          drvindx                          ;get index to previous track for current drive
                lda          drv0trk,x
                sta          curtrk                           ;this is where i am
                lda          track                            ;and where i'm going to
                sta          drv0trk,x
                jsr          seek                             ;go there!
alloff: ldy          #3                               ;turn off all phases before returning
nxoff: tya                                           ;(send phase in acc.)
                jsr          clrphase                         ;carry is clear, phases shold be turned off
                dey
                bpl          nxoff
                lsr          curtrk                           ;divide back down
                clc
                rts                                           ;all off... now it's dark


; **************************
; *                        *
; * fast seek subroutine *
; **************************
; *                        *
; *    on entry ----   *
; *                        *
; * x-reg holds slotnum    *
; *         times $10.     *
; *                        *
; * a-reg holds desired    *
; *         halftrack.     *
; *         (single phase) *
; *                        *
; * curtrk holds current *
; *          halftrack.    *
; *                        *
; *    on exit -----   *
; *                        *
; * a-reg uncertain.       *
; * y-reg uncertain.       *
; * x-reg undisturbed.     *
; *                        *
; * curtrk and trkn hold *
; *      final halftrack. *
; *                        *
; * prior holds prior      *
; *    halftrack if seek   *
; *    was required.       *
; *                        *
; * montimel and montimeh *
; *    are incremented by *
; *    the number of       *
; *    100 usec quantums   *
; *    required by seek    *
; *    for motor on time   *
; *    overlap.            *
; *                        *
; * --- variables used --- *
; *                        *
; * curtrk, trkn, count, *
; *    prior, slottemp     *
; *    montimel, montimeh *
; *                        *
; **************************

ibtrk: .byte            $00
ibsect: .byte            $00
ibstat: .byte            $00
iobpdn: .byte            $00
curtrk: .byte            $00
drv0trk          =           *-2
                .byte         0,0,0,0,0,0,0                 ;for slots 1 thru 7
                .byte         0,0,0,0,0,0,0                   ;drives 1 & 2

retrycnt:	.REPEAT 1
	.BYTE 0
.ENDREP

seekcnt:	.REPEAT 1
	.BYTE 0
.ENDREP

; *
; ************************
; *                        *
; *     readadr----    *
; *                        *
; ************************
;count             =        *                               ;'must find' count.

count:	.BYTE 0

last:	.REPEAT 1
	.BYTE 0
.ENDREP

csum:	.REPEAT 1
	.BYTE 0
.ENDREP

csstv:	.REPEAT 4
	.BYTE 0
.ENDREP

; *        checksum, sector, track, and volume.
sect              =        csstv+1
track             =        csstv+2
volume            =        csstv+3
; *
trkcnt            =        count                           ;halftrks moved count.
prior:	.REPEAT 1
	.BYTE 0
.ENDREP

trkn:	.REPEAT 1
	.BYTE 0
.ENDREP

	.export sect ;, old_sect

; **************************
; *                          *
; * phase on-, off-time      *
; *    tables in 100-usec    *
; *    intervals. (seek)     *
; *                          *
; **************************
ontable: .byte         1,$30,$28
                  .byte         $24,$20,$1e
                  .byte         $1d,$1c,$1c
offtable: .byte         $70,$2c,$26
                  .byte         $22,$1f,$1e
                  .byte         $1d,$1c,$1c

seek: sta             trkn                          ;save target track
                cmp             curtrk                        ;on desired track?
        beq             setphase                      ;yes,energize phase and return

                lda             #$0
                sta             trkcnt                        ;halftrack count.
seek2:
	        lda             curtrk                        ;save curtrk for
                sta             prior                         ;delayed turnoff.
                sec
                sbc             trkn                          ;delta-tracks.
                beq             seekend                       ;br if curtrk=destination
                bcs             out                           ;(move out, not in)
                eor             #$ff                          ;calc trks to go.
                inc             curtrk                        ;incr current track (in).
                bcc             mintst                        ;(always taken)
out: adc             #$fe                          ;calc trks to go.
                dec             curtrk                        ;decr current track (out).
mintst: cmp             trkcnt
        bcc             maxtst                        ; and 'trks moved'.

                lda             trkcnt
maxtst: cmp             #$9
                bcs             step2                         ;if trkcnt>$8 leave y alone (y=$8).
                tay                                           ;else set acceleration index in y
                sec
step2: jsr             setphase
                lda             ontable,y                     ;for 'ontime'.
                jsr             mswait                        ;(100 usec intervals)
                lda             prior
                clc                                           ;for phaseoff
                jsr             clrphase                      ;turn off prior phase
                lda             offtable,y                    ; then wait 'offtime'.
                jsr             mswait                        ;(100 usec intervals)
                inc             trkcnt                        ; 'tracks moved' count.
                bne             seek2                         ;(always taken)
seekend:
		jsr             mswait                        ;settle 25 msec
                clc                                           ;set for phase off

setphase: lda             curtrk                        ;get current track
clrphase: and             #3                            ;mask for 1 of 4 phases
                rol                                           ;double for phaseon/off index
                ora             slotz
                tax
                lda             phaseoff,x                    ;turn on/off one phase
                ldx             slotz                         ;restore x-reg
                rts                                           ;and return

; *
; **************************
; *                          *
; *    mswait subroutine     *
; *                          *
; **************************
; *                          *
; * delays a specified       *
; *    number of 100 usec    *
; *    intervals for motor *
; *    on timing.            *
; *                          *
; *     on entry ----    *
; *                          *
; * a-reg: holds number      *
; *         of 100 usec      *
; *         intervals to     *
; *         delay.           *
; *                          *

; *     on exit -----   *
; *                         *
; * a-reg: holds $00.       *
; * x-reg: holds $00.       *
; * y-reg: unchanged.       *
; * carry: set.             *
; *                         *
; * montimel, montimeh      *
; *    are incremented once *
; *    per 100 usec interval*
; *    for moton on timing. *
; *                         *
; *     assumes ----    *
; *                         *
; *    1 usec cycle time    *
; *                         *
; **************************
montimel          =        csstv+2                         ;motor-on time
montimeh          =        montimel+1                      ;counters.

mswait: ldx              #$11
msw1: dex              ;delay                        ; 86 usec.
                 bne              msw1
                 inc              montimel
                 bne              msw2                          ;double-byte
                 inc              montimeh                      ;increment.
msw2: sec ;s
                 sbc              #$1                           ;done 'n' intervals?
                 bne              mswait                        ;(a-reg counts)
                 rts



	.align 256

; ****************************
; *                          *
; *    read address field    *
; *        subroutine        *
; *    (16-sector format)    *
; *                          *
; ****************************
; *                          *
; *    reads volume, track   *
; *        and sector        *
; *                          *
; *    on entry ----     *
; *                          *
; * xreg: slotnum times $10 *
; *                          *
; * read mode (q6l, q7l)     *
; *                          *
; *    on exit -----     *
; *                          *
; * carry set if error.      *
; *                          *
; * if no error:             *
; *    a-reg holds $aa.      *
; *    y-reg holds $00.      *
; *    x-reg unchanged.      *
; *    carry clear.          *
; *                          *
; *    csstv holds chksum,   *
; *      sector, track, and *
; *      volume read.        *
; *                          *
; *    uses temps count,     *
; *      last, csum, and     *
; *      4 bytes at csstv.   *
; *                          *
; *     expects ----     *
; *                          *
; *   original 10-sector     *
; * normal density nibls     *
; *   (4-bit), odd bits,     *
; *   then even.             *
; *                          *
; *     caution ----     *
; *                          *
; *         observe          *
; *    'no page cross'       *
; *      warnings on         *
; *    some branches!!       *
; *                          *
; *     assumes ----     *
; *                          *
; *    1 usec cycle time     *

; *                           *
; ****************************

q6l = $c08c

;; Read here https://www.bigmessowires.com/2015/08/27/apple-ii-copy-protection/
;; Every three bytes read, there's an additional one for disk encoding reason
;; So if I read 768 times, that's 768 nibbles => 576 bytes => this can read up to two consecutive sectors I guess

; d = count - $FC gives number of wait loops before finding signature $D5 $AA $96
; if d == 0; then less than $FF - $FC (4) loops
; if d == 1 : between 4 and 256+4 loops

; A sector takes 12500 usec, a frame is 100000 usec => I should be able to read 8 sectors in one frame

rdadr16:
	ldy          #$fc                ; will count -4,-3,-2,-1,0 (three times) then three (count) times 256 => 768+3 = 771 counts
        sty          count                           ;'must find' count.

        lda sect
        ;sta old_sect

rdasyn: iny
        bne          rda1                            ;low order of count.
        inc          count                           ;(2k nibls to find
        beq          rderr                           ; adr mark, else err)

	;; Check for first byte of D5 AA 96 sequence
rda1:
	lda          q6l,x                           ;read nibl.
        bpl 	     rda1                            ;*** no page cross! ***
rdasn1:
	cmp          #$d5                            ;adr mark 1?
        bne          rdasyn                          ;(loop if not)

        nop                                          ;added nibl delay.

rda2: 	lda          q6l,x
        bpl          rda2                            ;*** no page cross! ***
        cmp          #$aa                            ;adr mark 2?
        bne          rdasn1                          ; (if not, is it am1?)


        ldy          #$3                             ;index for 4-byte read. WIZ!!! checksum, sector, track, and volume.
; *             (added nibl delay)
rda3: 	lda          q6l,x
        bpl          rda3                            ;*** no page cross! ***
        cmp          #$96                            ;adr mark 3?
        bne          rdasn1                          ; (if not, is it am1?)

	;sty count2                                         ; WIZ !!!

	sei                                          ;no interupts until address is tested.(carry is set)

        lda          #$0                             ;init checksum.
rdafld:
	sta          csum
rda4:
	lda          q6l,x                           ;read 'odd bit' nibl.
        bpl          rda4                            ;*** no page cross! ***
        rol                                          ;align odd bits, '1' into lsb.
        sta          last                            ; (save them)
rda5:
	lda          q6l,x                           ;read 'even bit' nibl.
        bpl          rda5                            ;*** no page cross! ***
        and          last                            ;merge odd and even bits.
        sta          csstv,y                         ;store data byte.
        eor          csum
        dey
        bpl          rdafld                          ;loop on 4 data bytes.

                 tay                                          ;if final checksum
                 bne          rderr                           ;nonzero, then error.
rda6: lda          q6l,x                           ;first bit-slip nibl.
                 bpl          rda6                            ;*** no page cross! ***
                 cmp          #$de
                 bne          rderr                           ;error if nonmatch.
                 nop                                          ;delay
rda7: lda          q6l,x                           ;second bit-slip nibl.
                 bpl          rda7                            ;*** no page cross! ***
                 cmp          #$aa
                 beq          rdgood                           ;error if nonmatch.
rderr: sec
                 rts

rdgood:
	clc
	rts



.align 256
; **************************
; *                         *
; *      read subroutine    *
; *    (16-sector format)   *
; *                         *
; **************************
; *                        *
; *    reads encoded bytes *
; * into nbuf1 and nbuf2   *
; *                        *
; * first reads nbuf2      *
; *           high to low, *
; * then reads nbuf1       *
; *           low to high. *
; *                        *
; *    on entry ----    *
; *                        *
; * x-reg: slotnum         *
; *          times $10.    *
; *                        *
; * read mode (q6l, q7l) *
; *                        *
; *    on exit -----    *
; *                        *
; * carry set if error.    *
; *                        *
; * if no error:           *
; *      a-reg holds $aa.  *
; *      x-reg unchanged.  *
; *      y-reg holds $00.  *
; *      carry clear.      *
; *    caution -----    *
; *                        *
; *         observe        *
; *    'no page cross'     *
; *       warnings on      *
; *    some branches!!     *
; *                        *
; *    assumes ----     *
; *                        *
; *   1 usec cycle time    *
; *                        *
; **************************
dnibl           =            *-$96
                .byte             $00,$04
                .byte             $ff,$ff,$08,$0c
                .byte             $ff,$10,$14,$18
twobit3: .byte             $00,$80,$40,$c0               ;used in fast prenib as lookup for 2-
; bit quantities.
                .byte             $ff,$ff,$1c,$20
                .byte             $ff,$ff,$ff,$24
                .byte             $28,$2c,$30,$34
                .byte             $ff,$ff,$38,$3c
                .byte             $40,$44,$48,$4c
                .byte             $ff,$50,$54,$58
                .byte             $5c,$60,$64,$68
twobit2: .byte             $00,$20,$10,$30               ;used in fast prenib.
endmrks: .byte             $de,$aa,$eb,$ff               ;table using 'unused' nibls
; ($c4,$c5,$c6,$c7)
                .byte             $ff,$ff,$ff,$6c
                .byte             $ff,$70,$74,$78
                .byte             $ff,$ff,$ff,$7c
                .byte             $ff,$ff,$80,$84
                .byte             $ff,$88,$8c,$90
                .byte             $94,$98,$9c,$a0
twobit1: .byte             $00,$08,$04,$0c               ;used in fast prenib.
                .byte             $ff,$a4,$a8,$ac
                .byte             $ff,$b0,$b4,$b8
                .byte             $bc,$c0,$c4,$c8
                .byte             $ff,$ff,$cc,$d0
                .byte             $d4,$d8,$dc,$e0
                .byte             $ff,$e4,$e8,$ec
                .byte             $f0,$f4,$f8,$fc


dnibl2: .byte            0
dnibl3: .byte            0
dnibl4: .byte            0
nibl: .byte            $96,2,0,0,$97
                 .byte            1,0,0,$9a,3,0,0,$9b
                 .byte            0,2,0,$9d,2,2,0,$9e
                 .byte            1,2,0,$9f,3,2,0,$a6
                 .byte            0,1,0,$a7,2,1,0,$ab
                 .byte            1,1,0,$ac,3,1,0,$ad
                 .byte            0,3,0,$ae,2,3,0,$af
                 .byte            1,3,0,$b2,3,3,0,$b3
                 .byte            0,0,2,$b4,2,0,2,$b5
                 .byte            1,0,2,$b6,3,0,2,$b7
                 .byte            0,2,2,$b9,2,2,2,$ba
                 .byte            1,2,2,$bb,3,2,2,$bc
                 .byte            0,1,2,$bd,2,1,2,$be
                 .byte            1,1,2,$bf,3,1,2,$cb
                 .byte            0,3,2,$cd,2,3,2,$ce
                 .byte            1,3,2,$cf,3,3,2,$d3
                 .byte            0,0,1,$d6,2,0,1,$d7
                 .byte            1,0,1,$d9,3,0,1,$da
                 .byte            0,2,1,$db,2,2,1,$dc
                 .byte            1,2,1,$dd,3,2,1,$de
                 .byte            0,1,1,$df,2,1,1,$e5
                 .byte            1,1,1,$e6,3,1,1,$e7
                 .byte            0,3,1,$e9,2,3,1,$ea
                 .byte            1,3,1,$eb,3,3,1,$ec
                 .byte            0,0,3,$ed,2,0,3,$ee
                 .byte            1,0,3,$ef,3,0,3,$f2
                 .byte            0,2,3,$f3,2,2,3,$f4
                 .byte            1,2,3,$f5,3,2,3,$f6
                 .byte            0,1,3,$f7,2,1,3,$f9
                 .byte            1,1,3,$fa,3,1,3,$fb
                 .byte            0,3,3,$fc,2,3,3,$fd
                 .byte            1,3,3,$fe,3,3,3,$ff
; *
nbuf2:	.REPEAT $56
	.BYTE 0
.ENDREP



	.align 256

read16: txa                                         ;get slot #.
                  ora           #$8c                          ;prepare mods to read routine.
                  sta           rd4+1                         ;warning: the read routine is self modified!!!
                  sta           rd5+1
                  sta           rd6+1
                  sta           rd7+1
                  sta           rd8+1
                  lda           buf                           ;modify storage addresses also.
                  ldy           buf+1
                  sta           ref3+1
                  sty           ref3+2
                  sec
                  sbc           #$54
                  bcs           rd16b                         ;branch if no borrow.
                  dey
rd16b: sta           ref2+1
                  sty           ref2+2
                  sec
                  sbc           #$57
                  bcs           rd16c                         ;branch if no borrow.
                  dey
rd16c: sta           ref1+1
                  sty           ref1+2
                  ldy           #$20                          ;'must find count'
rsync: dey
                  beq           rderr2                        ;branch if can't find data header
; marks.
rd1: lda           q6l,x

                    bpl            rd1
rsync1: eor            #$d5                          ;first data mark.
                    bne            rsync
                    nop                                          ;waste a little time...
rd2: lda            q6l,x
                    bpl            rd2
                    cmp            #$aa                          ;data mark 2
                    bne            rsync1                        ;if not, check for first again.
                    nop
rd3: lda            q6l,x
                    bpl            rd3
                    cmp            #$ad                          ;data mark 3
                    bne            rsync1                        ;if not, check for data mark 1 again.
                    ldy            #$aa
                    lda            #0
rdata1: sta            wtemp                         ;use zpage for checksum keeping.
rd4: ldx            $c0ec                         ;warning: self modified.
                    bpl            rd4
                    lda            dnibl,x
                    sta            nbuf2-$aa,y                   ;save the two-bit groups in nbuf.
                    eor            wtemp                         ;update checksum.
                    iny                                          ;bump to next nbuf position.
                    bne            rdata1                        ;loop for all $56 two-bit groups.
                    ldy            #$aa                          ;now read directly into user buffer.
                    bne            rd5                           ;branch always taken!!!
; *
rderr2: sec
                    rts
; *
ref1: sta            $1000,y                       ;warning: self modified!
; *
rd5: ldx            $c0ec
                    bpl            rd5
                    eor            dnibl,x                       ;get actual 6-bit data from dnib table.
                    ldx            nbuf2-$aa,y                   ;get associated two-bit pattern.
                    eor            dnibl2,x                      ;and combine to form whole byte.
                    iny
                    bne            ref1                          ;loop for $56 bytes.
                    pha                                          ;save this byte for now, no time to
; store...
                    and            #$fc                          ;strip low bits...
                    ldy            #$aa                          ;prepare for next $56 bytes.
rd6: ldx            $c0ec
                    bpl            rd6
                    eor            dnibl,x
                    ldx            nbuf2-$aa,y
                    eor            dnibl3,x
ref2: sta            $1000,y                       ;warning: self modified.
                    iny
                    bne            rd6                           ;loop until this group of $56 read in.
; *
rd7: ldx            $c0ec
                    bpl            rd7
                    and            #$fc
                    ldy            #$ac                          ;last group is $54 long.
rdata2: eor            dnibl,x
                    ldx            nbuf2-$ac,y
                    eor            dnibl4,x                      ;combine to form full byte.
ref3: sta            $1000,y
rd8: ldx            $c0ec                         ;warning: self modified.
                    bpl            rd8
                    iny
                    bne            rdata2

                    and            #$fc
                    eor            dnibl,x                       ;check sum ok?
                    bne            rderr1                        ;branch if not.
                    ldx            slotz                         ;test end marks.
rd9: lda            q6l,x
                    bpl            rd9
                    cmp            #$de
                    clc
                    beq            rdok                          ;branch if good trailer...
rderr1: sec
rdok: pla                                          ;place last byte into user buffer.
                    ldy            #$55
                    sta            (buf),y
                    rts
