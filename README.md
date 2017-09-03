# infra

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

