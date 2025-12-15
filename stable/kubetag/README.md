# kubetag

![Version: 1.0.2](https://img.shields.io/badge/Version-1.0.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.0](https://img.shields.io/badge/AppVersion-1.0.0-informational?style=flat-square)

A Helm chart for KubeTag - Kubernetes Container Image Tracker with Tag History

**Homepage:** <https://github.com/huseyinbabal/kubetag>

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Huseyin Babal | <huseyinbabal88@gmail.com> |  |

## Source Code

* <https://github.com/huseyinbabal/kubetag>

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | postgresql | ~18.1.13 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | affinity for pod assignment |
| autoscaling.enabled | bool | `false` | enable horizontal pod autoscaler |
| autoscaling.maxReplicas | int | `3` | maximum number of replicas |
| autoscaling.minReplicas | int | `1` | minimum number of replicas |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | target CPU utilization percentage |
| autoscaling.targetMemoryUtilizationPercentage | int | `80` | target memory utilization percentage |
| env | object | `{"PORT":"8080"}` | environment variables |
| externalDatabase | object | `{"database":"kubetag","host":"","password":"","port":5432,"sslmode":"disable","username":"kubetag"}` | external database configuration (only used when postgresql.enabled=false) |
| externalDatabase.database | string | `"kubetag"` | database name |
| externalDatabase.host | string | `""` | hostname or IP address of the external PostgreSQL server |
| externalDatabase.password | string | `""` | database password (required when using external database) |
| externalDatabase.port | int | `5432` | port number of the external PostgreSQL server |
| externalDatabase.sslmode | string | `"disable"` | SSL mode for PostgreSQL connection (disable, require, verify-ca, verify-full) |
| externalDatabase.username | string | `"kubetag"` | database username |
| fullnameOverride | string | `""` | override the fullname of the chart |
| image.pullPolicy | string | `"IfNotPresent"` | image pull policy |
| image.repository | string | `"ghcr.io/huseyinbabal/kubetag"` | container image repository |
| image.tag | string | `"latest"` | overrides the image tag whose default is the chart appVersion |
| imagePullSecrets | list | `[]` | image pull secrets for private registries |
| ingress.annotations | object | `{}` | ingress annotations |
| ingress.className | string | `""` | ingress class name |
| ingress.enabled | bool | `false` | enable ingress |
| ingress.hosts | list | `[{"host":"kubetag.local","paths":[{"path":"/","pathType":"Prefix"}]}]` | ingress hosts configuration |
| ingress.tls | list | `[]` | ingress TLS configuration |
| nameOverride | string | `""` | override the name of the chart |
| nodeSelector | object | `{}` | node selector for pod assignment |
| podAnnotations | object | `{}` | annotations to add to the pod |
| podLabels | object | `{}` | labels to add to the pod |
| podSecurityContext | object | `{"fsGroup":1000,"runAsNonRoot":true,"runAsUser":1000}` | pod security context |
| postgresql | object | `{"auth":{"database":"kubetag","password":"kubetag","username":"kubetag"},"enabled":true,"primary":{"persistence":{"enabled":true,"size":"8Gi"},"resources":{"limits":{"cpu":"500m","memory":"512Mi"},"requests":{"cpu":"100m","memory":"256Mi"}}}}` | PostgreSQL configuration (set enabled to false to use an external PostgreSQL database) |
| postgresql.auth.database | string | `"kubetag"` | PostgreSQL database name |
| postgresql.auth.password | string | `"kubetag"` | PostgreSQL password |
| postgresql.auth.username | string | `"kubetag"` | PostgreSQL username |
| postgresql.enabled | bool | `true` | enable PostgreSQL subchart |
| postgresql.primary.persistence.enabled | bool | `true` | enable PostgreSQL data persistence using PVC |
| postgresql.primary.persistence.size | string | `"8Gi"` | PVC storage size |
| postgresql.primary.resources | object | `{"limits":{"cpu":"500m","memory":"512Mi"},"requests":{"cpu":"100m","memory":"256Mi"}}` | PostgreSQL resource limits and requests |
| replicaCount | int | `1` | number of replicas for the kubetag deployment |
| resources | object | `{"limits":{"cpu":"500m","memory":"512Mi"},"requests":{"cpu":"100m","memory":"128Mi"}}` | resource limits and requests |
| securityContext | object | `{"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsNonRoot":true,"runAsUser":1000}` | container security context |
| service.port | int | `80` | service port |
| service.targetPort | int | `8080` | container target port |
| service.type | string | `"ClusterIP"` | service type |
| serviceAccount.annotations | object | `{}` | annotations to add to the service account |
| serviceAccount.automount | bool | `true` | automatically mount a ServiceAccount's API credentials |
| serviceAccount.create | bool | `true` | specifies whether a service account should be created |
| serviceAccount.name | string | `""` | the name of the service account to use (if not set and create is true, a name is generated using the fullname template) |
| tolerations | list | `[]` | tolerations for pod assignment |
| volumeMounts | list | `[{"mountPath":"/tmp","name":"tmp"}]` | additional volumeMounts on the output Deployment definition |
| volumes | list | `[{"emptyDir":{},"name":"tmp"}]` | additional volumes on the output Deployment definition |
| watch_namespaces | string | `"*"` | Kubernetes namespace filtering configuration. Use "*" to watch all namespaces or provide a comma-separated list like "default,kube-system,production" |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
