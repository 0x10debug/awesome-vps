#!/usr/bin/env bash
# validate-links.sh — Verify all URLs in README files are reachable (HTTP HEAD)
#
# Usage:
#   ./scripts/validate-links.sh                 # default timeout 15s
#   ./scripts/validate-links.sh --timeout 20    # custom timeout in seconds
#
# Exit code: 0 = all links OK, 1 = some links broken/unreachable

set -euo pipefail

README_FILES=("README.md" "README.zh.md")
TIMEOUT=15
FAILED=0
CHECKED=0

usage() {
    cat <<EOF
Usage: $0 [--timeout SECONDS]
  Checks all http(s) links in README files via curl HEAD (fallback GET).
  Exit 0 if all reachable, exit 1 if any broken.
EOF
    exit 1
}

while [ $# -gt 0 ]; do
    case "$1" in
        --timeout) TIMEOUT="$2"; shift 2 ;;
        -h|--help) usage ;;
        *) echo "Unknown argument: $1" >&2; usage ;;
    esac
done

# Extract URLs from markdown links: [text](url), skipping fenced code blocks.
extract_urls() {
    awk '
        /^```/ { fence = !fence; next }
        fence { next }
        {
            while (match($0, /\]\(https?:\/\/[^)]+\)/)) {
                s = substr($0, RSTART + 2, RLENGTH - 3)
                print s
                $0 = substr($0, RSTART + RLENGTH)
            }
        }
    ' "$1"
}

check_url() {
    local url="$1"
    local code
    # Use GET with a 1-byte range to minimize transfer while staying compatible
    # with servers that reject HEAD. Fall back to a plain GET if the server
    # ignores the Range header.
    code=$(curl -s -o /dev/null -L --max-time "$TIMEOUT" -r 0-0 -w '%{http_code}' "$url" 2>/dev/null || echo "000")
    if [ "$code" = "000" ]; then
        code=$(curl -s -o /dev/null -L --max-time "$TIMEOUT" -w '%{http_code}' "$url" 2>/dev/null || echo "000")
    fi
    if [ "$code" = "000" ] || { [ "$code" -ge 400 ] 2>/dev/null; }; then
        echo "  ❌ [$code] $url"
        return 1
    else
        echo "  ✅ [$code] $url"
        return 0
    fi
}

echo "Validating links in awesome-vps READMEs (timeout=${TIMEOUT}s)..."
echo ""

for file in "${README_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "⚠️  $file not found, skipping"
        continue
    fi

    echo "📄 $file"
    urls=$(extract_urls "$file" | sort -u)
    count=$(echo "$urls" | grep -c . || true)
    echo "   Found $count unique URLs"
    echo ""

    while IFS= read -r url; do
        [ -z "$url" ] && continue
        CHECKED=$((CHECKED + 1))
        if ! check_url "$url"; then
            FAILED=$((FAILED + 1))
        fi
    done <<< "$urls"

    echo ""
done

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Checked: $CHECKED  |  Failed: $FAILED"
if [ "$FAILED" -gt 0 ]; then
    echo "❌ Some links are broken. Please fix them."
    exit 1
else
    echo "✅ All links are reachable."
    exit 0
fi
