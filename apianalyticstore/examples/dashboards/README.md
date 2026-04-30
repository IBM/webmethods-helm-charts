# Dashboard Examples

This directory contains example dashboards and visualizations for both Kibana and OpenSearch Dashboards.

## Overview

Dashboards can be deployed using ConfigMaps that are mounted into the dashboard containers. The examples provided here demonstrate common monitoring and analytics use cases.

## Deployment Methods

### Method 1: Using ConfigMaps (Recommended)

Deploy dashboards as ConfigMaps that are automatically loaded by Kibana or OpenSearch Dashboards.

#### For Kibana (Elasticsearch)

```bash
# Create ConfigMap with dashboard
kubectl create configmap kibana-dashboards \
  --from-file=system-metrics-dashboard.ndjson \
  -n <namespace>

# Deploy with values
helm install analytics webmethods/apianalyticstore \
  --set databaseType=elasticsearch \
  --set elasticsearch.deploy=true \
  --set kibana.extraVolumes[0].name=dashboards \
  --set kibana.extraVolumes[0].configMap.name=kibana-dashboards \
  --set kibana.extraVolumeMounts[0].name=dashboards \
  --set kibana.extraVolumeMounts[0].mountPath=/usr/share/kibana/data/dashboards
```

#### For OpenSearch Dashboards

```bash
# Create ConfigMap with dashboard
kubectl create configmap opensearch-dashboards \
  --from-file=application-logs-dashboard.ndjson \
  -n <namespace>

# Deploy with values
helm install analytics webmethods/apianalyticstore \
  --set databaseType=opensearch \
  --set opensearch.deploy=true \
  --set opensearchDashboards.deploy=true \
  --set opensearchDashboards.extraVolumes[0].name=dashboards \
  --set opensearchDashboards.extraVolumes[0].configMap.name=opensearch-dashboards \
  --set opensearchDashboards.extraVolumeMounts[0].name=dashboards \
  --set opensearchDashboards.extraVolumeMounts[0].mountPath=/usr/share/opensearch-dashboards/data/dashboards
```

### Method 2: Using extraConfigMaps (Recommended for Helm)

Deploy dashboards directly from values.yaml using extraConfigMaps:

```yaml
extraConfigMaps:
  - name: "{{ include \"common.names.fullname\" . }}-kibana-dashboards"
    data:
      system-metrics.ndjson: |
        {"type":"dashboard","id":"system-metrics","attributes":{"title":"System Metrics"}}
        {"type":"visualization","id":"viz-1","attributes":{"title":"CPU Usage"}}

kibana:
  extraVolumes:
    - name: dashboards
      configMap:
        name: "{{ include \"common.names.fullname\" . }}-kibana-dashboards"
  extraVolumeMounts:
    - name: dashboards
      mountPath: /usr/share/kibana/data/dashboards
      readOnly: true
```

**Deploy with values file:**
```bash
helm install analytics webmethods/apianalyticstore \
  -f values-with-dashboards.yaml
```

See `values-with-dashboards.yaml` for a complete example.

### Method 3: Using Custom Resource Objects

Deploy dashboards as part of the Helm chart using customResourceObjects:

```yaml
customResourceObjects:
  - apiVersion: v1
    kind: ConfigMap
    metadata:
      name: "{{ include \"common.names.fullname\" . }}-dashboards"
      namespace: "{{ .Release.Namespace }}"
    data:
      system-metrics.ndjson: |
        {"type":"dashboard","id":"system-metrics","attributes":{"title":"System Metrics"}}
```

### Method 4: Manual Import via UI

1. Access Kibana/OpenSearch Dashboards UI
2. Navigate to **Stack Management** > **Saved Objects**
3. Click **Import**
4. Select the `.ndjson` file
5. Click **Import**

### Method 5: Using API

#### Kibana API

```bash
# Get credentials
KIBANA_USER=$(kubectl get secret <release>-apianalyticstore-kibana-user -o jsonpath='{.data.username}' | base64 -d)
KIBANA_PASS=$(kubectl get secret <release>-apianalyticstore-kibana-user -o jsonpath='{.data.password}' | base64 -d)

# Import dashboard
curl -X POST "http://localhost:5601/api/saved_objects/_import" \
  -H "kbn-xsrf: true" \
  -u "$KIBANA_USER:$KIBANA_PASS" \
  --form file=@system-metrics-dashboard.ndjson
```

#### OpenSearch Dashboards API

```bash
# Get credentials
OSD_USER=$(kubectl get secret <release>-apianalyticstore-opensearch-dashboards-user -o jsonpath='{.data.username}' | base64 -d)
OSD_PASS=$(kubectl get secret <release>-apianalyticstore-opensearch-dashboards-user -o jsonpath='{.data.password}' | base64 -d)

# Import dashboard
curl -X POST "http://localhost:5601/api/saved_objects/_import" \
  -H "osd-xsrf: true" \
  -u "$OSD_USER:$OSD_PASS" \
  --form file=@application-logs-dashboard.ndjson
```

## Available Dashboards

### 1. System Metrics Dashboard
**File:** `system-metrics-dashboard.ndjson`
**Use Case:** Monitor system-level metrics (CPU, memory, disk, network)
**Data Source:** Metricbeat or similar system metrics collector

### 2. Application Logs Dashboard
**File:** `application-logs-dashboard.ndjson`
**Use Case:** Analyze application logs, errors, and warnings
**Data Source:** Filebeat, Fluentd, or application log shippers

### 3. API Analytics Dashboard
**File:** `api-analytics-dashboard.ndjson`
**Use Case:** Monitor API Gateway metrics, request rates, response times
**Data Source:** API Gateway logs and metrics

## Creating Custom Dashboards

### Export Existing Dashboard

#### From Kibana
```bash
curl -X GET "http://localhost:5601/api/saved_objects/_export" \
  -H "kbn-xsrf: true" \
  -u "$KIBANA_USER:$KIBANA_PASS" \
  -H "Content-Type: application/json" \
  -d '{"type":"dashboard","includeReferencesDeep":true}' \
  > my-dashboard.ndjson
```

#### From OpenSearch Dashboards
```bash
curl -X GET "http://localhost:5601/api/saved_objects/_export" \
  -H "osd-xsrf: true" \
  -u "$OSD_USER:$OSD_PASS" \
  -H "Content-Type: application/json" \
  -d '{"type":"dashboard","includeReferencesDeep":true}' \
  > my-dashboard.ndjson
```

### Dashboard Structure

Dashboards are stored in NDJSON (Newline Delimited JSON) format. Each line represents a saved object:

```json
{"type":"index-pattern","id":"logs-*","attributes":{"title":"logs-*"}}
{"type":"visualization","id":"viz-1","attributes":{"title":"Request Rate"}}
{"type":"dashboard","id":"dash-1","attributes":{"title":"My Dashboard"}}
```

## Best Practices

1. **Version Control**: Store dashboard files in version control
2. **Naming Convention**: Use descriptive names for dashboards
3. **Documentation**: Document data sources and required indices
4. **Testing**: Test dashboards in development before production
5. **Automation**: Use CI/CD pipelines to deploy dashboards
6. **Backup**: Regularly export and backup dashboards

## Troubleshooting

### Dashboard Not Loading

1. Check if ConfigMap is created:
   ```bash
   kubectl get configmap <configmap-name> -n <namespace>
   ```

2. Verify volume mount:
   ```bash
   kubectl describe pod <dashboard-pod> -n <namespace>
   ```

3. Check dashboard logs:
   ```bash
   kubectl logs <dashboard-pod> -n <namespace>
   ```

### Import Errors

- Ensure index patterns exist before importing visualizations
- Check for ID conflicts with existing objects
- Verify JSON format is valid NDJSON

## Additional Resources

- [Kibana Dashboard Documentation](https://www.elastic.co/guide/en/kibana/current/dashboard.html)
- [OpenSearch Dashboards Documentation](https://opensearch.org/docs/latest/dashboards/index/)
- [Saved Objects API](https://www.elastic.co/guide/en/kibana/current/saved-objects-api.html)