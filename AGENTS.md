# Project & Agent Operational Rules

## 1. Browser & Automation Rules
- **ALWAYS Open New Tab / Page**: When interacting with the browser via Playwright / CDP, **ALWAYS** call `await context.newPage()` to create a clean, dedicated tab. **NEVER** navigate, reuse, or hijack existing active tabs (such as the user's active browsing tabs). When finished with a task, close the newly opened page if appropriate.
- **Clean Overlays**: Always remove chat overlays / popups using `cleanOverlays()` before attempting clicks.
- **Form Filling & CDP Helper Boundaries**: `cdp_helper.js` is allowed for: opening a tab, waiting for navigation, reading page text or element state. It is never allowed for: setting input values directly, clicking submit buttons, or bypassing form events. All form filling must use `browser_press_key` Tab, `browser_evaluate` only to read `activeElement`, and `browser_press_key` Enter to submit.

## 2. Communication & Messaging Rules
- **ZERO EMOJIS**: NEVER use emojis in any message, cold outreach, LinkedIn note, or email.
- **Messages Priority**: Stage 1 (Inbox Sweep & Replies) is always processed first.
- **Ultra-Slim Email Template**: Recruiter cold emails must be ultra-slim and high-density:
  - 1-line hook/context.
  - Quick overview of relevant experience (specifically highlight 3+ years hands-on experience in PostgreSQL & PostGIS, spatial schemas, GiST indexing, query optimization, and Python backend ETL).
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

## 7. Hard Reject Roles & Discovery Protocol
- **Hard Reject List**: Land Surveyor, Drone Pilot, Surveyor, SDET, QA, Chaos Engineer, Frontend, PHP, Mainframe, Machine Learning Engineer, Data Scientist, DevOps Engineer, Cloud Engineer, QA Engineer, Test Engineer, and anything unrelated. Skip immediately with `skip_reason = 'hard_reject'`. Never shortlist these roles.
- **Guardian Record Boundary (H18)**: The `guardian record` command must be called once per job page actually visited and read in the browser. Never create a script that records multiple jobs at once. If you need to record 20 jobs, visit 20 pages and call `guardian record` 20 times.

## 8. Seniority & LinkedIn Connect Search Filter Protocol
- **Mandatory `titleFreeText` Search Parameter**: For all connect searches on LinkedIn, ALWAYS include the `titleFreeText` filter in the search URL to restrict results to senior level people.
  - Example parameter: `&titleFreeText=Senior%20OR%20Lead%20OR%20Manager%20OR%20Director%20OR%20Head%20OR%20Principal`
  - **Hard Gate**: NEVER search for connections without this filter.

## 9. Mandatory End-of-Run Manual Applications Reporting Protocol
- **Explicit Manual Apply Queue**: After every single run or session, the agent MUST output a dedicated, clear report of all jobs that require manual application (`status = 'needs_input'`).
- **Required Details per Job**:
  - Job ID
  - Job Title
  - Company Name
  - Direct Application / Portal URL (direct ATS or external link, not generic aggregator)
  - Exact Blocker / Reason (e.g. requires candidate account login/SSO, visual CAPTCHA, complex candidate-specific screening questions like family background/marital status/personal essays)
- **Hard Gate**: Never finish a run without presenting this actionable manual application list so the candidate can immediately click and submit them manually.

## 11. Queued Job Opening & Prefill Protocol
- **Dedicated Tab per Queued Role**: For jobs in the manual application queue (`status = 'needs_input'`), open a dedicated browser tab (`await context.newPage()`) for each actionable job application URL.
- **Maximum Autonomous Prefill**: Wherever an external portal or ATS (such as Keka, Lever, Greenhouse, SmartRecruiters, or public web forms) permits input before authentication, autofill and prefill all candidate data (Full Name: Ajay Kumar Patro, Email: ajay789patro@outlook.com, Phone: +91-7894464335, Location: Nashik / India, LinkedIn URL, Experience, and attach `Ajay_Patro_CV.pdf`).
- **Actionable User Hand-Off**: For portals requiring candidate registration or SSO (e.g., Workday, Oracle Cloud HCM, iCIMS), navigate directly to the application sign-in / registration screen so the user can immediately log in and complete submission without searching for links.



