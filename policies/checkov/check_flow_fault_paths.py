# policies/checkov/check_flow_fault_paths.py
#
# Custom Checkov check: AutoLaunchedFlows must have fault paths on Record Updates.
# Check ID : CKV2_SFO_004
# Metadata : .flow-meta.xml

from checkov.common.models.enums import CheckResult, CheckCategories
from checkov.common.checks.base_check import BaseCheck


class FlowHasFaultPaths(BaseCheck):
    def __init__(self):
        super().__init__(
            name="AutoLaunchedFlows must have fault paths on all Record Update elements",
            id="CKV2_SFO_004",
            categories=[CheckCategories.GENERAL_SECURITY],
            supported_entities=["Flow"],
            block_type="salesforce",
        )

    def scan_resource_conf(self, conf):
        ptype = conf.get("processType", [None])
        if isinstance(ptype, list):
            ptype = ptype[0] if ptype else None
        if ptype != "AutoLaunchedFlow":
            return CheckResult.PASSED  # rule only applies to auto-launched flows

        updates = conf.get("recordUpdates", [])
        if isinstance(updates, dict):
            updates = [updates]

        for update in updates:
            if not update.get("faultConnector"):
                return CheckResult.FAILED

        return CheckResult.PASSED


check = FlowHasFaultPaths()
