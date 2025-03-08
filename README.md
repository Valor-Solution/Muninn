# Muninn
## Objective: 
In the case of disaster, we need to have the repositories in github backed up somewhere else. 

## Strategy: 
Use GitHub actions to push any new changes to master up to an S3 bucket in a separate AWS account. 

## Scope
We are going to bundle and push all repositories in the valor organization that are not archived. Additionally there are two repos that appear to be basically empty so I will not include those either. 


## Design
The workflow should be simple:
- Trigger: on merge to "main-line"
- Bundle the repo
- Push the bundle into S3 with a timestamp for versioning.

# Execution

I copied the workflow into each repo's `.github/workflows`, set the trigger appropriately according to the main-line in each repository, and opened up a PR. I use the term "main-line" because each repo appears to have a different convention, but this seems to be the branch to which PR's get merged and the production branch is cut. Once the PR is merged, I expect that the workflow will be active and successful.






