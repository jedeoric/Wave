;Wave Music Compiler for 1.1
;Expand to encompass
;>VRST expansion
;>Pattern Command storage
;>Expanded Pattern Option
;?Fixed Bar issue


CompileDriver
	;Reserve 32 zpage locations
	sei
	ldx #31
.(
loop1	lda $00,x
	sta $B800,x
	dex
	bpl loop1
.)	
;twi999	nop
;	jmp twi999	
	;Build main header
	lda #00
	sta CM_HEADER
	lda WVE_TEMPO
	sta CM_TEMPO
	lda WVE_LLOOP
	clc
	adc #11
	sta CM_LLOOP
	lda #<$770B
	sta destination
	lda #>$770B
	sta destination+1
	
	;Compile list
	ldx #00
	stx HighestPatternID
.(
loop1	lda WVE_LIST,x

	;Branch if NOT end of list
	bpl skip2
	
	;Compile End of List flag(128)
	jsr CompileByte
	
	;jump out of List
	jmp skip1
	
skip2	;Record Highest PatternID
	cmp HighestPatternID
	bcc skip3
	sta HighestPatternID
skip3	
	;Compile List Pattern
	jsr CompileByte
	
	;Branch on max list
	inx
	bpl loop1
skip1
.)

	;Store Current compile lo address as address of Pattern Address Table (for this program)
	lda destination
	sta pataddrtable
	
	;Store Offset to Pattern Address Table in Compiled music header
	sec
	sbc #<CM_HEADER
	sta CM_HEADER+2
	
	;Store Current compile hi address as address of Pattern Address Table (for this program)
	lda destination+1
	sta pataddrtable+1
	
	;Store Offset to Pattern Address Table in Compiled music header
	sbc #>CM_HEADER
	sta CM_HEADER+3
	
	;Multiply HighestPatternID by 2 and add to Pattern Address Table address to get first
	;address of Compiled Pattern memory
	lda HighestPatternID
	clc
	adc #1
	asl
	adc destination
	sta destination
	lda destination+1
	adc #00
	sta destination+1
	
	;Compile Patterns
	ldx #00
.(	
loop1	jsr StoreCompiledPatternAddress
	jsr FetchPatternAddress	;into row
	jsr CompilePattern
	
	inx
	cpx HighestPatternID
	beq loop1
	bcc loop1
.)

	;Compile Effects
	;Store current compiled address lo as address of EffectAddressTable
	lda destination
	sta effaddrtable
	
	;Store Offset in Compiled Header
	sec
	sbc #<CM_HEADER
	sta CM_HEADER+4
	
	;Store current compiled address hi as address of EffectAddressTable
	lda destination+1
	sta effaddrtable+1
	
	;Store Offset in Compiled Header
	sec
	sbc #>CM_HEADER
	sta CM_HEADER+5
	
	;Multiply HighestEffectID by 2 and add to EffectAddressTable address to get first
	;address of Compiled Effect memory
	lda HighestEffectID
	clc
	adc #1
	asl
	adc destination
	sta destination
	lda destination+1
	adc #00
	sta destination+1
	
	;Compile Effects
	ldx #00
.(	
loop1	jsr StoreCompiledEffectAddress
	jsr FetchEffectAddress	;into row
	jsr CompileEffect
	
	inx
	cpx HighestEffectID
	beq loop1
	bcc loop1
.)
	;Compile Ornaments
	;Store current compiled address lo as address of OrnamentAddressTable
	lda destination
	sta ornaddrtable
	
	;Store Offset in Compiled Header
	sec
	sbc #<CM_HEADER
	sta CM_HEADER+6
	
	;Store current compiled address hi as address of OrnamentAddressTable
	lda destination+1
	sta ornaddrtable+1
	
	;Store Offset in Compiled Header
	sec
	sbc #>CM_HEADER
	sta CM_HEADER+7
	
	;Multiply HighestOrnamentID by 2 and add to OrnamentAddressTable address to get first
	;address of Compiled Ornament memory
	lda HighestOrnamentID
	clc
	adc #1
	asl
	adc destination
	sta destination
	lda destination+1
	adc #00
	sta destination+1
	
	;Compile Ornaments
	ldx #00
.(	
loop1	jsr StoreCompiledOrnamentAddress
	jsr FetchOrnamentAddress	;into row
	jsr CompileOrnament
	
	inx
	cpx HighestOrnamentID
	beq loop1
	bcc loop1
.)
	;Compile Samples
	;Store current compiled address lo as address of SampleAddressTable
	lda destination
	sta samaddrtable
	
	;Store Offset in Compiled Header
	sec
	sbc #<CM_HEADER
	sta CM_HEADER+8
	
	;Store current compiled address hi as address of OrnamentAddressTable
	lda destination+1
	sta samaddrtable+1
	
	;Store Offset in Compiled Header
	sec
	sbc #>CM_HEADER
	sta CM_HEADER+9
	
	;Multiply HighestSampleID by 5 and add to SampleAddressTable address to get first
	;address of Compiled Sample memory
	;5 rather than 2 because the address table will hold 5 entries rather than 2..
	;SampleAddressLo,SampleAddressHi,SampleLoopAddressLo,SampleLoopAddressHi and SampleProperty
	lda HighestSampleID
	asl
	asl
	adc HighestSampleID
	adc destination
	sta destination
	lda destination+1
	adc #00
	sta destination+1
	
	;Compile Samples
	ldx #00
.(	
loop1	jsr StoreCompiledSampleAddress

	inx
	cpx HighestSampleID
	beq loop1
	bcc loop1
.)
;	jsr FindHighestSampleAddress
;	jsr CompileSampleMemory

	;Record destination
	lda destination
	pha
	lda destination+1
	pha
	
	;Restore 32 zpage locations
	ldx #31
.(
loop1	lda $B800,x
	sta $00,x
	dex
	bpl loop1
.)	
	;Recall destination and store in 00-01(End of Compilation)
	pla
	sta $01
	pla
	sta $00
	
	;All Done!!
	cli
	rts

	
StoreCompiledPatternAddress
	txa
	asl
	tay
	lda destination
	sec
	sbc #<CM_HEADER
	sta (pataddrtable),y
	lda destination+1
	iny
	sbc #>CM_HEADER
	sta (pataddrtable),y
	rts

StoreCompiledEffectAddress
	txa
	asl
	tay
	lda destination
	sec
	sbc #<CM_HEADER
	sta (effaddrtable),y
	lda destination+1
	iny
	sbc #>CM_HEADER
	sta (effaddrtable),y
	rts

StoreCompiledOrnamentAddress
	txa
	asl
	tay
	lda destination
	sec
	sbc #<CM_HEADER
	sta (ornaddrtable),y
	lda destination+1
	iny
	sbc #>CM_HEADER
	sta (ornaddrtable),y
	rts

StoreCompiledSampleAddress
	txa
	sta Temp01
	asl
	asl
	adc Temp01
	tay
	lda destination
	sec
	sbc #<CM_HEADER
	sta (samaddrtable),y
	lda destination+1
	iny
	sbc #>CM_HEADER
	sta (samaddrtable),y
	;Also store Sample loop Address Offset ( (LoopAddress - SampleAddress)+(destination - CM_HEADER)
	lda SAMPLELOOPADDRESSLO,x
	sec
	sbc SAMPLEADDRESSTABLELO,x
	sta Temp01
	lda SAMPLELOOPADDRESSHI,x
	sbc SAMPLEADDRESSTABLEHI,x
	sta Temp02
	;
	lda destination
	sec
	sbc #<CM_HEADER
	sta Temp03
	lda destination+1
	sbc #>CM_HEADER
	sta Temp04
	;
	lda Temp01
	clc
	adc Temp03
	iny
	sta (samaddrtable),y
	lda Temp02
	adc Temp04
	iny
	sta (samaddrtable),y
	;Also store Sample Property
	lda SAMPLEPROPERTY,x
	iny
	sta (samaddrtable),y
	rts

FetchPatternAddress
	lda PatternAddressTableLo,x
	sta row
	lda PatternAddressTableHi,x
	sta row+1
	rts

FetchEffectAddress
	lda EffectAddressTableLo,x
	sta effect
	lda EffectAddressTableHi,x
	sta effect+1
	rts

FetchOrnamentAddress
	lda OrnamentAddressTableLo,x
	sta ornament
	lda OrnamentAddressTableHi,x
	sta ornament+1
	rts

FindHighestSampleAddress
	ldx #00
	stx HighestSampleAddressLo
	sta HighestSampleAddressHi
.(	
loop1	lda SAMPLEADDRESSTABLEHI,x
	cmp HighestSampleAddressHi
	beq skip2
	bcc skip1
	sta HighestSampleAddressHi
	lda SAMPLEADDRESSTABLELO,x
	sta HighestSampleAddressLo
	jmp skip1
skip2	lda SAMPLEADDRESSTABLELO,x
	cmp HighestSampleAddressLo
	bcc skip1
	sta HighestSampleAddressLo
	lda SAMPLEADDRESSTABLEHI,x
	sta HighestSampleAddressHi
skip1	inx
	cpx HighestSampleID
	beq loop1
	bcc loop1
.)
	rts

CompileSampleMemory
	lda #<WVE_SAMPLEBANK
	sta sample
	lda #>WVE_SAMPLEBANK
	sta sample
	ldy #00
.(
loop1	lda (sample),y
	sta Temp01
	jsr CompileByte
	inc sample
	bne skip1
	inc sample+1
skip1	lda Temp01
	and #%00001111
	bne loop1
	lda Temp01
	and #%11110000
	bne loop1
	lda sample+1
	cmp HighestSampleAddressHi
	bcc loop1
	bne end
	lda sample
	cmp HighestSampleAddressLo
	bcc loop1
end	rts
.)

CompileEffect
	;Compile Loop
	lda WVE_EFFECTLOOPS,x
.(
	bmi skip1
;	asl
	clc
	adc #1
skip1	jsr CompileByte
.)	
	;Compile Effect
	ldy #00
.(
loop1	lda (effect),y
	sta Temp01
	jsr CompileByte
	iny
	cpy #32
	bcs skip1
	lda Temp01
	bne loop1
skip1	rts
.)

CompileOrnament
	;Compile Loop
	lda WVE_ORNAMENTLOOPS,x
.(
	bmi skip1
;	asl
	;Add 1 because oat will always reference first byte of ornament block which is loop index
	clc
	adc #1
skip1	jsr CompileByte
.)	
	;Compile Ornament
	ldy #00
.(
loop1	lda (ornament),y
	sta Temp01
	jsr CompileByte
	iny
	cpy #32
	bcs skip1
	lda Temp01
	bne loop1
skip1	rts
.)
	
;row == Pattern Address
CompilePattern
	ldy #00
	lda #64
	sta RowCounter
.(
loop1	;Is Row populated at all?
	jsr IsRowPopulated
	bcs skip5
	
	;Count Empty Rows then move on to next row
	inc EmptyRowCounter
	jmp skip6
	
skip5	;Check empty row counter in case we need to add it
	lda EmptyRowCounter
	beq skip7
	
	;Compile Empty Rows count
	jsr CompileEmptyRowsCount

skip7	;Is Cycle used?
	ldy #00
	lda (row),y
	and #3

	beq skip1
	
	;Compile Cycle
	clc
	adc #BR_CYCLE-1
	jsr CompileByte

skip1	;Is EG Period used?
	lda (row),y
	lsr
	lsr
	beq skip2
	
	;Compile EGPeriod
	clc
	adc #BR_EGPERIOD
	jsr CompileByte
	
skip2	;Proceed to Row Byte 1
	iny
	
	;Is Sample used?
	lda (row),y
	and #7
	beq skip3
	
	;Compile Sample
	cmp HighestSampleID
	bcc skip8
	sta HighestSampleID
skip8	clc
	adc #BR_SAMPLE
	jsr CompileByte
	
skip3	;Is Noise Used?
	lda (row),y
	lsr
	lsr
	lsr
	beq skip4
	
	;Compile Noise
	clc
	adc #BR_NOISE
	jsr CompileByte
	
skip4	;Compile Channels Note Groups
	jsr CompileNoteGroup
	bcs FinishedPattern
	jsr CompileNoteGroup
	bcs FinishedPattern
	jsr CompileNoteGroup
	bcs FinishedPattern

skip6	;proceed to next row
	lda row
	clc
	adc #11
	sta row
	lda row+1
	adc #00
	sta row+1
	
	;Count 64 Rows
	dec RowCounter
	beq skip9
	jmp loop1

skip9	lda EmptyRowCounter
	beq FinishedPattern
	
	;Compile Empty Rows count
	jsr CompileEmptyRowsCount

FinishedPattern
	rts
.)

IsRowPopulated
	;If a row contains just 1 change we must compile the complete rows Notes
	
	;Check Sample,Noise,EGPeriod and Cycle fields
	ldy #1
.(
loop1	lda (row),y
	bne PopulatedRow
	dey
	bpl loop1
	;Check Notes A(2),B(5),C(8)
	ldy #2
	lda (row),y
	lsr
	lsr
	cmp #62
	bne PopulatedRow
	;Check Zero Volume
	lda (row),y
	and #3
	cmp #3
	bcc PopulatedRow

	ldy #5
	lda (row),y
	lsr
	lsr
	cmp #62
	bne PopulatedRow
	;Check Zero Volume
	lda (row),y
	and #3
	cmp #3
	bcc PopulatedRow

	ldy #8
	lda (row),y
	lsr
	lsr
	cmp #62
	bne PopulatedRow
	;Check Zero Volume
	lda (row),y
	and #3
	cmp #3
	bcc PopulatedRow
	clc
	rts
PopulatedRow
.)
	sec
	rts
	
	

CompileEmptyRowsCount
	;Decide what code to add based on number of empty rows
	cmp #47
.(
	bcs CompileLongRow
	adc #BR_SHORTROWREST-1
	jsr CompileByte
	jmp skip8

CompileLongRow
	lda #BR_LONGROWREST
	jsr CompileByte
	lda EmptyRowCounter
	sec
	sbc #1
	jsr CompileByte
skip8	lda #00
.)
	sta EmptyRowCounter
	rts
	
CompileNoteGroup
	;Always store Note
	iny
	lda (row),y
	lsr
	lsr
	pha
	clc
	adc #BR_NOTE
	;Ensure Note is last stored field in Note Group
	sta NoteByte

	;If Note is Note then store Volume directly
	pla
	cmp #62
.(
	bcs skip5
	lda (row),y
	and #3
	adc #BR_VOLUME
	jsr CompileByte
	jmp skip6
	
skip5	;If Note is Rest and Volume is 0,1 or 2 then store Volume
	bne skip7
	lda (row),y
	and #3
	cmp #3
	bcc skip6
	adc #BR_VOLUME-1
	jsr CompileByte
	jmp skip6
	
skip7	;If Note is Bar then store Bar and End Pattern
	lda #BR_BAR
	jsr CompileByte
	sec	;Flag caller to terminate pattern
	jmp skip11
	
skip6	;Is Effect Used?
	iny
	lda (row),y
	and #15
	beq skip8
	
	;Compile Effect
	cmp HighestEffectID
	bcc skip1
	sta HighestEffectID
skip1	clc
	adc #BR_EFFECT-1	;Compensate range 1-15
	jsr CompileByte
	
skip8	;Is Ornament used?
	lda (row),y
	lsr
	lsr
	lsr
	lsr
	beq skip9
	
	;Compile Ornament
	cmp HighestOrnamentID
	bcc skip2
	sta HighestOrnamentID
skip2	clc
	adc #BR_ORNAMENT-1	;Compensate range 1-15
	jsr CompileByte
	
skip9	;Is Command Used?
	iny
	lda (row),y
	and #7
	clc	;Flag caller to continue pattern row
	beq skip10
	
	;Compile Command and Parameter
	clc
	adc #BR_COMMAND
	jsr CompileByte
	lda (row),y
	lsr
	lsr
	lsr
	;Since Parameter ALWAYS follows Command we can just write it as a direct byte
	jsr CompileByte
	clc	;Flag caller to continue pattern row

skip10	;NOW store Note
	lda NoteByte
	jsr CompileByte
skip11	rts
.)

CompileByte
	sty cbTemp01
	ldy #00
	sta (destination),y
	inc destination
.(
	bne skip1
	inc destination+1
skip1	ldy cbTemp01
.)
	rts

HighestPatternID		.byt 0
HighestEffectID     	.byt 0
HighestOrnamentID   	.byt 0
HighestSampleID     	.byt 0
HighestSampleAddressLo        .byt 0
HighestSampleAddressHi        .byt 0
Temp01			.byt 0
Temp02			.byt 0
Temp03			.byt 0
Temp04			.byt 0
cbTemp01			.byt 0
EmptyRowCounter		.byt 0
RowCounter		.byt 0
PatternAddressTableLo
 .byt <WVE_PATTERNMEMORY
 .byt <WVE_PATTERNMEMORY+704*1
 .byt <WVE_PATTERNMEMORY+704*2
 .byt <WVE_PATTERNMEMORY+704*3
 .byt <WVE_PATTERNMEMORY+704*4
 .byt <WVE_PATTERNMEMORY+704*5
 .byt <WVE_PATTERNMEMORY+704*6
 .byt <WVE_PATTERNMEMORY+704*7
 .byt <WVE_PATTERNMEMORY+704*8
 .byt <WVE_PATTERNMEMORY+704*9
 .byt <WVE_PATTERNMEMORY+704*0
 .byt <WVE_PATTERNMEMORY+704*11
 .byt <WVE_PATTERNMEMORY+704*12
 .byt <WVE_PATTERNMEMORY+704*13
 .byt <WVE_PATTERNMEMORY+704*14
 .byt <WVE_PATTERNMEMORY+704*15
 .byt <WVE_PATTERNMEMORY+704*16
 .byt <WVE_PATTERNMEMORY+704*17
 .byt <WVE_PATTERNMEMORY+704*18
 .byt <WVE_PATTERNMEMORY+704*19
 .byt <WVE_PATTERNMEMORY+704*20
 .byt <WVE_PATTERNMEMORY+704*21
 .byt <WVE_PATTERNMEMORY+704*22
 .byt <WVE_PATTERNMEMORY+704*23
PatternAddressTableHi
 .byt >WVE_PATTERNMEMORY
 .byt >WVE_PATTERNMEMORY+704*1
 .byt >WVE_PATTERNMEMORY+704*2
 .byt >WVE_PATTERNMEMORY+704*3
 .byt >WVE_PATTERNMEMORY+704*4
 .byt >WVE_PATTERNMEMORY+704*5
 .byt >WVE_PATTERNMEMORY+704*6
 .byt >WVE_PATTERNMEMORY+704*7
 .byt >WVE_PATTERNMEMORY+704*8
 .byt >WVE_PATTERNMEMORY+704*9
 .byt >WVE_PATTERNMEMORY+704*0
 .byt >WVE_PATTERNMEMORY+704*11
 .byt >WVE_PATTERNMEMORY+704*12
 .byt >WVE_PATTERNMEMORY+704*13
 .byt >WVE_PATTERNMEMORY+704*14
 .byt >WVE_PATTERNMEMORY+704*15
 .byt >WVE_PATTERNMEMORY+704*16
 .byt >WVE_PATTERNMEMORY+704*17
 .byt >WVE_PATTERNMEMORY+704*18
 .byt >WVE_PATTERNMEMORY+704*19
 .byt >WVE_PATTERNMEMORY+704*20
 .byt >WVE_PATTERNMEMORY+704*21
 .byt >WVE_PATTERNMEMORY+704*22
 .byt >WVE_PATTERNMEMORY+704*23
EffectAddressTableLo
 .byt <WVE_EFFECTMEMORY
 .byt <WVE_EFFECTMEMORY+32*1
 .byt <WVE_EFFECTMEMORY+32*2
 .byt <WVE_EFFECTMEMORY+32*3
 .byt <WVE_EFFECTMEMORY+32*4
 .byt <WVE_EFFECTMEMORY+32*5
 .byt <WVE_EFFECTMEMORY+32*6
 .byt <WVE_EFFECTMEMORY+32*7
 .byt <WVE_EFFECTMEMORY+32*8
 .byt <WVE_EFFECTMEMORY+32*9
 .byt <WVE_EFFECTMEMORY+32*10
 .byt <WVE_EFFECTMEMORY+32*11
 .byt <WVE_EFFECTMEMORY+32*12
 .byt <WVE_EFFECTMEMORY+32*13
 .byt <WVE_EFFECTMEMORY+32*14
EffectAddressTableHi
 .byt >WVE_EFFECTMEMORY
 .byt >WVE_EFFECTMEMORY+32*1
 .byt >WVE_EFFECTMEMORY+32*2
 .byt >WVE_EFFECTMEMORY+32*3
 .byt >WVE_EFFECTMEMORY+32*4
 .byt >WVE_EFFECTMEMORY+32*5
 .byt >WVE_EFFECTMEMORY+32*6
 .byt >WVE_EFFECTMEMORY+32*7
 .byt >WVE_EFFECTMEMORY+32*8
 .byt >WVE_EFFECTMEMORY+32*9
 .byt >WVE_EFFECTMEMORY+32*10
 .byt >WVE_EFFECTMEMORY+32*11
 .byt >WVE_EFFECTMEMORY+32*12
 .byt >WVE_EFFECTMEMORY+32*13
 .byt >WVE_EFFECTMEMORY+32*14
OrnamentAddressTableLo
 .byt <WVE_ORNAMENTMEMORY
 .byt <WVE_ORNAMENTMEMORY+32*1
 .byt <WVE_ORNAMENTMEMORY+32*2
 .byt <WVE_ORNAMENTMEMORY+32*3
 .byt <WVE_ORNAMENTMEMORY+32*4
 .byt <WVE_ORNAMENTMEMORY+32*5
 .byt <WVE_ORNAMENTMEMORY+32*6
 .byt <WVE_ORNAMENTMEMORY+32*7
 .byt <WVE_ORNAMENTMEMORY+32*8
 .byt <WVE_ORNAMENTMEMORY+32*9
 .byt <WVE_ORNAMENTMEMORY+32*10
 .byt <WVE_ORNAMENTMEMORY+32*11
 .byt <WVE_ORNAMENTMEMORY+32*12
 .byt <WVE_ORNAMENTMEMORY+32*13
 .byt <WVE_ORNAMENTMEMORY+32*14
OrnamentAddressTableHi
 .byt >WVE_ORNAMENTMEMORY
 .byt >WVE_ORNAMENTMEMORY+32*1
 .byt >WVE_ORNAMENTMEMORY+32*2
 .byt >WVE_ORNAMENTMEMORY+32*3
 .byt >WVE_ORNAMENTMEMORY+32*4
 .byt >WVE_ORNAMENTMEMORY+32*5
 .byt >WVE_ORNAMENTMEMORY+32*6
 .byt >WVE_ORNAMENTMEMORY+32*7
 .byt >WVE_ORNAMENTMEMORY+32*8
 .byt >WVE_ORNAMENTMEMORY+32*9
 .byt >WVE_ORNAMENTMEMORY+32*10
 .byt >WVE_ORNAMENTMEMORY+32*11
 .byt >WVE_ORNAMENTMEMORY+32*12
 .byt >WVE_ORNAMENTMEMORY+32*13
 .byt >WVE_ORNAMENTMEMORY+32*14
EndOfCompiler
 .byt 0

