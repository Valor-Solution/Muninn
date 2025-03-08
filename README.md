# Muninn
## Objective: 
In the case of disaster, we need to have the repositories in github backed up somewhere else. 

## Strategy: 
Use GitHub actions to push any new changes to master up to an S3 bucket in a separate AWS account. 

We should also look at permissions in github -- it looks like we can set who has permissions to delete repositories. You can set roles individually so that code-owners do not have the delete permission. 

I think having a backup is smart as well, but we should also use permissions to take a more proactive defensive stance.

## Scope
We are going to bundle and push all repositories in the valor organization that are not archived. Additionally there are two repos that appear to be basically empty so I will not include those either. 


The repositories are here in github:
https://github.com/Valor-solution

## Design
The workflow should be simple:
- Trigger: on merge to "main-line"
- Bundle the repo
- Push the bundle into S3 with a timestamp for versioning.

```yaml
name: Create and Push Git Bundle on Merge to Master

on:
  push:
    branches:
      - master

jobs:
  bundle-and-upload:
    runs-on: ubuntu-latest
    steps:
      - name: Set Timestamp
        id: timestamp
        # run: echo "::set-output name=ts::$(date -u +"%Y%m%dT%H%M%SZ")"
        run: echo "ts=$(date -u +"%Y%m%dT%H%M%SZ")" >> $GITHUB_OUTPUT

      - name: Clone Repository as Mirror
        run: | 
          git clone --mirror https://x-access-token:${{ secrets.PAT }}@github.com/${{ github.repository }} mirror-repo

      - name: Create Git Bundle
        run: |
          repo_name=$(basename "$GITHUB_REPOSITORY")
          TIMESTAMP=${{ steps.timestamp.outputs.ts }}
          cd mirror-repo
          git bundle create "../${repo_name}-${TIMESTAMP}.bundle" --all

      - name: Upload Bundle to S3
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          AWS_DEFAULT_REGION: us-east-1
          S3_BUCKET: valorrepositorybackup
        run: |
          repo_name=$(basename "$GITHUB_REPOSITORY")
          TIMESTAMP=${{ steps.timestamp.outputs.ts }}
          BUNDLE_NAME="${repo_name}-${TIMESTAMP}.bundle"
          aws s3 cp "$BUNDLE_NAME" "s3://${S3_BUCKET}/${BUNDLE_NAME}"

```


# Execution

I created a repo called `Muninn` to develop the workflow and store the "master copy". Once the approach was validated, I copied the workflow into each repo's `.github/workflows`, set the trigger appropriately according to the main-line in each repository, and opened up a PR. I use the term "main-line" because each repo appears to have a different convention, but this seems to be the branch to which PR's get merged and the production branch is cut. Once the PR is merged, I expect that the workflow will be active and successful.






