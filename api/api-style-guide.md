# OENEXA Global API Style Guide

## 1. Resource Naming
- URIs must use kebab-case, plural nouns: `/v1/wallets`, `/v1/orders`, `/v1/merchants`.
- Verbs in URIs are forbidden. Action triggers must use sub-resources or state transitions:
  - ❌ `POST /v1/send-money`
  - ✅ `POST /v1/transfers`

## 2. Mandatory Tracing & Correlation
Every HTTP request must accept and propagate:
- `X-Correlation-Id`: Distributed tracing span ID across service boundaries.
- `Idempotency-Key`: Mandatory on all mutating requests (`POST`, `PATCH`, `DELETE`) to prevent duplicate processing.

## 3. Error Responses
All errors must strictly format responses according to **RFC 7807 (Problem Details for HTTP APIs)**:
```json
{
  "type": "https://api.oenexa.com/errors/insufficient-balance",
  "title": "Insufficient Balance",
  "status": 422,
  "detail": "Account 0x... has 1.25 ONXC available; required 5.00 ONXC.",
  "instance": "/v1/transfers/tx_991823"
}
```

## 4. API Versioning
- Major versions are embedded in the URI path (`/v1/`, `/v2/`).
- Deprecated endpoints must return the `Sunset: <date>` HTTP header and remain active for a minimum of 6 months.
