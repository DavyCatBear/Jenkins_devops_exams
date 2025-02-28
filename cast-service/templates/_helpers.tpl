{{/*
Expand the name of the chart.
*/}}
{{- define "cast-service.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cast-service.fullname" -}}
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
{{- define "cast-service.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "cast-service.labels" -}}
helm.sh/chart: {{ include "cast-service.chart" . }}
{{ include "cast-service.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "cast-service.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cast-service.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "cast-service.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "cast-service.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/* Définir une fonction pour obtenir l'URI de la base de données en fonction de l'environnement */}}
{{- define "cast-service.databaseUri" -}}
{{- if eq .Values.environment "dev" -}}
{{- .Values.environments.dev.database_uri | b64enc }}
{{- else if eq .Values.environment "qa" -}}
{{- .Values.environments.qa.database_uri | b64enc }}
{{- else if eq .Values.environment "staging" -}}
{{- .Values.environments.staging.database_uri | b64enc }}
{{- else if eq .Values.environment "prod" -}}
{{- .Values.environments.prod.database_uri | b64enc }}
{{- end -}}
{{- end -}}

{{/* Définir une fonction pour obtenir l'URL du service hôte en fonction de l'environnement */}}
{{- define "cast-service.serviceHostUrl" -}}
{{- if eq .Values.environment "dev" -}}
{{- .Values.environments.dev.service_host_url | b64enc }}
{{- else if eq .Values.environment "qa" -}}
{{- .Values.environments.qa.service_host_url | b64enc }}
{{- else if eq .Values.environment "staging" -}}
{{- .Values.environments.staging.service_host_url | b64enc }}
{{- else if eq .Values.environment "prod" -}}
{{- .Values.environments.prod.service_host_url | b64enc }}
{{- end -}}
{{- end -}}

