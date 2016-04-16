;Wave_MenuPlot.s

MenuCursorPlot
	ldx MenuCursorX
	lda MenuID
.(
	bne skip1
	ldy Menu1CursorX2ScreenIndex,x
	lda Menu1CursorX2FieldLength,x
	jmp skip2
skip1	ldy Menu2CursorX2ScreenIndex,x
	lda Menu2CursorX2FieldLength,x
skip2	tax
loop1	lda $BB81,y
	and #127
	sta $BB81,y
	iny
	dex
	bne loop1
.)
	rts


MenuPlot
	lda MenuID
.(
	bne skip1
	ldx #37
loop1	lda MenuText1,x
	ora #128
	sta $BB80,x
	dex
	bpl loop1
	rts
skip1	ldx #37
loop2	lda MenuText2,x
	ora #128
	sta $BB80,x
	dex
	bpl loop2
.)
	rts

MenuText1
 .byt 131,"FILE",8,"LIST",8,"PATT",8,"EFFE",8,"ORNA",8,"SAMP",8,"TM"
MenuEmbeddedTempoText
 .byt "10",8,127,"<"
;FILE LIST PATT EFFE ORNA SAMP HELP s<
;EDIT LOAD SAVE UPDATE DIR MAIN-MENU
MenuText2
 .byt 134,"EDIT",8,"LOAD",8,"SAVE",8,"UPDATE",8,"DIR",8,"NEW",8,"MMENU",8,8
Menu1CursorX2ScreenIndex
 .byt 0,5,10,15,20,25,30,35,36
Menu1CursorX2FieldLength
 .byt 4,4,4,4,4,4,4,1,1
Menu2CursorX2ScreenIndex
 .byt 0,5,10,15,22,26,30
Menu2CursorX2FieldLength
 .byt 4,4,4,6,3,3,5
