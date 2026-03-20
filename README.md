# salesforce-project — Static Analysis & Policy as Code

Original Salesforce DX project enhanced with a full **Policy as Code** layer.
Every pull request automatically runs 5 parallel quality gates before any deployment.

---

## Pipeline Overview

```
Push / PR  →  develop or main
                 │
                 ▼
┌────────────────────────────────────────────────────┐
│  STAGE 1 — Validate (Dry Run)                      │
│  sf project deploy validate --test-level           │
│  RunLocalTests                                     │
└──────────────────────┬─────────────────────────────┘
                       │ succeeded()
                       ▼
┌────────────────────────────────────────────────────┐
│  STAGE 2 — Static Analysis & Policy as Code        │
│  (5 jobs run in PARALLEL)                          │
│                                                    │
│  Job 1: ApexPMD    → PMD rules on .cls files       │
│  Job 2: LWCLint    → ESLint on lwc/                │
│  Job 3: FlowScan   → Flow Scanner on flows/        │
│  Job 4: OPAPolicy  → Custom Rego on metadata JSON  │
│  Job 5: CheckovScan→ CIS checks on metadata XML    │
│                      └─ Publishes SARIF artifact   │
└──────────────────────┬─────────────────────────────┘
                       │ succeeded() AND branch=main
                       ▼
┌────────────────────────────────────────────────────┐
│  STAGE 3 — Deploy to Dev Org                       │
│  sf project deploy start --test-level RunLocalTests│
└────────────────────────────────────────────────────┘
```

---

## Project Structure

```
salesforce-project/
│
├── azure-pipelines.yml               ← 3-stage pipeline definition
│
├── force-app/main/default/
│   ├── classes/
│   │   ├── HelloWorld.cls            ← with sharing, no SOQL in loops
│   │   └── HelloWorldTest.cls        ← assertions, no SeeAllData
│   ├── lwc/greetingCard/             ← ESLint-compliant LWC component
│   ├── flows/
│   │   └── UpdateGreetingDate.flow-meta.xml  ← fault paths present
│   └── permissionsets/
│       └── HelloWorld_User.permissionset-meta.xml
│
├── policies/
│   ├── pmd/apex-ruleset.xml          ← Job 1: PMD Apex rules
│   ├── eslint/.eslintrc.json         ← Job 2: LWC ESLint rules
│   ├── flow-scanner/flow-scanner.json← Job 3: Flow quality rules
│   ├── opa/
│   │   ├── security.rego             ← Job 4: SEC-001 to SEC-005
│   │   └── compliance.rego           ← Job 4: COMP-001 to COMP-004
│   └── checkov/
│       ├── check_permset_description.py  ← Job 5: CKV2_SFO_001
│       ├── check_object_sharing_model.py ← Job 5: CKV2_SFO_002
│       ├── check_connected_app_oauth.py  ← Job 5: CKV2_SFO_003
│       └── check_flow_fault_paths.py     ← Job 5: CKV2_SFO_004
│
├── scripts/
│   ├── utils/metadata-to-json.js    ← converts XML → JSON for OPA
│   └── validate/opa-exit-check.js   ← exits 1 on OPA violations
│
├── package.json                     ← npm run policy:check
├── .forceignore
├── .prettierrc
└── .gitignore
```

---

## Local Development

```bash
# 1. Install dependencies
npm install
pip3 install checkov --break-system-packages

# 2. Install OPA (Linux)
curl -sSL -o /usr/local/bin/opa \
  https://openpolicyagent.org/downloads/latest/opa_linux_amd64_static
chmod +x /usr/local/bin/opa

# 3. Run all policy checks (same as Stage 2 in the pipeline)
npm run policy:check

# 4. Run individual checks
npm run lint:apex        # PMD on .cls files
npm run lint:lwc         # ESLint on lwc/
npm run lint:flows       # Flow Scanner on flows/
npm run policy:opa       # OPA Rego evaluation
npm run policy:checkov   # Checkov XML scan

# 5. Dry-run deployment
npm run deploy:validate
```

---

## Azure DevOps Variable Group

The pipeline reads from **`Salesforce-DevOrg-Vars`** library group.

| Variable | Description | Secret |
|---|---|---|
| `SF_CONSUMER_KEY` | Connected App consumer key | ✅ |
| `SERVER_KEY_BASE64` | Base64-encoded JWT private key | ✅ |
| `SF_USERNAME` | Deployment user username | ✅ |
| `SF_INSTANCE_URL` | `https://login.salesforce.com` | No |

---

## Policy Rules Reference

### OPA — security.rego
| Rule | What it checks |
|---|---|
| SEC-001 | No Profile grants `ModifyAllData` |
| SEC-002 | No Profile grants `ViewAllData` |
| SEC-003 | No Profile grants `ManageUsers` |
| SEC-004 | Custom Objects must have `sharingModel` |
| SEC-005 | Apex classes must declare `with/without/inherited sharing` |

### OPA — compliance.rego
| Rule | What it checks |
|---|---|
| COMP-001 | PII fields must have a data classification description |
| COMP-002 | Connected Apps must not use `full` OAuth scope |
| COMP-003 | AutoLaunchedFlows need fault paths on Record Updates |
| COMP-004 | Test classes must not use `SeeAllData=true` |

### Checkov — custom checks
| Check ID | What it checks |
|---|---|
| CKV2_SFO_001 | Permission Sets must have descriptions |
| CKV2_SFO_002 | Custom Objects must declare a `sharingModel` |
| CKV2_SFO_003 | Connected Apps must not use `full` OAuth scope |
| CKV2_SFO_004 | AutoLaunchedFlows must have fault paths on Record Updates |

### PMD — apex-ruleset.xml (severity 1-2 block pipeline)
| Rule | Severity |
|---|---|
| ApexSOQLInjection | 1 — Critical |
| ApexSharingViolations | 1 — Critical |
| AvoidSoqlInLoops | 1 — Critical |
| AvoidDmlStatementsInLoops | 1 — Critical |
| ApexUnitTestClassShouldHaveAsserts | 2 — High |
| ApexUnitTestShouldNotUseSeeAllDataTrue | 2 — High |
| EmptyCatchBlock | 2 — High |
