# acid 0.1.0

GitHub Action used to deploy and delete one-off Azure Container Instances.

Uses Azure CLI, login with OpenID Connect is supported for this action.

Use:
- This is for short-running internal workloads, not a generic server deployer.
- Container gets only private IP thus only Linux workloads are supported by ACI.
- The resource group, virtual network and an unused subnet must already exist.

If subnet is not given, the first unused subnet in the virtual network is used.

## Setup

Create a service principal in Azure:

    az ad sp create-for-rbac \
      --name "alkue-com-acid" \
      --role contributor \
      --scopes /subscriptions/{subscription_id}/resourceGroups/{rg_name} \
      --json-auth

Add responded JSON object as a GitHub Actions Secret `AZURE_CREDENTIALS`.

## Usage

### Deploy

```yaml
uses: alkue-com/acid@main
with:
  action: up
  gh_repository: alkue-com/alkue
  gh_pat: ${{ secrets.GH_PAT }}
  location: westeurope
  subscription: alkue
  rg: alkue-dev
  aci: alkue-dev-runner
  vnet: alkue-dev
  subnet: ${{ secrets.SUBNET }}
  creds: $${ secrets.AZURE_CREDENTIALS }}
```

### Delete

```yaml
uses: alkue-com/acid@main
with:
  action: down
  subscription: alkue
  rg: alkue-dev
  aci: alkue-dev-runner
  creds: $${ secrets.AZURE_CREDENTIALS }}
```

## TODO

- `entrypoint.sh`: validate mandatory params (delete does not require all)
