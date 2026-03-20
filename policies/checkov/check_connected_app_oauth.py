# policies/checkov/check_connected_app_oauth.py
#
# Custom Checkov check: Connected Apps must not grant the 'full' OAuth scope.
# Check ID : CKV2_SFO_003
# Metadata : .connectedApp-meta.xml

from checkov.common.models.enums import CheckResult, CheckCategories
from checkov.common.checks.base_check import BaseCheck


class ConnectedAppNoFullScope(BaseCheck):
    def __init__(self):
        super().__init__(
            name="Connected App must not use the full OAuth scope",
            id="CKV2_SFO_003",
            categories=[CheckCategories.GENERAL_SECURITY],
            supported_entities=["ConnectedApp"],
            block_type="salesforce",
        )

    def scan_resource_conf(self, conf):
        oauth = conf.get("oauthConfig", {})
        if isinstance(oauth, list):
            oauth = oauth[0] if oauth else {}
        scopes = oauth.get("scopes", [])
        if isinstance(scopes, str):
            scopes = [scopes]
        if "full" in scopes:
            return CheckResult.FAILED
        return CheckResult.PASSED


check = ConnectedAppNoFullScope()
