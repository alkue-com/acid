# acid 0.1.0

GitHub Action to deploy and delete Azure Container Instances.

## Inputs

### `action`

**Required** `up` to deploy, `down` to delete.

### `configfile`

**Required** File representing the target Azure environment.

```sh
SUBSCRIPTION="alkue"
PREFIX="alkue-dev"
APP="runner"
LOCATION="westeurope"
GH_REPOSITORY="alkue-com/alkue"
```

## Outputs

## `finished_at`

ISO 8601 timestamp when finished at.

## Example usage

Deploy:

```sh
uses: alkue/acid@main
with:
  action: up
  envfile: dev.env
```

Delete:

```sh
uses: alkue/acid@main
with:
  action: down
  envfile: dev.env
```
