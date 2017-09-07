# Infra

This repo contains configuration to prepare and run sample reddit-app project in Google Cloud: https://github.com/Artemmkin/reddit.

There are several ways to start and deploy the instances:
- "fry" base ubuntu/debian image with shell scripts: install ruby, mongodb, app to base version
- prepare "baked" images with builtin app dependencies using packer
- to be continued ...

## Prerequisites

1. Google cloud account
2. Google Cloud SDK (https://cloud.google.com/sdk/downloads)
3. Packer (https://www.packer.io/downloads.html)

The app uses TPC port 9292 for external comminucation, you need to open it in Google cloud firewall. In the examples below, network firewall tag "puma-server" is used to allow it. You can create this rule using the following command:

```
gcloud compute firewall-rules create default-puma-server2 --allow=tcp:9293 --description="Reddit app on puma server" --direction=IN --network=default --target-tags=puma-server
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
          --metadata-from-file startup-script=start_all.sh \
          reddit-app
```

**From github**

```
gcloud compute instances create \
          --boot-disk-size=10GB --image-family=ubuntu-1604-lts \
          --image-project=ubuntu-os-cloud --machine-type=g1-small \
          --tags puma-server --restart-on-failure --zone=europe-west1-b \
          --metadata startup-script-url=https://raw.githubusercontent.com/vbrednikov/infra/config-scripts/start_all.sh \
          reddit-app
```


## Packer - base image

Bake the image with packer and then deploying it with gcloud. Use `gcloud inspect ubuntu16.json` to examine all available user variables that can be overrided.


In the examples below, project id and zone user variables are extracted from default gcloud settings.

**Bake the image**

```
project_id=$(gcloud info --format=flattened|grep config.project:|awk '{print $2}') ; \
zone=$(gcloud info --format=flattened|grep config.properties.compute.zone:|awk '{print $2}') ; \
packer build --var project_id=$project_id --var zone=${zone:-europe-west-1b} --var machine_type=f1-micro  ubuntu16.json
```

**Run instance from the baked image with app deployment script**
```
gcloud compute instances create \
          --image-family=reddit-app-base \
          --boot-disk-size=10GB --machine-type=g1-small \
          --tags puma-server --restart-on-failure --zone=europe-west1-b \
          --metadata-from-file startup-script=deploy.sh \
          reddit-app
```
