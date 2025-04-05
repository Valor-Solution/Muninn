#!/bin/bash

# Configuration: update these variables
GITHUB_TOKEN="<GITHUB TOKEN HERE>"
ORG="Valor-Solution"
WORKFLOW_FILE=".github/workflows/sync_to_s3.yml"  # Adjust the workflow file name/path if needed
REPO_LIST="reposWithWorkflow.txt"  # File containing one repository name per line

# Check if the repository list file exists
if [[ ! -f "$REPO_LIST" ]]; then
  echo "Repository list file '$REPO_LIST' not found!"
  exit 1
fi

# Process each repository in the list
while IFS= read -r repo || [[ -n "$repo" ]]; do

# while IFS= read -r repo; do
  echo "Checking repository: $repo"
  
  # Build the GitHub API URL for the workflow file in the repository
  API_URL="https://api.github.com/repos/$ORG/$repo/contents/$WORKFLOW_FILE"
  
  # Retrieve the file content via the GitHub API
  response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "$API_URL")
  
  # Check if the workflow file exists
  if echo "$response" | grep -q "Not Found"; then
    echo "  Workflow file not found in $repo"
    continue
  fi
  
  # Extract and decode the base64-encoded file content
  encoded_content=$(echo "$response" | jq -r '.content')


  decoded_content=$(echo "$encoded_content" | base64 --decode)
  
  # Check if the secret is referenced in the file
  if echo "$decoded_content" | grep -q "secrets.ORG_AWS_SECRET_ACCESS_KEY"; then
    echo "  SUCCESS: Workflow found and secret name correct."
  else
    echo "  ERROR: Workflow found, but secret name NOT found in $repo"
  fi
  
  echo ""
done < "$REPO_LIST"