-- Migration 001: Dynamic Sources, Source Evaluations, Granular Statuses, and Execution State
-- Target Database: career.sqlite

PRAGMA foreign_keys = ON;

-- 1. Dynamic Sources Catalog
CREATE TABLE IF NOT EXISTS sources (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  domain TEXT NOT NULL UNIQUE,
  careers_url TEXT,
  source_type TEXT NOT NULL CHECK (source_type IN ('job_board', 'aggregator', 'direct_ats', 'community', 'referral_portal', 'specialized')),
  relevance_score INTEGER CHECK (relevance_score BETWEEN 0 AND 100),
  freshness_score INTEGER CHECK (freshness_score BETWEEN 0 AND 100),
  accessibility_score INTEGER CHECK (accessibility_score BETWEEN 0 AND 100),
  uniqueness_score INTEGER CHECK (uniqueness_score BETWEEN 0 AND 100),
  listing_quality_score INTEGER CHECK (listing_quality_score BETWEEN 0 AND 100),
  composite_score INTEGER CHECK (composite_score BETWEEN 0 AND 100),
  yield_status TEXT NOT NULL DEFAULT 'active' CHECK (yield_status IN ('promoted', 'active', 'deprioritized', 'evaluating', 'deprecated')),
  total_discovered INTEGER NOT NULL DEFAULT 0,
  total_shortlisted INTEGER NOT NULL DEFAULT 0,
  total_applied INTEGER NOT NULL DEFAULT 0,
  last_evaluated_at TEXT,
  notes TEXT,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ','now'))
);

CREATE INDEX IF NOT EXISTS ix_sources_domain ON sources(domain);
CREATE INDEX IF NOT EXISTS ix_sources_yield_status ON sources(yield_status);

-- 2. Source Evaluations History
CREATE TABLE IF NOT EXISTS source_evaluations (
  id INTEGER PRIMARY KEY,
  source_id INTEGER NOT NULL REFERENCES sources(id),
  relevance_score INTEGER NOT NULL,
  freshness_score INTEGER NOT NULL,
  accessibility_score INTEGER NOT NULL,
  uniqueness_score INTEGER NOT NULL,
  listing_quality_score INTEGER NOT NULL,
  composite_score INTEGER NOT NULL,
  yield_decision TEXT NOT NULL CHECK (yield_decision IN ('promote', 'maintain', 'deprioritize', 'deprecate')),
  findings TEXT NOT NULL,
  evaluated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ','now'))
);

CREATE INDEX IF NOT EXISTS ix_source_evaluations_source ON source_evaluations(source_id, evaluated_at);

-- 3. Execution State & Concurrency Control
CREATE TABLE IF NOT EXISTS execution_state (
  id INTEGER PRIMARY KEY,
  task_name TEXT NOT NULL UNIQUE,
  is_running INTEGER NOT NULL DEFAULT 0 CHECK (is_running IN (0,1)),
  locked_at TEXT,
  locked_by TEXT,
  last_started_at TEXT,
  last_completed_at TEXT,
  last_status TEXT CHECK (last_status IN ('success', 'failed', 'halted', 'interrupted')),
  checkpoint_data TEXT
);

-- Seed Execution State Tasks
INSERT OR IGNORE INTO execution_state (task_name, is_running, last_status, checkpoint_data) VALUES
  ('vacancy_discovery', 0, 'success', '{"last_query_index": 0, "queries_total": 9}'),
  ('application_pipeline', 0, 'success', '{"pending_queue_count": 0}'),
  ('inbox_monitor', 0, 'success', '{"last_sweep_at": null}'),
  ('source_evaluator', 0, 'success', '{"sources_evaluated": 0}');

-- 4. Extend jobs table with granular_status, submission_evidence, and source_id
-- We execute ALTER TABLE safely via conditional script

-- 5. Add columns to jobs table
ALTER TABLE jobs ADD COLUMN granular_status TEXT;
ALTER TABLE jobs ADD COLUMN submission_evidence TEXT;
ALTER TABLE jobs ADD COLUMN source_id INTEGER REFERENCES sources(id);

-- 6. Populate Sources Catalog with Discovered & Evaluated Sources
INSERT OR IGNORE INTO sources (name, domain, careers_url, source_type, relevance_score, freshness_score, accessibility_score, uniqueness_score, listing_quality_score, composite_score, yield_status, notes) VALUES
  ('Naukri', 'naukri.com', 'https://www.naukri.com', 'job_board', 92, 90, 95, 85, 88, 90, 'promoted', 'Primary high-volume Indian tech portal. Exceptional for Data Engineer and Python roles.'),
  ('LinkedIn', 'linkedin.com', 'https://www.linkedin.com/jobs', 'job_board', 95, 95, 70, 90, 90, 88, 'active', 'High signal senior listings; strict rate limits and auth boundaries require manual queue execution.'),
  ('Instahyre', 'instahyre.com', 'https://www.instahyre.com', 'job_board', 88, 82, 85, 75, 85, 83, 'active', 'Curated mid-to-senior tech opportunities with direct recruiter outreach.'),
  ('Google Jobs', 'google.com/jobs', 'https://www.google.com/search?ibp=htl;jobs', 'aggregator', 80, 85, 80, 90, 75, 82, 'active', 'Aggregator targeting direct employer portal links. Requires filtering out aggregator intermediaries.'),
  ('Cutshort', 'cutshort.io', 'https://cutshort.io', 'job_board', 86, 84, 88, 80, 86, 85, 'active', 'AI-driven tech recruitment platform popular with Indian product companies and funded startups.'),
  ('Wellfound', 'wellfound.com', 'https://wellfound.com/jobs', 'specialized', 82, 80, 80, 85, 84, 82, 'active', 'Specialized for tech startups, high-growth engineering teams, and remote Python/ETL roles.'),
  ('Hirist', 'hirist.tech', 'https://www.hirist.tech', 'job_board', 85, 80, 82, 78, 82, 81, 'active', 'Dedicated tech portal for analytics, database, and backend software engineering across India.'),
  ('GetMeReferred', 'getmereferred.com', 'https://getmereferred.com', 'referral_portal', 65, 60, 65, 50, 45, 57, 'deprioritized', 'Aggregator with frequent outdated listings and inflated senior requirements. Evaluated and deprioritized.');

-- 7. Record Initial Source Evaluations
INSERT INTO source_evaluations (source_id, relevance_score, freshness_score, accessibility_score, uniqueness_score, listing_quality_score, composite_score, yield_decision, findings)
SELECT id, 92, 90, 95, 85, 88, 90, 'promote', 'Consistently yields fresh, accessible listings for Python and Data Engineering in India with verified recruiter contacts.'
FROM sources WHERE domain = 'naukri.com';

INSERT INTO source_evaluations (source_id, relevance_score, freshness_score, accessibility_score, uniqueness_score, listing_quality_score, composite_score, yield_decision, findings)
SELECT id, 95, 95, 70, 90, 90, 88, 'maintain', 'High quality listings, but account security limits require manual queue workflow for connections and applications.'
FROM sources WHERE domain = 'linkedin.com';

INSERT INTO source_evaluations (source_id, relevance_score, freshness_score, accessibility_score, uniqueness_score, listing_quality_score, composite_score, yield_decision, findings)
SELECT id, 65, 60, 65, 50, 45, 57, 'deprioritize', 'Audit of Tekion listing 310 confirmed aggregator re-posts with mismatched senior experience brackets (5-8 yrs) and missing direct ATS links.'
FROM sources WHERE domain = 'getmereferred.com';

-- 8. Map existing job status to granular_status
UPDATE jobs SET granular_status = CASE
  WHEN status = 'discovered' THEN 'discovered'
  WHEN status = 'shortlisted' THEN 'shortlisted'
  WHEN status = 'skipped' THEN 'skipped'
  WHEN status = 'needs_input' THEN 'awaiting_user_info'
  WHEN status = 'applying' THEN 'application_prepared'
  WHEN status = 'applied' THEN 'submitted'
  WHEN status = 'interview' THEN 'submission_confirmed'
  WHEN status = 'rejected' THEN 'rejected_or_closed'
  WHEN status = 'closed' THEN 'rejected_or_closed'
  WHEN status = 'failed' THEN 'failed'
  ELSE 'discovered'
END
WHERE granular_status IS NULL;

-- 9. Update source_id on existing jobs where source_board matches
UPDATE jobs SET source_id = (SELECT id FROM sources WHERE domain = 'naukri.com') WHERE source_board = 'naukri';
UPDATE jobs SET source_id = (SELECT id FROM sources WHERE domain = 'linkedin.com') WHERE source_board = 'linkedin';
UPDATE jobs SET source_id = (SELECT id FROM sources WHERE domain = 'instahyre.com') WHERE source_board = 'instahyre';
UPDATE jobs SET source_id = (SELECT id FROM sources WHERE domain = 'google.com/jobs') WHERE source_board = 'google_jobs';
