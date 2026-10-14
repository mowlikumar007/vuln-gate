# Software Requirements Specification (SRS)

**Project:** Automated Container Vulnerability Scanner
**Event:** DevOps Community Hackathon 2026 (Dev Sprint'26), Bannari Amman Institute of Technology
**Problem Statement:** 21
**Version:** 1.0 - 14.10.2026
**Team:** _<fill in team name and members>_

## 1. Introduction

### 1.1 Purpose
This document specifies the requirements of a CI/CD workflow that scans container images for known vulnerabilities and prevents images exceeding a configured severity threshold from being deployed.

### 1.2 Scope
The system covers building a container image, scanning it with Trivy, generating vulnerability reports, enforcing a severity policy, and deploying compliant images to an externally accessible Linux server. It does not cover runtime protection, secret scanning, or production-grade release management.

### 1.3 Definitions
| Term | Meaning |
|------|---------|
| CVE | Common Vulnerabilities and Exposures identifier of a known vulnerability |
| Trivy | Open-source vulnerability scanner for container images |
| Severity threshold | Lowest severities that cause the pipeline to fail (CRITICAL, HIGH) |
| Gate | Pipeline step that fails the build on a policy violation |
| GHCR | GitHub Container Registry |

## 2. Overall Description

### 2.1 Product perspective
A GitHub Actions pipeline attached to a Git repository. Developers push code; the pipeline tests, builds, scans and (if compliant) deploys the container.

### 2.2 Users
- **Developer** - pushes changes and reads scan results.
- **Security reviewer** - reviews reports and the severity policy.
- **End user** - accesses the deployed application.

### 2.3 Operating environment
GitHub-hosted Ubuntu runners; target Linux server with Docker; Docker, Trivy, Python 3.12.

### 2.4 Constraints and assumptions
- Internet access from runners to the Trivy vulnerability database.
- A Linux server with Docker, open ports 22 and 80, and SSH access.
- GitHub Pages / Vercel / Netlify are not used for hosting.

## 3. Functional Requirements

| ID | Requirement |
|----|-------------|
| FR-1 | The system shall run automatically on every push to the repository. |
| FR-2 | The system shall run automated unit tests before building the image. |
| FR-3 | The system shall build a container image from a selectable Dockerfile. |
| FR-4 | The system shall scan the built image with Trivy. |
| FR-5 | The system shall generate a vulnerability report in table and JSON formats and retain it as a build artifact. |
| FR-6 | The system shall apply a configurable severity threshold (default CRITICAL, HIGH). |
| FR-7 | The system shall fail the pipeline when findings meet or exceed the threshold. |
| FR-8 | The system shall not run the deployment step when the scan fails. |
| FR-9 | The system shall push a compliant image to GHCR tagged with the commit SHA. |
| FR-10 | The system shall deploy the compliant image to an externally accessible Linux server over SSH. |
| FR-11 | The deployed application shall expose a `/health` endpoint. |
| FR-12 | The system shall provide a deliberately vulnerable image to demonstrate a policy-triggered failure. |

## 4. Non-Functional Requirements

| ID | Requirement |
|----|-------------|
| NFR-1 | Pipeline run time should stay under 10 minutes. |
| NFR-2 | The severity policy shall be changeable by editing one setting. |
| NFR-3 | Credentials shall be stored only as GitHub encrypted secrets. |
| NFR-4 | The secure image shall run as a non-root user. |
| NFR-5 | Reports shall be produced even when the gate fails. |

## 5. System Design

### 5.1 Architecture
See the diagram in `README.md`.

| Component | Technology |
|-----------|------------|
| Application | Python Flask |
| Container | Docker |
| Scanner | Trivy (via aquasecurity/trivy-action) |
| CI/CD | GitHub Actions |
| Registry | GitHub Container Registry |
| Hosting | Linux VM with Docker |

### 5.2 Pipeline stages
1. `test` - pytest
2. `scan` - build, full report, severity gate
3. `deploy` - push to GHCR, SSH deploy, health check

## 6. Test Plan

| ID | Scenario | Expected result |
|----|----------|-----------------|
| T-1 | Unit tests on the application | `/health` returns 200 |
| T-2 | Build `Dockerfile.vulnerable` and push | Scan fails, report shows HIGH/CRITICAL findings, deploy skipped |
| T-3 | Build `Dockerfile` (updated image) and push | Scan passes, deploy runs |
| T-4 | Open `http://<server>/health` after T-3 | Returns status ok with variant `secure` |
| T-5 | Change threshold and re-run | Gate behaviour changes accordingly |

## 7. Limitations and Future Work
- Add SBOM generation, image signing and secret/misconfiguration scanning.
- Add rollback or blue/green deployment.
- Publish scan results to GitHub code scanning (SARIF).
