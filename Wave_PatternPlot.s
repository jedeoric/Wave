;Wave_PatternPlot.s

;   0123456789012345678901234567890123456789
;00 -Top-Menu-------------------------------
;01 ------------Song   Beethoven -----------
;02  L00 P01 P02 P03 E01 --- --- --- --- ---
;03 -------------Pattern 03-----------------
;04 Nm S Eg8 N N#O VOSCP N#O VOSCP N#O VOSCP
;05 00 - --- - RST ----- RST ----- RST -----
;06 01 - --- - RST ----- RST ----- RST -----
;07 02 - --- - RST ----- RST ----- RST -----
;08 03 - --- - RST ----- RST ----- RST -----
;09 04 - --- - RST ----- RST ----- RST -----
;10 05 - --- - RST ----- RST ----- RST -----
;11 06 - --- - RST ----- RST ----- RST -----<
;12 07 - --- - RST ----- RST ----- RST -----
;13 08 - --- - RST ----- RST ----- RST -----
;14 09 - --- - RST ----- RST ----- RST -----
;15 10 - --- - RST ----- RST ----- RST -----
;16 11 - --- - RST ----- RST ----- RST -----
;17 12 - --- - RST ----- RST ----- RST -----
PatternLegendText
 .byt "NM",2,"S",5,"EGC",2,"N",3,"N#O",6,"VEOCP",3,"N#O",6,"VEOCP",3,"N#O",6,"VEOCP"
RestorePatternLegend
	ldx #39
.(
loop1	lda PatternLegendText,x
	sta $BB80+40*4,x
	dex
	bpl loop1
.)
	rts
	
RestorePatternArea
	lda #<$BB80+40*5
	sta screen
	lda #>$BB80+40*5
	sta screen+1
	ldx #13
.(
loop2	ldy #39
loop1	lda EmptyPatternScreenRow,y
	sta (screen),y
	dey
	bpl loop1
	jsr nl_screen
	dex
	bne loop2
.)
	rts
	

PatternCursorPlot
	ldx PatternCursorX
	lda PatternRowFieldLength,x
	ldy PatternRowFieldOffset,x
	tax
.(
loop1	lda $BB80+11*40,y
	ora #128
	sta $BB80+11*40,y
	iny
	dex
	bne loop1
.)
	lda #20
	sta $BB80+2+11*40
	rts

ClearPatternScreenRow
	ldy #39
.(
loop1	lda EmptyPatternScreenRow,y
	sta (screen),y
	dey
	bpl loop1
.)
	rts
	
DisplayPatternID
	lda #<$BB80+10+40*3
	sta screen
	lda #>$BB80+10+40*3
	sta screen+1
	lda PatternID
	ldx #128
	ldy #00
	jmp Display2DD

EmptyPatternScreenRow
 .byt 8,8,2,8,5,8,8,8,2,8,3,8,8,8,6,8,8,8,8,8,3,8,8,8,6,8,8,8,8,8,3,8,8,8,6,8,8,8,8,8
;   04 Nm S Eg8 N N#O VOSCP N#O VOSCP N#O VOSCP
;05 00 - --- - RST ----- RST ----- RST -----
PatternRowFieldOffset
 .byt 3,5,7,9
 .byt 11,15,16,17,18,19
 .byt 21,25,26,27,28,29
 .byt 31,35,36,37,38,39
PatternRowFieldLength
 .byt 1,2,1,1
 .byt 3,1,1,1,1,1
 .byt 3,1,1,1,1,1
 .byt 3,1,1,1,1,1
PatternSourceRow	.byt 0
PatternScreenRows	.byt 0
PatternTempY	.byt 0

PatternPlot
	ldx PatternID
	lda #<$BB80+40*5
	sta screen
	lda #>$BB80+40*5
	sta screen+1
	lda #13
	sta PatternScreenRows
	
	lda PatternCursorY
	sec
	sbc #6
	sta PatternSourceRow
.(
	bcs loop3
loop1	jsr ClearPatternScreenRow
	jsr nl_screen
	dec PatternScreenRows
	inc PatternSourceRow
	bne loop1

loop3	;Display Row index
	ldy #00
	lda PatternSourceRow
	ldx #00
	jsr Display2DD

	ldy PatternSourceRow
	ldx PatternID
	lda PatternAddressLo,x
	clc
	adc PatternRowOffsetLo,y
	sta source
	lda PatternAddressHi,x
	adc PatternRowOffsetHi,y
	sta source+1
	
	;Detect Bar and branch if found
	ldy #2
	lda (source),y
	cmp #%11111100
	bcs skip5
	ldy #5
	lda (source),y
	cmp #%11111100
skip5	bcs skip1
	ldy #8
	lda (source),y
	cmp #%11111100
	bcs skip1

	;Clear inverse flags
	ldy #5
	lda #00
loop7	sta PatternFieldInverseFlags,y
	dey
	bpl loop7
	;Set Inverse flags if Highlighting enabled
	lda peHighlightingFlag
	beq skip3
	;Check we're on a highlighted row
	lda PatternSourceRow
	cmp peHighlightStartY
	bcc skip3
	cmp peHighlightEndY
	beq skip4
	bcs skip3
skip4	;Now flag the columns that are highlighted
	ldy peHighlightStartX
	lda #128
loop6	ldx X2InverseIndex,y
	sta PatternFieldInverseFlags,x
	iny
	cpy peHighlightEndX
	beq loop6
	bcc loop6
skip3

	ldy #0	;10
loop2	lda PatternFieldDisplayCodeLo,y
	sta vector1+1
	lda PatternFieldDisplayCodeHi,y
	sta vector1+2
	lda (source),y
	sty PatternTempY
vector1	jsr $dead
	ldy PatternTempY
	iny
	cpy #11
	bcc loop2
	
	jsr nl_screen
	
	dec PatternScreenRows
	beq skip2
	
	inc PatternSourceRow
	lda PatternSourceRow
	cmp #64
	bcs loop4
	jmp loop3
	;
loop4	jsr ClearPatternScreenRow
	jsr nl_screen
	dec PatternScreenRows
	bne loop4
skip2	rts	
skip1	;Display Bar row
	ldy #39
loop5	lda BarRowText,y
	sta (screen),y
	dey
	bpl loop5
	jsr nl_screen
	dec PatternScreenRows
	beq skip2
	jmp loop4
.)
X2InverseIndex
 .byt 0,1,1,2
 .byt 3,3,3,3,3,3
 .byt 4,4,4,4,4,4
 .byt 5,5,5,5,5,5
PatternFieldInverseFlags
 .dsb 6,0
BarRowText
 .byt "==",2,"=",5,"===",2,"=",3,"===",6,"=====",3,"===",6,"=====",3,"===",6,"====="
PatternAddressLo
 .byt <mmPatternMemory
 .byt <mmPatternMemory+704*1
 .byt <mmPatternMemory+704*2
 .byt <mmPatternMemory+704*3
 .byt <mmPatternMemory+704*4
 .byt <mmPatternMemory+704*5
 .byt <mmPatternMemory+704*6
 .byt <mmPatternMemory+704*7
 .byt <mmPatternMemory+704*8
 .byt <mmPatternMemory+704*9
 .byt <mmPatternMemory+704*10
 .byt <mmPatternMemory+704*11
 .byt <mmPatternMemory+704*12
 .byt <mmPatternMemory+704*13
 .byt <mmPatternMemory+704*14
 .byt <mmPatternMemory+704*15
 .byt <mmPatternMemory+704*16
 .byt <mmPatternMemory+704*17
 .byt <mmPatternMemory+704*18
 .byt <mmPatternMemory+704*19
 .byt <mmPatternMemory+704*20
 .byt <mmPatternMemory+704*21
 .byt <mmPatternMemory+704*22
 .byt <mmPatternMemory+704*23
;Sample Memory Sacrifice
 .byt <mmSampleMemory+448+704*10
 .byt <mmSampleMemory+448+704*9 
 .byt <mmSampleMemory+448+704*8 
 .byt <mmSampleMemory+448+704*7 
 .byt <mmSampleMemory+448+704*6 
 .byt <mmSampleMemory+448+704*5 
 .byt <mmSampleMemory+448+704*4 
 .byt <mmSampleMemory+448+704*3 
 .byt <mmSampleMemory+448+704*2 
 .byt <mmSampleMemory+448+704*1 
 .byt <mmSampleMemory+448

PatternAddressHi
 .byt >mmPatternMemory
 .byt >mmPatternMemory+704*1
 .byt >mmPatternMemory+704*2
 .byt >mmPatternMemory+704*3
 .byt >mmPatternMemory+704*4
 .byt >mmPatternMemory+704*5
 .byt >mmPatternMemory+704*6
 .byt >mmPatternMemory+704*7
 .byt >mmPatternMemory+704*8
 .byt >mmPatternMemory+704*9
 .byt >mmPatternMemory+704*10
 .byt >mmPatternMemory+704*11
 .byt >mmPatternMemory+704*12
 .byt >mmPatternMemory+704*13
 .byt >mmPatternMemory+704*14
 .byt >mmPatternMemory+704*15
 .byt >mmPatternMemory+704*16
 .byt >mmPatternMemory+704*17
 .byt >mmPatternMemory+704*18
 .byt >mmPatternMemory+704*19
 .byt >mmPatternMemory+704*20
 .byt >mmPatternMemory+704*21
 .byt >mmPatternMemory+704*22
 .byt >mmPatternMemory+704*23

 .byt >mmSampleMemory+448+704*10
 .byt >mmSampleMemory+448+704*9 
 .byt >mmSampleMemory+448+704*8 
 .byt >mmSampleMemory+448+704*7 
 .byt >mmSampleMemory+448+704*6 
 .byt >mmSampleMemory+448+704*5 
 .byt >mmSampleMemory+448+704*4 
 .byt >mmSampleMemory+448+704*3 
 .byt >mmSampleMemory+448+704*2 
 .byt >mmSampleMemory+448+704*1 
 .byt >mmSampleMemory+448

PatternRowOffsetLo
 .byt 0
 .byt <11*1
 .byt <11*2
 .byt <11*3
 .byt <11*4
 .byt <11*5
 .byt <11*6
 .byt <11*7
 .byt <11*8
 .byt <11*9
 .byt <11*10
 .byt <11*11
 .byt <11*12
 .byt <11*13
 .byt <11*14
 .byt <11*15
 .byt <11*16
 .byt <11*17
 .byt <11*18
 .byt <11*19
 .byt <11*20
 .byt <11*21
 .byt <11*22
 .byt <11*23
 .byt <11*24
 .byt <11*25
 .byt <11*26
 .byt <11*27
 .byt <11*28
 .byt <11*29
 .byt <11*30
 .byt <11*31
 .byt <11*32
 .byt <11*33
 .byt <11*34
 .byt <11*35
 .byt <11*36
 .byt <11*37
 .byt <11*38
 .byt <11*39
 .byt <11*40
 .byt <11*41
 .byt <11*42
 .byt <11*43
 .byt <11*44
 .byt <11*45
 .byt <11*46
 .byt <11*47
 .byt <11*48
 .byt <11*49
 .byt <11*50
 .byt <11*51
 .byt <11*52
 .byt <11*53
 .byt <11*54
 .byt <11*55
 .byt <11*56
 .byt <11*57
 .byt <11*58
 .byt <11*59
 .byt <11*60
 .byt <11*61
 .byt <11*62
 .byt <11*63
PatternRowOffsetHi
 .byt 0
 .byt >11*1
 .byt >11*2
 .byt >11*3
 .byt >11*4
 .byt >11*5
 .byt >11*6
 .byt >11*7
 .byt >11*8
 .byt >11*9
 .byt >11*10
 .byt >11*11
 .byt >11*12
 .byt >11*13
 .byt >11*14
 .byt >11*15
 .byt >11*16
 .byt >11*17
 .byt >11*18
 .byt >11*19
 .byt >11*20
 .byt >11*21
 .byt >11*22
 .byt >11*23
 .byt >11*24
 .byt >11*25
 .byt >11*26
 .byt >11*27
 .byt >11*28
 .byt >11*29
 .byt >11*30
 .byt >11*31
 .byt >11*32
 .byt >11*33
 .byt >11*34
 .byt >11*35
 .byt >11*36
 .byt >11*37
 .byt >11*38
 .byt >11*39
 .byt >11*40
 .byt >11*41
 .byt >11*42
 .byt >11*43
 .byt >11*44
 .byt >11*45
 .byt >11*46
 .byt >11*47
 .byt >11*48
 .byt >11*49
 .byt >11*50
 .byt >11*51
 .byt >11*52
 .byt >11*53
 .byt >11*54
 .byt >11*55
 .byt >11*56
 .byt >11*57
 .byt >11*58
 .byt >11*59
 .byt >11*60
 .byt >11*61
 .byt >11*62
 .byt >11*63


PatternFieldDisplayCodeLo
 .byt <DisplayPatternsEGPeriodCycle	;EGPeriod + Cycle
 .byt <DisplayPatternsNoiseSample	;Noise + Sample
 .byt <DisplayPatternsNoteAVolume	;NoteA + Volume
 .byt <DisplayPatternsOrnamentAVolseq	;OrnamentA + VolseqA
 .byt <DisplayPatternsCommandAParam	;CommandA + ParamA
 .byt <DisplayPatternsNoteBVolume	;NoteB + Volume     
 .byt <DisplayPatternsOrnamentBVolseq	;OrnamentB + VolseqB
 .byt <DisplayPatternsCommandBParam	;CommandB + ParamB
 .byt <DisplayPatternsNoteCVolume	;NoteB + Volume     
 .byt <DisplayPatternsOrnamentCVolseq	;OrnamentB + VolseqB
 .byt <DisplayPatternsCommandCParam	;CommandB + ParamB
PatternFieldDisplayCodeHi
 .byt >DisplayPatternsEGPeriodCycle	;EGPeriod + Cycle
 .byt >DisplayPatternsNoiseSample	;Noise + Sample
 .byt >DisplayPatternsNoteAVolume	;NoteA + Volume
 .byt >DisplayPatternsOrnamentAVolseq	;OrnamentA + VolseqA
 .byt >DisplayPatternsCommandAParam	;CommandA + ParamA
 .byt >DisplayPatternsNoteBVolume	;NoteB + Volume     
 .byt >DisplayPatternsOrnamentBVolseq	;OrnamentB + VolseqB
 .byt >DisplayPatternsCommandBParam	;CommandB + ParamB
 .byt >DisplayPatternsNoteCVolume	;NoteB + Volume     
 .byt >DisplayPatternsOrnamentCVolseq	;OrnamentB + VolseqB
 .byt >DisplayPatternsCommandCParam	;CommandB + ParamB

DisplayPatternsEGPeriodCycle	;EGPeriod + Cycle
	;Display EGPeriod
	ldy #5
	pha
	lsr
	lsr
.(
	beq skip2
	sec
	sbc #1
	ldx PatternFieldInverseFlags+1
	jsr Display2DD
	jmp skip1
skip2	lda #"-"
	ora PatternFieldInverseFlags+1
	sta (screen),y
	iny
	sta (screen),y
skip1	;Display Cycle
.)
	pla
	and #3
	tay
	lda CycleCharacter,y
	ldy #7
	ora PatternFieldInverseFlags+1
	sta (screen),y
	rts

;Cycle
;0 -
;1 Sawtooth \/\/\/
;2 Triangle \|\|\|
;3 Decay    \_____

CycleCharacter
 .byt "-STD"

DisplayPatternsNoiseSample	;Noise + Sample
	;Display Noise
	ldy #"-"
	pha
	lsr
	lsr
	lsr
.(
	beq skip2
	cmp #10
	bcc skip1
	adc #6
skip1	adc #48
	tay
skip2	tya
.)
	ldy #9
	ora PatternFieldInverseFlags+2
	sta (screen),y
	
	;Display Sample
	ldy #"-"
	pla
	and #7
.(
	beq skip1
	sec
	sbc #1
	ora #48
	tay
skip1	tya
.)
	ora PatternFieldInverseFlags
	ldy #3
	sta (screen),y
	rts
	
DisplayPatternsNoteAVolume	;NoteA + Volume
	;Display
	ldy #10
	jmp CommonDisplayNoteAndVolume
	
DisplayPatternsOrnamentAVolseq	;OrnamentA + VolseqA
	;Display
	ldy #16
	jmp CommonDisplayOrnamentAndVolseq
DisplayPatternsCommandAParam	;CommandA + ParamA
	ldy #18
	jmp CommonDisplayCommandAndParam
DisplayPatternsNoteBVolume	;NoteB + Volume     
	;Display Note
	ldy #20
	jmp CommonDisplayNoteAndVolume
DisplayPatternsOrnamentBVolseq	;OrnamentB + VolseqB
	;Display
	ldy #26
	jmp CommonDisplayOrnamentAndVolseq
DisplayPatternsCommandBParam	;CommandB + ParamB
	ldy #28
	jmp CommonDisplayCommandAndParam
DisplayPatternsOrnamentCVolseq	;OrnamentB + VolseqB
	;Display
	ldy #36
	jmp CommonDisplayOrnamentAndVolseq
DisplayPatternsCommandCParam	;CommandB + ParamB
	ldy #38
	jmp CommonDisplayCommandAndParam
DisplayPatternsNoteCVolume	;NoteB + Volume     
	;Display Note
	ldy #30
CommonDisplayNoteAndVolume
	pha
	lsr
	lsr
	tax
	;Plot colour of note
	lda #3
	cpx #62
.(
	beq skip1
	lda #7
skip1	sta (screen),y
.)
	iny
	;At this point y(xpos) is 11,21,31 but we need to translate to 0,1,2 to get inverse index
	tya 	;11 21 31
	sty ppTemp01
	lsr 	;5  10 15
	lsr 	;2  5  7
	lsr 	;1  2  3
	tay
	lda PatternFieldInverseFlags+2,y
	ldy ppTemp01
	sta ppTemp01

	ora NoteText_Semitone,x
	sta (screen),y
	and #128
	iny
	ora NoteText_Sharp,x
	sta (screen),y
	and #128
	iny
	ora NoteText_Octave,x
	sta (screen),y
	;Plot colour of params (6/2)
	iny
	lda #6
	cpx #62	;RST
.(
	beq skip1
	lda #7
skip1	sta (screen),y
.)
	
	
	;Display Volume
	;If note..
	;0 0
	;1 4
	;2 8
	;3 F
	;If Rest..
	;0 0
	;1 -
	;2 ^
	;3 v
	;Note is in X
	iny
	cpx #62
.(
	bcs ppRestOrBar
	pla
	and #3
	tax
	lda PatternVolumeDigit,x
skip2	ora ppTemp01
	sta (screen),y
skip1	rts
ppRestOrBar
	bne skip1
	pla
	and #3
	tax
	lda PatternRestDigit,x
	jmp skip2
.)
	
PatternRestDigit
 .byt "0*)-"

CommonDisplayOrnamentAndVolseq
	;Display Effect
	pha
	and #15
	jsr Display1DHOrHyphen
	
	;Display Ornament
	iny
	pla
	lsr
	lsr
	lsr
	lsr
Display1DHOrHyphen
.(
	beq skip2
	sec
	sbc #1
	cmp #10
	bcc skip1
	adc #6
skip1	adc #48
	ora ppTemp01
	sta (screen),y
	rts
skip2	lda #"-"
.)
 	ora ppTemp01
 	sta (screen),y
 	rts

CommonDisplayCommandAndParam
	;Display Command
	pha
	and #7
.(
	beq skip1
	tax
	lda CommandDigit-1,x
 	ora ppTemp01
	sta (screen),y
	
	;Display Param
	iny
	pla
	lsr
	lsr
	lsr
	cmp #10
	bcc skip2
	adc #6
skip2	adc #48
 	ora ppTemp01
	sta (screen),y
	rts
skip1	pla
	lda #"-"
.)
 	ora ppTemp01
 	sta (screen),y
 	iny
 	sta (screen),y
 	rts



;1 C Apply Channel or Status SID to this channel		SID EOR Value(0-F) or Status(T)
;    Initial Volume - Note Volume
;2 Z Apply Buzzer SID to this channel			Cycle EOR Value(0-F)
;    Initial Cycle - EGC Cycle
;3 S Sample Behaviour(and apply to this channel)		Frac(0-F) or Note Synchronised(N)
;4 T Music Tempo					Tempo(0-31)
;5 B Pitchbend					Step(0-7)
;6 O Trigger Out					Value(0-31)
;7 - -




CommandDigit
 .byt "CZSTBO-"
ppTemp01
 .byt 0
NoteText_Semitone
 .byt "BCCDDEFFGGAA"
 .byt "BCCDDEFFGGAA"
 .byt "BCCDDEFFGGAA"
 .byt "BCCDDEFFGGAA"
 .byt "BCCDDEFFGGAA"
 .byt "BCRB"
NoteText_Sharp
 .byt "--#-#--#-#-#"
 .byt "--#-#--#-#-#"
 .byt "--#-#--#-#-#"
 .byt "--#-#--#-#-#"
 .byt "--#-#--#-#-#"
 .byt "--SA"
NoteText_Octave
 .byt "011111111111"
 .byt "122222222222"
 .byt "233333333333"
 .byt "344444444444"
 .byt "455555555555"
 .byt "56TR"
PatternVolumeDigit
 .byt "048F"
