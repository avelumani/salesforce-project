# policies/checkov/check_permset_description.py
#
# Custom Checkov check: every Permission Set must have a non-empty description.
# Check ID : CKV2_SFO_001
# Metadata : .permissionset-meta.xml

from checkov.common.models.enums import CheckResult, CheckCategories
from checkov.common.checks.base_check import BaseCheck


class PermSetHasDescription(BaseCheck):
    def __init__(self):
        super().__init__(
            name="Ensure every Permission Set has a description",
            id="CKV2_SFO_001",
            categories=[CheckCategories.GENERAL_SECURITY],
            supported_entities=["PermissionSet"],
            block_type="salesforce",
        )

    def scan_resource_conf(self, conf):
        description = conf.get("description", [{}])
        if isinstance(description, list):
            description = description[0] if description else {}
        value = description if isinstance(description, str) \
            else description.get("#text", "")
        if value and value.strip():
            return CheckResult.PASSED
        return CheckResult.FAILED


check = PermSetHasDescription()
