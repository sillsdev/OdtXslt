@echo off
REM UpdateHeadword-83.bat - 4-Oct-2016 Greg Trihus
set myProg=\SIL\OdtXslt\OdtXslt.exe
set progDir=C:\Program Files
if exist "%progDir%%myProg%" goto foundIt
set progDir=%ProgramFiles(x86)%
if exist "%progDir%%myProg%" goto foundIt
set progDir=%ProgramFiles%
if exist "%progDir%%myProg%" goto fountIt
echo OdtXslt.exe not found
goto done

:foundIt
@echo on
"%progDir%%myProg%" -v -c -t="%progDir%\SIL\OdtXslt\UpdateHeadword.xsl" %1
@echo off
:done
pause