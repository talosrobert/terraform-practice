# terraform-practice
Terraform Practice Repository

## build new image with podman
podman build -f Dockerfile --tag aztf

## run the container and mount the config folder
podman container run --rm -v ./config:/root/config:z -it aztf
