;Play lhl sample @5Khz
#define	VIA_PCR	$030C
#define	VIA_PORTA	$030F
#define	VIA_T1LL	$0306
#define	VIA_T1LH	$0307
#define	VIA_T1CL	$0304

 .zero
*=$00
sample		.dsb 2
templo		.dsb 1
temphi              .dsb 1
NibbleFlag          .dsb 1
SavedA              .dsb 1
SavedX              .dsb 1
SavedY              .dsb 1
EndFlag		.dsb 1

 .text
*=$A000
PlaySample
	ldx #$7f
	lda #7
	jsr $F590
	sei
	lda #8
	sta VIA_PORTA
	lda #$FF
	sta VIA_PCR
	lda #$DD
	sta VIA_PCR
	lda #00
	sta VIA_PORTA
	lda #$FD
	sta VIA_PCR
	lda #<IRQRoutine
	ldx $245
	sta $245
	lda #>IRQRoutine
	ldy $246
	sta $246
	stx templo
	sty temphi
	lda #<200
	sta VIA_T1LL
	lda #>200
	sta VIA_T1LH
	
	lda #<$5000
	sta sample
	lda #>$5000
	sta sample+1
	lda #128
	sta NibbleFlag
	lda #00
	sta EndFlag
	
	cli
loop1	lda EndFlag
	beq loop1
	sei
	ldx templo
	ldy temphi
	stx $245
	sty $246
	lda #$DD
	sta VIA_PCR
	lda #<10000
	sta VIA_T1LL
	lda #>10000
	sta VIA_T1LH
	cli
	rts
	
IRQRoutine
	;Reset irq
	bit VIA_T1CL
	
	;Save reg
	sta SavedA
	stx SavedX
	sty SavedY
	
	ldy #00
	lda NibbleFlag
	eor #128
	sta NibbleFlag
.(
	bmi PlayHi
PlayLo	lda (sample),y
	and #15
	sta VIA_PORTA
	
	lda SavedA
	ldx SavedX
	ldy SavedY
	
	rti
	
PlayHi	lda (sample),y
	lsr
	lsr
	lsr
	lsr
	sta VIA_PORTA
	beq EndSample
	
	inc sample
	bne skip1
	inc sample+1
skip1	
	
	lda SavedA
	ldx SavedX
	ldy SavedY
	
	rti
	

EndSample	lda #1
.)
	sta EndFlag
	
	lda SavedA
	ldx SavedX
	ldy SavedY
	
	rti

