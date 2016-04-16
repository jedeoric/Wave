The problem is that a tune like stormlord ingame music is too long to be composed in wave even using
all 36 patterns.

V2.00
1)Settable Pattern for each channel
2)Option of 2 channel SID
3)Effects raised to 31 with Ornaments reduced to 7
4)Enhanced Effects
5)Note Offset for Channels A-C in List Editor

NUM SP EG NP AP AO BP BO CP CO
000 00 00 00 00 +7 00 +7 00 +7



So the idea is that if patterns are organised into columns rather than a single pattern covering all
channels that this would both make the compiled music smaller whilst also making code simpler and permit
longer, more repetitive music such as Stormlord theme tunes.

However the most important advancement in this editor should be that it should allow the music list
to be edited in two modes..

1) Wave style - displaying just a single PatternID even though in the background 5 patterns are assigned
2) Combi style - Allowing full Pattern control

The same size of 11x64 per pattern is quite feasable however some elements of a row would have to be
grouped together..

Column A - 1 - Sample/Noise
  B0-2 - Sample 1-7
  B3-7 - Noise 1-31
Column B - 1 - EG/Cycle
  B0-1 - Cycle 1-3
  B2-7 - Period 1-61
Column C - 3 - Note/Volume/Effect/Ornament/Command/Parameter
  B0-1 - Volume 1-3
  B2-7 - Note 0-62
  
  B0-2 - Ornament 1-7 (More emphasis on Effects)
  B3-7 - Effect 1-31
  
  B0-2 - Command 1-7
  B3-7 - Parameter 0-31
Column D - 3 - Note/Volume/Effect/Ornament/Command/Parameter
  B0-1 - Volume 1-3
  B2-7 - Note 0-62
  
  B0-2 - Ornament 1-7 (More emphasis on Effects)
  B3-7 - Effect 1-31
  
  B0-2 - Command 1-7
  B3-7 - Parameter 0-31
Column E - 3 - Note/Volume/Effect/Ornament/Command/Parameter
  B0-1 - Volume 1-3
  B2-7 - Note 0-62
  
  B0-2 - Ornament 1-7 (More emphasis on Effects)
  B3-7 - Effect 1-31
  
  B0-2 - Command 1-7
  B3-7 - Parameter 0-31


The list memory would be bigger, containing 5 fields instead of 1.
if grouped in series then 51 entries for 256 bytes.

Problem?
The List Editor is currently on one or two rows. Such an emended scheme would require more rows.

S  EG N  A  B  C
00 00 00 00 00 00

Also it is not expected to share patterns between S, EG and N but sharing patterns for A,B and C
would be beneficial (but not vital).

So each channel could show only Patterns for it in range 0-31 but internally they are held
as a single list of patterns?

20000 cycles available
6 cycles per byte shifted
3333 bytes
38 columns == 87 rows
36 == 92

16384(overlay) - 512(disk) == (15872 / 6)-3(JMP) == 2642 bytes / 36 columns == 73 rows
/ 32 == 82 rows /12(block height) == 6


2 Channel SID

	lda #frac1
	adc #
	sta
	lda #frac1
	adc #
	sta
	bcc
	
Wave would display Pattern sets instead of patterns directly.
Pattern sets would be between 00 and ZZ? and each set consists of 8 bytes.

-FILE LIST PATT EFFE ORNA SAMP TM10 >O--
 000 001 002 003 ...
 P00 P00 P00 P00 P00 P00 P00 P00 P00 P00
--PATTERN 00----------------------------
NM S EGC N N#O VEOCP N#O VEOCP N#O VEOCP
01
02
03
04
05
06
07
08
09
10
11
12
13
-SAMPLES----EFFECT 0--------ORNAMENT 0--
00          00              00
01          01              01
02          02              02
03          03              03
04          04              04
05          05              05
06          06              06
-----00/000-07              07
-PATTERN EDIT--------------------------

Would be amended to be...

-FILE LIST PATT EFFE ORNA SAMP TM10 >O--
NUM L SP EG NP  AP OFS BP OFS CP OFS RPT
000 > 00 00 00  00 +00 00 +00 00 +00 001
001   00 00 00  00 +00 00 +00 00 +00 001
002   00 00 00  00 +00 00 +00 00 +00 001
003   00 00 00  00 +00 00 +00 00 +00 001
004   00 00 00  00 +00 00 +00 00 +00 001
--PATTERN 00----------------------------
NM S EGC N N#O VEOCP N#O VEOCP N#O VEOCP
01
02
03
04
05
06
07
08
09
-SAMPLES----EFFECT 0--------ORNAMENT 0--
00          00              00
01          01              01
02          02              02
03          03              03
04          04              04
05          05              05
06          06              06
-----00/000-07              07
-PATTERN EDIT--------------------------

Byte 0
 B0-4 Pattern S (0-31)
 B5-6
 B7   0 Pattern Rest
      1 Pattern Flag 
Byte 1
 B0-4 Pattern EGC (1-31)
 B5-6
 B7   0 Pattern Rest
      1 Pattern Flag 
Byte 2
 B0-4 Pattern N (1-31)
 B5-6
 B7   0 Pattern Rest
      1 Pattern Flag 
Byte 3
 B0-4 Pattern A (1-31)
 B5-7 
Byte 4
 B0-4 Pattern B (1-31)
 B5-7 
Byte 5
 B0-4 Pattern C (1-31)
 B5-7 
Byte 6
 B0-3 Pattern A Offset
 B4-7 Pattern B Offset
Byte 7
 B0-3 Pattern C Offset
 B4-7 Repeats

128 List x 8 bytes == 1024 Bytes
