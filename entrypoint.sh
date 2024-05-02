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

get_subnet_prefix() {
  az network vnet subnet show \
    --name "$subnet" \
    --vnet-name "$vnet" \
    --subscription "$subscription" \
    --resource-group "$rg" \
    --query 'addressPrefix' | jq -r
}

login() {
  echo "acid: Logging in ------------------------------------------------------"
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
  [ -z "$subnet" ] && subnet="$(get_unused_subnet)"
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

  echo "subnet=$subnet" >>"$GITHUB_OUTPUTS"
}

delete() {
  echo "acid: Deleting --------------------------------------------------------"

  if [ -n "$vnet" ] && [ -z "$subnet" ]; then
    subnet="$(get_used_subnet)"
  fi
  [ -n "$subnet" ] && subnet_prefix="$(get_subnet_prefix)"

  az container delete --yes \
    --name "$aci" \
    --subscription "$subscription" \
    --resource-group "$rg"

  if [ -n "$subnet_prefix" ]; then
    az network vnet subnet delete \
      --name "$subnet" \
      --vnet-name "$vnet" \
      --subscription "$subscription" \
      --resource-group "$rg"

    az network vnet subnet create \
      --name "$subnet" \
      --address-prefixes "$subnet_prefix" \
      --vnet-name "$vnet" \
      --subscription "$subscription" \
      --resource-group "$rg"

    echo "subnet=$subnet" >>"$GITHUB_OUTPUTS"
  fi
}

### main #######################################################################

if [ "$action" != "deploy" ] && [ "$action" != "delete" ]; then
  echo "Error: Unknown action: $action. Allowed: deploy/delete."
  exit 2
fi

login
# shellcheck disable=SC2154  # status is assigned from failing command
trap 'status=$?; logout; exit $status' INT TERM QUIT ERR

"$action"
logout
