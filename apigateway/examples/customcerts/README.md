# Importing Custom Certificates into API Gateway

This example demonstrates how to import custom certificates into API Gateway's truststore using init containers. The init container copies the Java cacerts truststore from the API Gateway image and imports custom certificates before the main API Gateway container starts.

## Overview

The solution uses:
- **Init Container**: Runs before the main container using the same API Gateway image to access Java keytool
- **Source Truststore**: Uses the cacerts file from the API Gateway image (`/opt/softwareag/jvm/jvm/jre/lib/security/cacerts`)
- **ConfigMaps**: Store custom certificates to import
- **Shared Volumes**: Allow init container to prepare the truststore for the main container

## Prerequisites

1. **Custom Certificate**: Certificate file(s) to import (e.g., `custom-ca.crt`)
2. **API Gateway Image**: The example uses the API Gateway image which contains Java and keytool

## Setup Steps

### 1. Create a ConfigMap with Custom Certificates

```bash
kubectl create configmap apigw-custom-certs \
  --from-file=custom-ca.crt=/path/to/your/custom-ca.crt \
  --from-file=another-cert.crt=/path/to/another-cert.crt \
  -n <namespace>
```

Alternatively, the example values.yaml includes a ConfigMap with a sample certificate that you can use for testing.

## Installing the Chart

Install the chart with the custom values file:

```bash
helm install apigw webmethods-helm-charts/apigateway \
  --values webmethods-helm-charts/apigateway/examples/customcerts/values.yaml \
  -n <namespace> \
  --create-namespace
```

## How It Works

1. **Init Container Execution**:
   - Uses the same API Gateway image as the main container to access Java keytool
   - Copies the cacerts truststore from `/opt/softwareag/jvm/jvm/jre/lib/security/cacerts` to a shared volume
   - Mounts custom certificates from a ConfigMap
   - Imports custom certificates into the copied truststore
   - Validates the truststore and verifies successful import

2. **Certificate Import Process**:
   - Copies Java's cacerts (contains standard CA certificates) to `/mnt/prepared/truststore.jks`
   - Validates the truststore format and password
   - Imports each custom certificate using Java keytool with `-storetype JKS`
   - Verifies successful import by listing the certificate

3. **Main Container**:
   - Starts after init container completes successfully
   - Mounts the shared directory with the prepared truststore
   - Uses the truststore via JVM system properties (`JAVA_OPTS`)
   - Has access to both standard Java CA certificates and custom certificates

## Configuration Details

### Init Container Configuration

The `extraInitContainers` section in values.yaml defines the init container with an inline shell script that:
- Copies cacerts from the API Gateway image
- Validates the truststore format
- Imports custom certificates
- Verifies the import was successful

### Volume Mounts

Two volume mounts are required:

1. **custom-certs**: Custom certificate files from ConfigMap (init container only)
2. **prepared-truststore**: Shared emptyDir for the prepared truststore (both init and main containers)

### JVM Configuration

The JVM must be configured to use the custom truststore via environment variables:

```yaml
extraEnvs:
  - name: JAVA_OPTS
    value: "-Djavax.net.ssl.trustStore=/mnt/prepared/truststore.jks -Djavax.net.ssl.trustStorePassword=changeit -Djavax.net.ssl.trustStoreType=JKS"
```

This sets the JVM system properties to:
- Use the truststore from `/mnt/prepared/truststore.jks`
- Authenticate with the truststore password
- Specify JKS as the truststore type

### Script Parameters

The init container script uses the following key paths and values:

- **Source Keystore**: `/opt/softwareag/jvm/jvm/jre/lib/security/cacerts` (from API Gateway image)
- **Target Directory**: `/mnt/prepared`
- **Target Keystore**: `/mnt/prepared/truststore.jks`
- **Keystore Password**: `changeit` (default Java cacerts password)
- **Certificate File**: `/mnt/certs/custom-ca.crt` (from ConfigMap)
- **Certificate Alias**: `example-custom-ca`
- **Keytool Path**: `/opt/softwareag/jvm/jvm/bin/keytool` (API Gateway 11.x)

## Multiple Certificates

To import multiple certificates, add them to the ConfigMap and extend the init container script to import each one:

```yaml
extraInitContainers:
  - name: import-custom-certs
    # ... (image, command, etc.)
    args:
      - |
        #!/bin/sh
        set -e
        # Copy cacerts
        cp /opt/softwareag/jvm/jvm/jre/lib/security/cacerts /mnt/prepared/truststore.jks
        
        # Import first certificate
        /opt/softwareag/jvm/jvm/bin/keytool -import \
          -noprompt -storetype JKS \
          -keystore /mnt/prepared/truststore.jks \
          -storepass changeit \
          -file /mnt/certs/custom-ca.crt \
          -alias example-custom-ca \
          -trustcacerts
        
        # Import second certificate
        /opt/softwareag/jvm/jvm/bin/keytool -import \
          -noprompt -storetype JKS \
          -keystore /mnt/prepared/truststore.jks \
          -storepass changeit \
          -file /mnt/certs/another-cert.crt \
          -alias another-custom-ca \
          -trustcacerts
```

## Troubleshooting

### Check Init Container Logs

```bash
kubectl logs <pod-name> -c import-custom-certs -n <namespace>
```

### Verify Certificate Import

After the pod is running, verify the certificate was imported:

```bash
kubectl exec <pod-name> -n <namespace> -- \
  /opt/softwareag/jvm/jvm/bin/keytool -list \
  -storetype JKS \
  -keystore /mnt/prepared/truststore.jks \
  -storepass changeit \
  -alias example-custom-ca
```

### List All Certificates in Truststore

```bash
kubectl exec <pod-name> -n <namespace> -- \
  /opt/softwareag/jvm/jvm/bin/keytool -list \
  -storetype JKS \
  -keystore /mnt/prepared/truststore.jks \
  -storepass changeit
```

### Common Issues

1. **"Invalid keystore format" error**:
   - The cacerts file path may be incorrect for your API Gateway version
   - Verify the cacerts location: `kubectl exec <pod-name> -- ls -la /opt/softwareag/jvm/jvm/jre/lib/security/cacerts`
   - Ensure the password `changeit` is correct (this is the default Java cacerts password)
   - Check init container logs for the exact error

2. **Init container fails**:
   - Check that the certificate files exist in the ConfigMap mount
   - Verify the ConfigMap was created correctly: `kubectl get configmap apigw-custom-certs -n <namespace> -o yaml`
   - Check init container logs for detailed error messages: `kubectl logs <pod-name> -c import-custom-certs -n <namespace>`

3. **Wrong keytool path**:
   - Verify the keytool path matches your API Gateway image version
   - For API Gateway 11.x: `/opt/softwareag/jvm/jvm/bin/keytool`
   - For older versions, the path may differ

4. **Permission issues**:
   - Ensure the init container has write permissions to the shared volume
   - Check pod security policies and security contexts
   - The emptyDir volume should be writable by default

5. **Certificate already exists**:
   - If re-importing, the alias may already exist in the truststore
   - Either use a different alias or delete the existing one first
   - To delete: `keytool -delete -alias example-custom-ca -keystore /mnt/prepared/truststore.jks -storepass changeit`

6. **Main container doesn't use custom truststore**:
   - Verify the `JAVA_OPTS` environment variable is set correctly
   - Check that the prepared-truststore volume is mounted in the main container
   - Ensure the truststore path in `JAVA_OPTS` matches the mount path

## Uninstalling the Chart

```bash
helm uninstall apigw -n <namespace>
```

## Additional Resources

- [API Gateway Helm Chart Documentation](../../helm/README.md)
- [Java Keytool Documentation](https://docs.oracle.com/en/java/javase/11/tools/keytool.html)