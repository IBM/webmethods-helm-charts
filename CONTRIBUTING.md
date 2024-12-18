# Contributing Guidelines

Contributions are welcome via GitHub Pull Requests. This document outlines the process to help get your contribution accepted.

Any type of contribution is welcome; from new features, bug fixes, [tests](#testing), documentation improvements or even [adding charts to the repository](#adding-a-new-chart-to-the-repository) (if it's viable once evaluated the feasibility).

## How to Contribute

1. Fork this repository, develop, and test your changes.
2. Submit a pull request.

***NOTE***: To make the Pull Requests' (PRs) testing and merging process easier, please submit changes to multiple charts in separate PRs.

### Technical Requirements

When submitting a PR make sure that it:

- Must pass CI jobs for linting and test the changes on top of different k8s platforms.
- Must follow [Helm best practices](https://helm.sh/docs/chart_best_practices/).
- Any change to a chart requires a version bump following [semver](https://semver.org/) principles. This is the version that is going to be merged in the GitHub repository, then our CI/CD system is going to publish in the Helm registry a new patch version including your changes and the latest images and dependencies.

### Documentation Requirements

- A chart's `README.md` must include configuration options. The tables of parameters are generated based on the metadata information from the `values.yaml` file, by using [this tool](https://github.com/norwoodj/helm-docs).
- A chart's `NOTES.txt` must include relevant post-installation information.
- The title of the PR starts with chart name (e.g. `[universalmessaging]`)

### PR Approval and Release Process

1. Changes are manually reviewed by Container Inno team members.
2. Once the changes are accepted, the PR is verified with a "four-eyes-principle" at the moment that includes the lint and the vulnerability checks. If that passes, the Container Inno team will review the changes and trigger any verification and functional tests on the reference environment.
3. When the PR passes all tests, the PR is merged by the reviewer(s) in the GitHub `main` branch.

***NOTE***: Please note that, in terms of time, may be a slight difference between the appearance of the code in GitHub and the chart in the registry.


### Adding a new chart to the repository

There are three major technical requirements to add a new Helm chart to our catalog:

- The chart should use by default official IBM webMethods based container images or dependend publicly available 3rd party images from Docker Hub. 
- Follow the same structure/patterns that the rest of the Inno Container team charts (you can find a basic scaffolding in the [`template` directory](https://github.com/IBM/webmethods-helm-charts/template)).
- Use an [OSI approved license](https://opensource.org/licenses) for all the software.
Please, note we will need to check internally and evaluate the feasibility of adding the new solution to the catalog. Due to limited resources this step could take some time.