# Job Search & Outreach Automation Engine

Autonomous multi-platform job application and recruitment outreach pipeline tailored for Data Engineering, Database Engineering, and Python Backend roles across India and Remote.

The engine automates discovery, dynamic recruitment source evaluation, eligibility filtering, candidate rate limiting, ATS application submission, and personalized recruiter outreach while strictly adhering to candidate truth, Markdown operational protocols, and safety boundaries.

---

## Key Features

- **Multi-Platform Application**: Native automation for Naukri, Instahyre, Direct Enterprise ATS Portals (Greenhouse, Lever, SmartRecruiters, Workday, Keka, Oracle Cloud HCM, iCIMS), and LinkedIn manual execution queue.
- **Dynamic Job-Source Discovery Engine**: Persistent tracking and periodic evaluation of recruitment sources (Naukri, LinkedIn, Instahyre, Cutshort, Wellfound, Hirist, Google Jobs) using a 5-factor scoring model.
- **Granular Application Lifecycle & Evidentiary Standard**: Distinct states (`discovered`, `shortlisted`, `application_prepared`, `awaiting_user_info`, `awaiting_authorization`, `submitted`, `submission_confirmed`, `rejected_or_closed`, `failed`) requiring verifiable confirmation evidence before marking `submission_confirmed`.
- **Safe Execution Concurrency & State Locking**: Automated concurrency lock management and stale-lock recovery via `execution_state` table in `career.sqlite`.
- **Guardian Operational Protocol & Audit Ledger**: Enforces daily caps, action reservations (`INSERT INTO actions`), deduplication, rate limits, and SQLite transaction logging with database trigger enforcement.
- **Candidate Truth Configuration**: Candidate-agnostic architecture. Uses `job-skill/profile.template.json` as the pristine schema template and `job-skill/profile.json` as the active truth profile.
- **Queued Job Prefill Protocol**: For portals requiring SSO or visual CAPTCHA, the engine opens dedicated browser tabs, pre-fills all candidate fields and resumes, and presents an actionable queue for 1-click completion.
- **Ultra-Slim Recruiter Cold Outreach**: Automated high-density cold emails dispatched via official webmail with resume attachments and zero-spam rest gates.
- **Zero-Emoji Professional Standard**: Strict formatting compliance across all outreach text, connection notes, and database records.

---

## Prerequisites

- **Operating System**: Windows
- **Node.js**: v22 or higher (Node 24 recommended)
- **Database CLI**: SQLite CLI 3.54.1 (64-bit) for inspection and administration
- **Browser**: Brave Browser automatically launched and managed via Playwright MCP using persistent profile (`PlaywrightProfile`)

---

## Quick Start

### 1. Initialize the Environment

Run the initialization script from the root of the workspace:

```cmd
init.cmd
```
*(or via npm: `npm run init`)*

This script automatically:
1. Validates the Node.js runtime.
2. Ensures the `job-skill\data\` directory exists.
3. Bootstraps `job-skill\data\career.sqlite` from `job-skill\schema.sql` if no database exists.
4. Ensures candidate profile (`job-skill\profile.json`) is populated.
5. Verifies the master CV PDF exists.

### 2. Candidate Onboarding & Configuration

To configure the engine for a new candidate or adjust profile facts:

1. Copy `job-skill/profile.template.json` to `job-skill/profile.json` (if setting up fresh).
2. Populate the required truth sections:
   - **Identity & Contact**: Full Name, Email, Phone, Location, LinkedIn URL.
   - **Work Facts**: Total experience years (2.5 Yrs), Current CTC, Expected CTC range, Notice period, Current Employer.
   - **Target Roles**: Primary role hierarchy (Data Engineer > Database Engineer > Python Developer).
   - **Technical Skills**: Core technical stack and database/ETL specializations.
   - **Location Preferences**: Primary South hubs (Hyderabad, Bengaluru, Chennai, Remote) and relocation parameters.
   - **CV File**: Path to active PDF resume in `career-ops/`.
3. Alternatively, ask the AI agent in chat to configure or update candidate parameters, and the agent will update `profile.json`, `career.sqlite` answers, and `AGENTS.md` synchronously.

### 3. Pure AI Agent Autonomous Execution

The system operates on a **Pure AI Agent Architecture** (Zero Script-Based Automation):
- **Candidate Truth & Inputs**: `job-skill/profile.json`, `career-ops/Ajay_Patro_CV.pdf`, and Markdown operational policies.
- **AI Agent (The Worker)**: Evaluates pages dynamically, formulates queries, judges vacancy fit against Ajay's 2.5 yrs experience truth, navigates ATS forms, and drafts communications. No hardcoded scrapers or decision scripts.
- **Persistent Memory**: `job-skill/data/career.sqlite` records all discovered vacancies, investigated companies, evaluated sources, and application actions using native `sqlite3.exe`.

To execute an autonomous mission outside the interactive chat session, the agent CLI (OpenAI Codex CLI) is invoked directly:

```cmd
codex exec --dangerously-bypass-approvals-and-sandbox -C C:\job-search - < mission.txt
```

### 4. Run the Validation Test Suite

To verify database schema, triggers, and qualification gate integrity:

```powershell
powershell -ExecutionPolicy Bypass -File "job-skill\test_validation.ps1"
```

---

## Directory Architecture

```text
job-search/
├── .agents/                    # Agent skill definitions and metadata
├── .gitignore                  # Git exclusion rules (databases, logs, build artifacts)
├── AGENTS.md                   # Operational rules, candidate truth, and safety guardrails
├── career-ops/                 # Candidate resume and career assets
│   └── Ajay_Patro_CV.pdf       # Active master CV
├── init.cmd                    # One-command project initializer and environment validator
├── package.json                # Project script shortcuts
├── README.md                   # Complete project documentation
└── job-skill/                  # Core automation engine
    ├── boards.md               # Dynamic sources catalog and platform-specific guidelines
    ├── cv/                     # LaTeX CV source templates (master.tex)
    ├── data/
    │   └── career.sqlite       # Authoritative SQLite production database
    ├── migrations/             # Database migrations (001_dynamic_sources_and_execution.sql)
    ├── pillars.md              # 5 Workflow pillars: Connect, First Message, Reply, Apply, Track
    ├── profile.json            # Active candidate truth profile & messaging templates
    ├── profile.template.json   # Pristine candidate profile schema template
    ├── schema.sql              # Complete SQLite database schema & triggers
    ├── SKILL.md                # Agent instruction set and execution procedures
    └── test_validation.ps1     # 16-point automated test validation suite
```

---

## Dynamic Source Discovery & Scoring

Recruitment sources are tracked dynamically in the `sources` table and evaluated along five dimensions:
- **Relevance (25%)**: Alignment with Data Engineer / Database Engineer / Python Developer roles.
- **Freshness (20%)**: Recency of job postings.
- **Accessibility (20%)**: Clean application flow without hostile bot barriers.
- **Uniqueness (15%)**: Ratio of direct company listings vs re-syndicated posts.
- **Listing Quality (20%)**: Clear salary bands, required experience brackets, and tech stack details.

Sources are classified into:
- `promoted`: Top-yield portals (e.g. Naukri.com, score: 90).
- `active`: Verified platforms (Cutshort, Instahyre, LinkedIn, Wellfound, Hirist, Google Jobs).
- `deprioritized`: Low-yield or misleading aggregators (e.g. GetMeReferred.com, score: 57).

---

## Granular Application Lifecycle & Evidentiary Standard

```text
discovered -> shortlisted -> application_prepared -> submitted -> submission_confirmed
                                                  \-> awaiting_user_info (SSO / CAPTCHA)
                                                  \-> awaiting_authorization (Approval)
                                                  \-> failed / rejected_or_closed
```

- **`submission_confirmed`**: Requires explicit verifiable proof in `submission_evidence` (portal confirmation message, confirmation ID, or dashboard listing).
- **`awaiting_user_info`**: Queued for candidate manual input (SSO login, CAPTCHA).
- **`awaiting_authorization`**: Queued for candidate review and approval before outreach dispatch.
