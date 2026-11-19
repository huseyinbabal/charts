{{- define "cvedetector.fullname" -}}
{{- if contains .Chart.Name .Release.Name -}}
{{- .Release.Name | trunc 50 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 50 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "cvedetector.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "cvedetector.labels" -}}
{{ include "cvedetector.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: cvedetector
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version }}
{{- end -}}

{{/* Component labels: (dict "ctx" $ "component" "api") */}}
{{- define "cvedetector.componentLabels" -}}
{{ include "cvedetector.labels" .ctx }}
app.kubernetes.io/component: {{ .component }}
{{- end -}}
{{- define "cvedetector.componentSelector" -}}
{{ include "cvedetector.selectorLabels" .ctx }}
app.kubernetes.io/component: {{ .component }}
{{- end -}}

{{- define "cvedetector.image" -}}
{{- printf "%s/cvedetector-%s:%s" .ctx.Values.image.registry .component (.ctx.Values.image.tag | default .ctx.Chart.AppVersion) -}}
{{- end -}}

{{- define "cvedetector.apiName" -}}{{ include "cvedetector.fullname" . }}-api{{- end -}}
{{- define "cvedetector.apiURL" -}}http://{{ include "cvedetector.apiName" . }}.{{ .Release.Namespace }}.svc:{{ .Values.api.service.port }}{{- end -}}

{{/* Secret holding the agent token for the API side. */}}
{{- define "cvedetector.ingestSecret" -}}
{{- .Values.api.existingTokenSecret | default (printf "%s-ingest" (include "cvedetector.fullname" .)) -}}
{{- end -}}

{{/* Secret the agent reads its token from. */}}
{{- define "cvedetector.agentTokenSecret" -}}
{{- if .Values.agent.existingTokenSecret -}}
{{- .Values.agent.existingTokenSecret -}}
{{- else if .Values.agent.token -}}
{{- printf "%s-agent" (include "cvedetector.fullname" .) -}}
{{- else -}}
{{- include "cvedetector.ingestSecret" . -}}
{{- end -}}
{{- end -}}

{{/* Database connection: name of the Secret + key holding the password. */}}
{{- define "cvedetector.dbSecret" -}}
{{- if .Values.postgresql.enabled -}}
{{- .Values.postgresql.auth.existingSecret | default (printf "%s-postgresql" (include "cvedetector.fullname" .)) -}}
{{- else -}}
{{- .Values.externalDatabase.existingSecret | default (printf "%s-externaldb" (include "cvedetector.fullname" .)) -}}
{{- end -}}
{{- end -}}
{{- define "cvedetector.dbSecretKey" -}}
{{- if .Values.postgresql.enabled -}}{{ .Values.postgresql.auth.existingSecretPasswordKey }}{{- else -}}{{ .Values.externalDatabase.existingSecretPasswordKey }}{{- end -}}
{{- end -}}

{{/* A random value kept across upgrades: (dict "ctx" $ "secret" name "key" key). */}}
{{- define "cvedetector.stableRandom" -}}
{{- $existing := lookup "v1" "Secret" .ctx.Release.Namespace .secret -}}
{{- if and $existing (hasKey $existing.data .key) -}}
{{- index $existing.data .key | b64dec -}}
{{- else -}}
{{- randAlphaNum 40 -}}
{{- end -}}
{{- end -}}

{{/* Fail early on contradictory or incomplete values. */}}
{{- define "cvedetector.validate" -}}
{{- $v := .Values -}}
{{- if and $v.agent.enabled (not (regexMatch "^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$" (toString $v.agent.clusterName))) -}}
{{- fail (printf "agent.clusterName %q is invalid: lowercase letters, digits and '-' (max 63)" (toString $v.agent.clusterName)) -}}
{{- end -}}
{{- if $v.api.enabled -}}
{{- if and $v.postgresql.enabled $v.externalDatabase.host -}}
{{- fail "Both postgresql.enabled and externalDatabase.host are set: choose one (set postgresql.enabled=false to use the external database)" -}}
{{- end -}}
{{- if and (not $v.postgresql.enabled) (not $v.externalDatabase.host) -}}
{{- fail "The API requires PostgreSQL: set postgresql.enabled=true (bundled) or externalDatabase.host" -}}
{{- end -}}
{{- if and (not $v.postgresql.enabled) (not $v.externalDatabase.password) (not $v.externalDatabase.existingSecret) -}}
{{- fail "externalDatabase needs a password: set externalDatabase.existingSecret (recommended) or externalDatabase.password" -}}
{{- end -}}
{{- end -}}
{{- if and $v.agent.enabled (not $v.api.enabled) -}}
{{- if not $v.agent.apiUrl -}}
{{- fail "agent.apiUrl is required when api.enabled=false (the agent must report to a remote API)" -}}
{{- end -}}
{{- if and (not $v.agent.token) (not $v.agent.existingTokenSecret) -}}
{{- fail "agent.existingTokenSecret (or agent.token) is required when api.enabled=false" -}}
{{- end -}}
{{- end -}}
{{- if and $v.dashboard.enabled (not $v.metrics.enabled) -}}
{{- fail "dashboard.enabled needs metrics.enabled: the dashboard reads the Prometheus metrics" -}}
{{- end -}}
{{- if and $v.ui.enabled (not $v.api.enabled) -}}
{{- fail "ui.enabled requires api.enabled in the same release" -}}
{{- end -}}
{{- end -}}
