const fs = require('node:fs');
const path = require('node:path');
const { DatabaseSync } = require('node:sqlite');

const DB_PATH = path.resolve(__dirname, 'data', 'career.sqlite');
const SESSION_PATH = path.resolve(__dirname, 'data', 'session.json');

let inMemoryCount = 0;

function getDb() {
  const db = new DatabaseSync(DB_PATH);
  db.exec('PRAGMA busy_timeout = 5000;');
  return db;
}

function getSessionCount() {
  try {
    if (fs.existsSync(SESSION_PATH)) {
      const data = JSON.parse(fs.readFileSync(SESSION_PATH, 'utf8'));
      return data.count || 0;
    }
  } catch {
    // fallback
  }
  return inMemoryCount;
}

function incrementSessionCount() {
  inMemoryCount++;
  try {
    let current = 0;
    if (fs.existsSync(SESSION_PATH)) {
      try {
        const data = JSON.parse(fs.readFileSync(SESSION_PATH, 'utf8'));
        current = data.count || 0;
      } catch {
        current = 0;
      }
    }
    current++;
    fs.writeFileSync(SESSION_PATH, JSON.stringify({ count: current, updated_at: new Date().toISOString() }), 'utf8');
  } catch (err) {
    // silent fallback
  }
}

function resetSessionCount() {
  inMemoryCount = 0;
  try {
    fs.writeFileSync(SESSION_PATH, JSON.stringify({ count: 0, updated_at: new Date().toISOString() }), 'utf8');
  } catch {
    // silent
  }
}

function reserve(type, jobId) {
  const validTypes = ['connect', 'message', 'apply_naukri', 'apply_linkedin', 'apply_instahyre', 'apply_portal', 'email'];
  if (!validTypes.includes(type)) {
    console.log(`DENIED invalid action type: ${type}`);
    return;
  }

  const db = getDb();
  try {
    const jid = jobId ? parseInt(jobId, 10) : null;
    db.prepare(`
      INSERT INTO actions (type, ref_table, ref_id)
      VALUES (?, ?, ?)
    `).run(type, jid ? 'jobs' : null, jid);

    if (jid) {
      db.prepare(`
        UPDATE jobs
        SET status = 'applying'
        WHERE id = ? AND status NOT IN ('applied', 'closed')
      `).run(jid);
    }

    incrementSessionCount();
    console.log('OK');
  } catch (err) {
    console.log(`DENIED ${err.message}`);
  }
}

function record(company, title, url, fitScore, board, status) {
  if (!company || !title || !url || !board) {
    console.log('ERROR missing required fields');
    return;
  }

  const validBoards = ['naukri', 'linkedin', 'instahyre', 'google_jobs', 'company_portal'];
  if (!validBoards.includes(board)) {
    console.log(`ERROR invalid board: ${board}`);
    return;
  }

  const db = getDb();
  const companyKey = company
    .toLowerCase()
    .replace(/[^a-z0-9 ]/g, ' ')
    .replace(/\b(pvt|private|ltd|limited|inc|llc|corp|technologies|solutions|india)\b/g, '')
    .replace(/\s+/g, '')
    .trim();

  const titleKey = title
    .toLowerCase()
    .replace(/[^a-z0-9 ]/g, ' ')
    .replace(/\s+/g, '')
    .trim();

  const cleanUrl = url.split(/[?#]/)[0].trim();
  const dedupeKey = `${companyKey}|${titleKey}|${cleanUrl}`;

  // Check duplicate
  const existing = db.prepare(`
    SELECT id FROM jobs WHERE apply_url = ? OR dedupe_key = ?
  `).get(url, dedupeKey);

  if (existing) {
    console.log('DUPLICATE');
    return;
  }

  const score = parseInt(fitScore, 10) || 0;
  const applyRoute = (board === 'google_jobs' || board === 'company_portal') ? 'company_portal' : board;
  const initialStatus = status || (score >= 70 ? 'shortlisted' : 'discovered');

  try {
    const res = db.prepare(`
      INSERT INTO jobs (
        company_name, company_key, title, dedupe_key, apply_url,
        fit_score, source_board, apply_route, status, cv_file
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'Ajay_Patro_CV.pdf')
    `).run(company, companyKey, title, dedupeKey, url, score, board, applyRoute, initialStatus);

    console.log(res.lastInsertRowid);
  } catch (err) {
    if (err.message && err.message.includes('UNIQUE')) {
      console.log('DUPLICATE');
    } else {
      console.log(`DENIED ${err.message}`);
    }
  }
}

function applied(jobId) {
  if (!jobId) {
    console.log('ERROR missing job_id');
    return;
  }

  const db = getDb();
  try {
    const res = db.prepare(`
      UPDATE jobs
      SET status = 'applied',
          applied_at = strftime('%Y-%m-%dT%H:%M:%SZ', 'now')
      WHERE id = ?
    `).run(parseInt(jobId, 10));

    if (res.changes > 0) {
      console.log('OK');
    } else {
      console.log('ERROR job not found');
    }
  } catch (err) {
    console.log(`ERROR ${err.message}`);
  }
}

function session(action) {
  if (action === 'reset') {
    resetSessionCount();
    console.log('0');
    return;
  }
  console.log(getSessionCount());
}

// CLI router
const [,, cmd, ...args] = process.argv;

switch (cmd) {
  case 'reserve':
    reserve(args[0], args[1]);
    break;
  case 'record':
    record(args[0], args[1], args[2], args[3], args[4], args[5]);
    break;
  case 'applied':
    applied(args[0]);
    break;
  case 'session':
    session(args[0]);
    break;
  default:
    console.log('Usage: node guardian.js <reserve|record|applied|session> [args...]');
    break;
}

module.exports = { reserve, record, applied, session, getSessionCount, incrementSessionCount, resetSessionCount };

