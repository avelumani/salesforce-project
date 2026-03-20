#!/usr/bin/env node
/**
 * scripts/utils/metadata-to-json.js
 *
 * Reads Salesforce XML metadata from a SFDX source directory and converts
 * it into a single JSON object that OPA can evaluate with --input.
 *
 * Supports: profiles, permissionsets, customObjects, flows,
 *           connectedApps, apexClasses (body included for SEC-005/COMP-004).
 *
 * Usage:
 *   node scripts/utils/metadata-to-json.js \
 *     --source force-app/main/default \
 *     --output /tmp/metadata.json
 */

'use strict';

const fs   = require('fs');
const path = require('path');

const argv  = process.argv.slice(2);
const get   = (flag) => argv[argv.indexOf(flag) + 1];
const source = get('--source') || 'force-app/main/default';
const output = get('--output') || '/tmp/metadata.json';

const TYPES = {
  profiles:       { dir: 'profiles',       ext: '.profile-meta.xml'      },
  permissionsets: { dir: 'permissionsets', ext: '.permissionset-meta.xml' },
  customObjects:  { dir: 'objects',        ext: '.object-meta.xml'        },
  flows:          { dir: 'flows',          ext: '.flow-meta.xml'          },
  connectedApps:  { dir: 'connectedApps',  ext: '.connectedApp-meta.xml'  },
  apexClasses:    { dir: 'classes',        ext: '.cls'                    },
};

function parseSimpleXml(xml) {
  const result = {};
  const tagRe  = /<(\w+)(?:[^>]*)>([\s\S]*?)<\/\1>/g;
  let m;
  while ((m = tagRe.exec(xml)) !== null) {
    const [, tag, inner] = m;
    const trimmed = inner.trim();
    const hasNested = /<\w+/.test(trimmed);
    const value = hasNested ? parseSimpleXml(trimmed) : trimmed;
    if (result[tag] === undefined) {
      result[tag] = value;
    } else if (Array.isArray(result[tag])) {
      result[tag].push(value);
    } else {
      result[tag] = [result[tag], value];
    }
    tagRe.lastIndex = m.index + m[0].length;
  }
  return result;
}

function readDir(baseDir, { dir, ext }) {
  const fullDir = path.join(baseDir, dir);
  if (!fs.existsSync(fullDir)) return [];

  const files   = fs.readdirSync(fullDir).filter(f => f.endsWith(ext));
  const records = [];

  for (const file of files) {
    const filePath = path.join(fullDir, file);
    const content  = fs.readFileSync(filePath, 'utf8');

    if (ext === '.cls') {
      records.push({ name: file.replace('.cls', ''), body: content });
    } else {
      try {
        const parsed   = parseSimpleXml(content);
        const rootKey  = Object.keys(parsed)[0];
        const root     = parsed[rootKey] || {};
        root.fullName  = root.fullName || file.replace(ext, '');
        records.push(root);
      } catch (err) {
        console.warn(`  Warning: could not parse ${file}: ${err.message}`);
      }
    }
  }
  return records;
}

console.log(`\nConverting metadata from: ${source}`);
const metadata = {};

for (const [key, config] of Object.entries(TYPES)) {
  const items = readDir(source, config);
  metadata[key] = items;
  const status = items.length > 0 ? `${items.length} file(s)` : '(none)';
  console.log(`  ${key.padEnd(16)} ${status}`);
}

fs.writeFileSync(output, JSON.stringify(metadata, null, 2));
console.log(`\nMetadata JSON written to ${output}\n`);
