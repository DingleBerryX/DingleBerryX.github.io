@echo off
git rev-parse --is-inside-work-tree >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: This is not a Git repository!
    pause
    exit /b 1
)
for /f "tokens=*" %%i in ('git rev-parse --abbrev-ref HEAD') do set branch=%%i
echo staging changes...
git add .
git diff-index --quiet HEAD --
if %errorlevel% equ 0 (
    echo no changes
) else (
    echo Committing changes...
    git commit -m "lazy commit: %date% %time%"
)
echo pushing to %branch%...
git push origin %branch%

if %errorlevel% equ 0 (
    echo Changes successfully pushed to origin/%branch%!
) else (
    echo failed: try again
    pause
    exit /b 1
)
pause