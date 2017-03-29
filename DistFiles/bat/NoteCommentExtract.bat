@echo off
REM NoteCommentExtract.bat - 29-Mar-2017 Greg Trihus
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
set inp=%1
@echo on
"%progDir%%myProg%" -v -c -t="%progDir%\SIL\OdtXslt\NoteComments.xsl" -o=%inp:.odt=Notes.txt% %1
@echo off
:done
pause