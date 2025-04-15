@echo off
setlocal enabledelayedexpansion

REM 设置起始编号为 1
set /a count=1

REM 遍历当前目录下的所有子文件夹
for /d %%i in (*) do (
    REM 格式化编号（前导零）
    set "num=0!count!"
    set "num=!num:~-2!"

    REM 重命名子文件夹
    ren "%%i" "!num!"
    set /a count+=1
)

echo 重命名完成！
pause
