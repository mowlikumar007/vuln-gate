# Container Image Severity Policy

| Severity | Action |
|----------|--------|
| CRITICAL | **Block** - pipeline fails, image is not deployed |
| HIGH     | **Block** - pipeline fails, image is not deployed |
| MEDIUM   | Reported only, does not block |
| LOW / UNKNOWN | Reported only, does not block |

**Unfixed vulnerabilities** (no patch available yet) are ignored by the gate
(`ignore-unfixed: true`) because the team cannot remediate them. They still appear
in the full report.

## Where the policy is configured
- `.github/workflows/security-gate.yml` -> `env.SEVERITY_THRESHOLD` and `env.IGNORE_UNFIXED`
- `trivy.yaml` -> same values for local scans
- `.trivyignore` -> explicit, documented exceptions (empty by default)

## Changing the threshold
Edit `SEVERITY_THRESHOLD`, e.g. `"CRITICAL"` to block only critical findings.
