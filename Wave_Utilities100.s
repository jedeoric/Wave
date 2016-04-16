;Wave_Utilities.s

#define	VIA_PORTA			$030F
#define	VIA_PORTB			$0300
#define	VIA_IFR			$030D

#define	ROM_LPRINT_BYTE		$F5C1

#define	WVE_VERSION		$1003
#define	WVE_TEMPO			$100B
#define	WVE_LLOOP			$1010
#define	WVE_LIST			$1011
#define	WVE_SAMPLEBANK		$56AA
#define	WVE_PATTERNMEMORY		$1091
#define	WVE_EFFECTLOOPS		$5480
#define	WVE_EFFECTMEMORY		$5490
#define	WVE_ORNAMENTLOOPS		$5291
#define	WVE_ORNAMENTMEMORY		$52A0
#define	SAMPLEADDRESSTABLELO	$76AA
#define	SAMPLEADDRESSTABLEHI     	$76B1
#define	SAMPLELOOPADDRESSLO 	$76B8
#define	SAMPLELOOPADDRESSHI 	$76BF
#define	SAMPLEPROPERTY      	$76C6

#define	CM_HEADER			$7700
#define	CM_TEMPO			$7701
#define	CM_LLOOP			$770A
#define	CM_LISTSTART		$770B

;#define	BR_SAMPLE           	0
;#define	BR_EGPERIOD         	6
;#define	BR_CYCLE            	69
;#define	BR_NOISE            	72
;#define	BR_NOTE             	103
;#define	BR_BAR			164
;#define	BR_VOLUME           	165
;#define	BR_EFFECT           	171
;#define	BR_ORNAMENT         	186
;#define	BR_COMMAND          	201
;#define	BR_LONGROWREST      	208
;#define	BR_SHORTROWREST     	209

#define	BR_SAMPLE           	0
#define	BR_EGPERIOD         	6
#define	BR_CYCLE            	69
#define	BR_NOISE            	72
#define	BR_NOTE             	103
#define	BR_BAR			166
#define	BR_VOLUME           	167
#define	BR_EFFECT           	171
#define	BR_ORNAMENT         	186
#define	BR_COMMAND          	201
#define	BR_LONGROWREST      	208
#define	BR_SHORTROWREST     	209
; .byt 6   ;01 prcEGPeriod    
; .byt 69  ;02 prcCycle       
; .byt 72  ;03 prcNoise       
; .byt 103 ;04 prcNote        
; .byt 165 ;05 prcRest        
; .byt 166 ;06 prcBar         
; .byt 167 ;07 prcVolume      
; .byt 171 ;08 prcEffect      
; .byt 186 ;09 prcOrnament    
; .byt 201 ;10 prcCommand     
; .byt 208 ;11 prcLongRowRest 
; .byt 209 ;12 prcShortRowRest

;Header
;+00 Wave Version ID(00)
;+01 Music Tempo
;+02-03 Offset to Pattern Address Table
;+04-05 Offset to Effect Address Table
;+06-07 Offset to Ornament Address Table
;+08-09 Offset to Sample Address Table
;+0A List Loop Position, List
;+?? Pattern Address Table (lo,hi,lo)
;+?? Patterns
;     000-005	Sample(6)
;     006-068	EGPeriod(63)
;     069-071	Cycle(3)
;     072-102	Noise(31)
;     103-164	Note(62)
;     165-165	Rest(1)
;     166-166	Bar(1)
;     167-170	Volume(4)
;     171-185	Effect(15)
;     186-200	Ornament(15)
;     201-207	Command(7)
;     208-239	Parameter(31)
;     240-240	Long Row Rest(Second byte holds period)
;     241-255	Short Row Rest(15)
;If a row contains at least 1 change then all three channel rests are written
;+?? Effect Address Table (lo,hi,lo)
;+?? Loop Position, Effect,
;
;+?? Ornament Address Table (lo,hi,lo)
;+?? Loop Position, Ornaments,
;+?? Sample Address Table (lo,hi,llo,lhi,pro)
;+?? Samples

;The compiler is called from a central BASIC menu
;0500 BASIC File Handler
;1003 Uncompiled Flat Music File
;7700 10496 (Bytes) Compiled Music Area (Less Samples which are appended after saving)
;A000 Compiler Machine Code

 .zero
*=$00
source
destination	.dsb 2
row		.dsb 2
effect		.dsb 2
ornament		.dsb 2
sample		.dsb 2
NoteByte		.dsb 1

pataddrtable	.dsb 2
effaddrtable        .dsb 2
ornaddrtable        .dsb 2
samaddrtable        .dsb 2


 .text
*=$A000
WaveCompiler
	jmp CompileDriver
WavePrintHex
	jmp LPrint2DH
#include "Wave_Compiler100.s"
#include "Wave_PrintHex.s"

