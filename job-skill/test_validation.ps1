<#
.SYNOPSIS
  Validation Test Suite for Autonomous Job Search Engine
.DESCRIPTION
  Tests deduplication, qualification gate, granular lifecycle states, 
  database integrity triggers, dynamic source scoring, and execution concurrency.
#>

$SqlitePath = "C:\Users\Ajay_lap\AppData\Local\Programs\SQLite\sqlite3.exe"
$DbPath = "C:\job-search\job-skill\data\career.sqlite"

function Run-Sql([string]$sql) {
    & $SqlitePath $DbPath $sql
}

function Run-SqlScalar([string]$sql) {
    return (& $SqlitePath $DbPath $sql)
}

$PassCount = 0
$FailCount = 0

function Assert-Test([string]$TestName, [bool]$Condition, [string]$Details = "") {
    if ($Condition) {
        Write-Host "PASS: $TestName" -ForegroundColor Green
        $script:PassCount++
    } else {
        Write-Host "FAIL: $TestName ($Details)" -ForegroundColor Red
        $script:FailCount++
    }
}

Write-Host "=== STARTING AUTONOMOUS JOB SEARCH ENGINE VALIDATION SUITE ===" -ForegroundColor Cyan

# ---------------------------------------------------------------------------
# Test 1: SQLite CLI and Database Availability
# ---------------------------------------------------------------------------
$sqliteVer = (& $SqlitePath --version)
Assert-Test "SQLite CLI Executable Available" ($sqliteVer -like "3.*") $sqliteVer

$jobCount = Run-SqlScalar "SELECT COUNT(*) FROM jobs;"
Assert-Test "Production Database Accessible & Populated" ([int]$jobCount -ge 300) "Job count: $jobCount"

# ---------------------------------------------------------------------------
# Test 2: Job ID 310 Audit Verification (Tekion Corp)
# ---------------------------------------------------------------------------
$job310Status = Run-SqlScalar "SELECT status FROM jobs WHERE id = 310;"
$job310Score = Run-SqlScalar "SELECT fit_score FROM jobs WHERE id = 310;"
$job310SkipReason = Run-SqlScalar "SELECT skip_reason FROM jobs WHERE id = 310;"

Assert-Test "Job 310 Re-Scored Below Threshold" ([int]$job310Score -le 30) "Score: $job310Score"
Assert-Test "Job 310 Status Skipped" ($job310Status -eq "skipped") "Status: $job310Status"
Assert-Test "Job 310 Skip Reason Documents Experience Mismatch" ($job310SkipReason -like "*experience_mismatch*") "Reason: $job310SkipReason"

# ---------------------------------------------------------------------------
# Test 3: Deduplication Constraint Verification
# ---------------------------------------------------------------------------
$testDedupeKey = "test_comp|test_engineer|remote"
# Clean up any leftover test row if exists (via unique key check)
$existingTestJob = Run-SqlScalar "SELECT count(*) FROM jobs WHERE dedupe_key = '$testDedupeKey';"
if ([int]$existingTestJob -eq 0) {
    Run-Sql "INSERT INTO jobs (company_name, company_key, title, dedupe_key, source_board, fit_score, status) VALUES ('Test Company', 'test_comp', 'Test Engineer', '$testDedupeKey', 'company_portal', 75, 'discovered');"
}

# Now attempt duplicate insert - must fail
$dupError = & $SqlitePath $DbPath "INSERT INTO jobs (company_name, company_key, title, dedupe_key, source_board, fit_score, status) VALUES ('Test Company', 'test_comp', 'Test Engineer', '$testDedupeKey', 'company_portal', 75, 'discovered');" 2>&1
Assert-Test "Deduplication Enforcement (Unique dedupe_key rejects duplicate)" ($dupError -like "*UNIQUE constraint failed*") $dupError

# ---------------------------------------------------------------------------
# Test 4: Database Integrity Trigger (No Deletes)
# ---------------------------------------------------------------------------
$deleteError = & $SqlitePath $DbPath "DELETE FROM jobs WHERE dedupe_key = '$testDedupeKey';" 2>&1
Assert-Test "No-Delete Trigger Enforcement (trg_nodelete_jobs)" ($deleteError -like "*no deletes*") $deleteError

# ---------------------------------------------------------------------------
# Test 5: Dynamic Sources Catalog & 5-Factor Evaluation
# ---------------------------------------------------------------------------
$sourceCount = Run-SqlScalar "SELECT COUNT(*) FROM sources;"
Assert-Test "Dynamic Sources Catalog Populated" ([int]$sourceCount -ge 8) "Source count: $sourceCount"

$deprioritizedCheck = Run-SqlScalar "SELECT yield_status FROM sources WHERE domain = 'getmereferred.com';"
Assert-Test "Deprioritized Sources Classified Correctly" ($deprioritizedCheck -eq "deprioritized") "Yield status: $deprioritizedCheck"

$promotedCheck = Run-SqlScalar "SELECT yield_status FROM sources WHERE domain = 'naukri.com';"
Assert-Test "Promoted Sources Classified Correctly" ($promotedCheck -eq "promoted") "Yield status: $promotedCheck"

$evaluationHistory = Run-SqlScalar "SELECT COUNT(*) FROM source_evaluations;"
Assert-Test "Source Evaluations History Recorded" ([int]$evaluationHistory -ge 3) "Evaluations count: $evaluationHistory"

# ---------------------------------------------------------------------------
# Test 6: Granular Status Lifecycle & Evidentiary Standard
# ---------------------------------------------------------------------------
$granularDist = Run-SqlScalar "SELECT COUNT(DISTINCT granular_status) FROM jobs WHERE granular_status IS NOT NULL;"
Assert-Test "Granular Statuses Assigned" ([int]$granularDist -ge 4) "Distinct granular statuses: $granularDist"

$confirmedEvidence = Run-SqlScalar "SELECT count(*) FROM jobs WHERE granular_status = 'submission_confirmed' AND submission_evidence IS NOT NULL;"
Assert-Test "Submission Confirmed Jobs Require Verifiable Evidence" ([int]$confirmedEvidence -ge 2) "Confirmed with evidence: $confirmedEvidence"

# ---------------------------------------------------------------------------
# Test 7: Concurrency & State Locking
# ---------------------------------------------------------------------------
$stateTasks = Run-SqlScalar "SELECT COUNT(*) FROM execution_state;"
Assert-Test "Execution State Tasks Configured" ([int]$stateTasks -ge 4) "Tasks count: $stateTasks"

$lockTest = Run-SqlScalar "SELECT is_running FROM execution_state WHERE task_name = 'vacancy_discovery';"
Assert-Test "Task Lock Idle & Unlocked" ($lockTest -eq "0") "is_running: $lockTest"

# ---------------------------------------------------------------------------
# Test 8: Blocklist Trigger Enforcement
# ---------------------------------------------------------------------------
# Test insert of a blocklisted company
$blocklistError = & $SqlitePath $DbPath "INSERT INTO jobs (company_name, company_key, title, dedupe_key, source_board, fit_score, status) VALUES ('Blocklisted Co', 'blocklisted_co', 'Data Engineer', 'block_comp|de|india', 'company_portal', 80, 'discovered');" 2>&1
# Temporarily check with an existing blocklist entry
$sampleBlock = Run-SqlScalar "SELECT value_key FROM blocklist WHERE kind = 'company' LIMIT 1;"
if ($sampleBlock) {
    $blockTestErr = & $SqlitePath $DbPath "INSERT INTO jobs (company_name, company_key, title, dedupe_key, source_board, fit_score, status) VALUES ('Blocked Co', '$sampleBlock', 'Data Engineer', 'blocked|de|india', 'company_portal', 80, 'discovered');" 2>&1
    Assert-Test "Blocklist Trigger Enforcement (trg_jobs_blocked)" ($blockTestErr -like "*company is blocklisted*") $blockTestErr
}

# ---------------------------------------------------------------------------
# Test Summary
# ---------------------------------------------------------------------------
Write-Host "`n=== VALIDATION RESULTS ===" -ForegroundColor Cyan
Write-Host "Total Passed: $PassCount" -ForegroundColor Green
Write-Host "Total Failed: $FailCount" -ForegroundColor $(if ($FailCount -eq 0) { "Green" } else { "Red" })

if ($FailCount -eq 0) {
    Write-Host "ALL VALIDATION CHECKS PASSED!" -ForegroundColor Green
} else {
    Write-Host "SOME CHECKS FAILED. PLEASE REVIEW." -ForegroundColor Red
}

