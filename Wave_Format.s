;Notes for Wave


Patterns..
			Default	Range	Bits
EGPeriod	6		0	0-62      2-7
Cycle	2		0	0-3       0-1

Noise	5		0	0-30      3-7
Sample	3		0	0-6       0-2


Note	6		61	0-60      2-7
Volume	2 (4/8/12/15)	3         0-3       0-1

Ornament	4                   0         0-14      4-7
Volseq	4                   0         0-14      0-3

Command	3                   0	0-6       0-2
Param	5                   0         0-31      3-7


Note	6                   61	0-60      2-7 
Volume	2                   3         0-3       0-1
                                                     
Ornament	4                   0         0-14      4-7
Volseq	4                   0         0-14      0-3

Command	3                   0	0-6       0-2
Param	5                   0         0-31      3-7


Note	6		61	0-60      2-7 
Volume	2                   3         0-3       0-1
                                                     
Ornament	4                   0         0-14      4-7
Volseq	4                   0         0-14      0-3

Command	3                   0	0-6       0-2
Param	5                   0         0-31      3-7





11 Bytes per row
64 Rows
24 Patterns
==
16896 For Patterns

Ornaments..
1 Byte per row
32 Rows
15 Ornaments
==
480 for Ornaments

Volseqs..
1 Byte per row
32 Rows
15 Volseqs
==
480 for Volseqs

Samples
8192 for Samples

List
128 for List

Totals..
16896 For Patterns
480 for Ornaments
480 for Effects
8192 for Samples
64 for names(8x8)
128 for List
====
26240 - 6680

Memory Map..
$0500	BASIC (Files)
$1000	Music Memory(26240)
$78C0	Editor(15424)
$B500	!

Areas in detail
Ornaments
Split into header and data areas
Header..
 LoopIndex (0-31) or End(128)
Data
 2's compliment entries for signed offset of note
 However if Zero then loop or end depending on Header

Effects
 B0-4
  Offset -16 to +15
 B5-7
  0 Loop(Offset) or 0 to End
  1 Noise Off (Offset not used)
  2 EG Off (Offset not used)
  3 Tone Off (Offset not used)
  4 Tone On and Pitch Offset
  5 Noise On and Noise Offset
  6 EG On and EGPeriod Offset
  7 Tone On and Volume Offset
    If volume overlaps then ends Effect

List
Split into header and data areas
Data(Up to 127)
 B0-6
  0-127 Data
 B7
  0 Pattern in Data(0-23)
  1 End(End(0) or Loop back offset(1-127))
  



Pattern
Note (0-61) Oric C-1 to C-6
 0   B-0
 1   C-1
 2   C#1
 3   D-1
 4   D#1
 5   E-1
 6   F-1
 7   F#1
 8   G-1
 9   G#1
 10  A-1
 11  A#1
 12  B-1
 13  C-2
 14  C#2
 15  D-2
 16  D#2
 17  E-2
 18  F-2
 19  F#2
 20  G-2
 21  G#2
 22  A-2
 23  A#2
 24  B-2
 25  C-3
 26  C#3
 27  D-3
 28  D#3
 29  E-3
 30  F-3
 31  F#3
 32  G-3
 33  G#3
 34  A-3
 35  A#3
 36  B-3
 37  C-4
 38  C#4
 39  D-4
 40  D#4
 41  E-4
 42  F-4
 43  F#4
 44  G-4
 45  G#4
 46  A-4
 47  A#4
 48  B-4
 49  C-5
 50  C#5
 51  D-5
 52  D#5
 53  E-5
 54  F-5
 55  F#5
 56  G-5
 57  G#5
 58  A-5
 59  A#5
 60  B-5
 61  C-6
Rest (62) or VRest (62+Volume)
 62 0 : RST 0 Silence all on channel
 62 1 : RST ^ Raise volume
 62 2 : RST v Decay volume
 62 3 : RST - Normal Rest
Bar  (63)
 63 0 : === =

