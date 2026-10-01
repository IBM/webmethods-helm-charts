# webMethods MyWebMethods Server Helm Chart

This Helm Chart installs and configures a MyWebMethods Server (MWS) container. It is starting with a simple example and provides more complex scenarios in the *Examples for Use-cases* section.

## Prerequisites

### Create Image for MyWebMethods Server

IBM webMethods does not offer currently ready-made container images for MyWebMethods Server. Therefore you will need to create an image on your own. You can follow the instructions
from the build directory of this repository here: [building My webMethods Server Image](../examples/image-builder/README.md).

## Examples for Use-cases

Sub-folder `examples` contains some *values* examples for more use-cases. To use the use-case, adapt and add the provided `values.yaml` to your values.

| Use-case | Description |
|-----|------|
| [mws-postgresql](../examples/postgresql/README.md) | Using MWS with external PostgreSQL database |
| [service-auditing-monitor](../examples/service-auditing-monitor/README.md) | Using MWS as Service Auditing Monitor |

## Install MyWebMethods Server Release

Install release with pulling image and setting secret (to pull image) ...

```shell
helm install wm-mws mywebmethodsserver
```

... define default domain name of Ingress service host ...

```shell
  --set "ingress.defaultHost="
```

... define hostname of Ingress service ...

```shell 
  --set "ingress.hosts[0].paths[0].path=/"            \
  --set "ingress.hosts[0].paths[0].pathType=Prefix"   \
  --set "ingress.hosts[0].paths[0].port=5555"
```

## Version History

| Version | Changes and Description |
|-----|------|
| `1.0.0` | Initial release |
| `1.0.1` | CRD `ServiceMonitor` added |
| `1.0.2` | `storage.enabled` added in `values.yaml`. For backward reason is this value set to `true` as default. `false` doesn't create and mount any PV. (You can test this feature if you don't want to deploy any own MWS application. MWS is more stateless and has only the database as stateful dependency.) |
| `1.0.2` | `containerName` added in `values.yaml`. Default is the Chart name. (Use `helm repo update` to get latest Helm Chart version.) |
| `1.0.3` | `tpl` function support in `affinity` value added. `topologySpreadConstraints` support added. |
| `1.0.4` | `priorityClassName` support added. Implementation of `extraConfigMaps`, `extraVolumeMounts` and `extraVolumes` added. |
| `1.1.0` | Fix and implements `extraEnvs` how other Charts. Supports 64base encoded as binary data for ConfigMaps. Implements `revisionHistoryLimit`. |
| `1.2.0` | Custom Resource objects are supported. Enhancement in job template to add `extraSpec` options. |
| `1.3.0` | `tpl` function support added on `podAnnotation` option. |
| `1.3.1` | Fix leading newline in `extraConfigMaps` values: replaced `nindent` with `indent` in `configmaps-extra.yaml` to prevent XML and other strict parsers from failing on a leading blank line. |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Set Pod (anti-) affinity. You can use templates inside because `tpl` function is called for rendering. |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| containerName | string | `nil` | The name of the main container, by default this will be Chart name. |
| extraConfigMaps | list | `[]` | Extra config maps for addtional configurations such as extra ports, etc. |
| extraContainers | string | `nil` | Extra containers which should run in addtion to the main container as a sidecar - name: do-something   image: busybox   command: ['do', 'something'] |
| extraEnvs | object | `{}` | Exta environment properties to be passed on to the My webMethods Server  - name: extraEnvironmentVariable    value: "myvalue" |
| extraInitContainers | list | `[]` | Extra init containers that are executed before starting the main container - name: do-something   image: busybox   command: ['do', 'something'] |
| extraLabels | object | `{}` | Extra Labels |
| extraVolumeClaimTemplates | list | `[]` | Extra volume claim template to be passed on to the My webMethods Server |
| extraVolumeMounts | list | `[]` | Extra volume mounts - name: extras   mountPath: /usr/share/extras   readOnly: true |
| extraVolumes | list | `[]` | Exta volumes that should be mounted. Example:    - metadata:        name: shared-volume      spec:        accessModes: ["ReadWriteMany"]        storageClassName: nfs        resources:          requests:            storage: 10 |
| fullnameOverride | string | `""` | Overwrites full workload name. As default, the workload name is release name + '-' + Chart name. |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"mywebmethodsserver"` | The image name / location of the custom MyWebmethodsRepository |
| image.tag | string | `""` |  |
| imagePullSecrets | list | `[{"name":"regcred"}]` | Image pull secret reference. By default looks for `regcred`. |
| ingress | object | `{"annotations":{},"className":"","defaultHostname":"msr.mydomain.com","enabled":true,"hosts":[{"host":"","paths":[{"path":"/","pathType":"Prefix","port":8585}]}],"tls":[]}` | Ingress Settings |
| ingress.enabled | bool | `true` | Enables deployment of an ingress |
| ingress.hosts[0] | object | `{"host":"","paths":[{"path":"/","pathType":"Prefix","port":8585}]}` | Hostname of Ingress. By default the defaultHostname is used. For more complex rules or addtional hosts, you will need to overwrite this section. |
| ingress.hosts[0].paths | list | `[{"path":"/","pathType":"Prefix","port":8585}]` | Address the backend |
| ingress.hosts[0].paths[0] | object | `{"path":"/","pathType":"Prefix","port":8585}` | Path to address the backend |
| ingress.hosts[0].paths[0].pathType | string | `"Prefix"` | Path type to address the backend |
| ingress.hosts[0].paths[0].port | int | `8585` | Port of service |
| ingress.tls | list | `[]` | TLS of Ingress |
| lifecycle | object | `{}` | lifecycle hooks to execute on preStop / postStart,... preStop:   exec:     command: ["/bin/sh", "-c", "echo Hello from the preStop handler > /usr/share/message"] postStart:   exec:     command: ["/bin/sh", "-c", "echo Hello from the postStart handler > /usr/share/message"] |
| mws | object | `{"jdbc":{"dbURL":"jdbc:wm:postgresql://mws-db-postgresql:5432;databaseName=wmdb","password":null,"type":"postgresql","user":null},"secretName":null}` | MyWebMethods Server specific configurations |
| mws.jdbc.dbURL | string | `"jdbc:wm:postgresql://mws-db-postgresql:5432;databaseName=wmdb"` | Database connection URL, based on the type of database and the driver. |
| mws.jdbc.password | string | `nil` | The password of the My webMethods Server database user. If user and password are provided a secret will automatically generated initially. E.g. helm install webmethods/mywebmethodsserver mws --set mws.jdbc.user=mwsuser --set mws.jdbc.password=mydbpassword Do not save this information in a plain value file, use --set and reference it from an environment variable, or setup manually |
| mws.jdbc.type | string | `"postgresql"` | The type of database used by the server instance. Valid values are: *ms - Microsoft SQL Server *oracle - Oracle *db2 - DB2 *mysqlee - MySQL Enterprise Edition *mysqlce - MySQL Community Edition *postgresql - PostgreSQL |
| mws.jdbc.user | string | `nil` | The user name to use when connecting to the My webMethods Server database. If user and password are provided a secret will automatically generated initially.  E.g. helm install webmethods/mywebmethodsserver mws --set mws.jdbc.user=mwsuser --set mws.jdbc.password=mydbpassword Do not save this information in a plain value file, use --set and reference it from an environment variable, or setup manually |
| mws.secretName | string | `nil` | The secret name containing user and password for the JDBC connection By default the secret name contains of the full name + "-mws-secret".  Provide a value if you setup a secret manually. Example: `kubectl create secret generic mws-secret --from-literal=user=mwsuser --from-literal=password=mypassword` and use `secretName: mws-secret` in your values file |
| nameOverride | string | `""` | Overwrites Chart name of release name in workload name. As default, the workload name is release name + '-' + Chart name. The workload name is at the end release name + '-' + value of `nameOverride`. |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| priorityClassName | string | `""` | Set Pods' Priority Class Name ref: https://kubernetes.io/docs/concepts/configuration/pod-priority-preemption/ |
| prometheus | object | `{"interval":"10s","path":"/metrics","port":"8585","scheme":"http","scrape":"true","scrapeTimeout":"10s"}` | Define values for Prometheus Operator to scrap metrics via annotation or ServiceMonitor. |
| replicaCount | int | `1` |  |
| resources | object | `{}` | Define CPU and memory resources for container |
| revisionHistoryLimit | int | `10` | The number of old ReplicaSets to retain to allow rollback. |
| securityContext | object | `{}` | The security context the pods should run in. capabilities:   drop:   - ALL readOnlyRootFilesystem: true runAsNonRoot: true runAsUser: 1000 |
| service | object | `{"port":8585,"type":"ClusterIP"}` | The service type of the MyWebMethodsServer service |
| serviceAccount.create | bool | `false` |  |
| serviceMonitor | object | `{"enabled":false}` | Create and enable ServiceMonitor. The default is `false`. |
| storage.defaultAccessMode | list | `["ReadWriteOnce"]` | The default access mode |
| storage.defaultStorageClass | string | `nil` | The default storage class for all application directories |
| storage.defaultStorageRequest | string | `"1Gi"` | Storage claim request size |
| storage.defaultVolume | string | `"data"` | The default volume name. |
| storage.dirs.appsdir | object | `{"accessMode":[],"path":"/opt/softwareag/MWS/volumes/apps","storageClass":null,"storageRequest":null,"volume":null}` | A directory on the container file system which contains the custom assets and applications to copy to the MWS/deploy directory of the My webMethods Server instance, and installed on container startup. If not specified, My webMethods Server uses the default SAGHOME/MWS/volumes/apps directory in the container. Assets and applications are sourced through a bind-mounted host directory, or an external volume, mounted to the apps directory location in the container. Valid asset formats are war, cdp, pdp, jar. For more information about deploying applications to a My webMethods Server Docker container, see Custom Applications in My webMethods Server Containers. |
| storage.dirs.appsdir.volume | string | `nil` | when set to true, a separate volume will be created for this directory. Otherwise, the directory will be created on the defaultVolume. |
| storage.dirs.configsdir | object | `{"accessMode":[],"path":"/opt/softwareag/MWS/volumes/configs","storageClass":null,"storageRequest":null,"volume":null}` | A directory on the container file system which contains miscellaneous configuration files that My webMethods Server loads on container startup. If not specified, the container startup script for My webMethods Server uses the default SAGHOME/MWS/volumes/configs and checks for a configs directory on the volume, mounted to the SAGHOME/MWS/volumes/configs directory on the container file system if such volume is available. The configs directory on the mounted volume can contain one or more of the following subdirectories: *assets_cfg - for supplying xmlImport files and My webMethods Server skins. *cluster_cfg - stores custom configuration files for the My webMethods Server cluster, for example the cluster.xml file. *instance_cfg - stores custom configuration files for the My webMethods Server instance, for example the mws.db.xml and server.properties files. *jvm_cfg - for supplying custom JVM configuration files and certificates. *profile_cfg - stores custom configuration files for the My webMethods Server OSGi profile, for example the custom_wrapper.conf file. For more information about modifying the configuration of a My webMethods Server Docker container through an external volume, see Modifying the Configuration of a Container |
| storage.dirs.configsdir.volume | string | `nil` | when set to true, a separate volume will be created for this directory. Otherwise, the directory will be created on the defaultVolume. |
| storage.dirs.datadir | object | `{"accessMode":[],"path":"/opt/softwareag/MWS/volumes/data","storageClass":null,"storageRequest":null,"volume":null}` | Directory on the container file system to which My webMethods Server stores runtime data, such as search indexes and information about the deployed applications, and persists events from the Task Engine event queue. If not specified, My webMethods Server uses the default SAGHOME/MWS/volumes/data directory on the container file system. |
| storage.dirs.datadir.volume | string | `nil` | when set to true, a separate volume will be created for this directory. Otherwise, the directory will be created on the defaultVolume. |
| storage.dirs.libsdir | object | `{"accessMode":[],"path":"/opt/softwareag/MWS/volumes/libs","storageClass":null,"storageRequest":null,"volume":null}` | Directory on the container file system that holds third-party libraries or other custom jar files to be copied to the MWS/lib directory of the My webMethods Server instance and loaded by My webMethods Server on container startup. If not specified, the container startup script for My webMethods Server uses the default directory SAGHOME/MWS/volumes/libs on the container file system. Libraries and jars are sourced through a bind-mounted host directory or an external volume. For more information about using third-party libraries and custom jars in a My webMethods Server Docker container, see Using External Libraries in My webMethods Server Containers.       |
| storage.dirs.libsdir.volume | string | `nil` | when set to true, a separate volume will be created for this directory. Otherwise, the directory will be created on the defaultVolume. |
| storage.dirs.logsdir | object | `{"accessMode":[],"path":"/opt/softwareag/MWS/volumes/logs","storageClass":null,"storageRequest":null,"volume":null}` | Directory on the container file system to which My webMethods Server persists all log files, generated by the My webMethods Server instance. By default, the directory contains the following subdirectories: *instance_logs - corresponds to the default SAGDir/MWS/server/instanceName/logs directory of an on-premise My webMethods Server installation. *profile_logs - corresponds to the SAGDir/profiles/MWS_default/logs directory of an on-premise My webMethods Server installation. *cli_logs - for all logs, stored in the SAGDir/MWS/bin directory of an on-premise installation. Logs for OSGi profile-related operations that My webMethods Server executes during operation, for example, when adding external libraries, are stored in cli_logs/archive. If not specified, My webMethods Server uses the default directory SAGHOME/MWS/volumes/logs on the container file system.     |
| storage.dirs.logsdir.volume | string | `nil` | when set to true, a separate volume will be created for this directory. Otherwise, the directory will be created on the defaultVolume. |
| storage.enabled | bool | `true` | Enable or disable persistent storage handling. `true`creates (PVCs) and mounts all volumes. `false` doesn't create any PVC. |
| tolerations | list | `[]` |  |
| topologySpreadConstraints | object | `{}` | Set Pod topology spread constraints. You can use templates inside because `tpl` function is called for rendering.  |
