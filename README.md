# acid 1.2.0

GitHub Action to deploy and delete one-off Azure Container Instances.

Intended for short-living Linux container workloads in private Azure network.

GitHub runner must have `bash` and `az` installed (GitHub hosted runners do).

## Setup

In the GitHub repository, create the following as GitHub Actions secrets:

- `SUBSCRIPTION` - name or id, subscription must exist
- `LOCATION` - e.g. `westeurope`, get name from `az account list-locations`
- `RG` - name, resource group must exist
- `ACI` - name, target to deploy/delete
- `VNET` - name or id - created if does not exist, use `az_args` to set CIDR
- `SUBNET` - name or id - created if does not exist, use `az_args` to set CIDR

Use [azure/login](https://github.com/Azure/login) action in pipeline to login
to Azure before using this action.

## Inputs

### Deploy

Required arguments:

- `action: deploy`
- `subscription`
- `location`
- `rg`
- `aci`
- `image`

Optional arguments:

- `vnet`
- `subnet`
- `env_variables` - space-separated list (`NAME=${{ vars.NAME }} VAR=value`)
- `env_secrets` - space-separated list (`SUM=${{ secrets.SUM }} ANOTHER=...`)
- `cpus` - defaults to 1 CPU core
- `memory_gbs` - defaults to 1.5GB
- `restart_policy` - defaults to Always
- `law` - existing Log Analytics Workspace name or id
- `law_key` - Log Analytics Workspace primary or secondary key
- `cmd` - Command to run in container (`CMD`), not double quoted
- `az_args` - any Azure CLI arguments (may extend or override previous)

See `az container create --help` for detailed description on arguments.

Example:

```yaml
uses: alkue-com/acid@1.2.0
with:
  action: deploy
  subscription: ${{ vars.SUBSCRIPTION }}
  location: ${{ vars.LOCATION }}
  rg: ${{ vars.RG }}
  aci: ${{ vars.ACI }}
  image: fqdn/repository:tag
  vnet: ${{ vars.VNET }}
  subnet: ${{ vars.SUBNET }}
```

### Delete

Required arguments:

- `action: delete`
- `subscription`
- `rg`
- `aci`

Optional arguments:

- `az_args` - any Azure CLI arguments (may extend or override previous)

See `az container delete --help` for detailed description on arguments.

Example:

```yaml
uses: alkue-com/acid@1.2.0
with:
  action: delete
  subscription: ${{ vars.SUBSCRIPTION }}
  rg: ${{ vars.RG }}
  aci: ${{ vars.ACI }}
```

## Outputs

Always returned:

- `vnet`: Virtual network name where ACI was deployed to or deleted from
- `subnet`: Subnet name where ACI was deployed to or deleted from

### After deploy

Example:

```yaml
    steps:
    - name: Deploy ACI
      id: deploy
      uses: alkue-com/acid@1.2.0
      with:
        action: deploy
        ...

    - name: Output subnet ACI was deployed to
      run: echo ${{ steps.deploy.outputs.subnet }}
```

### After delete

Example:

```yaml
    steps:
    - name: Delete ACI
      id: delete
      uses: alkue-com/acid@1.2.0
      with:
        action: delete
        ...

    - name: Output subnet ACI was deleted from
      run: echo ${{ steps.delete.outputs.subnet }}
```
