import json
import logging
import os
from typing import Any

import github
import yaml
from cloud_cron.lambda_task import CronLambdaTask
from eshgham import Harness, Outputter, Status, get_token, make_json_ready


class _SilentOutputter(Outputter):
    """No-op outputter; keeps Harness quiet inside Lambda."""


def _load_workflow_config() -> dict[str, list[str]]:
    raw = os.environ.get("ESHGHAM_WORKFLOWS_YAML")
    if not raw:
        raise ValueError("Missing ESHGHAM_WORKFLOWS_YAML env var")
    workflow_dict = yaml.safe_load(raw)
    if not isinstance(workflow_dict, dict):
        raise ValueError("ESHGHAM_WORKFLOWS_YAML must parse to a mapping")
    return workflow_dict


class EshghamCronTask(CronLambdaTask):
    def _perform_task(self, event, context):
        workflow_dict = _load_workflow_config()
        token = get_token(None, workflow_dict)
        gh = github.Github(token)

        runner = Harness(_SilentOutputter())
        sorted_results = runner(gh, workflow_dict)

        json_ready = make_json_ready(sorted_results)
        result_payload = {
            status: {"workflows": workflows}
            for status, workflows in json_ready.items()
            if workflows
        }
        logging.getLogger(self.__class__.__name__).info(
            "eshgham_run_summary",
            extra={"summary": json.dumps(result_payload)},
        )
        return result_payload


task = EshghamCronTask()
handler = task.lambda_handler
