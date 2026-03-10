import json
import logging
import os
from typing import Any

import github
import yaml
from lambdacron.lambda_task import CronLambdaTask
from eshgham import Harness, Outputter, get_token, make_json_ready

logging.basicConfig(level=logging.INFO)

RESULT_TYPE_GROUPS: dict[str, tuple[str, ...]] = {
    "ACTION_NEEDED": ("FAILED", "INACTIVATED"),
    # Keep both spellings to tolerate upstream naming drift.
    "WARNINGS": ("REENABLED", "REACTIVATED", "NO_SCHEDULED_RUNS"),
    "ALL_ABNORMAL": (
        "FAILED",
        "INACTIVATED",
        "REENABLED",
        "REACTIVATED",
        "NO_SCHEDULED_RUNS",
    ),
}


class _SilentOutputter(Outputter):
    """No-op outputter; keeps Harness quiet inside Lambda."""


def _load_workflow_config(filename=None) -> dict[str, list[str]]:
    if filename is not None:
        with open(filename, "r") as f:
            workflow_dict = yaml.safe_load(f)
            return workflow_dict

    raw = os.environ.get("ESHGHAM_WORKFLOWS_YAML")
    if not raw:
        raise ValueError("Missing ESHGHAM_WORKFLOWS_YAML env var")
    workflow_dict = yaml.safe_load(raw)
    if not isinstance(workflow_dict, dict):
        raise ValueError("ESHGHAM_WORKFLOWS_YAML must parse to a mapping")
    return workflow_dict


def _collect_non_empty_workflows_by_status(
    json_ready: dict[str, list[dict[str, Any]]], statuses: tuple[str, ...]
) -> dict[str, list[dict[str, Any]]]:
    grouped: dict[str, list[dict[str, Any]]] = {}
    for status in statuses:
        workflows = json_ready.get(status) or []
        if workflows:
            grouped[status] = workflows
    return grouped


def _build_result_payload(
    json_ready: dict[str, list[dict[str, Any]]],
) -> dict[str, dict[str, Any]]:
    result_payload: dict[str, dict[str, Any]] = {}

    # Keep single-status result types so existing subscriptions continue working.
    for status, workflows in json_ready.items():
        if workflows:
            result_payload[status] = {status: workflows}

    for result_type, statuses in RESULT_TYPE_GROUPS.items():
        grouped = _collect_non_empty_workflows_by_status(json_ready, statuses)
        if grouped:
            result_payload[result_type] = grouped

    return result_payload


def _do_task(logger, filename=None) -> dict[str, dict[str, Any]]:
    workflow_dict = _load_workflow_config(filename)
    token = get_token(None, workflow_dict)
    gh = github.Github(token)

    runner = Harness(_SilentOutputter())
    sorted_results = runner(gh, workflow_dict)

    json_ready = make_json_ready(sorted_results)
    result_payload = _build_result_payload(json_ready)
    logger.info(
        "eshgham_run_summary",
        extra={"summary": json.dumps(result_payload)},
    )
    return result_payload


class EshghamCronTask(CronLambdaTask):
    def _perform_task(
        self,
        event,
        context,
    ) -> dict[str, dict[str, Any]]:
        logger = logging.getLogger(self.__class__.__name__)
        try:
            return _do_task(logger, filename=None))
        except Exception as exc:
            logger.exception("eshgham_run_exception")
            error_payload = {"FAILED": [], "error": str(exc)}
            return {
                "FAILED": dict(error_payload),
                "ACTION_NEEDED": dict(error_payload),
                "ALL_ABNORMAL": dict(error_payload),
            }


task = EshghamCronTask()
handler = task.lambda_handler

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('config', help='Path to YAML config file')
    args = parser.parse_args()
    result = _do_task(logging.getLogger("EshghamCronTask"),
                      filename=args.config)
    print(json.dumps(result, indent=2))
