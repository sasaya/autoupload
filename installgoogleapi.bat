@echo off

REM HINT=http://qiita.com/usagi/items/2623145f22faf54b99e0

cd %~dp0

:checkMandatoryLevel
REM ▼管理者として実行されているか確認 START
for /f "tokens=1 delims=," %%i in ('whoami /groups /FO CSV /NH') do (
    if "%%~i"=="BUILTIN\Administrators" set ADMIN=yes
    if "%%~i"=="Mandatory Label\High Mandatory Level" set ELEVATED=yes
)

if "%ADMIN%" neq "yes" (
    echo このファイルは管理者権限での実行が必要です{Administratorsグループでない}
    goto runas
)
if "%ELEVATED%" neq "yes" (
    echo このファイルは管理者権限での実行が必要です{プロセスが昇格されていない}
    goto runas
)
REM ▲管理者として実行されているか確認 END

:admins
    REM ▼管理者として実行したいコマンド START
    @echo on
    conda install -c conda-forge google-api-python-client

    if not %errorlevel% equ 0 (
    echo Minicondaがインストールされていません　http://conda.pydata.org/miniconda.html　より Python3.xを入手してください
    pause
    )
    @echo off
    REM ▲管理者として実行したいコマンド END
    goto exit1

:runas
    REM ★管理者として再実行
    powershell -Command Start-Process -Verb runas "%0" 

:exit1