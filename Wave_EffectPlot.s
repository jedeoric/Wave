;Wave_VolseqPlot.s

;   0123456789012345678901234567890123456789
;18 --SAMPLES--+---VOL-SEQ F----+-ORNAMENT--
;19 00 Sample01|00 +N +E +T P+05|00 L +00 XX
;20 01 Sample02|01 +N +E +T P+05|01   +01 XX
;21 02 Sample03|02 +N +E +T P+05|02   -01 XX
;22 03 Sample04|03 +N +E +T P+05|03   --- XX
;23 04 Sample05|04 +N +E +T P+05|04   --- XX
;24 05 Sample06|05 +N +E +T P+05|05   --- XX
;25 06 Sample07|06 +N +E +T P+05|06   --- XX
;26 07 Sample08|07 +N +E +T P+05|07   --- XX
;"00 +N +E +T P+05"
; 00 L -----------"
; 01   Noise Off  "
; 02   EG Off     "
; 03   Pitch +15  "
; 04   Noise -16  "
; 05 > Volume +15 "
; 06   EGPer +15  "
; 07   -----------"
DisplayEffectID
	lda #<$BB80+19+40*18
	sta screen
	lda #>$BB80+19+40*18
	sta screen+1
	lda EffectID
	ldx #128
	ldy #00
	jmp Display1DH

   
; B0-4
;  Offset (-16 to +15)
;  For end marks loop back offset(1-31) or End(0)
; B5-7
;  00 Loop or End(0)
;  01 Noise Off
;  02 EG Off
;  03 Tone Off
;  04 Volume Offset
;  05 Noise Offset +Noise On
;  06 EGPeriod Offset +EG On
;  07 Pitch Offset +Tone On


EffectCursorPlot
	ldx EffectCursorY
	lda EffectScreenRowAddressLo,x
	sta screen
	lda EffectScreenRowAddressHi,x
	sta screen+1
	ldy #8
.(
loop1	lda (screen),y
	ora #128
	sta (screen),y
	dey
	bpl loop1
.)
	rts

EffectScreenRowAddressLo
 .byt <$BB80+17+40*19
 .byt <$BB80+17+40*20
 .byt <$BB80+17+40*21
 .byt <$BB80+17+40*22
 .byt <$BB80+17+40*23
 .byt <$BB80+17+40*24
 .byt <$BB80+17+40*25
 .byt <$BB80+17+40*26
EffectScreenRowAddressHi
 .byt >$BB80+17+40*19
 .byt >$BB80+17+40*20
 .byt >$BB80+17+40*21
 .byt >$BB80+17+40*22
 .byt >$BB80+17+40*23
 .byt >$BB80+17+40*24
 .byt >$BB80+17+40*25
 .byt >$BB80+17+40*26
	

EffectPlot
	;
	lda #<$BB80+12+40*19
	sta screen
	lda #>$BB80+12+40*19
	sta screen+1
	lda #8
	sta ScreenRows
	
	lda EffectBaseIndex
	sta SourceIndex
	
	;Calculate Effect address into source
	jsr FetchEffectAddress

.(	
loop1	;Calculate if we need to highlight(inverse) this entry
	lda #00
	ldy eeHighlightingFlag
	beq skip6
	ldy SourceIndex
	cpy eeHighlightStartY
	bcc skip6
	cpy eeHighlightEndY
	beq skip7
	bcs skip6
skip7	lda #128
skip6	sta eeInverseFlag


	;Display Index
	lda SourceIndex
	ldy #00
	ldx eeInverseFlag
	jsr Display2DD

	;Display gap
	ldy #2
	lda #1
	ora eeInverseFlag
	sta (screen),y
	
	;If loop here
	;  Display "L"
	;If (entry AND 7 == 4 or 6)
	;  Display ">"
	;Else
	;  Display 8
	;end if
	ldy EffectID
	lda SourceIndex
	cmp mmEffectLoops,y
	bne skip4
	ldy #"L"
	jmp skip1
	
skip4	ldy SourceIndex
	lda (effect),y
	and #%11100000
	ldy #">"
	cmp #32*6
	beq skip1
	cmp #32*4
	beq skip1
	
	ldy #8
	
skip1	tya
	ldy #3
	ora eeInverseFlag
	sta (screen),y
	
	;Display Ink for change
	ldy SourceIndex
	lda (effect),y
	sta EffectTemp01
	and #%11100000
	lsr
	lsr
	lsr
	lsr
	lsr
	pha
	tay
	lda EffectActionColour,y
	ldy #4
	ora eeInverseFlag
	sta (screen),y
	
	;Locate Text
	pla
	tay
	lda EffectPlotTextLo,y	;Always 6 behind to sync with display offset
	sta text
	lda EffectPlotTextHi,y
	sta text+1
	
	;Display Text
	ldy #5
loop2	lda (text),y
	bpl skip2
	
	;Display Embedded Field
	lda EffectTemp01
	and #31
	jsr DisplaySigned5DD
	lda #7
skip2	ora eeInverseFlag
	sta (screen),y
skip3	iny
	cpy #14
	bcc loop2

	jsr nl_screen
	
	;If on End/Loop row then subsequent rows are redundant
;	ldy SourceIndex
;	lda (effect),y
;	and #7
;	beq skip5

	inc SourceIndex
	dec ScreenRows
	beq skip8
	jmp loop1
skip8	rts
skip5	;Display empty rows for remainder
.)
	inc SourceIndex
	dec ScreenRows
.(
	beq skip1
	
loop1	lda SourceIndex
	ldy #00
	ldx eeInverseFlag
	jsr Display2DD
	
	ldy #2
loop2	lda RedundantEffectRowsText-2,y
	ora eeInverseFlag
	sta (screen),y
	iny
	cpy #15
	bcc loop2
	
	jsr nl_screen
	inc SourceIndex
	dec ScreenRows
	bne loop1
skip1	rts
.)

RedundantEffectRowsText
 .byt "   -----------"
EffectActionColour
 .byt 7,1,2,3,6,1,2,3
 
;  1 Noise Off (Offset not used)
;  2 EG Off (Offset not used)
;  3 Tone Off (Offset not used)
;  4 Tone On and Volume Offset
;    If volume overlaps then ends Effect
;  5 Noise On and Noise Offset
;  6 EG On and EGPeriod Offset
;  7 Tone On and Pitch Offset

FetchEffectAddress
	lda EffectID
	asl
	asl
	asl
	asl
	asl
	sta effect
	lda #>mmEffectMemory
	adc #00
	sta effect+1
	lda effect
	adc #<mmEffectMemory
	sta effect
.(
	bcc skip1
	inc effect+1
skip1	;Now setup Y to the index in effect
.)
	lda EffectCursorY
	clc
	adc EffectBaseIndex
	tay
	rts


EffectPlotTextLo	;Always 6 behind to sync with display offset
 .byt <efxText00-5
 .byt <efxText01-5
 .byt <efxText02-5
 .byt <efxText03-5
 .byt <efxText04-5
 .byt <efxText05-5
 .byt <efxText06-5
 .byt <efxText07-5
EffectPlotTextHi
 .byt >efxText00-5
 .byt >efxText01-5
 .byt >efxText02-5
 .byt >efxText03-5
 .byt >efxText04-5
 .byt >efxText05-5
 .byt >efxText06-5
 .byt >efxText07-5

efxText00
 .dsb 9,8
efxText01
 .byt "NOISE",8,"OFF"
efxText02
 .byt "EG",8,"OFF",8,8,8
efxText03
 .byt "TONE",8,"OFF",8
efxText04
 .byt "VOLUME",128
efxText05
 .byt "NOISE",8,128
efxText06
 .byt "EGPER",8,128
efxText07
 .byt "PITCH",8,128

