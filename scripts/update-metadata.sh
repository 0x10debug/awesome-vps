#!/usr/bin/env bash
# update-metadata.sh — Query GitHub API for repo activity and update activity markers
#
# Usage:
#   ./scripts/update-metadata.sh --check    # Check only, print report, do not modify anything
#   ./scripts/update-metadata.sh --update   # Update activity_status in data/tools.yaml
#
# data/tools.yaml is the single source of truth. After --update, regenerate
# the READMEs with: ./scripts/generate-readme.sh --lang all
#
# Activity markers:
#   🟢 Active    — commit within the last 6 months
#   🟡 Maintained — commit within the last 6-12 months
#   🔴 Stagnant  — no commit in 12+ months
#   ⚫ Archived  — repository is archived
#
# Auth: prefers `gh` CLI (gh auth), falls back to GITHUB_TOKEN env var.
# Report: written to /tmp/awesome-vps-metadata-report.txt

set -euo pipefail

MODE=""
REPORT="/tmp/awesome-vps-metadata-report.txt"
DATA_FILE="data/tools.yaml"
ACTIVE_DAYS=180
MAINTAINED_DAYS=365

usage() {
    cat <<EOF
Usage: $0 --check | --update
  --check   Query GitHub API and print a report; do not modify anything.
  --update  Query GitHub API and rewrite activity_status in data/tools.yaml.
            Re-run ./scripts/generate-readme.sh --lang all afterwards to refresh READMEs.
EOF
    exit 1
}

for arg in "$@"; do
    case "$arg" in
        --check) MODE="check" ;;
        --update) MODE="update" ;;
        -h|--help) usage ;;
        *) echo "Unknown argument: $arg" >&2; usage ;;
    esac
done

[ -z "$MODE" ] && usage

# Resolve GitHub auth. Prefer `gh`; fall back to GITHUB_TOKEN.
if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
    GH_AVAILABLE=1
else
    GH_AVAILABLE=0
fi

if [ "$GH_AVAILABLE" -eq 0 ] && [ -z "${GITHUB_TOKEN:-}" ]; then
    echo "ERROR: no GitHub auth available. Run 'gh auth login' or set GITHUB_TOKEN." >&2
    exit 2
fi

# api_query owner/repo -> prints "pushed_at|stars|archived" or "ERROR"
api_query() {
    local repo="$1"
    if [ "$GH_AVAILABLE" -eq 1 ]; then
        gh api "repos/$repo" --jq '"\(.pushed_at)|\(.stargazers_count)|\(.archived)"' 2>/dev/null \
            || echo "ERROR"
    else
        curl -fsSL -H "Authorization: token $GITHUB_TOKEN" \
            "https://api.github.com/repos/$repo" 2>/dev/null \
            | python3 -c 'import sys,json
try:
    d=json.load(sys.stdin)
    print(f"{d[\"pushed_at\"]}|{d[\"stargazers_count\"]}|{d[\"archived\"]}")
except Exception:
    print("ERROR")'
    fi
}

# marker_for pushed_at archived -> emoji
marker_for() {
    local pushed="$1" archived="$2"
    if [ "$archived" = "true" ]; then
        echo "⚫"
        return
    fi
    local now_epoch pushed_epoch
    now_epoch=$(date +%s)
    # Parse ISO 8601 UTC (strip trailing Z) to epoch seconds.
    pushed_epoch=$(python3 -c 'import sys,datetime
try:
    s=sys.argv[1].rstrip("Z")
    dt=datetime.datetime.fromisoformat(s)
    print(int(dt.replace(tzinfo=datetime.timezone.utc).timestamp()))
except Exception:
    print(0)' "$pushed" 2>/dev/null || echo 0)
    if [ "$pushed_epoch" -eq 0 ]; then
        echo "🔴"
        return
    fi
    local diff_days=$(( (now_epoch - pushed_epoch) / 86400 ))
    if [ "$diff_days" -le "$ACTIVE_DAYS" ]; then
        echo "🟢"
    elif [ "$diff_days" -le "$MAINTAINED_DAYS" ]; then
        echo "🟡"
    else
        echo "🔴"
    fi
}

# Collect unique owner/repo from the YAML data source (data/tools.yaml).
# Only github.com URLs can be queried via the GitHub API; non-github tools
# (official sites, docs) are skipped and keep their existing activity_status.
if [ ! -f "$DATA_FILE" ]; then
    echo "ERROR: data source not found: $DATA_FILE" >&2
    exit 2
fi
declare -a REPOS=()
declare -A SEEN=()
while IFS= read -r repo; do
    [ -z "$repo" ] && continue
    if [ -z "${SEEN[$repo]:-}" ]; then
        SEEN[$repo]=1
        REPOS+=("$repo")
    fi
done < <(grep -oE 'https://github\.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+' "$DATA_FILE" \
    | sed 's#https://github.com/##' | sort -u)

# Query metadata for each repo.
declare -A META_MARKER
{
    echo "Awesome VPS metadata report"
    echo "Generated: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    echo "Mode: $MODE"
    echo "Repos checked: ${#REPOS[@]}"
    echo ""
    printf '%-45s %-12s %-8s %-9s %s\n' "REPO" "PUSHED_AT" "STARS" "ARCHIVED" "MARKER"
    printf '%-45s %-12s %-8s %-9s %s\n' "----" "---------" "-----" "--------" "------"
} > "$REPORT"

for repo in "${REPOS[@]}"; do
    raw=$(api_query "$repo")
    if [ "$raw" = "ERROR" ] || [ -z "$raw" ]; then
        META_MARKER[$repo]="🔴"
        printf '%-45s %-12s %-8s %-9s %s\n' "$repo" "unknown" "?" "?" "🔴" >> "$REPORT"
        continue
    fi
    pushed=$(echo "$raw" | cut -d'|' -f1)
    stars=$(echo "$raw" | cut -d'|' -f2)
    archived=$(echo "$raw" | cut -d'|' -f3)
    marker=$(marker_for "$pushed" "$archived")
    META_MARKER[$repo]="$marker"
    printf '%-45s %-12s %-8s %-9s %s\n' "$repo" "$pushed" "$stars" "$archived" "$marker" >> "$REPORT"
done

echo "" >> "$REPORT"
echo "Summary by marker:" >> "$REPORT"
for m in 🟢 🟡 🔴 ⚫; do
    n=0
    for repo in "${REPOS[@]}"; do
        [ "${META_MARKER[$repo]:-}" = "$m" ] && n=$((n + 1))
    done
    echo "  $m : $n" >> "$REPORT"
done

cat "$REPORT"

# In --check mode we stop here.
if [ "$MODE" = "check" ]; then
    exit 0
fi

# --update: rewrite the activity_status field in data/tools.yaml for every
# tool whose GitHub repo was queried. Comments and formatting are preserved by
# doing a targeted, line-based replacement (only the `activity_status:` line
# that follows a matching `url:` line is rewritten).
emoji_to_status() {
    case "$1" in
        🟢) echo "active" ;;
        🟡) echo "maintained" ;;
        🔴) echo "stagnant" ;;
        ⚫) echo "archived" ;;
        *)  echo "active" ;;
    esac
}

# Build a "repo<TAB>status" mapping for the Python rewriter.
MAP_FILE="$(mktemp)"
trap 'rm -f "$MAP_FILE"' EXIT
for repo in "${REPOS[@]}"; do
    marker="${META_MARKER[$repo]:-}"
    [ -z "$marker" ] && continue
    status=$(emoji_to_status "$marker")
    printf '%s\t%s\n' "$repo" "$status" >> "$MAP_FILE"
done

python3 - "$DATA_FILE" "$MAP_FILE" <<'PYEOF'
import re
import sys

data_file, map_file = sys.argv[1], sys.argv[2]

# repo -> new activity_status word
status_by_repo = {}
with open(map_file, encoding="utf-8") as f:
    for line in f:
        line = line.rstrip("\n")
        if not line:
            continue
        repo, status = line.split("\t", 1)
        status_by_repo[repo] = status

with open(data_file, encoding="utf-8") as f:
    lines = f.readlines()

# Walk the file; track the github owner/repo of the current tool block and
# rewrite the next `activity_status:` line that belongs to it.
current_repo = None
updated = 0
url_re = re.compile(r'^\s*url:\s*https://github\.com/([A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+)')
status_re = re.compile(r'^(\s*activity_status:\s*)(\S+)')

for i, line in enumerate(lines):
    m = url_re.match(line)
    if m:
        current_repo = m.group(1)
        continue
    if current_repo and current_repo in status_by_repo:
        sm = status_re.match(line)
        if sm:
            new_status = status_by_repo[current_repo]
            if sm.group(2) != new_status:
                lines[i] = f"{sm.group(1)}{new_status}\n"
                updated += 1
            current_repo = None  # consume; next status belongs to this block

with open(data_file, "w", encoding="utf-8") as f:
    f.writelines(lines)

print(f"Updated {updated} activity_status field(s) in {data_file}")
PYEOF

echo ""
echo "Next step: regenerate READMEs with ./scripts/generate-readme.sh --lang all"
echo "Report saved to $REPORT"
