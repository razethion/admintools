## This just displays the lockout status of an account on repeat, useful if waiting for lockout propogration across DCs
@echo off
:start
cls
net user /domain <sAMAccountName> | findstr "Account.active"
timeout 3 >nul 2>&1
goto start
exit
