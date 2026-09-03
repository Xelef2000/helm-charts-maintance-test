#!/bin/bash

# --- CONFIGURATION ---
# The owner of the repository (your GitHub username or organization).
OWNER="Xelef2000"
# The name of the repository.
REPO="helm-charts-maintance-test"
# --- END CONFIGURATION ---

# Check if the GitHub token environment variable is set.
if [[ -z "$GITHUB_PAT" ]]; then
    echo "Error: GITHUB_PAT environment variable is not set."
    echo "Please set it by running: export GITHUB_PAT=\"your_token_here\""
    exit 1
fi

echo "Fetching all open issue numbers from ${OWNER}/${REPO}..."

# Use the GitHub API to get the numbers of all open issues.
# The 'jq' command extracts just the issue number from the JSON response.
# This handles up to 100 issues per page. For more, pagination logic would be needed.
ISSUE_NUMBERS=$(curl --silent \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token ${GITHUB_PAT}" \
  "https://api.github.com/repos/${OWNER}/${REPO}/issues?state=open&per_page=100" | jq '.[].number')

# Check if any open issues were found.
if [[ -z "$ISSUE_NUMBERS" ]]; then
    echo "No open issues found to close."
    exit 0
fi

echo "Found open issues: ${ISSUE_NUMBERS}"

# Loop through each issue number and send a PATCH request to close it.
for ISSUE_NUMBER in $ISSUE_NUMBERS; do
  echo "Closing issue #${ISSUE_NUMBER}..."
  curl --silent -X PATCH \
    -H "Accept: application/vnd.github.v3+json" \
    -H "Authorization: token ${GITHUB_PAT}" \
    "https://api.github.com/repos/${OWNER}/${REPO}/issues/${ISSUE_NUMBER}" \
    -d '{"state":"closed"}'
done

echo "All open issues have been successfully closed."
