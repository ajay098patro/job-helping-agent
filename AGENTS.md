# Project & Agent Operational Rules

## 1. Browser & Automation Rules (Exclusive Playwright MCP Policy)
- **Mandatory Exclusive Interface**: All browser interaction MUST happen exclusively through the existing `playwright` MCP server.
  - Available tools:
    - `browser_tabs`
    - `browser_navigate`
    - `browser_navigate_back`
    - `browser_snapshot`
    - `browser_take_screenshot`
    - `browser_click`
    - `browser_type`
    - `browser_press_key`
    - `browser_fill_form`
    - `browser_hover`
    - `browser_select_option`
    - `browser_handle_dialog`
    - `browser_console_messages`
    - `browser_network_requests`
    - `browser_evaluate`
- **Strictly Prohibited for Browser Control**:
  - Do NOT use custom Python browser automation.
  - Do NOT use standalone Playwright navigation scripts.
  - Do NOT use Puppeteer, Selenium, or alternative browser-control frameworks.
  - Do NOT use direct CDP HTTP requests or direct CDP WebSocket connections.
  - Do NOT create or use custom Chrome DevTools Protocol helpers (e.g. `cdp_helper.py`).
  - Do NOT use manual browser debugging ports (e.g. port 9222).
  - Do NOT use BAT files to start browsers for automation.
  - Do NOT use alternative browser-control MCP servers.
  - Do NOT generate scripts to perform routine actions already supported by MCP tools.
- **Dedicated Tab / Page Isolation**: When opening a new flow or external application, create a clean dedicated tab via `browser_tabs(action='new', url=...)`. NEVER navigate or hijack active candidate tabs. Close auxiliary tabs when finished.
- **Candidate-Authorized Direct Outreach**: Per candidate's explicit directive, the agent is authorized and directed to dispatch personalized connection notes, outreach messages, and recruiter emails directly (`approval_mode = 'none'`) rather than leaving them in draft. All automated actions must introduce natural human jitter, adhere strictly to daily caps, and target relevant verified professionals. Bulk member scraping or aggressive automated clicking without delays is strictly prohibited.
- **Failure Policy**:
  - If Playwright MCP is unavailable or fails:
    1. Inspect the MCP error.
    2. Report the failure.
    3. Diagnose the existing MCP configuration.
    4. Ask for intervention if required.
  - Never silently switch to another browser automation mechanism.
- **Browser Session & State Policy**:
  - Reuse the existing Brave browser session.
  - Reuse the configured persistent profile (`PlaywrightProfile`).
  - Do not unnecessarily create new browser instances.
  - Do not clear cookies or browser storage.
  - Do not interfere with the user's active sessions (LinkedIn, Naukri, Instahyre).
  - Verify important interactions using snapshots or screenshots.
- **Clean Overlays**: Always clear overlays or popups before attempting clicks.
- **Form Filling Boundaries**: Form filling must use standard inputs and keys; direct DOM mutation without triggering events is prohibited.

## 2. Communication & Messaging Rules
- **ZERO EMOJIS**: NEVER use emojis in any message, cold outreach, LinkedIn note, or email.
- **Messages Priority**: Stage 1 (Inbox Sweep & Replies) is always processed first.
- **Ultra-Slim Email Template**: Recruiter cold emails must be ultra-slim and high-density:
  - 1-line hook/context.
  - Quick overview of relevant experience (specifically highlight 2.5+ years hands-on experience in PostgreSQL & PostGIS, spatial schemas, GiST indexing, query optimization, and Python backend ETL).
  - NO bulky "Key Details" (CTC/Notice) block in the cold email body.
  - Resume attachment (`Ajay_Patro_CV.pdf`).
  - Single consistent signature:
    Regards  
    Ajay Kumar Patro  
    +91-7894464335  
    ajay789patro@outlook.com

## 3. Candidate Truth & Credentials
- **Name**: Ajay Kumar Patro
- **Phone**: +91-7894464335 (matching resume and Outlook signature)
- **Email**: ajay789patro@outlook.com (dispatched from Outlook)
- **Current CTC**: ₹3.6 LPA
- **Expected CTC**: ₹10–13 LPA
- **Notice Period**: 30 days
- **CV Path**: `C:/job-search/career-ops/Ajay_Patro_CV.pdf`

## 4. Location & Relocation Behavioral Protocol
- **Primary Preferences**: Hyderabad, Bengaluru, Chennai, Remote/Hybrid (immediately open and flexible at baseline ₹10–13 LPA).
- **All Other Locations Across India (e.g., Guwahati, Delhi/NCR, Pune, Mumbai, Kolkata, etc.)**: Do NOT reject any location. The candidate is permissive and open to relocating anywhere in India, but moving outside the primary South hubs requires a higher budget/compensation package than the standard baseline to justify the relocation.
- **Negotiation Response**: When asked *"Can you relocate to [City]?"* (outside HYD/BLR/Chennai), respond permissively: express openness to consider it depending on the overall opportunity, and inquire about the role scope, budget/compensation package on offer, and relocation assistance so we can evaluate and decide.
- **Trigger Condition**: Only bring up this relocation/compensation evaluation inquiry if the recruiter or hiring manager specifically asks about location/relocation.

## 5. Mandatory Historical Message Inspection & Rest Gate
- **NEVER Message Without Full History Inspection**: The agent must **NEVER** send a message or reply to ANY contact without reading, parsing, and inspecting the **entire historical conversation transcript** from Turn 1 to the end.
- **The Self-Questioning Gate ("Do we REALLY need to message them?")**: Before composing or sending ANY message, the agent MUST ask itself: *"Do we REALLY need to message this person?"* If the answer is not an undeniable YES triggered by an explicit, direct, unanswered question from the contact, **DO NOT MESSAGE**. When in doubt, STOP and do NOT message.
- **Reactions, Acknowledgments & Closures are Hard Stops**: If the contact's latest message is a reaction (e.g. `👍`, `🙏`, `👏`, `😊`, any emoji), or a conversational acknowledgment/closure (e.g. *"Thanks"*, *"Sure"*, *"Noted"*, *"Ok"*, *"All the best"*, *"If something comes in my notice"*, *"I will get back to you"*), the conversation is AT REST. **NEVER SEND A MESSAGE**. Replying to closures or acknowledgments is unacceptable spam that damages the candidate's professional standing.
- **Strict CV De-Duplication**: If `Ajay_Patro_CV.pdf` was already shared anywhere in the previous history of the conversation, **NEVER** re-attach or re-send the CV.
- **Outbound Reply Condition**: An outbound reply is ONLY allowed if the contact has asked an explicit, unanswered question (e.g. about CTC, notice period, location, technical experience) or made a new actionable request that has not yet been addressed. If there is no explicit question, the conversation stays at rest.

## 6. Multi-Platform Job Application Protocol & Limit Failover
- **LinkedIn Limit Detection & Immediate Failover**: When LinkedIn displays *"We limit daily submissions to maintain quality and prevent bots"*, or when Easy Apply modals fail to open due to account caps, immediately halt LinkedIn Easy Apply for the day and failover to external platforms.
- **Execution Order**:
  1. **Naukri First**: Process matching applications on Naukri.com across GIS, Geospatial, Python Backend, PostGIS, and Data Engineering openings.
  2. **Google Jobs for Direct Company Portals Second**: Search Google Jobs specifically targeting direct company website advertised openings ONLY (e.g. Lepton Software career site, Esri career portal, Caterpillar, WSP, etc.). Never apply through 3rd-party aggregators; only consider direct company career portals.
- **Dedicated Tab Rule**: Always open dedicated tabs (`await context.newPage()`) and close them when finished.

## 7. Hard Reject Roles & Qualification Gates
- **Hard Reject List**: Land Surveyor, Drone Pilot, Surveyor, SDET, QA, Chaos Engineer, Frontend, PHP, Mainframe, Machine Learning Engineer, Data Scientist, DevOps Engineer, Cloud Engineer, QA Engineer, Test Engineer, and anything unrelated. Skip immediately with `skip_reason = 'hard_reject'`. Never shortlist these roles.
- **Experience Requirement Gate**:
  - Candidate truth: **2.5 Years Experience**, backed by exceptional depth in PostgreSQL, PostGIS, spatial schemas, query optimization, Apache Airflow ETL, and Python backend engineering.
  - **Permitted Experience Bracket**: Candidate explicitly authorizes targeting roles up to **5–6 years experience** based on qualification quality, technical depth, and hands-on production engineering delivery.
  - Reject only roles strictly requiring **> 6 years experience** (e.g., 7–10+ years, Principal, Director, VP) with `fit_score <= 30`, `status = 'skipped'`, `granular_status = 'skipped'`, and `skip_reason = 'seniority_beyond_6yr_limit'`.
  - Openly shortlist and apply to matching roles in the **0–6 years experience bracket**.
- **Record Inspection Boundary**: Each job vacancy and company record in `career.sqlite` must reflect a page actually visited, read, and evaluated in the browser. Never perform bulk inserts or ingest lists of uninspected job links. If 10 jobs are evaluated, visit each page and record each evaluated vacancy individually.

## 8. Seniority & LinkedIn Connect Search Filter Protocol
- **Mandatory `titleFreeText` Search Parameter**: For all connect searches on LinkedIn, ALWAYS include the `titleFreeText` filter in the search URL to restrict results to senior level people:
  - Parameter: `&titleFreeText=Senior%20OR%20Lead%20OR%20Manager%20OR%20Director%20OR%20Head%20OR%20Principal`
  - **Hard Gate**: NEVER search for connections without this filter.
- **LinkedIn Direct Dispatch Protocol**: Connection requests and personalized notes are dispatched directly by the agent via Playwright MCP using human-like delays, reserving the action in `actions` (`type = 'connect'`), navigating to the candidate profile, clicking Connect -> Add a note, filling the personalized note, and sending. Record status as `sent` in `messages` and `stage = 'requested'` in `contacts`.

## 9. Mandatory End-of-Run Manual Applications Reporting Protocol
- **Explicit Manual Apply Queue**: After every single run or session, the agent MUST output a dedicated, clear report of all jobs that require manual application (`status = 'needs_input'` or `granular_status = 'awaiting_user_info' / 'awaiting_authorization'`).
- **Required Details per Job**:
  - Job ID
  - Job Title
  - Company Name
  - Direct Application / Portal URL (direct ATS or external link, not generic aggregator)
  - Exact Blocker / Reason (e.g. requires candidate account login/SSO, visual CAPTCHA, complex candidate-specific screening questions like family background/marital status/personal essays)
- **Hard Gate**: Never finish a run without presenting this actionable manual application list so the candidate can immediately click and submit them manually.

## 11. Queued Job Opening & Prefill Protocol
- **Mandatory Prefill for ALL Queued Jobs**: Every single job placed into the manual application queue (`status = 'needs_input'` or `granular_status = 'awaiting_user_info' / 'awaiting_authorization'`) MUST be actively opened, inspected, and 100% prefilled by the agent before handing off to the candidate. Never leave a queued job without prefilling all permissible fields.
- **Dedicated Tab per Queued Role**: For jobs in the manual application queue (`granular_status = 'awaiting_user_info'`), open a dedicated browser tab (`await context.newPage()`) for each actionable job application URL.
- **Maximum Autonomous Prefill**: Wherever an external portal or ATS (such as Keka, Lever, Greenhouse, SmartRecruiters, Workable, or public web forms) permits input before authentication, autofill and prefill all candidate data (Full Name: Ajay Kumar Patro, Email: ajay789patro@outlook.com, Phone: +91-7894464335, Location: Nashik / India, LinkedIn URL, Experience: 2.5 Years, technical screening essays, CTC: ₹3.6 LPA / ₹10–13 LPA, Notice: 30 days, and attach `Ajay_Patro_CV.pdf`).
- **Actionable User Hand-Off**: For portals requiring candidate registration or SSO (e.g., Workday, Oracle Cloud HCM, iCIMS), navigate directly to the application sign-in / registration screen so the user can immediately log in and complete submission without searching for links.

## 12. Role Hierarchy & 8-Pillar Optimization Playbook Protocol
- **Role Priority Hierarchy**: **Data Engineer (DE) > Database Engineer (DBE) > Python Developer (PyE)**.
- **GIS Status**: GIS/Geospatial is secondary domain evidence, NOT the primary filter or identity. Always prioritize general Data Engineering, Database Engineering, and Python backend engineering openings across all platforms.
- **Experience Truth**: 2.5 Years hands-on experience.
- **8 Pillars Alignment (Naukri, LinkedIn, Instahyre, Portals)**:
  1. *Research & Role Alignment*: Target roles: Data Engineer, Database Engineer, Python Backend Developer.
  2. *Resume Headline*: High-density keyword headline: `Data Engineer | Database Engineer | Python Developer | PostgreSQL, SQL Query Optimization, Airflow, ETL Pipelines, FastAPI | 2.5 Yrs Exp | Notice: 15-30 Days`.
  3. *Profile Summary*: "About Me" and "What I Build" structure with concrete technical evidence (Airflow pipelines, PostgreSQL/PostGIS architecture, GiST/B-tree indexing, query optimization, pgBackRest PITR, FastAPI backend).
  4. *Key Skills*: Data Engineering, ETL, PostgreSQL, SQL Query Optimization, Apache Airflow, Python, PostGIS, FastAPI, Docker.
  5. *Employment Framing*: Frame responsibilities to highlight backend ETL, data pipelines, schema optimization, and database architecture.
  6. *Projects & Career Evidence*: Present the production spatial ETL pipeline, automated Airflow DAGs, and high-throughput PostgreSQL query optimization as primary proof points.
  7. *Career Profile Preferences*: Preferred Roles: Data Engineer, Database Engineer, Python Developer; Preferred Locations: Hyderabad, Bengaluru, Chennai, Remote; Salary: ₹10–13 LPA.
  8. *Basic Details & Availability*: 2.5 Years, 15–30 Days notice period (negotiable for early release).

## 13. Database Administration & Interaction Policy (Native SQLite CLI)
- **Primary Database Path**: `C:/job-search/job-skill/data/career.sqlite` (single authoritative production database).
- **Executable**: `C:\Users\Ajay_lap\AppData\Local\Programs\SQLite\sqlite3.exe`.
- **Mandatory Database Interaction Rules**:
  1. Use `sqlite3.exe` for all routine agent-driven SQLite inspection and administration.
  2. Execute SQL directly through the native SQLite CLI.
  3. Use `.tables`, `.schema`, `SELECT`, `INSERT`, `UPDATE`, `DELETE`, and other native SQLite commands directly.
  4. Avoid creating temporary JavaScript or Python scripts for routine database queries.
  5. Do not create custom database wrappers when native SQLite CLI commands are sufficient.
  6. Use explicit transactions (`BEGIN TRANSACTION; ... COMMIT;`) for multi-step modifications.
  7. Verify all modifications using read-only `SELECT` queries.
  8. Preserve the production database and all existing records.
  9. Always verify that the target database exists at `C:/job-search/job-skill/data/career.sqlite` before executing commands; never create accidental new database files.
  10. Report database errors explicitly rather than silently attempting alternative database files.

## 14. Guardian Operational Protocols (Markdown-Governed Architecture)
- **Application Target & Action Limits**:
  - `apply_volume`: **50+ applications minimum daily target**. Applications are uncapped; apply to as many matching roles as possible without artificial upper ceilings.
  - `apply_naukri`: Uncapped (minimum target contributing to 50+ total daily applications).
  - `apply_instahyre`: Uncapped (minimum target contributing to 50+ total daily applications).
  - `apply_portal`: Uncapped (Direct ATS portal submissions).
  - `apply_linkedin`: Up to daily safe account thresholds.
  - `connect`: Up to 200 daily cap in settings (drafted for candidate approval).
  - `message`: Up to 200 daily cap in settings (drafted for candidate approval).
  - `email`: 10 per day (Recruiter cold emails via webmail).
- **Mandatory Action Reservation Protocol**:
  - Before initiating any external browser click or submission, the agent must reserve the action via SQL:
    ```sql
    INSERT INTO actions (type, ref_table, ref_id) VALUES ('apply_naukri', 'jobs', <job_id>);
    ```
  - If the insert succeeds, the reservation is confirmed. If rejected by trigger (`daily cap reached`), the agent must immediately halt that action category for the day.
- **Granular Application Status Lifecycle & Evidentiary Standard**:
  - `discovered` -> `shortlisted` -> `application_prepared` -> `submitted` -> `submission_confirmed`.
  - Blocked paths: `awaiting_user_info` (SSO/CAPTCHA), `awaiting_authorization` (outreach approval), `failed`, `rejected_or_closed`.
  - `submission_confirmed` requires recorded evidence in `submission_evidence` (confirmation screen message, reference ID, or dashboard entry). Never mark `submission_confirmed` without evidence.
- **Dynamic Job-Source Discovery**:
  - Dynamic discovery evaluates recruitment sources via the 5-factor model (Relevance, Freshness, Accessibility, Uniqueness, Listing Quality) stored in `sources` and `source_evaluations`.
  - Yield status transitions: `evaluating` -> `active` / `promoted` / `deprioritized` / `deprecated`.
- **Human Approval & Dispatch Requirements**:
  - `approval_mode = 'none'`: All outbound connection notes, recruiter emails, and messages are dispatched directly by the agent upon generation, reserving the action in `actions` and updating `status = 'sent'`.
  - While `approval_mode = 'all'`, outreach messages are drafted for review.

## 15. Candidate Onboarding & Truth Profile Protocol
- **Configuration Schema & Templates**:
  - Pristine Schema Template: `job-skill/profile.template.json`.
  - Active Candidate Truth Profile: `job-skill/profile.json`.
- **Configured Candidate Dimensions**:
  1. *Identity & Contact*: Legal Full Name, Preferred First Name, Email, Phone Number, Calling Availability, Location, LinkedIn URL, Portfolio URL.
  2. *Compensation Truth*: Current CTC (₹3.6 LPA), Expected CTC Range (Min ₹10 – Target ₹13 LPA), Notice Period (30 days), Current Employer, Current Title.
  3. *Target Roles & Technical Stack*: Role hierarchy priority (DE > DBE > PyE), core technical skills (PostgreSQL, PostGIS, Airflow, FastAPI, Docker).
  4. *Locations & Relocation*: Primary target hubs (Hyderabad, Bengaluru, Chennai, Remote) and nationwide relocation budget evaluation protocol.
  5. *CV Asset*: Active PDF resume path in `career-ops/Ajay_Patro_CV.pdf`.
  6. *Communication Templates*: Standardized outreach templates (`connect_note`, `recruiter_email`, and parameterized replies for notice, CTC, and location).
- **Synchronized Locations**:
  - When onboarding or updating candidate parameters, the agent must update:
    1. `job-skill/profile.json`
    2. `job-skill/data/career.sqlite` (`answers` table: current CTC, expected CTC, notice period, total experience)
    3. `AGENTS.md` (Sections 2, 3, 4, 12)

## 16. Operational Enforcement Boundaries & Technical Limitations
- **Markdown Is Policy, Not Technical Enforcement**:
  - Markdown instructions govern agent behavior and execution rules. They do NOT provide operating system-level process sandboxing or network traffic interception.
- **Technical Database Enforcements (SQLite Triggers & Constraints)**:
  - Daily action caps: Enforced by `trg_actions_cap` on the `actions` table.
  - Paused and cooldown states: Enforced by `trg_actions_paused`.
  - Blocklisted entities: Enforced by `trg_jobs_blocked`, `trg_contacts_blocked`, and `trg_leads_blocked`.
  - Closed contacts: Enforced by `trg_msg_closed`.
  - Locked answers: Enforced by `trg_answers_locked` and `trg_answers_nodelete`.
  - Deletion prevention: Enforced by `trg_nodelete_*` triggers across all core tables.
- **Agent-Governed Operational Policies (Non-Database Enforced)**:
  - The following rules rely on the AI agent strictly adhering to Markdown policies:
    1. Pausing between browser actions and introducing natural human jitter.
    2. Enforcing human approval gates before sending messages in `draft` status.
    3. Maintaining dedicated browser tabs and never hijacking existing user tabs.
    4. Reading full historical conversation transcripts before sending replies (Rule 5).
    5. Compiling and presenting the `needs_input` manual application queue at run completion.

## 17. Autonomous Job Search & Career Outreach Strategy Protocol
- **Agent Ownership Principle**:
  - The candidate owns their career truth (`profile.json`), target role priority, compensation boundaries, and explicit approvals.
  - The agent completely owns the execution: which boards to search, what queries to generate, which companies to investigate, which senior decision-makers to approach, and how to adapt search strategy.
  - The agent never asks the user for routine search directions or queries.
- **Autonomous Query Generation Matrix**:
  - Sourced from candidate target roles (DE > DBE > PyE) and technical specializations:
    - *Data Engineering*: `Data Engineer Python PostgreSQL`, `Data Engineer Airflow ETL`, `Data Pipeline Engineer SQL`, `Junior Data Engineer PostgreSQL`.
    - *Database Engineering*: `Database Engineer PostgreSQL`, `PostgreSQL Developer Query Optimization`, `Database Developer PostgreSQL PostGIS`, `SQL Performance Engineer`.
    - *Python Backend*: `Python Backend Developer FastAPI`, `Python Developer ETL Pipelines`, `Backend Engineer Python SQL Docker`.
  - Target Hubs: Hyderabad, Bengaluru, Chennai, Remote, India.
  - Query Rotation: Dynamically alternate queries across boards to maintain high lead velocity and avoid stale search results.
- **Autonomous Referral & Outreach Protocol**:
  - When target companies are identified in job searches, the agent automatically identifies senior engineering managers, lead architects, and recruiters on LinkedIn (`titleFreeText=Senior%20OR%20Lead%20OR%20Manager%20OR%20Director%20OR%20Head%20OR%20Principal`).
  - Outreach messages are generated using candidate facts in `profile.json`, saved as `draft` in `messages`, and submitted to the user for one-click approval.
- **Autonomous Yield Optimization**:
  - If a particular board or query exhibits low yield or exhausted listings, the agent autonomously expands to alternative search permutations and adjacent ATS portals without stopping or asking the user what to search next.

## 18. Execution Concurrency & State Locking Protocol
- **Concurrency Control**:
  - Every autonomous execution task (vacancy discovery, application pipeline, inbox monitor, source evaluation) must check and acquire a lock in `execution_state`:
    ```sql
    UPDATE execution_state 
    SET is_running = 1, locked_at = strftime('%Y-%m-%dT%H:%M:%SZ','now'), locked_by = 'antigravity' 
    WHERE task_name = '<task>' AND is_running = 0;
    ```
  - If 0 rows updated, task is already running; abort to prevent overlapping execution.
- **Recovery from Interrupted Runs**:
  - If a task has `is_running = 1` but `locked_at` is older than 30 minutes, it is classified as crashed or interrupted. The lock is safely reset and recovery checkpoints from `checkpoint_data` are loaded.
- **Global Pause Check**:
  - Tasks check `SELECT value FROM settings WHERE key = 'paused';`. If `'1'`, halt immediately.

## 19. Pure AI Agent Operating Architecture (Zero Script-Based Automation)
- **Zero Script-Driven Intelligence**:
  - Absolutely NO custom JavaScript, Python, or PowerShell scripts for query generation, company discovery, scraping pipelines, vacancy scoring, or decision-making.
  - All strategic search decisions, page comprehension, suitability evaluation, and outreach drafting are made dynamically at runtime by the AI agent using LLM reasoning and native tools.
- **Three-Tier Architecture**:
  1. *Candidate Truth & Directives*: `job-skill/profile.json` (facts, constraints, compensation, notice period), `career-ops/Ajay_Patro_CV.pdf`, and Markdown operational rules.
  2. *The AI Agent (Worker)*: Operates browser tools via Playwright MCP and the native command shell. Uses multimodal/text reasoning to interpret complex web pages and ATS forms.
  3. *Persistent Memory (SQLite)*: `job-skill/data/career.sqlite` tracks all discovered vacancies, investigated companies, evaluated sources, granular application states, and conversation history via native `sqlite3.exe`.
- **Detached Execution Capability**:
  - The AI agent runtime can run interactively within Antigravity or autonomously outside it via the OpenAI Codex CLI (`codex exec` with native Playwright MCP and shell access).
  - Background scheduling triggers the agent CLI directly with operational prompts; no custom script middleman is permitted.

## 20. End-to-End Autonomous Multi-Tier Outreach & Application Loop Protocol ("Gold Standard Loop")
- **Standard Autonomous Execution Cycle**:
  The agent must execute this comprehensive multi-tier loop during every continuous or high-velocity run:
  1. **Tier 1: High-Velocity Direct Applications (50+ Target)**:
     - Uncapped volume targeting **50+ minimum daily applications** across target role hierarchy: **Data Engineer > Database Engineer > Python Developer**.
     - Openly target openings in the authorized **0–6 years experience bracket**.
     - Reserve action via SQLite CLI (`INSERT INTO actions (type, ref_table, ref_id) VALUES ('apply_naukri'|'apply_portal', 'jobs', <id>)`).
     - Submit applications via 1-click apply, interactive questionnaire chatbot answering (using candidate facts in `profile.json` and `answers` table), or portal link follow-through.
     - Record confirmed evidence in `jobs.submission_evidence` (HTTP 200/202 `multiApplyResp`, confirmation URL, reference number) and update `granular_status = 'submission_confirmed'`.
  2. **Tier 2: Social/LinkedIn Hiring Posts Scrape & Recruiter Cold Email Dispatch**:
     - Dynamically search LinkedIn content posts for active recruiter/hiring posts requesting resumes (`"share your resume"`, `"send your resume to"`, email addresses).
     - Extract recruiter contact details, company name, email address, and target role.
     - Reserve action in `actions` (`type = 'email'`) and register in `companies` and `contacts`.
     - Compose ultra-slim cold email strictly adhering to Rule 2 (ZERO emojis, 1-line hook, 2.5+ yrs hands-on PostgreSQL/PostGIS, Airflow ETL, Python backend, consistent signature, NO bulky CTC/Notice blocks).
     - Dispatch via Outlook Webmail on Tab 0:
       - Fill recipient into `div[aria-label="To"]` and click `button:has-text("Use this address: ...")` to resolve the chip and enable the Send button.
       - Fill subject into `input[aria-label="Subject"]`.
       - Fill body into `textarea.dFCbN`.
       - Click `button[aria-label="Attach file"]` and select recent file `Ajay_Patro_CV.pdf` (`button[role="menuitem"]:has-text("Ajay_Patro_CV.pdf") >> nth=0`) to attach without OS file picker modals.
       - Click `button[aria-label="Send"]`, verify dispatch in Sent Items, and update SQLite `messages.status = 'sent'`.
  3. **Tier 3: Senior Decision-Maker & Hiring Manager Outreach (Direct Dispatch)**:
     - Search LinkedIn people using the mandatory `titleFreeText` filter (`&titleFreeText=Senior%20OR%20Lead%20OR%20Manager%20OR%20Director%20OR%20Head%20OR%20Principal`).
     - Target Engineering Managers, Tech Leads, Directors of Engineering, and Talent Acquisition Leads in primary South hubs (Bengaluru, Hyderabad, Chennai).
     - Draft highly personalized connection notes highlighting relevant technical depth and leadership alignment.
     - Dispatch connection requests with personalized notes directly via the browser (reserving `type = 'connect'` in `actions`, navigating to profile, clicking Connect -> Add a note, submitting invitation, and updating `messages.status = 'sent'`).
  4. **Tier 4: Mandatory 100% Prefill for Queued Portal Applications (Rule 11)**:
     - Open any job requiring external authentication, SSO, or candidate review in a dedicated tab (`await context.newPage()`).
     - 100% prefill all candidate fields, contact details, work experience (2.5 years), compensation (₹3.6 LPA / ₹10–13 LPA), notice (30 days), and technical screening essay answers.
     - Keep tab open and present in the End-of-Run report for candidate 1-click submission.
  5. **Tier 5: Evidence-Backed Reporting**:
     - Compile and present the structured End-of-Run report with confirmed applications, sent cold emails, queued connection drafts, and prefilled tabs.


