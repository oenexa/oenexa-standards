$baseDir = "C:\workspace\oenexarepo"
$scaffoldScript = Join-Path $baseDir "oenexa-standards\scripts\scaffold-repo-template.ps1"

$repoConfigs = @(
    @{ Name = "oenexa-platform"; Domain = "Platform"; Desc = "Core shared enterprise SDKs, design tokens, micro-frontend shell components, cryptographic utilities, and foundational abstractions" },
    @{ Name = "oenexa-devops"; Domain = "Platform"; Desc = "Enterprise GitOps repository holding all ArgoCD application manifests, Helm charts, CI/CD reusable workflows, and deployment orchestration" },
    @{ Name = "oenexa-infra"; Domain = "Platform"; Desc = "Infrastructure as Code (IaC) managing cloud providers (Cloudflare, Bare-Metal, VPCs, Firewalls, Kubernetes Clusters)" },
    @{ Name = "oenexa-security"; Domain = "Platform"; Desc = "Enterprise security policies, HashiCorp Vault configurations, Open Policy Agent (OPA) rules, SOC 2 compliance frameworks, and GDPR control definitions" },
    @{ Name = "oenexa-docs"; Domain = "Platform"; Desc = "Unified developer portal, API catalog, architectural whitepapers, and customer-facing technical documentation" },
    @{ Name = "oenexa-architecture"; Domain = "Platform"; Desc = "Master architectural governance repository maintaining the 24 Enterprise Deliverables, enterprise ADRs, and ecosystem domain boundaries" },
    @{ Name = "oenexa-standards"; Domain = "Platform"; Desc = "Enterprise linting configurations, API style guides, commit conventions, shared tsconfig/eslint/prettier/golangci-lint rules" },
    @{ Name = "oenexa-identity"; Domain = "Identity/IAM"; Desc = "Sovereign IAM microservice handling OpenID Connect (OIDC), OAuth 2.1, in-memory PKCE authentication, and user credential management at id.oenexa.com" },
    @{ Name = "oenexa-wallet"; Domain = "Fintech/Wallet"; Desc = "High-security financial wallet service managing double-entry account balances, asset transfers, and multi-currency user vaults" },
    @{ Name = "oenexa-pay"; Domain = "Fintech/Payments"; Desc = "Sovereign tri-rail payment gateway orchestrating Crypto, Card/Stripe, and Bank/SEPA-SWIFT payments" },
    @{ Name = "oenexa-exchange"; Domain = "Trading/Exchange"; Desc = "Ultra-low latency, in-memory matching engine and order management system for institutional and retail trading" },
    @{ Name = "oenexa-market-data"; Domain = "Trading/MarketData"; Desc = "High-frequency market data distribution service broadcasting Level 1, Level 2, and Level 3 order book snapshots and trade streams" },
    @{ Name = "oenexa-liquidity"; Domain = "Fintech/Liquidity"; Desc = "Automated Market Maker (AMM) engine, internal liquidity routing, and external market maker bridging" },
    @{ Name = "oenexa-node"; Domain = "Blockchain/L1"; Desc = "Sovereign Layer 1 Native Blockchain full node client running JSON-RPC 2.0 at rpc.oenexa.com" },
    @{ Name = "oenexa-validator"; Domain = "Blockchain/L1"; Desc = "Proof-of-Stake / Proof-of-Authority validator daemon responsible for signing blocks and producing consensus" },
    @{ Name = "oenexa-explorer"; Domain = "Blockchain/L1"; Desc = "Block explorer web application and indexing backend for querying transactions, blocks, and addresses on the OENEXA L1 network" },
    @{ Name = "oenexa-contracts"; Domain = "Blockchain/Contracts"; Desc = "Smart contract repository for native tokens (ONXC, OENEXA USD), liquidity pools, and decentralized governance" },
    @{ Name = "oenexa-ai-core"; Domain = "AI/Inference"; Desc = "Enterprise AI gateway, inference orchestrator, model serving, and LLM fine-tuning pipelines" },
    @{ Name = "oenexa-ai-web"; Domain = "AI/UI"; Desc = "Interactive AI portal and assistant user interface for OENEXA generative and analytics workflows" },
    @{ Name = "oenexa-rag"; Domain = "AI/Data"; Desc = "Enterprise Retrieval-Augmented Generation (RAG) platform, document vectorization, chunking, and semantic search" },
    @{ Name = "oenexa-agents"; Domain = "AI/Autonomous"; Desc = "Autonomous multi-agent coordination platform, execution planners, tool-use sandboxes, and agent workflow engines" },
    @{ Name = "oengo-customer"; Domain = "Commerce/Mobile"; Desc = "Customer-facing mobile and web application portal for the OENGO on-demand logistics, food, and grocery delivery marketplace" },
    @{ Name = "oengo-merchant"; Domain = "Commerce/Merchant"; Desc = "Merchant portal and order management system for restaurants, supermarkets, and retail stores on OENGO" },
    @{ Name = "oengo-driver"; Domain = "Commerce/Fleet"; Desc = "Driver and courier mobile application for order dispatch, turn-by-turn navigation, delivery proof, and earnings tracking" },
    @{ Name = "oengo-admin"; Domain = "Commerce/Admin"; Desc = "Central back-office operations console for OENGO marketplace managers, support agents, and dispute resolution teams" },
    @{ Name = "oengo-api"; Domain = "Commerce/Backend"; Desc = "Unified API service for OENGO marketplace order matching, driver routing, and merchant catalog dispatch" },
    @{ Name = "oengo-web"; Domain = "Commerce/Frontend"; Desc = "Responsive web application portal for the OENGO on-demand marketplace" },
    @{ Name = "oenexa-core"; Domain = "Platform/Core"; Desc = "Core foundational services, system daemons, and backend utilities for OENEXA" },
    @{ Name = "oenexa-ui"; Domain = "Platform/Frontend"; Desc = "Unified ecosystem frontend web application hosted at app.oenexa.com" },
    @{ Name = "oenexa-design-system"; Domain = "Platform/UI"; Desc = "Design system component library, themes, typography, and UI widgets for OENEXA" }
)

Write-Host "Starting ecosystem-wide repository template upgrade across $($repoConfigs.Count) repositories..." -ForegroundColor Cyan

foreach ($cfg in $repoConfigs) {
    $repoDir = Join-Path $baseDir $cfg.Name
    if (Test-Path $repoDir) {
        & $scaffoldScript -RepoPath $repoDir -RepoName $cfg.Name -Description $cfg.Desc -DomainType $cfg.Domain
    } else {
        Write-Warning "Repository path $repoDir does not exist, skipping."
    }
}

Write-Host "All repositories successfully upgraded to OENEXA Enterprise Template Specification!" -ForegroundColor Green
