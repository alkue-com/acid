#!/bin/bash

# shellcheck disable=SC2317

set -Eo pipefail

### inputs #####################################################################

action="$INPUT_ACTION"
location="$INPUT_LOCATION"
subscription="$INPUT_SUBSCRIPTION"
rg="$INPUT_RG"
aci="$INPUT_ACI"
image="$INPUT_IMAGE"
env_variables="$INPUT_ENV_VARIABLES"
env_secrets="$INPUT_ENV_SECRETS"
vnet="$INPUT_VNET"
subnet="$INPUT_SUBNET"
cpus="$INPUT_CPUS"
memory_gbs="$INPUT_MEMORY_GBS"
restart_policy="$INPUT_RESTART_POLICY"
creds="$INPUT_CREDS"

### functions ##################################################################

get_unused_subnet() {
  # shellcheck disable=SC2016  # JMESPath requires backticks
  az network vnet subnet list \
    --vnet-name "$vnet" \
    --subscription "$subscription" \
    --resource-group "$rg" \
    --query '[?delegations == `[]`].name | [0]' | jq -r
}

get_used_subnet() {
  az container show \
    --name "$aci" \
    --subscription "$subscription" \
    --resource-group "$rg" \
    --query 'subnetIds[0].id' | jq -r | rev | cut -d '/' -f 1 | rev
}

login() {
  echo "acid: Logging in ------------------------------------------------------"
  if [ -z "$creds" ]; then
    echo "Error: Requires creds"
    exit 1
  fi

  username="$(echo "$creds" | jq -r .clientId)"
  password="$(echo "$creds" | jq -r .clientSecret)"
  tenant="$(echo "$creds" | jq -r .tenantId)"
  az login --service-principal \
    --username="$username" \
    --password="$password" \
    --tenant="$tenant"
}

logout() {
  echo "acid: Logging out -----------------------------------------------------"
  az logout
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

  [ -z "$subnet" ] && subnet="$(get_used_subnet)"

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

login
# shellcheck disable=SC2154  # status is assigned from failing command
trap 'status=$?; logout; exit $status' INT TERM QUIT ERR

"$action"
logout
