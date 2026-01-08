# Terracotta BigMemory Max Helm Chart

## Disclaimer and Warnings

**The user is responsible for customizing these files on-site.**
This Helm chart is provided as a minimal requirement to install Terracotta BigMemory Max on k8s.

---

*Considering the complexity of k8s settings regarding pod and volume lifecycle in the context of a multi-stripe active/passive cluster it is strongly advised that the user consult with a k8s expert.*

*Pay attention that the nature of k8s automatically handling pod restart and volume assignment can go against the expected normal behavior of Terracotta Servers on a traditional infrastructure. This can lead to unexpected behaviors and / or malfunctioning clusters.*

*Terracotta Servers embed a mechanism to automatically restart in case of failure or configuration change, and eventually can invalidate the data on disk (to be wiped). This mechanism is not compatible with the default k8s lifecycle management which can for example respawn a pod on a pre-existing volume where the data has been marked invalidated.*

---

## Compatibility Matrix

| NAME                              | CHART VERSION | APP VERSION |
|:----------------------------------|:-------------:|:-----------:|
| webmethods/terracottabigmemorymax |  `>= 2.0.1`   |   `4.5.0`   |
| webmethods/terracottabigmemorymax |  `<= 1.4.0`   |   `4.4.0`   |

## QuickStart

From the helm directory

```bash
helm install <release-name> --set-file terracotta.license=<license-file> --set tag=4.3.10-SNAPSHOT .
```

**IMPORTANT note:** license and tag are mandatory parameter that need to be set during helm chart installation.

There are other parameters defined in values.yaml which can be overridden as well during installation which can be used
for changing how terracotta cluster should be deployed in kubernetes environment. By default it deploys BigMemory
cluster with two stripe each having two nodes and a tmc inside kubernetes.

### Security

### Image Pull Secret

Provide an image pull secret for the registry where the desired images  are to be pulled from.

```
kubectl create secret docker-registry regcred --docker-server=<your-registry-server> --docker-username=<your-name> --docker-password=<your-pwd> --docker-email=<your-email>
```

### STEP #1: Create a secret

Suppose you are creating a 2*1 bigmemory cluster and 1 tmc then Create a secret which contains following files

- terracotta-0-keystore.jks :- keystore file for server1.
- terracotta-1-keystore.jks :- keystore file for server2.
- tmc-0-keystore.jks :- keystore file for tmc.
- truststore.jks :- truststore file containing public certs for all the above keystores.
- keychain - keychain file containing password for everything. For ex-

````
Terracotta Command Line Tools - Keychain Client
tc://user@terracotta-1.terracotta-service.default.svc.cluster.local:9540 : chunuAa1$
file:/opt/terracotta/.tc/mgmt/truststore.jks : chunuAa1$
file:/opt/terracotta/run/truststore.jks : chunuAa1$
tc://user@terracotta-1.terracotta-service.default.svc.cluster.local:9510 : chunuAa1$
tc://user@terracotta-1.terracotta-service.default.svc.cluster.local:9530 : chunuAa1$
file:/opt/terracotta/.tc/mgmt/tmc-0-keystore.jks : chunuAa1$
https://terracotta-1.terracotta-service.default.svc.cluster.local:9540/tc-management-api : chunuAa1$
https://terracotta-0.terracotta-service.default.svc.cluster.local:9540/tc-management-api : chunuAa1$
tc://user@terracotta-0.terracotta-service.default.svc.cluster.local:9510 : chunuAa1$
jks:terracotta-0-alias@/opt/terracotta/run/terracotta-0-keystore.jks : chunuAa1$
tc://user@terracotta-0.terracotta-service.default.svc.cluster.local:9540 : chunuAa1$
tc://user@terracotta-0.terracotta-service.default.svc.cluster.local:9530 : chunuAa1$
jks:terracotta-1-alias@/opt/terracotta/run/terracotta-1-keystore.jks : chunuAa1$
````

- tmc-https.ini :- For enabling ssl connections in jetty. For ex-

````
jetty.sslContext.keyManagerPassword=OBF:1fwe1jg61vgz1nsc1zen1npu1vfv1jd41fsw
jetty.sslContext.keyStorePassword=OBF:1fwe1jg61vgz1nsc1zen1npu1vfv1jd41fsw
jetty.sslContext.trustStorePassword=OBF:1fwe1jg61vgz1nsc1zen1npu1vfv1jd41fsw
````

- terracotta.ini :- contains user with name 'user' as we are using it in generated tc-config.xml.

````
./usermanagement.sh -c terracotta.ini user terracotta admin
````

Example to create secret in k8s cluster manually -

````
kubectl create secret generic certificatesecret \
--from-file=/home/mdh@eur.ad.sag/4.xconfig/k8sCert/keychain \
--from-file=/home/mdh@eur.ad.sag/4.xconfig/k8sCert/terracotta-0-keystore.jks \
--from-file=/home/mdh@eur.ad.sag/4.xconfig/k8sCert/truststore.jks \
--from-file=/home/mdh@eur.ad.sag/4.xconfig/k8sCert/terracotta.ini \
--from-file=/home/mdh@eur.ad.sag/4.xconfig/k8sCert/tmc-0-keystore.jks \
--from-file=/home/mdh@eur.ad.sag/4.xconfig/k8sCert/tmc-https.ini \
--from-file=/home/mdh@eur.ad.sag/4.xconfig/k8sCert/terracotta-1-keystore.jks
````

### Step #2: Install the helm chart and use the above created secret.

````
helm install "my-release" --set terracotta.stripeCount=2 --set terracotta.nodeCountPerStripe=1 --set-file terracotta.license=/home/mdh@eur.ad.sag/4.xlicense/license.key --set tag=4.3.10-SNAPSHOT --set security=true --set secretName=certificatesecret  .
````

### Step #3: Verify from the browser to see if connections can be created securely to tmc.

- First enable port-forwarding for tmc-service using -

````
kubectl port-forward service/tmc-service 8080:9443
````

- Go to browser and go to url https://localhost:8080 and then set up authentication.
- It will ask for tmc restart so do it using

```
kubectl delete pod tmc-0.
```

- Now again start port-forwarding and go to browser and provide the connection location (URL)  -

```
https://terracotta-0.terracotta-service.default.svc.cluster.local:9540
```

- When asking for username enter "user" . It should be able to connect and show cluster information on browser.

### Prometheus support
Terracotta BigMemory provides a list of key metrics in Prometheus compatible format over HTTP on TMC endpoint:
```
http(s)://<host>:<port>/tmc/api/prometheus
```
Sample config to add BigMemory as a target in the prometheus.yml configuration file

For non secure cluster -
```
- job_name: 'big_memory'
    metrics_path: /tmc/api/prometheus
    static_configs:
        - targets: ['localhost:9889']
```

For secure cluster -
```
- job_name: 'big_memory'
    scheme: https
    metrics_path: /tmc/api/prometheus
    static_configs:
    - targets: ['localhost:9443']
    basic_auth:
      username: <username>
      password: <password>
    tls_config:
      ca_file: <path-to-tmc-certificate>
```

### Step #4: For removing deployment from kubernetes cluster.

```bash
helm delete <release-name>
```

## Version History

| Version | Changes and Description |
|---------|-------------------------|
| `1.0.0' | Initial release         |
| `1.1.0' | Available from GitHub   |
| `1.2.0' | Adapted to webMethods Helm charts   |
| `1.2.1' | Set `terracotta.stripeCount` to 1 by default and added `terracotta.tmcEnabled`   |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| extraEnvs | list | `[]` | Exta environment properties to be passed on to the terracotta runtime  - name: extraEnvironmentVariable    value: "myvalue" |
| extraLabels | object | `{}` | Extra Labels |
| imagePullSecrets | list | `[{"name":"regcred"}]` | Image pull secret reference. By default looks for `regcred`. |
| prometheus | object | `{"interval":"10s","path":"/tmc/api/prometheus","scrapeTimeout":"10s"}` | Define values for Prometheus Operator to scrap metrics via ServiceMonitor. |
| pullPolicy | string | `"IfNotPresent"` |  |
| registry | string | `"sagcr.azurecr.io"` | The repository for the image. By default, this points to the IBM webMethodscontainer repository. Change this for air-gaped installations or custom images. For the IBM webMethods container repository you need to have a valid access token stored as registry credentials |
| resources | object | `{}` | We usually recommend not to specify default resources and to leave this as a conscious choice for the user. This also increases chances charts run on environments with little resources, such as Minikube. If you do want to specify resources, uncomment the following lines, adjust them as necessary, and remove the curly braces after 'resources:'.  tsaContainer:   limits:     cpu: 100m     memory: 128Mi   requests:     cpu: 100m     memory: 128Mi tmcContainer:   requests:     cpu: 500m     memory: 2Gi   limits:     # use a high cpu limit to avoid the container being throttled     cpu: 8     memory: 4Gi |
| securityContext.fsGroup | int | `0` |  |
| securityContext.runAsGroup | int | `0` |  |
| securityContext.runAsNonRoot | bool | `true` |  |
| securityContext.runAsUser | int | `1724` |  |
| serverImage | string | `"bigmemorymax-server"` |  |
| serverStorage | string | `"10Gi"` | The pvc storage request for the server pods |
| serviceMonitor | object | `{"enabled":false}` | Create and enable ServiceMonitor. The default is `false`. |
| tag | string | `"4.4.0"` | Specific version to not accidentally change production versions with newer images. |
| terracotta | object | `{"datastoreSize":"4G","jsonLogging":true,"license":"","nodeCountPerStripe":2,"offHeapSize":"2G","restartable":false,"secretName":"","security":false,"selfSignedCerts":true,"serverOpts":"","serviceAccountName":"","stripeCount":1,"tmcEnabled":true,"tmcManagementPort":9889,"tmcOpts":"","tmcSecurePort":9443,"tsaGroupPort":9530,"tsaManagementPort":9540,"tsaPort":9510}` | Terracotta BigMemoryMax configurations |
| terracotta.datastoreSize | string | `"4G"` | The <datastoreSize> configuration for each Terracotta server. |
| terracotta.jsonLogging | bool | `true` | The JSON_LOGGING environment variable for each Terracotta server. |
| terracotta.license | string | `""` | The license content for the Terracotta cluster. Optional. |
| terracotta.nodeCountPerStripe | int | `2` | The number of Terracotta servers per stripe. |
| terracotta.offHeapSize | string | `"2G"` | The <offheap> configuration for each Terracotta server. |
| terracotta.restartable | bool | `false` | The <restartable> configuration for each Terracotta server. |
| terracotta.secretName | string | `""` | Create a secret manually in cluster which contains all the necessary certs, files etc. for all the servers as well as tmc as the same secret will be mounted to all the pods deployed via this helm chart. |
| terracotta.security | bool | `false` | Add the <security> configuration for each Terracotta server. Requires secretName to be set. |
| terracotta.selfSignedCerts | bool | `true` | Configure JAVA_OPTS appropriately when using self-signed certificates. |
| terracotta.serverOpts | string | `""` | Can be used for passing some jvm related options for terracotta servers. |
| terracotta.serviceAccountName | string | `""` | ServiceAccountName for the terracotta related pods |
| terracotta.stripeCount | int | `1` | The number of Terracotta stripes to deploy. |
| terracotta.tmcEnabled | bool | `true` | TMC Enabled or not |
| terracotta.tmcManagementPort | int | `9889` | TMC Management Port |
| terracotta.tmcOpts | string | `""` | Can be used for passing some jvm related options for tmc. |
| terracotta.tmcSecurePort | int | `9443` | TMC Secure Port |
| terracotta.tsaGroupPort | int | `9530` | TSA group port |
| terracotta.tsaManagementPort | int | `9540` | TSA Management port |
| terracotta.tsaPort | int | `9510` | TSA port |
| tmcImage | string | `"bigmemorymax-management-server"` |  |
| tmcServer | object | `{"livenessProbe":{"failureThreshold":3,"initialDelaySeconds":20,"periodSeconds":30,"successThreshold":1,"tcpSocket":{"port":9889},"timeoutSeconds":5},"readinessProbe":{"failureThreshold":3,"initialDelaySeconds":20,"periodSeconds":30,"successThreshold":1,"tcpSocket":{"port":9889},"timeoutSeconds":5},"startupProbe":{"failureThreshold":3,"initialDelaySeconds":10,"periodSeconds":30,"successThreshold":1,"tcpSocket":{"port":9889},"timeoutSeconds":5}}` | TMC-specific configurations for probes |
| tmcServer.livenessProbe | object | `{"failureThreshold":3,"initialDelaySeconds":20,"periodSeconds":30,"successThreshold":1,"tcpSocket":{"port":9889},"timeoutSeconds":5}` | Configure liveness probe |
| tmcServer.readinessProbe | object | `{"failureThreshold":3,"initialDelaySeconds":20,"periodSeconds":30,"successThreshold":1,"tcpSocket":{"port":9889},"timeoutSeconds":5}` | Configure readiness probe |
| tmcServer.startupProbe | object | `{"failureThreshold":3,"initialDelaySeconds":10,"periodSeconds":30,"successThreshold":1,"tcpSocket":{"port":9889},"timeoutSeconds":5}` | Configure startup probe |
| tmcStorage | string | `"1Gi"` | The pvc storage request for the tmc pods |
| tsaServer | object | `{"livenessProbe":{"failureThreshold":3,"initialDelaySeconds":30,"periodSeconds":30,"successThreshold":1,"tcpSocket":{"port":9530},"timeoutSeconds":5},"readinessProbe":{"failureThreshold":3,"initialDelaySeconds":30,"periodSeconds":30,"successThreshold":1,"tcpSocket":{"port":9530},"timeoutSeconds":5},"startupProbe":{"failureThreshold":3,"initialDelaySeconds":10,"periodSeconds":5,"successThreshold":1,"tcpSocket":{"port":9530},"timeoutSeconds":5}}` | TSA container-specific configurations for probes |
| tsaServer.livenessProbe | object | `{"failureThreshold":3,"initialDelaySeconds":30,"periodSeconds":30,"successThreshold":1,"tcpSocket":{"port":9530},"timeoutSeconds":5}` | Configure liveness probe |
| tsaServer.readinessProbe | object | `{"failureThreshold":3,"initialDelaySeconds":30,"periodSeconds":30,"successThreshold":1,"tcpSocket":{"port":9530},"timeoutSeconds":5}` | Configure readiness probe |
| tsaServer.startupProbe | object | `{"failureThreshold":3,"initialDelaySeconds":10,"periodSeconds":5,"successThreshold":1,"tcpSocket":{"port":9530},"timeoutSeconds":5}` | Configure startup probe |
