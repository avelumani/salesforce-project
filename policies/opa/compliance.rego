# policies/opa/compliance.rego
# Data governance and compliance rules evaluated against metadata JSON.

package salesforce.policy

# ── [COMP-001] PII fields must have a description ──────────────
deny[msg] {
  obj   := input.customObjects[_]
  field := obj.fields[_]

  pii_names := {
    "Email__c", "Phone__c", "MobilePhone__c",
    "SSN__c", "NationalId__c", "DateOfBirth__c",
    "HomeAddress__c", "BankAccount__c"
  }
  pii_names[field.fullName]
  not field.description

  msg := sprintf(
    "[COMP-001] PII field '%v.%v' must have a description documenting its data classification.",
    [obj.fullName, field.fullName]
  )
}

# ── [COMP-002] Connected Apps must not use 'full' OAuth scope ──
deny[msg] {
  app   := input.connectedApps[_]
  scope := app.oauthConfig.scopes[_]
  scope == "full"
  msg := sprintf(
    "[COMP-002] Connected App '%v' uses the 'full' OAuth scope. Restrict to minimum required scopes.",
    [app.fullName]
  )
}

# ── [COMP-003] AutoLaunchedFlows must have fault paths on DML ──
deny[msg] {
  flow    := input.flows[_]
  flow.processType == "AutoLaunchedFlow"
  element := flow.recordUpdates[_]
  not element.faultConnector
  msg := sprintf(
    "[COMP-003] Flow '%v': Record Update element '%v' is missing a Fault path.",
    [flow.fullName, element.name]
  )
}

# ── [COMP-004] Test classes must not use SeeAllData=true ───────
deny[msg] {
  cls := input.apexClasses[_]
  contains(cls.body, "SeeAllData=true")
  msg := sprintf(
    "[COMP-004] Apex class '%v' uses @isTest(SeeAllData=true). Use test data factories instead.",
    [cls.name]
  )
}
