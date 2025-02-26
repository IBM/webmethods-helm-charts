# WebMethods Helm Charts Development 01

This devcontainer is provided for convenience. It contains development tools, kubernetes (kubectl) and openshift (oc) clients that can be configured to connect to a development or test environment.

This way, the user may have an IDE with the necessary tools to author content in this repository without installing anyhing on the host machine besides visual studio code with devcontainers extension and a docker provider such as Rancher Desktop.

This devcontainer has been tested with Rancher Desktop on Windows 11 on an AMD64 CPU architecture.

The devcontainer requires the user to ensure eventual credentials to pull the base image.

The default image is `registry.redhat.io/openshift4/ose-cli`, requiring the user to register to RedHat and then login to the registry.`
