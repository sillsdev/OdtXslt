@echo off
REM ApplyDoubleUnderline.bat - 10-May-2016 Greg Trihus
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
"%progDir%%myProg%" -v -s -t="%progDir%\SIL\OdtXslt\DoubleUnderlineGn.xsl" %1
@echo off
:done
pause