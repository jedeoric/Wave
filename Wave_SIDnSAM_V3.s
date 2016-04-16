;Wave_SIDnSAM_V3.s
;137 Bytes (42 Less Bytes than previous and 3% faster)
;Based on 5Khz IRQ(200 Cycles)
;CPU Load is between 23% and 83% (Real Machine)
;No Sample or SID   45 Cycles		- 23%
;SampleLo+SID 	166 Cycles	- 83%
;SampleHi+SID 	155 Cycles	- 78%
;SampleLo Only	77 Cycles		- 39%
;SampleHi Only	66 Cycles		- 33%
;SID Only		137 Cycles	- 69%

irqDriver
	;Reset IRQ
	bit VIA_T1CL		;20/21/22
	
	;Record Acc
	sta $A0			;23/24 (OriginalAccumulator+1)
	
	;Countdown Music IRQ
	dec $A9			;25/26 (MusicCountdown)
	bne SIDPatch		;27/28
	lda #100			;29/2A
	sta $A9			;2B/2C (MusicCountdown)
	sta $AA			;2D/2E (MusicProcessFlag)
	
	;Either Patched with Jmp or Perform 16 bit fractional stepping for SID
FracSIDLC
SIDPatch
	jmp ProcSAM		;2F/30/31
;	lda #00			;
;	sec			;
FracSIDLR	adc #00			;32/33
	sta $30			;34/35 (FracSIDLC+1)
FracSIDHC
	lda #00			;36/37
FracSIDHR
	adc #00			;38/39
	sta $37			;3A/3B (FracSIDHC+1)
	bcc ProcSAM		;3C/3D
	
	;Set SID AY Register
	lda #$FF			;3E/3F
	sta VIA_PCR		;40/41/42
SIDRegister
	lda #08			;43/44
	sta VIA_PORTA		;45/46/47
	lda #$DD			;48/49
	sta VIA_PCR		;4A/4B/4C
	
	;Process SID and store
RegSIDVal	lda #00			;4D/4E
RegSIDEOR	eor #00			;4F/50
	sta $4E			;51/52 (RegSIDVal+1)
	sta VIA_PORTA		;53/54/55
	
	;Write SID to AY
	lda #$FD			;56/57
	sta VIA_PCR		;58/59/5A
	
	;Restore Sample AY Register
	lda #$FF			;5B/5C
	sta VIA_PCR		;5D/5E/5F
SAMRegister
	lda #14			;60/61
	sta VIA_PORTA		;62/63/64
	lda #$DD			;65/66
	sta VIA_PCR		;67/68/69
	;Write last Sample value
SAMValue	lda #00			;6A/6B
	and #15			;6C/6D
	sta VIA_PORTA		;6E/6F/70
	lda #$FD			;71/72
	sta VIA_PCR		;73/74/75

ProcSAM	;Jump either to High Nibble Process, Low Nibble Process or No Sample
SAMVector	jmp $009F			;76/77/78

ProcSAMHi	;Process High Nibble Sample
	lda $6B			;79/7A (SAMValue+1)
	lsr			;7B
	lsr			;7C
	lsr			;7D
	lsr			;7E
	sta VIA_PORTA		;7F/80/81
	
	;Switch to Process Low Nibble next time
	lda #<ProcSAMLo		;82/83
	sta $77			;84/85 (SAMVector+1)
	
	lda $A0			;86/87 (OriginalAccumulator+1)
	rti			;88
	
ProcSAMLo
SAMMemory	;Process Low Nibble Sample
	lda $dead			;89/8A/8B
	beq EndSample		;8C/8D
	sta $6B			;8E/8F (SAMValue+1)
	and #15			;90/91
	sta VIA_PORTA		;92/93/94
	
	;Switch to process High Nibble next time
	lda #<ProcSAMHi		;95/96
	sta $77			;97/98 (SAMVector+1)
	
	;Increment Sample Address
	inc $8A			;99/9A (SAMMemory+1)
	bne SAMNoSAM		;9B/9C
	inc $8B			;9D/9E (SAMMemory+2)
SAMNoSAM
OriginalAccumulator
	lda #00			;9F/A0
	rti			;A1

EndSample	;We'll keep things simple with Sample and limit to 5Khz with no looping
	lda #<SAMNoSAM		;A2/A3
	sta $77			;A4/A5 (SAMVector+1)
	jmp SAMNoSAM		;A6/A7/A8

;28
ProcSID2	;Process Second SID (Alt to SAM)
	lda #00			;
	sec			;
FracSI2LR	adc #00			;32/33
	sta $30			;34/35 (FracSIDLC+1)
FracSI2HC
	lda #00			;36/37
FracSI2HR
	adc #00			;38/39
	sta $37			;3A/3B (FracSIDHC+1)
	bcc SAMNoSAM		;3C/3D
RegSI2Val	lda #00			;4D/4E
RegSI2EOR	eor #00			;4F/50
	sta $4E			;51/52 (RegSIDVal+1)
	sta VIA_PORTA		;53/54/55
	lda $A0
	rti	
;29