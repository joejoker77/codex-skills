#!/usr/bin/env bash
# Refuse a change that edits its own examiner, unless a human said otherwise.
#
# `.github/` and `ci/` are the gates. A pull request that modifies them is asking to be judged by
# rules it wrote, which is the one thing no automatic check can sensibly allow. The label is the
# human saying "I have read this one myself".
#
#   gate-sensitive-paths.sh <base-ref> [labels...]
set -uo pipefail
BASE="${1:-origin/main}"
shift || true
LABELS="$*"

PROTECTED='^(\.github/|ci/)'
changed=$(git diff --name-only "$BASE"...HEAD 2>/dev/null || git diff --name-only "$BASE" 2>/dev/null)
hits=$(printf '%s\n' "$changed" | grep -E "$PROTECTED" || true)

if [ -z "$hits" ]; then
  echo "sensitive-paths: nothing protected was touched"
  exit 0
fi

echo "sensitive-paths: this change edits the checks themselves:"
printf '%s\n' "$hits" | sed 's/^/  /'

case " $LABELS " in
  *" sensitive-path-approved "*)
    echo "sensitive-paths: allowed — a human applied sensitive-path-approved"
    exit 0 ;;
esac

echo "sensitive-paths: BLOCKED. A person has to read this one and add the"
echo "                 'sensitive-path-approved' label. That is not a formality:"
echo "                 everything else in this pipeline trusts these files."
exit 1
