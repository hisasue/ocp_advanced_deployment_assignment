#!/bin/bash

ansible-playbook -f 20 -i hosts /usr/share/ansible/openshift-ansible/playbooks/prerequisites.yml
ansible-playbook -f 20 -i hosts /usr/share/ansible/openshift-ansible/playbooks/deploy_cluster.yml
ansible-playbook -i hosts site.yml
