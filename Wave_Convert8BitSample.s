;Convert 8 Bit signed samples to lhl
;1000 Source Sample(Maximum 16K)
;5000 Converted Sample(8K max)
;7000 Code


 .zero
*=$00
source		.dsb 2
end		.dsb 2
destination	.dsb 2

 .text
*=$8000
ConvertSample
	lda #<$5000
	sta destination
	lda #>$5000
	sta destination+1

	ldx #128
	ldy #00
.(	
loop1	txa
	eor #128
	tax
	
	lda (source),y
	cpx #1
	bcc StoreLowNibble
StoreHighNibbleAndIncMem
	and #%11110000
	bne skip4
	lda #%00010000
skip4	ora (destination),y
	sta (destination),y
	inc destination
	bne skip1
	inc destination+1
	jmp skip1
StoreLowNibble
	lsr
	lsr
	lsr
	lsr
	bne skip5
	lda #1
skip5	sta (destination),y
skip1	lda source
	clc
	adc #2
	sta source
	bcc skip2
	inc source+1
skip2	lda source+1
	cmp end+1
	bcc loop1
	bne skip3
	lda source
	cmp end
	bcc loop1
	beq loop1
skip3	;Stick a zero at end
.)
	lda #00
	sta (destination),y
	inc destination
.(
	bne skip1
	inc destination+1
skip1	rts	
.)	

	