# UM Deployment with a Dynamically Named Init Job

This example runs an initialization job that is **re-executed whenever its configuration changes**. Kubernetes Jobs are immutable, so a job can only run again if its name changes. Therefore the job `name` is a Helm template (rendered with `tpl`) that contains a hash of the configuration used by the job.

In contrast to the [post-init example](../post-init/README.md), no Helm hooks are used. The job is a regular part of the release: Helm creates the new job when the name changes and removes the old one.

## Prerequisites

See general Prerequisites. Requires chart version `1.4.4` or later (templated job names).

## How it works

1. The init script is stored in a ConfigMap, created by the chart through `extraConfigMaps`.
2. The ConfigMap is mounted into the job and executed. The script uses [runUMTool.sh](https://documentation.softwareag.com/universal_messaging/num10-15/webhelp/num-webhelp/index.html#page/num-webhelp%2Fto-title_clu_administration_tools.html%23). The environment variable `DEPLOYMENT` (set by the [Job template](../../helm/templates/job.yaml)) contains the UM service name.
3. The job name is built from a dynamic expression:

   ```yaml
   jobs:
   - name: um-init-{{ .Values.extraConfigMaps | toYaml | sha256sum | trunc 8 }}
   ```

   The resulting Job is named `<fullname>-um-init-<hash>`, e.g. `universalmessaging-um-init-d3858510`. The same rendered name is used for the pod template and the container.

When you change the script in `extraConfigMaps` and run `helm upgrade`, the hash changes, a new job with a new name is created and the script runs again. If nothing changes, the job name stays the same and nothing is re-executed.

> **Note:** Job and container names must not exceed 63 characters. `sha256sum` returns 64 characters, so always shorten it, e.g. with `trunc 8`.

You can use any other expression as well, e.g. hash a different value or use `{{ .Release.Revision }}` to run the job on every upgrade.

## Values

Download the [values.yaml](./values.yaml) file. Add the content to your existing or create a new file. Afterwards, you can install the release with ...

```
helm install um webmethods/universalmessaging -f values.yaml
```

[values.yaml](./values.yaml) has following content ...

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| extraConfigMaps[0].metadata.name | string | `"um-init-script"` | Name of the ConfigMap holding the script |
| extraConfigMaps[0].data."init.sh" | string | Script creating a JMS connection factory | Retried until `runUMTool.sh` returns `0` or `48` (already exists) |
| jobs[0].name | string | `"um-init-{{ .Values.extraConfigMaps \| toYaml \| sha256sum \| trunc 8 }}"` | Dynamic job name, changes with the content of `extraConfigMaps` |
| jobs[0].image.repository | string | `"ibmwebmethods.azurecr.io/universalmessaging-server"` | |
| jobs[0].image.tag | float | `10.15` | |
| jobs[0].image.imagePullPolicy | string | `"IfNotPresent"` | |
| jobs[0].restartPolicy | string | `"Never"` | |
| jobs[0].extraSpec.backoffLimit | int | `3` | |
| jobs[0].env[0] | object | `TOOLS_ONLY=true` | Start the image in tools-only mode |
| jobs[0].command | list | `["/bin/bash"]` | |
| jobs[0].args | list | `["/scripts/init.sh"]` | Runs the mounted script |
| jobs[0].volumes / jobs[0].volumeMounts | list | ConfigMap `um-init-script` mounted at `/scripts` | |

## Verify

Render the chart locally to see the job name. Change the script and render again - the name changes:

```
helm template um webmethods/universalmessaging -f values.yaml | grep "kind: Job" -A 3
```
