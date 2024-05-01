#!/bin/sh

# shellcheck disable=SC2317

set -e

### inputs #####################################################################

action="$INPUT_ACTION"
gh_repository="$INPUT_GH_REPOSITORY"
gh_pat="$INPUT_GH_PAT"
location="$INPUT_LOCATION"
subscription="$INPUT_SUBSCRIPTION"
rg="$INPUT_RG"
aci="$INPUT_ACI"
vnet="$INPUT_VNET"
subnet="$INPUT_SUBNET"
labels="$INPUT_LABELS"
image="$INPUT_IMAGE"
cpus="$INPUT_CPUS"
memory_gbs="$INPUT_MEMORY_GBS"
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
  username="$(echo "$creds" | jq -r .clientId)"
  password="$(echo "$creds" | jq -r .clientSecret)"
  tenant="$(echo "$creds" | jq -r .tenantId)"
  az login --service-principal \
    --username="$username" \
    --password="$password" \
    --tenant="$tenant"
}

logout() {
  az logout
}

deploy() {
  : "${subnet:="$(get_unused_subnet)"}"
  az container create \
    --subscription "$subscription" \
    --resource-group "$rg" \
    --location "$location" \
    --sku Standard \
    --name "$aci" \
    --image "$image" \
    --environment-variables LABELS="$labels" NAME="$aci" \
    --secure-environment-variables GH_REPOSITORY="$gh_repository" GH_PAT="$gh_pat" \
    --restart-policy OnFailure \
    --os-type Linux \
    --cpu "$cpus" \
    --memory "$memory_gbs" \
    --ip-address Private \
    --vnet "$vnet" \
    --subnet "$subnet"
}

delete() {
  #: "${subnet:="$(get_used_subnet)"}"
  az container delete --yes \
    --name "$aci" \
    --subscription "$subscription" \
    --resource-group "$rg"
}

### main #######################################################################

if [ "$action" != "deploy" ] && [ "$action" != "delete" ]; then
  echo "Error: Unknown action: $action. Allowed: deploy, delete."
  exit 2
fi

login
# shellcheck disable=SC2154
trap 'status=$?; logout; exit $status' INT TERM QUIT EXIT

output="$($action)"
echo "output=$output" >>"$GITHUB_OUTPUT"
