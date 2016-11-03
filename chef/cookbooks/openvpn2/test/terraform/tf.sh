#!/bin/bash

regions="us-east-1 us-west-1"

if [ -z "$AWS_ACCESS_KEY" ] || [ -z "$AWS_SECRET_KEY"]; then
  if [ -f ".env" ]; then
    source .env
  else
    echo -e "\$AWS_ACCESS_KEY \$AWS_SECRET_KEY variables are required"
    exit 1
  fi
fi

function runtf() {
  for region in ${regions}; do
    eval "terraform $1 -state=test/terraform/${region}.tfstate -var 'region=${region}' test/terraform"
  done
}

case "${1}" in 
  setup)
    runtf "apply" \
      && exit 0
    ;;
  teardown)
    runtf "destroy -force" \
      && rm test/terraform/*.tfstate \
      && exit 0
    ;;
esac

exit 1 # fail if unsuccessful
