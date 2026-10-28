const { DatabaseSync } = require('node:sqlite');
const db = new DatabaseSync('c:/job-search/job-skill/data/career.sqlite');

const args = process.argv.slice(2);
const op = args[0];

if (op === 'insert_contact') {
  const [name, firstName, profileUrl, companyId, companyName, companyKey, headline, stage] = args.slice(1);
  const stmt = db.prepare(`
    INSERT INTO contacts (name, first_name, profile_url, company_id, company_name, company_key, headline, in_india, stage, created_at)
    VALUES (?, ?, ?, ?, ?, ?, ?, 1, ?, datetime('now', 'localtime'))
  `);
  stmt.run(name, firstName, profileUrl, Number(companyId), companyName, companyKey, headline, stage);
  console.log(`Inserted contact: ${name}`);
} else if (op === 'query') {
  const query = args[1];
  const rows = db.prepare(query).all();
  console.log(JSON.stringify(rows, null, 2));
}

