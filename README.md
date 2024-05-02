# acid 0.1.0

GitHub Action to deploy and delete one-off Azure Container Instances.

Purpose:
- This is for short-running internal workloads, not a web server deployer.
- Container gets only private IP thus only Linux workloads are supported by ACI.
- A resource group, a virtual network and an unused subnet must already exist.

Uses Azure CLI container image, login with OpenID Connect is not supported.

## Setup

Create a service principal in Azure:

    az ad sp create-for-rbac \
      --name "alkue-com-acid" \
      --role contributor \
      --scopes /subscriptions/{subscription_id}/resourceGroups/{rg_name} \
      --json-auth

In the target repository, add the following as GitHub Actions secrets:
- `AZURE_CREDENTIALS` (the response JSON object from the `az` command above)
- `GH_PAT` (must have administrator read/write rights to the repository)
- `SUBSCRIPTION` (name, must exist)
- `RG` (name, must exist)
- `ACI` (name)
- `IMAGE` (fqdn/repository:tag, must be publicly available)
- `VNET` (name, must exist)
- `SUBNET`
- `LOCATION`

## Usage

### Deploy

Required arguments:
- `action`
- `subscription`
- `rg`
- `aci`
- `image`
- `vnet`
- `creds`

Optional arguments:
- `location` - if not given, West Europe is used
- `subnet` - if not given, the first `VNET` subnet without delegations is used
- `env_variables`
- `env_secrets`
- `cpus`
- `memory_gbs`
- `restart_policy`

Example:

```yaml
uses: alkue-com/acid@0.1.0
with:
  action: deploy
  subscription: ${{ secrets.SUBSCRIPTION }}
  location: ${{ secrets.LOCATION }}
  rg: ${{ secrets.RG }}
  aci: ${{ secrets.ACI }}
  image: ${{ secrets.IMAGE }}
  vnet: ${{ secrets.VNET }}
  creds: $${ secrets.AZURE_CREDENTIALS }}

```

### Delete

Required arguments:
- `action`
- `subscription`
- `rg`
- `aci`
- `creds`

Optional_arguments:
- `subnet` - if given, the subnet is recreated after ACI has been deleted

Example:

```yaml
uses: alkue-com/acid@0.1.0
with:
  action: delete
  subscription: ${{ secrets.SUBSCRIPTION }}
  rg: ${{ secrets.RG }}
  aci: ${{ secrets.ACI }}
  creds: $${ secrets.AZURE_CREDENTIALS }}
```

## TODO

- `entrypoint.sh`: validate mandatory params (delete does not require all)
