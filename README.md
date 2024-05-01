# acid 0.1.0

GitHub Action used to deploy and delete one-off Azure Container Instances.

Use:
- This is for short-running internal workloads, not generic web server deployer.
- Container gets only private IP. The virtual network and the subnet must exist.
- Due to private only networking, only Linux Docker workloads are supported.

Azure login with OpenID Connect is not currently supported for this action.

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

## Inputs

TODO

## TODO

- only private network/Linux is supported
- `entrypoint.sh`: validate mandatory params
