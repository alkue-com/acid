#!/bin/sh

set -e

### inputs #####################################################################

action="$1"
gh_repository="$2"
gh_pat="$3"
location="$4"
subscription="$5"
rg="$6"
aci="$7"
vnet="$8"
subnet="$9"
labels="${10}"
image="${11}"
cpus="${12}"
memory_gbs="${13}"

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

echo "output=$($action)" >>"$GITHUB_OUTPUT"
