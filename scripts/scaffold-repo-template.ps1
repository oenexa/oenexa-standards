param(
    [Parameter(Mandatory=$true)]
    [string]$RepoPath,
    [Parameter(Mandatory=$true)]
    [string]$RepoName,
    [Parameter(Mandatory=$true)]
    [string]$Description,
    [Parameter(Mandatory=$true)]
    [string]$DomainType
)

$ErrorActionPreference = "Stop"

Write-Host "Scaffolding enterprise repository standards for $RepoName at $RepoPath..."

# 1. Required Directories
$dirs = @(
    ".github",
    ".github/ISSUE_TEMPLATE",
    ".github/workflows",
    "docs",
    "docs/architecture",
    "docs/api",
    "docs/operations",
    "architecture",
    "adr",
    "api",
    "api/v1",
    "events",
    "events/v1",
    "deploy",
    "deploy/base",
    "deploy/overlays/staging",
    "deploy/overlays/production",
    "scripts",
    "tests",
    "tests/unit",
    "tests/integration",
    "tests/e2e",
    "security",
    "monitoring",
    "monitoring/prometheus",
    "monitoring/grafana",
    "runbooks"
)

foreach ($d in $dirs) {
    $fullDir = Join-Path $RepoPath $d
    if (-not (Test-Path $fullDir)) {
        New-Item -ItemType Directory -Path $fullDir -Force | Out-Null
    }
}

# Helper to write file only if it doesn't exist or is empty
function Write-IfMissing {
    param([string]$RelativePath, [string]$Content)
    $target = Join-Path $RepoPath $RelativePath
    $shouldWrite = $false
    if (-not (Test-Path $target)) {
        $shouldWrite = $true
    } else {
        $item = Get-Item $target -ErrorAction SilentlyContinue
        if ($item -and $item.Length -lt 50) {
            $shouldWrite = $true
        }
    }
    if ($shouldWrite) {
        [System.IO.File]::WriteAllText($target, $Content.TrimStart(), [System.Text.Encoding]::UTF8)
        Write-Host "  [+] Created: $RelativePath"
    }
}

# 2. Baseline & .github Templates
Write-IfMissing "README.md" @"
# $RepoName

> **$Description**  
> Part of the OENEXA Enterprise Ecosystem. Governed by the OENEXA Architecture Board.

## 1. Quick Start
```bash
# Install dependencies
npm install # or go mod download / cargo build

# Run unit tests
npm test # or go test ./... / cargo test
```

## 2. Architecture & Documentation
- [Architecture Specification](ARCHITECTURE.md)
- [API Contract](API.md)
- [Events Specification](EVENTS.md)
- [Operations Runbook](RUNBOOK.md)
- [Security Policy](SECURITY.md)
"@

Write-IfMissing ".github/PULL_REQUEST_TEMPLATE.md" @"
## Summary
<!-- Concise explanation of changes and motivation for $RepoName -->

## Closes / References
Closes #<!-- Issue Number -->

## Type of Change
- [ ] 🚀 New Feature (non-breaking change which adds functionality)
- [ ] 🐛 Bug Fix (non-breaking change which fixes an issue)
- [ ] 💥 Breaking Change (fix or feature that would cause existing functionality to not work as expected)
- [ ] 🔒 Security Fix / Vulnerability Patch
- [ ] ⚡ Performance Improvement
- [ ] 📚 Documentation Update / ADR
- [ ] 🔧 Refactoring / Technical Debt

## Architectural & Domain Boundary Compliance
- [ ] This change adheres to the single responsibility principle of this repository ($RepoName).
- [ ] Zero shared database access introduced; all cross-service communication is via declared API/Events.
- [ ] Backward compatibility of APIs/Events verified (or deprecation notice documented).
- [ ] An Architectural Decision Record (ADR) is included if architectural boundaries were altered.

## Security & Compliance Checklist
- [ ] Zero hardcoded secrets, API keys, or private certificates.
- [ ] Input validation and output sanitization implemented according to OWASP Top 10.
- [ ] Authentication and authorization scopes enforced.
- [ ] Audit logging added for state changes and financial operations.
- [ ] Dependency vulnerabilities verified with trivy and snyk.

## Testing & Quality Assurance
- [ ] Unit test coverage >= 85% on new code.
- [ ] Contract/Integration tests added or updated.
- [ ] Performance and benchmark tests run (for latency-critical paths).
- [ ] Rollback procedure verified in staging environment.

## Deployment & Operational Impact
- [ ] Database migrations are backward compatible (expand-contract pattern).
- [ ] Prometheus metrics and alerts added/updated.
- [ ] Runbook updated or newly created in /runbooks/.

---
### Reviewer Attestation
By approving this PR, the reviewer certifies that the changes have been inspected against OENEXA Enterprise Architecture and Security Standards.
"@

Write-IfMissing ".github/ISSUE_TEMPLATE/bug_report.md" @"
---
name: Bug Report
about: Report a defect or regression in $RepoName
title: "[BUG] <Short Description>"
labels: ["type: bug", "triage: required"]
assignees: ""
---

## Bug Description
<!-- Clear and concise description of the bug in $RepoName -->

## Service & Environment
- **Service Name:** $RepoName
- **Environment:** [Production / Staging / Development / Local]
- **Commit/Tag:** <!-- e.g., v1.0.0 / commit sha -->

## Steps to Reproduce
1. In $RepoName
2. Trigger action / send payload '...'
3. Observe error

## Expected vs Actual Behavior
- **Expected:** ...
- **Actual:** ...

## Telemetry Context
- **Request ID:** <!-- e.g. req-xxx -->
- **Trace ID:** <!-- e.g. 4bf92f3577b34da6a3ce929d0e0e4736 -->
"@

Write-IfMissing ".github/ISSUE_TEMPLATE/feature_request.md" @"
---
name: Feature Request
about: Propose a new feature or improvement for $RepoName
title: "[FEAT] <Short Description>"
labels: ["type: feature", "rfc: needed"]
assignees: ""
---

## Feature Summary
<!-- Describe the proposed capability -->

## Problem Statement / Business Rationale
<!-- Why is this needed in $RepoName? -->

## Proposed Solution & Architecture
<!-- High-level design and cross-service interaction -->

## Non-Functional Requirements
- [ ] Latency & Throughput Targets
- [ ] Zero Shared Database Adherence
- [ ] Backward Compatibility
"@

Write-IfMissing "CODEOWNERS" @"
# Global ownership for $RepoName
* @oenexa/core-architects @oenexa/domain-maintainers

# Security critical configurations
/security/ @oenexa/security-architects
/deploy/ @oenexa/devops-architects
/adr/ @oenexa/architecture-board
"@

# 3. Core Governance Markdown Files
Write-IfMissing "ARCHITECTURE.md" @"
# Architecture Specification: $RepoName

> **Domain:** $DomainType  
> **Status:** APPROVED & ACTIVE  
> **Classification:** Enterprise Architecture Baseline  

## 1. Domain Purpose & Responsibilities
$Description

## 2. Architectural Boundaries & Invariants
- **Single Responsibility:** $RepoName manages exclusively its bounded context.
- **Data Sovereignty:** Exclusively owns its datastore (db_$($RepoName.Replace('-','_'))). Zero cross-service database access.
- **Inter-service Communication:** Strictly via REST/gRPC synchronous APIs or CloudEvents asynchronous message bus.
- **Secret Management:** Dynamically fetched via Vault; zero static credentials.

## 3. Component Architecture & Data Flow
```mermaid
flowchart LR
    Client["Client / API Gateway"] -->|"REST / gRPC"| Service["$RepoName"]
    Service -->|"Read/Write"| DB[("Private Datastore")]
    Service -->|"CloudEvents"| Kafka["Kafka / NATS Event Bus"]
```
"@

Write-IfMissing "ROADMAP.md" @"
# Roadmap: $RepoName

## Q1 2026 - Q2 2026: Foundation & High Availability
- [x] Initial service scaffolding and domain interface definition.
- [x] GitOps pipeline integration via ArgoCD.
- [x] Enterprise observability (Prometheus/Grafana) integration.

## Q3 2026 - Q4 2026: Scale & Optimization
- [ ] Automated chaos engineering resilience validation.
- [ ] Post-quantum cryptography readiness audit.
- [ ] Multi-region active-active read replica support.
"@

Write-IfMissing "CHANGELOG.md" @"
# Changelog: $RepoName

All notable changes to this project will be documented in this file.
The format is based on Keep a Changelog, and this project adheres to Semantic Versioning.

## [1.0.0] - 2026-11-15
### Added
- Enterprise repository template alignment and standardized directory layout.
- Formalized ADR, Security, Deployment, Operations, and Runbook specifications.
- Baseline API contract and CloudEvents schema definitions.
"@

Write-IfMissing "CONTRIBUTING.md" @"
# Contributing to $RepoName

Thank you for contributing to the OENEXA ecosystem.

## Branching & Commit Workflow
1. Branch from main using standard naming: feat/<ticket>-<description> or fix/<ticket>-<description>.
2. Follow Conventional Commits: type(scope): description.
3. Ensure all tests pass: npm test or go test ./...
4. Ensure PR conforms to .github/PULL_REQUEST_TEMPLATE.md.
"@

Write-IfMissing "SECURITY.md" @"
# Security Policy: $RepoName

## Supported Versions
| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Reporting a Vulnerability
Please report security issues directly to the OENEXA Security Team via security@oenexa.com or submit an internal confidential report.
Do not disclose vulnerabilities in public issues or pull requests.
"@

Write-IfMissing "OPERATIONS.md" @"
# Operations Guide: $RepoName

## Service Level Objectives (SLOs)
- **Availability:** 99.99% uptime.
- **Latency:** P95 < 50ms, P99 < 150ms.
- **Error Budget:** <= 0.01% 5xx responses per 30-day window.

## Health Endpoints
- **Liveness:** GET /api/health/live -> 200 OK
- **Readiness:** GET /api/health/ready -> 200 OK
- **Metrics:** GET /metrics -> Prometheus format
"@

Write-IfMissing "DEPLOYMENT.md" @"
# Deployment Guide: $RepoName

## GitOps Architecture
All deployments to Staging and Production are managed declaratively by **ArgoCD**.
- **Staging Application:** oenexa-staging-$RepoName
- **Production Application:** oenexa-prod-$RepoName

## Continuous Delivery Process
1. PR merged to main triggers CI pipeline (lint, test, security scan, docker build).
2. Signed container image pushed to internal container registry with Cosign.
3. ArgoCD detects updated tag in Git and reconciles cluster state.
4. Health checks verified before traffic shift.
"@

Write-IfMissing "RUNBOOK.md" @"
# Operations Runbook: $RepoName

## Incident Escalation Matrix
- **Level 1:** SRE On-Call (PagerDuty)
- **Level 2:** $RepoName Domain Lead
- **Level 3:** Enterprise Architecture & Security Board

## Quick Diagnostic Commands
```bash
# Check pod status
kubectl get pods -n oenexa-production -l app=$RepoName

# Stream recent logs
kubectl logs -n oenexa-production -l app=$RepoName --tail=100 -f

# Check recent Prometheus alerts
curl -s http://prometheus.oenexa.internal/api/v1/alerts
```
"@

Write-IfMissing "API.md" @"
# API Specification: $RepoName

> **Synchronous Protocol:** REST (OpenAPI 3.1) / gRPC (HTTP/2)  
> **Base Path:** /v1  
> **Auth:** Bearer JWT issued by id.oenexa.com (RFC 9068)  

Detailed OpenAPI specifications are maintained in /api/v1/openapi.json.
"@

Write-IfMissing "EVENTS.md" @"
# Events Specification: $RepoName

> **Asynchronous Protocol:** CloudEvents v1.0 over Kafka / NATS  
> **Schema Standard:** JSON Schema / Apache Avro  

## Emitted Events
- com.oenexa.$($RepoName.Replace('-','.')).state_changed.v1

Detailed schemas are maintained in /events/v1/.
"@

# 4. Architecture Decision Records
Write-IfMissing "adr/template.md" @"
# ADR-[NUMBER]: [TITLE]

- **Status:** [Proposed | Accepted | Superseded | Deprecated]
- **Deciders:** [List of Architects and Domain Leads]
- **Date:** [YYYY-MM-DD]

## Context and Problem Statement
<!-- Context description -->

## Decision Drivers
* Driver 1: Zero shared database constraint
* Driver 2: High availability and sub-second failover

## Decision Outcome
Chosen option: "[Option Title]", because [rationale].
"@

Write-IfMissing "adr/0001-record-architecture-decisions.md" @"
# ADR-0001: Record Architecture Decisions in $RepoName

- **Status:** Accepted
- **Deciders:** Enterprise Architecture Board, Domain Lead
- **Date:** 2026-11-15

## Context and Problem Statement
We need an immutable, transparent method to record architectural and design decisions for $RepoName.

## Decision Outcome
We will use Architectural Decision Records (ADRs) following the MADR format within the /adr/ directory of this repository.
"@

# 5. Security & Threat Model
Write-IfMissing "security/threat-model.md" @"
# Threat Model: $RepoName

## STRIDE Analysis
- **Spoofing:** Mitigated via mTLS between internal services and JWT validation from id.oenexa.com.
- **Tampering:** In-transit TLS 1.3 encryption; database encryption at rest (AES-256-GCM).
- **Repudiation:** Cryptographically signed immutable audit logs.
- **Information Disclosure:** Strict PII redaction and zero-log policy for sensitive keys.
- **Denial of Service:** Ingress rate limiting and HPA autoscaling.
- **Elevation of Privilege:** Strict RBAC and zero-trust service account permissions.
"@

# 6. Monitoring & Runbooks
Write-IfMissing "monitoring/prometheus/rules.yaml" @"
groups:
  - name: $RepoName-alerts
    rules:
      - alert: ServiceDown
        expr: up{service=\"$RepoName\"} == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: \"$RepoName instance is down\"
          description: \"Pod for $RepoName has been down for more than 1 minute.\"
      - alert: High5xxRate
        expr: rate(http_requests_total{service=\"$RepoName\",status=~\"5..\"}[5m]) > 0.05
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: \"Elevated 5xx error rate on $RepoName\"
"@

Write-IfMissing "runbooks/RB-001-service-degradation.md" @"
# RB-001: Mitigating Service Degradation on $RepoName

## Symptoms
- Alert High5xxRate or HighLatency firing.
- Influx of HTTP 502/503 errors on the Ingress Gateway.

## Immediate Triage Steps
1. **Verify Pod Status:** kubectl get pods -n oenexa-production -l app=$RepoName
2. **Inspect Memory/CPU:** kubectl top pods -n oenexa-production -l app=$RepoName
3. **Check Downstream Connectivity:** Verify database connectivity and Redis cache response time.
4. **Trigger Pod Restart (if stuck):** kubectl rollout restart deployment/$RepoName -n oenexa-production
5. **Rollback (if post-deployment):** argocd app rollback oenexa-prod-$RepoName
"@

# 7. GitOps K8s Manifests
Write-IfMissing "deploy/base/deployment.yaml" @"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $RepoName
  labels:
    app.kubernetes.io/name: $RepoName
    app.kubernetes.io/part-of: oenexa
spec:
  replicas: 2
  selector:
    matchLabels:
      app: $RepoName
  template:
    metadata:
      labels:
        app: $RepoName
    spec:
      containers:
        - name: $RepoName
          image: oenexa/$RepoName:latest
          ports:
            - containerPort: 8080
          readinessProbe:
            httpGet:
              path: /api/health/ready
              port: 8080
            initialDelaySeconds: 5
            periodSeconds: 10
          livenessProbe:
            httpGet:
              path: /api/health/live
              port: 8080
            initialDelaySeconds: 15
            periodSeconds: 20
          resources:
            requests:
              cpu: 100m
              memory: 128Mi
            limits:
              cpu: 500m
              memory: 512Mi
"@

Write-IfMissing "deploy/base/service.yaml" @"
apiVersion: v1
kind: Service
metadata:
  name: $RepoName
  labels:
    app.kubernetes.io/name: $RepoName
spec:
  type: ClusterIP
  ports:
    - port: 8080
      targetPort: 8080
      protocol: TCP
      name: http
  selector:
    app: $RepoName
"@

Write-IfMissing "deploy/base/kustomization.yaml" @"
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
  - service.yaml
"@

Write-Host "Completed scaffolding for $RepoName."
