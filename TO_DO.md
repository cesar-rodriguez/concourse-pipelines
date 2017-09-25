To do
======

- **Resources** - Add GitHub AuthN to Vault resource
- **Docker images** - Create docker image for terrascan
- **Docker images** - Create docker image for terraform that includes AWS provider
- **All Pipelines** - Require GPG signed commits to run the pipeline
- **All Pipelines** - Add dynamic analysis checks. This would be check against AWS for things like provisioning EC2 instances in public subnets and other checks that can't be done relying solely on the terraform template
- **Commit Pipeline** - Add capability to terrascan task to capture any issues found as GitHub issues in the infrastructure repository
- **Commit Pipeline** - Add post provisioning smoke test/roleback capability
- **Commit Pipeline** - Add release notes
