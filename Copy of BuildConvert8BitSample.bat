@ECHO OFF
SET STARTADDR=$A000
SET INPUTFN=Wave_PlayLHL
SET OUTTAP=plhl.tap
SET AUTOFLAG=0
c:\osdk\bin\xa.exe %INPUTFN%.s -o final.out -e xaerr.txt -l %INPUTFN%.txt
c:\osdk\bin\header.exe -a%AUTOFLAG% final.out %OUTTAP% %STARTADDR%
copy %OUTTAP% c:\emulate\oric\shared /Y
pause
