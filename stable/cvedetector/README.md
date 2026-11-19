# cvedetector

Shows which known CVEs affect the container images running in your Kubernetes clusters, and tracks them over time. No image scanning: image versions are read from tags and matched against a CVE feed built from NVD and OSV.

Source and images: [huseyinbabal/cvedetector](https://github.com/huseyinbabal/cvedetector) (`ghcr.io/huseyinbabal/cvedetector-{agent,api,ui}`). Chart `appVersion` is the image tag.

Components: **agent** (read-only, per cluster) → **API** (PostgreSQL) ← **UI**.

## Install

```sh
helm repo add huseyinbabal https://huseyinbabal.github.io/charts
helm install cvedetector huseyinbabal/cvedetector -n cvedetector --create-namespace
kubectl -n cvedetector port-forward svc/cvedetector-ui 8080
```

## Database

The API requires PostgreSQL.

| | Values |
|---|---|
| Bundled (default) | `postgresql.enabled=true`: single-instance `postgres:18.6-alpine` StatefulSet with an 8Gi PVC. Password generated once and kept across upgrades. |
| External | `postgresql.enabled=false`, `externalDatabase.host`, `externalDatabase.existingSecret` (key `password`), `externalDatabase.sslmode` |

## Private feed

While the feed repository is private, give the API a GitHub fine-grained token with read-only *Contents* access:

```sh
kubectl -n cvedetector create secret generic cvedetector-feed --from-literal=token=<github token>
--set api.feed.existingTokenSecret=cvedetector-feed
```

## More clusters

Install the agent only in each additional cluster, pointing at the central API (exposed with `ingress.enabled=true`, which routes `/api` to the API):

```sh
kubectl -n cvedetector create secret generic cvedetector-token --from-literal=token=<token of the central install>
helm install cvedetector huseyinbabal/cvedetector -n cvedetector --create-namespace \
  --set api.enabled=false,ui.enabled=false,postgresql.enabled=false \
  --set agent.clusterName=prod-eu-1,agent.apiUrl=https://cvedetector.example.com \
  --set agent.existingTokenSecret=cvedetector-token
```

The central install's token: `kubectl -n cvedetector get secret cvedetector-ingest -o jsonpath='{.data.token}' | base64 -d`.

## Monitoring

The API and the agent serve Prometheus metrics on `/metrics`.

```sh
--set metrics.enabled=true                                  # scrape annotations (prometheus.io/scrape)
--set metrics.serviceMonitor.enabled=true                   # or a ServiceMonitor (Prometheus Operator)
--set metrics.serviceMonitor.labels.release=kube-prometheus-stack
--set metrics.prometheusRule.enabled=true                   # alerts, see below
--set dashboard.enabled=true                                # Grafana dashboard ConfigMap
```

**Dashboard.** [`dashboards/cvedetector.json`](dashboards/cvedetector.json) ships with the chart. With `dashboard.enabled=true` it is installed as a ConfigMap labelled `grafana_dashboard: "1"`, which the Grafana sidecar (kube-prometheus-stack, Grafana chart with `sidecar.dashboards.enabled`) loads automatically. Use `dashboard.namespace` if the sidecar only watches Grafana's namespace, and `dashboard.annotations.grafana_folder` to pick a folder. Without the sidecar, import the JSON in Grafana.

It shows open vulnerabilities by severity (one trend chart per severity), known exploited count, a cluster/namespace breakdown, image match coverage, time since each cluster's last report, inventory reports and feed sync errors. Variables: data source, cluster, namespace.

**Alerts** (`metrics.prometheusRule.enabled=true`):

| Alert | When | Default severity |
|---|---|---|
| `CvedetectorAgentNotReporting` | a cluster sent nothing for `agentNotReportingSeconds` (30 min) | warning |
| `CvedetectorFeedStale` | the feed is older than `feedStaleSeconds` (48 h) | warning |
| `CvedetectorFeedSyncFailing` | 3+ failed feed syncs in 3 h | warning |
| `CvedetectorKnownExploitedVulnerability` | a CISA KEV vulnerability affects a running image | critical |
| `CvedetectorCriticalVulnerability` | a critical vulnerability affects a running image | warning |

Turn the last two off with `knownExploited: false` / `critical: false`, change severities under `metrics.prometheusRule.severity`, and add your own rules with `additionalRules`.

**Metrics** (from the API; every replica reports the same values, aggregate with `max`):
`cvedetector_cluster_vulnerabilities{cluster,severity}`, `cvedetector_cluster_kev_vulnerabilities{cluster}`, `cvedetector_vulnerabilities{cluster,namespace,severity}`, `cvedetector_kev_vulnerabilities{cluster,namespace}`, `cvedetector_images{cluster,status}`, `cvedetector_cluster_last_report_timestamp_seconds{cluster}`, `cvedetector_feed_age_seconds`, `cvedetector_ingest_total{result}`, `cvedetector_feed_sync_errors_total`, and with `api.workloadMetrics=true` `cvedetector_workload_max_severity{cluster,namespace,kind,name,severity}`. The agent exports `cvedetector_agent_*`.

## Main values

| Key | Default | Description |
|---|---|---|
| `agent.clusterName` | `local` | Name shown in the UI (lowercase, digits, `-`) |
| `agent.namespaces.include` / `exclude` | `[]` | Namespace filter |
| `api.replicas` | `1` | Stateless; coordinates through PostgreSQL locks |
| `api.feed.url` | data branch on raw.githubusercontent.com | Feed location |
| `api.retention` | `8760h` | How long resolved findings are kept |
| `api.workloadMetrics` | `false` | One metric series per workload |
| `ingress.enabled` / `host` | `false` | `/` → UI, `/api` → API |
| `metrics.enabled` | `false` | Let Prometheus scrape the API and the agent |
| `metrics.serviceMonitor.enabled` | `false` | ServiceMonitor instead of scrape annotations |
| `metrics.prometheusRule.enabled` | `false` | Alerting rules |
| `dashboard.enabled` | `false` | Grafana dashboard ConfigMap (needs `metrics.enabled`) |

See [values.yaml](values.yaml) for everything.
