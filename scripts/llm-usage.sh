#!/bin/bash
# =============================================================================
# LLM USAGE TRACKER
# =============================================================================
# Query LLM proxy for usage statistics
# Requires: jq, curl
# =============================================================================

set -euo pipefail

# Load API credentials from secure location
CREDENTIALS_FILE="$HOME/.zsh/private/api-keys.zsh"

if [[ ! -f "$CREDENTIALS_FILE" ]]; then
  echo "❌ Error: Credentials file not found at $CREDENTIALS_FILE"
  echo "Please create it with your API credentials:"
  echo "  touch '$CREDENTIALS_FILE'"
  echo "  chmod 600 '$CREDENTIALS_FILE'"
  echo "  # Edit and add your credentials:"
  echo "  # export LLM_API_KEY='your-key'"
  echo "  # export LLM_API_TOKEN='your-token'"
  echo "  # export LLM_API_BASE_URL='https://api.example.com'"
  exit 1
fi

# Source credentials
source "$CREDENTIALS_FILE"

# Validate required credentials
if [[ -z "${LLM_API_KEY:-}" ]]; then
  echo "❌ Error: LLM_API_KEY not set in $CREDENTIALS_FILE"
  exit 1
fi

if [[ -z "${LLM_API_TOKEN:-}" ]]; then
  echo "❌ Error: LLM_API_TOKEN not set in $CREDENTIALS_FILE"
  exit 1
fi

# Get date range (default to current year)
START_DATE="${1:-$(date +%Y-01-01)}"
END_DATE="${2:-$(date +%Y-12-31)}"

# Query API
echo "📊 Querying LLM usage from $START_DATE to $END_DATE..."

RESPONSE=$(curl -s "${LLM_API_BASE_URL}/user/daily/activity/aggregated?start_date=$START_DATE&end_date=$END_DATE" \
  -H "authorization: Bearer ${LLM_API_KEY}" \
  -H "cache-control: no-cache" \
  -H "content-type: application/json" \
  -b "token=${LLM_API_TOKEN}" \
  -H "pragma: no-cache" \
  -H "user-agent: Mozilla/5.0")

# Check if jq is available
if ! command -v jq &> /dev/null; then
  echo "❌ Error: jq is not installed. Install with: sudo apt install jq"
  exit 1
fi

# Parse and display results
TOTAL_SPEND=$(echo "$RESPONSE" | jq -r ".metadata.total_spend // 0")

if [[ "$TOTAL_SPEND" == "0" ]]; then
  echo "⚠️  Warning: No usage data found or API error"
  echo "Response: $RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
  exit 1
fi

echo "💰 Total Spend: \$$TOTAL_SPEND"

# Optional: Show detailed breakdown if available
if [[ "${SHOW_DETAILS:-false}" == "true" ]]; then
  echo ""
  echo "📈 Detailed Usage:"
  echo "$RESPONSE" | jq '.'
fi
