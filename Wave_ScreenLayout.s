;ScreenLayout.s

DisplayScreenLayout
	lda #<ScreenLayout
	sta source
	lda #>ScreenLayout
	sta source+1
	lda #$80
	sta screen
	lda #$BB
	sta screen+1
	ldx #28
.(
loop2	ldy #39
loop1	lda (source),y
	sta (screen),y
	dey
	bpl loop1
	jsr nl_screen
	lda #40
	jsr add_source
	dex
	bne loop2
.)
	rts
	

;   0123456789012345678901234567890123456789
;00 -Top-Menu-------------------------------
;01 ------------Song   Beethoven -----------
;02  L00 P01 P02 P03 E01 --- --- --- --- ---
;03 -------------Pattern 03-----------------
;04 Nm S Eg8 N N#O VOSCP N#O VOSCP N#O VOSCP
;05 00 - 00T V RST ----- RST ----- RST -----
;06 00 - 00T V RST ----- RST ----- RST -----
;07 00 - 00T V RST ----- RST ----- RST -----
;08 00 - 00T V RST ----- RST ----- RST -----
;09 00 - 00T V RST ----- RST ----- RST -----
;10 00 - 00T V RST ----- RST ----- RST -----
;11 00 - 00T V RST ----- RST ----- RST -----<
;12 00 - 00T V RST ----- RST ----- RST -----
;13 00 - 00T V RST ----- RST ----- RST -----
;14 00 - 00T V RST ----- RST ----- RST -----
;15 00 - 00T V RST ----- RST ----- RST -----
;16 00 - 00T V RST ----- RST ----- RST -----
;17 00 - 00T V RST ----- RST ----- RST -----
;18 --SAMPLES--+---VOL-SEQ F----+-ORNAMENT--
;19 00 Sample01|00 +N +E +T P+05|00 L +00 XX
;20 01 Sample02|01 +N +E +T P+05|01   +01 XX
;21 02 Sample03|02 +N +E +T P+05|02   -01 XX
;22 03 Sample04|03 +N +E +T P+05|03   --- XX
;23 04 Sample05|04 +N +E +T P+05|04   --- XX
;24 05 Sample06|05 +N +E +T P+05|05   --- XX
;25 06 Sample07|06 +N +E +T P+05|06   --- XX
;26 07 Sample08|07 +N +E +T P+05|07   --- XX
;27 -------Status Bar-----------------------

ScreenLayout
;      0123456789012345678901234567890123456789
        
 .byt " FILE PLAY LIST PATS SMPS VLSQ ORNS HELP"
 .byt "------------Song:Unknown----------------"
 .byt "--- --- --- --- ---  --- --- --- --- ---"
 .byt "-------------Pattern 00-----------------"
 .byt "Nm S Eg8 N N#O VOECP N#O VOECP N#O VOECP"
 .byt "                                        "
 .byt "                                        "
 .byt "                                        "
 .byt "                                        "
 .byt "                                        "
 .byt "                                        "
 .byt "                                        "
 .byt "                                        "
 .byt "                                        "
 .byt "                                        "
 .byt "                                        "
 .byt "                                        "
 .byt "                                        "
 .byt "-----------+----EFFECT0-----+ORNAMENT0--"
 .byt "--SAMPLES--|                |        ",9,"AB"
 .byt "00         |                |        ",9,"CD"
 .byt "01         |                |        ",9,"EF"
 .byt "02         |                |        ",9,"GH"
 .byt "03         |                |        ",9,"IJ"
 .byt "04         |                |        ",9,"KL"
 .byt "05         |                |        ",9,"MN"
 .byt "06         |                |        ",9,"OP"
 .byt "-Please wait..                          "

RedefineAltChars
	ldx #127
.(
loop1	lda Wave0,x
	sta $B800+8*65,x
	dex
	bpl loop1
.)
	rts


Wave0
 .byt %000000
 .byt %000000
 .byt %000000
 .byt %000000
 .byt %000000
 .byt %000000
 .byt %000001
 .byt %000011

 .byt %000000
 .byt %000000
 .byt %000000
 .byt %001000
 .byt %011000
 .byt %011000
 .byt %011000
 .byt %011000

 .byt %000011
 .byt %001011
 .byt %011011
 .byt %111111
 .byt %011111
 .byt %001111
 .byt %000111
 .byt %000011

 .byt %011000
 .byt %011000
 .byt %011000
 .byt %111000
 .byt %111000
 .byt %111000
 .byt %111000
 .byt %111000

 .byt %000001
 .byt %000100
 .byt %000110
 .byt %000111
 .byt %000111
 .byt %000111
 .byt %000111
 .byt %000111

 .byt %111000
 .byt %111000
 .byt %011000
 .byt %001000
 .byt %100000
 .byt %110000
 .byt %111000
 .byt %111100

 .byt %000111
 .byt %000000
 .byt %000111
 .byt %000111
 .byt %000111
 .byt %000111
 .byt %000111
 .byt %000111

 .byt %111110
 .byt %001111
 .byt %111110
 .byt %111100
 .byt %111000
 .byt %110000
 .byt %100000
 .byt %001000

 .byt %000110
 .byt %000100
 .byt %000001
 .byt %000011
 .byt %000111
 .byt %001111
 .byt %011111
 .byt %111001

 .byt %011000
 .byt %111000
 .byt %111000
 .byt %111000
 .byt %111000
 .byt %111000
 .byt %111000
 .byt %000000

 .byt %011111
 .byt %001111
 .byt %000111
 .byt %000011
 .byt %000001
 .byt %000100
 .byt %000110
 .byt %000111

 .byt %111000
 .byt %111000
 .byt %111000
 .byt %111000
 .byt %111000
 .byt %111000
 .byt %011000
 .byt %001000

 .byt %000111
 .byt %000111
 .byt %000000
 .byt %000111
 .byt %000111
 .byt %000111
 .byt %000111
 .byt %000111

 .byt %100000
 .byt %110000
 .byt %111000
 .byt %111100
 .byt %111110
 .byt %111111
 .byt %111110
 .byt %111100

 .byt %000000
 .byt %000111
 .byt %000111
 .byt %000111
 .byt %000110
 .byt %000100
 .byt %000000
 .byt %000000

 .byt %111000
 .byt %110000
 .byt %100000
 .byt %000000
 .byt %000000
 .byt %000000
 .byt %000000
 .byt %000000

