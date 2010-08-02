@echo off

set RUBYLIB=

call spec spec_all_tests.rb > testresults.txt

REM pause
