# Helm Chart Repository for IBM webMethods Products and Components

This repository contains a collection of Helm charts for various webMethods components. The section *Available Charts* provides more information about the contents. We test and develop all Helm Charts for webMethods release versions 10.15 and 11.x. The App Version specified in the charts indicates the minimum supported version only.

## Adding the Helm Chart Repository

To add this Helm chart repository to your Helm CLI, run the following command:

```shell
helm repo add webmethods https://ibm.github.io/webmethods-helm-charts/charts
```

To list the content of repository, type `helm search repo webmethods`

```
NAME                                    CHART VERSION   APP VERSION     DESCRIPTION                                       
webmethods/mywebmethodsserver           1.2.0           10.15           My webMethods Server (MWS) Helm Chart for Kuber...
webmethods/apicontrolplane              1.1.0           11.1            API Control Plane Helm Chart for Kubernetes       
webmethods/apigateway                   3.6.3           10.15           API Gateway Helm Chart for Kubernetes             
webmethods/common                       1.0.5           1.0.0           A Library Helm Chart for grouping common logic ...
webmethods/developerportal              1.0.3           10.15           webMethods Developer Portal Helm Chart for Kube...
webmethods/microservicesruntime         1.1.0           10.15           Microservices Runtime (MSR) Helm Chart for Kube...
webmethods/terracottabigmemorymax       2.0.4           4.5.0           Terracotta BigMemory Max Helm Chart for Kubernetes
webmethods/universalmessaging           1.1.0           10.15           Universal Messaging (UM) Helm Chart for Kubernetes
```

## Available Charts READMEs

Each chart has a README for *how to use* and lists some prerequisites.

| Chart Name | Description |
| --- | --- |
| [apigateway](https://github.com/IBM/webmethods-helm-charts/blob/main/apigateway/helm/README.md) | API Gateway |
| [apicontrolplane](https://github.com/IBM/webmethods-helm-charts/blob/main/apicontrolplane/helm/README.md) | API Control Plane |
| [developerportal](https://github.com/IBM/webmethods-helm-charts/blob/main/developerportal/helm/README.md) | webMethods Developer Portal |
| [microservicesruntime](https://github.com/IBM/webmethods-helm-charts/blob/main/microservicesruntime/helm/README.md) | Microservices Runtime (MSR) |
| [mywebmethodsserver](https://github.com/IBM/webmethods-helm-charts/blob/main/mywebmethodsserver/helm/README.md) | My webMethods Server (MWS) |
| [universalmessaging](https://github.com/IBM/webmethods-helm-charts/blob/main/universalmessaging/helm/README.md) | Universal Messaging (UM) |
| [terracottabigmemorymax](https://github.com/IBM/webmethods-helm-charts/blob/main/terracottabigmemorymax/helm/README.md) | Terracotta BigMemoryMax |

## Chart Versions

Per default, Helm uses the latest version on release installation. If you have successfully installed a webMethods release, you should notice the current used Chart version. Therefore, on further release installation or upgrades (with `helm upgrade --install`) you should use the `--version X.Y.Z` to guarantee that the same is installed everywhere.

## Utilities

To adopt Microservices Runtime for your deployment and environment or to build images, there is a collection of utilities:

| Utility | Description |
| --- | --- |
| [image-builder-dcc](https://github.com/IBM/webmethods-helm-charts/blob/main/utils/image-builder-dcc/README.md) | Script to create Image for Database Component Configurator (DCC) |
| [PostgreSQL](https://github.com/IBM/webmethods-helm-charts/blob/main/utils/postgresql/README.md) | Information to deploy a PostgreSQL database |
| [BPM Demo](https://github.com/IBM/webmethods-helm-charts/blob/main/utils/bpm-demo/README.md) | BPM scenarios to deploy MSR as Process Engine |
| [Image Builder using Azure DevOps](https://github.com/IBM/webmethods-helm-charts/blob/main/utils/image-builder-using-azure-devops/README.md) | webMethods Image builder using Azure DevOps pipelines |

## Contributing

If you want to contribute to this repository, please read the [contributing guidelines](./CONTRIBUTING.md) first.

## Useful links   

📘 Explore the Knowledge Base    
Dive into a wealth of webMethods tutorials and articles in our [IBM webMethods Hybrid Integration TechXchange Community] (https://community.ibm.com/community/user/groups/community-home?CommunityKey=82b75916-ed06-4a13-8eb6-0190da9f1bfa).  

💡 Get Expert Answers    
Stuck or just curious? Ask the webMethods experts directly on our [Forum](https://community.ibm.com/community/user/groups/community-home/digestviewer?communitykey=82b75916-ed06-4a13-8eb6-0190da9f1bfa).  

✍️ Share Your Feedback    
Your input drives our innovation. If you find a bug, please create an issue in the repository.

More to discover
* [Helm Charts: Deploying webMethods Components in Kubernetes](https://community.ibm.com/community/user/viewdocument/helm-charts-deploying-webmethods-c?CommunityKey=82b75916-ed06-4a13-8eb6-0190da9f1bfa&tab=librarydocuments)  
* [What is Develop Anywhere, Deploy Anywhere?](https://community.ibm.com/community/user/blogs/john-carter/2024/08/26/develop-anywhere-deploy-anywhere)
  
## Disclaimer

### IBM Public Repository Disclosure

All content in these repositories including code has been provided by IBM under the associated open source software license and IBM is under no obligation to provide enhancements, updates, or support. IBM developers produced this code as an open source project (not as an IBM product), and IBM makes no assertions as to the level of quality nor security, and will not be maintaining this code going forward.
