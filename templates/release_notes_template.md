# Release Notes - [SERVICE_NAME] v[MAJOR.MINOR.PATCH]

**Release Date:** YYYY-MM-DD  
**Git Commit / Tag:** `vX.Y.Z` (`[commit-sha]`)  
**Deployment Pipeline:** ArgoCD Application `[argo-app-name]`

## Highlights
<!-- Executive summary of key enhancements, regulatory additions, and architectural shifts -->

## What's Changed
### 🚀 New Features & Capabilities
- **[DOMAIN-XXX]** Feature description with PR link (@author).

### 🐛 Bug Fixes & Stability
- **[DOMAIN-YYY]** Bug fix description with PR link (@author).

### ⚡ Performance & Scale
- Benchmarked improvements in throughput, latency, or memory optimization.

### 🔒 Security & Compliance
- Security patch details, dependency updates, and audit verification.

## Breaking Changes & Migration Guide
> [!WARNING]
> Detailed instructions for dependent services, breaking API adjustments, or schema transitions.

## Verification & Rollback Procedures
- **Rollback Target:** `vX.Y.(Z-1)`
- **Automated Rollback Command:** `argocd app rollback [app-name] [revision]`
- **Smoke Test Suite:** `npm run test:smoke` or `go test -v ./tests/e2e/smoke`
