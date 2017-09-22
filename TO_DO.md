To do
======
Resources:
    - Add github based Authentication capabilities to Vault resource
Docker images:
    - Create one for terrascan
    - Create one for terraform that includes AWS provider
Pipeline:
    - Require GPG signed commits to run the pipeline
    - Add capability to terrascan task to capture any issues found as github issues in the infrastructure repository
    - Add dynamic analysis checks. This would be checks against AWS for things like provisioning EC2 instances in public subnets and other checks that can't be done relying solely on the terraform template
    - Add post provisioning smoke test/roleback capability
    - Add release notes
