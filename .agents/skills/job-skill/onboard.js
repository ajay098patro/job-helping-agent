const fs = require('node:fs');
const path = require('node:path');
const readline = require('node:readline/promises');
const { stdin: input, stdout: output } = require('node:process');
const { DatabaseSync } = require('node:sqlite');

const ROOT_DIR = path.resolve(__dirname, '..');
const PROFILE_PATH = path.resolve(__dirname, 'profile.json');
const DB_PATH = path.resolve(__dirname, 'data', 'career.sqlite');
const AGENTS_MD_PATH = path.resolve(ROOT_DIR, 'AGENTS.md');
const CAREER_OPS_DIR = path.resolve(ROOT_DIR, 'career-ops');

async function prompt(rl, questionText, defaultValue = '') {
  const promptText = defaultValue ? `${questionText} [${defaultValue}]: ` : `${questionText}: `;
  const answer = (await rl.question(promptText)).trim();
  return answer || defaultValue;
}

async function runOnboarding() {
  const rl = readline.createInterface({ input, output });

  console.log('\n=============================================================');
  console.log('   Autonomous Candidate Onboarding & Profile Configuration');
  console.log('=============================================================\n');
  console.log('Please answer the following questions to configure the job search engine.\n');

  try {
    // 1. Identity & Contact Info
    console.log('--- 1. Candidate Identity & Contact Information ---');
    const fullName = await prompt(rl, 'Full Name (matching legal/resume name)', 'Ankush Sharma');
    const defaultFirstName = fullName.split(' ')[0] || fullName;
    const firstName = await prompt(rl, 'First / Preferred Calling Name', defaultFirstName);
    const email = await prompt(rl, 'Official Job-Search Email Address');
    const phone = await prompt(rl, 'Phone Number with Country Code (e.g. +91-XXXXXXXXXX)');
    const location = await prompt(rl, 'Current City / Location', 'India');
    const linkedinUrl = await prompt(rl, 'LinkedIn Profile URL');
    const githubUrl = await prompt(rl, 'GitHub / Portfolio URL', '');

    // 2. CV / Resume Detection
    console.log('\n--- 2. Master Resume / CV Verification ---');
    let cvPath = '';
    const pdfFiles = fs.existsSync(CAREER_OPS_DIR)
      ? fs.readdirSync(CAREER_OPS_DIR).filter(f => f.toLowerCase().endsWith('.pdf'))
      : [];

    if (pdfFiles.length > 0) {
      console.log('Found resume(s) in career-ops/:');
      pdfFiles.forEach((f, idx) => console.log(`  [${idx + 1}] career-ops/${f}`));
      const choice = await prompt(rl, `Select resume [1-${pdfFiles.length}] or type full path`, '1');
      const num = parseInt(choice, 10);
      if (!isNaN(num) && num >= 1 && num <= pdfFiles.length) {
        cvPath = `career-ops/${pdfFiles[num - 1]}`;
      } else {
        cvPath = choice;
      }
    } else {
      cvPath = await prompt(rl, 'Path to Master CV PDF file (e.g. career-ops/resume.pdf)', 'career-ops/resume.pdf');
    }

    // 3. Work Facts & Compensation Truth
    console.log('\n--- 3. Professional Facts & Compensation Details ---');
    const currentTitle = await prompt(rl, 'Current Job Title', 'Software Engineer');
    const currentCompany = await prompt(rl, 'Current Employer / Company Name');
    const totalExpStr = await prompt(rl, 'Total Years of Professional Experience', '3');
    const totalExp = parseFloat(totalExpStr) || 3;
    const currentCtcStr = await prompt(rl, 'Current CTC in ₹ LPA (e.g. 3.6 or 6.0)', '6.0');
    const currentCtc = parseFloat(currentCtcStr) || 6.0;
    const expectedCtcMinStr = await prompt(rl, 'Minimum Expected CTC in ₹ LPA', '12.0');
    const expectedCtcMaxStr = await prompt(rl, 'Target Expected CTC in ₹ LPA', '15.0');
    const expectedCtcMin = parseFloat(expectedCtcMinStr) || 12.0;
    const expectedCtcMax = parseFloat(expectedCtcMaxStr) || 15.0;
    const noticePeriodStr = await prompt(rl, 'Official Notice Period in Days', '30');
    const noticePeriod = parseInt(noticePeriodStr, 10) || 30;

    // 4. Target Roles & Core Skills
    console.log('\n--- 4. Target Roles & Technical Specialization ---');
    const targetRolesInput = await prompt(rl, 'Target Roles (comma-separated)', 'Python Backend Developer, Software Engineer');
    const targetRoles = targetRolesInput.split(',').map(r => r.trim()).filter(Boolean);

    const skillsInput = await prompt(rl, 'Top 4-6 Core Skills/Tools for Outreach (comma-separated)', 'Python, PostgreSQL, FastAPI, Docker');
    const skillsCore = skillsInput.split(',').map(s => s.trim()).filter(Boolean);

    const emailHook = await prompt(rl, '1-Line Technical Hook for Cold Emails', `Hands-on experience in ${skillsCore.slice(0, 3).join(', ')}`);

    // 5. Locations & Relocation
    console.log('\n--- 5. Location & Relocation Preferences ---');
    const locationsInput = await prompt(rl, 'Primary Preferred Cities (comma-separated)', 'Hyderabad, Bengaluru, Pune, Remote');
    const preferredLocations = locationsInput.split(',').map(l => l.trim()).filter(Boolean);
    const relocateInput = await prompt(rl, 'Open to Relocation across India? (y/n)', 'y');
    const willingToRelocate = relocateInput.toLowerCase().startsWith('y');

    console.log('\n[INFO] Saving Candidate Configuration...\n');

    // Build profile.json
    const profileData = {
      _readme: `Candidate Truth Profile for ${fullName}. null means unknown: ask, never guess.`,
      identity: {
        full_name: fullName,
        first_name: firstName,
        email: email,
        phone: phone,
        phone_availability: 'After 1:00 PM IST',
        current_location: location,
        linkedin_url: linkedinUrl,
        github_url: githubUrl
      },
      work_facts: {
        total_experience_years: totalExp,
        current_ctc_lpa: currentCtc,
        expected_ctc_lpa: {
          min: expectedCtcMin,
          max: expectedCtcMax
        },
        notice_period_days: noticePeriod,
        current_company: currentCompany,
        current_title: currentTitle,
        willing_to_relocate: willingToRelocate,
        work_authorization_india: true,
        work_authorization_outside_india: 'Open to relocation with employer sponsorship'
      },
      target_roles: targetRoles,
      skills_core: skillsCore,
      skills_technical: {
        languages: skillsCore.filter(s => ['python', 'sql', 'javascript', 'java', 'c++', 'go', 'bash'].includes(s.toLowerCase())),
        databases: skillsCore.filter(s => s.toLowerCase().includes('sql') || s.toLowerCase().includes('postgis') || s.toLowerCase().includes('mongo')),
        tools: skillsCore
      },
      previous_employment: [
        {
          company: currentCompany,
          title: currentTitle,
          dates: 'Present'
        }
      ],
      education: [],
      certifications: [],
      projects: [],
      highlights: [
        `${totalExp}+ years hands-on experience in ${skillsCore.slice(0, 3).join(', ')}`
      ],
      preferred_locations: preferredLocations,
      allowed_domains: [
        'linkedin.com',
        'naukri.com',
        'instahyre.com',
        'google.com',
        'myworkdayjobs.com',
        'greenhouse.io',
        'lever.co',
        'smartrecruiters.com'
      ],
      cv: {
        master_tex: 'job-skill/cv/master.tex',
        existing_pdf: cvPath,
        output_dir: 'job-skill/cv/out',
        output_filename: path.basename(cvPath) || 'CV.pdf'
      },
      personal_line_max_words: 25,
      templates: {
        _approved_by_user: ['first_message', 'second_ask'],
        _draft_needs_user_approval: ['connect_note', 'recruiter_email'],
        connect_note: `Hi {first_name}, I came across your profile and work. I specialize in ${skillsCore.slice(0, 3).join(', ')}. Would welcome connecting with you. Best, ${firstName}`,
        recruiter_email: `Dear Hiring Team,\n\nI am writing regarding engineering opportunities with your team.\n\nQuick overview of my relevant experience:\n- ${skillsCore[0] || 'Core Engineering'}: ${totalExp}+ years hands-on experience.\n- ${emailHook}.\n\nI have attached my CV (${path.basename(cvPath)}) for your review. I would welcome the opportunity to connect and discuss how my background can contribute to your team.\n\nRegards\n${fullName}\n${phone}\n${email}`,
        replies: {
          notice: `Hi {first_name}, my notice period is ${noticePeriod} days, and I am available for technical rounds.`,
          ctc: `Hi {first_name}, my current CTC is ${currentCtc} LPA and my expected CTC is ${expectedCtcMin}-${expectedCtcMax} LPA.`,
          location: `Hi {first_name}, I am primarily targeting ${preferredLocations.slice(0, 3).join(', ')}, and open to evaluating other locations based on role scope and compensation.`
        }
      }
    };

    fs.writeFileSync(PROFILE_PATH, JSON.stringify(profileData, null, 2), 'utf8');
    console.log(`[OK] Saved profile to: ${PROFILE_PATH}`);

    // Update SQLite answers table
    if (fs.existsSync(DB_PATH)) {
      try {
        const db = new DatabaseSync(DB_PATH);
        const upsert = db.prepare(`
          INSERT INTO answers (question_key, value, scope, source, asked_at, answered_at)
          VALUES (?, ?, 'always', 'profile', strftime('%Y-%m-%dT%H:%M:%SZ','now'), strftime('%Y-%m-%dT%H:%M:%SZ','now'))
          ON CONFLICT(question_key, scope, COALESCE(company_name,''))
          DO UPDATE SET value = excluded.value, source = 'profile', answered_at = strftime('%Y-%m-%dT%H:%M:%SZ','now')
        `);
        upsert.run('current ctc', String(currentCtc));
        upsert.run('expected ctc', String(expectedCtcMin));
        upsert.run('notice period', `${noticePeriod} days`);
        upsert.run('total experience', String(totalExp));
        console.log('[OK] Updated SQLite answers table (CTC, notice period, total experience)');
      } catch (err) {
        console.log(`[NOTE] Database update skipped or deferred: ${err.message}`);
      }
    }

    // Update AGENTS.md
    if (fs.existsSync(AGENTS_MD_PATH)) {
      let agentsContent = fs.readFileSync(AGENTS_MD_PATH, 'utf8');

      // Update signature in Rule 2
      agentsContent = agentsContent.replace(
        /Regards\s*\n\s*[^\n]+\s*\n\s*\+91-[0-9]+\s*\n\s*[^\n@]+@[^\n]+/,
        `Regards\n    ${fullName}\n    ${phone}\n    ${email}`
      );

      // Update Rule 3
      const rule3Replacement = `## 3. Candidate Truth & Credentials\n` +
        `- **Name**: ${fullName}\n` +
        `- **Phone**: ${phone} (matching resume and email signature)\n` +
        `- **Email**: ${email}\n` +
        `- **Current CTC**: ₹${currentCtc} LPA\n` +
        `- **Expected CTC**: ₹${expectedCtcMin}–${expectedCtcMax} LPA\n` +
        `- **Notice Period**: ${noticePeriod} days\n` +
        `- **CV Path**: \`${cvPath}\``;

      agentsContent = agentsContent.replace(/## 3\. Candidate Truth & Credentials[\s\S]*?(?=## 4\.)/, rule3Replacement + '\n\n');

      // Update Rule 4
      agentsContent = agentsContent.replace(
        /\*\*Primary Preferences\*\*: [^\n]+/,
        `**Primary Preferences**: ${preferredLocations.join(', ')} (immediately open and flexible at baseline ₹${expectedCtcMin}–${expectedCtcMax} LPA).`
      );

      // Update Rule 11 prefill values
      agentsContent = agentsContent.replace(
        /Full Name: [^,]+, Email: [^,]+, Phone: [^,]+, Location: [^,]+/,
        `Full Name: ${fullName}, Email: ${email}, Phone: ${phone}, Location: ${location}`
      );

      fs.writeFileSync(AGENTS_MD_PATH, agentsContent, 'utf8');
      console.log(`[OK] Updated AGENTS.md with candidate credentials and operational rules`);
    }

    console.log('\n=============================================================');
    console.log(`   Onboarding Complete! Project configured for: ${fullName}`);
    console.log('=============================================================\n');
    console.log(`Target Roles:        ${targetRoles.join(', ')}`);
    console.log(`Notice Period:       ${noticePeriod} days`);
    console.log(`Current CTC:         ₹${currentCtc} LPA`);
    console.log(`Expected CTC:        ₹${expectedCtcMin}–${expectedCtcMax} LPA`);
    console.log(`Master CV:           ${cvPath}`);
    console.log(`Preferred Locations: ${preferredLocations.join(', ')}\n`);

  } finally {
    rl.close();
  }
}

if (require.main === module) {
  runOnboarding().catch(err => {
    console.error('[ERROR] Onboarding failed:', err);
    process.exit(1);
  });
}

module.exports = { runOnboarding };

