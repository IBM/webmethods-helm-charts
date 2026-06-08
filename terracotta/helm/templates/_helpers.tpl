{{/* vim: set filetype=mustache: */}}
{{- define "kube-terracotta.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 50 | trimSuffix "-" -}}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
The components in this chart create additional resources that expand the longest created name strings.
The longest name that gets created adds and extra 37 characters, so truncation should be 63-35=26.
*/}}
{{- define "kube-terracotta.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 26 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 26 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 26 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/* Create chart name and version as used by the chart label. */}}
{{- define "kube-terracotta.chartref" -}}
{{- replace "+" "_" .Chart.Version | printf "%s-%s" .Chart.Name -}}
{{- end }}

{{/* Generate basic labels */}}
{{- define "kube-terracotta.labels" -}}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: "{{ replace "+" "_" .Chart.Version }}"
app.kubernetes.io/part-of: {{ template "kube-terracotta.name" . }}
chart: {{ template "kube-terracotta.chartref" . }}
release: {{ $.Release.Name | quote }}
heritage: {{ $.Release.Service | quote }}
{{- end }}

{{/*
Allow the release namespace to be overridden for multi-namespace deployments in combined charts
*/}}
{{- define "kube-terracotta.namespace" -}}
  {{- if .Values.namespaceOverride -}}
    {{- .Values.namespaceOverride -}}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}

{{/* Create the name of kube-terracotta service account to use */}}
{{- define "kube-terracotta.operator.serviceAccountName" -}}
{{- if .Values.terracottaOperator.serviceAccount.create -}}
    {{ default (include "kube-terracotta.fullname" .) .Values.terracottaOperator.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.terracottaOperator.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "serverUrl" -}}
{{- $root := . }}
{{- range $i := until (int .Values.terracotta.stripes) -}}
{{- range $j := until (int $.Values.terracotta.nodes) -}}
{{ include "kube-terracotta.fullname" $root }}-terracotta-stripe-{{add $i 1}}-{{ add $j }}.{{ include "kube-terracotta.fullname" $root }}-terracotta-stripe-{{ add $i 1}}-service.{{ template "kube-terracotta.namespace" $ }}.svc.cluster.local,
{{- end -}}
{{- end -}}
{{- end -}}
