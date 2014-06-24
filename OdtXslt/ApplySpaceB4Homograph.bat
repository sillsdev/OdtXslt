@echo off
REM ApplySpaceB4Homograph.bat - 24-Jun-2014 Greg Trihus
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
"%progDir%%myProg%" -v -c -t="%progDir%\SIL\OdtXslt\SpaceB4Homograph.xsl" %1
@echo off
:done
pause