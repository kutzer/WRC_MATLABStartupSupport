@echo off
cd "C:\Program Files\MATLAB\<Your MATLAB Version>\bin"
start matlab.exe -nosplash -nodesktop -minimize -r "run('C:\path\to\your\script.m');exit;"