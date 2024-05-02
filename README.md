# acid 1.1.0

GitHub Action to deploy and delete one-off Azure Container Instances.

Purpose:
- This is for short-running internal workloads, not a web server deployer.
- Container gets only private IP thus only Linux workloads are supported by ACI.
- A resource group, a virtual network and an unused subnet must already exist.

## Setup

In the target repository, add the following as GitHub Actions secrets:

- `SUBSCRIPTION` (name, must exist)
- `LOCATION` (e.g. `westeurope`)
- `RG` (name, must exist)
- `ACI` (name)
- `VNET` (name, must exist)
- `SUBNET` (name, must exist)

Use [azure/login](https://github.com/Azure/login) action in your pipeline
to login to Azure your preferred way before using this action.

## Inputs

### Deploy

Required arguments:

- `action`
- `subscription`
- `location`
- `rg`
- `aci`
- `image`
- `vnet`
- `subnet`

Optional arguments:

- `env_variables`
- `env_secrets`
- `cpus`
- `memory_gbs`
- `restart_policy`

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

- `action`
- `subscription`
- `rg`
- `aci`

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
