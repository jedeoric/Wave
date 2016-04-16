;Wave_Driver.s
;0500 BASIC Disk Code
;1000 Editor Code
;???? Music Memory
;B500 Std Charset
;B800 Zero Page Backup for BASIC restoration
;B900 Backup of Screen BB80-BC1F
;BA00 Backup of Screen BE50-BF4F
;BB00 
;BB80 Text Screen

#define	SYS_IRQVECTOR	$0245
#define	GTORKB		$EB78
#define	KBSTAT		$0209
#define	SCREENBACKUPPAGE1	$B900
#define	SCREENBACKUPPAGE2   $BA00
#define	SCREENBACKUPPAGE3	$0F00

#define	BARFLAG		128

#define	SAM_SETFREQUENCY    01
#define	SAM_SYNC2NOTE	02
#define	SID_CHANNEL     	04
#define	SID_STATUS      	05
#define	SID_BUZZER	06

#define	LISTEDITOR	0
#define	PATTERNEDITOR	1
#define	ORNAMENTEDITOR	2
#define	EFFECTEDITOR	3
#define	SAMPLEVIEWER	4
#define	TOPMENU		5
#define	HELPEDITOR	6

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

#define	BASICMESSAGE	6
 .zero
*=$00
hkey                          .dsb 2	;00
ornament                      .dsb 2    ;02
effect                        .dsb 2    ;04
source			.dsb 2    ;06
destination                   .dsb 2    ;08
screen			.dsb 2    ;0a
vectorlo                      .dsb 2    ;0c
text                          .dsb 2    ;0e
pattern			.dsb 2    ;10
hardkey                       .dsb 2    ;12
vectorhi			.dsb 2    ;14
areaid			.dsb 2    ;16
InverseDisplayFlag		.dsb 1    ;18
;Display Message
MessageID			.dsb 1	;19
CurrentCharacter		.dsb 1	;1A
;Help List
ListIndex			.dsb 1	;1B
RowIndex                      .dsb 1	;1C
OffsetToKeyText		.dsb 1	;1D
eeInverseFlag
leInverseFlag		.dsb 1	;1E
LastVolumeIndex		.dsb 1	;1F
 .text
*=$1000

Driver1	jmp Driver2
;Music memory resides here because its then fixed at $1003
#include "Wave_MusicMemory.s"

Driver2	tsx
	stx OriginalStackPointer
	lda BASICMESSAGE
	pha
	jsr SwapZeroPage
	jsr SetupIRQ
	pla
.(
	beq skip1
	;Check top left of screen for filename
	jsr Check4Filename
	;Default 
	lda mmUltimatePattern
	bne skip3
	lda #23
	sta mmUltimatePattern
skip3	jsr RestoreScreen
	jmp skip2	
skip1	lda #5
	sta EditorID
skip2	jsr ListPlot

.)
	jsr RestorePatternArea
	jsr RestorePatternLegend
	jsr PatternPlot
	jsr SamplePlot
	jsr EffectPlot
	jsr OrnamentPlot
	lda mmMusicTempo
	sta pzNoteTempoCount
	jsr EmbedTempoInMenuScreen
	
	jmp CommonControl

Check4Filename
	lda $BBA8
	cmp #16
.(
	beq skip1	;No Filename
	;transfer 9 characters of filename
	ldx #08
loop1	lda $BBA8,x
	ora #128
	sta FilenameText,x
	dex
	bpl loop1
skip1	rts
.)
	
#include "Wave_Variables.s"
#include "Wave_IRQDriver.s"

#include "Wave_CommonCode.s"
#include "Wave_KeyRoutines.s"

#include "Wave_ListPlot.s"
#include "Wave_ListEditor.s"

#include "Wave_PatternPlot.s"
#include "Wave_PatternEditor.s"

#include "Wave_OrnamentPlot.s"
#include "Wave_OrnamentEditor.s"

#include "Wave_EffectPlot.s"
#include "Wave_EffectEditor.s"

#include "Wave_SamplePlot.s"
#include "Wave_SampleEditor.s"

#include "Wave_MenuPlot.s"
#include "Wave_Menu.s"

#include "Wave_HelpList.s"
#include "Wave_HelpEditor.s"



Himem
 .dsb $B500-*
CharsetAndScreen
#include "Wave_CharsetAndScreen.s"
EndOfMemory
 .byt 0