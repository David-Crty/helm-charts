{{/*
Expand the name of the chart.
*/}}
{{- define "generic-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "generic-app.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "generic-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "generic-app.labels" -}}
helm.sh/chart: {{ include "generic-app.chart" . }}
app.kubernetes.io/name: {{ include "generic-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "generic-app.baseSelectorLabels" -}}
app.kubernetes.io/name: {{ include "generic-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
{{- define "generic-app.webSelectorLabels" -}}
{{ include "generic-app.baseSelectorLabels" . }}
app.kubernetes.io/component: web
{{- end }}
{{- define "generic-app.workerSelectorLabels" -}}
{{ include "generic-app.baseSelectorLabels" . }}
app.kubernetes.io/component: worker
{{- end }}
{{- define "generic-app.cronjobSelectorLabels" -}}
{{ include "generic-app.baseSelectorLabels" . }}
app.kubernetes.io/component: cronjob
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "generic-app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "generic-app.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "generic-app.image" }}
{{- $tag := "" }}
{{- if .Values.tag }}
{{- $tag = .Values.tag }}
{{- else }}
{{- $tag = "latest" }}
{{- end }}
{{- printf "%s:%s" .Values.image $tag }}
{{- end }}

{{- define "toSlug" -}}
{{- $value := . | lower -}}
{{- $value = regexReplaceAll "\\W+" $value "-" }}
{{- print $value -}}
{{- end -}}

{{- define "common.resources.preset" -}}
{{/* The limits are the requests increased by 50% (except ephemeral-storage and xlarge/2xlarge sizes)*/}}
{{- $presets := dict
  "nano" (dict
      "requests" (dict "cpu" "50m" "memory" "128Mi" "ephemeral-storage" "1Gi")
      "limits" (dict "cpu" "200m" "memory" "256Mi" "ephemeral-storage" "2Gi")
   )
  "micro" (dict
      "requests" (dict "cpu" "50m" "memory" "128Mi" "ephemeral-storage" "1Gi")
      "limits" (dict "cpu" "500m" "memory" "512Mi" "ephemeral-storage" "2Gi")
   )
  "small" (dict
      "requests" (dict "cpu" "50m" "memory" "200Mi" "ephemeral-storage" "1Gi")
      "limits" (dict "cpu" "750m" "memory" "1024Mi" "ephemeral-storage" "2Gi")
   )
  "medium" (dict
      "requests" (dict "cpu" "100m" "memory" "256Mi" "ephemeral-storage" "1Gi")
      "limits" (dict "cpu" "750m" "memory" "1536Mi" "ephemeral-storage" "2Gi")
   )
  "large" (dict
      "requests" (dict "cpu" "200m" "memory" "512Mi" "ephemeral-storage" "1Gi")
      "limits" (dict "cpu" "1.5" "memory" "3072Mi" "ephemeral-storage" "2Gi")
   )
  "xlarge" (dict
      "requests" (dict "cpu" "500m" "memory" "1024Mi" "ephemeral-storage" "1Gi")
      "limits" (dict "cpu" "3.0" "memory" "6144Mi" "ephemeral-storage" "2Gi")
   )
  "2xlarge" (dict
      "requests" (dict "cpu" "1.0" "memory" "2048Mi" "ephemeral-storage" "1Gi")
      "limits" (dict "cpu" "6.0" "memory" "12288Mi" "ephemeral-storage" "2Gi")
   )
 }}
{{- if hasKey $presets .Values.resources.preset -}}
  {{- $preset := index $presets .Values.resources.preset -}}
  {{- if not .Values.resources.enableCpuLimit -}}
    {{- $_ := unset $preset.limits "cpu" -}}
  {{- end -}}
  {{- $preset | toYaml -}}
{{- else -}}
  {{- printf "ERROR: Preset key '%s' invalid. Allowed values are %s" .Values.resources.preset (join "," (keys $presets)) | fail -}}
{{- end -}}
{{- end -}}

{{- define "middlewareRedirections" -}}
{{- if .Values.ingress.redirections }}
{{- $fullName := include "generic-app.fullname" . -}}
{{- $middlewares := "" -}}
{{- range .Values.ingress.redirections }}
{{- $middlewareName := printf "traefik-%s-redirect-to-%s@kubernetescrd" $fullName (include "toSlug" .to) -}}
{{- if $middlewares }}
{{- $middlewares = printf "%s,%s" $middlewares $middlewareName -}}
{{- else }}
{{- $middlewares = $middlewareName -}}
{{- end }}
{{- end }}
{{- $middlewares -}},
{{- end }}
{{- end }}