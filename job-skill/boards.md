# Boards & Dynamic Source Discovery

For every board: confirm you are logged in before work. A login page or wall means stop and ask the user (H2). Use the accessibility snapshot, not pixels. Add every lesson to `notes` with the board name as `scope`, and read that board's notes at the start of the run.

## 1. Dynamic Job-Source Discovery Engine

The agent does not rely solely on a hardcoded list of job boards. It dynamically discovers, evaluates, categorizes, and tracks recruitment sources relevant to Ajay Kumar Patro's candidate profile (Data Engineer > Database Engineer > Python Developer, 2.5 yrs exp, PostgreSQL/PostGIS, Airflow, FastAPI).

### 5-Factor Source Evaluation Model
Each newly discovered source is tracked in the `sources` table and evaluated along five distinct dimensions (0-100):
1. **Relevance (Weight: 25%)**: Alignment with candidate role hierarchy (Data Engineering, PostgreSQL Database Engineering, Python Backend) and target locations (Hyderabad, Bengaluru, Chennai, Remote).
2. **Freshness (Weight: 20%)**: Percentage of listings posted within the last 7-14 days; absence of stale/expired job postings.
3. **Accessibility (Weight: 20%)**: Ease of ingestion and application (clean forms, transparent ATS, absence of hostile bot walls or paywalls).
4. **Uniqueness (Weight: 15%)**: Ratio of exclusive/direct postings vs. redundant syndicated listings aggregated from other boards.
5. **Listing Quality (Weight: 20%)**: Completeness of job descriptions (salary bands, clear tech stack, exact experience brackets, direct company identity).

**Composite Score Formula:**
$$\text{Composite} = 0.25 \times \text{Relevance} + 0.20 \times \text{Freshness} + 0.20 \times \text{Accessibility} + 0.15 \times \text{Uniqueness} + 0.20 \times \text{Quality}$$

### Source Lifecycle States
- `evaluating`: Source discovered; undergoing automated inspection and initial test scraping.
- `active`: Verified source with composite score >= 70; included in regular discovery cycles.
- `promoted`: Top-tier source with composite score >= 85 and high conversion/interview yield; prioritized first.
- `deprioritized`: Composite score < 70 or high frequency of stale/mismatched listings (e.g. `getmereferred.com`); excluded from active discovery or restricted.
- `deprecated`: Defunct, paywalled, or permanently blocked source.

### Re-evaluation Cadence
Sources are re-evaluated every 14 days or immediately following an audit failure (such as misrepresenting experience brackets or aggregators pretending to be direct ATS portals).

---

## 2. Core Sourced Platforms

### Naukri (naukri.com) — [Promoted, Composite: 90]
- **Role in Engine**: Primary high-volume Indian tech portal for Data Engineering, Python Backend, and Geospatial systems.
- **Search Parameters**: Target roles (Data Engineer, Database Engineer, Python Developer), 2-3 years experience, Hyderabad / Bengaluru / Chennai / Remote.
- **Application Execution**: Process matching openings. For 1-click apply, verify submission. For redirect links, resolve company ATS.
- **Logging**: Record `apply_naukri` in `actions` against daily cap (30/day).

### LinkedIn (linkedin.com) — [Active / Manual Queue, Composite: 88]
- **Role in Engine**: High-signal senior listings, target company discovery, and direct decision-maker identification.
- **Safety Policy (Strict Manual-Queue Boundary)**: To prevent account restrictions, automated clicking of connection requests and messaging is prohibited.
- **Workflow**:
  - Search senior leaders (`&titleFreeText=Senior%20OR%20Lead%20OR%20Manager%20OR%20Director%20OR%20Head%20OR%20Principal`).
  - Queue contacts in `contacts` table (`stage = 'discovered'`).
  - Draft personalized outreach in `messages` table (`status = 'draft'`).
  - Present drafted connections and messages in the End-of-Run report for candidate one-click manual execution.
  - Read-only inbox polling tracks manual responses.

### Instahyre (instahyre.com) — [Active, Composite: 83]
- **Role in Engine**: Premium curated Indian tech opportunities for Python backend, PostgreSQL, and Data Engineering.
- **Entry Points**: `/python-jobs/`, `/python-jobs-in-bangalore/`, `/python-jobs-in-hyderabad/`, `/candidate/opportunities/`.
- **Candidate Profile**: 88%+ complete, 30 days notice period, verified CTC truth.
- **Application Flow**: 1-click apply with verified candidate profile. Log `apply_instahyre` action.

### Google Jobs (google.com/jobs) — [Active, Composite: 82]
- **Role in Engine**: Direct ATS discovery engine using `htidocid` link resolution.
- **Strict Direct Portal Rule**: Prioritize 1st-class direct company ATS links (Greenhouse, Lever, Workday, SmartRecruiters, Ashby, Taleo).
- **Aggregator Filter**: Strip out secondary repost aggregators (GetMeReferred, Jooble, Neuvoo) unless they point directly to the verifiable hiring company portal.

### Cutshort (cutshort.io) — [Active, Composite: 85]
- **Role in Engine**: Modern tech recruitment portal widely used by Indian product firms and VC-funded startups for backend and data engineering roles.
- **Workflow**: Keyword searches on `Data Engineer`, `Python PostgreSQL`, `FastAPI`. Match candidate salary expectations (₹10–13 LPA).

### Wellfound (wellfound.com) — [Active, Composite: 82]
- **Role in Engine**: Specialized platform for funded startups and remote engineering teams. Excellent for high-ownership Python/ETL roles.

### Hirist (hirist.tech) — [Active, Composite: 81]
- **Role in Engine**: Specialized tech hiring platform across India focusing on database engineering, analytics infrastructure, and backend services.

### GIS Careers India (giscareers.in) — [Active / Specialized Niche, Composite: 80]
- **Role in Engine**: Verified niche portal for Indian geospatial and GIS engineering roles. Direct employer postings (e.g. Geoconsultants, Geosys Enterprise Solutions).
- **Application Path**: Verified one-click apply via logged-in candidate dashboard.

### GetMeReferred (getmereferred.com) — [Deprioritized, Composite: 57]
- **Audit Finding**: Flagged during Tekion Job ID 310 audit. Frequently syndicates outdated listings with inflated senior experience brackets (5–8 yrs) without direct ATS links. Deprioritized from autonomous search.

---

## 3. Direct Company Portals & ATS Handling

- **Greenhouse & Lever**: Direct public ATS. Maximum autonomous prefill permitted before submission.
- **Workday, Oracle HCM, Taleo**: Require user account creation/SSO. Navigate directly to the sign-in/registration screen, fill available public fields, and queue as `awaiting_user_info` for manual candidate submission.
- **Keka & SmartRecruiters**: Prefill verified candidate details (Ajay Kumar Patro, ajay789patro@outlook.com, +91-7894464335, attach `Ajay_Patro_CV.pdf`).

## 4. File Upload Protocol
1. Locate file input or trigger button via `browser_snapshot`.
2. Click trigger via `browser_click`.
3. Dispatch `browser_file_upload` with `paths: ["C:/job-search/career-ops/Ajay_Patro_CV.pdf"]` or `cv/Ajay_Patro_CV.pdf`.
4. Immediately take `browser_snapshot` to confirm attachment success and absence of form validation errors.
