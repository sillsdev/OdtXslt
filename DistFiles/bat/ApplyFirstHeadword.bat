@echo off
REM ApplyFootnoteCaller.bat - 21-Feb-2013 Greg Trihus
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
"%progDir%%myProg%" -v -c -t="%progDir%\SIL\OdtXslt\MinorHeadword.xsl" %1
"%progDir%%myProg%" -v -c -t="%progDir%\SIL\OdtXslt\FirstHeadword.xsl" %1
@echo off
:done
pause