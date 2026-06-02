# Offline Installation of Elasticsearch Plugins

This example demonstrates how to install Elasticsearch plugins in an air-gapped or offline environment. The solution uses an init container to download and install plugins from a custom Artifactory URL before Elasticsearch starts.

## Overview

The solution uses:
- **Init Container**: Downloads and installs Elasticsearch plugins before the main Elasticsearch container starts
- **Custom Artifactory**: Hosts the plugin files in your internal network for air-gapped installations
- **Kubernetes Secrets**: Stores Artifactory credentials securely
- **Shared Volumes**: Allows the init container to install plugins that persist to the main Elasticsearch container

## Use Case

This example is particularly useful for:
- **Air-gapped environments**: Where direct internet access is restricted
- **Corporate networks**: With strict firewall rules requiring internal artifact repositories
- **Compliance requirements**: Mandating all dependencies come from approved internal sources
- **Offline installations**: Where external plugin downloads are not possible

## Prerequisites

1. **Artifactory or Internal Repository**: Hosting the Elasticsearch plugin files
2. **Plugin File**: The Elasticsearch plugin zip file (e.g., `mapper-size-8.17.3.zip`)
3. **Artifactory Credentials**: Username and password for accessing the repository
4. **API Gateway 11.x**: This example uses API Gateway 11.1 with minimal image

## Setup Steps

### 1. Upload Plugin to Artifactory

First, download the plugin from Elastic's official repository and upload it to your internal Artifactory:

```bash
# Download the plugin (from a machine with internet access)
curl -O https://artifacts.elastic.co/downloads/elasticsearch-plugins/mapper-size/mapper-size-8.17.3.zip

# Upload to your Artifactory
curl -u username:password \
  -T mapper-size-8.17.3.zip \
  "https://your-artifactory.company.com/artifactory/elasticsearch-plugins/mapper-size-8.17.3.zip"
```

### 2. Create Kubernetes Secret for Artifactory Credentials

Create a secret containing your Artifactory credentials:

```bash
kubectl create secret generic artifactory-credentials \
  --from-literal=username=your-artifactory-username \
  --from-literal=password=your-artifactory-password \
  -n <namespace>
```

### 3. Update the values.yaml

Modify the `MAPPER_SIZE_PLUGIN_URL` in the values.yaml file to point to your Artifactory URL:

```yaml
- name: MAPPER_SIZE_PLUGIN_URL
  value: "https://your-artifactory.company.com/artifactory/elasticsearch-plugins/mapper-size-8.17.3.zip"
```

## Installing the Chart

Install the chart with the custom values file:

```bash
helm install apigw webmethods-helm-charts/apigateway \
  --values webmethods-helm-charts/apigateway/examples/es-plugin-offline/values.yaml \
  -n <namespace> \
  --create-namespace
```

## How It Works

1. **Init Container Execution**:
   - Uses the official Elasticsearch image to access the `elasticsearch-plugin` command
   - Authenticates to Artifactory using credentials from the Kubernetes secret
   - Downloads the plugin zip file from your internal Artifactory
   - Installs the plugin using `elasticsearch-plugin install --batch`
   - The `--batch` flag automatically accepts all prompts

2. **Plugin Installation Process**:
   - Downloads plugin to `/tmp/mapper-size.zip`
   - Installs plugin to `/usr/share/elasticsearch/plugins` (shared volume)
   - Validates successful installation

3. **Main Elasticsearch Container**:
   - Starts after init container completes successfully
   - Mounts the shared `elasticsearch-plugins` volume
   - Loads the installed plugin automatically on startup

## Configuration Details

### Init Container Configuration

The init container is defined in the `extraInitContainers` section:

```yaml
extraInitContainers:
  install-mapper-size-plugin:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.17.3
    command:
      - /bin/bash
      - -c
      - |
        set -euo pipefail
        
        PLUGIN_FILE="/tmp/mapper-size.zip"
        
        curl -fL \
          -u "${ARTIFACTORY_USERNAME}:${ARTIFACTORY_PASSWORD}" \
          -o "${PLUGIN_FILE}" \
          "${MAPPER_SIZE_PLUGIN_URL}"
        
        bin/elasticsearch-plugin install --batch "file://${PLUGIN_FILE}"
```

### Environment Variables

The init container uses three environment variables:

- **ARTIFACTORY_USERNAME**: Retrieved from the `artifactory-credentials` secret
- **ARTIFACTORY_PASSWORD**: Retrieved from the `artifactory-credentials` secret
- **MAPPER_SIZE_PLUGIN_URL**: The full URL to the plugin file in your Artifactory

### Volume Configuration

A shared `emptyDir` volume is used to persist the installed plugins:

```yaml
volumes:
  - name: elasticsearch-plugins
    emptyDir: {}
```

This volume is mounted at `/usr/share/elasticsearch/plugins` in both the init container and the main Elasticsearch container.

## Installing Multiple Plugins

To install multiple plugins, you can extend the init container script:

```yaml
extraInitContainers:
  install-plugins:
    image: docker.elastic.co/elasticsearch/elasticsearch:8.17.3
    command:
      - /bin/bash
      - -c
      - |
        set -euo pipefail
        
        # Install mapper-size plugin
        PLUGIN_FILE="/tmp/mapper-size.zip"
        curl -fL -u "${ARTIFACTORY_USERNAME}:${ARTIFACTORY_PASSWORD}" \
          -o "${PLUGIN_FILE}" "${MAPPER_SIZE_PLUGIN_URL}"
        bin/elasticsearch-plugin install --batch "file://${PLUGIN_FILE}"
        
        # Install another plugin
        PLUGIN_FILE_2="/tmp/another-plugin.zip"
        curl -fL -u "${ARTIFACTORY_USERNAME}:${ARTIFACTORY_PASSWORD}" \
          -o "${PLUGIN_FILE_2}" "${ANOTHER_PLUGIN_URL}"
        bin/elasticsearch-plugin install --batch "file://${PLUGIN_FILE_2}"
    env:
      - name: ARTIFACTORY_USERNAME
        valueFrom:
          secretKeyRef:
            name: artifactory-credentials
            key: username
      - name: ARTIFACTORY_PASSWORD
        valueFrom:
          secretKeyRef:
            name: artifactory-credentials
            key: password
      - name: MAPPER_SIZE_PLUGIN_URL
        value: "https://your-artifactory.company.com/artifactory/elasticsearch-plugins/mapper-size-8.17.3.zip"
      - name: ANOTHER_PLUGIN_URL
        value: "https://your-artifactory.company.com/artifactory/elasticsearch-plugins/another-plugin.zip"
```

## Troubleshooting

### Check Init Container Logs

View the init container logs to see the plugin installation process:

```bash
kubectl logs <elasticsearch-pod-name> -c install-mapper-size-plugin -n <namespace>
```

### Verify Plugin Installation

After Elasticsearch starts, verify the plugin was installed successfully:

```bash
kubectl exec <elasticsearch-pod-name> -n <namespace> -- \
  bin/elasticsearch-plugin list
```

You should see `mapper-size` in the output.

### Common Issues

1. **Authentication failure**:
   - Verify the Artifactory credentials are correct
   - Check the secret exists: `kubectl get secret artifactory-credentials -n <namespace>`
   - Ensure the secret keys are named `username` and `password`

2. **Download failure**:
   - Verify the plugin URL is accessible from within the cluster
   - Check network policies and firewall rules
   - Test the URL manually: `curl -u username:password <PLUGIN_URL>`
   - Ensure the Artifactory URL is correct and the file exists

3. **Plugin installation fails**:
   - Check that the plugin version matches the Elasticsearch version
   - Verify the downloaded file is a valid Elasticsearch plugin zip
   - Review init container logs for detailed error messages

4. **Init container doesn't start**:
   - Verify the Elasticsearch image is accessible
   - Check image pull secrets if using a private registry
   - Review pod events: `kubectl describe pod <pod-name> -n <namespace>`

5. **Plugin not loaded by Elasticsearch**:
   - Ensure the `elasticsearch-plugins` volume is mounted correctly
   - Verify the volume mount path is `/usr/share/elasticsearch/plugins`
   - Check Elasticsearch logs for plugin loading errors

6. **Certificate/TLS errors**:
   - If your Artifactory uses self-signed certificates, you may need to add the CA certificate
   - Use `curl -k` (insecure) for testing only, not for production
   - Consider mounting custom CA certificates into the init container

## Alternative: Using Online Installation

For non-air-gapped environments, you can use the default Elasticsearch plugin installation method by setting:

```yaml
elasticsearch:
  defaultNodeSet:
    installMapperSizePlugin: true
```

This will install the plugin directly from Elastic's official repository without requiring an init container.

## Uninstalling the Chart

```bash
helm uninstall apigw -n <namespace>
```

## Additional Resources

- [API Gateway Helm Chart Documentation](../../helm/README.md)
- [Elasticsearch Plugin Installation](https://www.elastic.co/guide/en/elasticsearch/plugins/current/installation.html)
- [Elasticsearch Mapper Size Plugin](https://www.elastic.co/guide/en/elasticsearch/plugins/current/mapper-size.html)
- [ECK Operator Documentation](https://www.elastic.co/guide/en/cloud-on-k8s/current/index.html)