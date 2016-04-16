;Compiler V2
;Scan for duplicates and remove
; Pattern column 1
; Pattern column 2
; Pattern column 3
; Pattern columns 4,5,6
; Effects
; Ornaments
;Scan for redundants and remove (elements that reside within the range but are not used)
; Redundant Patterns
; Redundant Effects
; Redundant Ornaments
;Compile Pattern Columns
; Compile Column 1
; Compile Column 2
; Compile Column 3
; Compile Column 4
; Compile Column 5
; Compile Column 6
;Compile Effects
;Compile Ornaments
;Compile LHL Samples

BuildPatternProliferationTables


LookForDuplicatePatternColumn1
	ldx #00
.(	
loop2	lda PatternAddressLo,x
	sta pattern1
	lda PatternAddressHi,x
	sta pattern1+1
	;
	lda PatternAddressLo+1,x
	sta pattern2
	lda PatternAddressHi+1,x
	sta pattern2+1
	;
	lda #64
	sta RowCount
	
	ldy #01
loop1	lda (pattern1),y
	and #7
	sta Temp01
	lda (pattern2),y
	and #7
	cmp Temp01
	bne DifferenceFound
	
	lda pattern1
	clc
	adc #11
	sta pattern1
	bcc skip1
	inc pattern1
skip1
	lda pattern2
	clc
	adc #11
	sta pattern2
	bcc skip2
	inc pattern2
skip2	
	dec RowCount
	bne loop1
	
	;Duplicate found
	jmp RemoveDuplicateSamplePatternColumn
	
DifferenceFound
	;Proceed to next
	cpx mmUltimatePattern
	bcs EndOfPatterns
	inx
	jmp loop2
.)
EndOfPatterns