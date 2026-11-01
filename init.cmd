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

:: 4. Check if profile.json exists
if not exist "job-skill\profile.json" (
    echo.
    echo [NOTICE] No candidate profile detected. Copying profile.template.json...
    copy "job-skill\profile.template.json" "job-skill\profile.json" >nul
    echo [INFO] Created job-skill\profile.json. Please edit with candidate truth details.
)

:: Display active candidate
for /f "tokens=*" %%a in ('node -e "try { const p = require('./job-skill/profile.json'); console.log(p.identity.full_name + ' (' + p.identity.email + ')'); } catch(e) { console.log('Unknown'); }"') do set ACTIVE_CANDIDATE=%%a

echo [OK] Active Candidate Profile: !ACTIVE_CANDIDATE!

:: 5. Verify master CV exists
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

echo.
echo ===================================================
echo   Initialization Complete! Project is ready.
echo ===================================================
echo.
echo Useful commands:
echo   Database inspection:             sqlite3.exe "job-skill\data\career.sqlite" ".tables"
echo   Review operational protocols:    AGENTS.md
echo.
