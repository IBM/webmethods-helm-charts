# Terracotta Helm Chart

## Table of Contents

- [Overview](#overview)
- [Disclaimer and Warnings](#disclaimer-and-warnings)
- [Version History](#version-history)
- [Compatibility Matrix](#compatibility-matrix)
- [Prerequisites](#prerequisites)
- [Platforms](#platforms)
- [Installation](#installation)
  - [Add the Helm Repository](#add-the-helm-repository)
  - [Install the Chart](#install-the-chart)
  - [Verify Installation](#verify-installation)
- [Configuration](#configuration)
- [Upgrading](#upgrading)
- [Uninstalling](#uninstalling)
- [Setup Guide](#setup-guide)
  - [Creating a new Terracotta cluster](#creating-a-new-terracotta-cluster)
  - [With default settings](#with-default-settings)
  - [Node/Stripe scaling](#nodestripe-scaling)
  - [Running In Consistency Mode](#running-in-consistency-mode)
  - [Running with Security](#running-with-security)
- [F.A.Q and Troubleshooting](#faq-and-troubleshooting)

## Overview

This Helm chart deploys a Terracotta cluster on Kubernetes, including:

1. **Terracotta Server** - Distributed in-memory data management
2. **Terracotta Management Server (TMS)** - Cluster monitoring and management
3. **Terracotta Operator** - Manages cluster lifecycle, activation, and scaling operations

The chart automatically deploys the Terracotta Operator CRD during installation if not already present. Note that `helm uninstall` does not remove the CRD from the cluster.

## Disclaimer and Warnings

**The user is responsible for customizing these files on-site.**
This Helm chart is provided as a minimal requirement to install Terracotta BigMemory Max on k8s.

---

_Considering the complexity of k8s settings regarding pod and volume lifecycle in the context of a multi-stripe
active/passive cluster it is strongly advised that the user consult with a k8s expert._

_Pay attention that the nature of k8s automatically handling pod restart and volume assignment can go against the
expected normal behavior of Terracotta Servers on a traditional infrastructure. This can lead to unexpected behaviors
and / or malfunctioning clusters._

_Terracotta Servers embed a mechanism to automatically restart in case of failure or configuration change, and
eventually can invalidate the data on disk (to be wiped). This mechanism is not compatible with the default k8s
lifecycle management which can for example respawn a pod on a pre-existing volume where the data has been marked
invalidated._

---

## Version History

| Version | Changes and Description |
| ------- | ----------------------- |
| `1.0.0' | Initial release         |

## Compatibility Matrix

| NAME                  | CHART VERSION | APP VERSION |
| :-------------------- | :-----------: | :---------: |
| webmethods/terracotta |     `1.x`     |   `11.x`    |

## Prerequisites

- Kubernetes 1.19+
- Helm 3.x
- PersistentVolume provisioner support in the underlying infrastructure
- Sufficient cluster resources for multi-stripe deployment

## Platforms

Here are the list of platforms on which we have tested these Helm Charts:

- Minikube
- Rancher Desktop
- OpenShift

## Installation

### Add the Helm Repository

```bash
helm repo add webmethods https://open-source.softwareag.com/webmethods-helm-charts/
helm repo update
```

### Install the Chart

```bash
helm install <release-name> webmethods/terracotta [flags]
```

Example:

```bash
helm install my-terracotta webmethods/terracotta
```

### Verify Installation

```bash
kubectl get pods
kubectl get statefulsets
kubectl get services
```

## Configuration

The following table lists the main configurable parameters of the Terracotta chart and their default values.

| Parameter               | Description                             | Default                   |
| ----------------------- | --------------------------------------- | ------------------------- |
| `stripes`               | Number of stripes in the cluster        | `2`                       |
| `nodes`                 | Number of nodes per stripe              | `2`                       |
| `offheaps`              | Off-heap memory configuration           | `"offheap-1:512MB"`       |
| `datadirs`              | Data directory configuration            | `"dataroot-1,dataroot-2"` |
| `failoverPriority`      | Failover priority mode                  | `"availability"`          |
| `clusterName`           | Name of the Terracotta cluster          | `"my-cluster"`            |
| `namespaceOverride`     | Override default namespace              | `""`                      |
| `voters`                | Number of voter pods (consistency mode) | `0`                       |
| `security.isConfigured` | Enable security features                | `false`                   |
| `security.sslEnabled`   | Enable SSL/TLS                          | `"false"`                 |
| `security.authc`        | Authentication method                   | `""`                      |

Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example:

```bash
helm install my-terracotta webmethods/terracotta \
  --set stripes=3 \
  --set nodes=2 \
  --set clusterName=production-cluster
```

Alternatively, provide a YAML file with parameter values:

```bash
helm install my-terracotta webmethods/terracotta -f values.yaml
```

## Upgrading

To upgrade an existing release:

```bash
helm upgrade my-terracotta webmethods/terracotta [flags]
```

## Uninstalling

To uninstall/delete the deployment:

```bash
helm uninstall my-terracotta
```

**Note:** This command removes all Kubernetes components associated with the chart but does not delete:

- The Terracotta Operator CRD
- PersistentVolumeClaims (PVCs) - these must be manually deleted if needed

## Setup Guide

## How to use the helm chart to perform various operations

### Creating a new Terracotta cluster

```bash
helm install <release-name> cloud/multi-stripe.
For ex:-
helm install "my-release" cloud/multi-stripe
```

As part of install with default values for the charts, it deploys 2\*2 Terracotta cluster and activate it -

```
mdh@SAG-1HXQKG3:/mnt/c/Users/MDH/Myrepos/terracotta-enterprise/cloud/helm/multi-stripe$ kubectl get pods
NAME                                              READY   STATUS    RESTARTS   AGE
tms-statefulset-0                                 1/1     Running   0          35s
my-release-terracotta-operator-66b7fddc97-7mskc   1/1     Running   0          35s
terracotta-stripe-1-1                             0/1     Running   0          33s
terracotta-stripe-1-0                             0/1     Running   0          33s
terracotta-stripe-2-0                             0/1     Running   0          33s
terracotta-stripe-2-1                             0/1     Running   0          33s

mdh@SAG-1HXQKG3:/mnt/c/Users/MDH/Myrepos/terracotta-enterprise/cloud/helm/multi-stripe$ kubectl get pvc
NAME                              STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
tmsdata-tms-statefulset-0         Bound    pvc-005091fc-dee0-4d42-be4e-6be0e07d8c0f   5Gi        RWO            local-path     83s
corestore-terracotta-stripe-2-0   Bound    pvc-3a109ca7-1c10-481f-9a6a-573f894de38f   10Gi       RWO            local-path     81s
corestore-terracotta-stripe-1-0   Bound    pvc-f0c34001-593b-466c-bea5-b9c228d7b8d0   10Gi       RWO            local-path     81s
corestore-terracotta-stripe-1-1   Bound    pvc-7b3e40e1-78ff-4bf5-88fa-9679ab2e85cf   10Gi       RWO            local-path     81s
corestore-terracotta-stripe-2-1   Bound    pvc-422d1959-d970-4418-b1d0-1b09198fde95   10Gi       RWO            local-path     81s

mdh@SAG-1HXQKG3:/mnt/c/Users/MDH/Myrepos/terracotta-enterprise/cloud/helm/multi-stripe$ kubectl get deployments
NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
my-release-terracotta-operator   1/1     1            1           3m24s
mdh@SAG-1HXQKG3:/mnt/c/Users/MDH/Myrepos/terracotta-enterprise/cloud/helm/multi-stripe$ kubectl get statefulsets
NAME                  READY   AGE
tms-statefulset       1/1     14m
terracotta-stripe-1   2/2     14m
terracotta-stripe-2   2/2     14m
mdh@SAG-1HXQKG3:/mnt/c/Users/MDH/Myrepos/terracotta-enterprise/cloud/helm/multi-stripe$ kubectl get svc
NAME                          TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)             AGE
kubernetes                    ClusterIP   10.43.0.1    <none>        443/TCP             20d
tms-service                   ClusterIP   None         <none>        9480/TCP            14m
terracotta-stripe-1-service   ClusterIP   None         <none>        9410/TCP,9430/TCP   14m
terracotta-stripe-2-service   ClusterIP   None         <none>        9410/TCP,9430/TCP   14m

```

NOTE:- It installs and deploys everything in default namespace in the kubernetes. If its intended to be
deployed in some other namespace `namespaceOverride` in values.yaml can be configured and helm install will make sure
that it deploys
everything in the specified namespace configured in `namespaceOverride`. k8s cluster must have the namespace provided in
`namespaceOverride`.

#### With default settings

By default helm install will create and activate 2\*2 terracotta cluster with following configuration-

```bash
offheaps: "offheap-1:512MB"
datadirs: "dataroot-1,dataroot-2"
failoverPriority: "availability"
clusterName: "my-cluster"
```

NOTE:- These above configurations are initial/one time configuration only and can't be changed with helm upgrade by
changing default values in values.yaml.
config-tool set command must be used if any change for above config is intended.

### Node/Stripe scaling

By default helm install creates 2\*2 cluster i.e 2 stripes with 2 nodes in each stripe.
It is controlled via stripes and nodes in values.yaml.

#### Adding a node in all stripes of an activated cluster

Adding a node in all stripes can be achieved by changing the nodes to N+1 in values.yaml and do an helm upgrade.
terracotta-operator logs can be used to verify the node addition for each stripe.

```
helm upgrade "my-release" cloud/multi-stripe
mdh@SAG-1HXQKG3:/mnt/c/Users/MDH/Myrepos/terracotta-enterprise/cloud/helm/multi-stripe$ kubectl get pods
NAME                                              READY   STATUS    RESTARTS   AGE
my-release-terracotta-operator-66b7fddc97-7mskc   1/1     Running   0          48m
terracotta-stripe-2-0                             1/1     Running   0          48m
terracotta-stripe-1-0                             1/1     Running   0          48m
terracotta-stripe-1-1                             1/1     Running   0          48m
terracotta-stripe-2-1                             1/1     Running   0          48m
tms-statefulset-0                                 1/1     Running   0          80s
terracotta-stripe-1-2                             1/1     Running   0          78s
terracotta-stripe-2-2                             0/1     Running   0          29s

the pvcs for the newly created pod -
corestore-terracotta-stripe-1-2   Bound    pvc-4fd7a59c-3772-4f00-bf8f-cb25fcf2e8b6   10Gi       RWO            local-path     95s
corestore-terracotta-stripe-2-2   Bound    pvc-2064205a-1b38-4d47-ac3f-3bf04171e900   10Gi       RWO            local-path     46s
```

#### Removing a node from all stripes of an activated cluster

Removing a node from all stripes can be achieved by change the nodes to N-1 in values.yaml and do an helm upgrade.

```
helm upgrade "my-release" cloud/multi-stripe
mdh@SAG-1HXQKG3:/mnt/c/Users/MDH/Myrepos/terracotta-enterprise/cloud/helm/multi-stripe$ kubectl get pods
NAME                                              READY   STATUS    RESTARTS   AGE
my-release-terracotta-operator-66b7fddc97-7mskc   1/1     Running   0          54m
terracotta-stripe-2-0                             1/1     Running   0          54m
terracotta-stripe-1-0                             1/1     Running   0          54m
terracotta-stripe-1-1                             1/1     Running   0          54m
terracotta-stripe-2-1                             1/1     Running   0          54m
tms-statefulset-0                                 1/1     Running   0          113s

You can verify the pvcs also get deleted.
mdh@SAG-1HXQKG3:/mnt/c/Users/MDH/Myrepos/terracotta-enterprise/cloud/helm/multi-stripe$ kubectl get pvc
NAME                              STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
tmsdata-tms-statefulset-0         Bound    pvc-005091fc-dee0-4d42-be4e-6be0e07d8c0f   5Gi        RWO            local-path     108m
corestore-terracotta-stripe-2-0   Bound    pvc-3a109ca7-1c10-481f-9a6a-573f894de38f   10Gi       RWO            local-path     108m
corestore-terracotta-stripe-1-0   Bound    pvc-f0c34001-593b-466c-bea5-b9c228d7b8d0   10Gi       RWO            local-path     108m
corestore-terracotta-stripe-1-1   Bound    pvc-7b3e40e1-78ff-4bf5-88fa-9679ab2e85cf   10Gi       RWO            local-path     108m
corestore-terracotta-stripe-2-1   Bound    pvc-422d1959-d970-4418-b1d0-1b09198fde95   10Gi       RWO            local-path     108m
```

#### Adding a stripe to an activated cluster

Adding a stripe to an activated cluster can be achieved by changing the stripes to N+1 in values.yaml and do an helm
upgrade.
Adding a stripe will result in creation of new statefulset which is logical representation of a stripe and its pod will
be attached to the existing terracotta cluster.

```
mdh@SAG-1HXQKG3:/mnt/c/Users/MDH/Myrepos/terracotta-enterprise/cloud/helm/multi-stripe$ kubectl get pods
NAME                                              READY   STATUS    RESTARTS   AGE
terracotta-stripe-1-0                             1/1     Running   0          154m
terracotta-stripe-1-1                             1/1     Running   0          154m
terracotta-stripe-2-0                             1/1     Running   0          154m
terracotta-stripe-2-1                             1/1     Running   0          154m
my-release-terracotta-operator-66b7fddc97-7mskc   1/1     Running   0          154m
tms-statefulset-0                                 1/1     Running   0          2m18s
terracotta-stripe-3-0                             1/1     Running   0          2m18s
terracotta-stripe-3-1                             1/1     Running   0          2m18s

mdh@SAG-1HXQKG3:/mnt/c/Users/MDH/Myrepos/terracotta-enterprise/cloud/helm/multi-stripe$ kubectl get statefulsets
NAME                  READY   AGE
terracotta-stripe-1   2/2     155m
terracotta-stripe-2   2/2     155m
tms-statefulset       1/1     155m
terracotta-stripe-3   2/2     2m46s
mdh@SAG-1HXQKG3:/mnt/c/Users/MDH/Myre

mdh@SAG-1HXQKG3:/mnt/c/Users/MDH/Myrepos/terracotta-enterprise/cloud/helm/multi-stripe$ kubectl get svc
NAME                          TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)             AGE
kubernetes                    ClusterIP   10.43.0.1    <none>        443/TCP             20d
tms-service                   ClusterIP   None         <none>        9480/TCP            155m
terracotta-stripe-1-service   ClusterIP   None         <none>        9410/TCP,9430/TCP   155m
terracotta-stripe-2-service   ClusterIP   None         <none>        9410/TCP,9430/TCP   155m
terracotta-stripe-3-service   ClusterIP   None         <none>        9410/TCP,9430/TCP   3m2s
```

#### Removing a stripe from an activated cluster

Removing a stripe from an activated cluster can be achieved by changing the stripes to N-1 in values.yaml and do an helm
upgrade.

For stripe scaling down when stripes is changed to N-1, Nth statefulset resembling terracotta stripe will be detached
from the terracotta cluster
but the statefulset, the pods and pvc remains in kubernetes cluster and it must not be deleted unless the detach stripe
operation becomes successful.

```
Note- Stripe scaling up/down is a long running process as data movement is associated with it, nothing should be deleted untill internal terracotta config tool suggests that internal lock
acquired as part of stripe scaling operation is successful.Once its verifed that data movement is successful statefulset, its service and the pvcs associated
to the pods for the detached stripe can be deleted and if not then it will be deleted when further operation is carried out by the operator as part of the reconcilition loop.
```

```
Note - For stripe or node scaling operation it must always go from N to N+1/N-1 otherwise the scaling operation is rejected.
Also, after helm upgrade verify that desired state is reached and all the pods are up and running before doing any further operations as there could
be possibility that operator failed to perform the operation and repair might be required.You can always check the
operator pod logs to see if certain action failed and in that case the operator pod
could  be restarted to see if reconciles to get to the desired state if not manual intervention is
required to see why the operation failed .
Also if stripe scaling operation fails during data rebalancing and nother scale operation is triggered using helm upgrade
then it will keep getting discarded which can be verified using operator logs untill repair command is used to manually fix the cluster state.
```

### Running In Consistency Mode

This chart can also be used to run Terracotta cluster in consistency mode by configuring `failoverPriority` accordingly
in values.yaml before triggering helm install.

This chart can also be used to run desired number of voter and can be achieved by configuring `voters`
in values.yaml either during initial deployment time (i.e helm install) or later using helm upgrade.
It will result in creation of voter deployment with the configured number of voter pods.

```
mdh@SAG-1HXQKG3:/mnt/c/Users/MDH/Myrepos/terracotta-enterprise/cloud/helm/multi-stripe$ kubectl get deployments
NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
my-release-terracotta-operator   1/1     1            1           84s
terracotta-voter                 1/1     1            1           21s
```

### Running with Security

This chart can also be used to run secure Terracotta cluster and TMS.

1. For enabling security terracotta.security.isConfigured must be set to true in values.yaml.
2. Depending on the kind of security configuration needed terracotta.security.sslEnabled, terracotta.security.authc and
   terracotta.security.whitelist can be configured with values similar to terracotta server start up script. For ex - If
   only ssl is required values.yaml can be configured like following-

   ```
   security:
     isConfigured: true
     sslEnabled: "true"
   ```

   If ssl with authentication is required values.yaml can be configured like following -

   ```
   security:
     isConfigured: true
     sslEnabled: "true"
     authc: "file"
   ```

3. This chart requires various configmaps to be present in the namespace in which the terracotta cluster is supposed to
   be deployed. It contains the security root directories for various nodes of the terracotta cluster. For ex - For
   running 2 stripes 2 nodes secure cluster in the default namespace following configmaps need to be created in the
   default namespace.

   ```
   terracotta-stripe-1-security-configmap -> It should contain the security root directory for terracotta-stripe-1.
   terracotta-stripe-2-security-configmap -> It should contain the security root directory for terracotta-stripe-2.
   tool-security-configmap -> It should contain the client security root directory for communicating with the various terracotta server nodes.
   tms-security-configmap -> It should contain the security root directory for terracotta management server and the tms.properties file .
   ```

   kubectl create configmap can be used for the creation of the above mentioned configmaps.

   ##### Creation procedure of terracotta-stripe-1-security-configmap

   ```
   mdh@SAG-1HXQKG3:~/Downloads/terracotta-stripe-1-security$ ls
   access-control  identity  trusted-authority
   ```

   Step 1: create tar.gz file from the above directory like following -

   ```
   tar -czf security.tar.gz terracotta-stripe-1-security
   ```

   Step 2 : create configmap from the security.tar.gz using following command -

   ```
   kubectl create configmap terracotta-stripe-1-security-configmap --from-file security.tar.gz -o yaml --dry-run=client | kubectl apply -f -
   ```

   ##### Creation procedure of terracotta-stripe-2-security-configmap

   ```
   mdh@SAG-1HXQKG3:~/Downloads/terracotta-stripe-2-security$ ls
   access-control  identity  trusted-authority
   ```

   Step 1: create tar.gz file from the above directory like following -

   ```
   tar -czf security.tar.gz terracotta-stripe-2-security
   ```

   Step 2 : create configmap from the security.tar.gz using following command -

   ```
   kubectl create configmap terracotta-stripe-2-security-configmap --from-file security.tar.gz -o yaml --dry-run=client | kubectl apply -f -
   ```

   ##### Creation procedure of tool-security-configmap

   ```
   mdh@SAG-1HXQKG3:~/Downloads/tool-security$ ls
   identity  trusted-authority
   ```

   Step 1: create tar.gz file from the above directory like following -

   ```
   tar -czf security.tar.gz tool-security
   ```

   Step 2 : create configmap from the security.tar.gz using following command -

   ```
   kubectl create configmap tool-security-configmap --from-file security.tar.gz -o yaml --dry-run=client | kubectl apply -f -
   ```

   ##### Creation procedure of tms-security-configmap

   An additional tms.properties must also be present in tms-security-configmap which is necessary for configuring
   security in TMS. For ex -

   ```
   mdh@SAG-1HXQKG3:~/Downloads/tms-security$ ls
   client  tms  tms.properties

   tms.properties file must have following properties configured like following -

   # tms directory should be configured like following
   tms.security.root.directory=/opt/softwareag/config/tms

   # if audit directory is required
   tms.security.audit.directory=

   # Whether HTTPS should be configured for connections between browsers and the TMS.
   tms.security.https.enabled=true

   # client directory should be configured like following
   tms.security.root.directory.connection.default=/opt/softwareag/config/client
   ```

   Next create a tar.gz for security folder like following -

   ```
   mdh@SAG-1HXQKG3:~/Downloads/tms-security$ tar -czf security.tar.gz .
   This is necessary since the docker container for tms looks for tms.properties file inside /opt/softwareag/config inside container.
   ```

   ```
   Note- The directory names for creating security.tar.gz i.e terracotta-stripe-1-security, tool-security etc. must be as its shown in
   the above example because these are the names that's used internally by terracotta operator.
   ```

4. Once, all the above mentioned configmaps are deployed in the designated namespace inside the kubernetes cluster helm
   install could be triggered.

```
Note - There are two ways in which node identity certificates can be configured.
1. Identity certificate named <hostname>.jks for each node within identity folder of the security root directory could be configured.
   This way during scaling up the number of nodes in a stripe, its security configmap needs to be updated everytime
   before triggering helm upgrade via creation of new security.tar.gz from the updated security root directory and then finally updating the configmap
   via ` kubectl create configmap terracotta-stripe-1-security-configmap --from-file security.tar.gz -o yaml --dry-run=client | kubectl apply -f - `.

2. Single identity certificate for the whole stripe named wildcard.jks can be configured with CN as `*.terracotta-stripe-<ind>.<namespace>.svc.cluster.local`.
   This way the same certificate could be used for all the nodes in single stripe and hence there is no need to update the security configmap for the stripes in case of scaling up the number of nodes in stripes.
```

## F.A.Q and Troubleshooting

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| extraEnvs | string | `nil` | Exta environment properties to be passed on to the terracotta runtime extraEnvs:   name: extraEnvironmentVariable   value: "myvalue" |
| extraLabels | object | `{}` | Extra Labels |
| fullnameOverride | string | `""` |  |
| imagePullSecrets | list | `[{"name":"regcred"}]` | Image pull secret reference. By default looks for `regcred`. |
| nameOverride | string | `""` |  |
| namespaceOverride | string | `""` |  |
| pullPolicy | string | `"IfNotPresent"` |  |
| securityContext.fsGroup | int | `0` |  |
| securityContext.runAsGroup | int | `0` |  |
| securityContext.runAsNonRoot | bool | `true` |  |
| securityContext.runAsUser | int | `1724` |  |
| storageClass | string | `""` |  |
| tag | float | `11.1` | Specific version to not accidentally change production versions with newer images. |
| terracotta.clusterName | string | `"my-cluster"` |  |
| terracotta.datadirs | string | `"dataroot-1,dataroot-2"` |  |
| terracotta.failoverPriority | string | `"availability"` |  |
| terracotta.jsonAuditLogging | bool | `true` |  |
| terracotta.jsonLogging | bool | `false` |  |
| terracotta.nodes | int | `2` |  |
| terracotta.offheaps | string | `"offheap-1:512MB"` |  |
| terracotta.probeFailureThreshold | string | `nil` |  |
| terracotta.resources | object | `{}` |  |
| terracotta.security.authc | string | `""` |  |
| terracotta.security.isConfigured | bool | `false` |  |
| terracotta.security.sslEnabled | string | `""` |  |
| terracotta.security.whitelist | string | `""` |  |
| terracotta.serverImage | string | `"ibmwebmethods.azurecr.io/terracotta-server"` |  |
| terracotta.storage | string | `"10Gi"` |  |
| terracotta.stripes | int | `2` |  |
| terracotta.voterImage | string | `"ibmwebmethods.azurecr.io/terracotta-voter"` |  |
| terracotta.voters | int | `0` |  |
| terracottaOperator.connectionTimeout | string | `"30s"` |  |
| terracottaOperator.operatorImage | string | `"ibmwebmethods.azurecr.io/terracotta-operator"` |  |
| terracottaOperator.requestTimeout | string | `"30s"` |  |
| terracottaOperator.serviceAccount.create | bool | `true` |  |
| terracottaOperator.serviceAccount.name | string | `""` |  |
| tms.jsonAuditLogging | bool | `true` |  |
| tms.jsonLogging | bool | `false` |  |
| tms.resources | object | `{}` |  |
| tms.storage | string | `"5Gi"` |  |
| tms.tmsImage | string | `"ibmwebmethods.azurecr.io/terracotta-management-server"` |  |
