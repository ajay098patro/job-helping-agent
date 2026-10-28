# Boards

For every board: confirm you are logged in before work. A login page or wall means stop and ask the user (H2). Use the accessibility snapshot, not pixels. Add every lesson to `notes` with the board name as `scope`, and read that board's notes at the start of the run.

## Naukri (naukri.com)
- Works well today. Run first when testing.
- Logged in: your name or profile avatar is visible in the header.
- Search by target role, experience 3 years, India and remote. Jobs marked "Applied" are skipped.
- "Apply" may complete at once, open a drawer with questions, or send you to the company site (then use the company-portal route).
- Questions may appear in a chat-style drawer. Answer through the same `answers` flow.

## LinkedIn (linkedin.com)
- Used for Easy Apply jobs, people search, connections and messaging. Highest account risk: respect caps and H3 strictly.
- Easy Apply opens a multi-step modal. Read the step counter, fill each step, review, submit, then confirm the "application sent" state.
- Skip jobs that only offer an external "Apply" unless the company-portal route is wanted.
- Messaging: use the message drawer or the messaging page. Confirm each sent message appears in the thread.

## Instahyre (instahyre.com)
- First-Class Application Board for Python Backend, PostGIS, Data Engineering, and Geospatial roles.
- Search entry points: `https://www.instahyre.com/python-jobs/`, `/python-jobs-in-bangalore/`, `/python-jobs-in-hyderabad/`, and candidate matching feed (`/candidate/opportunities/`).
- Verified candidate profile: 88%+ complete with preloaded resume, CTC details (₹3.6 LPA current, ₹11-15 LPA expected), 30 days notice, and key skills (Python, PostGIS, FastAPI, PostgreSQL, GeoServer).
- Application Flow: Click "Apply now" (`button.btn-filled` or job card apply trigger). Ingest as `apply_route = 'instahyre'`, record `actions` with type `apply_instahyre` against daily cap (100).
- Activity Verification: Track status and applied openings at `https://www.instahyre.com/candidate/activity/`.

## Google Jobs (google.com)
- First-Class Application Board with automated 2-tier link extraction and dispatch.
- Direct DocID Architecture: Extract `data-share-url` (`htidocid`) from search cards on `https://www.google.com/search?q=<query>&udm=8` or `https://www.google.com/search?ibp=htl;jobs`. Direct navigation to the docid viewer avoids background animation throttling and reveals all "Apply on..." links.
- Application Link Hierarchy:
  - **1st Class (Direct Company Portal / ATS):** Direct company career websites and enterprise ATS platforms (Greenhouse, Lever, Workday, SmartRecruiters, Ashby, Taleo, SAP SuccessFactors, Darwinbox, Oracle HCM).
    - Route: `apply_route = 'company_portal'`.
    - Priority: ALWAYS prioritize 1st Class links first. Navigate to the company portal, inspect form requirements, autofill verified candidate truth, attach CV from `cv/`, and complete submission.
  - **2nd Class (Aggregators & Partner Boards):** Aggregators like Naukri, LinkedIn, Instahyre, Indeed.
    - Route: When no 1st Class link exists, fall back immediately to 2nd Class links and dispatch through the matching native application route (`apply_naukri`, `apply_linkedin`, `apply_instahyre`).
- Non-Aggregator Rule: Never skip or treat Google Jobs as passive search; actively ingest and execute applications for matching roles (fit >= 60).

## GIS Careers India (giscareers.in)
- Proven specialized niche board for Indian geospatial/GIS engineering roles.
- Direct employer postings (e.g. Geoconsultants, Geosys Enterprise Solutions, IORA).
- Account creation via mobile/email. Logged in dashboard at `https://giscareers.in/Employee`.
- One-click application flow via `button.btn.btn-primary` ("Login & Apply") after profile and CV are uploaded.
- Verified live: Job 2, Job 4, and Job 20 applied and confirmed in dashboard.

## Dynamic Board Discovery & Proof Protocol
- Never remain locked into stale boards if they dry up. Actively discover fresh, specialized sources (e.g. Cutshort, GeoJobs, direct enterprise ATS pages like Esri, RMSI, Hexagon, MapmyIndia).
- Proof Gate: Before adding or moving to a new board, verify three proofs:
  1. Genuine, active postings with verifiable post dates and hiring companies.
  2. Direct, legitimate application path without spammy aggregator redirects or paywalls.
  3. Domain authority and reputation.
- Record every verified board in `boards.md` and log lessons to the `notes` table in `career.sqlite`.

## Company portals
- Greenhouse and Lever usually need no account. Workday and many custom portals need an account: ask the user first and skip the job if they say no (H10).
- Fill from the answers flow. Upload the job's CV from `cv/out/`.

## Webmail (for recruiter emails)
- The account comes from `settings.mail_account`. If empty, ask the user.
- Compose, attach, then check that the attachment chip with the exact filename is visible before sending. After sending, find the message in the Sent folder. Only then mark it sent.

## Uploading a file
1. In the active form, locate the file upload button or input using `browser_snapshot`.
2. Click the upload button or file input using `browser_click` with `target: "<selector_or_ref>"` to activate the file chooser modal state.
3. Call `browser_file_upload` with `paths: ["<path>"]`. The browser tool runs with its working directory at `c:/job-search/job-skill/cv` (without `--allow-unrestricted-file-access`), so any files outside `cv/` and `_pw-output` (including `career.sqlite` and `profile.json`) are strictly denied by the server's root sandbox. Only upload files under `cv/` (`cv/out/` or `cv/Ajay_Patro_CV.pdf`) per rule H14.
4. Take a `browser_snapshot` immediately to confirm the filename appears attached and no upload errors are visible.

## Form Filling & CDP Helper Automation Rule
cdp_helper.js is allowed for: opening a tab, waiting for navigation, reading page text or element state. It is never allowed for: setting input values directly, clicking submit buttons, or bypassing form events. All form filling must use browser_press_key Tab, browser_evaluate only to read activeElement, and browser_press_key Enter to submit.

