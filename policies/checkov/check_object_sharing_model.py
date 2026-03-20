# policies/checkov/check_object_sharing_model.py
#
# Custom Checkov check: Custom Objects must declare an explicit sharingModel.
# Check ID : CKV2_SFO_002
# Metadata : .object-meta.xml

from checkov.common.models.enums import CheckResult, CheckCategories
from checkov.common.checks.base_check import BaseCheck

ALLOWED_MODELS = {"ReadWrite", "Private", "PublicRead", "PublicReadWrite", "ControlledByParent"}


class ObjectHasSharingModel(BaseCheck):
    def __init__(self):
        super().__init__(
            name="Ensure custom objects declare an explicit sharingModel",
            id="CKV2_SFO_002",
            categories=[CheckCategories.GENERAL_SECURITY],
            supported_entities=["CustomObject"],
            block_type="salesforce",
        )

    def scan_resource_conf(self, conf):
        model = conf.get("sharingModel", [None])
        if isinstance(model, list):
            model = model[0] if model else None
        if model and model in ALLOWED_MODELS:
            return CheckResult.PASSED
        return CheckResult.FAILED


check = ObjectHasSharingModel()
