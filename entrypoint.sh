#!/bin/bash

set -Eo pipefail

### inputs #####################################################################

action="$INPUT_ACTION"
location="$INPUT_LOCATION"
subscription="$INPUT_SUBSCRIPTION"
rg="$INPUT_RG"
aci="$INPUT_ACI"
image="$INPUT_IMAGE"
vnet="$INPUT_VNET"
subnet="$INPUT_SUBNET"
env_variables="$INPUT_ENV_VARIABLES"
env_secrets="$INPUT_ENV_SECRETS"
cpus="$INPUT_CPUS"
memory_gbs="$INPUT_MEMORY_GBS"
restart_policy="$INPUT_RESTART_POLICY"

### functions ##################################################################

_get_used_subnet() {
  az container show \
    --name "$aci" \
    --subscription "$subscription" \
    --resource-group "$rg" \
    --query 'subnetIds[0].id' | jq -r | rev | cut -d '/' -f 1 | rev
}

deploy() {
  echo "acid: Deploying -------------------------------------------------------"
  if [ -z "$subscription" ] || [ -z "$location" ] || [ -z "$rg" ] ||
    [ -z "$aci" ] || [ -z "$image" ] || [ -z "$vnet" ] || [ -z "$subnet" ]; then
    echo "Error: Requires subscription, location, rg, aci, image, vnet, subnet."
    exit 1
  fi

  # eval: not escaping env_variables and env_secrets
  eval az container create \
    --subscription "$subscription" \
    --resource-group "$rg" \
    --location "$location" \
    --sku Standard \
    --name "$aci" \
    --image "$image" \
    --environment-variables "$env_variables" \
    --secure-environment-variables "$env_secrets" \
    --restart-policy "$restart_policy" \
    --os-type Linux \
    --cpu "$cpus" \
    --memory "$memory_gbs" \
    --ip-address Private \
    --vnet "$vnet" \
    --subnet "$subnet"

  echo "subnet=$subnet" >>"$GITHUB_OUTPUT"
}

delete() {
  echo "acid: Deleting --------------------------------------------------------"
  if [ -z "$subscription" ] || [ -z "$rg" ] || [ -z "$aci" ]; then
    echo "Error: Requires subscription, rg, aci."
    exit 1
  fi

  [ -z "$subnet" ] && subnet="$(_get_used_subnet)"

  az container delete --yes \
    --name "$aci" \
    --subscription "$subscription" \
    --resource-group "$rg"

  echo "subnet=$subnet" >>"$GITHUB_OUTPUT"
}

### main #######################################################################

if [ "$action" != "deploy" ] && [ "$action" != "delete" ]; then
  echo "Error: Unknown action: $action. Allowed: deploy/delete."
  exit 1
fi

"$action"
