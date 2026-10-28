@echo off
setlocal enabledelayedexpansion

echo ===================================================
echo   Job Search and Application Automation Engine
echo ===================================================
echo.

:: 1. Check Node.js
where node >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Node.js is not found in PATH. Please install Node.js v22 or higher.
    exit /b 1
)

for /f "tokens=*" %%v in ('node -v') do set NODE_VERSION=%%v
echo [OK] Node.js detected: !NODE_VERSION!

:: 2. Ensure data directory exists
if not exist "job-skill\data" (
    echo [INFO] Creating job-skill\data directory...
    mkdir "job-skill\data"
)

:: 3. Check / Initialize SQLite Database
if not exist "job-skill\data\career.sqlite" (
    echo [INFO] Initializing new SQLite database from job-skill\schema.sql...
    node -e "const { DatabaseSync } = require('node:sqlite'); const fs = require('node:fs'); const db = new DatabaseSync('job-skill/data/career.sqlite'); db.exec(fs.readFileSync('job-skill/schema.sql', 'utf8')); console.log('[OK] career.sqlite created and schema applied.');"
) else (
    echo [OK] SQLite database exists: job-skill\data\career.sqlite
)

:: 4. Check for --new or --onboard flag
if "%1"=="--new" goto DO_ONBOARD
if "%1"=="--onboard" goto DO_ONBOARD
if "%1"=="-n" goto DO_ONBOARD

:: 5. Check if profile.json exists
if not exist "job-skill\profile.json" (
    echo.
    echo [NOTICE] No candidate profile detected. Starting interactive onboarding...
    goto DO_ONBOARD
)

:: If profile exists, display active candidate and ask
for /f "tokens=*" %%a in ('node -e "try { const p = require('./job-skill/profile.json'); console.log(p.identity.full_name + ' (' + p.identity.email + ')'); } catch(e) { console.log('Unknown'); }"') do set ACTIVE_CANDIDATE=%%a

echo [OK] Active Candidate Profile: !ACTIVE_CANDIDATE!
echo.
set /p USER_CHOICE="Keep current candidate profile? [Y to proceed, or 'new' to onboard someone else]: "
if /i "!USER_CHOICE!"=="new" goto DO_ONBOARD
if /i "!USER_CHOICE!"=="n" goto DO_ONBOARD

goto POST_CHECK

:DO_ONBOARD
echo.
node job-skill\onboard.js
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Candidate onboarding failed.
    exit /b %ERRORLEVEL%
)

:POST_CHECK
:: 6. Verify master CV exists
for /f "tokens=*" %%c in ('node -e "try { const p = require('./job-skill/profile.json'); console.log(p.cv.existing_pdf || ''); } catch(e) { console.log(''); }"') do set CV_PATH=%%c

if exist "!CV_PATH!" (
    echo [OK] Master CV verified: !CV_PATH!
) else if exist "job-skill\!CV_PATH!" (
    echo [OK] Master CV verified: job-skill\!CV_PATH!
) else if exist "career-ops\!CV_PATH!" (
    echo [OK] Master CV verified: career-ops\!CV_PATH!
) else (
    echo [WARNING] Configured Master CV was not found at !CV_PATH!. Please place your PDF in career-ops/
)

:: 7. Initialize/Check guardian session
echo.
echo [INFO] Current Guardian Session:
node job-skill\guardian.js session
echo.

echo ===================================================
echo   Initialization Complete! Project is ready.
echo ===================================================
echo.
echo Useful commands:
echo   Launch debugging browser:        job-skill\run-brave.bat
echo   Re-run onboarding for someone:   init.cmd --new
echo   Guardian CLI ledger:             node job-skill\guardian.js [session/reserve/record/applied]
echo   Review operational protocols:    AGENTS.md
echo.
