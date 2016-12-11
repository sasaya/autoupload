cd %~dp0
python main.py
for /f "usebackq delims=," %%i in (`dir /B /S *.mp4`) do (
python uploadvideo.py --file "%%i" --title "%%i"
) 