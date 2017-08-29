terraform-pipeline
===================

A [Concourse CI](https://concourse.ci) pipeline for terraform.

Jobs:
1. **Code** = Initiate the pipeline through a commit or merge to the master branch on the infrastructure-repo. (To do: trigger pipeline through PRs)
2. **Scan** = Scans the terraform templates for security and quality
3. **Build** = Retrieve AWS STS tokens from Vault and produce a terraform plan file for each environment. The output is stored as a tar file in S3.
4. **Test** = Provision infrastructure in test environment and make sure terraform applies perform as expected.
5. **Provision** = Manually triggered to provision infrastructure by running `terraform apply` on all of the terraform plans
6. **Release** = Creates a release in github

Pipeline should flow as follows:
trigger -> scan -> build -> test -> send email for manual review of terraform plan -> provision -> release

Scanning
---------
Static code analysis of the terraform templates should be performed to ensure security, operations, and development best practices are followed. Any issues that are considered blockers will stop the pipeline from moving forward and any issues that are non-blocking should be captured as github issues.

It's important to block any dangerous operations at this step prior to running test.

Testing
--------
Provision infrastructure in test environment and use something like kitchen-terraform or serverspec to test. The following types of tests should be performed:
- Unit tests = test single terraform modules
- Integration tests = tests infrastructure as a whole

Provisioning
------------
Provisions infrastructure to the all specified environments and runs a smoke test to ensure everything works as expected.

Setting up the pipeline
=========================
A file named ci/credentials.yml should be created with all required variables and credentials, then the following fly command should be executed

fly -t terraform sp --config ci/pipeline.yml --pipeline terraform -n --load-vars-from ci/credentials.yml --var "github-private-key=$(cat ~/.ssh/id_rsa_pub_github_no_pass)"

Semantic versioning
====================
The provision step automatically bumps patch version number (e.g. 0.0.1 -> 0.0.2). The minor and major version bumps should be manually triggered prior to commits intended to that version. The following convention should be followed for bumping versions:
- **major**: Bump the major version number, e.g. 1.0.0 -> 2.0.0. when breaking changes are introduced to terraform templates.
- **minor**: Bump the minor version number, e.g. 0.1.0 -> 0.2.0. when non-breaking changes are introduced to terraform templates
- **patch**: Bump the patch version number, e.g. 0.0.1 -> 0.0.2. when minor changes are introduced to tfvars files.

To do
======
- Use [github-status-resource](https://github.com/dpb587/github-status-resource)
- Trigger pipeline through PR
- Add job for testing
- Better static code analysis. Should capture any issues found as github issues
- Email notifications
- Post provisioning smoke tests

