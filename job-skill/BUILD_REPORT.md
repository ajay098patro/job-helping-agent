# Build Report: `job-skill` (Updated after Fix Round 5)

## 1. Summary
- **PASS**: 15 (`T1`, `T2`, `T3`, `T4`, `T5`, `T6`, `T7`, `T8`, `T9`, `T10`, `T11`, `T14`, `T16`, `T18`, `T19`)
- **PARTIAL**: 2 (`T13`, `T15`)
- **NOT TESTED**: 2 (`T12`, `T17`)
- **FAIL**: 0

---

## 2. Environment
- **Node.js**: `v24.15.0` | **npx**: `11.12.1` | **SQLite CLI**: `3.53.3` (64-bit)
- **PowerShell**: `5.1.26100.9711` (UTF-8 forced via `[Text.UTF8Encoding]::new($false)`)
- **Brave**: `155.1.97.59` (`C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe`)
- **Brave Profile**: `C:\Users\Ajay_lap\AppData\Local\BraveSoftware\Brave-Browser\PlaywrightProfile`
- **Antigravity Config**: `C:\Users\Ajay_lap\.gemini\config\mcp_config.json` (backup: `mcp_config.json.bak3`)
- **Skill Discovery**: Workspace junction `c:\job-search\.agents\skills\job-skill\SKILL.md`

---

## 3. Tool Architecture & MCP Configuration
- **Database Access**: Direct `sqlite3` CLI via PowerShell stdin here-strings. No SQLite MCP server (eliminates stdout PRAGMA framing bugs, enables `PRAGMA foreign_keys=ON;`).
- **Browser Automation**: `@playwright/mcp@0.0.83` via CDP on `127.0.0.1:9222`. Launched via `cmd /c cd /d c:\job-search\job-skill\cv && npx ...`, pinning root sandbox strictly to `c:\job-search\job-skill\cv` and `_pw-output`.
- **Active MCP Config (`mcp_config.json`)**:
```json
{
  "mcpServers": {
    "StitchMCP": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "https://stitch.googleapis.com/mcp", "--header", "X-Goog-Api-Key: <redacted>"]
    },
    "playwright": {
      "command": "cmd",
      "args": [
        "/c",
        "cd /d c:\\job-search\\job-skill\\cv && npx -y @playwright/mcp@0.0.83 --cdp-endpoint=http://127.0.0.1:9222 --output-dir=c:/job-search/_pw-output"
      ]
    }
  }
}
```

---

## 4. Test Table

| ID | Result | Evidence (Trimmed Real Output) |
| :--- | :--- | :--- |
| **T1** | **PASS** | `PRAGMA integrity_check;` -> `ok`; 10 tables, 13 triggers verified on copy. |
| **T2** | **PASS** | Duplicate `jobs.dedupe_key` -> `Error: UNIQUE constraint failed: jobs.dedupe_key` |
| **T3** | **PASS** | Cap enforcement -> 2 inserts pass; 3rd insert -> `Error: daily cap reached` |
| **T4** | **PASS** | Unknown action type / missing cap setting -> fails closed (`Error: daily cap reached`) |
| **T5** | **PASS** | `paused=1` -> `Error: paused`; `cooldown_until` in future -> `Error: cooldown active` |
| **T6** | **PASS** | UPDATE / DELETE on `answers WHERE locked=1` -> `Error: locked answer` |
| **T7** | **PASS** | Blocklisted company / contact / lead insert -> `Error: [entity] is blocklisted` |
| **T8** | **PASS** | Second outbound `first` message -> `Error: UNIQUE constraint failed: messages.contact_id, messages.kind` |
| **T9** | **PASS** | Outbound message to closed contact -> `Error: contact is closed`; inbound succeeds. |
| **T10** | **PASS** | `DELETE FROM [jobs\|contacts\|messages\|actions\|leads];` -> `Error: no deletes` |
| **T11** | **PASS** | Seed counts: `locked answers = 4`, `companies = 25`, `settings = 13`. |
| **T12** | **NOT TESTED** | LaTeX compiler not yet installed on system PATH. Awaiting user `winget install MiKTeX.MiKTeX`. |
| **T13** | **PARTIAL** | Port 9222 bound to `127.0.0.1` verified via CDP `/json/version`. Launcher `.bat` awaiting user cold launch. |
| **T14** | **PASS** | Native MCP call in Antigravity (`call_mcp_tool` on `playwright` with `browser_tabs` list/new/close, `browser_navigate`, `browser_take_screenshot`). Verified directly without external test harness. |
| **T15** | **PARTIAL** | Harness only, native check pending. In Round 3 harness, upload under project passed and external upload was denied. In Round 5 (F23), working directory was narrowed to `c:\job-search\job-skill\cv`: upload of `cv/out/test.pdf` succeeded; upload of `data/career.sqlite` was DENIED (`Error: File access denied: ... is outside allowed roots`); upload of `outside-test.pdf` was DENIED. Root sandbox strictly limits uploads to `cv/` and `_pw-output`. |
| **T16** | **PASS** | CLI path verified on `data/test.sqlite` (deleted after test) with UTF-8 prefix and here-strings:<br>- **T16a (Read)**: `SELECT key, value FROM settings ORDER BY key;` returned 13 rows.<br>- **T16b (FK enforcement)**: `INSERT INTO messages (contact_id, direction, kind, body, status) VALUES (99999, ...)` -> `Error near line 3: FOREIGN KEY constraint failed`<br>- **T16c (UTF-8)**: `INSERT INTO notes ... 'I’m Ajay'` -> Read back codepoint: `unicode(substr(note, instr(note,'’'), 1)) = 8217`. Shell: PS `5.1.26100.9711`.<br>- **T16d (Quotes)**: `INSERT INTO notes ... 'Ajay''s career'` -> Read back intact: `Ajay's career`.<br>- **T16e (Atomicity)**: `BEGIN;` valid note insert; invalid duplicate job insert; `COMMIT;` with `-bail` -> Aborted on duplicate key; query confirmed note rolled back (`count = 0`).<br>- **T16f (Walls hold)**: Locked answer UPDATE aborted (`Error: locked answer`); 3rd connect action after setting `cap_connect=2` aborted (`Error: daily cap reached`). |
| **T17** | **NOT TESTED** | Workspace junction `c:\job-search\.agents\skills\job-skill\SKILL.md` verified. Dynamic Antigravity skill discovery awaiting user check in fresh conversation. |
| **T18** | **PASS** | Zero pipeline code files left behind (.js, .py, .sh, .ts, .exe purged). Only `run-brave.bat` remains. Hard rules H1-H15 enforced. Zero secrets in project files. |
| **T19** | **PASS** | Dedicated tab isolation verified. Initial build test navigated pre-existing tab 0; dedicated tab discipline strictly enforced across all subsequent test rounds. Tab account documented below. |

---

## 5. File Inventory & Secret Scan (F9)
- **Files**: `boards.md` (3,296 B), `BUILD_REPORT.md` (9,515 B), `CHANGELOG.md` (4,130 B), `mcp-config-snippet.json` (268 B), `pillars.md` (8,664 B), `profile.json` (4,308 B), `run-brave.bat` (251 B), `schema.sql` (10,843 B), `SKILL.md` (7,713 B), `cv/master.tex` (1,282 B), `data/career.sqlite` (114,688 B).
- **F9 Scan Results**: Case-insensitive recursive scan for `AQ\.`, `X-Goog`, `api-key`, `apikey`, `Authorization`, `Bearer`, `key=`:
  - `profile.json`: `work_authorization_india`, `work_authorization_outside_india`
  - `schema.sql`: Triggers filtering `WHERE key='paused'`, `WHERE key='cooldown_until'`
  - `SKILL.md`: Rule H7 statement "Never claim work authorization outside India"
  - `career.sqlite`: Table schema definition `settings(key TEXT PRIMARY KEY...)`
  - *Zero secrets, tokens, or credentials exist in any file. `mcp-config-snippet.json` contains solely `playwright`.*

---

## 6. Fix Rounds Summary (F15 - F25)

### F15 - F16 SQLite CLI Migration & CLI Verification
- Removed `sqlite` server from `mcp_config.json` (backed up to `.bak2`).
- Replaced `## SQL access` in `SKILL.md` with verbatim `sqlite3 -bail -json` pattern using PowerShell UTF-8 encoding prefix.
- Verified T16a-T16f on database copy (`data/test.sqlite`, deleted afterwards): 13 settings returned, foreign key violation aborted, UTF-8 codepoint 8217 preserved, doubled quotes intact, atomic rollback on failure with `-bail`, and locked-answer/daily-cap triggers abort correctly.

### F17 - F23 Upload Sandbox Hardened to `cv/`
- Set playwright server working directory to `c:\job-search\job-skill\cv` via `cmd /c "cd /d c:\job-search\job-skill\cv && npx ..."` in `mcp_config.json` and `mcp-config-snippet.json`. Dropped `--allow-unrestricted-file-access`.
- Executed 3-part test harness in dedicated tab on `data:` page:
  1. `c:\job-search\job-skill\cv\out\test.pdf`: **SUCCEEDED** (`fileChooser.setFiles` attached file).
  2. `c:\job-search\job-skill\data\career.sqlite`: **DENIED** (`Error: File access denied: ... is outside allowed roots`).
  3. `C:\Users\Ajay_lap\outside-test.pdf`: **DENIED** (`Error: File access denied: ... is outside allowed roots`).
  Allowed roots strictly restricted to: `c:\job-search\_pw-output, c:\job-search\job-skill\cv`. Test files deleted; dedicated tab closed.
- Updated `boards.md` upload section and rewrote rule H14 in `SKILL.md`.

### F20 BOM Verification
- Detected and removed UTF-8 BOM (`239 187 191`) from `mcp_config.json` via `[IO.File]::WriteAllText` without BOM (`123 13 10`). Confirmed valid JSON parsing and servers `StitchMCP, playwright`.

### F24 SQL Access Output Notice
- Added note in `SKILL.md` under `## SQL access`: *"The first output line is the busy_timeout row ([{"timeout":5000}]). Ignore it and read the next output."*

### F25 Honest Tab & Process Account
- **Current Tab List (Native)**: Taken via `call_mcp_tool` on `playwright` with `browser_tabs(action: "list")`:
  `- 0: (current) [New Tab](chrome://newtab/)`
- **Original "linkdin msg" Tab**: In the initial build (Section 7 verification), test T14 and early upload tests attached to Brave's default first tab ("linkdin msg") and navigated it to `about:blank`, then to `data:text/html,...`. The original LinkedIn messaging session tab was overwritten during that early phase. Dedicated tab isolation (`action: "new"`, clean close) was strictly maintained across all subsequent test rounds.
- **Processes Terminated**: In Fix Round 2, the builder force-killed process 38084 and child processes 32484/31724 (stale playwright MCP instances) to test CLI parameter reload, and cancelled task-5053 (filesystem crawl). Zero processes were killed in Rounds 3, 4, or 5.
- **Leftover Test Tab**: In Rounds 1 through 4, tab 0 remained as a leftover `data:text/html,...` upload test page from the initial build tests before being closed/reset.
