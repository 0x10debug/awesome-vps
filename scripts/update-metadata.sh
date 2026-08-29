#!/usr/bin/env bash
# update-metadata.sh — Query GitHub API for repo activity and update README activity markers
#
# Usage:
#   ./scripts/update-metadata.sh --check    # Check only, print report, do not modify README
#   ./scripts/update-metadata.sh --update   # Update activity markers in README.md and README.zh.md
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
README_FILES=("README.md" "README.zh.md")
ACTIVE_DAYS=180
MAINTAINED_DAYS=365

usage() {
    cat <<EOF
Usage: $0 --check | --update
  --check   Query GitHub API and print a report; do not modify README files.
  --update  Query GitHub API and rewrite activity markers in README files.
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

# Collect unique owner/repo from all README files (excluding fenced code blocks).
declare -a REPOS=()
declare -A SEEN=()
for file in "${README_FILES[@]}"; do
    [ -f "$file" ] || continue
    # awk prints github.com owner/repo URLs only when outside ``` fences.
    while IFS= read -r repo; do
        [ -z "$repo" ] && continue
        if [ -z "${SEEN[$repo]:-}" ]; then
            SEEN[$repo]=1
            REPOS+=("$repo")
        fi
    done < <(awk '
        /^```/ { fence = !fence; next }
        fence { next }
        {
            while (match($0, /https:\/\/github\.com\/[A-Za-z0-9_.-]+\/[A-Za-z0-9_.-]+/)) {
                print substr($0, RSTART + 19, RLENGTH - 19)
                $0 = substr($0, RSTART + RLENGTH)
            }
        }' "$file" | sort -u)
done

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

# --update: rewrite the leading marker on every tool line in each README.
# Tool line shape: ^- <OLD_MARKER> [Name](https://github.com/owner/repo) ...
# We replace <OLD_MARKER> with the freshly computed one.
UPDATED_LINES=0
for file in "${README_FILES[@]}"; do
    [ -f "$file" ] || continue
    tmp="${file}.tmp-meta.$$"
    : > "$tmp"
    in_fence=0
    while IFS= read -r line || [ -n "$line" ]; do
        # Track fenced code blocks (``` ... ```); skip tool-line rewriting inside them.
        case "$line" in
            '```'*) in_fence=$((1 - in_fence)); printf '%s\n' "$line" >> "$tmp"; continue ;;
        esac
        if [ "$in_fence" -eq 1 ]; then
            printf '%s\n' "$line" >> "$tmp"
            continue
        fi
        # Match a tool entry whose link points to a github.com owner/repo.
        # Shape: "- <marker> [Name](https://github.com/owner/repo) ..."
        if [[ "$line" =~ ^-\ (🟢|🟡|🔴|⚫)\ \[ ]]; then
            repo=$(printf '%s' "$line" | grep -oE 'https://github\.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+' | head -1 | sed 's#https://github.com/##' || true)
            [ -z "$repo" ] && { printf '%s\n' "$line" >> "$tmp"; continue; }
            new_marker="${META_MARKER[$repo]:-}"
            if [ -n "$new_marker" ]; then
                rest="${line#*- }"
                rest="${rest#🟢 }"
                rest="${rest#🟡 }"
                rest="${rest#🔴 }"
                rest="${rest#⚫ }"
                printf -- '- %s %s\n' "$new_marker" "$rest" >> "$tmp"
                UPDATED_LINES=$((UPDATED_LINES + 1))
                continue
            fi
        fi
        printf '%s\n' "$line" >> "$tmp"
    done < "$file"
    mv "$tmp" "$file"
done

echo ""
echo "Updated $UPDATED_LINES tool entries across ${#README_FILES[@]} README files."
echo "Report saved to $REPORT"
