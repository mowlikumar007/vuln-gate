#!/usr/bin/env bash
# Local dry run of the security gate (same policy as CI).
# Usage: ./scripts/scan-local.sh [Dockerfile|Dockerfile.vulnerable]
set -euo pipefail
cd "$(dirname "$0")/.."

DF="${1:-Dockerfile}"
TAG="demo-app:local-$(echo "$DF" | tr '.' '-' | tr 'A-Z' 'a-z')"

echo ">>> Building $DF as $TAG"
docker build -f "$DF" -t "$TAG" .

mkdir -p reports
echo ">>> Full report -> reports/$TAG.txt"
trivy image --scanners vuln --format table --output "reports/${TAG//:/_}.txt" "$TAG" || true

echo ">>> Applying severity gate from trivy.yaml"
if trivy image --config trivy.yaml "$TAG"; then
  echo "GATE: PASSED - image allowed to proceed to deployment"
else
  echo "GATE: FAILED - image blocked by severity policy"
  exit 1
fi
