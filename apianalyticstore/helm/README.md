# apianalyticstore

![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0](https://img.shields.io/badge/AppVersion-1.0-informational?style=flat-square)

Analytics Store Helm Chart for Kubernetes - Supports Elasticsearch+Kibana or OpenSearch+OpenSearch Dashboards

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://ibm.github.io/webmethods-helm-charts/charts | common | 1.0.4 |
| https://prometheus-community.github.io/helm-charts | prometheus-elasticsearch-exporter | 6.6.0 |

## Overview

The API Analytics Store Helm chart provides a flexible deployment solution for analytics and search capabilities using either:

- **Elasticsearch + Kibana** (using Elastic Cloud on Kubernetes operator)
- **OpenSearch + OpenSearch Dashboards** (using Opster OpenSearch operator)

This chart is designed to be used as a standalone analytics store or as a dependency for other charts like API Gateway.

## Prerequisites

### For Elasticsearch Deployment

- Kubernetes 1.19+
- Helm 3.2.0+
- Elastic Cloud on Kubernetes (ECK) operator installed
- PV provisioner support in the underlying infrastructure

Install ECK operator:
```bash
kubectl create -f https://download.elastic.co/downloads/eck/2.9.0/crds.yaml
kubectl apply -f https://download.elastic.co/downloads/eck/2.9.0/operator.yaml
```

### For OpenSearch Deployment

- Kubernetes 1.19+
- Helm 3.2.0+
- Opster OpenSearch Kubernetes operator installed
- PV provisioner support in the underlying infrastructure

Install Opster operator:
```bash
helm repo add opensearch-operator https://opster.github.io/opensearch-k8s-operator/
helm install opensearch-operator opensearch-operator/opensearch-operator
```

## Installing the Chart

### Deploy Elasticsearch + Kibana

```bash
helm install my-analytics-store webmethods/apianalyticstore \
  --set databaseType=elasticsearch \
  --set elasticsearch.deploy=true
```

### Deploy OpenSearch + OpenSearch Dashboards

```bash
helm install my-analytics-store webmethods/apianalyticstore \
  --set databaseType=opensearch \
  --set opensearch.deploy=true \
  --set opensearchDashboards.deploy=true
```

## Configuration

The following table lists the main configurable parameters of the API Analytics Store chart and their default values.

### Global Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `databaseType` | Database type to deploy: "elasticsearch" or "opensearch" | `"elasticsearch"` |
| `extraLabels` | Extra labels for all resources | `{}` |
| `imagePullSecrets` | Image pull secrets | `[{"name": "regcred"}]` |
| `revisionHistoryLimit` | Number of old ReplicaSets to retain | `10` |
| `secrets.generateSecrets` | Auto-generate authentication secrets | `true` |
| `customResourceObjects` | Array of custom Kubernetes resources to deploy | `[]` |

### Ingress Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable Ingress for dashboard access | `true` |
| `ingress.className` | Ingress class name | `"nginx"` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.defaultDomain` | Default domain for ingress hosts | `"my-domain.com"` |
| `ingress.hosts` | Ingress hosts configuration | `[{"host": "", "paths": [{"path": "/", "pathType": "Prefix"}]}]` |
| `ingress.tls` | TLS configuration for ingress | `[]` |

### OpenShift Routes Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `routes.enabled` | Enable OpenShift Routes | `false` |
| `routes.name` | Route name | `""` |
| `routes.portName` | Port name to use | `"http"` |
| `routes.labels` | Additional labels | `{}` |
| `routes.annotations` | Route annotations | `{}` |
| `routes.hostName` | Hostname for the route | `""` |
| `routes.tls.enabled` | Enable TLS for route | `false` |
| `routes.tls.termination` | TLS termination type | `"edge"` |
| `routes.tls.insecureEdgeTerminationPolicy` | Insecure edge termination policy | `"Redirect"` |

### Elasticsearch Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `elasticsearch.deploy` | Deploy Elasticsearch instance | `true` |
| `elasticsearch.version` | Elasticsearch version | `"8.2.3"` |
| `elasticsearch.image` | Custom Elasticsearch image | `""` |
| `elasticsearch.storage` | Storage size for Elasticsearch | `"5Gi"` |
| `elasticsearch.storageClassName` | Storage class name | `""` |
| `elasticsearch.resources` | Resource limits and requests | `{}` |
| `elasticsearch.tlsEnabled` | Enable TLS for Elasticsearch | `false` |
| `elasticsearch.defaultNodeSet.count` | Number of Elasticsearch nodes | `1` |
| `elasticsearch.defaultNodeSet.memoryMapping` | Enable memory mapping | `false` |

### Kibana Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `kibana.version` | Kibana version | `"8.2.3"` |
| `kibana.image` | Custom Kibana image | `""` |
| `kibana.count` | Number of Kibana instances | `1` |
| `kibana.port` | Kibana port | `5601` |
| `kibana.resources` | Resource limits and requests | `{}` |
| `kibana.allowAnonymousStatus` | Allow anonymous access to /api/status | `true` |

### OpenSearch Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `opensearch.deploy` | Deploy OpenSearch instance | `false` |
| `opensearch.version` | OpenSearch version | `"2.11.0"` |
| `opensearch.image` | Custom OpenSearch image | `""` |
| `opensearch.storage` | Storage size for OpenSearch | `"5Gi"` |
| `opensearch.storageClassName` | Storage class name | `""` |
| `opensearch.resources` | Resource limits and requests | `{}` |
| `opensearch.tlsEnabled` | Enable TLS for OpenSearch | `false` |
| `opensearch.defaultNodePool.replicas` | Number of OpenSearch nodes | `1` |

### OpenSearch Dashboards Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `opensearchDashboards.deploy` | Deploy OpenSearch Dashboards | `false` |
| `opensearchDashboards.version` | OpenSearch Dashboards version | `"2.11.0"` |
| `opensearchDashboards.image` | Custom image | `""` |
| `opensearchDashboards.count` | Number of instances | `1` |
| `opensearchDashboards.port` | Port | `5601` |
| `opensearchDashboards.resources` | Resource limits and requests | `{}` |
| `opensearchDashboards.allowAnonymousStatus` | Allow anonymous access | `true` |

### Prometheus Exporter Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `prometheus-elasticsearch-exporter.enabled` | Enable Elasticsearch exporter | `false` |

## Examples

### Production Elasticsearch Setup

```yaml
databaseType: elasticsearch

elasticsearch:
  deploy: true
  version: "8.2.3"
  storage: "50Gi"
  storageClassName: "fast-ssd"
  defaultNodeSet:
    count: 3
    memoryMapping: true
    setMaxMapCount: true
  resources:
    requests:
      memory: "4Gi"
      cpu: "2"
    limits:
      memory: "8Gi"
      cpu: "4"

kibana:
  count: 2
  resources:
    requests:
      memory: "1Gi"
      cpu: "500m"
    limits:
      memory: "2Gi"
      cpu: "1"

prometheus-elasticsearch-exporter:
  enabled: true
```

### Production OpenSearch Setup

```yaml
databaseType: opensearch

opensearch:
  deploy: true
  version: "2.11.0"
  storage: "50Gi"
  storageClassName: "fast-ssd"
  tlsEnabled: true
  defaultNodePool:
    replicas: 3
    jvm: "-Xms4g -Xmx4g"
  resources:
    requests:
      memory: "8Gi"
      cpu: "2"
    limits:
      memory: "8Gi"
      cpu: "4"

opensearchDashboards:
  deploy: true
  count: 2
  resources:
    requests:
      memory: "1Gi"
      cpu: "500m"
    limits:
      memory: "2Gi"
      cpu: "1"
```

### Ingress Configuration

```yaml
ingress:
  enabled: true
  className: "nginx"
  defaultDomain: "example.com"
  hosts:
    - host: "analytics.example.com"
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: analytics-tls
      hosts:
        - analytics.example.com
```

### OpenShift Routes Configuration

```yaml
routes:
  enabled: true
  hostName: "analytics.apps.openshift.example.com"
  tls:
    enabled: true
    termination: edge
    insecureEdgeTerminationPolicy: Redirect
```

### Custom Resource Objects (CROs)

Deploy additional Kubernetes resources alongside the analytics store:

```yaml
customResourceObjects:
  # Example: SealedSecret for secure credential management
  - apiVersion: bitnami.com/v1alpha1
    kind: SealedSecret
    metadata:
      name: "my-release-apianalyticstore-sealed-secret"
      namespace: "default"
    spec:
      encryptedData:
        username: AgBh8T7...encrypted-username...
        password: AgBh8T7...encrypted-password...
      template:
        metadata:
          name: "my-release-apianalyticstore-credentials"
          namespace: "default"
        type: Opaque
 
  # Example: ExternalSecret for external secret management
  - apiVersion: external-secrets.io/v1beta1
    kind: ExternalSecret
    metadata:
      name: "my-release-apianalyticstore-external-secret"
      namespace: "default"
    spec:
      refreshInterval: 1h
      secretStoreRef:
        name: vault-backend
        kind: SecretStore
      target:
        name: "my-release-apianalyticstore-vault-credentials"
        creationPolicy: Owner
      data:
        - secretKey: username
          remoteRef:
            key: analytics/credentials
            property: username
        - secretKey: password
          remoteRef:
            key: analytics/credentials
            property: password
```

This feature allows you to deploy any custom Kubernetes resources such as:
- **SealedSecrets** (Bitnami Sealed Secrets)
- **ExternalSecrets** (External Secrets Operator)
- **Certificates** (cert-manager)
- **Custom CRDs** specific to your environment

## Accessing the Services

### Elasticsearch

```bash
# Get the Elasticsearch service
kubectl get svc <release-name>-apianalyticstore-es-http

# Port forward to access locally
kubectl port-forward svc/<release-name>-apianalyticstore-es-http 9200:9200
```

### Kibana

```bash
# Get the Kibana service
kubectl get svc <release-name>-apianalyticstore-kb-http

# Port forward to access locally
kubectl port-forward svc/<release-name>-apianalyticstore-kb-http 5601:5601
```

### OpenSearch

```bash
# Get the OpenSearch service
kubectl get svc <release-name>-apianalyticstore

# Port forward to access locally
kubectl port-forward svc/<release-name>-apianalyticstore 9200:9200
```

### OpenSearch Dashboards

```bash
# Get the OpenSearch Dashboards service
kubectl get svc <release-name>-apianalyticstore-opensearch-dashboards

# Port forward to access locally
kubectl port-forward svc/<release-name>-apianalyticstore-opensearch-dashboards 5601:5601
```

## Retrieving Credentials

### Elasticsearch

```bash
# Get the IBM user password
kubectl get secret <release-name>-apianalyticstore-ibm-user-es -o jsonpath='{.data.password}' | base64 -d

# Get the Kibana user password
kubectl get secret <release-name>-apianalyticstore-kibana-user -o jsonpath='{.data.password}' | base64 -d
```

### OpenSearch

```bash
# Get the admin password
kubectl get secret <release-name>-apianalyticstore-opensearch-admin -o jsonpath='{.data.password}' | base64 -d

# Get the OpenSearch Dashboards user password
kubectl get secret <release-name>-apianalyticstore-opensearch-dashboards-user -o jsonpath='{.data.password}' | base64 -d
```

## Upgrading

### Switching from Elasticsearch to OpenSearch

**Warning:** Switching database types requires data migration. This is not handled automatically by the chart.

1. Backup your Elasticsearch data
2. Uninstall the current release
3. Install with OpenSearch configuration
4. Migrate data to OpenSearch

## Uninstalling the Chart

```bash
helm uninstall my-analytics-store
```

This command removes all the Kubernetes components associated with the chart and deletes the release.

## Troubleshooting

### Elasticsearch Pod Not Starting

Check if ECK operator is running:
```bash
kubectl get pods -n elastic-system
```

Check Elasticsearch logs:
```bash
kubectl logs <elasticsearch-pod-name>
```

### OpenSearch Pod Not Starting

Check if Opster operator is running:
```bash
kubectl get pods -n <operator-namespace>
```

Check OpenSearch logs:
```bash
kubectl logs <opensearch-pod-name>
```

### Storage Issues

Check PVC status:
```bash
kubectl get pvc
```

Ensure your cluster has a storage provisioner configured.

## Support

For issues and questions, please refer to:
- [GitHub Issues](https://github.com/IBM/webmethods-helm-charts/issues)
- [Documentation](https://github.com/IBM/webmethods-helm-charts)

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| customResourceObjects | list | `[]` | Custom Resource Objects (CROs) for additional Kubernetes resources This allows you to deploy any custom resources alongside the analytics store Example: SealedSecrets, ExternalSecrets, Certificates, etc.  Example SealedSecret: customResourceObjects:   - apiVersion: bitnami.com/v1alpha1     kind: SealedSecret     metadata:       name: {{ include "common.names.fullname" . }}-sealed-secret       namespace: {{ .Release.Namespace }}     spec:       encryptedData:         password: AgBh8T7...encrypted-data...       template:         metadata:           name: {{ include "common.names.fullname" . }}-credentials           namespace: {{ .Release.Namespace }}         type: Opaque |
| databaseType | string | `"elasticsearch"` | Database type for Analytics Store. Valid values: "elasticsearch" or "opensearch" This determines which search engine and dashboard to deploy |
| elasticsearch.affinity | object | `{}` | Set Pod (anti-) affinity for ElasticSearch. |
| elasticsearch.annotations | object | `{}` | Annotations for Elasticsearch crd |
| elasticsearch.certificateSecretName | string | `"{{ include \"common.names.fullname\" .}}-es-tls-secret"` | The name of the secret holding the tls secret |
| elasticsearch.defaultNodeSet | object | `{"annotations":{},"count":1,"extraCmdPluginInstaller":"","extraConfig":{},"extraInitContainers":{},"extraVolumeMounts":[],"extraVolumes":[],"installMapperSizePlugin":true,"memoryMapping":false,"setMaxMapCount":true}` | Default Node Set |
| elasticsearch.deploy | bool | `true` | Deploy elastic search instance |
| elasticsearch.disableElasticUser | bool | `false` | Decide wether to disable the default elastic user or not |
| elasticsearch.extraSecrets | list | `[]` | Extra Secrets adding or changing built-in users of Elasticsearch. |
| elasticsearch.image | string | `""` | The image that should be used. By default ECK will use the official Elasticsearch images. Overwrite this to use an image from an internal registry or any custom images. Make sure that the image corresponds to the version field. |
| elasticsearch.keystoreSecretName | string | `""` | The secret name that holds the keystore password |
| elasticsearch.nodeSets | list | `[]` | Node sets. |
| elasticsearch.podDisruptionBudget | object | `{"data":{},"enabled":true}` | Customization of ElasticSearchs PodDisruptionBudget Policy. |
| elasticsearch.priorityClassName | string | `""` | Set Pods' Priority Class Name |
| elasticsearch.resources | object | `{}` | Resource Settings for Elasticsearch |
| elasticsearch.secretName | string | `""` | The secret name that holds the sag es user. |
| elasticsearch.secretPasswordKey | string | `""` | The key that holds the Elasticsearch password; defaults to "password" |
| elasticsearch.secretUserKey | string | `""` | The key that holds the Elasticsearch user; defaults to "username" |
| elasticsearch.serviceAccount | object | `{"create":false,"name":"","roleBindingName":"elasticsearch-rolebinding","roleName":""}` | Enable and configure service account creation. |
| elasticsearch.storage | string | `"5Gi"` | Request size of storage. The default is 1Gi. |
| elasticsearch.storageAnnotations | object | `{}` | Annotations of PVC storage |
| elasticsearch.storageClassName | string | `""` | Use the storage class. |
| elasticsearch.tlsEnabled | bool | `false` | Whether the communication should be HTTPS |
| elasticsearch.tlsSecretName | string | `""` | The name of the elasticsearch secret. |
| elasticsearch.topologySpreadConstraints | object | `{}` | Set Pod topology spread constraints for ElasticSearch. |
| elasticsearch.version | string | `"8.2.3"` | The ECK version to be used |
| extraConfigMaps | list | `[]` | Extra ConfigMaps for dashboards, configurations, etc. Example for dashboards: extraConfigMaps:   - name: kibana-dashboards     data:       system-metrics.ndjson: |         {"type":"dashboard","id":"system-metrics","attributes":{"title":"System Metrics"}}   - name: opensearch-dashboards     binaryData:       logo.png: <base64-encoded-data> |
| extraLabels | object | `{}` | Extra Labels for all resources |
| imagePullSecrets | list | `[{"name":"regcred"}]` | Image pull secret reference. By default looks for `regcred`. |
| ingress | object | `{"annotations":{"nginx.ingress.kubernetes.io/proxy-body-size":"10m","nginx.ingress.kubernetes.io/proxy-connect-timeout":"600","nginx.ingress.kubernetes.io/proxy-read-timeout":"600"},"className":"nginx","defaultDomain":"my-domain.com","enabled":true,"hosts":[{"host":"","paths":[{"path":"/","pathType":"Prefix"}]}],"tls":[{"hosts":[],"secretName":""}]}` | Ingress configuration for dashboards (Kibana or OpenSearch Dashboards) |
| ingress.defaultDomain | string | `"my-domain.com"` | Default domain for ingress |
| kibana.affinity | object | `{}` | Set Pod (anti-) affinity for Kibana. |
| kibana.allowAnonymousStatus | bool | `true` | Enable anonymous access to /api/status. |
| kibana.annotations | object | `{}` | Annotations for Kibana |
| kibana.count | int | `1` |  |
| kibana.customLogging | object | `{"appenders":{},"enabled":false,"loggers":[],"root":{}}` | Custom logging configuration for kibana container. |
| kibana.extraContainers | list | `[]` | The definition of extra containers for kibana. |
| kibana.extraInitContainers | list | `[]` | The definition of extra initContainers for kibana. |
| kibana.extraLabels | object | `{}` | Additional labels to be added to kibana pod labels. |
| kibana.extraVolumeMounts | list | `[]` | The definition of extra volumeMounts for kibana. |
| kibana.extraVolumes | list | `[]` | The definition of extra volumes for kibana. |
| kibana.image | string | `""` | The image that should be used. |
| kibana.livenessProbe | object | `{}` | Configure Kibana's livenessProbe. |
| kibana.podSecurityContext | object | `{}` | The pod securityContext for kibana pod. |
| kibana.port | int | `5601` | The default Kibana Port |
| kibana.priorityClassName | string | `""` | Set Pods' Priority Class Name |
| kibana.readinessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/status","port":5601,"scheme":"HTTP"},"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1}` | Configure Kibana's readinessProbe. |
| kibana.resources | object | `{}` | Resource Settings for Kibana |
| kibana.secretName | string | `""` | The secret name that holds the kibana user. |
| kibana.securityContext | object | `{}` | The securityContext for kibana container. |
| kibana.serviceAccount | object | `{"create":false,"name":"","roleBindingName":"kibana-rolebinding","roleName":""}` | Enable and configure service account creation. |
| kibana.tls | object | `{"enabled":false,"secretName":"","trustStoreName":"","truststorePasswordSecret":"","verificationMode":"certificate"}` | Enable and configure tls connection from Kibana to Elasticsearch. |
| kibana.topologySpreadConstraints | object | `{}` | Set Pod topology spread constraints for Kibana. |
| kibana.version | string | `"8.2.3"` | The ECK version to be used |
| opensearch.additionalConfig | object | `{}` | Additional configuration for OpenSearch cluster |
| opensearch.adminCredentialsSecret | string | `""` | The secret name that holds the admin credentials for OpenSearch. |
| opensearch.affinity | object | `{}` | Set Pod (anti-) affinity for OpenSearch. |
| opensearch.annotations | object | `{}` | Annotations for OpenSearch cluster |
| opensearch.dashboards | object | `{"additionalConfig":{},"enable":false,"image":"","replicas":1,"resources":{},"tls":{"enable":false,"secretName":""},"version":""}` | OpenSearch Dashboards configuration |
| opensearch.defaultNodePool | object | `{"additionalConfig":{},"annotations":{},"env":[],"extraVolumeMounts":[],"extraVolumes":[],"initContainers":[],"jvm":"","labels":{},"nodeSelector":{},"persistence":{},"replicas":1,"tolerations":[]}` | Default Node Pool |
| opensearch.deploy | bool | `false` | Deploy OpenSearch instance using OpenSearch Operator |
| opensearch.http | object | `{"tlsSecretName":""}` | HTTP layer TLS configuration |
| opensearch.httpPort | int | `9200` | HTTP port for OpenSearch. Default is 9200 |
| opensearch.image | string | `""` | The image that should be used. |
| opensearch.nodePools | list | `[]` | Node pools. |
| opensearch.pluginsList | list | `[]` | List of plugins to install |
| opensearch.priorityClassName | string | `""` | Set Pods' Priority Class Name |
| opensearch.resources | object | `{}` | Resource Settings for OpenSearch |
| opensearch.secretName | string | `""` | The secret name that holds the security config for OpenSearch. |
| opensearch.storage | string | `"5Gi"` | Request size of storage. The default is 5Gi. |
| opensearch.storageClassName | string | `""` | Use the storage class. |
| opensearch.tlsEnabled | bool | `false` | Whether the communication should be HTTPS |
| opensearch.topologySpreadConstraints | object | `{}` | Set Pod topology spread constraints for OpenSearch. |
| opensearch.transport | object | `{"tlsSecretName":""}` | Transport layer TLS configuration |
| opensearch.vendor | string | `"opensearch"` | The vendor for OpenSearch. Default is "opensearch" |
| opensearch.version | string | `"2.11.0"` | The OpenSearch version to be used |
| opensearchDashboards.affinity | object | `{}` | Set Pod (anti-) affinity for OpenSearch Dashboards. |
| opensearchDashboards.allowAnonymousStatus | bool | `true` | Enable anonymous access to /api/status. |
| opensearchDashboards.annotations | object | `{}` | Annotations for OpenSearch Dashboards |
| opensearchDashboards.config | object | `{}` | Additional configuration for OpenSearch Dashboards as key-value pairs |
| opensearchDashboards.count | int | `1` | Number of OpenSearch Dashboards replicas |
| opensearchDashboards.deploy | bool | `false` | Deploy OpenSearch Dashboards instance |
| opensearchDashboards.extraContainers | list | `[]` | The definition of extra containers for opensearch dashboards. |
| opensearchDashboards.extraEnv | list | `[]` | Additional environment variables for OpenSearch Dashboards |
| opensearchDashboards.extraInitContainers | list | `[]` | The definition of extra initContainers for opensearch dashboards. |
| opensearchDashboards.extraLabels | object | `{}` | Additional labels to be added to opensearch dashboards pod labels. |
| opensearchDashboards.extraVolumeMounts | list | `[]` | The definition of extra volumeMounts for opensearch dashboards. |
| opensearchDashboards.extraVolumes | list | `[]` | The definition of extra volumes for opensearch dashboards. |
| opensearchDashboards.image | string | `""` | The image that should be used. |
| opensearchDashboards.livenessProbe | object | `{}` | Configure OpenSearch Dashboards' livenessProbe. |
| opensearchDashboards.opensearchHosts | string | `""` | OpenSearch hosts URL. Defaults to the OpenSearch service created by this chart. |
| opensearchDashboards.podSecurityContext | object | `{}` | The pod securityContext for opensearch dashboards pod. |
| opensearchDashboards.port | int | `5601` | The default OpenSearch Dashboards Port |
| opensearchDashboards.priorityClassName | string | `""` | Set Pods' Priority Class Name |
| opensearchDashboards.readinessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/api/status","port":5601,"scheme":"HTTP"},"periodSeconds":10,"successThreshold":1,"timeoutSeconds":5}` | Configure OpenSearch Dashboards' readinessProbe. |
| opensearchDashboards.resources | object | `{}` | Resource Settings for OpenSearch Dashboards |
| opensearchDashboards.secretName | string | `""` | The secret name that holds the opensearch dashboards user credentials. |
| opensearchDashboards.securityContext | object | `{}` | The securityContext for opensearch dashboards container. |
| opensearchDashboards.serviceAccount | object | `{"create":false,"name":"","roleBindingName":"opensearch-dashboards-rolebinding","roleName":""}` | Enable and configure service account creation. |
| opensearchDashboards.tls | object | `{"enabled":false,"secretName":"","trustStoreName":"","truststorePasswordSecret":"","verificationMode":"certificate"}` | Enable and configure tls connection from OpenSearch Dashboards to OpenSearch. |
| opensearchDashboards.topologySpreadConstraints | object | `{}` | Set Pod topology spread constraints for OpenSearch Dashboards. |
| opensearchDashboards.version | string | `"2.11.0"` | The OpenSearch Dashboards version to be used |
| prometheus-elasticsearch-exporter | object | `{"enabled":false,"es":{"uri":"http://$(ES_USER):$(ES_PASSWORD)@{{ printf \"%s\" .Release.Name }}-apianalyticstore-es-http:9200"},"extraEnvSecrets":{"ES_PASSWORD":{"key":"password","secret":"{{ printf \"%s-apianalyticstore-ibm-user-es\" .Release.Name }}"},"ES_USER":{"key":"username","secret":"{{ printf \"%s-apianalyticstore-ibm-user-es\" .Release.Name }}"}},"podAnnotations":{"prometheus.io/path":"/metrics","prometheus.io/port":"9108","prometheus.io/scheme":"http","prometheus.io/scrape":"true"},"podSecurityContext":{"runAsNonRoot":true,"runAsUser":1000730001},"revisionHistoryLimit":10,"serviceAccount":{"name":""},"serviceMonitor":{"enabled":false}}` | Elasticsearch exporter settings. |
| prometheus-elasticsearch-exporter.enabled | bool | `false` | Deploy the prometheus exporter for elasticsearch |
| prometheus-elasticsearch-exporter.extraEnvSecrets | object | `{"ES_PASSWORD":{"key":"password","secret":"{{ printf \"%s-apianalyticstore-ibm-user-es\" .Release.Name }}"},"ES_USER":{"key":"username","secret":"{{ printf \"%s-apianalyticstore-ibm-user-es\" .Release.Name }}"}}` | secret for elasticsearch user. |
| prometheus-elasticsearch-exporter.revisionHistoryLimit | int | `10` | The number of old ReplicaSets to retain to allow rollback. |
| revisionHistoryLimit | int | `10` | The number of old ReplicaSets to retain to allow rollback. |
| routes | object | `{"annotations":{},"enabled":false,"hostName":"","labels":{},"name":"","portName":"http","tls":{"enabled":false,"insecureEdgeTerminationPolicy":"Redirect","termination":"edge"}}` | OpenShift Routes configuration for dashboards |
| routes.hostName | string | `""` | Hostname for the route |
| routes.name | string | `""` | Route name, defaults to release name |
| routes.portName | string | `"http"` | Port name to use (http) |
| secrets | object | `{"generateSecrets":true}` | Controls if secrets should be generated automatically. |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)