@echo off
setlocal enabledelayedexpansion

REM 遍历所有子文件夹（如 01, 02, 03）
for /d %%F in (*) do (
    set "folder=%%F"
    set /a count=1

    REM 遍历该文件夹下的所有文件（可以自行扩展文件类型）
    for %%I in ("%%F\*.*") do (
        REM 格式化编号，如 01, 02
        set "num=0!count!"
        set "num=!num:~-2!"

        REM 新文件名（文件夹名_编号.jpg）
        set "newname=%%F_!num!.jpg"

        REM 重命名文件
        ren "%%I" "!newname!"

        set /a count+=1
    )
)

echo 图片重命名完成！
pause
