#!/usr/bin/env bash

grep 'ignore-playbook' /proc/cmdline && exit 0

curl http://10.0.2.55/playbook.yml > /tmp/playbook.yml
ansible-playbook /tmp/playbook.yml | tee -a /root/ansible.log
