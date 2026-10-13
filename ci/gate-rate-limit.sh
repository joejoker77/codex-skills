#!/usr/bin/env bash
# One author, five pull requests, one day. Past that, a human decides.
#
# The limit is not about spam for its own sake: a compromised account's first move is volume, and
# volume is what exhausts the attention of the people reviewing. Five a day is enough for anyone
# working normally and slow enough that a flood is visible.
#
# The override label is not a weakness in it. A limit with no way past it gets switched off the
# first time it is wrong about somebody legitimate — and a switched-off limit protects nothing.
# The old platform had this gate WITHOUT the label, and that is exactly how it ended up ignored.
#
#   gate-rate-limit.sh <author> [labels...]
# Environment: GITHUB_REPOSITORY, GH_TOKEN (as GitHub Actions provides them)
set -uo pipefail
AUTHOR="${1:-}"
shift || true
LABELS="$*"
LIMIT="${RATE_LIMIT_PER_DAY:-5}"

case " $LABELS " in
  *" rate-limit-override "*)
    echo "rate-limit: allowed — a human applied rate-limit-override"
    exit 0 ;;
esac

[ -n "$AUTHOR" ] || { echo "rate-limit: no author given; skipping"; exit 0; }
[ -n "${GITHUB_REPOSITORY:-}" ] || { echo "rate-limit: not running in CI; skipping"; exit 0; }

since=$(date -u -d '24 hours ago' +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -v-24H +%Y-%m-%dT%H:%M:%SZ)
count=$(curl -sS -H "Authorization: Bearer ${GH_TOKEN:-}" -H "Accept: application/vnd.github+json" \
  "https://api.github.com/search/issues?q=repo:${GITHUB_REPOSITORY}+type:pr+author:${AUTHOR}+created:>${since}" \
  | python3 -c 'import json,sys; print(json.load(sys.stdin).get("total_count", 0))' 2>/dev/null || echo 0)

echo "rate-limit: ${AUTHOR} opened ${count} pull request(s) in the last 24h (limit ${LIMIT})"
if [ "${count:-0}" -gt "$LIMIT" ]; then
  echo "rate-limit: BLOCKED. Add 'rate-limit-override' if this is legitimate — and if it is"
  echo "            happening often, the limit is the wrong number, not the wrong idea."
  exit 1
fi
exit 0
