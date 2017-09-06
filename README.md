# infra

**Baking the image with packer**

```
packer build --var gc_project_id=week-3-178421 --var gc_machine_type=f1-micro --var gc_source_image=ubuntu-1604-xenial-v20170815a  ubuntu16.json
```

**Local** 
```
gcloud compute instances create \
          --boot-disk-size=10GB --image=ubuntu-1604-xenial-v20170815a \
          --image-project=ubuntu-os-cloud --machine-type=g1-small \
          --tags puma-server --restart-on-failure --zone=europe-west1-b \
          --metadata-from-file startup-script=start_all.sh \
          reddit-app
```

**From github**

```
gcloud compute instances create \
          --boot-disk-size=10GB --image=ubuntu-1604-xenial-v20170815a \
          --image-project=ubuntu-os-cloud --machine-type=g1-small \
          --tags puma-server --restart-on-failure --zone=europe-west1-b \
          --metadata startup-script-url=https://raw.githubusercontent.com/vbrednikov/infra/config-scripts/start_all.sh \
          reddit-app
```

**From baked image**

```
gcloud compute instances create \
          --boot-disk-size=10GB --image=reddit-base-1504648314 \
          --image-project=week-3-178421 --machine-type=g1-small \
          --tags puma-server --restart-on-failure --zone=europe-west1-b \
          --metadata-from-file startup-script=deploy.sh \
          reddit-app
```
