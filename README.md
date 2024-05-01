# acid 0.1.0

GitHub Action to deploy and delete Azure Container Instances.

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
```

### Delete

```yaml
uses: alkue-com/acid@main
with:
  action: down
  subscription: alkue
  rg: alkue-dev
  aci: alkue-dev-runner
```

## Inputs

TODO

## Outputs

TODO

## TODO

- `entrypoint.sh`: validate params
