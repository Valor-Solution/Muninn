# GitHub Action: Git Bundle Backup to S3

## Overview

This repo provides the template github action to create a complete Git bundle of your repository each time changes are pushed to the main line of a given branch, then uploads this bundle to an AWS S3 bucket for backup and archival purposes.

## Workflow Trigger

- Triggered on every `push` event to the main line of the specified branch (e.g., `master`, `main`, or any other primary branch).

## Workflow Steps

### 1. **Set Timestamp**
Generates a timestamp used for naming the bundle file.

### 2. **Clone Repository as Mirror**
Clones the repository as a mirrored repository using a Personal Access Token (`PAT`) stored in GitHub Secrets.

### 3. **Create Git Bundle**
Creates a Git bundle file containing all repository references (branches, tags, etc.)

**Bundle Filename Format:**
```
<repository-name>-<timestamp>.bundle
```

Example:
```
my-repo-20230405T121212Z.bundle
```

### 4. **Upload Bundle to S3**
Uploads the created Git bundle to the specified AWS S3 bucket (`valorrepositorybackup`). AWS credentials are securely stored at the GitHub Organization level and shared with all repositories within the organization.

## GitHub Secrets Configuration

Ensure the following GitHub Secret is configured for the repository:

- `PAT`: GitHub Personal Access Token with repository access.

AWS credentials are pre-configured at the GitHub Organization level and shared across all repositories:

- `ORG_AWS_ACCESS_KEY_ID`: AWS Access Key ID.
- `ORG_AWS_SECRET_ACCESS_KEY`: AWS Secret Access Key.

## AWS Configuration

- **Region:** `us-east-1`
- **S3 Bucket:** `valorrepositorybackup`

## Usage

1. Copy the workflow into your repo, and replace the trigger where it says master with your main-line branch like this:
```
on:
  push:
    branches:
      - <main-line-branch>
```

And that is it!

The workflow will automatically run when you merge to that branch, create a backup Git bundle, and store it safely in AWS S3.

---

*This automation ensures that a secure and accessible backup of your repository is maintained, facilitating easy recovery and archival.*

