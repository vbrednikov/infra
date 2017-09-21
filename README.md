# Infra

This repo contains configuration to prepare and run sample reddit-app project in Google Cloud: https://github.com/Artemmkin/reddit.

There are several ways to start and deploy the instances:
- "fry" base ubuntu/debian image with shell scripts: install ruby, mongodb, app to base version
- prepare "baked" images with builtin app dependencies using packer
- using terraform
- to be continued ...

## Repo layout

**ansible** contains ansible cookbooks to prepare environment for running reddit:
- `ansible/reddit_app.yml`: installs ruby and bundler
- `ansible/reddit_db.yml`: installs mongodb
- `ansible/reddit.yml`: installs reddit application
- `ansible/immutable.yml`: installs everything (including the application itself) on one vm
- `ansible/os_update.yml`: does equivalent of apt-get update && apt-get upgrade

These cookbooks are used by packer (see below) to bake correct images.

**packer** dir contains packer configuration to prepare images in Google Cloud:
- `packer/app.json` -- prepare image with ruby and bundler
- `packer/db.json` -- image with mongodb
- `packer/immutable.json` -- all-in-one image with deployed reddit app
- `packer/ubuntu16.json` -- base image with ruby and mongo, without the app

**terraform** dir contains terraform configuration and modules to start instances in Google Cloud:
- `terraform/prod` -- production configuration
- `terraform/stage` -- staging

## Prerequisites

1. Google cloud account
2. Google Cloud SDK (https://cloud.google.com/sdk/downloads)
3. Packer (https://www.packer.io/downloads.html)
4. Ansible

The app uses TPC port 9292 for external comminucation, you need to open it in Google cloud firewall. In the examples below, network firewall tag "puma-server" is used to allow it. You can create this rule using the following command:

```
gcloud compute firewall-rules create default-puma-server2 --allow=tcp:9292 --description="Reddit app on puma server" --direction=IN --network=default --target-tags=puma-server
```

## Raw gcloud version

"Fry" the instance from base OS image using startup script. You will get an instance with ruby, mongodb and reddit app running on port 9292. Tested with Ubuntu 1604, probably will work with Debian.

**Local**

The command below should be executed in the cloned infra repo.
```
gcloud compute instances create \
          --boot-disk-size=10GB --image-family=ubuntu-1604-lts \
          --image-project=ubuntu-os-cloud --machine-type=g1-small \
          --tags puma-server --restart-on-failure --zone=europe-west1-b \
          --metadata-from-file startup-script=scripts/start_all.sh \
          reddit-app
```

**From github**

```
gcloud compute instances create \
          --boot-disk-size=10GB --image-family=ubuntu-1604-lts \
          --image-project=ubuntu-os-cloud --machine-type=g1-small \
          --tags puma-server --restart-on-failure --zone=europe-west1-b \
          --metadata startup-script-url=https://raw.githubusercontent.com/vbrednikov/infra/master/scripts/start_all.sh \
          reddit-app
```


## Packer - base image

Bake the image with packer and then deploying it with gcloud. Use `gcloud inspect packer/ubuntu16.json` to examine all available user variables that can be overrided.

In the examples below, project id and zone user variables are extracted from default gcloud settings.

**Bake the image**

```
project_id=$(gcloud info --format=flattened|grep config.project:|awk '{print $2}') ; \
zone=$(gcloud info --format=flattened|grep config.properties.compute.zone:|awk '{print $2}') ; \
packer build --var project_id=$project_id --var zone=${zone:-europe-west-1b} --var machine_type=f1-micro  packer/ubuntu16.json
```

**Run instance from the baked image with app deployment script**
```
gcloud compute instances create \
          --image-family=reddit-app-base \
          --boot-disk-size=10GB --machine-type=g1-small \
          --tags puma-server --restart-on-failure --zone=europe-west1-b \
          --metadata-from-file startup-script=scripts/deploy_start_reddit.sh \
          reddit-app
```

## Packer - complete image

Bake the image with the application and all its dependencies installed.
No startup script is required since puma.service is started automatically.

By default, it creates image of family reddit-app, instead of reddit-app-base, as in previous example.

**Bake the image**
```
project_id=$(gcloud info --format=flattened|grep config.project:|awk '{print $2}') ; \
zone=$(gcloud info --format=flattened|grep config.properties.compute.zone:|awk '{print $2}') ; \
packer build --var project_id=$project_id --var zone=${zone:-europe-west-1b} --var machine_type=f1-micro  packer/immutable.json
```

**Run an instance**
```
gcloud compute instances create \
          --image-family=reddit-app \
          --boot-disk-size=10GB --machine-type=g1-small \
          --tags puma-server --restart-on-failure --zone=europe-west1-b \
          reddit-app
```

## Packer - separate images

In this variant MongoDB and Reddit-app are deployed on separate instances that should be deployed from packer-baked images reddit-mongodb-base and reddit-app-base. There are two similat configurations in terraform folder: prod and stage, with the same logic (except firewall) and different access configuration (in theory).

For production, firewall allow connections to tcp:22 (ssh) only from the IP (should be specified explicitly as `--var source_ranges="8.8.4.4/32") or in `terraform.tfvarsz. For staging, all connections to ssh are allowed.

Make sure to run "terraform init" in each environment folder.

### Baking the images

Run the commands simultaneously in different console windows:

```
project_id=$(gcloud info --format=flattened|grep config.project:|awk '{print $2}') ; \
zone=$(gcloud info --format=flattened|grep config.properties.compute.zone:|awk '{print $2}') ; \
packer build --var project_id=$project_id --var zone=${zone:-europe-west-1b} --var machine_type=f1-micro  packer/db.json
```

```
project_id=$(gcloud info --format=flattened|grep config.project:|awk '{print $2}') ; \
zone=$(gcloud info --format=flattened|grep config.properties.compute.zone:|awk '{print $2}') ; \
packer build --var project_id=$project_id --var zone=${zone:-europe-west-1b} --var machine_type=f1-micro  packer/app.json
```

### Deploying the images with terraform

```
cd prod
terraform plan
terraform apply
terraform destroy
```

## Shared terraform state with Gcloud

In `prod` and `stage` terraform folders, there are backend-gcs.tf.example files. They contain example configurations for (Google Cloud Storage)[https://www.terraform.io/docs/backends/types/gcs.html] backend.

1. copy the file to backend-gcs.tf in the same folder
2. create a bucket in your project and in your region
3. set variables in backend-gcs.tf according to your project's settings
4. run `terraform init` to migrate current terraform.tfstate to the cloud
