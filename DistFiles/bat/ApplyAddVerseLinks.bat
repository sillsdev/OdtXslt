@echo off
REM ApplyAddVerseLinks.bat - 20-Apr-2013 Greg Trihus
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
"%progDir%%myProg%" -v -i=OEBPS\PartFile*.xhtml -t="%progDir%\SIL\OdtXslt\AddVerseLinks.xsl" %1
@echo off
:done
pause