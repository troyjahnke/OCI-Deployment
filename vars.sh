#!/bin/sh

if [ $1 = "d" ]
then
    action="decrypt"
elif [ "$1" = "e" ]
then
    action="encrypt"
else
    echo "Please use d for decrypt or e for encrypt"
    exit
fi
echo $action
ansible-vault $action terraform.tfvars docker_dns/terraform.tfvars docker_search/terraform.tfvars