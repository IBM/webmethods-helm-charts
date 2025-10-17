# Deploying API Control Plane

We have two ways of deploying a self-hosted version of API Control Plane - using Docker Compose and using Helm.

For deployment instructions using Docker Compose, go [here](../examples/docker/README.md).

## API Control Plane Deployment with Helm

The instructions for installing and running the API Control Plane on Kubernetes using Helm are below.

The standard deployment of API Control plane contains the following 5 microservices.
![img.png](../docs/diagrams/apicp_logical_architecture.png)

1. Asset catalog - Assets(Runtimes,Data planes) processing of Control plane.
2. Engine - Metrics processing and aggregation.
3. Ingress - User management and security
4. API Control Plane UI - user interface
5. Opensearch - data persistence layer

***

Table of contents

1. [Prerequisite](#Prerequisite)
2. [How to deploy IBM webMethods API Control Plane using Helm?](#how-to-deploy-webmethods-api-control-plane-using-helm)
3. [How to stop IBM webMethods API Control Plane using Helm?](#how-to-stop-webmethods-api-control-plane-using-helm)
4. [How to access the newly deployed IBM webMethods API Control Plane?](#how-to-access-the-newly-deployed-webmethods-api-control-plane)
5. [Additional deployment flavors](#additional-deployment-flavors)

***
## Prerequisite
The machine needs following to install the control plane through Helm.
1. Kubernetes
2. Helm

***

## How to deploy IBM webMethods API Control Plane using Helm?
> **Note:** This release includes container images built only for the `amd64` and `arm64` architectures.

1. Refer https://www.ibm.com/docs/en/wm-api-control-plane/11.1.0?topic=plane-deploy-api-control to pull control plane images from IBM container registry.

2. Configure your deployment

    The [values.yaml](values.yaml) file allows to configure different aspects of API Control Plane deployment. To be able to access API Control Plane after it's deployed, you need to edit this file and provide a value for `domainName` that matches the hostname of the machine you're deploying API Control plane on. Make sure this hostname is accessible to whoever will be connecting to API Control Plane.

    If you don't want to use the `latest` version and prefer a specific one, make sure to update the [values.yaml](values.yaml) file for appropriate versions of the docker image you want to use for ingress, ui, engine and asset catalog applications.

    Default configuration is set up to deploy 2 replicas of API Control Plane containers and 1 replica for others. Edit the values.yaml file to change that as needed.

3. Execute the deployment script

    To deploy the API Control Plane with default configuration:

    - create namespace

        ```bash
        kubectl create namespace control-plane
        ```
   
    - create a Kubernetes secret named certs-secret

        ```bash
        kubectl create secret generic certs-secret --from-file=../examples/certs -n control-plane
        ```

    - create a Kubernetes docker-registry secret

        ```bash
        kubectl create secret docker-registry regcred --docker-username=<ICR_USERNAME> --docker-password=<ICR_PASSWORD>  --docker-server=<ICR_REGISTRY> -n control-plane
        ```

    - build helm dependencies

        ```bash
        helm dependency build
        ```

    - execute the deployment script

        ```bash
        helm upgrade --install --namespace control-plane --wait --timeout 10m0s control-plane .
        ```

    If everything goes well, the output should be similar to this

    ```bash
    [user@somehost helm]$ helm upgrade --install --create-namespace --namespace control-plane --wait --timeout 5m0s control-plane .
    Release "control-plane" does not exist. Installing it now.
    NAME: control-plane
    LAST DEPLOYED: Fri Apr  7 11:37:53 2023
    NAMESPACE: control-plane
    STATUS: deployed
    REVISION: 1
    TEST SUITE: None
    ```
 
4. Verify it's started

    It will take a couple of minutes to start. You can monitor that with solutions like Portainer or Docker\Kubernetes Dashboard etc. or simply user Docker\Kubernetes CLI like this

    ```bash
    [user@somehost helm]$ kubectl get all -n control-plane
    NAME                               READY   STATUS    RESTARTS   AGE
    pod/assetcatalog-75d94cff5-7bmkk   1/1     Running   0          5m43s
    pod/assetcatalog-75d94cff5-vrsxm   1/1     Running   0          5m43s
    pod/datastore-cp-0                 1/1     Running   0          5m43s
    pod/engine-57967b46c4-5b5kg        1/1     Running   0          5m43s
    pod/engine-57967b46c4-92pnz        1/1     Running   0          5m43s
    pod/ingress-7d4567dcf8-grrrp       1/1     Running   0          5m43s
    pod/ingress-7d4567dcf8-jnrwt       1/1     Running   0          5m43s
    pod/ui-6c8d58d754-bc7s5            1/1     Running   0          5m43s
    pod/ui-6c8d58d754-l5qcs            1/1     Running   0          5m43s
    pod/nginx-7bdfdl4tba-sadsd         1/1     Running   0          5m43s

    NAME                             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
    service/assetcatalog-svc         ClusterIP   10.43.72.67     <none>        8080/TCP   5m43s
    service/datastore-cp-lb-headless ClusterIP   None            <none>        9300/TCP   5m43s
    service/datastore-cp-lb          ClusterIP   10.43.31.70     <none>        9200/TCP   5m43s
    service/engine-svc               ClusterIP   10.43.19.194    <none>        8080/TCP   5m43s
    service/ingress-svc              ClusterIP   10.43.111.144   <none>        8080/TCP   5m43s
    service/ui-svc                   ClusterIP   10.43.66.124    <none>        8080/TCP   5m43s
    service/nginx-svc                ClusterIP   10.43.66.143    <none>        8080/TCP   5m43s

    NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
    deployment.apps/assetcatalog   2/2     2            2           5m43s
    deployment.apps/engine         2/2     2            2           5m43s
    deployment.apps/ingress        2/2     2            2           5m43s
    deployment.apps/ui             2/2     2            2           5m43s
    deployment.apps/nginx          1/1     1            1           5m43s

    NAME                                     DESIRED   CURRENT   READY   AGE
    replicaset.apps/assetcatalog-75d94cff5   2         2         2       5m43s
    replicaset.apps/engine-57967b46c4        2         2         2       5m43s
    replicaset.apps/ingress-7d4567dcf8       2         2         2       5m43s
    replicaset.apps/ui-6c8d58d754            2         2         2       5m43s
    replicaset.apps/ui-6c8d58d754            1         1         1       5m43s
  
    NAME                             READY   AGE
    statefulset.apps/datastore-cp-0   1/1     5m43s
    ```

###### [Back to Top](#api-control-plane-deployment-with-helm)
***

## How to access the newly deployed IBM webMethods API Control Plane?

1. Open your browser and go to `https://[the-host-you-configured]/` or `http://[the-host-you-configured]/` (Unsecured)
2. You should see the login screen. Log in using Administrator username and the default password.

###### [Back to Top](#api-control-plane-deployment-with-helm)

***

## How to stop IBM webMethods API Control Plane using helm?

To stop and remove the API Control Plane default configuration:

```bash
helm uninstall control-plane -n control-plane
```

If everything goes well, the output should be similar to this

```bash
[user@somehost helm]$ sudo /usr/local/bin/helm uninstall control-plane -n control-plane
release "control-plane" uninstalled
```

###### [Back to Top](#api-control-plane-deployment-with-helm)
***

## Additional deployment flavors

### 1. Enabling Open Telemetry using Jaeger

API Control plane can be started in debug mode with Open telemetry enabled and exposed using [Jaeger UI](https://www.jaegertracing.io/). For this, the deployment needs additional image, namely `jaegertracing/all-in-one`.

To enable it set the property `applications.jaegertracing.enabled` to `true` in `values.yaml` file (line 111).

```yaml
  jaegertracing:
    enabled: true
    name: jaeger-tracing
    #--- Jaeger Tracer image name
    imageName: jaegertracing/all-in-one
    #--- Jaeger Tracer image tag
    imageTag: latest
    #--- Jaeger Tracer image replicas number
    replicas: 1
    #--- Port to run Jaeger.
    port : 4317
    #--- UI Port in which Jaeger is exposed
    uiPort: 16686
     #--- Node Port to access JaegarUI outside the cluster
    extPort: 30007
    storage: 2Gi
    resources:
      # This is just an example. This should be a consious choice of the user. Refer
      # https://raw.githubusercontent.com/hansehe/jaeger-all-in-one/master/helm/jaeger-all-in-one/values.yaml
      limits:
        cpu: 100m
        memory: 128Mi                                                    
      requests:
        cpu: 100m
        memory: 128Mi
    # - Enable to use volume mapping for Jaeger   
    volume:
      enabled: false
      className: ""
      size: 3Gi

```

:wave: The Jaeger UI can be accessed via the `applications.jaegertracing.extPort` port (NodePort type) configured in the `values.ymal` file.

:wave: The Jaeger deployment here is a stateless deployment. Please refer to https://github.com/hansehe/jaeger-all-in-one/tree/master/helm for the complete production level deployment of Jaeger.

###### [Back to Top](#api-control-plane-deployment-with-helm)
***

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| applications.assetcatalog.imageName | string | `"cp.icr.io/cp/webmethods/api/ibm-webmethods-api-control-plane-assetcatalog"` | Image name of assetcatalog |
| applications.assetcatalog.imageTag | string | `"11.1.5"` | Image tag of assetcatalog |
| applications.assetcatalog.logLevel | string | `"TRACE"` |  |
| applications.assetcatalog.name | string | `"assetcatalog"` | Name of the application  |
| applications.assetcatalog.replicas | int | `2` | No. of assetcatalog Replicas |
| applications.assetcatalog.resources.limits.cpu | string | `"500m"` | Maximum CPU resource units(1 CPU unit is equivalent to 1 physical CPU core, or 1 virtual core) |
| applications.assetcatalog.resources.limits.memory | string | `"512Mi"` | Maximum Memory resource units |
| applications.assetcatalog.resources.requests.cpu | string | `"500m"` | Minimum CPU resource units(1 CPU unit is equivalent to 1 physical CPU core, or 1 virtual core) |
| applications.assetcatalog.resources.requests.memory | string | `"512Mi"` | Minimum Memory resource units |
| applications.datastore.cluster | object | `{"initial_cluster_manager_nodes":"datastore-0"}` | Cluster master nodes in the format "<name>-0, ..., <name>-(n-1)" where n is replicas. For a single node cluster it will be "<name>-0". |
| applications.datastore.imageName | string | `"opensearchproject/opensearch"` | Opensearch image name |
| applications.datastore.imageTag | string | `"2.19.1"` | Opensearch image tag |
| applications.datastore.name | string | `"datastore"` |  |
| applications.datastore.replicas | int | `1` | Storage size for persistent volume |
| applications.datastore.resources.limits.cpu | int | `1` | Maximum CPU resource units(1 CPU unit is equivalent to 1 physical CPU core, or 1 virtual core) |
| applications.datastore.resources.limits.memory | string | `"2Gi"` | Maximum Memory resource units |
| applications.datastore.resources.requests.cpu | int | `1` | Minimum CPU resource units(1 CPU unit is equivalent to 1 physical CPU core, or 1 virtual core) |
| applications.datastore.resources.requests.memory | string | `"2Gi"` | Minimum Memory resource units |
| applications.datastore.storage | string | `"5Gi"` |  |
| applications.datastore.storageClassName | string | `"default"` |  |
| applications.engine.imageName | string | `"cp.icr.io/cp/webmethods/api/ibm-webmethods-api-control-plane-engine"` | Image name of engine |
| applications.engine.imageTag | string | `"11.1.5"` | Image tag of engine |
| applications.engine.logLevel | string | `"TRACE"` |  |
| applications.engine.name | string | `"engine"` |  |
| applications.engine.replicas | int | `2` | No. of engine Replicas  |
| applications.engine.resources.limits.cpu | string | `"500m"` | Maximum CPU resource units(1 CPU unit is equivalent to 1 physical CPU core, or 1 virtual core) |
| applications.engine.resources.limits.memory | string | `"512Mi"` | Maximum Memory resource units |
| applications.engine.resources.requests.cpu | string | `"500m"` | Minimum CPU resource units(1 CPU unit is equivalent to 1 physical CPU core, or 1 virtual core) |
| applications.engine.resources.requests.memory | string | `"512Mi"` | Minimum Memory resource units |
| applications.ingress.imageName | string | `"cp.icr.io/cp/webmethods/api/ibm-webmethods-api-control-plane-ingress"` | Image name of ingress |
| applications.ingress.imageTag | string | `"11.1.5"` | Image tag of ingress |
| applications.ingress.licenseFileName | string | `"my_cp_license.xml"` |  |
| applications.ingress.logLevel | string | `"TRACE"` |  |
| applications.ingress.name | string | `"ingress"` |  |
| applications.ingress.replicas | int | `2` | No. of ingress Replicas  |
| applications.ingress.resources.limits.cpu | string | `"500m"` | Maximum CPU resource units(1 CPU unit is equivalent to 1 physical CPU core, or 1 virtual core) |
| applications.ingress.resources.limits.memory | string | `"1024Mi"` | Maximum Memory resource units |
| applications.ingress.resources.requests.cpu | string | `"500m"` | Minimum CPU resource units(1 CPU unit is equivalent to 1 physical CPU core, or 1 virtual core) |
| applications.ingress.resources.requests.memory | string | `"1024Mi"` | Minimum Memory resource units |
| applications.ingress.sslEnabled | bool | `true` |  |
| applications.ingress.tenantId | string | `"default"` | Tenant ID - The name of the tenant for the deployment |
| applications.jaegertracing.enabled | bool | `false` |  |
| applications.jaegertracing.extPort | int | `30007` |  |
| applications.jaegertracing.imageName | string | `"jaegertracing/all-in-one"` |  |
| applications.jaegertracing.imageTag | string | `"latest"` |  |
| applications.jaegertracing.name | string | `"jaeger-tracing"` |  |
| applications.jaegertracing.port | int | `4317` |  |
| applications.jaegertracing.replicas | int | `1` |  |
| applications.jaegertracing.resources.limits.cpu | string | `"100m"` | Maximum CPU resource units(1 CPU unit is equivalent to 1 physical CPU core, or 1 virtual core) |
| applications.jaegertracing.resources.limits.memory | string | `"128Mi"` | Maximum Memory resource units |
| applications.jaegertracing.resources.requests.cpu | string | `"100m"` | Minimum CPU resource units(1 CPU unit is equivalent to 1 physical CPU core, or 1 virtual core) |
| applications.jaegertracing.resources.requests.memory | string | `"128Mi"` | Minimum Memory resource units |
| applications.jaegertracing.storage | string | `"2Gi"` |  |
| applications.jaegertracing.uiPort | int | `16686` |  |
| applications.jaegertracing.volume.className | string | `""` |  |
| applications.jaegertracing.volume.enabled | bool | `false` |  |
| applications.jaegertracing.volume.size | string | `"3Gi"` |  |
| applications.ui.imageName | string | `"cp.icr.io/cp/webmethods/api/ibm-webmethods-api-control-plane-ui"` | Image name of ui |
| applications.ui.imageTag | string | `"11.1.5"` | Image tag of ui |
| applications.ui.logLevel | string | `"TRACE"` |  |
| applications.ui.name | string | `"ui"` |  |
| applications.ui.replicas | int | `2` | No. of ui Replicas  |
| applications.ui.resources.limits.cpu | string | `"500m"` | Maximum CPU resource units(1 CPU unit is equivalent to 1 physical CPU core, or 1 virtual core) |
| applications.ui.resources.limits.memory | string | `"512Mi"` | Maximum Memory resource units |
| applications.ui.resources.requests.cpu | string | `"500m"` | Minimum CPU resource units(1 CPU unit is equivalent to 1 physical CPU core, or 1 virtual core) |
| applications.ui.resources.requests.memory | string | `"512Mi"` | Minimum Memory resource units |
| applications.ui.springCodecMaxMemorySize | string | `"5MB"` |  |
| domainName | string | `"localhost"` |  |
| imagePullSecretName | string | `"regcred"` |  |
| ingress.annotations | object | `{}` |  |
| ingress.domainName | string | `"my-control-plane"` |  |
| ingress.enabled | bool | `false` |  |
| ingress.name | string | `"apicp-ingress"` |  |
| secrets.certs.mountPath | string | `"/certs"` |  |
| secrets.certs.name | string | `"certs-secret"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `"apicp-sa"` |  |
