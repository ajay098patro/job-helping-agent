PRAGMA journal_mode = WAL;
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS settings (key TEXT PRIMARY KEY, value TEXT NOT NULL);
INSERT OR IGNORE INTO settings(key, value) VALUES
 ('paused','0'), ('cooldown_until',''), ('approval_mode','all'),
 ('fit_threshold','60'), ('apply_outside_india','0'), ('mail_account',''),
 ('cap_connect','200'), ('cap_message','200'), ('cap_apply_naukri','9999'),
 ('cap_apply_linkedin','9999'), ('cap_apply_instahyre','9999'),
 ('cap_apply_portal','9999'), ('cap_email','40');

CREATE TABLE IF NOT EXISTS companies (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  name_key TEXT NOT NULL UNIQUE,
  careers_url TEXT,
  careers_domain TEXT,
  hiring_system TEXT,
  country TEXT,
  priority INTEGER NOT NULL DEFAULT 3 CHECK (priority BETWEEN 1 AND 5),
  link_checked_at TEXT,
  active INTEGER NOT NULL DEFAULT 1 CHECK (active IN (0,1)),
  notes TEXT
);

CREATE TABLE IF NOT EXISTS jobs (
  id INTEGER PRIMARY KEY,
  company_id INTEGER REFERENCES companies(id),
  company_name TEXT NOT NULL,
  company_key TEXT NOT NULL,
  title TEXT NOT NULL,
  dedupe_key TEXT NOT NULL UNIQUE,
  location TEXT,
  remote INTEGER NOT NULL DEFAULT 0 CHECK (remote IN (0,1)),
  source_board TEXT NOT NULL CHECK (source_board IN ('naukri','linkedin','instahyre','google_jobs','company_portal')),
  apply_route TEXT CHECK (apply_route IN ('naukri','linkedin','instahyre','company_portal')),
  apply_url TEXT,
  fit_score INTEGER CHECK (fit_score BETWEEN 0 AND 100),
  fit_reason TEXT,
  status TEXT NOT NULL DEFAULT 'discovered' CHECK (status IN ('discovered','shortlisted','skipped','applying','applied','needs_input','failed','interview','rejected','closed')),
  skip_reason TEXT,
  cv_file TEXT,
  discovered_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ','now')),
  applied_at TEXT,
  last_checked_at TEXT
);

CREATE TABLE IF NOT EXISTS contacts (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  first_name TEXT,
  profile_url TEXT NOT NULL UNIQUE,
  company_id INTEGER REFERENCES companies(id),
  company_name TEXT,
  company_key TEXT,
  headline TEXT,
  location TEXT,
  in_india INTEGER CHECK (in_india IN (0,1)),
  stage TEXT NOT NULL DEFAULT 'discovered' CHECK (stage IN ('discovered','requested','connected','approached','careers_redirect','second_ask_sent','agreed_to_refer','links_sent','referred','closed')),
  closed_reason TEXT,
  research_notes TEXT,
  connected_at TEXT,
  last_inbound_at TEXT,
  last_outbound_at TEXT,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ','now'))
);

CREATE TABLE IF NOT EXISTS messages (
  id INTEGER PRIMARY KEY,
  contact_id INTEGER NOT NULL REFERENCES contacts(id),
  direction TEXT NOT NULL CHECK (direction IN ('inbound','outbound')),
  kind TEXT NOT NULL CHECK (kind IN ('connect_note','first','second_ask','third_links','reply','follow_up','other')),
  body TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('draft','approved','pending','sent','failed','cancelled','received')),
  cv_file TEXT,
  cv_attached INTEGER DEFAULT 0 CHECK (cv_attached IN (0,1)),
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ','now')),
  sent_at TEXT
);

CREATE TABLE IF NOT EXISTS leads (
  id INTEGER PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  recruiter_name TEXT,
  company_name TEXT,
  source_url TEXT,
  post_snippet TEXT,
  job_id INTEGER REFERENCES jobs(id),
  status TEXT NOT NULL DEFAULT 'new' CHECK (status IN ('new','draft','approved','sending','sent','replied','bounced','skipped')),
  cv_file TEXT,
  sent_at TEXT,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ','now'))
);

CREATE TABLE IF NOT EXISTS answers (
  id INTEGER PRIMARY KEY,
  question_key TEXT NOT NULL,
  patterns TEXT,
  field_type TEXT CHECK (field_type IN ('text','number','radio','select','checkbox','date','file')),
  value TEXT,
  scope TEXT NOT NULL DEFAULT 'always' CHECK (scope IN ('always','company')),
  company_name TEXT,
  locked INTEGER NOT NULL DEFAULT 0 CHECK (locked IN (0,1)),
  source TEXT NOT NULL CHECK (source IN ('profile','user','derived')),
  options_seen TEXT,
  context_job_id INTEGER REFERENCES jobs(id),
  notes TEXT,
  asked_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ','now')),
  answered_at TEXT
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_answers ON answers(question_key, scope, COALESCE(company_name,''));

CREATE TABLE IF NOT EXISTS actions (
  id INTEGER PRIMARY KEY,
  type TEXT NOT NULL CHECK (type IN ('connect','message','apply_naukri','apply_linkedin','apply_instahyre','apply_portal','email')),
  ref_table TEXT,
  ref_id INTEGER,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ','now'))
);

CREATE TABLE IF NOT EXISTS blocklist (
  id INTEGER PRIMARY KEY,
  kind TEXT NOT NULL CHECK (kind IN ('company','person','email','domain')),
  value_key TEXT NOT NULL,
  reason TEXT,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ','now')),
  UNIQUE(kind, value_key)
);

CREATE TABLE IF NOT EXISTS notes (
  id INTEGER PRIMARY KEY,
  scope TEXT NOT NULL,
  note TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ','now'))
);

CREATE TABLE IF NOT EXISTS runs (
  id INTEGER PRIMARY KEY,
  pillar TEXT NOT NULL,
  started_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%SZ','now')),
  ended_at TEXT,
  outcome TEXT NOT NULL DEFAULT 'running' CHECK (outcome IN ('running','completed','halted','crashed')),
  summary TEXT
);

CREATE INDEX IF NOT EXISTS ix_jobs_status ON jobs(status);
CREATE INDEX IF NOT EXISTS ix_contacts_stage ON contacts(stage);
CREATE INDEX IF NOT EXISTS ix_messages_contact ON messages(contact_id, created_at);
CREATE INDEX IF NOT EXISTS ix_actions_type_time ON actions(type, created_at);
CREATE INDEX IF NOT EXISTS ix_leads_status ON leads(status);

-- One outbound message of each one-time kind per contact (cancelled/failed rows do not count).
CREATE UNIQUE INDEX IF NOT EXISTS ux_msg_once ON messages(contact_id, kind)
WHERE direction='outbound'
  AND kind IN ('connect_note','first','second_ask','third_links','follow_up')
  AND status IN ('draft','approved','pending','sent');

-- Walls: pause, cooldown, daily cap (IST day), unknown action types fail closed.
CREATE TRIGGER IF NOT EXISTS trg_actions_paused BEFORE INSERT ON actions
BEGIN
  SELECT RAISE(ABORT,'paused')
  WHERE (SELECT value FROM settings WHERE key='paused') = '1';
  SELECT RAISE(ABORT,'cooldown active')
  WHERE (SELECT value FROM settings WHERE key='cooldown_until') <> ''
    AND (SELECT value FROM settings WHERE key='cooldown_until') > strftime('%Y-%m-%dT%H:%M:%SZ','now');
END;

CREATE TRIGGER IF NOT EXISTS trg_actions_cap BEFORE INSERT ON actions
BEGIN
  SELECT RAISE(ABORT,'daily cap reached')
  WHERE (SELECT COUNT(*) FROM actions
         WHERE type = NEW.type
           AND date(created_at,'+330 minutes') = date('now','+330 minutes'))
        >= COALESCE((SELECT CAST(value AS INTEGER) FROM settings WHERE key = 'cap_' || NEW.type), 0);
END;

-- Walls: blocklist and closed contacts.
CREATE TRIGGER IF NOT EXISTS trg_jobs_blocked BEFORE INSERT ON jobs
WHEN EXISTS (SELECT 1 FROM blocklist WHERE kind='company' AND value_key = NEW.company_key)
BEGIN SELECT RAISE(ABORT,'company is blocklisted'); END;

CREATE TRIGGER IF NOT EXISTS trg_contacts_blocked BEFORE INSERT ON contacts
WHEN EXISTS (SELECT 1 FROM blocklist
             WHERE (kind='company' AND value_key = NEW.company_key)
                OR (kind='person' AND value_key = NEW.profile_url))
BEGIN SELECT RAISE(ABORT,'contact is blocklisted'); END;

CREATE TRIGGER IF NOT EXISTS trg_leads_blocked BEFORE INSERT ON leads
WHEN EXISTS (SELECT 1 FROM blocklist
             WHERE (kind='email' AND value_key = NEW.email)
                OR (kind='domain' AND NEW.email LIKE '%@' || value_key))
BEGIN SELECT RAISE(ABORT,'lead is blocklisted'); END;

CREATE TRIGGER IF NOT EXISTS trg_msg_closed BEFORE INSERT ON messages
WHEN NEW.direction='outbound'
 AND (SELECT stage FROM contacts WHERE id = NEW.contact_id) = 'closed'
BEGIN SELECT RAISE(ABORT,'contact is closed'); END;

-- Walls: locked answers and no deletes on history.
CREATE TRIGGER IF NOT EXISTS trg_answers_locked BEFORE UPDATE OF value, patterns, question_key ON answers
WHEN OLD.locked = 1
BEGIN SELECT RAISE(ABORT,'locked answer'); END;

CREATE TRIGGER IF NOT EXISTS trg_answers_nodelete BEFORE DELETE ON answers
WHEN OLD.locked = 1
BEGIN SELECT RAISE(ABORT,'locked answer'); END;

CREATE TRIGGER IF NOT EXISTS trg_nodelete_jobs BEFORE DELETE ON jobs BEGIN SELECT RAISE(ABORT,'no deletes'); END;
CREATE TRIGGER IF NOT EXISTS trg_nodelete_contacts BEFORE DELETE ON contacts BEGIN SELECT RAISE(ABORT,'no deletes'); END;
CREATE TRIGGER IF NOT EXISTS trg_nodelete_messages BEFORE DELETE ON messages BEGIN SELECT RAISE(ABORT,'no deletes'); END;
CREATE TRIGGER IF NOT EXISTS trg_nodelete_actions BEFORE DELETE ON actions BEGIN SELECT RAISE(ABORT,'no deletes'); END;
CREATE TRIGGER IF NOT EXISTS trg_nodelete_leads BEFORE DELETE ON leads BEGIN SELECT RAISE(ABORT,'no deletes'); END;

-- Seeds: locked answers.
INSERT OR IGNORE INTO answers(question_key, patterns, field_type, value, scope, locked, source, notes, answered_at) VALUES
 ('current ctc','["current ctc","present ctc","current salary","existing ctc","current compensation"]','number','3.6','always',1,'profile','Lakhs per annum. Convert if the field asks for rupees or monthly. Never confuse with expected CTC.',strftime('%Y-%m-%dT%H:%M:%SZ','now')),
 ('expected ctc','["expected ctc","desired salary","expected salary","salary expectation"]','number','10','always',1,'profile','Lakhs per annum. Use 10 unless a range is accepted (10 to 13). Convert units as the field needs.',strftime('%Y-%m-%dT%H:%M:%SZ','now')),
 ('notice period','["notice period","how soon can you join","joining time"]','text','30 days','always',1,'profile','Choose the option equal to or nearest to 30 days.',strftime('%Y-%m-%dT%H:%M:%SZ','now')),
 ('total experience','["total experience","years of experience","overall experience"]','number','3','always',1,'profile','Years.',strftime('%Y-%m-%dT%H:%M:%SZ','now'));

-- Seeds: starter target companies (careers URLs are filled and verified by the agent in Discover).
INSERT OR IGNORE INTO companies(name, name_key, priority) VALUES
 ('Esri','esri',2), ('Hexagon','hexagon',2), ('Trimble','trimble',2), ('Bentley Systems','bentley systems',2),
 ('Autodesk','autodesk',3), ('HERE Technologies','here technologies',2), ('TomTom','tomtom',2),
 ('Mapbox','mapbox',2), ('CARTO','carto',2), ('MapmyIndia','mapmyindia',2), ('Ola Maps','ola maps',2),
 ('Genesys International','genesys international',2), ('RMSI','rmsi',2), ('SatSure','satsure',2), ('Pixxel','pixxel',2),
 ('WSP','wsp',3), ('AECOM','aecom',3), ('Arcadis','arcadis',3), ('Stantec','stantec',3), ('Jacobs','jacobs',3),
 ('Mott MacDonald','mott macdonald',3), ('Google','google',3), ('Microsoft','microsoft',3), ('Amazon','amazon',3), ('Uber','uber',3);

