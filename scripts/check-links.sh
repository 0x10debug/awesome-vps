#!/usr/bin/env bash
# check-links.sh — Verify all URLs in README files are reachable
# Usage: ./scripts/check-links.sh
# Exit code: 0 = all links OK, 1 = some links broken

set -euo pipefail

README_FILES=("README.md" "README.zh.md")
FAILED=0
CHECKED=0
TIMEOUT=10

# Extract URLs from markdown links: [text](url)
extract_urls() {
    grep -oE '\]\(https?://[^)]+\)' "$1" | sed 's/^](//; s/)$//'
}

check_url() {
    local url="$1"
    local code
    code=$(curl -s -o /dev/null -L --max-time "$TIMEOUT" -w '%{http_code}' "$url" 2>/dev/null || echo "000")
    if [ "$code" = "000" ] || [ "$code" -ge 400 ] 2>/dev/null; then
        echo "  ❌ [$code] $url"
        return 1
    else
        echo "  ✅ [$code] $url"
        return 0
    fi
}

main() {
    echo "Checking links in awesome-vps READMEs..."
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
}

main "$@"
