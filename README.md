# pwnbox vm

My personal pwnbox vm base image. Based on [vm-image-builder](https://github.com/htr/vm-image-builder).

### features

* ready to use X environment
  * exposed via vnc (localhost:5900) and novnc (http, localhost:6901)
* access the services bound to lo with `ssh -t -L 5900:localhost:5900 -L 6901:localhost:6901 user@my-pwnbox-address`
* base distribution is [kali](https://www.kali.org/)
  * plenty of tools pre-packaged and ready to be installed


### Quickstart

* take a look at [the ansible playbook](./artifacts/playbook.yml): if you do not want to rely on cloud-init, setting a public key might be a good idea. Fix the variable `myuser`.

* run the [builder script](./build.sh): `./build.sh -o test.qcow2 -s10`



### Running locally

The [runner script](./run.sh) allows you to quickly run the image locally:
```shell
./run.sh -i test.qcow2
```

you should be able to login locally:
```
ssh root@localhost -p50022
```


### Uploading to a cloud provider
The qcow2 format is supported by many cloud providers as is. During boot, the image will use any cloud-init configuration available (ssh keys, network configuration, etc).

Personally, I like to shrink the image to the smallest possible size before uploading it:

```shell
$ virt-sparsify test.qcow2 test-sparse.qcow2 # you might need to run this as root

$ pigz test-sparse.qcow2

```

I use [do-image-uploader](https://github.com/htr/do-image-uploader) to upload my images to DigitalOcean:

```shell
$ export DO_API_TOKEN=$(pass show do-tokens/personal)
$ do-image-uploader --image-file=test-sparse.qcow2.gz --region=fra1 --name=test-image --wait-until-available

```

#### Deploying a new VM

I use another [ansible playbook](./create-vm.yml) to create and configure the VM.

Once the base image is uploaded, you can easily create a new VM. I prefer to synchronize my dotfiles (because they change quite often) and my hackthebox.org openvpn configuration file at this stage.
