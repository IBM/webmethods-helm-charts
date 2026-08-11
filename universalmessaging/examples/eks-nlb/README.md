# UM Deployment on EKS with AWS Network Load Balancer

This example exposes each Universal Messaging replica through its own internal
AWS Network Load Balancer (NLB), provisioned by the
[AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/).

The UM Helm chart creates one `Service` per StatefulSet replica — named
`<release>-0`, `<release>-1`, etc. — so every pod gets a dedicated NLB with a
stable DNS hostname. This is the recommended topology for UM cluster inter-node
(NSP) communication on EKS, where each realm member must be reachable at a
predictable, stable address.

## Prerequisites

| Requirement | Notes |
|---|---|
| AWS Load Balancer Controller | Installed and running in the cluster |
| VPC subnet tags | Private subnets: `kubernetes.io/role/internal-elb=1` |
| EFS StorageClass `efs-sc` | Required for persistent volumes (data, logs, config) |
| Image pull secret `regcred` | Must exist in the target namespace |
| UM licence ConfigMap | Named `universalmessaging-license-key` (default) |

## How It Works

Setting `service.type: LoadBalancer` together with
`service.loadBalancerClass: service.k8s.aws/nlb` delegates NLB provisioning to
the AWS Load Balancer Controller. The annotations in [`values.yaml`](./values.yaml)
configure the NLB as:

- **Internal** (`aws-load-balancer-scheme: internal`) — reachable within the VPC
  or over VPN, not exposed to the public internet.
- **IP target mode** (`aws-load-balancer-nlb-target-type: ip`) — traffic is
  forwarded directly to the pod IP, bypassing `kube-proxy` node-port hops. This
  preserves the client source IP and is required for NLB health checks to reach
  the pod.
- **HTTP health check** on `/health/` port `9000` — matches UM's built-in health
  endpoint so the NLB marks targets healthy before routing traffic.
- **`allocateLoadBalancerNodePorts: false`** — suppresses unused `NodePort`
  allocation, keeping the Service definition clean.

## Storage

All three UM volume claim templates (`data`, `logs`, `configuration`) are set to
use the `efs-sc` StorageClass. EFS provides `ReadWriteOnce` access points per
PVC and works across Availability Zones without pinning pods to a specific AZ.

See [`storageclass-efs.yaml`](../../../../mw_argocd/envs/dev/cluster/storageclass-efs.yaml)
in `mw_argocd` for the cluster-level StorageClass definition.

## Install

```shell
helm install um-internal ibm-webmethods/universalmessaging \
  --namespace mw-um-internal \
  --create-namespace \
  -f values.yaml
```

Or with ArgoCD using a two-source Application (chart from Helm repo, values from
this Git repo) — see the `envs/dev/apps/um_internal/app.yaml` in `mw_argocd`.

## Values

Download or reference [`values.yaml`](./values.yaml) in this directory.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `replicaCount` | int | `1` | Number of UM replicas (StatefulSet pods) |
| `image.repository` | string | `sagcr.azurecr.io/universalmessaging-server` | Container image |
| `image.tag` | string | `"10.15"` | Image tag / fix level |
| `um.initJavaMemSize` | string | `"2048"` | Initial JVM heap in MB |
| `um.maxJavaMemSize` | string | `"2048"` | Maximum JVM heap in MB |
| `um.maxDirectMemSize` | string | `"2G"` | Maximum JVM direct (off-heap) memory |
| `service.type` | string | `LoadBalancer` | Kubernetes Service type |
| `service.loadBalancerClass` | string | `service.k8s.aws/nlb` | Delegates to AWS LBC NLB provisioner |
| `service.allocateLoadBalancerNodePorts` | bool | `false` | Suppress NodePort allocation |
| `service.annotations` | map | see values.yaml | AWS LBC NLB configuration annotations |
| `service.port` | int | `9000` | NSP port exposed by the NLB |
| `storage.dataSize` | string | `10Gi` | PVC size for UM data |
| `storage.logsSize` | string | `2Gi` | PVC size for UM logs |
| `storage.configurationSize` | string | `2Mi` | PVC size for UM configuration |
| `storage.data.storageClassName` | string | `efs-sc` | StorageClass for data PVC |
| `storage.logs.storageClassName` | string | `efs-sc` | StorageClass for logs PVC |
| `storage.configuration.storageClassName` | string | `efs-sc` | StorageClass for config PVC |

## Switching to a Public NLB

Change the scheme annotation in `values.yaml`:

```yaml
service:
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"
```

and ensure the target subnets carry the tag `kubernetes.io/role/elb=1`.
