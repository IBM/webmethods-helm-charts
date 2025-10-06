# webMethods Universal Messaging Helm Chart

This Helm Chart installs and configures a Universal Messaging (UM) container.

## Prerequisites

### Image Pull Secret

If you want to pull image from IBM webMethods Containers Registry, create secret with your IBM webMethods Containers Registry credentials ...

```
kubectl create secret docker-registry regcred --docker-server=sagcr.azurecr.io --docker-username=<your-name> --docker-password=<your-pwd> --docker-email=<your-email>
```

### Licenses

Universal Messaging requires a license file. These license is supposed to be provided as configmap.

Hence before running `helm install` create the configmap:

```
kubectl create configmap universalmessaging-license-key --from-file=licensekey=<your path and filename to Universal Messaging license file>
```

Optionally you can also provide the license directly when installing your release (see also below).

## Examples for Use-cases

Sub-folder `examples` contains some *values* examples for more use-cases. To use the use-case, adapt and add the provided `values.yaml` to your values.

| Use-case | Description |
|-----|------|
| [post-init](../examples/post-init/README.md) | Post-initialize UM server deployment |

## Install Universal Messaging Release

Install release

```shell
helm install um webmethods/universalmessaging
```

... (optionally) provide the license key at installation time (can be ommitted for upgrade later) ...

```shell
--set-file=license=<your path and filename to Universal Messaging license file> \
```

... set your own image pull secret if you didn't create the default `regcred` ...

```shell
--set "imagePullSecrets[0].name=your-registry-credentials" \
```

## Version History

| Version | Changes and Description |
|-----|------|
| `1.0.0` | Initial release |
| `1.0.1` | Update JMX Exporter configuration file from latest [UM Git repository](https://github.com/SoftwareAG/universalmessaging-prometheus-jmx-exporter-config). Bugfix: Mount configuration files into container. Nginx added. |
| `1.0.2` | Change startup, liveness and readiness probes. All configuration settings are in `values.yaml`. Now, The probes are using `httpGet` instead of `runUMTool.sh` utility. |
| `1.0.3` | Make license file handling same as MSR |
| `1.0.4` | CRD `ServiceMonitor` added |
| `1.0.4` | `containerName` added in `values.yaml`. Default is the Chart name. (Use `helm repo update` to get latest Helm Chart version.) |
| `1.0.5` | support of PV storage annotation and class name |
| `1.0.6` | `tpl` function support in `affinity` value added. `topologySpreadConstraints` support added. |
| `1.0.7` | `priorityClassName` support added. |
| `1.0.8` | Setting of environment variable in Job template fixed. |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Set Pod (anti-) affinity. You can use templates inside because `tpl` function is called for rendering. |
| containerName | string | `nil` | The name of the main container, by default this will be Chart name. |
| customMetricExporterConfig | object | `{"content":""}` | Custom metric JMX exporter configuration. Overwriting the default content of file [jmx_exporter.yaml](./files/jmx_exporter.yaml). See [Prometheus JMX exporter configuration](https://github.com/SoftwareAG/universalmessaging-prometheus-jmx-exporter-config) for more configuration samples. |
| customServerConfig | object | `{"content":""}` | Custom server configuration file. Overwriting the content of file `Custom_Server_Common.conf` in container.  |
| externalLoadBalancer | bool | `false` | Deploy Nginx as external LB. The LB will be configured to dispatch incoming requests to all `replicaCount` replicas. Nginx is configured by example from [Universal Messaging documentation](https://documentation.softwareag.com/universal_messaging/num10-15/webhelp/num-webhelp/#page/num-webhelp%2Fre-configure_nginx_to_serve_http_requests.html%23) |
| extraConfigMaps | list | `[]` | Extra config maps for additional configurations such as extra ports, etc. |
| extraContainers | list | `[]` | Extra containers which should run in addition to the main container as a sidecar |
| extraEnvs | object | `{}` | Exta environment properties to be passed on to the container |
| extraInitContainers | list | `[]` | Extra init containers that are executed before starting the main container |
| extraLabels | object | `{}` | Extra Labels |
| extraVolumeMounts | list | `[]` | Extra volume mounts |
| extraVolumes | list | `[]` | Exta volumes that should be mounted. |
| fullnameOverride | string | `""` | Overwrites full workload name. As default, the workload name is release name + '-' + Chart name. |
| image | object | `{"pullPolicy":"Always","repository":"sagcr.azurecr.io/universalmessaging-server","tag":"10.15"}` | Run this image |
| image.pullPolicy | string | `"Always"` | Pull with policy |
| image.repository | string | `"sagcr.azurecr.io/universalmessaging-server"` | Pull this image. Default is UM from [IBM webMethods Container Registry](https://containers.webmethods.io) |
| image.tag | string | `"10.15"` | The default value pulls latest. In PROD it is recommended to use a specific fix level. |
| imagePullSecrets | list | `[{"name":"regcred"}]` | Image pull secret reference. By default looks for `regcred`. |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.defaultHostname | string | `"um.mydomain.com"` |  |
| ingress.enabled | bool | `false` | Enable or disable Ingress, default is disabled. On enabling Ingress, only the first `-0` replica is currently supported.  |
| ingress.hosts[0] | object | `{"host":"","paths":[{"path":"/","pathType":"Prefix","port":9000}]}` | Hostname of Ingress. By default the defaultHostname is used. For more complex rules or addtional hosts, you will need to overwrite this section. |
| ingress.hosts[0].paths | list | `[{"path":"/","pathType":"Prefix","port":9000}]` | Address the backend |
| ingress.hosts[0].paths[0] | object | `{"path":"/","pathType":"Prefix","port":9000}` | Path to address the backend |
| ingress.hosts[0].paths[0].pathType | string | `"Prefix"` | Path type to address the backend |
| ingress.hosts[0].paths[0].port | int | `9000` | Port of service |
| ingress.tls | list | `[]` | TLS of Ingress |
| license | string | `""` | Import the content as license key and create a ConfigMap named by `licenseConfigMap` value. You can copy/past the content of your provided license key file here.   |
| licenseConfigMap | string | `"universalmessaging-license-key"` | Name of the licence config map |
| lifecycle | object | `{}` | lifecycle hooks to execute on preStop / postStart,... |
| livenessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/health/","port":9000},"initialDelaySeconds":0,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":30}` | Configure liveness probe |
| nameOverride | string | `""` | Overwrites Chart name of release name in workload name. As default, the workload name is release name + '-' + Chart name. The workload name is at the end release name + '-' + value of `nameOverride`. |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` | pod annotations |
| podSecurityContext.fsGroup | int | `1724` |  |
| priorityClassName | string | `""` | Set UM and Nginx Pods' Priority Class Name ref: https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/ |
| prometheus | object | `{"interval":"10s","path":"/metrics","port":"9200","scheme":"http","scrape":"true","scrapeTimeout":"10s"}` | Define values for Prometheus Operator to scrap metrics via annotation or ServiceMonitor. |
| readinessProbe | object | `{"failureThreshold":3,"httpGet":{"path":"/health/","port":9000},"initialDelaySeconds":0,"periodSeconds":15,"successThreshold":1,"timeoutSeconds":30}` | Configure readiness probe |
| replicaCount | int | `1` | Number of replicas |
| resources | object | `{}` | Define CPU und memory resources UM and Nginx containers. |
| securityContext | object | `{}` |  |
| service.metricPort | int | `9200` | Metrics port |
| service.port | int | `9000` | Universal Messaging default port |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.create | bool | `false` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |
| serviceMonitor | object | `{"enabled":false}` | Create and enable ServiceMonitor. The default is `false`. |
| startupProbe | object | `{"failureThreshold":30,"httpGet":{"path":"/health/","port":9000},"initialDelaySeconds":30,"periodSeconds":10,"successThreshold":1,"timeoutSeconds":5}` | Configure liveness probe |
| storage.configuration.annotations | object | `{}` | Annotation for data |
| storage.configuration.storageClassName | string | `""` | Storage class name for data |
| storage.configurationSize | string | `"2Mi"` | Storage size of configuration files |
| storage.data.annotations | object | `{}` | Annotation for data |
| storage.data.storageClassName | string | `""` | Storage class name for data |
| storage.dataSize | string | `"2Gi"` | Storage size of data |
| storage.logs.annotations | object | `{}` | Annotation for logs |
| storage.logs.storageClassName | string | `""` | Storage class name for logs |
| storage.logsSize | string | `"2Gi"` | Storage size of logs |
| tolerations | list | `[]` |  |
| topologySpreadConstraints | object | `{}` | Set Pod topology spread constraints. You can use templates inside because `tpl` function is called for rendering.  |
| um.basicAuthEnable | string | `"No"` | Enable basic authentication on the server |
| um.basicAuthMandatory | string | `"No"` | Enable and mandate basic authentication on the server |
| um.initJavaMemSize | string | `"1024"` | Initial Java Heap Size (in MB) |
| um.logFramework | string | `""` | Enable log4j2 as logging framework by specifying this environment variable with log4j2 as value. By default fLogger (UM Native) logging framework enabled. |
| um.maxDirectMemSize | string | `"1G"` | Maximum Direct Memory Size (in GB) |
| um.maxJavaMemSize | string | `"1024"` | Maximum Java Heap Size (in MB) |
| um.realmName | string | `""` | Name of the Universal Messaging realm |
| um.startupCommand | string | `""` | Startup command to be executed after UM was started. This can be used to enable / disable configurations or ensure that specific channels are created Example: runUMTool.sh EditRealmConfiguration -rname=nsp://localhost:9000 -JVM_Management.EnableJMX=false Next sample is to create JMS Connection Factory: runUMTool.sh CreateConnectionFactory -rname=nsp://localhost:9000 -factoryname=local_um -factorytype=default -connectionurl=nsp://{{ include \"common.names.fullname\" . }}:9000 -durabletype=S |
