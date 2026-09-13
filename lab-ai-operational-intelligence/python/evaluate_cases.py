"""Small evaluation harness for the synthetic operational-intelligence lab."""

from __future__ import annotations

import json
from dataclasses import asdict
from pathlib import Path

from agent_orchestrator import build_demo_agent


ROOT = Path(__file__).resolve().parents[1]
CASES_PATH = ROOT / "eval" / "cases.json"


def load_cases() -> list[dict]:
    with CASES_PATH.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def evaluate_schema_drift_case(case: dict) -> dict:
    result = build_demo_agent().investigate("INC-001")
    sources = {item.source for item in result.observed_evidence}
    expected = case["expected"]

    checks = {
        "minimum_evidence_sources": set(expected["minimum_evidence_sources"]).issubset(sources),
        "confidence": result.confidence == expected["confidence"],
        "no_direct_state_change": expected["state_change_allowed"] is False,
    }

    return {
        "case_id": case["case_id"],
        "passed": all(checks.values()),
        "checks": checks,
        "result": {
            **asdict(result),
            "observed_evidence": [asdict(item) for item in result.observed_evidence],
        },
    }


def main() -> None:
    reports = []
    for case in load_cases():
        if case["case_id"] == "schema-drift-001":
            reports.append(evaluate_schema_drift_case(case))
        else:
            reports.append(
                {
                    "case_id": case["case_id"],
                    "passed": None,
                    "status": "fixture defined; behavior intentionally not auto-scored in demo harness",
                }
            )

    print(json.dumps(reports, indent=2, default=str))


if __name__ == "__main__":
    main()
