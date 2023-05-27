setlocal DisableDelayedExpansion

set I=0
echo.>map_list.txt
@for /f "eol=; tokens=* delims=;" %%f in ('dir *.unr /A-D /B /OD') do @(
	set "name=%%f"
	setlocal EnableDelayedExpansion
	echo M[!I!]=!name:~0,-4!>>map_list.txt
	endlocal
	set /A I=I+1
)
echo iM=%I%>>map_list.txt