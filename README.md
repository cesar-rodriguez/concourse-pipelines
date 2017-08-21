Terraform pipeline
===================
Steps:
1. Code = Initiate the pipeline through a pull request, commit, or merge
2. Scan = Scans the terraform templates for security and quality
3. Build = Produces a terraform plan file
4. Test = Provision infrastructure in test environment and use something like kitchen-terraform or serverspec to test
5. Release = Creates a release in github
6. Provision = Provision infrastructure

Code
----
The pipeline is initiated through a PR/commit (only scan/test), or merge to master.

Scan
-----
Static code analysis of the terraform templates to ensure security, operations, and development best practices are followed. Any blockers will stop the pipeline and any issues that are non-blocking are captured as github issues. It's important to block any dangerous operations at this step prior to running test.

Build
------
Produces a terraform plan file that is stored in S3. The following commands are executed.
- Terraform fmt
- Terraform init
- Terraform plan (plan outputs should be saved into github PRs)

Test
------
Provision infrastructure in test environment and use something like kitchen-terraform or serverspec to test. The following types of tests will be performed:
- Unit tests = test single terraform modules
- Integration tests = tests infrastructure as a whole

 Release
 ---------
 Once the code is merges to master a new release is created.

 Provision
 ----------
 Provisions infrastructure to the specified environment and runs a smoke test to ensure everything works as expected.

Merges to master
=================
Any merges to master go through the pipeline. If any of the steps fail, the commit is reverted.


Pipeline flow
==============
For deployments:
Scan -> Build -> RC -> email for manual review -> apply -> git-hub release

Setting up pipeline
====================
fly -t tutorial sp --config ci/pipeline.yml --pipeline terraform -n --load-vars-from ci/credentials.yml --var "github-private-key=$(cat ~/.ssh/id_rsa_pub_github_no_pass)"
