;Sample Block Compiler utility

; WAVE - SAMPLE COMPILER  V1.0 TWILIGHTE 
;I01 Brass      BrassStab         658 1s1
;...
; 658(1) of 8192 Bytes(7534 Free)

;Return to basic for..
; To load sample (to play)
; To load compilation
; To Save compilation

#define	SYS_IRQVECTOR	$0245

#define	ROM_SENDAYBANK	$FA86

#define	VIA_PORTB		$0300
#define	VIA_T1CL		$0304
#define	VIA_T1CH            $0305
#define	VIA_T1LL            $0306
#define	VIA_T1LH            $0307
#define	VIA_T2LL            $0308
#define	VIA_T2CH            $0309
#define	VIA_PCR             $030C
#define	VIA_IFR		$030D
#define	VIA_IER		$030E
#define	VIA_PORTA           $030F

#define	NULLKEYCODE	63	;Not sure

 .zero
*=$00

source		.dsb 2	;0-1
screen		.dsb 2	;2-3
text		.dsb 2	;4-5
SamplePlayFlag	.dsb 1	;6
zpRegisterA         .dsb 1	;7
zpRegisterX         .dsb 1	;8
zpRegisterY         .dsb 1	;9
pzIRQCounter	.dsb 1	;A
FiftyHerzCount	.dsb 1	;B

 .text
*=$1000

Driver	lda #00
	sta ListIndex
	sta CursorY
	jsr SetupAY
	jsr Set5KhzIRQ

	jsr PlotTopLegend
	jsr DisplaySampleList
	jmp InputControl
	
SetupAY	;Send AY Bank using ROM Routine
	ldx #<DefaultAYBank
	ldy #>DefaultAYBank
	jmp ROM_SENDAYBANK

DefaultAYBank
 .byt 0,0,0,0,0,0
 .byt 0
 .byt %01111111
 .byt 0,0,0
 .byt 0,0
 .byt 15
 .byt 0

ListIndex		.byt 0
ScreenRows          .byt 0
CursorY		.byt 0
TempSpeed		.byt 0
TempLo		.byt 0
TempHi              .byt 0
TempX               .byt 0
pzKeyInDelayPhase	.byt 0
pzKeyRegister	.byt 0
ScreenRowBuffer	.dsb 40,8
;0123456789012345678901234567890123456789
;Brass    BrassStab      1280 <x1(+0000)

DisplaySampleList
	lda #<$BB80+40
	sta screen
	lda #>$BB80+40
	sta screen+1
	ldx ListIndex
	lda #26
	sta ScreenRows
	
.(	
loop2	lda SamplePropertyAddressLo,x
	sta source
	lda SamplePropertyAddressHi,x
	sta source+1

	;Clear Buffer row
	ldy #39
	lda #8
loop3	sta ScreenRowBuffer,y
	dey
	bpl loop3
	
	;Fetch and display category
	ldy #00
	;0-0 CategoryID(1)
	;1-2 Filename(2)
	;3-4 Length(2)
	;5-6 LoopOffset(2)
	;7-7 Compilation Flag(1)
	;8-8 Speed(1)
	;9-X Description(V)
loop1	lda (source),y
	asl
	asl
	asl
	adc #<SampleCategoryText
	sta text
	lda #>SampleCategoryText
	adc #00
	sta text+1
	ldy #07
loop4	lda (text),y
	sta ScreenRowBuffer,y
	dey
	bpl loop4
	
	;Fetch and display description
	lda #2
	sta ScreenRowBuffer+8
	ldy #9
loop5	lda (source),y
	php
	and #127
	sta ScreenRowBuffer,y
	iny
	plp
	bpl loop5

	ldy #7
	lda (source),y
	cmp #1
	lda #8
	bcc skip2
	lda #"<"
skip2	ldy #30
	sta ScreenRowBuffer,y
	
	;Fetch and display Speed
	lda #"x"
	ldy #31
	sta ScreenRowBuffer,y
	ldy TempSpeed	;0,1,2,3,
	lda SpeedTextDigit,y
	ldy #32
	sta ScreenRowBuffer,y
	
	;Fetch and display Loop Offset
	;5-6 LoopOffset(2)
	ldy #33
	lda #"("
	sta ScreenRowBuffer,y
	iny
	lda #"+"
	sta ScreenRowBuffer,y
	ldy #39
	lda #")"
	sta ScreenRowBuffer,y
	
	ldy #6
	lda (source),y
	bmi NoLoop
	stx TempX
	tax
	dey
	lda (source),y
	ldy #35
	jsr Display4DH
	ldx TempX
	jmp skip3
NoLoop	ldy #35
	lda #"-"
	sta ScreenRowBuffer,y
	iny
	sta ScreenRowBuffer,y
	iny
	sta ScreenRowBuffer,y
	iny
	sta ScreenRowBuffer,y
	
	ldy #39
loop10	lda ScreenRowBuffer,y
	sta (screen),y
	dey
	bpl loop10
	
	;Fetch and display Length (based on speed)
	ldy #8
	lda (source),y
	sta TempSpeed
	ldy #4
	lda (source),y
	sta TempLo
	iny
	lda (source),y
	sta TempHi
	lda TempSpeed
	beq skip1
	tay
loop6	lsr TempHi
	ror TempLo
	dey
	bne loop6
skip1	stx TempX
	lda TempLo
	ldx TempHi
	ldy #25
	jsr DisplayDelimitedDecimal
	ldx TempX
	
skip3	
	lda screen
	clc
	adc #40
	sta screen
	lda screen+1
	adc #00
	sta screen+1
	inx
	dec ScreenRows
	beq skip9
	jmp loop2
skip9	rts
.)

SpeedTextDigit
 .byt "1248"

Display4DH
	pha
	txa
	lsr
	lsr
	lsr
	lsr
	jsr Display1DH
	txa
	jsr Display1DH
	pla
	tax
	lsr
	lsr
	lsr
	lsr
	jsr Display1DH
	txa
	
Display1DH
	and #15
	cmp #10
.(
	bcc skip1
	adc #6
skip1	adc #48
.)
	sta (screen),y
	iny
	rts
	
;Up	Move Up
;Down	Move Down
;Space	Add/Sub Compilation
;Return	Play Sample
;,	Decrease Compile/Play Speed
;.	Increase Compile/Play Speed
;S	Save Sample Block
;ESC	Exit
InputControl
	jsr PlotCursor
	jsr CommonInkey
	ldx #11
.(
loop1	cmp KeyCode,x
	beq skip1
	dex
	bpl loop1
	jmp InputControl
skip1	lda KeyVectorLo,x
	sta vector1+1
	lda KeyVectorHi,x
	sta vector1+2
vector1	jsr $dead
.)
	jmp InputControl

PlotTopLegend
	ldx #39
.(
loop1	lda TopLegendText,x
	ora #128
	sta $BB80,x
	dex
	bpl loop1
.)
	rts

TopLegendText
 .byt 6,"WAVE - SAMPLE COMPILER  V1.0 TWILIGHTE "

PlotBottomLegend
	rts
;I01 Brass      BrassStab         658 1s1
;...
; 658(1) of 8192 Bytes(7534 Free)

PlotCursor
	ldx CursorY
	lda ListTextScreenAddressLo,x
	sta screen
	lda ListTextScreenAddressHi,x
	sta screen+1
	ldy #39
.(
loop1	lda (screen),y
	ora #128
	sta (screen),y
	dey
	bpl loop1
.)
	rts

GetKey	jsr $EB78
	bpl GetKey
	rts

ListTextScreenAddressLo
 .byt <$BB80+40*1
 .byt <$BB80+40*2
 .byt <$BB80+40*3
 .byt <$BB80+40*4
 .byt <$BB80+40*5
 .byt <$BB80+40*6
 .byt <$BB80+40*7
 .byt <$BB80+40*8
 .byt <$BB80+40*9
 .byt <$BB80+40*10
 .byt <$BB80+40*11
 .byt <$BB80+40*12
 .byt <$BB80+40*13
 .byt <$BB80+40*14
 .byt <$BB80+40*15
 .byt <$BB80+40*16
 .byt <$BB80+40*17
 .byt <$BB80+40*18
 .byt <$BB80+40*19
 .byt <$BB80+40*20
 .byt <$BB80+40*21
 .byt <$BB80+40*22
 .byt <$BB80+40*23
 .byt <$BB80+40*24
 .byt <$BB80+40*25
 .byt <$BB80+40*26
 .byt <$BB80+40*27
ListTextScreenAddressHi
 .byt >$BB80+40*1
 .byt >$BB80+40*2
 .byt >$BB80+40*3
 .byt >$BB80+40*4
 .byt >$BB80+40*5
 .byt >$BB80+40*6
 .byt >$BB80+40*7
 .byt >$BB80+40*8
 .byt >$BB80+40*9
 .byt >$BB80+40*10
 .byt >$BB80+40*11
 .byt >$BB80+40*12
 .byt >$BB80+40*13
 .byt >$BB80+40*14
 .byt >$BB80+40*15
 .byt >$BB80+40*16
 .byt >$BB80+40*17
 .byt >$BB80+40*18
 .byt >$BB80+40*19
 .byt >$BB80+40*20
 .byt >$BB80+40*21
 .byt >$BB80+40*22
 .byt >$BB80+40*23
 .byt >$BB80+40*24
 .byt >$BB80+40*25
 .byt >$BB80+40*26
 .byt >$BB80+40*27
	
KeyCode
 .byt 28	;Cursor Up  Move Up
 .byt 44  ;CursorDown Move Down
 .byt 12  ;,	  Dec Play Speed
 .byt 20  ;.          Inc Play Speed
 .byt 39  ;Return	  Play/Stop Sample
 .byt 4   ;Space Bar  Toggle Sample to Compilation
 .byt 15  ;L	  Toggle Sample Loop
 .byt 27  ;-	  Dec Sample Loop Offset
 .byt 55	;=	  Inc Sample Loop Offset
 .byt 13	;I	  Import LHL Sample
 .byt 18	;B	  Build Compilation
 .byt 33	;ESC	  Quit to main menu
 
KeyVectorLo
 .byt <MoveUp
 .byt <MoveDown
 .byt <DecPlaySpeed
 .byt <IncPlaySpeed
 .byt <PlayStopSample
 .byt <ToggleSampleToCompilation
 .byt <ToggleSampleLoop
 .byt <DecSampleLoopOffset
 .byt <IncSampleLoopOffset
 .byt <ImportLHLSample
 .byt <BuildCompilation
 .byt <QuitToMainMenu
KeyVectorHi
 .byt >MoveUp
 .byt >MoveDown
 .byt >DecPlaySpeed
 .byt >IncPlaySpeed
 .byt >PlayStopSample
 .byt >ToggleSampleToCompilation
 .byt >ToggleSampleLoop
 .byt >DecSampleLoopOffset
 .byt >IncSampleLoopOffset
 .byt >ImportLHLSample
 .byt >BuildCompilation
 .byt >QuitToMainMenu

MoveUp
	;Push scroll up
	lda CursorY
	beq PushScrollUp
	dec CursorY
	jmp DisplaySampleList
PushScrollUp
	lda ListIndex
.(
	beq skip1
	dec ListIndex
skip1	jmp DisplaySampleList
.)
MoveDown
	;Push scroll down
	lda CursorY
	cmp #25
	bcs PushScrollDown
	inc CursorY
	jmp DisplaySampleList
PushScrollDown
	lda ListIndex
	cmp #134-26
.(
	bcs skip1
	inc ListIndex
skip1	jmp DisplaySampleList
.)
DecPlaySpeed
IncPlaySpeed
ToggleSampleToCompilation
ToggleSampleLoop
DecSampleLoopOffset
IncSampleLoopOffset
ImportLHLSample
BuildCompilation
QuitToMainMenu
	rts

CommonInkey
	;Wait for a key observing key delay and key repeat (utilising irq Counter)
	lda FiftyHerzCount

	bne CommonInkey
	lda #100
	sta FiftyHerzCount
	jsr RapidKeyScan

	lda pzKeyRegister

	cmp #NULLKEYCODE
	beq NoKeyPressedOrKeyUp
	ldy pzIRQCounter
	bne CommonInkey	;Key Delayed
	ldy pzKeyInDelayPhase
	bne ProceedToRepeatKey
	ldy #16	;KeyDelayPeriod
	sty pzIRQCounter
	ldy #1
	sty pzKeyInDelayPhase
	rts

NoKeyPressedOrKeyUp
	lda #0
	sta pzKeyInDelayPhase
	jmp CommonInkey
ProceedToRepeatKey
	ldy #8
	sty pzIRQCounter
	rts

;Play x1,x2,x4 with optional Loop
Set5KhzIRQ
	sei
	lda #<IRQDriver
	sta SYS_IRQVECTOR
	lda #>IRQDriver
	sta SYS_IRQVECTOR+1
	lda #<200
	sta VIA_T1LL
	sta VIA_T1CL
	lda #>200
	sta VIA_T1LH
	sta VIA_T1CH
	cli
	rts
Set100HzIRQ
	sei
	lda #$C4
	sta SYS_IRQVECTOR
	lda #$04
	sta SYS_IRQVECTOR+1
	lda #$10
	sta VIA_T1LL
	sta VIA_T1CL
	lda #$27
	sta VIA_T1LH
	sta VIA_T1CH
	cli
	rts
	
	
;Parameters

;Play Samples and Read key on 100 count
IRQDriver
	;Backup A
	sta zpRegisterA
	
	;Reset IRQ
	lda VIA_T1CL
	
	;Count 100
	lda FiftyHerzCount
	beq irqskip1
	dec FiftyHerzCount
	
irqskip1	;Process programmable counter
	lda pzIRQCounter
	beq irqskip2
	dec pzIRQCounter

irqskip2	;Check Sample Play
	;0   No Play
	;1   Play Low
	;128 Play Hi/Advance
	lda SamplePlayFlag
	beq irqskip4
	
	bmi irqskip3

SampleLow	lda #00
	and #15
	sta VIA_PORTA
	lda #128
	sta SamplePlayFlag
	
irqskip4	lda zpRegisterA
	rti
	
irqskip3	;Play Hi
SampleAddress
	lda $DEAD
	beq EndSample
	sta SampleLow+1
	
	lsr
	lsr
	lsr
	lsr
	sta VIA_PORTA
	
	lda SampleAddress+1
SampleStep
	adc #01
	sta SampleAddress+1
	bcc irqskip5
	inc SampleAddress+2
irqskip5	lda #1
	sta SamplePlayFlag
	lda zpRegisterA
	rti
	
EndSample	;Check loop
SampleLoopOffsetHi
	lda #128
	bmi irqskip4
SampleLoopOffsetLo
	lda #00
	clc
SampleBaseAddressLo
	adc #00
	sta SampleAddress+2
	lda SampleLoopOffsetHi+1
SampleBaseAddressHi
	adc #00
	sta SampleAddress+1
	jmp irqskip3


PlayStopSample
	lda SamplePlayFlag
.(
	beq skip1
	;Stop Sample
	lda #00
	sta SamplePlayFlag
skip1	;Play Sample
.)
	sei
	lda #128
	sta SamplePlayFlag
	lda ListIndex
	clc
	adc CursorY
	tax
	lda #<$5000
	sta SampleAddress+1
	sta SampleBaseAddressLo+1
	lda #>$5000
	sta SampleAddress+2
	sta SampleBaseAddressHi+1
	lda SamplePropertyAddressLo,x
	sta source
	lda SamplePropertyAddressHi,x
	sta source+1
	;5-6 LoopOffset(2)
	;8-8 Speed(1)
	ldy #05
	lda (source),y
	sta SampleLoopOffsetLo+1
	iny
	lda (source),y
	sta SampleLoopOffsetHi+1
	ldy #8
	lda (source),y
	;0,1,2,3,4 >> 1,2,4,8,16
	tax
	lda Speed2StepSize,x
	sta SampleStep+1
	cli
	rts
	
Speed2StepSize
 .byt 1,2,4,8,16,32

;Rapidly scan for keys
;Scan Shift,Ctrl,Func Seperately
;0-63 Key
;+64  Shift
;+128 Ctrl
;+192 Func
;Then combine into single byte with a specific code when nothing pressed.
RapidKeyScan
	;Setup Virtual AY on Key Column
	sei
	lda #$DD
	sta VIA_PCR
	lda #14
	sta VIA_PORTA
	lda #$FF
	sta VIA_PCR
	lda #$FD
	sta VIA_PCR

	;Scan all columns apart from Soft
	lda #%00010000
	sta VIA_PORTA

	ldy #07	;Row
.(
loop1	sty VIA_PORTB
	jsr KeyDelay
	lda VIA_PORTB
	and #8
	bne skip1
	dey
	bpl loop1
	jsr RestoreSIDRegisterAndCLI
	lda #NULLKEYCODE
	sta pzKeyRegister
	rts
skip1	;Found row with key activity(column in Y) - now isolate key
	ldx #6
loop2	lda pmKeyColumn,x
	sta VIA_PORTA
	jsr KeyDelay
	lda VIA_PORTB
	and #8
	bne skip2
	dex
	bpl loop2
	jsr RestoreSIDRegisterAndCLI
	
	lda #NULLKEYCODE
	sta pzKeyRegister
	rts
skip2	;Found exact key - remember position
	sty pmKeyFoundRow+1

	;Now scan Soft column
	lda #%11101111
	sta VIA_PORTA
	ldy #3
loop3	lda pmSoftRow,y
	sta VIA_PORTB
	jsr KeyDelay
	lda VIA_PORTB
	and #8
	bne skip3
	dey
	bpl loop3
	ldy #4
skip3	;Fetch Row
.)
pmKeyFoundRow
	
	lda #00
	ora pmColumnBits,x	;8
	ora pmSoftBits,y	;5
	sta pzKeyRegister

RestoreSIDRegisterAndCLI
	lda #$FF
	sta VIA_PCR
	lda #8
	sta VIA_PORTA
	lda #$DD
	sta VIA_PCR
	cli
	rts

KeyDelay
	nop
	nop
	rts
	


;A==Lo
;X==Hi
;(screen),y
DisplayDelimitedDecimal
	;
	stx TempHi
	sta TempLo
	ldx #47
	sec
.(
loop1	inx
	lda TempLo
	sbc #<1000
	sta TempLo
	lda TempHi
	sbc #>1000
	sta TempHi
	bcs loop1
.)
	lda TempLo
	adc #<1000
	sta TempLo
	lda TempHi
	adc #>1000
	sta TempHi
	stx TempDigit1
	
	ldx #47
	sec
.(
loop2	inx
	lda TempLo
	sbc #<100
	sta TempLo
	lda TempHi
	sbc #>100
	sta TempHi
	bcs loop2
.)
	lda TempLo
	adc #<100
	sta TempLo
	lda TempHi
	adc #>100
	sta TempHi
	stx TempDigit2
	
	lda TempLo
	ldx #47
	sec
.(
loop3	inx
	sbc #10
	bcs loop3
.)
	adc #58
	stx TempDigit3
	sta TempDigit4
	
	;Now Delimit in display
	ldx #00
.(
loop1	lda TempDigit,x
	cmp #"0"
	bne skip1
	lda #" "
	sta TempDigit,x
	inx
	cpx #4
	bcc loop1
skip1	ldx #00
loop2	lda TempDigit,x
	sta (screen),y
	iny
	inx
	cpx #4
	bcc loop2
.)
	rts

TempDigit
TempDigit1	.byt 0
TempDigit2	.byt 0
TempDigit3	.byt 0
TempDigit4	.byt 0
SamplePropertyAddressLo
 .byt <SampleProperty000
 .byt <SampleProperty001
 .byt <SampleProperty002
 .byt <SampleProperty003
 .byt <SampleProperty004
 .byt <SampleProperty005
 .byt <SampleProperty006
 .byt <SampleProperty007
 .byt <SampleProperty008
 .byt <SampleProperty009
 .byt <SampleProperty010
 .byt <SampleProperty011
 .byt <SampleProperty012
 .byt <SampleProperty013
 .byt <SampleProperty014
 .byt <SampleProperty015
 .byt <SampleProperty016
 .byt <SampleProperty017
 .byt <SampleProperty018
 .byt <SampleProperty019
 .byt <SampleProperty020
 .byt <SampleProperty021
 .byt <SampleProperty022
 .byt <SampleProperty023
 .byt <SampleProperty024
 .byt <SampleProperty025
 .byt <SampleProperty026
 .byt <SampleProperty027
 .byt <SampleProperty028
 .byt <SampleProperty029
 .byt <SampleProperty030
 .byt <SampleProperty031
 .byt <SampleProperty032
 .byt <SampleProperty033
 .byt <SampleProperty034
 .byt <SampleProperty035
 .byt <SampleProperty036
 .byt <SampleProperty037
 .byt <SampleProperty038
 .byt <SampleProperty039
 .byt <SampleProperty040
 .byt <SampleProperty041
 .byt <SampleProperty042
 .byt <SampleProperty043
 .byt <SampleProperty044
 .byt <SampleProperty045
 .byt <SampleProperty046
 .byt <SampleProperty047
 .byt <SampleProperty048
 .byt <SampleProperty049
 .byt <SampleProperty050
 .byt <SampleProperty051
 .byt <SampleProperty052
 .byt <SampleProperty053
 .byt <SampleProperty054
 .byt <SampleProperty055
 .byt <SampleProperty056
 .byt <SampleProperty057
 .byt <SampleProperty058
 .byt <SampleProperty059
 .byt <SampleProperty060
 .byt <SampleProperty061
 .byt <SampleProperty062
 .byt <SampleProperty063
 .byt <SampleProperty064
 .byt <SampleProperty065
 .byt <SampleProperty066
 .byt <SampleProperty067
 .byt <SampleProperty068
 .byt <SampleProperty069
 .byt <SampleProperty070
 .byt <SampleProperty071
 .byt <SampleProperty072
 .byt <SampleProperty073
 .byt <SampleProperty074
 .byt <SampleProperty075
 .byt <SampleProperty076
 .byt <SampleProperty077
 .byt <SampleProperty078
 .byt <SampleProperty079
 .byt <SampleProperty080
 .byt <SampleProperty081
 .byt <SampleProperty082
 .byt <SampleProperty083
 .byt <SampleProperty084
 .byt <SampleProperty085
 .byt <SampleProperty086
 .byt <SampleProperty087
 .byt <SampleProperty088
 .byt <SampleProperty089
 .byt <SampleProperty090
 .byt <SampleProperty091
 .byt <SampleProperty092
 .byt <SampleProperty093
 .byt <SampleProperty094
 .byt <SampleProperty095
 .byt <SampleProperty096
 .byt <SampleProperty097
 .byt <SampleProperty098
 .byt <SampleProperty099
 .byt <SampleProperty100
 .byt <SampleProperty101
 .byt <SampleProperty102
 .byt <SampleProperty103
 .byt <SampleProperty104
 .byt <SampleProperty105
 .byt <SampleProperty106
 .byt <SampleProperty107
 .byt <SampleProperty108
 .byt <SampleProperty109
 .byt <SampleProperty110
 .byt <SampleProperty111
 .byt <SampleProperty112
 .byt <SampleProperty113
 .byt <SampleProperty114
 .byt <SampleProperty115
 .byt <SampleProperty116
 .byt <SampleProperty117
 .byt <SampleProperty118
 .byt <SampleProperty119
 .byt <SampleProperty120
 .byt <SampleProperty121
 .byt <SampleProperty122
 .byt <SampleProperty123
 .byt <SampleProperty124
 .byt <SampleProperty125
 .byt <SampleProperty126
 .byt <SampleProperty127
 .byt <SampleProperty128
 .byt <SampleProperty129
 .byt <SampleProperty130
 .byt <SampleProperty131
SamplePropertyAddressHi
 .byt >SampleProperty000
 .byt >SampleProperty001
 .byt >SampleProperty002
 .byt >SampleProperty003
 .byt >SampleProperty004
 .byt >SampleProperty005
 .byt >SampleProperty006
 .byt >SampleProperty007
 .byt >SampleProperty008
 .byt >SampleProperty009
 .byt >SampleProperty010
 .byt >SampleProperty011
 .byt >SampleProperty012
 .byt >SampleProperty013
 .byt >SampleProperty014
 .byt >SampleProperty015
 .byt >SampleProperty016
 .byt >SampleProperty017
 .byt >SampleProperty018
 .byt >SampleProperty019
 .byt >SampleProperty020
 .byt >SampleProperty021
 .byt >SampleProperty022
 .byt >SampleProperty023
 .byt >SampleProperty024
 .byt >SampleProperty025
 .byt >SampleProperty026
 .byt >SampleProperty027
 .byt >SampleProperty028
 .byt >SampleProperty029
 .byt >SampleProperty030
 .byt >SampleProperty031
 .byt >SampleProperty032
 .byt >SampleProperty033
 .byt >SampleProperty034
 .byt >SampleProperty035
 .byt >SampleProperty036
 .byt >SampleProperty037
 .byt >SampleProperty038
 .byt >SampleProperty039
 .byt >SampleProperty040
 .byt >SampleProperty041
 .byt >SampleProperty042
 .byt >SampleProperty043
 .byt >SampleProperty044
 .byt >SampleProperty045
 .byt >SampleProperty046
 .byt >SampleProperty047
 .byt >SampleProperty048
 .byt >SampleProperty049
 .byt >SampleProperty050
 .byt >SampleProperty051
 .byt >SampleProperty052
 .byt >SampleProperty053
 .byt >SampleProperty054
 .byt >SampleProperty055
 .byt >SampleProperty056
 .byt >SampleProperty057
 .byt >SampleProperty058
 .byt >SampleProperty059
 .byt >SampleProperty060
 .byt >SampleProperty061
 .byt >SampleProperty062
 .byt >SampleProperty063
 .byt >SampleProperty064
 .byt >SampleProperty065
 .byt >SampleProperty066
 .byt >SampleProperty067
 .byt >SampleProperty068
 .byt >SampleProperty069
 .byt >SampleProperty070
 .byt >SampleProperty071
 .byt >SampleProperty072
 .byt >SampleProperty073
 .byt >SampleProperty074
 .byt >SampleProperty075
 .byt >SampleProperty076
 .byt >SampleProperty077
 .byt >SampleProperty078
 .byt >SampleProperty079
 .byt >SampleProperty080
 .byt >SampleProperty081
 .byt >SampleProperty082
 .byt >SampleProperty083
 .byt >SampleProperty084
 .byt >SampleProperty085
 .byt >SampleProperty086
 .byt >SampleProperty087
 .byt >SampleProperty088
 .byt >SampleProperty089
 .byt >SampleProperty090
 .byt >SampleProperty091
 .byt >SampleProperty092
 .byt >SampleProperty093
 .byt >SampleProperty094
 .byt >SampleProperty095
 .byt >SampleProperty096
 .byt >SampleProperty097
 .byt >SampleProperty098
 .byt >SampleProperty099
 .byt >SampleProperty100
 .byt >SampleProperty101
 .byt >SampleProperty102
 .byt >SampleProperty103
 .byt >SampleProperty104
 .byt >SampleProperty105
 .byt >SampleProperty106
 .byt >SampleProperty107
 .byt >SampleProperty108
 .byt >SampleProperty109
 .byt >SampleProperty110
 .byt >SampleProperty111
 .byt >SampleProperty112
 .byt >SampleProperty113
 .byt >SampleProperty114
 .byt >SampleProperty115
 .byt >SampleProperty116
 .byt >SampleProperty117
 .byt >SampleProperty118
 .byt >SampleProperty119
 .byt >SampleProperty120
 .byt >SampleProperty121
 .byt >SampleProperty122
 .byt >SampleProperty123
 .byt >SampleProperty124
 .byt >SampleProperty125
 .byt >SampleProperty126
 .byt >SampleProperty127
 .byt >SampleProperty128
 .byt >SampleProperty129
 .byt >SampleProperty130
 .byt >SampleProperty131

;CategoryID(1),Filename(2),Length(2),LoopOffset(2),Compilation Flag(1),Speed(1),Description(V)
SampleProperty000
 .byt 0,"I",04,<658,>658,0,128,0,0,"Bass Dru","m"+128	;Percuss.
SampleProperty001
 .byt 0,"I",05,<1858,>1858,0,128,0,0,"Bong","o"+128		;Percuss.
SampleProperty002
 .byt 0,"I",06,<1986,>1986,0,128,0,0,"Brysnar","e"+128	;Percuss.
SampleProperty003
 .byt 0,"I",07,<2004,>2004,0,128,0,0,"Ch","a"+128		;Percuss.
SampleProperty004
 .byt 0,"I",08,<2050,>2050,0,128,0,0,"Chub","b"+128		;Percuss.
SampleProperty005
 .byt 0,"I",09,<2050,>2050,0,128,0,0,"Cla","p"+128		;Percuss.
SampleProperty006
 .byt 0,"I",10,<2050,>2050,0,128,0,0,"Doubl","e"+128	;Percuss.
SampleProperty007
 .byt 0,"I",11,<1354,>1354,0,128,0,0,"Drum","1"+128		;Percuss.
SampleProperty008
 .byt 0,"I",12,<802,>802,0,128,0,0,"Drumrol","l"+128	;Percuss.
SampleProperty009
 .byt 0,"I",13,<2029,>2029,0,128,0,0,"Electric To","m"+128	;Percuss.
SampleProperty010
 .byt 0,"I",14,<2004,>2004,0,128,0,0,"Nik","a"+128		;Percuss.
SampleProperty011
 .byt 0,"I",15,<802,>802,0,128,0,0,"Poc","k"+128		;Percuss.
SampleProperty012
 .byt 0,"I",16,<770,>770,0,128,0,0,"Pound dru","m"+128	;Percuss.
SampleProperty013
 .byt 0,"I",17,<404,>404,0,128,0,0,"PsBas","s"+128		;Percuss.
SampleProperty014
 .byt 0,"I",19,<802,>802,0,128,0,0,"Snare Dru","m"+128	;Percuss.
SampleProperty015
 .byt 0,"I",20,<802,>802,0,128,0,0,"Sylvian Dru","m"+128	;Percuss.
SampleProperty016
 .byt 0,"I",21,<802,>802,0,128,0,0,"Syn To","m"+128		;Percuss.
SampleProperty017
 .byt 0,"I",22,<802,>802,0,128,0,0,"To","m"+128		;Percuss.
SampleProperty018
 .byt 0,"I",23,<802,>802,0,128,0,0,"Uh Snar","e"+128	;Percuss.
SampleProperty019
 .byt 0,"I",24,<802,>802,0,128,0,0,"Ult Dru","m"+128	;Percuss.
SampleProperty020
 .byt 0,"I",25,<1314,>1314,0,128,0,0,"Vis bas","s"+128	;Percuss.
SampleProperty021
 .byt 0,"I",26,<669,>669,0,128,0,0,"vtak-bas","s"+128	;Percuss.
SampleProperty022
 .byt 0,"I",27,<802,>802,0,128,0,0,"vtak to","m"+128	;Percuss.
SampleProperty023
 .byt 0,"I",28,<442,>442,0,128,0,0,"wah snar","e"+128	;Percuss.
SampleProperty024
 .byt 0,"I",29,<802,>802,0,128,0,0,"white snar","e"+128	;Percuss.
SampleProperty025
 .byt 0,"I",30,<802,>802,0,128,0,0,"wild to","m"+128	;Percuss.
SampleProperty026
 .byt 0,"I",37,<898,>898,0,128,0,0,"Crash Cymba","l"+128	;Percuss.
SampleProperty027
 .byt 0,"I",38,<802,>802,0,128,0,0,"Hihat Se","q"+128	;Percuss.
SampleProperty028
 .byt 0,"I",39,<802,>802,0,128,0,0,"Limpe","t"+128		;Percuss.
SampleProperty029
 .byt 0,"I",40,<802,>802,0,128,0,0,"Shake","r"+128		;Percuss.
SampleProperty030
 .byt 0,"I",73,<338,>338,0,128,0,0,"Ow","l"+128		;Percuss.
SampleProperty031
 .byt 1,"I",01,<802,>802,0,128,0,0,"BrassSta","b"+128	;Instrmnt
SampleProperty032
 .byt 1,"I",02,<802,>802,0,128,0,0,"Trumpe","t"+128		;Instrmnt
SampleProperty033
 .byt 1,"I",34,<770,>770,0,128,0,0,"Pipe Orga","n"+128	;Instrmnt
SampleProperty034
 .byt 1,"I",35,<674,>674,0,128,0,0,"Tremelo Orga","n"+128	;Instrmnt
SampleProperty035
 .byt 1,"I",36,<802,>802,0,128,0,0,"Bel","l"+128		;Instrmnt
SampleProperty036
 .byt 1,"I",65,<930,>930,0,128,0,0,"Bwa","h"+128		;Instrmnt
SampleProperty037
 .byt 1,"I",66,<634,>634,0,128,0,0,"Bwa","p"+128		;Instrmnt
SampleProperty038
 .byt 1,"I",69,<1486,>1486,0,128,0,0,"Mid Thro","b"+128	;Instrmnt
SampleProperty039
 .byt 1,"I",70,<914,>914,0,128,0,0,"Modulat","e"+128	;Instrmnt
SampleProperty040
 .byt 1,"I",71,<242,>242,0,128,0,0,"Oc","k"+128		;Instrmnt
SampleProperty041
 .byt 1,"I",74,<409,>409,0,128,0,0,"Pu","n"+128		;Instrmnt
SampleProperty042
 .byt 1,"I",75,<2029,>2029,0,128,0,0,"Sparkl","e"+128	;Instrmnt
SampleProperty043
 .byt 1,"I",31,<1858,>1858,0,128,0,0,"harpsichord ","1"+128	;Instrmnt
SampleProperty044
 .byt 1,"I",32,<1922,>1922,0,128,0,0,"harpsichord ","2"+128	;Instrmnt
SampleProperty045
 .byt 1,"I",33,<2050,>2050,0,128,0,0,"Honky Ton","k"+128	;Instrmnt
SampleProperty046
 .byt 1,"I",41,<2004,>2004,0,128,0,0,"Vibe","s"+128		;Instrmnt
SampleProperty047
 .byt 1,"I",42,<802,>802,0,128,0,0,"AccousticGuit","r"+128	;Instrmnt
SampleProperty048
 .byt 1,"I",43,<2004,>2004,0,128,0,0,"Accoustic Bas","s"+128	;Instrmnt
SampleProperty049
 .byt 1,"I",44,<2050,>2050,0,128,0,0,"Bass Guita","r"+128	;Instrmnt
SampleProperty050
 .byt 1,"I",45,<2050,>2050,0,128,0,0,"Cello Mi","d"+128	;Instrmnt
SampleProperty051
 .byt 1,"I",46,<2050,>2050,0,128,0,0,"Celtic Har","p"+128	;Instrmnt
SampleProperty052
 .byt 1,"I",47,<2050,>2050,0,128,0,0,"Double Bas","s"+128	;Instrmnt
SampleProperty053
 .byt 1,"I",48,<2004,>2004,0,128,0,0,"Dulcime","r"+128	;Instrmnt
SampleProperty054
 .byt 1,"I",49,<2018,>2018,0,128,0,0,"ElectricGuita","r"+128	;Instrmnt
SampleProperty055
 .byt 1,"I",50,<2050,>2050,0,128,0,0,"Guita","r"+128	;Instrmnt
SampleProperty056
 .byt 1,"I",51,<802,>802,0,128,0,0,"Guitar Stru","m"+128	;Instrmnt
SampleProperty057
 .byt 1,"I",52,<2050,>2050,0,128,0,0,"Kot","o"+128		;Instrmnt
SampleProperty058
 .byt 1,"I",53,<2050,>2050,0,128,0,0,"Orchestra ","2"+128	;Instrmnt
SampleProperty059
 .byt 1,"I",54,<2004,>2004,0,128,0,0,"Pluck ","1"+128	;Instrmnt
SampleProperty060
 .byt 1,"I",55,<1039,>1039,0,128,0,0,"Pluck ","2"+128	;Instrmnt
SampleProperty061
 .byt 1,"I",56,<1698,>1698,0,128,0,0,"Reverb Guita","r"+128	;Instrmnt
SampleProperty062
 .byt 1,"I",57,<2050,>2050,0,128,0,0,"Slap Bas","s"+128	;Instrmnt
SampleProperty063
 .byt 1,"I",58,<1266,>1266,0,128,0,0,"Slid","e"+128		;Instrmnt
SampleProperty064
 .byt 1,"I",59,<1666,>1666,0,128,0,0,"Stru","m"+128		;Instrmnt
SampleProperty065
 .byt 1,"I",61,<1218,>1218,0,128,0,0,"Big Synt","h"+128	;Instrmnt
SampleProperty066
 .byt 1,"I",67,<2004,>2004,0,128,0,0,"Class Bo","w"+128	;Instrmnt
SampleProperty067
 .byt 1,"I",68,<802,>802,0,128,0,0,"Gaz Buz","z"+128	;Instrmnt
SampleProperty068
 .byt 1,"I",72,<1412,>1412,0,128,0,0,"Oing","y"+128		;Instrmnt
SampleProperty069
 .byt 1,"I",77,<1986,>1986,0,128,0,0,"String Synth ","2"+128	;Instrmnt
SampleProperty070
 .byt 1,"I",78,<2029,>2029,0,128,0,0,"Sync Osc","s"+128	;Instrmnt
SampleProperty071
 .byt 1,"I",79,<2050,>2050,0,128,0,0,"Synth Bas","s"+128	;Instrmnt
SampleProperty072
 .byt 1,"I",03,<2050,>2050,0,128,0,0,"Tub","a"+128		;Instrmnt
SampleProperty073
 .byt 1,"I",60,<2004,>2004,0,128,0,0,"Bass Yow","l"+128	;Instrmnt
SampleProperty074
 .byt 1,"I",62,<2004,>2004,0,128,0,0,"Blow","y"+128		;Instrmnt
SampleProperty075
 .byt 1,"I",63,<2004,>2004,0,128,0,0,"Bowed Synt","h"+128	;Instrmnt
SampleProperty076
 .byt 1,"I",64,<1506,>1506,0,128,0,0,"Breathe","y"+128	;Instrmnt
SampleProperty077
 .byt 1,"I",80,<2004,>2004,0,128,0,0,"Wobbl","e"+128	;Instrmnt
SampleProperty078
 .byt 1,"I",81,<2050,>2050,0,128,0,0,"Bassoo","n"+128	;Instrmnt
SampleProperty079
 .byt 1,"I",82,<2050,>2050,0,128,0,0,"Obo","e"+128		;Instrmnt
SampleProperty080
 .byt 1,"I",83,<1474,>1474,0,128,0,0,"Panpip","e"+128	;Instrmnt
SampleProperty081
 .byt 2,"S",24,<2274,>2274,0,128,0,0,"Excellen","t"+128	;Bill&Ted
SampleProperty082
 .byt 2,"S",15,<1716,>1716,0,128,0,0,"Certainl","y"+128	;Disney  
SampleProperty083
 .byt 2,"S",41,<426,>426,0,128,0,0,"Ooooo","h"+128		;Disney  
SampleProperty084
 .byt 2,"S",60,<2468,>2468,0,128,0,0,"I think it su","c"+128	;Disney  
SampleProperty085
 .byt 2,"S",69,<1593,>1593,0,128,0,0,"Uh O","h"+128		;Disney  
SampleProperty086
 .byt 2,"S",74,<2618,>2618,0,128,0,0,"Waho","o"+128		;Disney  
SampleProperty087
 .byt 2,"S",78,<1198,>1198,0,128,0,0,"Whiz","z"+128		;Disney  
SampleProperty088
 .byt 2,"S",84,<1117,>1117,0,128,0,0,"Yaho","o"+128		;Disney  
SampleProperty089
 .byt 2,"S",77,<1547,>1547,0,128,0,0,"What the hel","l"+128	;Godfathr
SampleProperty090
 .byt 2,"S",90,<1686,>1686,0,128,0,0,"You son of a.","."+128	;Godfathr
SampleProperty091
 .byt 2,"S",14,<781,>781,0,128,0,0,"Bumme","r"+128	;Mask    
SampleProperty092
 .byt 5,"S",10,<1613,>1613,0,128,0,0,"Block Mov","e"+128	;Misc.
SampleProperty093
 .byt 5,"S",11,<1512,>1512,0,128,0,0,"Boin","g"+128	;Misc.
SampleProperty094
 .byt 5,"S",12,<3013,>3013,0,128,0,0,"Bom","b"+128	;Misc.
SampleProperty095
 .byt 5,"S",19,<2327,>2327,0,128,0,0,"Cow Mo","o"+128	;Misc.
SampleProperty096
 .byt 5,"S",20,<2339,>2339,0,128,0,0,"Crea","k"+128	;Misc.
SampleProperty097
 .byt 5,"S",45,<676,>676,0,128,0,0,"Po","p"+128		;Misc.
SampleProperty098
 .byt 5,"S",57,<1101,>1101,0,128,0,0,"Splat","!"+128	;Misc.
SampleProperty099
 .byt 5,"S",59,<552,>552,0,128,0,0,"Erk","!"+128		;Misc.
SampleProperty100
 .byt 5,"S",81,<2181,>2181,0,128,0,0,"Woo","b"+128	;Misc.
SampleProperty101
 .byt 3,"S",06,<1405,>1405,0,128,0,0,"Be quiet ","1"+128	;Python
SampleProperty102
 .byt 3,"S",07,<2657,>2657,0,128,0,0,"Be quiet ","2"+128	;Python
SampleProperty103
 .byt 3,"S",09,<2705,>2705,0,128,0,0,"Bloody peasan","t"+128	;Python
SampleProperty104
 .byt 3,"S",31,<2001,>2001,0,128,0,0,"How d'u d","o"+128	;Python
SampleProperty105
 .byt 3,"S",34,<2132,>2132,0,128,0,0,"I told yo","u"+128	;Python
SampleProperty106
 .byt 3,"S",38,<191,>191,0,128,0,0,"N","i"+128		;Python
SampleProperty107
 .byt 3,"S",40,<2332,>2332,0,128,0,0,"On abou","t"+128	;Python
SampleProperty108
 .byt 3,"S",50,<2932,>2932,0,128,0,0,"Repress m","e"+128	;Python
SampleProperty109
 .byt 3,"S",54,<1919,>1919,0,128,0,0,"Shut up ","1"+128	;Python
SampleProperty110
 .byt 3,"S",55,<1907,>1907,0,128,0,0,"Shut up ","2"+128	;Python
SampleProperty111
 .byt 3,"S",61,<2191,>2191,0,128,0,0,"Don't switch ","o"+128	;Python
SampleProperty112
 .byt 3,"S",73,<3394,>3394,0,128,0,0,"Don't vote ki","n"+128	;Python
SampleProperty113
 .byt 3,"S",75,<3310,>3310,0,128,0,0,"What? Sorr","y"+128	;Python
SampleProperty114
 .byt 3,"S",76,<547,>547,0,128,0,0,"What","?"+128	;Python
SampleProperty115
 .byt 3,"S",80,<3240,>3240,0,128,0,0,"Whose castle ","i"+128	;Python
SampleProperty116
 .byt 3,"S",85,<882,>882,0,128,0,0,"Ye","s"+128		;Python
SampleProperty117
 .byt 3,"S",86,<1482,>1482,0,128,0,0,"Yes i se","e"+128	;Python
SampleProperty118
 .byt 3,"S",89,<1667,>1667,0,128,0,0,"You saw i","t"+128	;Python
SampleProperty119
 .byt 2,"S",21,<3262,>3262,0,128,0,0,"Your move cre","e"+128	;Robocop
SampleProperty120
 .byt 2,"S",30,<2355,>2355,0,128,0,0,"Hi ma","n"+128	;Simpsons
SampleProperty121
 .byt 2,"S",05,<2162,>2162,0,128,0,0,"Communicato","r"+128	;StarTrek
SampleProperty122
 .byt 2,"S",29,<2453,>2453,0,128,0,0,"Hello Compute","r"+128	;StarTrek
SampleProperty123
 .byt 2,"S",35,<3198,>3198,0,128,0,0,"Kirk her","e"+128	;StarTrek
SampleProperty124
 .byt 2,"S",47,<2095,>2095,0,128,0,0,"Red aler","t"+128	;StarTrek
SampleProperty125
 .byt 2,"S",67,<2265,>2265,0,128,0,0,"Door swis","h"+128	;StarTrek
SampleProperty126
 .byt 2,"S",68,<3341,>3341,0,128,0,0,"Whistl","e"+128	;StarTrek
SampleProperty127
 .byt 2,"S",82,<2589,>2589,0,128,0,0,"Wooki","e"+128	;StarWars
SampleProperty128
 .byt 2,"S",04,<3060,>3060,0,128,0,0,"I'll be back ","1"+128	;Termintr
SampleProperty129
 .byt 2,"S",63,<2469,>2469,0,128,0,0,"I'll be back ","2"+128	;Termintr
SampleProperty130
 .byt 5,"S",16,<3534,>3534,0,128,0,0,"Chime","s"+128	;Windows
SampleProperty131
 .byt 5,"S",23,<2454,>2454,0,128,0,0,"Din","g"+128	;Windows
SampleCategoryText
 .byt 5,"Percuss"	;0
 .byt 2,"Instrum"    ;1
 .byt 6,"Movie  "    ;2
 .byt 1,"Python "    ;3
 .byt 3,"Windows"    ;4
 .byt 7,"Misc.  "    ;5

pmKeyColumn
 .byt %11111110
 .byt %11111101
 .byt %11111011
 .byt %11110111
 .byt %11011111
 .byt %10111111
 .byt %01111111
pmSoftRow
 .byt 7,4,2,5
pmColumnBits
 .byt 0
 .byt 8*1
 .byt 8*2
 .byt 8*3
 .byt 8*4
 .byt 8*5
 .byt 8*6
 .byt 8*7
pmSoftBits
 .byt 64,64
 .byt 128,192,0
