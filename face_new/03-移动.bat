@echo off
setlocal enabledelayedexpansion

REM 创建 all 文件夹（如果不存在）
if not exist "all" (
    mkdir all
)

REM 遍历所有子文件夹（排除 all 文件夹本身）
for /d %%F in (*) do (
    if /I not "%%F"=="all" (
        REM 遍历子文件夹中的所有文件（支持图片格式）
        for %%I in ("%%F\*.*") do (
            copy "%%I" "all\"
        )
    )
)

echo 所有图片已复制到 all 文件夹中！
pause
