# Deploy reddit-app to Amazon

Preparing and starting reddit-app image in Amazon Web Services. Applicable for free-tier accounts.

## Prerequisites

- aws free tier account
- packer
- terraform

## Preparing the image with packer

In packer dir, copy `ubuntu-16-aws-vars-example.json` to `ubuntu-16-aws-vars.json` and edit it according to your setup. Put any other variables reported by inspect there.

```
cd packer && packer build --var-file=ubuntu16-aws-vars.json ubuntu16-aws.json
```

Record resulting AMI id somewhere.

## Launching the instance using terraform

In terrawform-aws folder, copy terraform.tfvars.example to terraform.tfvars, edit it and launch terraform as usual:

```
terraform --var ami=ami-9dd9c0e6 plan
terraform --var ami=ami-9dd9c0e6 apply
```

Connect to the public_ip:9292

