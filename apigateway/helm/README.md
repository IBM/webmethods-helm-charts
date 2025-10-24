# API Gateway Cluster Helm Chart

## Overview

This chart sets up an API Gateway cluster which by default consists of
* 1 API Gateway cluster nodes,
* 1 ElasticSearch cluster with 1 node,
* 1 Kibana node,
* 1 Ingress providing public access to the API Gateay UI and runtime ports.

![API Gateway Cluster](../docs/diagrams/api_gateway.png)

### TLDR;

The minimum prerequisite that has to be fulfilled is, that the **ECK operator** is installed. See section [Prerequisites](#ECK / Elasticsearch) for details.

You can install the default configuration of the API Gateway cluster with the following command:

```
helm install <your-release-name> webmethods/apigateway -f my-values.yaml --set-file license=licenseKey.xml
```

This will install the API Gateway cluster with the following default configuration as depicted above. Make sure that the licenseKey.xml points to a valid license file.

## Prerequisites

### ECK / Elasticsearch

This deployment uses the ECK Operator to deploy Elasticsearch. You can use Helm to deploy the operator with the following commands:

#### Register the Elasticsearch Helm Repository

```
helm repo add elastic https://helm.elastic.co
helm repo update
```

#### Install ECK (Cluster-wide)

```
helm install elastic-operator elastic/eck-operator -n elastic-system --create-namespace
```

For more information please see: https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-install-helm.html

## Licenses

API Gateway requires a license file. These license is supposed to be
provided as configmap.

Hence before running `helm install` create the configmap:

```
kubectl create configmap apigw-license-config --from-file=licensekey=<your path to API Gateway license file>
```

Optionally you can directly provide the license file at the time of running `helm install`:

```
helm install <your-release-name> webmethods/apigateway -f my-values.yaml --set-file license=licenseKey.xml
```

Note: the license key config map will not be removed when the helm release is deleted.

## Image Pull Secret

Provide an image pull secret for the registry where the desired images for API Gateway,
ElasticSearch, and Kibana are to be pulled from.

```
kubectl create secret docker-registry regcred --docker-server=<your-registry-server> --docker-username=<your-name> --docker-password=<your-pwd> --docker-email=<your-email>
```

## Access to the API Gateway cluster

By default, this chart establishes an Ingress to provide access to the API Gateway UI and runtime ports from outside the Kubernetes cluster.
The Ingress refers to services which in turn refer to the API Gateway pods. Due to the API Gateway UI requiring sticky sessions ([see also below](#sticky-ui-sessions)) the Ingress
is configured accordingly. However this default setup works only if the Kubernetes cluster runs with the wide-spread nginx-ingress controller which
can handle sticky sessions.

If the nginx-ingress controller is not present, or another ingress controller is preferred, an accordingly configured external load balancer can be used to
achieve sticky sessions. The chart can easily be switched to use a load balancer, for details see the [chart readme](apigateway/README.md).
When doing so, the chart will still establish an Ingress which then refers to the load balancer service, and the load balancer in turn is
configured as a proxy for the API Gateway services.

For the latter purpose the chart comes with an nginx deployment and appropriate configuration. Please note that API Gateway does not
rely on or prefer nginx. In order to use a different load balancer the chart needs to be adapted manually: replace the `nginx-*.yaml` files
in the [template folder](apigateway/templates) as desired, and keep in mind to configure the load balancer with sticky sessions for the
API Gateway UI port.

### Sticky UI sessions

The API Gateway web interface requires sticky sessions in order to function correctly. This is achieved by configuring the API Gateway service
for the UI port as well as the Ingress with sticky behaviour. The relevant parts of the service and the Ingress look like this:

```
---
# apigateway-ui-svc.yaml
apiVersion: v1
kind: Service
spec:
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 1000
---
# apigateway-ingress.yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/affinity: "cookie"
```

Note, if you are using the default configuration and nginx as your ingress controller, sticky sessions will be enabled by default for the UI port and ingress. Change the ingress annotations accordingly for other ingress controllers like Traefik.

## Using an external load balancer

The Ingress provides two entrypoints for accessing the API Gateway cluster, one for the UI port to
allow access to the administration UI, and another one for the runtime port to allow for example REST access
to the services.

The API Gateway UI requires session stickiness and therefore both the Ingress and the Kubernetes
service in front of the API Gateway pods are correspondingly configured.

In some cases, typically if the nginx-ingress controller is not available in the Kubernetes system, the stickiness
settings are not correctly respected, and the API Gateway UI will not work. In particular the login to the UI
will fail.

This can be handled by using an external load balancer which is configured to use the API Gateway as
backend. And the Ingress is then defined against the load balancer service.

In order to enable the external load balancer provide the following configuration value:

```
--set loadBalancer.enabled=true
```

## TLS for API Gateway

If desired you may deploy API Gateway with your own TLS key and cert. The Template contains a TLS manifest which will look for the keys: ingress.tls.key and ingress.tls.cert. In your deployment environment you can redirect the output of a certificate and key file (e.g. using secure files from Azure) and directly deploy the TLS configuration for the API Gateway.

```bash
helm upgrade -i -f myvalues.yaml --set ingress.tls.key="$(<key.pem)" --set ingress.tls.cert="$(<cert.pem)"
```

## Examples for Use-cases

Sub-folder `examples` contains some *values* examples for more use-cases. To use the use-case, adapt and add the provided `values.yaml` to your values.

| Use-case | Description |
|-----|------|
| [fluentd-sidecar](../examples/fluentd-sidecar/README.md) | Running API Gateway with Fluentd Sidecar |
| [house-keeping-job](../examples/house-keeping-job/README.md) | Example to create house keeping job: purge transaction events  |

## Version History

| Version | Changes and Description |
|-----|------|
| `1.0.0` | Initial release |
| `1.1.0` | Bug fixes in default values and helper functions for elastic secret names. <br> **Attention:** moved elasticsearch secret keys: <br>elasticSecretName --> elasticsearch.secretName<br>elasticSecretUserKey --> elasticsearch.secretUserKey<br>elasticSecretPasswordKey --> elasticsearch.secretPasswordKey |
| `1.2.0` | Added Kibana TLS/SSL functionality towards Elasticsearch. Helper function aded for kibana truststore password. |
| `1.2.1` | Added Kibana configuration field 'status.allowAnonymous' set by Values.kibana.allowAnonymousStatus. This removes errors in API Gateway log indicating that Kibana is not available. |
| `1.2.2` | Option in `values.yaml` to create a ServiceMonitor added. |
| `1.2.3` | Job template added to create house keeping (cron) jobs.  |
| `1.2.4` | Added Kibana extra container configuration, set by Values.kibana.extraContainers. <br> Added ServiceMonitor matchLabel for a specific service. The service is set by .Values.serviceMonitor.serviceName defaulting to API Gateways runtime service. |
| `1.2.5` | Added possibility to read metering truststore password by secretKeyRef. <br> Added custom logging configuration for Kibana. |
| `1.2.6` | Fixed commons dependency to enable metering change from 1.2.5. |
| `1.2.7` | Added possibility to rename roleBinding for API Gateway, Kibana and Elasticsearch. This allows for multiple deployments into the same namespace. Also, CRD ServiceMonitor selector corrected. Support of ES storage PVC annotations. |
| `1.2.8` | `tpl` function support in `affinity` value added. `affinity` support added for Kibana and Elasticsearch. `topologySpreadConstraints` support added for APIGW, Elasticsearch and Kibana. |
| `1.2.9` | `priorityClassName` support added for APIGW, Elasticsearch and Kibana. |
| `2.0.0` | Prometheus Elasticsearch Exporter version `6.5.0` is used. Value `revisionHistoryLimit` is added and documented. |
| `2.0.1` | Fix `revisionHistoryLimit` for Kibana. |
| `2.1.0` | Added ability to use PodDisruptionBudget for API Gateway and updated Prometheus Elasticsearch Exporter to `6.6.0` |
| `2.1.1` | Fixed metadata of PodDisruptionBudget for API Gateway |
| `2.1.2` | Fixed metadata.name of PodDisruptionBudget for API Gateway |
| `2.1.3` | Fixed proxy connect timeout annotation on all ingresses for API Gateway |
| `3.0.0` | Added functionality to define startup, liveness and readiness probes for API Gateway in the values file. |
| `3.1.0` | Added functionality to define annotations for Elasticsearch and Kibana custom resource definition in the values file. |
| `3.2.0` | Added minor changes and example values for API Gateway 11.1 |
| `3.3.0` | Install Elasticsearch Plugins behind a Proxy. See `extraCmdPluginInstaller` |
| `3.3.1` | Setting of environment variable in Job template fixed. |
| `3.4.0` | The Service Monitor supports the setting of `fallbackScrapeProtocol`. This allows newer Prometheus server versions 3.x to scrape metrics from API Gateway. See [Prometheus configuration](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config) for more information. Set the port `apigw.adminPort` to empty value if you don't want to expose the administration port as a service.|

## Chart Version `3.0.0`

Added functionality to define liveness and readiness probes for API Gateway in the values file.
Added startup probe to the API Gateway deployment.
This allows for smaller timeouts in the liveness probe and thus an unresponsive API Gateway container will be recognized and restarted faster by Kubernetes.

### Migrate from `2.x.x` to `3.0.0`

Due to moving the definition of startup and readiness probes into the default values.yaml file, the path .Values.apigw.readinessProbe.scheme changed to .Values.apigw.readinessProbe.httpGet.scheme.
If you have overwritten the values in your own values-file you have to change the path for the chart to work.

## Chart Version `2.0.0`

The Chart version `2.0.0` uses the [Prometheus Elasticsearch Exporter](https://github.com/prometheus-community/helm-charts/tree/main/charts/prometheus-elasticsearch-exporter) version `6.5.0`.

### Migrate from `1.x.x` to `2.0.0`

If you want to migrate the Elasticsearch Exporter version `5.0.0`, you must delete the existing deployment. Over install is not working. You see the error ...

```
Error: UPGRADE FAILED: cannot patch "apigw-prometheus-elasticsearch-exporter" ...
```

To delete the Elasticsearch Exporter deployment ...

```
kubectl delete deployment <Helm-release-name>-prometheus-elasticsearch-exporter  -n <namespace>
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Set Pod (anti-) affinity for APIGW. You can use templates inside because `tpl` function is called for rendering. |
| apigw.adminPort | int | `5555` | The default administration port. Note in a default installation this port will also be used for runtime traffic. Set the port to empty value if you don't want to expose the administration port as a service. |
| apigw.adminSecretKey | string | `""` | The key that holds the admin secret key; defauls to "password" |
| apigw.adminSecretName | string | `""` | The secret that holds the admin password Depends on secrets.genereateAdminSecret; if true the setting will be ignored. |
| apigw.apigwAdminService | string | `"apigw-admin-svc"` |  |
| apigw.applicationProperties | string | `""` | Application Properties to overwrite default API Gateway settings. Please check Handle with care - Most settings should be set via the UI, Admin API, configSources values, or via environment variables. By default only the default Administrator password is set through this mechanism if nothing is set here. Other examples are extended settings which can be set through this mechanism. Examples:  Set the default Administrator password from environment variable user.Administrator.password=$env{ADMINISTRATOR_PASSWORD}  Avoid archiving audit log files ... settings.watt.server.audit.logFilesToKeep=1  Avoid archiving server log files ... settings.watt.server.serverlogFilesToKeep=1  Avoid archiving statistic files ... settings.watt.server.stats.logFilesToKeep=1  Value for 1 to 9 to set debug level of server log ... settings.watt.debug.level=  Set the maximum number of permitted service threads in the global pool ... settings.watt.server.threadPool=750  Set the default request/response content-type ... settings.watt.net.default.content-type=json  Avoid IS internal statistic data collector ... statisticsdatacollector.monitorConfig.enabled=false |
| apigw.configSources | object | `{"cluster":{"actionOnStartupError":"standalone","aware":"{{- $isClusterEnabled := or (gt (int .Values.replicaCount) 1) .Values.apigw.clusterAware -}} {{- if $isClusterEnabled -}} true {{- else -}} false {{- end }}","ignite":{"communicationPort":"10400","discoveryPort":"10100","k8sNamespace":"{{ .Release.Namespace }}","k8sServiceName":"{{ include \"common.names.fullname\" . }}-rt"},"name":"IgniteCluster","sessTimeout":"60"},"elasticsearch":{"hosts":"{{ default (printf \"%s-%s-es-http\" .Release.Name .Chart.Name) .Values.global.elasticsearch.serviceName }}:{{ .Values.global.elasticsearch.port }}","tenantId":"default"},"kibana":{"dashboardInstance":"{{ printf \"http://%s-%s-kb-http:%d\" .Release.Name .Chart.Name (int .Values.kibana.port) }}"}}` | configuration source files for API Gateway |
| apigw.diagPort | int | `9999` | The API Diagnostics port. |
| apigw.elasticSearchDeployment | bool | `true` | Deploy Elasticsearch. Depends on Elasic Search Helm Charts. See https://github.com/elastic/helm-charts/blob/main/elasticsearch |
| apigw.elastickeyStoreName | string | `""` | The secret that holds the keystore password. If empty the chart will generate the name: fullname + "-es-keystore-secret". |
| apigw.elastickeyStorePassKey | string | `""` | The key that holds the keystore password; defaults to "password" |
| apigw.elastictrustStoreName | string | `""` | The secret that holds the truststore password. If empty the chart will generate the name: fullname + "-es-truststore-secret". |
| apigw.elastictrustStorePassKey | string | `""` | The key that holds the truststore password; defaults to "password" |
| apigw.extraConfigSources | list | `[]` | Extra configuration sources for API Gateway Example: - type: YAML   allowEdit: false   properties:     location: apigw-config.yml |
| apigw.extraLabels | object | `{}` | Additional labels to be added to apigw pod labels. |
| apigw.grpcPort | int | `4440` | gRPC port for High Availability and Fault Tolerance (HAFT) solution. This port must be manually setup after API Gateway was initizalized. |
| apigw.initContainer | object | `{"enabled":true,"securityContext":{}}` | SecurityContext for apigw initContainer Deactivated by default. Usage example: securityContext:   runAsGroup: 1000   runAsUser: 1000   runAsNonRoot: true   allowPrivilegeEscalation: false   capabilities:     drop:       - ALL |
| apigw.initContainer.enabled | bool | `true` | If apigw initContainer for ES should be enabled |
| apigw.initMemory | string | `"1024Mi"` |  |
| apigw.isHomeDir | string | `"/opt/softwareag/IntegrationServer/instances/default"` | IS HOME directory, for 11.x images based on Microservices Runtime use /opt/softwareag/IntegrationServer |
| apigw.livenessProbe | object | `{"failureThreshold":3,"initialDelaySeconds":10,"periodSeconds":10,"successThreshold":1,"tcpSocket":{"port":"admin-http"},"timeoutSeconds":1}` | livenessProbe configuration for API Gateway container. The liveness probe is used to determine if the container is still running. |
| apigw.maxMemory | string | `"1024Mi"` |  |
| apigw.readinessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/rest/apigateway/health","port":"admin-http","scheme":"HTTP"},"initialDelaySeconds":30,"periodSeconds":30,"successThreshold":1,"timeoutSeconds":1}` | readinessProbe configuration for API Gateway container. The readiness probe is used to determine if the container is ready to accept traffic. |
| apigw.rtExternalService | string | `"apigw-rt-ext-svc"` |  |
| apigw.rtService | string | `"apigw-rt-svc"` |  |
| apigw.runtimeExternalPort | int | `6555` | External Runtime Port for Reverse Invoke Setups. This port must be manually setup after API Gateway was initizalized. |
| apigw.runtimePort | int | `5556` | The API Gateway runtime port for API invocations. By default API Gateway images do not have this port setup. You must manually set up this port or create post init job that creates this port after API Gateway was initialized. |
| apigw.sagIsConfigProperties | string | `"/config/application.properties"` | Specifies the location and name of the configuration variables template or the directory containing templates for use with Microservices Runtime or an Integration Server with licensed Microservices functionality. Use a comma-separated list to specify multiple templates and/or directories. See: https://documentation.softwareag.com/webmethods/integration_server/pie10-15/webhelp/pie-webhelp/index.html#page/pie-webhelp%2Fto-sag_environment_variables_2.html Note: should only be used for passing simple configurations such as extended settings. For all other configurations of API Gateway, use the official Admin REST API. |
| apigw.serviceName | string | `"apigw"` |  |
| apigw.startupProbe | object | `{"failureThreshold":12,"periodSeconds":30,"successThreshold":1,"tcpSocket":{"port":"admin-http"},"timeoutSeconds":1}` | startupProbe configuration for API Gateway container. Runs before the livenessProbe. It is used to determine if the container has finished starting. |
| apigw.uiPort | int | `9072` | The default API Administration UI port |
| apigw.uiService | string | `"apigw-ui-svc"` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| elasticsearch.affinity | object | `{}` | Set Pod (anti-) affinity for ElasticSearch. You can use templates inside because `tpl` function is called for rendering. |
| elasticsearch.annotations | object | `{}` | Annotations for Elasticsearch crd |
| elasticsearch.certificateSecretName | string | `"{{ include \"common.names.fullname\" .}}-es-tls-secret"` | The name of the secret holding the tls secret By default the name will be fullname of release + "es-tls-secret" |
| elasticsearch.defaultNodeSet | object | `{"annotations":{},"count":1,"extraCmdPluginInstaller":"","extraConfig":{},"extraInitContainers":{},"installMapperSizePlugin":true,"memoryMapping":false,"setMaxMapCount":true}` | Default Node Set |
| elasticsearch.defaultNodeSet.annotations | object | `{}` | Annotations for Elasticsearch pod annotations |
| elasticsearch.defaultNodeSet.count | int | `1` | the number of replicas for Elastic Search |
| elasticsearch.defaultNodeSet.extraCmdPluginInstaller | string | `""` | Extra command before Plugin Installer is called. This can be used to set environment variable regarding Proxy settings bevore the Plugin Installer is called. The Plugin Installer needs the `CLI_JAVA_OPTS` environment variable to work through a proxy. Use the following template for setting Java options to install Plugins behind a proxy. `export CLI_JAVA_OPTS="-Dhttp.proxyHost=host_name -Dhttp.proxyPort=port_number -Dhttps.proxyHost=host_name -Dhttps.proxyPort=https_port_number"` |
| elasticsearch.defaultNodeSet.extraConfig | object | `{}` | Extra configuration parameters for Elasticsearch nodes to be appended to the default (none). See https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-node-configuration.html |
| elasticsearch.defaultNodeSet.extraInitContainers | object | `{}` | Extra init containers to be started before Elasticsearch nodes are started. See https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-init-containers-plugin-downloads.html |
| elasticsearch.defaultNodeSet.memoryMapping | bool | `false` | Set this to true for production workloads, this will also use an init container to increase the vm.max_map_count to 262144 on the nodes. |
| elasticsearch.defaultNodeSet.setMaxMapCount | bool | `true` | Controls whether to start an init container that increases the vm.max_map_count to 262144 on the node. Set memoryMapping to true and this setting also to true to run the init container. Note that this requires the ability to run privileged containers, which is likely not the case on many secure clusters. |
| elasticsearch.deploy | bool | `true` | Deploy elastic search instance |
| elasticsearch.disableElasticUser | bool | `false` | Decide wether to disable the default elastic user or not |
| elasticsearch.extraSecrets | list | `[]` | Extra Secrets adding or changing built-in users of Elasticsearch. You can use this to limit the roles of the default elastic user. Note if you specify user and roles, the secret will be generated with a random password. If you just specify a name, the secret will be used as is. Example for setting the default user elastic to role view only:  - name: "elasticusersecret"    username: "elastic"    roles: "viewer" |
| elasticsearch.image | string | `nil` | The image that should be used. By default ECK will use the official Elasticsearch images. Overwrite this to use an image from an internal registry or any custom images. Make sure that the image corresponds to the version field. |
| elasticsearch.keystoreSecretName | string | `""` | The secret name that holds the keystore password |
| elasticsearch.nodeSets | list | `[]` | Node sets. See official ElasticSearch documentation at: https://www.elastic.co/guide/en/cloud-on-k8s/current/k8s-orchestration.html if you specify node sets here the defaultNodeSet will not be used. |
| elasticsearch.podDisruptionBudget | object | `{"data":{},"enabled":true}` | Customization of ElasticSearchs PodDisruptionBudget Policy. Elastic Cloud on Kubernetes operator (ECK) creates a default PodDisruptionBudget Policy. |
| elasticsearch.podDisruptionBudget.data | object | `{}` | Overwrite the default PodDisruptionBudget Policy. Overwriting with custom PodDisruptionBudget Policy requires enabled=true. Examples can be seen here: https://kubernetes.io/docs/tasks/run-application/configure-pdb/ |
| elasticsearch.podDisruptionBudget.enabled | bool | `true` | Whether a PodDisruptionBudget Policy should be created. Enabled=true results in ECK deploying the default (or custom, see data) PodDisruptionBudget Policy. Enabled=false results in no PodDisruptionBudget Policy deployment. |
| elasticsearch.priorityClassName | string | `""` | Set Pods' Priority Class Name |
| elasticsearch.resources | object | `{}` | Resource Settings for Elasticsearch Example:  limits:   cpu: 100m   memory: 128Mi requests:   cpu: 100m   memory: 128Mi |
| elasticsearch.secretName | string | `""` | The secret name that holds the sag es user for API Gateway. |
| elasticsearch.secretPasswordKey | string | `""` | The key that holds the Elasticsearch password; defauls to "password" |
| elasticsearch.secretUserKey | string | `""` | The key that holds the Elasticsearch user; defauls to "username" |
| elasticsearch.serviceAccount | object | `{"create":false,"name":"","roleBindingName":"elasticsearch-rolebinding","roleName":""}` | Enable and configure service account creation. |
| elasticsearch.serviceAccount.create | bool | `false` | Whether to create a ServiceAccount for Elasticsearch |
| elasticsearch.serviceAccount.name | string | `""` | Name of the ServiceAccount for Elasticsearch |
| elasticsearch.serviceAccount.roleBindingName | string | `"elasticsearch-rolebinding"` | Name of the ServiceAccount Rolebinding used by the Elasticsearch ServiceAccount. Requires create=true to work. |
| elasticsearch.serviceAccount.roleName | string | `""` | Name of the ServiceAccount Role used by the Elasticsearch ServiceAccount. Requires create=true to work. |
| elasticsearch.storage | string | `""` | Request size of storage. The default is 1Gi. |
| elasticsearch.storageAnnotations | object | `{}` | Annotations of PVC storage |
| elasticsearch.storageClassName | string | `""` | Use the storage class. |
| elasticsearch.tlsEnabled | bool | `false` | Whether the communication from APIGW and Kibana should be HTTPS Note: you will need to create certificate and a separate truststore for the communication. |
| elasticsearch.tlsSecretName | string | `""` | The name of the elasticsearch secret. By default it will created by the fullname + "-es-tls-secret" if tlsEnabled is set to true. |
| elasticsearch.topologySpreadConstraints | object | `{}` | Set Pod topology spread constraints for ElasticSearch. You can use templates inside because `tpl` function is called for rendering. |
| elasticsearch.version | string | `"8.2.3"` | The ECK version to be used |
| extraConfigMaps | list | `[]` | Extra config maps for additional configurations such as extra ports, etc. |
| extraContainers | list | `[]` | Extra containers which should run in addition to the main container as a sidecar - name: do-something   image: busybox   command: ['do', 'something'] |
| extraEnvs | object | `{}` | Exta environment properties to be passed on to the container |
| extraInitContainers | list | `[]` | Extra init containers that are executed before starting the main container - name: do-something   image: busybox   command: ['do', 'something'] |
| extraLabels | object | `{}` | Extra Labels for API Gateway |
| extraVolumeMounts | list | `[]` | Extra volume mounts - name: extras   mountPath: /usr/share/extras   readOnly: true |
| extraVolumes | list | `[]` | Exta volumes that should be mounted. - name: extras   emptyDir: {} |
| fullnameOverride | string | `""` | Overwrites full workload name. As default, the workload name is release name + '-' + Chart name. |
| global.apigwHealthPort | int | `5555` | Port for health check for kibana startup, must same value as apigwAdminPort |
| global.apigwHealthProtocol | string | `"http"` | Protocol for health check for kibana startup, must be http / https |
| global.apigwHealthService | string | `"apigw-admin-svc"` | Service name for health check for kibana startup, must same value as apigwAdminService |
| global.curlImage | string | `"curlimages/curl"` |  |
| global.elasticsearch | object | `{"port":9200,"serviceName":""}` | Elasticsearch global settings Required for Prometheus Exporter Sub Chart |
| global.elasticsearch.serviceName | string | `""` | The elasticsearch http service name that API Gateway uses. The default is compiled of the fullname (releasename + chart name) + "-http" You MUST override this if you use an external elastic search service and do not deploy the embedded elastic CRD from this chart. |
| grpcService.azureInternalLoadBalancer | bool | `false` |  |
| grpcService.dnsExternal | bool | `false` |  |
| grpcService.enabled | bool | `false` |  |
| grpcService.hostname | string | `""` |  |
| grpcService.type | string | `"LoadBalancer"` |  |
| hostAliases | list | `[]` | Value to add extra host aliases to APIGW container. |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"ibmwebmethods.azurecr.io/apigateway-minimal"` | The repository for the image. By default, this points to the IBM webMethods container repository. Change this for air-gapped installations or custom images. For the IBM webMethods container repository you need to have a valid access token stored as registry credentials |
| image.tag | string | `"10.15"` | The image tag of the apigateway image default this will be the latest version. For realworld scenarios SAG recommends to use a specific version to not accidently change production versions with newer images. |
| imagePullSecrets | list | `[{"name":"regcred"}]` | Image pull secret reference. By default looks for `regcred`. |
| ingress.defaultDomain | string | `"my-domain.com"` |  |
| ingress.tls.cert | string | `""` |  |
| ingress.tls.key | string | `""` |  |
| ingress.tls.secretName | string | `""` | default secret name for TLS. By default empty, will look for <release-name-apigateway->tls". |
| ingress.tls.secretProviderClassName | string | `""` |  |
| ingress.tls.secretProviderEnabled | bool | `false` |  |
| ingress.tls.secretProviderName | string | `""` |  |
| ingress.tls.secretProviderParameters | object | `{}` |  |
| ingresses.admin.annotations."nginx.ingress.kubernetes.io/affinity" | string | `"cookie"` |  |
| ingresses.admin.annotations."nginx.ingress.kubernetes.io/proxy-body-size" | string | `"10m"` |  |
| ingresses.admin.annotations."nginx.ingress.kubernetes.io/proxy-connect-timeout" | string | `"600"` |  |
| ingresses.admin.annotations."nginx.ingress.kubernetes.io/proxy-read-timeout" | string | `"600"` |  |
| ingresses.admin.className | string | `"nginx"` |  |
| ingresses.admin.defaultHost | string | `""` |  |
| ingresses.admin.enabled | bool | `true` |  |
| ingresses.admin.hosts[0].host | string | `nil` |  |
| ingresses.admin.hosts[0].paths[0].path | string | `"/"` |  |
| ingresses.admin.hosts[0].paths[0].pathType | string | `"Prefix"` |  |
| ingresses.admin.svcName | string | `""` |  |
| ingresses.admin.svcPort | string | `""` |  |
| ingresses.admin.tls[0].hosts | string | `nil` |  |
| ingresses.admin.tls[0].secretName | string | `nil` |  |
| ingresses.admin.tls[0].secretProviderEnabled | bool | `false` |  |
| ingresses.admin.tls[0].secretProviderSecretName | string | `nil` |  |
| ingresses.rt.annotations."nginx.ingress.kubernetes.io/proxy-body-size" | string | `"10m"` |  |
| ingresses.rt.annotations."nginx.ingress.kubernetes.io/proxy-connect-timeout" | string | `"600"` |  |
| ingresses.rt.annotations."nginx.ingress.kubernetes.io/proxy-read-timeout" | string | `"600"` |  |
| ingresses.rt.className | string | `"nginx"` |  |
| ingresses.rt.defaultHost | string | `""` |  |
| ingresses.rt.enabled | bool | `true` |  |
| ingresses.rt.hosts[0].host | string | `nil` |  |
| ingresses.rt.hosts[0].paths[0].path | string | `"/gateway"` |  |
| ingresses.rt.hosts[0].paths[0].pathType | string | `"Prefix"` |  |
| ingresses.rt.svcName | string | `""` |  |
| ingresses.rt.svcPort | string | `""` |  |
| ingresses.rt.tls[0].hosts | string | `nil` |  |
| ingresses.rt.tls[0].secretName | string | `nil` |  |
| ingresses.rt.tls[0].secretProviderEnabled | bool | `false` |  |
| ingresses.rt.tls[0].secretProviderSecretName | string | `nil` |  |
| ingresses.ui.annotations."nginx.ingress.kubernetes.io/affinity" | string | `"cookie"` |  |
| ingresses.ui.annotations."nginx.ingress.kubernetes.io/proxy-body-size" | string | `"10m"` |  |
| ingresses.ui.annotations."nginx.ingress.kubernetes.io/proxy-connect-timeout" | string | `"600"` |  |
| ingresses.ui.annotations."nginx.ingress.kubernetes.io/proxy-read-timeout" | string | `"600"` |  |
| ingresses.ui.className | string | `"nginx"` |  |
| ingresses.ui.defaultHost | string | `""` |  |
| ingresses.ui.enabled | bool | `true` |  |
| ingresses.ui.hosts[0].host | string | `nil` |  |
| ingresses.ui.hosts[0].paths[0].path | string | `"/"` |  |
| ingresses.ui.hosts[0].paths[0].pathType | string | `"Prefix"` |  |
| ingresses.ui.svcName | string | `""` |  |
| ingresses.ui.svcPort | string | `""` |  |
| ingresses.ui.tls[0].csiSecretProvider | string | `nil` |  |
| ingresses.ui.tls[0].hosts | string | `nil` |  |
| ingresses.ui.tls[0].secretName | string | `nil` |  |
| ingresses.ui.tls[0].secretProviderEnabled | bool | `false` |  |
| ingresses.ui.tls[0].secretProviderSecretName | string | `nil` |  |
| kibana.affinity | object | `{}` | Set Pod (anti-) affinity for Kibana. You can use templates inside because `tpl` function is called for rendering. |
| kibana.allowAnonymousStatus | bool | `true` | Enable anonymous access to /api/status. |
| kibana.annotations | object | `{}` | Annotations for Kibana |
| kibana.count | int | `1` |  |
| kibana.customLogging | object | `{"appenders":{},"enabled":false,"loggers":[],"root":{}}` | Custom logging configuration for kibana container. |
| kibana.customLogging.appenders | object | `{}` | Define appenders for custom logging config. Example for logging to file: file:   type: file   fileName: /usr/share/kibana/logs/kibana.log   layout:     type: pattern |
| kibana.customLogging.enabled | bool | `false` | Enable custom logging configuration. |
| kibana.customLogging.loggers | list | `[]` | Define loggers other than root logger. Example for custom server logger: - name: server   appenders: [console]   level: warn |
| kibana.customLogging.root | object | `{}` | Define which appenders are used by root logger. Example for logging to file additionally to default/console:   appenders: [file, default]   level: warn |
| kibana.extraContainers | list | `[]` | The definition of extra containers for kibana. |
| kibana.extraInitContainers | list | `[]` | The definition of extra initContainers for kibana. |
| kibana.extraLabels | object | `{}` | Additional labels to be added to kibana pod labels. |
| kibana.extraVolumeMounts | list | `[]` | The definition of extra volumeMounts for kibana. |
| kibana.extraVolumes | list | `[]` | The definition of extra volumes for kibana. |
| kibana.image | string | `nil` | The image that should be used. By default ECK will use the official Elasticsearch images. Overwrite this to use an image from an internal registry or any custom images. Make sure that the image corresponds to the version field. |
| kibana.livenessProbe | object | `{}` | Configure Kibana's livenessProbe. |
| kibana.podSecurityContext | object | `{}` | The pod securityContext for kibana pod. |
| kibana.port | int | `5601` | The default Kibana Port |
| kibana.priorityClassName | string | `""` | Set Pods' Priority Class Name |
| kibana.readinessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/status","port":5601,"scheme":"HTTP"},"periodSeconds":10,"successThreshold":1,"timeoutSeconds":1}` | Configure Kibana's readinessProbe. |
| kibana.resources | object | `{}` | Resource Settings for Kibana Example:  limits:   cpu: 100m   memory: 128Mi requests:   cpu: 100m   memory: 128Mi |
| kibana.secretName | string | `""` | The secret name that holds the kibana user for API Gateway. |
| kibana.securityContext | object | `{}` | The securityContext for kibana container. |
| kibana.serviceAccount | object | `{"create":false,"name":"","roleBindingName":"kibana-rolebinding","roleName":""}` | Enable and configure service account creation. |
| kibana.serviceAccount.create | bool | `false` | Whether to create a ServiceAccount for Kibana |
| kibana.serviceAccount.name | string | `""` | Name of the ServiceAccount for Kibana |
| kibana.serviceAccount.roleBindingName | string | `"kibana-rolebinding"` | Name of the ServiceAccount Rolebinding used by the Kibana ServiceAccount. Requires create=true to work. |
| kibana.serviceAccount.roleName | string | `""` | Name of the ServiceAccount Role used by the Kibana ServiceAccount. Requires create=true to work. |
| kibana.tls | object | `{"enabled":false,"secretName":"","trustStoreName":"","truststorePasswordSecret":"","verificationMode":"certificate"}` | Enable and configure tls connection from Kibana to Elasticsearch. |
| kibana.tls.enabled | bool | `false` | Whether to enable tls connection from Kibana to Elasticsearch. |
| kibana.tls.secretName | string | `""` | Name of the k8s secret holding the p12 truststore for Kibana |
| kibana.tls.trustStoreName | string | `""` | File name of the p12 truststore for Kibana |
| kibana.tls.truststorePasswordSecret | string | `""` | Name of the k8s secret containing the password for above p12 truststore in key 'password' |
| kibana.tls.verificationMode | string | `"certificate"` | TLS verification mode. Either 'none', 'certificate' or 'full'. Full includes hostname verification (service name must be in alt dns for it to work). |
| kibana.topologySpreadConstraints | object | `{}` | Set Pod topology spread constraints for Kibana. You can use templates inside because `tpl` function is called for rendering. |
| kibana.version | string | `"8.2.3"` | The ECK version to be used |
| license | string | `""` | Import the content as license key and create a ConfigMap named by `licenseConfigMap` value. You can copy/past the content of your provided license key file here. |
| licenseConfigKey | string | `""` |  |
| licenseConfigName | string | `""` | The name of the secret or configmap that contains the license key. Defaults to the release name + chart name + "-license". |
| lifecycle | object | `{}` | lifecycle hooks to execute on preStop / postStart,... preStop:   exec:     command: ["/bin/sh", "-c", "echo Hello from the postStart handler > /usr/share/message"] postStart:   exec:     command: ["/bin/sh", "-c", "echo Hello from the postStart handler > /usr/share/message"] |
| metering.accumulationPeriod | string | `"1800"` | The period in seconds for which data is accumulated before a log record is produced. |
| metering.enabled | bool | `true` | enable metering |
| metering.logLevel | string | `nil` | The level of log messages that are logged on the console. Valid values are: *error - logs only ERROR messages. *warn (default) - logs ERROR and WARN messages. *info - logs ERROR, WARN, and INFO messages. *debug - logs ERROR, WARN, INFO, and DEBUG messages. Use as a Java system property or an environment variable to see the debug messages of the configuration initialization. |
| metering.proxyAddress | string | `nil` | The proxy address in a <host>:<port> format that the metering client uses. Configure this property only if you use a metering proxy. |
| metering.proxyPass | string | `nil` | The proxy password that the metering client uses. Configure this property only if you use a metering proxy with authentication. Depending on the method that you use to provide a password, ensure that you escape password characters that are specific for the selected method. Valid characters: *Letters: A-Z, a-z *Numbers: 0-9 *Special characters: !@#$%^&*()_+-=[]{}\/?,.<>; |
| metering.proxyType | string | `"DIRECT"` | The type of the proxy that the metering client uses. Valid values are: *DIRECT (default). *HTTP *SOCKS Indicates that the metering client does not use a proxy. |
| metering.reportPeriod | string | `"3600"` |  |
| metering.runtimeAlias | string | `nil` | An alias of the webMethods product instance or a group of instances, for which usage data is measured. |
| metering.serverConnectTimeout | string | `"60000"` | The time in milliseconds to establish the initial TCP connection when the metering client calls the server REST endpoint. This is also the time to start the request. |
| metering.serverReadTimeout | string | `"300000"` | The maximum time in milliseconds without data transfer over the TCP connection to the server. This is also the time that it takes for the server to respond. When this time passes, the request fails. |
| metering.serverUrl | string | `"https://metering.softwareag.cloud/api/measurements"` | The URL of the metering aggregator server REST API. |
| metering.trustStoreFile | string | `nil` | The absolute path to the metering client truststore that is used for HTTPS connections. Add this value in any of the following cases: *If you use the IBM webMethods Metering Server on premises (via HTTPS) and the certificates in the truststore do not match the certificates configured in IBM webMethods Runtime (CTP). *If you use a metering proxy that terminates the SSL connection to the Metering Server in IBM webMethods.io Cloud. |
| metering.trustStorePassword | string | `nil` | The password for the metering client truststore. Configure this property only if you use a truststore. |
| metering.trustStorePasswordFromSecret | object | `{"enabled":false,"secretKey":"","secretName":""}` | Configuration for secretKeyRef containing the password for the metering client truststore. Configure this property only if you use a truststore. Mutually exclusive with providing the password directly over metering.trustStorePassword. |
| metering.trustStorePasswordFromSecret.enabled | bool | `false` | enable secretKeyRef instead of providing password directly |
| metering.trustStorePasswordFromSecret.secretKey | string | `""` | Key containing the truststore password in the referenced secret |
| metering.trustStorePasswordFromSecret.secretName | string | `""` | Name of the referenced secret |
| nameOverride | string | `""` | Overwrites Chart name of release name in workload name. As default, the workload name is release name + '-' + Chart name. The workload name is at the end release name + '-' + value of `nameOverride`. |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podDisruptionBudget | object | `{"enabled":false}` | Create a PodDisruptionBudget for API Gateway |
| podSecurityContext | object | `{}` |  |
| priorityClassName | string | `""` | Set APIGW and Nginx Pods' Priority Class Name ref: https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/ |
| prometheus | object | `{"fallbackScrapeProtocol":null,"interval":"10s","path":"/metrics","port":"5555","scheme":"http","scrape":"true","scrapeTimeout":"10s"}` | Define values for Prometheus Operator to scrap metrics via annotation or ServiceMonitor. |
| prometheus-elasticsearch-exporter | object | `{"enabled":true,"es":{"uri":"http://$(ES_USER):$(ES_PASSWORD)@{{ printf \"%s\" .Release.Name }}-apigateway-es-http:9200"},"extraEnvSecrets":{"ES_PASSWORD":{"key":"password","secret":"{{ printf \"%s-apigateway-sag-user-es\" .Release.Name }}"},"ES_USER":{"key":"username","secret":"{{ printf \"%s-apigateway-sag-user-es\" .Release.Name }}"}},"podAnnotations":{"prometheus.io/path":"/metrics","prometheus.io/port":"9108","prometheus.io/scheme":"http","prometheus.io/scrape":"true"},"podSecurityContext":{"runAsNonRoot":true,"runAsUser":1000730001},"revisionHistoryLimit":10,"serviceAccount":{"name":""},"serviceMonitor":{"enabled":false}}` | Elasticsearch exporter settings. See https://github.com/prometheus-community/elasticsearch_exporter for details. |
| prometheus-elasticsearch-exporter.enabled | bool | `true` | Deploy the prometheus exporter for elasticsearch |
| prometheus-elasticsearch-exporter.es.uri | string | `"http://$(ES_USER):$(ES_PASSWORD)@{{ printf \"%s\" .Release.Name }}-apigateway-es-http:9200"` | The uri of the elasticsearch service. By default this is null and the environment variable ES_URI is used instead. Overwrite this if you are using an external Elasticsearch instance |
| prometheus-elasticsearch-exporter.extraEnvSecrets | object | `{"ES_PASSWORD":{"key":"password","secret":"{{ printf \"%s-apigateway-sag-user-es\" .Release.Name }}"},"ES_USER":{"key":"username","secret":"{{ printf \"%s-apigateway-sag-user-es\" .Release.Name }}"}}` | secret for elasticsearch user. Will need to adjust the secret's name. By default the secret name is <releasename>-apigateway-sag-user-es. Adjust accordingly if your release name is different. |
| prometheus-elasticsearch-exporter.podSecurityContext.runAsUser | int | `1000730001` | Enter value {1000770001} from UID range of an OpenShift Project. |
| prometheus-elasticsearch-exporter.revisionHistoryLimit | int | `10` | The number of old ReplicaSets to retain to allow rollback. |
| prometheus.fallbackScrapeProtocol | string | `nil` | Setup Prometheus scrape protocol. Set value `PrometheusText0.0.4` here if you are using Prometheus server version 3.x. See [Prometheus configuration](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config). |
| replicaCount | int | `1` |  |
| resources.apigwContainer.limits.cpu | int | `8` |  |
| resources.apigwContainer.limits.memory | string | `"8Gi"` |  |
| resources.apigwContainer.requests.cpu | string | `"500m"` |  |
| resources.apigwContainer.requests.memory | string | `"4Gi"` |  |
| resources.apigwInitContainer.limits.cpu | string | `"200m"` |  |
| resources.apigwInitContainer.limits.memory | string | `"100Mi"` |  |
| resources.apigwInitContainer.requests.cpu | string | `"100m"` |  |
| resources.apigwInitContainer.requests.memory | string | `"50Mi"` |  |
| revisionHistoryLimit | int | `10` | The number of old ReplicaSets to retain to allow rollback. |
| routes | object | `{"admin":{"annotations":null,"enabled":false,"hostName":"","labels":null,"name":"","portName":"adminport"},"ui":{"annotations":null,"enabled":false,"hostName":"","labels":null,"name":"","portName":"uiport"}}` | Routes for admin, ui port for openshift |
| routes.admin | object | `{"annotations":null,"enabled":false,"hostName":"","labels":null,"name":"","portName":"adminport"}` | Route for API Gateway Admin Port |
| routes.ui | object | `{"annotations":null,"enabled":false,"hostName":"","labels":null,"name":"","portName":"uiport"}` | Route for API Gateway UI Port |
| secrets | object | `{"generateAdminSecret":true,"generateElasticSecrets":true}` | Controls if secrets should be generated automatically. |
| securityContext | object | `{}` |  |
| service.port | int | `80` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `true` | - apiVersion: rbac.authorization.k8s.io/v1 kind: Role metadata:   name: {{ include "common.names.roleName" . }} rules: - apiGroups:   - ""   resources:   - pods   - endpoints   verbs:   - get   - list   - watch |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| serviceAccount.roleBindingName | string | `"cluster-discovery-rolebinding"` |  |
| serviceAccount.roleName | string | `""` |  |
| serviceMonitor.enabled | bool | `false` | Create and enable CRD ServiceMonitor. The default is `false`. |
| serviceMonitor.serviceName | string | `""` | Set the monitored service which is connected by ServiceMonitor. Default (if not set) is the `rt` runtime service. |
| skipKibanaAutostartParameter | bool | `false` | Skip Kibana Autostart Parameter for minimal 11.x container images |
| skipLicenseKey | bool | `false` | Skip License Key (for 11.x container images) |
| strategy | object | `{}` | The update strategy to use |
| tolerations | list | `[]` |  |
| topologySpreadConstraints | object | `{}` | Set Pod topology spread constraints for APIGW. You can use templates inside because `tpl` function is called for rendering. |
