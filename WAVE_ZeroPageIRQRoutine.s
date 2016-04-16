;WAVE_ZeroPageIRQRoutine.s

;1x 16 Bit Fractional Stepping Sample Channel
;1x 16 Bit Fractional Stepping SID Channel

;Total Bytes   :179 ($B3)Bytes
;CPU Demand    : 33-79%

;Average SID+SAM: 75%
;Average SAM    : 67%
;Average SID    : 41%

;No Sample or SID   :66 Cycles	- 33%
;SampleLo+SID Cycles:141 Cycles	- 71%
;SampleHi+SID Cycles:157 Cycles	- 79% <<
;SampleLo	Cycles    :126 Cycles	- 63%
;SampleHi Cycles	:142 Cycles	- 71%
;SID Cycles         :82 Cycles	- 41%
;Sample End+SID	:134 Cycles	- 67%
;Sample Loop+SID	:137 Cycles	- 69%
;Sample End	:118 Cycles	- 59%
;Sample Loop	:121 Cycles	- 61%


IRQDriver	;Reset IRQ
	bit VIA_T1CL		;4

	;Countdown Music Process
	dec MusicIRQCountdown         ;5
	beq ProcessMusic              ;2

	;Preserve Registers
	sta RegisterA+1		;3

	;Fractional step Sample
FracSAMLC	lda #00                       ;2
	sec                           ;2
FracSAMLR	adc #00                       ;2
	sta FracSAMLC+1		;3
FracSAMHC	lda #00                       ;2
FracSAMHR	adc #00                       ;2
	sta FracSAMHC+1		;3 == 30
SampleBranch
	bcs ProcessSampleLoNibble     ;2/3

	jmp SIDRent2		;3

ProcessSampleLoNibble	;1 of 2
	;Setup Sample Register
	lda #$FF                      ;2
	sta VIA_PCR                   ;4
SampleRegister1
	lda #8                        ;2
	sta VIA_PORTA                 ;4
	lda #$DD                      ;2
	sta VIA_PCR                   ;4
	
	;Process Sample
SampleMem	lda $DEAD                     ;4
	sta SampleLowIndex+1	;3
SampleLowIndex
	lda HighNibbleTable		;4
	sta VIA_PORTA                 ;4
	lda #$FD                      ;2
	sta VIA_PCR                   ;4
	
	;Redirect Sample Branch
	lda #ProcessSampleHiNibble-IRQDriver-2	;2
	sta SampleBranch+1			;3 == 44+33
	
SIDRent1	;Restore SID Register again
	lda #$FF			;2
	sta VIA_PCR                   ;4
SIDReg	lda #9                        ;2
	sta VIA_PORTA                 ;4
	lda #$DD                      ;2
	sta VIA_PCR                   ;4
	
SIDRent2	;Fractional step SID
FracSIDLC	lda #00                       ;2
FracSIDLR	adc #00                       ;2
	sta FracSIDLC+1               ;3
FracSIDHC	lda #00                       ;2
FracSIDHR	adc #00                       ;2
	sta FracSIDHC+1		;3
	bcc RegisterA		;2/3
	
	;Process SID
RegSIDVal	lda #00                       ;2
RegSIDEOR	eor #00			;2
	sta RegSIDVal+1		;3
	sta VIA_PORTA                 ;4
	lda #$FD                      ;2
	sta VIA_PCR                   ;4
	
RegisterA	lda #00                       ;2
	rti                           ;12

ProcessSampleHiNibble	;2 of 2
	;Setup Sample Register
	lda #$FF                      ;2
	sta VIA_PCR                   ;4
SampleRegister2
	lda #8                        ;2
	sta VIA_PORTA                 ;4
	lda #$DD                      ;2
	sta VIA_PCR                   ;4
	
	;Process Sample
	lda SampleLowIndex+1	;3
	beq ProcessSampleEnd	;2/3
	and #15			;2
	sta VIA_PORTA                 ;4
	lda #$FD                      ;2
	sta VIA_PCR                   ;4
	
	lda SampleMem+1		;3
	adc #00			;2
	sta SampleMem+1		;3
	lda SampleMem+2		;3
	adc #00			;2
	sta SampleMem+2		;3
	
	;Redirect Sample Branch
	lda #ProcessSampleLoNibble-IRQDriver-2	;2
	sta SampleBranch+1			;3
	
	jmp SIDRent1		;3

ProcessMusic
	jmp ProcMusic
ProcessSampleEnd
SampleLoopHi	;57
	lda #00			;2
	bne skip1			;2/3
	;End Sample
	;Redirect branch to not process Sample anymore
	lda #SIDRent2-IRQDriver-2	;2
	sta SampleBranch+1		;3
	;but also restore SID Register
	jmp SIDRent1		;3

skip1	sta SampleMem+2		;3
SampleLoopLo
	lda #00			;2
	sta SampleMem+1		;3
	jmp SIDRent1		;3
	
