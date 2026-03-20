#!/usr/bin/env node
/**
 * scripts/validate/opa-exit-check.js
 *
 * Reads OPA evaluation output from stdin.
 * Exits 0 (pass) if no deny rules fired.
 * Exits 1 (fail) with clear messages + Azure DevOps ##vso annotations.
 *
 * Usage (piped from OPA):
 *   opa eval ... | node scripts/validate/opa-exit-check.js
 */

'use strict';

const readline = require('readline');
const rl       = readline.createInterface({ input: process.stdin });
const lines    = [];

rl.on('line', line => lines.push(line));

rl.on('close', () => {
  const raw = lines.join('\n').trim();

  if (!raw || raw === 'set()' || raw === '[]') {
    console.log('\nOPA Policy Check PASSED — no violations found.\n');
    process.exit(0);
  }

  let violations;
  try {
    violations = JSON.parse(raw);
  } catch {
    console.error('\nOPA returned unexpected output — treating as failure:\n');
    console.error(raw);
    process.exit(1);
  }

  if (!Array.isArray(violations) || violations.length === 0) {
    console.log('\nOPA Policy Check PASSED — no violations found.\n');
    process.exit(0);
  }

  console.error(`\nOPA Policy Check FAILED — ${violations.length} violation(s):\n`);
  violations.forEach((msg, i) => {
    console.error(`  ${String(i + 1).padStart(2, '0')}. ${msg}`);
    // Azure DevOps error annotation — appears inline in pipeline logs
    console.error(`##vso[task.logissue type=error]${msg}`);
  });
  console.error('\nDeployment blocked. Fix all violations before merging.\n');

  process.exit(1);
});
