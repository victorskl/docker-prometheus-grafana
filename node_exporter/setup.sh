#!/bin/bash

[ $# -eq 0 ] && { echo "Usage: $0 username key_file.pem playbook-name.yaml"; exit 1; }

ansible-playbook -i hosts.ini -u ${1} -v -b --ask-become-pass --become-method=sudo --key-file=${2} ${3}