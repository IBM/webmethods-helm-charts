# API Control Plane deployment with docker compose

The instructions for installing and running the API Control Plane on docker are below.

The standard deployment of API Control plane contains the following 5 microservices.
![img.png](../../docs/diagrams/apicp_logical_architecture.png)

1. Asset catalog - Assets(Runtimes,Data planes) processing of Control plane.
2. Engine - Metrics processing and aggregation.
3. Ingress - User management and security
4. API Control Plane UI - user interface
5. Opensearch - data persistence layer

***

Table of contents
1. [Prerequisite](#Prerequisite)
2. [How to deploy IBM webMethods API Control Plane using docker compose?](#how-to-deploy-webmethods-api-control-plane-using-docker-compose)
3. [How to stop IBM webMethods API Control Plane using docker compose?](#how-to-stop-webmethods-api-control-plane-using-docker-compose)
4. [How to access the newly deployed IBM webMethods API Control Plane?](#how-to-access-the-newly-deployed-webmethods-api-control-plane)
5. [Additional deployment flavors](#additional-deployment-flavors)

***
## Prerequisite
The machine needs following to install the control plane using docker.
1. docker-compose version should be above 2.23.3. 
2. Docker Desktop / Rancher Desktop (version between 1.9.0 and 1.12.0) if you are using the Windows / Mac Operating System.

***

## How to deploy IBM webMethods API Control Plane using docker compose?
> **Note:** This release includes container images built for the `amd64` and `arm64` architectures.

1. Refer https://www.ibm.com/docs/en/wm-api-control-plane/11.1.0?topic=plane-deploy-api-control to pull control plane images from IBM container registry.

2. Configure your deployment

    The [.env](.env) file allows for configuring different aspects of API Control Plane deployment. To be able to access API Control Plane after it's deployed, you need to edit this file and provide a value for `NGINX_DOMAIN_NAME` that matches the hostname of the machine you're deploying API Control plane on. Make sure this hostname is accessible to whoever will be connecting to API Control Plane.

3. Execute the deployment scripts

    To deploy the API Control Plane with default configuration:

    - execute the deployment script from this folder

        ```bash
        docker-compose -f control-plane.yaml up -d
        ```

    If everything goes well, the output should be similar to this

    ```bash
    [user@somehost docker]$ docker-compose -f control-plane.yaml up -d
    [+] Running 8/8
    ⠿ Network ibm-wm-api-cp-nw      Created                         0.2s
    ⠿ Container datastore-cp                 Healthy                        22.6s
    ⠿ Container nginx_setup                  Started                         1.5s
    ⠿ Container control-plane-asset-catalog  Healthy                        88.6s
    ⠿ Container control-plane-engine         Healthy                        88.6s
    ⠿ Container control-plane-ui             Healthy                       119.1s
    ⠿ Container control-plane-ingress        Healthy                       150.5s
    ⠿ Container nginx                        Started                       151.2s
    ⠿ Container artifact-init                Exited                                                                                                           100.4s
    ```

4. Verify it's started

    It will take a couple of minutes to start. You can monitor that with solutions like Portainer or Docker Dashboard etc. or simply user Docker CLI like this

    ```bash
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    ```

    The output, when everything starts should look similar to this

    ```bash
    NAMES                         STATUS                        PORTS
    control-plane-ingress         Up About a minute (healthy)   0.0.0.0:8080->8080/tcp, :::8080->8080/tcp
    control-plane-ui              Up About a minute (healthy)   8080/tcp
    control-plane-engine          Up About a minute (healthy)   8080/tcp
    control-plane-asset-catalog   Up About a minute (healthy)   8080/tcp
    nginx                         Up About a minute (healthy)   0.0.0.0:81->80/tcp, :::81->80/tcp, 0.0.0.0:444->443/tcp, :::444->443/tcp
    datastore-cp                  Up About a minute (healthy)   0.0.0.0:9200->9200/tcp, :::9200->9200/tcp, 9300/tcp
    ```
>
###### [Back to Top](#api-control-plane-deployment-with-docker-compose)
***

## How to stop IBM webMethods API Control Plane using docker compose?

To stop and remove the API Control Plane default configuration:
```
docker-compose -f control-plane.yaml down
```

If everything goes well, the output should be similar to this

```bash
[user@somehost docker]$ docker-compose -f control-plane.yaml down
[+] Running 8/8
⠿ Container nginx_setup                  Removed                         0.0s
⠿ Container nginx                        Removed                         0.3s
⠿ Container control-plane-ingress        Removed                        10.3s
⠿ Container control-plane-ui             Removed                        10.4s
⠿ Container control-plane-engine         Removed                        10.3s
⠿ Container control-plane-asset-catalog  Removed                        10.3s
⠿ Container datastore-cp                 Removed                         2.6s
⠿ Network   ibm-wm-api-cp-nw             Removed                         0.3s
```

###### [Back to Top](#api-control-plane-deployment-with-docker-compose)
***

## How to access the newly deployed IBM webMethods API Control Plane?

1. Open your browser and go to `https://[the-host-you-configured]:444/`
2. You should see the login screen. Log in using Administrator username and the default password.

###### [Back to Top](#api-control-plane-deployment-with-docker-compose)
***

## Additional deployment flavors

### 1. Enabling Open Telemetry using Jaeger

API Control plane can be started in debug mode with Open telemetry enabled and exposed using [Jaeger UI](https://www.jaegertracing.io/). For this, the deployment needs additional image, namely `jaegertracing/all-in-one`.

To start API Control Plane in debug mode:

- change to deployment/docker directory:

    ```bash
    cd deployment/docker
    ```

- execute the deployment script

    ```bash
    docker-compose -f control-plane.debug.yaml --profile observed up -d
    ```

:wave: The Jaeger UI can be accessed via the `JAEGER_UI_PORT` port configured in the `.env` file.

###### [Back to Top](#api-control-plane-deployment-with-docker-compose)
***
