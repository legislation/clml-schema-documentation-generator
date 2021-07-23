echo Generating doc for %1 with settings %2 using oXygen at %3 > trace1.txt

REM "C:\Program Files\Oxygen XML Editor 21\schemaDocumentation.bat" %1 %2 > trace.txt
%3\schemaDocumentation.bat %1 %2 
