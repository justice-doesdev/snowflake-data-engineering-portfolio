"""Public-safe reference implementation for bounded AI operations.

This module does not call a live model or Snowflake account. It demonstrates the
application-layer contracts around evidence gathering, recommendation generation,
and approval-gated actions using synthetic inputs.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timezone
from enum import Enum
from typing import Callable, Iterable


class RiskLevel(str, Enum):
    READ_ONLY = "read_only"
    STATE_CHANGING = "state_changing"


@dataclass(frozen=True)
class Evidence:
    evidence_id: str
    source: str
    summary: str
    observed_at: datetime


@dataclass(frozen=True)
class ToolSpec:
    name: str
    risk: RiskLevel
    handler: Callable[..., list[Evidence]]


@dataclass
class Recommendation:
    incident_id: str
    status: str
    observed_evidence: list[Evidence]
    likely_cause: str
    confidence: str
    next_step: str
    requested_action: str | None = None
    approval_required: bool = False
    created_at: datetime = field(default_factory=lambda: datetime.now(timezone.utc))


class PolicyError(RuntimeError):
    """Raised when a requested tool violates the bounded execution policy."""


class OperationalAgent:
    """Coordinates evidence gathering while keeping authority outside the model."""

    def __init__(self, tools: Iterable[ToolSpec]) -> None:
        self._tools = {tool.name: tool for tool in tools}

    def call_tool(self, tool_name: str, **kwargs: object) -> list[Evidence]:
        tool = self._tools[tool_name]
        if tool.risk is RiskLevel.STATE_CHANGING:
            raise PolicyError(
                f"{tool_name} cannot execute directly; create an approval request instead"
            )
        return tool.handler(**kwargs)

    def investigate(self, incident_id: str) -> Recommendation:
        evidence: list[Evidence] = []
        evidence.extend(self.call_tool("get_task_failures", incident_id=incident_id))
        evidence.extend(self.call_tool("get_schema_changes", incident_id=incident_id))
        evidence.extend(self.call_tool("get_quality_exceptions", incident_id=incident_id))

        has_failure = any(item.source == "task_history" for item in evidence)
        has_schema_change = any(item.source == "schema_change_log" for item in evidence)

        if has_failure and has_schema_change:
            likely_cause = "Schema drift is the leading hypothesis."
            confidence = "high"
            next_step = "Validate the transform contract against the changed source schema."
        elif has_failure:
            likely_cause = "The failure is confirmed, but the current evidence is insufficient for RCA."
            confidence = "low"
            next_step = "Retrieve additional dependency and deployment evidence."
        else:
            likely_cause = "No supported failure evidence was found."
            confidence = "low"
            next_step = "Confirm the incident window and evidence-source freshness."

        return Recommendation(
            incident_id=incident_id,
            status="investigated",
            observed_evidence=evidence,
            likely_cause=likely_cause,
            confidence=confidence,
            next_step=next_step,
        )


def synthetic_task_failures(*, incident_id: str) -> list[Evidence]:
    return [
        Evidence(
            evidence_id=f"{incident_id}:task:1",
            source="task_history",
            summary="TASK_LOAD_REVENUE failed before dependent refresh tasks ran.",
            observed_at=datetime(2026, 9, 13, 10, 14, tzinfo=timezone.utc),
        )
    ]


def synthetic_schema_changes(*, incident_id: str) -> list[Evidence]:
    return [
        Evidence(
            evidence_id=f"{incident_id}:schema:1",
            source="schema_change_log",
            summary="SRC_REVENUE changed shape shortly before the first task failure.",
            observed_at=datetime(2026, 9, 13, 9, 52, tzinfo=timezone.utc),
        )
    ]


def synthetic_quality_exceptions(*, incident_id: str) -> list[Evidence]:
    return [
        Evidence(
            evidence_id=f"{incident_id}:dq:1",
            source="quality_exceptions",
            summary="Downstream revenue freshness checks are outside the expected window.",
            observed_at=datetime(2026, 9, 13, 10, 20, tzinfo=timezone.utc),
        )
    ]


def build_demo_agent() -> OperationalAgent:
    return OperationalAgent(
        [
            ToolSpec("get_task_failures", RiskLevel.READ_ONLY, synthetic_task_failures),
            ToolSpec("get_schema_changes", RiskLevel.READ_ONLY, synthetic_schema_changes),
            ToolSpec("get_quality_exceptions", RiskLevel.READ_ONLY, synthetic_quality_exceptions),
        ]
    )


if __name__ == "__main__":
    result = build_demo_agent().investigate("INC-001")
    print(result)
