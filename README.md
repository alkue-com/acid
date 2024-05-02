# acid 1.1.0

GitHub Action to deploy and delete one-off Azure Container Instances.

This is for provisioning/deprovisioning workloads in private network.

Note: Only Linux containers are supported for private networking by ACI.

Requirements:
- GitHub runner must have `bash` and `az` installed (GitHub hosted runners do).
- The resource group, the virtual network and the subnet must already exist.
- Docker image must be publicly available

## Setup

In the repository, add the following as GitHub Actions secrets:

- `SUBSCRIPTION` - name or id, must exist
- `LOCATION` - e.g. `westeurope`
- `RG` - resource group name, must exist
- `ACI` - name, service to be created/deleted
- `VNET` - name or id - created if not exists, use `az_cli_args` to set prefix
- `SUBNET` - name or id - created if not exists, use `az_cli_args` to set prefix

Use [azure/login](https://github.com/Azure/login) action in your pipeline
to login to Azure your preferred way before using this action.

## Inputs

See `az container create --help` for detailed description on arguments.

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

- `env_variables` - space-separated list (e.g. `ENV1=VALUE1 ENV2=VALUE2`)
- `env_secrets` - space-separated list (e.g. `KEY=${{secrets.KEY1}}) KEY2=...`)
- `cpus` - defaults to 1 CPU core
- `memory_gbs` - defaults to 1.5GB
- `restart_policy` - defaults to OnFailure
- `az_cli_args` - any `az container create` args

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

- `az_cli_args` - any `az container delete` args

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

## TODO

- public networking
- cleanup changelog
- publish marketplace
