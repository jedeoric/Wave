;Wave_IRQDriver.s

SetupIRQ
	sei
	
	;Redirect Main IRQ vector to IRQDriver
	ldx SYS_IRQVECTOR
	lda #$20
	sta SYS_IRQVECTOR
	
	ldy SYS_IRQVECTOR+1
	lda #$00
	sta SYS_IRQVECTOR+1
	
	stx BasicsIRQVector
	sty BasicsIRQVector+1
	
	;Copy Zero Page Routine
	ldx #00
.(
loop1	lda BaseCopyAddress,x
	sta $20,x
	inx
	bne loop1
.)

	;Set T1 counters high (to ensure they do not trigger IRQ below)
	lda #$FF
	sta VIA_T1CL
	sta VIA_T1CH

	;Clear T1 IRQ
	CMP VIA_T1CL
	
	;Set Column register to %00010000 before entering irq
	lda #$0E
	sta VIA_PORTA
	lda #$FF
	sta VIA_PCR
	lda #$FD
	sta VIA_PCR
	lda #%00010000
	sta VIA_PORTA
	lda #$DD
	sta VIA_PCR
	
	;Set 50Hz Counter
	lda #100
	sta MusicCountdown
	
	;Set T1 to 5Khz
	lda #<200
	sta VIA_T1LL
	sta VIA_T1CL
	lda #>200
	sta VIA_T1LH
	sta VIA_T1CH
	
	jsr StopSID
	jsr StopSample
	
	cli
	rts
	
BaseCopyAddress
 *=$20
ZeroPageRoutineStart

;IRQ Driver resides in zero page to optimise Sample and SID playing to 5Khz(Every 200 cycles)
;The Fast register is (by default) for SID so sample momentarily switches registers
;1x 16 Bit Fractional Stepping Sample Channel
;1x 16 Bit Fractional Stepping SID Channel

;Total Bytes   179 ($B3)Bytes
;CPU Demand     38-83%
;cpu cycles include entering irq(12), Page2 jump(3) and RTI(6)

;Average SID+SAM 75%
;Average SAM     70%
;Average SID     44%

;Based on 5Khz IRQ(200 Cycles)
;137 Bytes (42 Less Bytes than previous and 3% faster)
;Based on 5Khz IRQ(200 Cycles)
;CPU Load is between 23% and 80%
;No Sample or SID   45 Cycles		- 23%
;SampleLo+SID 	160 Cycles	- 80%
;SampleHi+SID 	149 Cycles	- 75%
;SampleLo Only	77 Cycles		- 39%
;SampleHi Only	66 Cycles		- 33%
;SID Only		131 Cycles	- 66%
;Unfortunately XA is being lame and using absolute addresses for everything, so i am forced
;to calculate zp addresses myself.

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


;50/100Hz Counter
MusicCountdown		.byt 0		;A9
MusicProcessFlag		.byt 0		;AA

;Pitchbend Tables
pzTempPitchHi		.byt 0		;DA
pzTempPitchLo		.byt 0		;DB
;pbDestinationPitchLo	.byt 0,0,0	;DC
;pbDestinationPitchHi	.byt 0,0,0	;DF

;Keyboard Variables
pzKeyRegister		.byt 0		;E2

;B0 Effect Channel A Active(1) or Inactive(0)
;B1 Effect Channel B Active(1) or Inactive(0)
;B2 Effect Channel C Active(1) or Inactive(0)
;B3 Ornament Channel A Active(1) or Inactive(0)
;B4 Ornament Channel B Active(1) or Inactive(0)
;B5 Ornament Channel C Active(1) or Inactive(0)
;B6 Pattern Playing Active
;B7 List(Music) Playing Active
pzMusicElementActivity	.byt 0		;E4

;Other Music Variables
pzNoteTempoCount		.byt 0		;E5
pzIntermediatePitchLo         .byt 0		;E9
pzIntermediatePitchHi         .byt 0		;EA
pzPatternRowPlayFlag	.byt 0		;EB

;AY Bank
ayBankCurrent
ayPitchLo           	.byt 0,0,0	;EC
ayPitchHi           	.byt 0,0,0	;EF
ayNoise             	.byt 0		;F2
ayStatus            	.byt %01111000	;F3
ayVolume            	.byt 0,0,0	;F4
ayEGPeriod		.byt 0,0		;F7
ayCycle			.byt 0		;F9

;Music Pointers
pmPattern 		.byt 0,0		;FA
pmOrnament		.byt 0,0		;FC
pmEffect  		.byt 0,0		;FE
peTemp02			.byt 0

ZeroPageRoutineEnd
 *=BaseCopyAddress+(ZeroPageRoutineEnd-ZeroPageRoutineStart)
BaseCopyEndAddress

SIDActivity		.byt 0		;
SAMActivity                   .byt 0              ;
pzPatternRowCounter		.byt 64		;£6
pzListIndex		.byt 0		;E7
pzTemp01			.byt 0		;E8


Main50HzIRQ
	;Reset 50Hz Countdown(actually 100Hz)
	lda #50
	sta MusicCountdown
	
	;Check Music
	lda pzMusicElementActivity
.(
	beq skip2
	
	;Progress music elements
	jsr ProcMusic
	
	;Send AY
	sei
	lda #$DD
	sta VIA_PCR
	ldx #13

loop1	lda ayBankCurrent,x
	cmp ayBankReference,x
	beq skip1
	sta ayBankReference,x

	ldy ayRealRegister,x
	sty VIA_PORTA
	ldy #$FF
	sty VIA_PCR
	ldy #$DD
	sty VIA_PCR
	sta VIA_PORTA
	lda #$FD
	sta VIA_PCR
	sty VIA_PCR
skip1	dex
	bpl loop1
skip2	cli
.)
	;Read Keyboard every 2nd Interrupt
AlternateKeyscan
	lda #00
	eor #128
	sta AlternateKeyscan+1
.(
	bmi skip1
	jsr RapidKeyScan

skip1	;Is SID FastReg being used?
.)

	ldx #$DD
	lda $77
	cmp #<SAMNoSAM
	beq irqskip1
	
	;Restore SAM Register
	sei
	stx VIA_PCR
	ldy SAMRegister+1
	sty VIA_PORTA
	ldy #$FF
	sty VIA_PCR
	lda $6B
	and #15
	stx VIA_PCR
	sta VIA_PORTA
	ldx #$FD

irqskip1	stx VIA_PCR
	cli

	;Process Counter
pzIRQCounter
	lda #00
.(
	beq skip1
	dec pzIRQCounter+1

skip1	
.)
	;Return
	rts

pzKeyInDelayPhase		.byt 0		;E3

;To improve performance, rather than interrupt SID, automatically setup Column 00
;before calling keyscan for first time and after keyscan for next time. In this way
;No keys will not interrupt Sound through SEI.
;Rapidly scan for keys
;Scan Shift,Ctrl,Func Seperately
;0-63 Key
;+64  Shift
;+128 Ctrl
;+192 Func
;Then combine into single byte with a specific code when nothing pressed.
RapidKeyScan
	ldy #07	;Row
.(
loop1	sty VIA_PORTB
	jsr KeyDelay
	lda VIA_PORTB
	and #8
	bne skip1
	dey
	bpl loop1
	lda #NULLKEYCODE
	sta pzKeyRegister
	rts
skip1	;Found row with key activity(column in Y) - now isolate key
	;Which means we must NOW have virtual Key column register
	sei
	lda #$FF
	sta VIA_PCR
	lda #$0E
	sta VIA_PORTA
	lda #$FD
	sta VIA_PCR

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
	;Restore Key column %00010000
	lda #$FF
	sta VIA_PCR
	lda #$0E
	sta VIA_PORTA
	lda #$FD
	sta VIA_PCR
	lda #%00010000
	sta VIA_PORTA
	
	;Restore SID register
	lda #$FF
	sta VIA_PCR
	lda SIDRegister+1
	sta VIA_PORTA
	lda #$DD
	sta VIA_PCR
	cli
	rts

KeyDelay
	nop
	nop
	rts

;To optimise pitch and Volume processing ProcMusic processes the music as follows
;If NoteCount times out then procpattern (To capture Pattern Note and PatternVolume)
;Then for each channel
; Ornament		The relative Note offset
;  convert to pitch
; Effect		The relative Pitch offset	The accumulative Note offset
;  convert to ayvolume
; Pitchbend	Accumulative Pitch offset
;  convert to ayPitch


ProcMusic
	;Check Pattern Note
	lda pzMusicElementActivity
	asl
.(
	bpl skip1

	;Process Pattern and List
	dec pzNoteTempoCount
	bne skip1
	lda pmMusicTempo
	sta pzNoteTempoCount
	
	jsr ProcPattern
skip1
.)

	;Process Effects, Ornaments, Pitchbend, Rapid Register and Conversions
	ldx #2

.(
loop1	;Check Ornament
	lda pzMusicElementActivity
	and pmOrnamentBits,x
	cmp #1
	lda pmPatternNote,x
	bcc skip1
	
	;Process Ornament
	ldy pmOrnamentID,x
	lda pmOrnamentAddressLo,y
	sta pmOrnament
	lda pmOrnamentAddressHi,y
	sta pmOrnament+1
loop2	ldy pmOrnamentIndex,x
	lda (pmOrnament),y
	bne skip2
	ldy pmOrnamentID,x
	lda mmOrnamentLoops,y
	bmi skip6
	sta pmOrnamentIndex,x
	jmp loop2
skip6	lda pzMusicElementActivity
	and pmNoiseMask,x
	sta pzMusicElementActivity
	lda #00
skip2	clc
	adc pmPatternNote,x
	and #127
	inc pmOrnamentIndex,x
	
	;Check Pitchbend
	;If Pitchbend off then calc rapid register pitch from PatternNote+OrnamentOffset
	;If Pitchbend on then calc rapid register pitch from semitone stuff
skip1	tay
	lda pbFlag,x
	beq skip3
	dec pbDelayCount,x
	bpl skip10
	lda pbDelayRefer,x
	sta pbDelayCount,x
	jsr pbProcPitchbend
	
	jmp skip7
skip10	;Ensure that current pitchbend interpolation is stored during a delay
	cmp #128
	bcc ContinueDescendHold
	jsr ContinueAscending4
	jmp skip7
ContinueDescendHold
	jsr ContinueDescending4
	jmp skip7

skip3	;Convert to Pitch
	lda pmPitchTableHi,y
	sta pzIntermediatePitchHi
	lda pmPitchTableLo,y
	sta pzIntermediatePitchLo
	
	;Check if either SID is active
	cpx SIDActivity
	bne skip7

skip11	;Check Note no less than C-2(24)
;	cpy #24
;	bcs skip8
;	ldy #24
skip8	;Check note no more than D#6(75)
	cpy #76
	bcc skip9
	ldy #75
skip9	;Convert to 16 bit SID Frac
	lda rssFracStepLo,y
	sta FracSIDLR+1
	lda rssFracStepHi,y
	sta FracSIDHR+1

	
skip7	;Check Effect
	lda pzMusicElementActivity
	and pmEffectBits,x
	beq skip4
	
	;Process Effect
	ldy pmEffectID,x
	lda pmEffectAddressLo,y
	sta pmEffect
	lda pmEffectAddressHi,y
	sta pmEffect+1
	ldy pmEffectIndex,x
loop3	lda (pmEffect),y
	and #%11100000
	lsr
	sta vector1+1
	lda (pmEffect),y
	iny
	and #31
	adc #255-15
	clc
vector1	jsr pmeLoopOrEnd
	bcs loop3
	tya
	sta pmEffectIndex,x

skip4	;Transfer Intermediate Pitch to AY Registers
	lda pzIntermediatePitchLo
	sta ayPitchLo,x
	lda pzIntermediatePitchHi
	sta ayPitchHi,x
	
	;Progress to next Effect/Ornament
	dex
	bmi skip5
	jmp loop1
skip5	rts
.)

;1) Process pitchbend of channel pitch
;2) Process rapid-register if on
;Both pzTempPitchLo and pzTempPitchHi must be zp
pbProcPitchbend
	lda pbFlag,x
	bpl Descend
	jmp Ascend
Descend	;Descend
	dec pmStepCount,x
	bpl ContinueDescending
	
	;Set up next Semitone Interpolation
	;Decrement Pattern Note
	dec pmPatternNote,x
	;But Use Note after Ornament has dealt with it(A-1)
	tya
	dey
	cmp pbDestinationNote,x
.(
	bne skip1
	inc pmPatternNote,x
	lda #00
	sta pbFlag,x
	;Still need to setup intermidiate pitch
	lda pmPitchTableLo+1,y
	sta pzIntermediatePitchLo
	lda pmPitchTableHi+1,y
	sta pzIntermediatePitchHi
	
	rts
skip1	;Fetch pitch of this semitone, subtract from next to get difference
.)
	lda pmPitchTableLo,y
	sec
	sbc pmPitchTableLo+1,y
	sta pzTempPitchLo
	lda pmPitchTableHi,y
	sbc pmPitchTableHi+1,y
	sta pzTempPitchHi

	;Shift Down Difference to get step size through semitone
	jsr pbPerformShifts
	
	;Transfer result to Channel Pitch Interpolation Step Tables
	lda pzTempPitchLo
	sta pbChannelInterpolationStepLo,x
	lda pzTempPitchHi
	sta pbChannelInterpolationStepHi,x

	;Reset Interpolation Step accumulator
	lda #00
	sta pbChannelInterpolationAccumulatorLo,x
	sta pbChannelInterpolationAccumulatorHi,x
	
	;Reset Count
	lda pmStepRefer,x
	sta pmStepCount,x
	
	;If either SID or Sample RapidReg used then perform shifting on fractional step too
	
	;Is SID Active on this channel?
	cpx SIDActivity
	bne ContinueDescending3
	
	;Calculate Difference in Fracs
	lda rssFracStepLo+1,y
	sec
	sbc rssFracStepLo,y
	sta pzTempPitchLo
	lda rssFracStepHi+1,y
	sbc rssFracStepHi,y
	sta pzTempPitchHi
	
	;Shift Down Difference to get step size through semitone
	jsr pbPerformShifts
	
	;Transfer result to Rapid Pitch Interpolation Step Tables
	lda pzTempPitchLo
	sta pbRapidInterpolationStepLo,x
	lda pzTempPitchHi
	sta pbRapidInterpolationStepHi,x
	
	;Reset Interpolation Step accumulator
	lda #00
	sta pbRapidInterpolationAccumulatorLo,x
	sta pbRapidInterpolationAccumulatorHi,x
	
	;Fetch Current Ornament resultant note
	jmp ContinueDescending2
	

ContinueDescending
	;Transfer Current Ornament resultant note to Y
;	tay

	;Process Rapid Register Pitchbend?
	cpx SIDActivity
	bne ContinueDescending3
ContinueDescending2

	;Accumulate Interpolation Steps in Accumulator
	jsr AccumulateSIDInterpolationSteps
	;Subtract from Current Ornament resultant note(Y) pitch and store result to SID Frac
	lda rssFracStepLo,y
	clc
	adc pbRapidInterpolationAccumulatorLo,x
	sta FracSIDLR+1
	lda rssFracStepHi,y
	adc pbRapidInterpolationAccumulatorHi,x
	sta FracSIDHR+1
ContinueDescending3
	;Process Channel Pitchbend (Note in Y)

	;Accumulate Interpolation Steps in Accumulator
	jsr AccumulateInterpolationSteps
ContinueDescending4	
	;Subtract from Current Ornament resultant note(Y) pitch
	lda pmPitchTableLo,y
	adc pbChannelInterpolationAccumulatorLo,x
	sta pzIntermediatePitchLo
	lda pmPitchTableHi,y
	adc pbChannelInterpolationAccumulatorHi,x
	sta pzIntermediatePitchHi
	rts
	
Ascend	;Ascend
	dec pmStepCount,x
	bpl ContinueAscending
	
	;Set up next Semitone Interpolation
	;Increment Pattern Note
	inc pmPatternNote,x
	;But Use Note after Ornament has dealt with it(A-1)
	tya
	iny
	
	cmp pbDestinationNote,x
.(
	bne skip1
	lda #00
	sta pbFlag,x
	
	;Still need to setup intermidiate pitch
	dec pmPatternNote,x
	lda pmPitchTableLo-1,y
	sta pzIntermediatePitchLo
	lda pmPitchTableHi-1,y
	sta pzIntermediatePitchHi
	rts
skip1	;Fetch pitch of this semitone, subtract from next to get difference
.)
	lda pmPitchTableLo-1,y
	sec
	sbc pmPitchTableLo,y
	sta pzTempPitchLo
	lda pmPitchTableHi-1,y
	sbc pmPitchTableHi,y
	sta pzTempPitchHi

	;Shift Down Difference to get step size through semitone
	jsr pbPerformShifts
	
	;Transfer result to Channel Pitch Interpolation Step Tables
	lda pzTempPitchLo
	sta pbChannelInterpolationStepLo,x
	lda pzTempPitchHi
	sta pbChannelInterpolationStepHi,x

	;Reset Interpolation Step accumulator
	lda #00
	sta pbChannelInterpolationAccumulatorLo,x
	sta pbChannelInterpolationAccumulatorHi,x
	
	;Reset Count
	lda pmStepRefer,x
	sta pmStepCount,x
	
	;If Rapid Register used(2+) then perform shifting on fractional step too
	cpx SIDActivity
	bne ContinueAscending3
	
	;Calculate Difference in Fracs
	lda rssFracStepLo,y
	sec
	sbc rssFracStepLo-1,y
	sta pzTempPitchLo
	lda rssFracStepHi,y
	sbc rssFracStepHi-1,y
	sta pzTempPitchHi
	
	;Shift Down Difference to get step size through semitone
	jsr pbPerformShifts
	
	;Transfer result to Rapid Pitch Interpolation Step Tables
	lda pzTempPitchLo
	sta pbRapidInterpolationStepLo,x
	lda pzTempPitchHi
	sta pbRapidInterpolationStepHi,x
	
	;Reset Interpolation Step accumulator
	lda #00
	sta pbRapidInterpolationAccumulatorLo,x
	sta pbRapidInterpolationAccumulatorHi,x
	
	;Fetch Current Ornament resultant note
	jmp ContinueAscending2
	

ContinueAscending
	;Transfer Current Ornament resultant note to Y
;	tay

	;Process SID Pitchbend?
	cpx SIDActivity
	bne ContinueAscending3
ContinueAscending2

	;Accumulate Interpolation Steps in Accumulator
	jsr AccumulateSIDInterpolationSteps
	;Add to Current Ornament resultant note(Y) pitch to SID
	lda rssFracStepLo,y
	sec
	sbc pbRapidInterpolationAccumulatorLo,x
	sta FracSIDLR+1
	lda rssFracStepHi,y
	sbc pbRapidInterpolationAccumulatorHi,x
	sta FracSIDHR+1
ContinueAscending3
	;Process Channel Pitchbend (Note in Y)

	;Accumulate Interpolation Steps in Accumulator
	jsr AccumulateInterpolationSteps
ContinueAscending4
	;Add to Current Ornament resultant note(Y) pitch
	lda pmPitchTableLo,y
	sec
	sbc pbChannelInterpolationAccumulatorLo,x
	sta pzIntermediatePitchLo
	lda pmPitchTableHi,y
	sbc pbChannelInterpolationAccumulatorHi,x
	sta pzIntermediatePitchHi
	rts

	;Shift Down steps through semitone
pbPerformShifts
	;Fetch Number of Shifts
	lda pbBranchStep,x	;0,4,8,etc.
	sta pbBranchVector+1
pbBranchVector
	bne ShiftCod1
ShiftCode	lsr pzTempPitchHi	;0
	ror pzTempPitchLo
	
ShiftCod1	lsr pzTempPitchHi	;1
	ror pzTempPitchLo

	lsr pzTempPitchHi	;2
	ror pzTempPitchLo
	
	lsr pzTempPitchHi	;3
	ror pzTempPitchLo

	lsr pzTempPitchHi	;4
	ror pzTempPitchLo

	lsr pzTempPitchHi	;5
	ror pzTempPitchLo

	lsr pzTempPitchHi	;6
	ror pzTempPitchLo
	
	;7 (Glissando)
	rts

AccumulateInterpolationSteps
	lda pbChannelInterpolationAccumulatorLo,x
	clc
	adc pbChannelInterpolationStepLo,x
	sta pbChannelInterpolationAccumulatorLo,x
	lda pbChannelInterpolationAccumulatorHi,x
	adc pbChannelInterpolationStepHi,x
	sta pbChannelInterpolationAccumulatorHi,x
	rts
AccumulateSIDInterpolationSteps
	lda pbRapidInterpolationAccumulatorLo,x
	clc
	adc pbRapidInterpolationStepLo,x
	sta pbRapidInterpolationAccumulatorLo,x
	lda pbRapidInterpolationAccumulatorHi,x
	adc pbRapidInterpolationStepHi,x
	sta pbRapidInterpolationAccumulatorHi,x
	rts

;Effect Modifiers
;  xx00 Loop or End(0)
;  xx10 Noise Off
;  xx20 EG Off
;  xx30 Tone Off
;  xx40 Volume Offset 	>>
;  xx50 Noise Offset +Noise On
;  xx60 EGPeriod Offset +EG On>>
;  xx70 Pitch Offset +Tone On
PageAllignedEffectCommands
 .dsb 256-(*&255)
pmeLoopOrEnd	;00
 	ldy pmEffectID,x
 	lda mmEffectLoops,y
 	bpl pmeLoop
 	;Just End
	lda pzMusicElementActivity
	and pmToneMask,x
	sta pzMusicElementActivity
	rts

pmeNoiseOff	;10
	lda ayStatus
	ora pmNoiseBit,x
	sta ayStatus
	sec
	rts
	
	;space to 16 bytes
pmeLoop 	tay
	sec
	rts
	
CompositeKey		.byt 0

PatternID			.byt 0
PatternCursorX		.byt 0
PatternCursorY		.byt 0

pmeEGOff		;20
	lda ayVolume,x
	and #15
	sta ayVolume,x
	lda #00
	sta pmEGActiveFlag,x
	sec
	rts
	
	;space to 16 bytes
OrnamentID		.byt 0
OrnamentBaseIndex		.byt 0
OrnamentCursorY		.byt 0

pmeToneOff	;30
	lda ayStatus
	ora pmToneBit,x
	sta ayStatus
	sec
	rts
	
	;space to 16 bytes
EffectID			.byt 0
EffectBaseIndex               .byt 0
EffectCursorY                 .byt 0
EffectLoopIndex               .byt 0
EffectTemp01                  .byt 0
dsTemp01			.byt 0
Grabbed_EffectEntryByte	.byt 0

pmeVolumeOFS	;40
	adc pmPatternVolume,x
	cmp #16
	bcs EndEffect
	sta pmPatternVolume,x
	sta ayVolume,x
	clc
	rts
	
	;space to 16 bytes
SourceIndex		.byt 0
ScreenRows		.byt 0

pmeNoiseOFS	;15
	adc ayNoise
	and #31
	sta ayNoise
	lda ayStatus
	and pmNoiseMask,x
	sta ayStatus
	sec
	rts
	
	;space to 16 bytes
SampleCursorY		.byt 0

pmeEGPerOFS	;15
	adc ayEGPeriod
	sta ayEGPeriod
	lda ayVolume,x
	ora #16
	sta ayVolume,x
	sta pmEGActiveFlag,x
	clc
	rts
	
	;space to 16 bytes
PreviousEditorID		.byt 0

	
pmePitchOFS	;-
.(
	;A pitch offset is always relative to the Intermediate Pitch
	sta pzTemp01
	adc pzIntermediatePitchLo
	sta pzIntermediatePitchLo
	bit pzTemp01
	bmi skip2
	bcc skip1
	inc pzIntermediatePitchHi
	jmp skip1
skip2	bcs skip1
	dec pzIntermediatePitchHi
skip1	lda ayStatus
.)
	and pmToneMask,x
	sta ayStatus
	sec
	rts

EndEffect	lda pzMusicElementActivity
	and pmEffectMask,x
	sta pzMusicElementActivity
	clc
	rts


ProcPattern
	;Capture Previous Pattern Notes (incase Pitchbend needs them)
	lda pmPatternNote
	sta pbOldPatternNote
	lda pmPatternNote+1
	sta pbOldPatternNote+1
	lda pmPatternNote+2
	sta pbOldPatternNote+2
	
	
	
	;Capture EG cycle
	ldy #00
	lda (pmPattern),y
	and #3
.(
	beq SkipCycleMod
	tax
	lda pmCycleCode-1,x
	sta ayCycle
	lda #128
	sta ayBankReference+13
SkipCycleMod
.)
	;Capture EGPeriod
	lda (pmPattern),y
	lsr
	lsr
.(
	beq SkipEGPeriodMod
	sta ayEGPeriod
SkipEGPeriodMod
.)
	;Capture Sample
	iny
	lda (pmPattern),y
	and #7
.(
	beq CheckIfSampleEnded
	tax
	jsr StartSample
	jmp skip2
CheckIfSampleEnded
	;If no sample on this entry and has ended then replace first 3 bytes
	;of smpExtractionCode with JMP smpSkip1
	lda SAMVector+1
	cmp #<SAMNoSAM
	bne skip2
	;Stop Sample
	jsr StopSample

skip2
.)
	;Capture Noise
	lda (pmPattern),y
	lsr
	lsr
	lsr
.(
	beq SkipNoiseMod
	sta ayNoise
SkipNoiseMod
.)
	
	
	;Capture Note & Volume on A
	iny
	lda (pmPattern),y
	lsr
	lsr
	cmp #62
.(
	beq skip6
	adc #11
	sta pmPatternNote
	
	;If Note specified always default to Noise Off, Tone On
	lda ayStatus
	and pmToneMask
	ora pmNoiseBit
	sta ayStatus

	lda (pmPattern),y
	and #3
	tax
	lda pmEntriesRealVolume,x
	sta pmPatternVolume
	tax
	;If no effect used then transfer volume directly to AY
	iny
	lda (pmPattern),y
	and #15
	bne skip2
	stx ayVolume
	jmp skip2
skip6     ldx #00
	jsr DealWithRest
	jmp SkipNote

skip2	;Capture Ornament & Effect on A
	;If either are not set (0) then disable in music element
	lda (pmPattern),y
	lsr
	lsr
	lsr
	lsr
	beq SkipOrnamentMod
	sec
	sbc #1
	sta pmOrnamentID
	lda #00
	sta pmOrnamentIndex
	;Turn on ornament
	lda pzMusicElementActivity
	ora #%00001000
	sta pzMusicElementActivity
	jmp skip3
SkipOrnamentMod
	lda pzMusicElementActivity
	and #%11110111
	sta pzMusicElementActivity
	
skip3	lda (pmPattern),y
	and #15
	beq SkipEffectMod
	sec
	sbc #1
	sta pmEffectID
	lda #00
	sta pmEffectIndex
	;Turn on effect
	lda pzMusicElementActivity
	ora #00000001
	sta pzMusicElementActivity
	jmp skip4
SkipEffectMod
	lda pzMusicElementActivity
	and #%11111110
	sta pzMusicElementActivity

skip4	;Capture Command & Param on A
	iny
	lda (pmPattern),y
	and #7
	beq SkipCommandMod
	;Perform Command in A-1
	tax
	lda (pmPattern),y
	lsr
	lsr
	lsr
	ldy pmCommandActionVectorLo-1,x
	sty vector1+1
	ldy pmCommandActionVectorHi-1,x
	sty vector1+2
	ldx #00	;Channel
vector1	jsr $dead
SkipCommandMod
SkipNote
.)
	

	;Capture Note & Volume on B
	ldy #5
	lda (pmPattern),y
	lsr
	lsr
	cmp #62
.(
	beq skip6
	adc #11
	sta pmPatternNote+1
	
	;If Note specified always default to Noise Off, Tone On
	lda ayStatus
	and pmToneMask+1
	ora pmNoiseBit+1
	sta ayStatus

	lda (pmPattern),y
	and #3
	tax
	lda pmEntriesRealVolume,x
	sta pmPatternVolume+1
	tax
	;If no effect used then transfer volume directly to AY
	iny
	lda (pmPattern),y
	and #15
	bne skip2
	stx ayVolume+1
	jmp skip2
skip6     ldx #01
	jsr DealWithRest
	jmp SkipNote

skip2	;Capture Ornament & Effect on B
	lda (pmPattern),y
	lsr
	lsr
	lsr
	lsr
	beq SkipOrnamentMod
	sec
	sbc #1
	sta pmOrnamentID+1
	lda #00
	sta pmOrnamentIndex+1
	;Turn on ornament
	lda pzMusicElementActivity
	ora #%00010000
	sta pzMusicElementActivity
	jmp skip3
SkipOrnamentMod
	lda pzMusicElementActivity
	and #%11101111
	sta pzMusicElementActivity

skip3	lda (pmPattern),y
	and #15
	beq SkipEffectMod
	sec
	sbc #1
	sta pmEffectID+1
	lda #00
	sta pmEffectIndex+1
	;Turn on effect
	lda pzMusicElementActivity
	ora #%00000010
	sta pzMusicElementActivity
	jmp skip4
SkipEffectMod
	lda pzMusicElementActivity
	and #%11111101
	sta pzMusicElementActivity

skip4	;Capture Command & Param on B
	iny
	lda (pmPattern),y
	and #7
	beq SkipCommandMod
	;Perform Command in A-1
	tax
	lda (pmPattern),y
	lsr
	lsr
	lsr
	ldy pmCommandActionVectorLo-1,x
	sty vector1+1
	ldy pmCommandActionVectorHi-1,x
	sty vector1+2
	ldx #01	;Channel
vector1	jsr $dead
SkipCommandMod
SkipNote
.)
	

	;Capture Note & Volume on C
	ldy #8
	lda (pmPattern),y
	lsr
	lsr
	cmp #62
.(
	beq skip6
	adc #11
	sta pmPatternNote+2
	
	;If Note specified always default to Noise Off, Tone On
	lda ayStatus
	and pmToneMask+2
	ora pmNoiseBit+2
	sta ayStatus

	lda (pmPattern),y
	and #3
	tax
	lda pmEntriesRealVolume,x
	sta pmPatternVolume+2
	tax
	;If no effect used then transfer volume directly to AY
	iny
	lda (pmPattern),y
	and #15
	bne skip2
	stx ayVolume+2
	jmp skip2
skip6     ldx #02
	jsr DealWithRest
	jmp SkipNote

skip2	;Capture Ornament & Effect on B
	lda (pmPattern),y
	lsr
	lsr
	lsr
	lsr
	beq SkipOrnamentMod
	sec
	sbc #1
	sta pmOrnamentID+2
	lda #00
	sta pmOrnamentIndex+2
	;Turn on ornament
	lda pzMusicElementActivity
	ora #%00100000
	sta pzMusicElementActivity
	jmp skip3
SkipOrnamentMod
	lda pzMusicElementActivity
	and #%11011111
	sta pzMusicElementActivity
	
skip3	lda (pmPattern),y
	and #15
	beq SkipEffectMod
	sec
	sbc #1
	sta pmEffectID+2
	lda #00
	sta pmEffectIndex+2
	;Turn on ornament
	lda pzMusicElementActivity
	ora #%00000100
	sta pzMusicElementActivity
	jmp skip4
SkipEffectMod
	lda pzMusicElementActivity
	and #%11111011
	sta pzMusicElementActivity

skip4	;Capture Command & Param on B
	iny
	lda (pmPattern),y
	and #7
	beq SkipCommandMod
	;Perform Command in A-1
	tax
	lda (pmPattern),y
	lsr
	lsr
	lsr
	ldy pmCommandActionVectorLo-1,x
	sty vector1+1
	ldy pmCommandActionVectorHi-1,x
	sty vector1+2
	ldx #02	;Channel
vector1	jsr $dead
SkipCommandMod
SkipNote
.)
	

	lda pzPatternRowPlayFlag
.(
	bne skip2

	;Progress Pattern
	lda pmPattern
	clc
	adc #11
	sta pmPattern
	bcc skip1
	inc pmPattern+1
skip1

	;Check for End of Pattern (Either 64th Entry or Bar in this next row)
	dec pzPatternRowCounter
	beq ProcList
	ldy #2
	lda (pmPattern),y
	cmp #%11111100
	bcs ProcList
	ldy #5
	lda (pmPattern),y
	cmp #%11111100
	bcs ProcList
	ldy #8
	lda (pmPattern),y
	cmp #%11111100
	bcs ProcList

	;Finished
	rts
skip2	lda #00
.)
	sta pzPatternRowPlayFlag
	rts

ProcList
	
	
	lda pzMusicElementActivity
.(
	bpl skip2
	
	ldx pzListIndex
	bmi EndOfList
	ldy mmListMemory,x
	bpl skip1
	ldx mmListHeader
	bmi EndOfList
	stx pzListIndex
	ldy mmListMemory,x
skip1	lda PatternAddressLo,y
	sta pmPattern
	lda PatternAddressHi,y
	sta pmPattern+1
	lda #64
	sta pzPatternRowCounter
	
	inc pzListIndex
	rts
skip2
.)
	;If the Music Play flag is not set at this point it is because
	;we intended to play just the pattern which has now finished.
	;So we should reset Music Activity but keep Effects and
	;Ornaments going.
	and #%00111111
	sta pzMusicElementActivity
	rts

EndOfList	lda #00
	sta pzMusicElementActivity
	rts

DealWithRest
	lda (pmPattern),y
	and #3
.(
	bne skip1
	;Silence any SID or Sample on Channel
	cpx SIDActivity
	bne skip4
	jsr StopSID
skip4	cpx SAMActivity
	bne skip6
	jsr StopSample
skip6	;Silence any ornament or effect on this channel
	lda pzMusicElementActivity
	and pmEffectMask,x
	and pmOrnamentMask,x
	sta pzMusicElementActivity
	;Silence Volumes
	lda #00
	sta pmPatternVolume,x
	sta ayVolume,x
	;Silence any pitchbend
	sta pbFlag,x
	rts

skip1	;1 Decrement Volume
	;2 Increment Volume
	;3 Normal Rest
	cmp #2
	bcc skip5
	bne skip2
	;3 Increment Volume
	inc ayVolume,x
	cpx SIDActivity
	beq skip3
skip2	rts

skip5	;2 Decrement Volume
	dec ayVolume,x
	dec pmPatternVolume,x
	cpx SIDActivity
	bne skip2
skip3	;Ensure we are using SID Channel rather than Status, Noise or Buzzer
	lda SIDRegister+1
	;Just an optimisation..
	; v
	;0111 7 Status or Noise
	;1000 8 Channel A
	;1001 9 Channel B
	;1010 10Channel C
	;1101 13Buzzer
	and #4
	bne skip2
	lda ayVolume,x
.)
	sta RegSIDVal+1
	rts

StopSample	;Stop Sample
	sei
	
	;Disable Sample in fast irq
	lda #<SAMNoSAM
	sta SAMVector+1
	
	;Always assign Column register to SAM channel after(To prevent disabled volume)
	lda #14
	sta SAMRegister+1
	
	cli
	
	;Disable Sample in Music
	lda #128
	sta SAMActivity
	rts

;X SampleID+1
StartSample
	sei
	
	;Redirect IRQ Branch to read first byte
	lda #<ProcSAMLo
	sta SAMVector+1
	
	;Ensure at least Channel C is selected for Sample reproduction
	lda SAMRegister+1
	cmp #14
.(
	bne skip1
	lda #10
	sta SAMRegister+1
	
skip1	;Set Sample Address
.)
	lda mmSampleAddressLo-1,x
	sta SAMMemory+1
	lda mmSampleAddressHi-1,x
	sta SAMMemory+2
	
	cli
	rts

;1 C Apply Channel or Status SID to this channel		SID EOR Value(0-F) or Status(S) or Stop(O)
;    Initial Volume - Note Volume
;A==Param
;X==Channel
;Y==Spare
pmCom_ApplyChannelOrStatusSID
;	nop
;	jmp pmCom_ApplyChannelOrStatusSID
	cmp #"S"-55
	beq ActivateStatusSID
	cmp #"N"-55
	beq ActivateNoiseSID
	cmp #"O"-55
	beq StopSID
	cmp #"G"-55
	beq ActivateEGSID
	sta RegSIDEOR+1
ApplySIDRent1
	lda pmPatternVolume,x
	sta RegSIDVal+1
	;Set SID Register to this channel
	txa
	ora #8
	sta SIDRegister+1
	;Enable SID
	stx SIDActivity
	
StartSID	;Patch restoring original code
	sei
	lda #$A9
	sta SIDPatch
	lda #00
	sta SIDPatch+1
	lda #$38
	sta SIDPatch+2
	cli
	rts

StopSID	;Patch so SID is never performed but jumped across
	sei
	lda #$4C
	sta SIDPatch
	lda #<ProcSAM
	sta SIDPatch+1
	lda #00
	sta SIDPatch+2
	cli
	lda #128
	sta SIDActivity
	;Force a rewrite of status incase status or noise sid was used
	sta ayBankReference+7
	rts


ActivateNoiseSID
	lda pmNoiseBit,x
	jmp ActivateStatusSID2
ActivateStatusSID
	lda pmToneBit,x
ActivateStatusSID2
	sta RegSIDEOR+1
	lda ayStatus
	sta RegSIDVal+1
	lda #7
	sta SIDRegister+1
	stx SIDActivity
	jmp StartSID
ActivateEGSID
	lda #16
	sta RegSIDEOR+1
	jmp ApplySIDRent1 

;2 Z Apply Buzzer SID to this channel			Cycle EOR Value(0-F)
;    Initial Cycle - EGC Cycle
;A==Param
;X==Channel
;Y==Spare
pmCom_ApplyBuzzerSID
	sta RegSIDEOR+1
	lda ayCycle
	sta RegSIDVal+1
	lda #13
	sta SIDRegister+1
	stx SIDActivity
	jmp StartSID

;3 S Sample Behaviour(and apply to this channel)		Frac(0-F) or Note Synchronised(N)
;A==Param
;X==Channel
;Y==Spare
pmCom_ApplySample
;	cmp #"N"-55
;	beq SynchroniseNote
;	asl
;	asl
;	asl
;	asl
;	sta FracSAMHR
;	lda #255
;	sta FracSAMLR
	stx SAMActivity
	;Set Sample Registers
	txa
	ora #8
	sta SAMRegister+1
	rts

pmCom_Tempo
	sta pmMusicTempo
	sta pzNoteTempoCount
	rts

pmCom_TriggerOut
	;Show Trigger change by alternating colour(Red/Blue) in play monitor
	lda $BF90
	eor #5
	sta $BF90
	rts



pmCom_Pitchbend
	;Extract Step size
	;Parameter has dual purpose
	; Counter for number of steps
	; Index for shift table
	pha
	lsr
	lsr
	sta pmStepRefer,x

	;Shift to steps of 4 (4 bytes per shift calc)
	eor #7
	asl
	asl
	sta pbBranchStep,x
	
	pla
	and #3
	sta pbDelayRefer,x
	
	;Writing 0 ensures the next pitchbend step will set up the next semitone interpolation
	lda #00
	sta pmStepCount,x
	sta pbDelayCount,x

	;At this point the new pattern note will have been set.
	;However since we are wanting to bend to this note we must set it to the previous note..
	ldy pmPatternNote,x
	lda pbOldPatternNote,x
	sta pmPatternNote,x
	;And use the current pattern note as the destination note to reach
	tya
	sta pbDestinationNote,x
	
	;Compare destination with current note
	cmp pmPatternNote,x
.(
	beq skip1
	
	;Place result into the pbFlag ensuring its value is always more than zero
	lda #2
	ror
	sta pbFlag,x
skip1	rts
.)

	
pmCom_CopyLeftChannel
;	sta pmDynamicDelay,x
;	;Work out channel left
;	txa
;	tay
;	dey
;.(
;	bpl skip1
;	ldy #2
;skip1	sty pmCopyChannel,x
;.)
;	lda #1
;	sta pmCLCFlag,x
	rts

pmCopyChannel
 .dsb 3,0
pmCLCFlag
 .dsb 3,0
pmDynamicDelay
 .dsb 3,0
 
;1 C Apply Channel or Status SID to this channel		SID EOR Value(0-F) or Status(T)
;    Initial Volume - Note Volume
;2 Z Apply Buzzer SID to this channel			Cycle EOR Value(0-F)
;    Initial Cycle - EGC Cycle
;3 S Sample Behaviour(and apply to this channel)		Frac(0-F) or Note Synchronised(N)
;4 T Music Tempo					Tempo(0-31)
;5 B Pitchbend					Step(0-7)
;6 O Trigger Out					Value(0-31)
;7 - -
pmCommandActionVectorLo
 .byt <pmCom_ApplyChannelOrStatusSID
 .byt <pmCom_ApplyBuzzerSID
 .byt <pmCom_ApplySample
 .byt <pmCom_Tempo
 .byt <pmCom_Pitchbend
 .byt <pmCom_TriggerOut
 .byt <pmCom_CopyLeftChannel
pmCommandActionVectorHi
 .byt >pmCom_ApplyChannelOrStatusSID
 .byt >pmCom_ApplyBuzzerSID
 .byt >pmCom_ApplySample
 .byt >pmCom_Tempo
 .byt >pmCom_Pitchbend
 .byt >pmCom_TriggerOut
 .byt >pmCom_CopyLeftChannel


pmPitchTableLo
 .byt <3822,<3606,<3404,<3214,<3032,<2862,<2702,<2550,<2406,<2272,<2144,<2024
 .byt <1911,<1803,<1702,<1607,<1516,<1431,<1351,<1275,<1203,<1136,<1072,<1012
 .byt <955,<901,<851,<803,<758,<715,<675,<637,<601,<568,<536,<506
 .byt <477,<450,<425,<401,<379,<357,<337,<318,<300,<284,<268,<253
 .byt <238,<225,<212,<200,<189,<178,<168,<159,<150,<142,<134,<126
 .byt <119,<112,<106,<100,<94,<89,<84,<79,<75,<71,<67,<63
 .byt <59,<56,<53,<50,<47,<44,<42,<39,<37,<35,<33,<31
 .byt <29,<28,<26,<25,<23,<22,<21,<19,<18,<17,<16,<15
 .byt <14,<14,<13,<12,<11,<11,<10,<9,<9,<8,<8,<7
 .byt 7,7,6,6,5,5,5,4,4,4,4,3
 .byt 3,3,3,3,2,2,2,2
pmPitchTableHi
 .byt >3822,>3606,>3404,>3214,>3032,>2862,>2702,>2550,>2406,>2272,>2144,>2024
 .byt >1911,>1803,>1702,>1607,>1516,>1431,>1351,>1275,>1203,>1136,>1072,>1012
 .byt >955,>901,>851,>803,>758,>715,>675,>637,>601,>568,>536,>506
 .byt >477,>450,>425,>401,>379,>357,>337,>318,>300,>284,>268,>253
 .byt >238,>225,>212,>200,>189,>178,>168,>159,>150,>142,>134,>126
 .byt >119,>112,>106,>100,>94,>89,>84,>79,>75,>71,>67,>63
 .byt >59,>56,>53,>50,>47,>44,>42,>39,>37,>35,>33,>31
 .byt >29,>28,>26,>25,>23,>22,>21,>19,>18,>17,>16,>15
 .byt >14,>14,>13,>12,>11,>11,>10,>9,>9,>8,>8,>7
 .byt 0,0,0,0,0,0,0,0,0,0,0,0
 .byt 0,0,0,0,0,0,0,0

ayBankReference
 .dsb 14,128
ayRealRegister
 .byt 0,2,4,1,3,5
 .byt 6,7,8,9,10
 .byt 11,12,13

pbFlag
 .dsb 3,0
pbDelayRefer
 .dsb 3,0
pbDelayCount
 .dsb 3,0
pbDestinationNote
 .dsb 3,0
pbChannelInterpolationStepLo
 .dsb 3,0
pbChannelInterpolationStepHi
 .dsb 3,0
pbChannelInterpolationAccumulatorLo
 .dsb 3,0
pbChannelInterpolationAccumulatorHi
 .dsb 3,0
pbRapidInterpolationStepLo
 .dsb 3,0
pbRapidInterpolationStepHi
 .dsb 3,0
pbRapidInterpolationAccumulatorLo
 .dsb 3,0
pbRapidInterpolationAccumulatorHi
 .dsb 3,0
pbBranchStep
 .dsb 3,0
pbOldPatternNote
 .dsb 3,0


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

pmPatternNote
 .dsb 3,0
pmPatternVolume
 .dsb 3,0


pmOrnamentAddressLo
 .byt <mmOrnamentMemory
 .byt <mmOrnamentMemory+32*1
 .byt <mmOrnamentMemory+32*2
 .byt <mmOrnamentMemory+32*3
 .byt <mmOrnamentMemory+32*4
 .byt <mmOrnamentMemory+32*5
 .byt <mmOrnamentMemory+32*6
 .byt <mmOrnamentMemory+32*7
 .byt <mmOrnamentMemory+32*8
 .byt <mmOrnamentMemory+32*9
 .byt <mmOrnamentMemory+32*10
 .byt <mmOrnamentMemory+32*11
 .byt <mmOrnamentMemory+32*12
 .byt <mmOrnamentMemory+32*13
 .byt <mmOrnamentMemory+32*14
pmOrnamentAddressHi
 .byt >mmOrnamentMemory
 .byt >mmOrnamentMemory+32*1
 .byt >mmOrnamentMemory+32*2
 .byt >mmOrnamentMemory+32*3
 .byt >mmOrnamentMemory+32*4
 .byt >mmOrnamentMemory+32*5
 .byt >mmOrnamentMemory+32*6
 .byt >mmOrnamentMemory+32*7
 .byt >mmOrnamentMemory+32*8
 .byt >mmOrnamentMemory+32*9
 .byt >mmOrnamentMemory+32*10
 .byt >mmOrnamentMemory+32*11
 .byt >mmOrnamentMemory+32*12
 .byt >mmOrnamentMemory+32*13
 .byt >mmOrnamentMemory+32*14


pmOrnamentID
 .dsb 3,0
pmOrnamentIndex
 .dsb 3,0

pmEffectPitchLo
 .dsb 3,0
pmEffectPitchHi
 .dsb 3,0

pmEffectAddressLo
 .byt <mmEffectMemory		;0
 .byt <mmEffectMemory+32*1              ;1
 .byt <mmEffectMemory+32*2              ;2
 .byt <mmEffectMemory+32*3              ;3
 .byt <mmEffectMemory+32*4              ;4
 .byt <mmEffectMemory+32*5              ;5
 .byt <mmEffectMemory+32*6              ;6
 .byt <mmEffectMemory+32*7              ;7
 .byt <mmEffectMemory+32*8              ;8
 .byt <mmEffectMemory+32*9              ;9
 .byt <mmEffectMemory+32*10             ;A
 .byt <mmEffectMemory+32*11             ;B
 .byt <mmEffectMemory+32*12             ;C
 .byt <mmEffectMemory+32*13             ;D
 .byt <mmEffectMemory+32*14             ;E
 .byt <EditorEffect4OrnamentPlay        ;F(15)
pmEffectAddressHi
 .byt >mmEffectMemory
 .byt >mmEffectMemory+32*1
 .byt >mmEffectMemory+32*2
 .byt >mmEffectMemory+32*3
 .byt >mmEffectMemory+32*4
 .byt >mmEffectMemory+32*5
 .byt >mmEffectMemory+32*6
 .byt >mmEffectMemory+32*7
 .byt >mmEffectMemory+32*8
 .byt >mmEffectMemory+32*9
 .byt >mmEffectMemory+32*10
 .byt >mmEffectMemory+32*11
 .byt >mmEffectMemory+32*12
 .byt >mmEffectMemory+32*13
 .byt >mmEffectMemory+32*14
 .byt >EditorEffect4OrnamentPlay

EditorEffect4OrnamentPlay
 .byt $21,$8F,$90,0,0

pmEffectID
 .dsb 3,0
pmEffectIndex
 .dsb 3,0
pmEffectVolume
 .dsb 3,0
pmEGActiveFlag
 .dsb 3,0


 
pmOrnamentBits
pmNoiseBit
 .byt %00001000
 .byt %00010000
 .byt %00100000
pmOrnamentMask
pmNoiseMask
 .byt %11110111
 .byt %11101111
 .byt %11011111
pmEffectBits
pmToneBit
 .byt %00000001
 .byt %00000010
 .byt %00000100
pmEffectMask
pmToneMask
 .byt %11111110
 .byt %11111101
 .byt %11111011

;Cycle
;1 Sawtooth \/\/\/
;2 Triangle \|\|\|
;3 Decay    \_____
pmCycleCode
 .byt 8,14,0
pmEntriesRealVolume
 .byt 0,4,8,15

;rssFracStep
; .byt 12,13,14,15,16,17,18,19,20,22,23,24
; .byt 26,27,29,31,33,35,37,39,42,44,47,50
; .byt 53,56,59,63,66,70,75,79,84,89,95,100
; .byt 106,113,119,126,134,142,151,159,169,179,190,201
; .byt 213,226,240,254
rssFracStepLo
 .byt <428
 .byt <454
 .byt <481
 .byt <509
 .byt <540
 .byt <572
 .byt <606
 .byt <642
 .byt <680
 .byt <721
 .byt <764
 .byt <809

 .byt <857
 .byt <908
 .byt <962
 .byt <1019
 .byt <1080
 .byt <1145
 .byt <1213
 .byt <1285
 .byt <1361
 .byt <1442
 .byt <1528
 .byt <1618
 
 .byt <1715
 .byt <1817
 .byt <1925
 .byt <2039
 .byt <2160
 .byt <2289
 .byt <2425
 .byt <2569
 .byt <2722
 .byt <2884
 .byt <3055
 .byt <3237
 .byt <3429
 .byt <3633
 .byt <3849
 .byt <4078
 .byt <4321
 .byt <4578
 .byt <4850
 .byt <5138
 .byt <5444
 .byt <5768
 .byt <6110
 .byt <6473
 .byt <6858
 .byt <7266
 .byt <7698
 .byt <8156
 .byt <8641
 .byt <9155
 .byt <9700
 .byt <10276
 .byt <10887
 .byt <11535
 .byt <12220
 .byt <12947
 .byt <13717
 .byt <14532
 .byt <15397
 .byt <16312
 .byt <17282
 .byt <18310
 .byt <19398
 .byt <20551
 .byt <21774
 .byt <23069
 .byt <24441
 .byt <25894
 .byt <27434
 .byt <29065
 .byt <30793
 .byt <32624
 .byt <34564
 .byt <36619
 .byt <38797
 .byt <41103
 .byt <43548
 .byt <46138
 .byt <48881
 .byt <51788
 .byt <54867
 .byt <58079
 .byt <61526
 .byt <65183
rssFracStepHi
 .byt >428
 .byt >454
 .byt >481
 .byt >509
 .byt >540
 .byt >572
 .byt >606
 .byt >642
 .byt >680
 .byt >721
 .byt >764
 .byt >809

 .byt >857
 .byt >908
 .byt >962
 .byt >1019
 .byt >1080
 .byt >1145
 .byt >1213
 .byt >1285
 .byt >1361
 .byt >1442
 .byt >1528
 .byt >1618

 .byt >1715
 .byt >1817
 .byt >1925
 .byt >2039
 .byt >2160
 .byt >2289
 .byt >2425
 .byt >2569
 .byt >2722
 .byt >2884
 .byt >3055
 .byt >3237
 .byt >3429
 .byt >3633
 .byt >3849
 .byt >4078
 .byt >4321
 .byt >4578
 .byt >4850
 .byt >5138
 .byt >5444
 .byt >5768
 .byt >6110
 .byt >6473
 .byt >6858
 .byt >7266
 .byt >7698
 .byt >8156
 .byt >8641
 .byt >9155
 .byt >9700
 .byt >10276
 .byt >10887
 .byt >11535
 .byt >12220
 .byt >12947
 .byt >13717
 .byt >14532
 .byt >15397
 .byt >16312
 .byt >17282
 .byt >18310
 .byt >19398
 .byt >20551
 .byt >21774
 .byt >23069
 .byt >24441
 .byt >25894
 .byt >27434
 .byt >29065
 .byt >30793
 .byt >32624
 .byt >34564
 .byt >36619
 .byt >38797
 .byt >41103
 .byt >43548
 .byt >46138
 .byt >48881
 .byt >51788
 .byt >54867
 .byt >58079
 .byt >61526
 .byt >65183

pmStepRefer
 .byt 0,0,0	;D4
pmStepCount
 .byt 0,0,0	;D7
;HighNibbleTable
; .dsb 16,0
; .dsb 16,1
; .dsb 16,2
; .dsb 16,3
; .dsb 16,4
; .dsb 16,5
; .dsb 16,6
; .dsb 16,7
; .dsb 16,8
; .dsb 16,9
; .dsb 16,10
; .dsb 16,11
; .dsb 16,12
; .dsb 16,13
; .dsb 16,14
; .dsb 16,15
