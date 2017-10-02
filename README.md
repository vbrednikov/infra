# Reddit-app infrastructure

This set of scripts and configurations is attended to run sample ruby application https://github.com/Artemmkin/reddit in Google Cloud. 

The application arhitecture supposes at least two instances: mongodb server and application server with ruby and rails. Application listens on  HTTP port 9292.

Basic steps are:

1. **Packer**: prepare base images for running mongodb (reddit-db-base) and application (reddit-app-base)  (`packer` folder)
2. **Terraform**: setup Google Cloud instances from the images using (`terraform` folder)
3. **Ansible**: start mongodb, deploy application from github and start it using  (`ansible` folder)

## Repo layout

**scripts** dir contains script to deploy everything from scratch using old-school scripts approach
- `start_all.sh` -- deploy and start everything on single instance
- `install_ruby.sh` -- install ruby and bundler
- `install_mongodb.sh` -- install mongo from their repository
- `install_app.sh` -- install the application from github repo
- `deploy_start_reddit.sh` -- install and start the application

**packer** dir contains packer configuration to prepare images in Google Cloud:
- **`packer/app.json`** -- base image with ruby and bundler
- **`packer/db.json`** -- base image with mongodb
- `packer/immutable.json` -- all-in-one image with deployed reddit app
- `packer/ubuntu16.json` -- all-in-one image with ruby and mongo, without the app

**terraform** dir contains terraform configuration and modules to start instances in Google Cloud:
- **`terraform/prod`** -- production configuration
- **`terraform/stage`** -- staging

**ansible** contains ansible cookbooks to prepare environment for running reddit:
- Main modules:
  - **`ansible/packer_reddit_app.yml`**: installs ruby and bundler, for use with packer
  - **`ansible/packer_reddit_db.yml`**: installs mongodb, for use with packer
  - **`ansible/reddit_app.yml`**: puts configuration files in place, deploys and starts application
- Additional:  
  - `ansible/reddit.yml`: simple playbook to deploy and start reddit application 
  - `ansible/immutable.yml`: installs everything (including the application itself) on one vm
  - `ansible/os_update.yml`: does equivalent of apt-get update && apt-get upgrade


## Prerequisites

1. [Google Cloud free account](https://console.cloud.google.com/freetrial)
2. [Google Cloud SDK](https://cloud.google.com/sdk/downloads), installed, added to `$PATH` and authorized 
    - [prerequisites and installation](https://cloud.google.com/sdk/docs/)
3. [Packer binary](https://www.packer.io/downloads.html) in `$PATH`
4. [Terraform binary](https://www.terraform.io/downloads.html) in `$PATH` 
5. Ansible 2.3.2, libcloud:
   ```
   pip install ansible==2.3.2
   pip install apache-libcloud
   ```

> During terraform manipulations, default ssh rule can be dropped, but it is still required to prepare base images with packer. Use the following cmdline to restore:
>
> ```
>  gcloud compute firewall-rules create default-ssh2 --allow=tcp:22 --description="Allow SSH access" --direction=IN --network=default 
> ```

## Fried instances

> **WARNING** This is the very manual way to start and deploy the application. Not recommended for production, kept for the history.

"Fry" the instance from base OS image using startup script. You will get an instance with ruby, mongodb and reddit app running on port 9292. Tested with Ubuntu 1604, probably will work with Debian. Different scripts in `scripts` folder (see "layout" section above for more details) can be used in different combinations.

Project ID and zone from default gcloud settings are used.

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

## Packer


Prepare base db and app images for future use with terraform. Use `gcloud inspect packer/app.json` or `gcloud inspect packer/db.json` to examine all available user variables that can be overrided.

In the examples below, project id and zone user variables are extracted from default gcloud settings.


### Packer -- all-in-one instance

> **WARNING**: non-production example

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

> The app uses TPC port 9292 for external comminucation, you need to open it in Google cloud firewall. In the examples below, network firewall tag "puma-server" is used to allow it. You can create this rule using the following command:
>
> ```
> gcloud compute firewall-rules create default-puma-server2 --allow=tcp:9292 --description="Reddit app on puma server" --direction=IN --network=default --target-tags=puma-server
> ```

Make sure that reddit-app is reachable via http://reddit-ip:9292.

> **WARNING** Do not forget to cleanup the instance, image and firewall rules after experiments.

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

## Terraform

1. In `prod` and `stage` folders, copy terraform.tfvars.example to terraform.tfvars and fill with your project's settings. 
2. Configure shared state, if needed (see the section below)
2. Review `variables.tf`, edit, if needed

### Shared terraform state with Gcloud

In `prod` and `stage` terraform folders, there are backend-gcs.tf.example files. They contain example configurations for (Google Cloud Storage)[https://www.terraform.io/docs/backends/types/gcs.html] backend.

1. copy the file to backend-gcs.tf in the same folder
2. create a bucket in your project and in your region
3. set variables in backend-gcs.tf according to your project's settings
4. run `terraform init` to migrate current terraform.tfstate to the cloud

### Bringing up the environment

```
cd terraform/prod
terraform init
terraform plan
terraform apply
terraform destroy
```

## Ansible

TBD