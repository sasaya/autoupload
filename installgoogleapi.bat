@echo off

REM HINT=http://qiita.com/usagi/items/2623145f22faf54b99e0

cd %~dp0

:checkMandatoryLevel
REM ���Ǘ��҂Ƃ��Ď��s����Ă��邩�m�F START
for /f "tokens=1 delims=," %%i in ('whoami /groups /FO CSV /NH') do (
    if "%%~i"=="BUILTIN\Administrators" set ADMIN=yes
    if "%%~i"=="Mandatory Label\High Mandatory Level" set ELEVATED=yes
)

if "%ADMIN%" neq "yes" (
    echo ���̃t�@�C���͊Ǘ��Ҍ����ł̎��s���K�v�ł�{Administrators�O���[�v�łȂ�}
    goto runas
)
if "%ELEVATED%" neq "yes" (
    echo ���̃t�@�C���͊Ǘ��Ҍ����ł̎��s���K�v�ł�{�v���Z�X�����i����Ă��Ȃ�}
    goto runas
)
REM ���Ǘ��҂Ƃ��Ď��s����Ă��邩�m�F END

:admins
    REM ���Ǘ��҂Ƃ��Ď��s�������R�}���h START
    @echo on
    conda install -c conda-forge google-api-python-client

    if not %errorlevel% equ 0 (
    echo Miniconda���C���X�g�[������Ă��܂���@http://conda.pydata.org/miniconda.html�@��� Python3.x����肵�Ă�������
    pause
    )
    @echo off
    REM ���Ǘ��҂Ƃ��Ď��s�������R�}���h END
    goto exit1

:runas
    REM ���Ǘ��҂Ƃ��čĎ��s
    powershell -Command Start-Process -Verb runas "%0" 

:exit1