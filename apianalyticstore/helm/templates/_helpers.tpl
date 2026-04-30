{{/*
  * Copyright (c) 2026 IBM Corporation
  *
  * SPDX-License-Identifier: Apache-2.0
*/}}

{{/*
Elasticsearch secret name for ibm user
*/}}
{{- define "apianalyticstore.elasticsecret" -}}
{{- if .Values.elasticsearch.secretName -}}
{{- tpl .Values.elasticsearch.secretName . -}}
{{- else -}}
{{- printf "%s-ibm-user-es" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Kibana secret name
*/}}
{{- define "apianalyticstore.kibanasecret" -}}
{{- if .Values.kibana.secretName -}}
{{- tpl .Values.kibana.secretName . -}}
{{- else -}}
{{- printf "%s-kibana-user" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
OpenSearch secret name for ibm user
*/}}
{{- define "apianalyticstore.opensearchsecret" -}}
{{- if .Values.opensearch.secretName -}}
{{- tpl .Values.opensearch.secretName . -}}
{{- else -}}
{{- printf "%s-ibm-user-os" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
OpenSearch Dashboards secret name
*/}}
{{- define "apianalyticstore.opensearchdashboardssecret" -}}
{{- if .Values.opensearchDashboards.secretName -}}
{{- tpl .Values.opensearchDashboards.secretName . -}}
{{- else -}}
{{- printf "%s-opensearch-dashboards-user" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
OpenSearch Dashboards truststore password secret name
*/}}
{{- define "apianalyticstore.opensearchdashboardstruststorepassword" -}}
{{- if .Values.opensearchDashboards.tls.truststorePasswordSecret -}}
{{- tpl .Values.opensearchDashboards.tls.truststorePasswordSecret . -}}
{{- else -}}
{{- printf "%s-opensearch-dashboards-truststore-password" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Elasticsearch TLS secret name
*/}}
{{- define "apianalyticstore.elastictlssecret" -}}
{{- if .Values.elasticsearch.tlsSecretName -}}
{{- tpl .Values.elasticsearch.tlsSecretName . -}}
{{- else -}}
{{- printf "%s-es-tls-secret" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
OpenSearch admin credentials secret name
*/}}
{{- define "apianalyticstore.opensearchadminsecret" -}}
{{- if .Values.opensearch.adminCredentialsSecret -}}
{{- tpl .Values.opensearch.adminCredentialsSecret . -}}
{{- else -}}
{{- printf "%s-opensearch-admin" (include "common.names.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/*
Determine if Elasticsearch should be deployed
*/}}
{{- define "apianalyticstore.deployElasticsearch" -}}
{{- if and (eq .Values.databaseType "elasticsearch") .Values.elasticsearch.deploy -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
Determine if OpenSearch should be deployed
*/}}
{{- define "apianalyticstore.deployOpensearch" -}}
{{- if and (eq .Values.databaseType "opensearch") .Values.opensearch.deploy -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
Determine if Kibana should be deployed
*/}}
{{- define "apianalyticstore.deployKibana" -}}
{{- if and (eq .Values.databaseType "elasticsearch") .Values.elasticsearch.deploy -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
Determine if OpenSearch Dashboards should be deployed
*/}}
{{- define "apianalyticstore.deployOpensearchDashboards" -}}
{{- if and (eq .Values.databaseType "opensearch") .Values.opensearchDashboards.deploy -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{/*
Get the Elasticsearch service name
*/}}
{{- define "apianalyticstore.elasticsearchServiceName" -}}
{{- printf "%s-es-http" (include "common.names.fullname" .) -}}
{{- end -}}

{{/*
Get the OpenSearch service name
*/}}
{{- define "apianalyticstore.opensearchServiceName" -}}
{{- printf "%s" (include "common.names.fullname" .) -}}
{{- end -}}

{{/*
Get the Kibana service name
*/}}
{{- define "apianalyticstore.kibanaServiceName" -}}
{{- printf "%s-kb-http" (include "common.names.fullname" .) -}}
{{- end -}}

{{/*
Get the OpenSearch Dashboards service name
*/}}
{{- define "apianalyticstore.opensearchDashboardsServiceName" -}}
{{- printf "%s-opensearch-dashboards" (include "common.names.fullname" .) -}}
{{- end -}}