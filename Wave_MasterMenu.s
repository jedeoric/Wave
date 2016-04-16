;Wave_MasterMenu.s


*=$A000



;0500-0FFF Disc Ops
;1000-76FF WAVE Flatfile
;7700-9FFF Compiled Music (less Samples)
;A000-B4FF Utility Code

;X - MenuID
DisplayMenu
	lda TextMenuAddressLo,x
	sta source
	lda TextMenuAddressHi,x
	sta source+1
	

;      0123456789012345678901234567890123456789
Text_WaveMasterMenu
 .byt "               Wave Menu                "
 .byt "      1   Music Editor                  "
 .byt "      2   Compiler                      "
 .byt "      3   Get Music Stats               "
 .byt 128
Text_KeyGuideInsert
 .byt "SPACEBAR       - Refresh Printer State  "
 .byt "Cursor Keys    - Navigate               "
 .byt "RETURN	  - Select Option          "
 .byt "ESC            - Quit to BASIC          "
 .byt 128
Text_WaveCompilerMenu
 .byt "Prt:Offline  Compiler Menu    FN:DEFAULT"
 .byt "      1   Load WAVE Music               "
 .byt "      2   Compile Music                 "
 .byt "      3   Load Compiled Music           "
 .byt 128
Text_WaveCompiledMenu
 .byt "Prt:Offline  Compiled Menu    FN:DEFAULT"
 .byt "      1   Save Compiled Music           "
 .byt "      2   Save BASIC HIRES Player(Dyna) "
 .byt "      3   Save BASIC HIRES Player(Perm) "
 .byt "      4   Save BASIC Player for TEXT    "
 .byt "      4   Dump(XA) Compiled to Printer  "

 .byt "                                        "
 .byt "
 .byt 128


