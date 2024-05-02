# acid 1.1.0

GitHub Action to deploy and delete one-off Azure Container Instances.

Intended for short-living Linux container workloads in private Azure network.

GitHub runner must have `bash` and `az` installed (GitHub hosted runners do).

## Setup

In the repository, add the following as GitHub Actions secrets:

- `SUBSCRIPTION` - name or id, subscription must exist
- `LOCATION` - e.g. `westeurope`
- `RG` - name, resource group must exist
- `ACI` - name, target to deploy/delete
- `VNET` - name or id - created if not exists, use `az_cli_args` to set prefix
- `SUBNET` - name or id - created if not exists, use `az_cli_args` to set prefix

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
- `vnet`
- `subnet`

Optional arguments:

- `env_variables` - space-separated list (`ENV1=VALUE1 ENV2=VALUE2`)
- `env_secrets` - space-separated list (`KEY1=${{ secrets.KEY1 }} KEY2=...`)
- `cpus` - defaults to 1 CPU core
- `memory_gbs` - defaults to 1.5GB
- `restart_policy` - defaults to OnFailure
- `az_cli_args` - any Azure CLI arguments (may extend or override previous)

See `az container create --help` for detailed description on arguments.

Example:

```yaml
uses: alkue-com/acid@1.1.0
with:
  action: deploy
  subscription: ${{ secrets.SUBSCRIPTION }}
  location: ${{ secrets.LOCATION }}
  rg: ${{ secrets.RG }}
  aci: ${{ secrets.ACI }}
  image: fqdn/repository:tag
  vnet: ${{ secrets.VNET }}
  subnet: ${{ secrets.SUBNET }}
```

### Delete

Required arguments:

- `action: delete`
- `subscription`
- `rg`
- `aci`

Optional arguments:

- `az_cli_args` - any Azure CLI arguments (may extend or override previous)

See `az container delete --help` for detailed description on arguments.

Example:

```yaml
uses: alkue-com/acid@1.1.0
with:
  action: delete
  subscription: ${{ secrets.SUBSCRIPTION }}
  rg: ${{ secrets.RG }}
  aci: ${{ secrets.ACI }}
```

## Outputs

Always returned:

- `subnet`: Subnet name where ACI was deployed to or deleted from

### After deploy

Example:

```yaml
    steps:
    - name: Deploy ACI
      id: deploy
      uses: alkue-com/acid@1.1.0
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
      uses: alkue-com/acid@1.1.0
      with:
        action: delete
        ...

    - name: Output subnet ACI was deleted from
      run: echo ${{ steps.delete.outputs.subnet }}
```
