# acid 0.1.0

GitHub Action to deploy and delete Azure Container Instances.

## Setup

Azure login with OpenID Connect is not currently supported for this action.

Create a service principal in Azure:

    az ad sp create-for-rbac \
      --name "alkue-com-acid" \
      --role contributor \
      --scopes /subscriptions/{subscription_id}/resourceGroups/{rg_name} \
      --json-auth

Add GitHub Actions Secret `AZURE_CREDENTIALS` with JSON object as the content.

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

## Outputs

TODO

## TODO

- `entrypoint.sh`: validate params
