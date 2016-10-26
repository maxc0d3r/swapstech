Terraform config for setting up swapstech infrastructure on AWS. Please create a vars file (call it credentials) with following content -


```
access_key = "YOUR_ACCESS_KEY"
secret_key = "YOUR_SECRET_KEY"
key_name = "DESIRED_AWS_SSH_KEY_PAIR_NAME"
public_key_path = "PATH_TO_PUBLIC_SSH_KEY_ON_YOUR_MACHINE"
```

Install terraform from https://www.terraform.io/downloads.html.

See if configuration is working as expected by running  following command -
```
terraform plan -var-file credentials
```

If you are okay with the configuration explained by terraform plan, go ahead and apply the configuration using following command -
```
terraform apply -var-file credentials
```
