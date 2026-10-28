# Job Search & Outreach Automation Engine

Autonomous multi-platform job application and recruitment outreach pipeline tailored for GIS, Geospatial Engineering, and Python Backend roles across India and Remote.

The engine automates discovery, eligibility filtering, candidate rate limiting, ATS application submission, and personalized recruiter outreach while strictly adhering to candidate truth and safety boundaries.

---

## Key Features

- **Multi-Platform Application**: Native automation for Naukri, LinkedIn Easy Apply, and Direct Enterprise ATS Portals (SmartRecruiters, Workday, Keka, Oracle Cloud HCM, iCIMS, Lever, Greenhouse).
- **Guardian Rate Limiter & Audit Ledger**: Enforces daily caps, action reservations (`reserve`), deduplication, rate limits, and SQLite transaction logging.
- **Dynamic Onboarding Wizard**: Completely candidate-agnostic. Anyone (e.g., Ankush or a new candidate) can clone the repo and run an interactive onboarding interview to configure their own profile.
- **Queued Job Prefill Protocol**: For portals requiring SSO or visual CAPTCHA, the engine opens dedicated browser tabs, pre-fills all candidate fields and resumes, and presents an actionable queue for 1-click completion.
- **Ultra-Slim Recruiter Cold Outreach**: Automated high-density cold emails dispatched via official webmail with resume attachments and zero-spam rest gates.
- **Zero-Emoji Professional Standard**: Strict formatting compliance across all outreach text, connection notes, and database records.

---

## Prerequisites

- **Operating System**: Windows
- **Node.js**: v22 or higher (Node 24 recommended; leverages native `node:sqlite` with zero npm package dependencies)
- **Browser**: Brave Browser (or Google Chrome) started with remote debugging enabled on port `9222`

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
4. Checks the candidate profile (`job-skill\profile.json`) and master CV (`career-ops/*.pdf`).
5. Displays the active Guardian session action counter.

### 2. Onboard a New Candidate (e.g., Ankush)

To configure the engine for a new candidate or switch profiles, choose either method:

#### Method A: Interactive Terminal Wizard
Run:
```cmd
init.cmd --new
```
*(or `npm run onboard` / `node job-skill\onboard.js`)*

The wizard walks through:
- Candidate identity and contact details (name, email, phone, location, LinkedIn, GitHub).
- Master CV selection from `career-ops/`.
- Compensation truth (Current CTC, Expected CTC range, Notice period).
- Target roles and 4–6 core technical skills.
- Location and relocation preferences.
- Automatically writes `job-skill\profile.json`, updates `career.sqlite` answers, and synchronizes `AGENTS.md`.

#### Method B: Autonomous Agent Interview (via AI Agent)
In chat, simply tell the AI agent:
> *"Run init for Ankush"* or *"Onboard a new candidate"*

The agent will request the candidate's CV, parse verifiable career evidences, ask clarifying questions until satisfied, and configure all pipeline files automatically.

### 3. Launch Debugging Browser

To enable browser automation via Playwright / CDP:

```cmd
job-skill\run-brave.bat
```
*(or `npm run browser`)*

---

## Directory Architecture

```text
job-search/
├── .agents/                    # Agent skill definitions and metadata
├── .gitignore                  # Git exclusion rules (databases, logs, build artifacts)
├── AGENTS.md                   # Operational rules, candidate truth, and safety guardrails
├── career-ops/                 # Candidate resume and career assets
│   └── Ajay_Patro_CV.pdf       # Active master CV
├── init.cmd                    # One-command project initializer and candidate switcher
├── package.json                # Project script shortcuts
├── README.md                   # Complete project documentation
└── job-skill/                  # Core automation engine
    ├── boards.md               # Platform-specific selectors and application guidelines
    ├── cv/                     # LaTeX CV source templates (master.tex)
    ├── guardian.js             # Rate limiter, ledger, and action reservation CLI
    ├── onboard.js              # Interactive candidate onboarding wizard
    ├── pillars.md              # 5 Workflow pillars: Connect, First Message, Reply, Apply, Track
    ├── profile.json            # Active candidate truth profile & messaging templates
    ├── profile.template.json   # Pristine candidate profile schema template
    ├── run-brave.bat           # Remote debugging browser launcher script
    ├── schema.sql              # Complete SQLite database schema & triggers
    └── SKILL.md                # Agent instruction set and execution procedures
```

---

## Guardian CLI Reference

The Guardian ledger (`job-skill/guardian.js`) regulates all actions and records audit trails:

| Command | Syntax | Description |
|---|---|---|
| `session` | `node job-skill/guardian.js session` | Inspect current session action count |
| `reserve` | `node job-skill/guardian.js reserve <type> [job_id]` | Reserve an action (`apply_naukri`, `apply_linkedin`, `apply_portal`, `email`, `connect`, `message`) |
| `record` | `node job-skill/guardian.js record "<company>" "<title>" "<url>" <fit_score> "<board>" "<status>"` | Record a visited job listing in the database |
| `applied` | `node job-skill/guardian.js applied <job_id>` | Mark a job as successfully applied in the database |

---

## Operational Guardrails & Behavioral Rules

All agent and automation behavior is governed by [`AGENTS.md`](AGENTS.md):

1. **Zero Emojis**: Strictly prohibited in outreach, notes, messages, and records.
2. **Dedicated Tab Protocol**: Never navigate, reuse, or hijack existing user browsing tabs. Always open dedicated tabs (`await context.newPage()`) and close them upon task completion.
3. **Mandatory History Inspection & Rest Gate**: Never message without inspecting the full thread transcript. Reactions, closures, and acknowledgments are hard stops. Outbound messages are only allowed for explicit, unanswered recruiter questions.
4. **Candidate Truth Integrity**: Absolute honesty regarding CTC, notice period, work authorization, and technical experience. Never fabricate credentials.
5. **Guardian Record Boundary (H18)**: `guardian record` must be invoked once per job page actually visited and inspected in the browser.
6. **Queued Job Opening & Prefill Protocol (Rule 11)**: For jobs in `needs_input`, dedicated tabs are opened and prefilled autonomously so the user only needs to complete final authentication or CAPTCHA.

---

## Supported Boards & ATS Systems

| Platform | Automation Level | Route |
|---|---|---|
| **Naukri.com** | 100% Autonomous | 1-Click Apply & ACP Redirects |
| **LinkedIn** | Autonomous | Easy Apply (with daily submission cap handling) |
| **SmartRecruiters** | 100% Autonomous | Shadow-DOM form fill, CV upload, confirmation |
| **Keka ATS** | Autonomous Prefill | Full form prefilled + CV attached; stops at CAPTCHA |
| **Workday** | Autonomous Prefill | Navigates to candidate sign-in / registration with email prefilled |
| **Oracle Cloud HCM** | Autonomous Prefill | Navigates directly to candidate email submission step |
| **iCIMS** | Autonomous Prefill | Navigates to login iframe with candidate email prefilled |
| **Recruiter Webmail** | Autonomous Dispatch | Dispatches ultra-slim cold email via Outlook with verified CV attachment |
