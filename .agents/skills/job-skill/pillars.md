# Pillars of the Autonomous Career Engine

Always run the start-up checklist in `SKILL.md` first. All hard rules apply. All dates in the database are UTC; format in IST when reporting to the user.

---

## 1. Connect & Referral Sourcing (LinkedIn Compliance & Manual-Queue Architecture)

1. **Autonomous People & Referral Sourcing**:
   - The agent independently discovers hiring managers, engineering directors, and talent leads without requiring user prompt.
   - Sourcing targets 2nd-degree senior decision-makers in India or Remote matching keywords: `Data Engineer`, `Database Engineer`, `PostgreSQL`, `Python backend`, `ETL`, `Geospatial`.
   - **Mandatory Seniority Filter**: ALWAYS include the `titleFreeText` filter in the search URL:
     `&titleFreeText=Senior%20OR%20Lead%20OR%20Manager%20OR%20Director%20OR%20Head%20OR%20Principal`
   - Target company priority: Companies in `companies` catalog (lowest `priority` first), followed by independently discovered engineering firms.

2. **Seniority & Role Hard Gate**:
   - ONLY connect with contacts meeting at least one criterion:
     - Leadership titles: Lead, Senior, Staff, Principal, Head, Director, Manager, VP, President, Founder, CTO, Architect, Engineering Manager.
     - Recruiter / Talent Acquisition Specialist at a target tech company.
     - Senior technical specialist (5+ years demonstrable experience) at a target company.
   - NEVER connect with: Interns, freshers, junior analysts, trainees, associates with < 2 years experience, or peers at the candidate's level.

3. **LinkedIn Safety & Anti-Scraping Compliance**:
   - Automated clicking of LinkedIn connection buttons and automated message dispatch via browser DOM is strictly PROHIBITED to protect the candidate's account.
   - Sourcing is conducted via standard accessible page reads.
   - Deduplication: Normalise profile URL. Skip if exists in `contacts`, matches `blocklist`, or matches candidate's current employer in `profile.json`.

4. **Action Reservation & Draft Queue**:
   - Reserve action: `INSERT INTO actions (type, ref_table, ref_id) VALUES ('connect', 'contacts', <contact_id>)`.
   - Record contact in `contacts` table (`stage = 'discovered'`, with name, headline, company, location, `in_india`).
   - Generate tailored, professional connection note (max 300 chars, ZERO emojis, highlighting 2.5 yrs PostgreSQL, Airflow, and Python ETL experience).
   - Insert into `messages` (`kind = 'connect_note'`, `status = 'draft'`).
   - Queue action as `awaiting_authorization` and present in the End-of-Run report for candidate one-click manual submission.

---

## 2. First Message (Outreach Execution)

1. **Target Selection**:
   - Select contacts with `stage = 'connected'` that have no outbound message of kind `first`.
2. **Transcript Verification**:
   - Inspect thread history. If an earlier message from candidate exists, record in `messages`, set `stage = 'approached'`, and do NOT duplicate.
3. **High-Density Personalization**:
   - Review contact's profile summary and engineering focus.
   - Compose outreach using candidate truth from `profile.json`:
     - 1-line hook/context.
     - Core technical evidence: 2.5+ years experience in PostgreSQL, PostGIS spatial indexing, Airflow ETL pipelines, FastAPI.
     - Zero emojis.
     - Standard signature.
4. **Queue & Approval**:
   - Save in `messages` (`kind = 'first'`, `status = 'draft'`).
   - Present to user for approval or queue for manual dispatch.
   - Once confirmed sent by candidate or verified in thread sweep, set `status = 'sent'`, `stage = 'approached'`, `last_outbound_at = strftime('%Y-%m-%dT%H:%M:%SZ','now')`.

---

## 3. Inbox Sweep, Replies & Historical Rest Gate

1. **Inbox Sweep**:
   - Open LinkedIn messaging via Playwright MCP.
   - Enumerate conversations where the latest message is from the contact (inbound). Never reply if the latest message is candidate's.
2. **Mandatory Full Transcript Inspection**:
   - Read entire historical conversation transcript from Turn 1 to the end.
   - Store new inbound messages in `messages` (`status = 'received'`). Update `contacts.last_inbound_at`.
3. **The Self-Questioning Gate ("Do we REALLY need to message them?")**:
   - If the contact's latest message is a reaction, acknowledgment, or conversational closure (*"Thanks"*, *"Sure"*, *"Noted"*, *"Ok"*, *"All the best"*, *"I will get back to you"*), the conversation is **AT REST**.
   - **NEVER SEND A MESSAGE TO A CONVERSATION AT REST.**
4. **Actionable Classification**:
   - Outbound reply is ONLY permitted if contact asks an explicit, unanswered question (CTC, notice period, technical experience, CV request).
   - If contact requests CV and `Ajay_Patro_CV.pdf` was NOT previously sent in the thread, attach `career-ops/Ajay_Patro_CV.pdf`. Never re-send if already provided.
   - Draft replies with `status = 'draft'` for candidate approval.

---

## 4. Discover (Dynamic Job Discovery & Scoring)

1. **Autonomous Source Navigation**:
   - Rotate across active platforms in `sources` catalog: Naukri (promoted), Instahyre, Google Jobs (direct ATS resolver), Cutshort, Wellfound, Hirist, and verified specialized boards.
   - Dynamically generate queries from candidate target roles:
     - Data Engineering: `Data Engineer Python PostgreSQL`, `Data Engineer Airflow ETL`, `Data Pipeline Engineer SQL`.
     - Database Engineering: `Database Engineer PostgreSQL`, `PostgreSQL Developer Query Optimization`, `SQL Performance Engineer`.
     - Python Backend: `Python Backend Developer FastAPI`, `Python Developer ETL Pipelines`.
   - Hubs: Hyderabad, Bengaluru, Chennai, Remote, India.

2. **Independent Company Discovery**:
   - Discover target product engineering companies building high-scale data pipelines, geospatial intelligence, and database infrastructure independently of job postings.
   - Inspect official company career domains (`companies.careers_url`), identify ATS provider, and store in `companies`.

3. **Canonical Deduplication & Qualification Gate**:
   - Compute `dedupe_key`: `company_key|title_key|clean_url`.
   - Check `blocklist`.
   - **Hard Reject Filter**: Skip immediately with `skip_reason = 'hard_reject'` for: Land Surveyor, Drone Pilot, Surveyor, SDET, QA, Chaos Engineer, Frontend, PHP, Mainframe, Machine Learning Engineer, Data Scientist, DevOps Engineer, Cloud Engineer, QA Engineer, Test Engineer.
   - **Experience Verification Gate**:
     - Candidate truth: **2.5 Years Experience**.
     - If the vacancy explicitly requires > 3 years (e.g. 5–8 years, Senior Lead, Principal), score fit <= 30 and mark `status = 'skipped'`, `granular_status = 'skipped'`, `skip_reason = 'experience_mismatch'`.
     - Never shortlist or apply to roles requiring 5+ years of experience.
   - **Fit Scoring (0–100)**:
     - 60–100: Mark `status = 'shortlisted'`, `granular_status = 'shortlisted'`.
     - < 60: Mark `status = 'skipped'`, `granular_status = 'skipped'` with explicit `skip_reason`.

4. **Application Route Assignment**:
   - `company_portal`: Direct ATS link (Greenhouse, Lever, Workday, SmartRecruiters, Taleo). Highest priority.
   - `apply_naukri`: High-volume Indian tech/database postings.
   - `apply_instahyre`: Curated product company matching feed.
   - `apply_linkedin`: Queued for manual candidate Easy Apply.

---

## 5. Apply (Granular Lifecycle & Evidentiary Standard)

1. **Granular Lifecycle States**:
   - `discovered`: Ingested and deduplicated.
   - `shortlisted`: Fit score >= 60; qualified for candidate.
   - `application_prepared`: Form autofilled and CV attached; ready for submission.
   - `awaiting_user_info`: Blocked by CAPTCHA, complex custom essays, or candidate SSO login.
   - `awaiting_authorization`: Queued for manual candidate click/approval (LinkedIn Easy Apply, restricted ATS).
   - `submitted`: Application submitted or 1-click apply executed; awaiting receipt proof.
   - `submission_confirmed`: Verified proof of receipt (portal confirmation screen, confirmation ID, email notification, or dashboard status).
   - `rejected_or_closed`: Application rejected or posting unlisted.
   - `failed`: Technical submission error (timeout, network drop).

2. **Evidentiary Standard for `submission_confirmed`**:
   - A job MAY NOT be marked `submission_confirmed` unless at least one verifiable proof exists:
     1. Portal confirmation message detected (e.g. *"Application submitted successfully"*, *"Thank you for applying"*).
     2. Unique Application Reference ID captured.
     3. Listing appears under *"Applied Jobs"* in candidate portal dashboard (e.g. Naukri Applied tab, GISCareers dashboard).
   - Store exact confirmation proof in `submission_evidence`.

3. **Autonomous Form Prefill**:
   - Full Name: Ajay Kumar Patro
   - Email: ajay789patro@outlook.com
   - Phone: +91-7894464335
   - Current CTC: ₹3.6 LPA
   - Expected CTC: ₹10–13 LPA
   - Notice Period: 30 days
   - Total Experience: 2.5 Years
   - CV Attachment: `career-ops/Ajay_Patro_CV.pdf` (or tailored CV from `cv/`).

4. **Manual Apply Queue Handoff**:
   - When an application encounters authentication gates (Workday, Oracle HCM, Taleo) or visual CAPTCHA:
     - Open dedicated tab (`await context.newPage()`).
     - Navigate directly to application sign-in/form screen.
     - Prefill all public fields.
     - Set `status = 'needs_input'`, `granular_status = 'awaiting_user_info'`.
     - Present actionable handoff URL and blocker description in the End-of-Run report.
