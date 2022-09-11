# Plausible Analytics Helm Chart for Kubernetes
 
Plausible Analytics is a Simple, lightweight privacy-friendly website analytics  alternative to Google Analytics.

## Install Chart

```shell
helm repo add david-crty https://david-crty.github.io/helm-chart/
helm repo update

# Helm 3
$ helm install [RELEASE_NAME] david-crty/plausible/
```


## Requirements

Before you start make sure you have the following dependencies ready and working: 

- Helm > 3
- Postgres DB

## Configuration

- Plausible specific values.
- Clickouse specific values. 
> The shown values represent defaults and comments provide a better description if needed. 

```yaml
baseURL: "https://plausible.crty.dev"
adminUser:
  email: david@crty.dev
  name: David
  password: agp3H6p2aTG3qj9SLcIa
database: # Postgres Database
  enabled: true
  url: "postgres://root:8PnLKk7b77iIh2Whcwm_l@51.159.205.167:26954/plausible"
ingress:
  enabled: true
  host: plausible.crty.dev
  certManager:
    enabled: true
clickhouse-server:
  clickhouse:
    persistentVolumeClaim:
      enabled: true
      dataPersistentVolume:
        enabled: true
        storageClassName: local # Change to your storage class depending on your cloud provider
        storage: "5Gi"
```

## Special Thanks

Source Code for this Helm Chart [8gears/plausible-analytics-helm-chart](https://github.com/8gears/plausible-analytics-helm-chart)
