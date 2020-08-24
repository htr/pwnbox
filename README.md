# vm image builder

This repo contains a almost-ready-to-use Debian VM image builder.


### Quickstart

* edit [the ansible playbook](./artifacts/playbook.yml): you might want to remove that public key ;)

* run the [builder script](./build.sh): `./build.sh -o test.qcow2 -s5`

By default, the image [has](./artifacts/preseed.cfg#L63) a functional cloud-init environment and a ssh server.


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


## Customizing

The last configuration [step](./artifacts/preseed.cfg#L70) runs the [post-install](./artifacts/post-install.sh) script. By default, this script runs the ansible [ansible playbook](./artifacts/playbook.yml).


