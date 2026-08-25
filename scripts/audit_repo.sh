#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

echo "Running public-portfolio safety audit..."

tracked_or_present_files=$(find . -type f -not -path './.git/*')

if printf '%s\n' "$tracked_or_present_files" | grep -E '/(\.env|secrets\.toml|connections\.toml)$|\.(pem|key|p8)$' >/dev/null; then
  echo "ERROR: secret-bearing filename detected"
  printf '%s\n' "$tracked_or_present_files" | grep -E '/(\.env|secrets\.toml|connections\.toml)$|\.(pem|key|p8)$'
  exit 1
fi

patterns='snowflakecomputing\.com|BEGIN ([A-Z ]+ )?PRIVATE KEY|AKIA[0-9A-Z]{16}|(password|passwd|api[_-]?key|access[_-]?token|client[_-]?secret)[[:space:]]*[:=][[:space:]]*[^<{$[:space:]]+'
if rg -n -i --hidden --glob '!.git/**' --glob '!scripts/audit_repo.sh' "$patterns" .; then
  echo "ERROR: review the possible secret or private identifier matches above"
  exit 1
fi

echo "PASS: no blocked filenames or high-confidence secret patterns found."
echo "Manual review is still required for names, metrics, screenshots, and business context."

