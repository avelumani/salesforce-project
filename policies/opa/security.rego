# policies/opa/security.rego
# Security policy rules evaluated against Salesforce XML metadata.
# Every `deny` rule that fires blocks the pipeline with a clear message.

package salesforce.policy

# ── [SEC-001] No Profile may grant Modify All Data ─────────────
deny[msg] {
  profile := input.profiles[_]
  perm    := profile.userPermissions[_]
  perm.name    == "ModifyAllData"
  perm.enabled == true
  msg := sprintf(
    "[SEC-001] Profile '%v' enables ModifyAllData. Grant via Permission Set instead.",
    [profile.fullName]
  )
}

# ── [SEC-002] No Profile may grant View All Data ───────────────
deny[msg] {
  profile := input.profiles[_]
  perm    := profile.userPermissions[_]
  perm.name    == "ViewAllData"
  perm.enabled == true
  msg := sprintf(
    "[SEC-002] Profile '%v' enables ViewAllData. Use a restricted Permission Set.",
    [profile.fullName]
  )
}

# ── [SEC-003] No Profile may grant Manage Users ────────────────
deny[msg] {
  profile := input.profiles[_]
  perm    := profile.userPermissions[_]
  perm.name    == "ManageUsers"
  perm.enabled == true
  msg := sprintf(
    "[SEC-003] Profile '%v' enables ManageUsers. Restrict to an admin Permission Set.",
    [profile.fullName]
  )
}

# ── [SEC-004] Custom Objects must declare a sharingModel ────────
deny[msg] {
  obj := input.customObjects[_]
  not obj.sharingModel
  msg := sprintf(
    "[SEC-004] Custom Object '%v' has no sharingModel. Add ReadWrite, Private, or PublicRead.",
    [obj.fullName]
  )
}

# ── [SEC-005] Apex classes must declare a sharing keyword ───────
deny[msg] {
  cls := input.apexClasses[_]
  not contains(cls.body, "with sharing")
  not contains(cls.body, "without sharing")
  not contains(cls.body, "inherited sharing")
  not endswith(cls.name, "Test")
  msg := sprintf(
    "[SEC-005] Apex class '%v' does not declare a sharing keyword (with/without/inherited sharing).",
    [cls.name]
  )
}
