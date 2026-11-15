# Incident Postmortem: [INCIDENT-ID] - [Brief Summary]

- **Incident Date:** YYYY-MM-DD
- **Incident Commander:** [Name / Role]
- **SRE / Domain Lead:** [Name / Role]
- **Severity Level:** [P0 / P1 / P2]
- **Time to Detect (TTD):** [XX minutes]
- **Time to Mitigate (TTM):** [XX minutes]
- **Total Outage Duration:** [XX minutes]

## Executive Summary
<!-- High-level non-technical summary of what occurred, impact, and root cause -->

## Customer & Financial Impact
- **Services Affected:** <!-- e.g., oenexa-pay, oenexa-wallet -->
- **Transactions Failed:** <!-- Number of transactions -->
- **Estimated Financial Exposure:** <!-- Currency amount or zero -->
- **SLA Breach:** [Yes / No]

## Incident Timeline (UTC)
| Timestamp | Event / Observation / Action Taken | Actor |
|---|---|---|
| HH:MM:SS | Automated alert triggered on Prometheus `HighLatencyMatchingEngine` | Alertmanager |
| HH:MM:SS | Incident Commander paged via PagerDuty | PagerDuty |
| HH:MM:SS | Mitigation initiated (traffic routed to failover cluster) | SRE Lead |
| HH:MM:SS | Service telemetry stabilized; SLA recovered | Team |

## Root Cause Analysis (5 Whys)
1. **Why did the outage occur?** The matching engine crashed during order book matching.
2. **Why did it crash?** An uncaught memory allocation overflow on circular buffer expansion.
3. **Why was it uncaught?** Load test thresholds did not simulate extreme book depth during high-volatility events.
4. **Why was load testing deficient?** Stress testing harnesses capped at 50,000 orders/sec rather than 200,000 orders/sec.
5. **Why was threshold capped?** Outdated testing configuration in CI performance pipeline.

## Corrective Actions & Prevention (CAPA)
| Action Item | Type | Owner | Target Date | Status |
|---|---|---|---|---|
| Implement dynamic ring buffer clamping | Preventative | Exchange Team | YYYY-MM-DD | In Progress |
| Update CI performance suite to 250k TPS | Detection | SRE / QA | YYYY-MM-DD | Backlog |
| Introduce automated circuit breaker in API Gateway | Mitigative | Platform Team | YYYY-MM-DD | Planned |
