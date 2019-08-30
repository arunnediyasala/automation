#!/bin/bash
if [ $# -ne 1 ]
then
  echo "enter the statename of the job you want to delete " 
  exit 0
fi
statename=$1.json
terraform destroy -auto-approve -state=$statename
