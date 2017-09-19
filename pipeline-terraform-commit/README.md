Setup
------
```bash
fly -t lite sp --config pipeline.yml --pipeline terraform-commit -n --load-vars-from credentials.yml --var "github-private-key=$(cat ~/.ssh/id_rsa_pub_github_no_pass)"
fly -t lite up --pipeline terraform-commit
```
