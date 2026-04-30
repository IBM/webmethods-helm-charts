# Generating README.md from README.md.gotmpl

## ✅ Verified Working

The README.md has been successfully generated using podman. The template is now error-free and ready for use.

---


## ⚠️ Important Fix Applied

**Issue**: The original README.md.gotmpl contained Helm template syntax (e.g., `{{ include "common.names.fullname" . }}`) in example code blocks, which caused helm-docs to fail with:
```
Error generating gotemplates for chart .: template: .:285: function "include" not defined
```

**Solution**: Replaced all Helm template expressions in example code blocks with static example values (e.g., `my-release-apianalyticstore-sealed-secret`). This allows helm-docs to process the template successfully while still providing clear examples.

---


The `README.md` file is automatically generated from `README.md.gotmpl` using the `helm-docs` tool.

## Prerequisites

Install `helm-docs`:

### Using Homebrew (macOS/Linux)
```bash
brew install norwoodj/tap/helm-docs
```

### Using Go
```bash
go install github.com/norwoodj/helm-docs/cmd/helm-docs@latest
```

### Using Docker
```bash
docker pull jnorwood/helm-docs:latest
```

### Download Binary
Download from: https://github.com/norwoodj/helm-docs/releases

## Generate README.md

### From the chart directory:
```bash
cd apianalyticstore/helm
helm-docs
```

### From the repository root:
```bash
helm-docs apianalyticstore/helm
```

### Using Docker:
```bash
docker run --rm -v "$(pwd):/helm-docs" jnorwood/helm-docs:latest
```

### Using Podman:
```bash
podman run --rm -v "$(pwd):/helm-docs:z" -u $(id -u) jnorwood/helm-docs:latest
```

## What helm-docs does:

1. Reads `README.md.gotmpl` template file
2. Parses `Chart.yaml` for chart metadata
3. Parses `values.yaml` for configuration parameters
4. Generates `README.md` with:
   - Chart information (name, version, description)
   - Requirements/dependencies
   - Values table (auto-generated from values.yaml comments)
   - Custom content from the template

## Template Syntax

The `README.md.gotmpl` file uses Go template syntax with special helm-docs functions:

### Available Functions:

- `{{ template "chart.header" . }}` - Chart name as header
- `{{ template "chart.description" . }}` - Chart description
- `{{ template "chart.version" . }}` - Chart version
- `{{ template "chart.appVersion" . }}` - App version
- `{{ template "chart.maintainersSection" . }}` - Maintainers list
- `{{ template "chart.sourcesSection" . }}` - Sources/URLs
- `{{ template "chart.requirementsSection" . }}` - Dependencies
- `{{ template "chart.valuesSection" . }}` - Auto-generated values table
- `{{ template "helm-docs.versionFooter" . }}` - Footer with generation info

## Values Documentation

Document values in `values.yaml` using comments:

```yaml
# -- Description of the parameter
# This is a multi-line description
# @default -- auto-generated default value
parameterName: value
```

The `# --` prefix marks a comment as documentation.

## Automation

### Pre-commit Hook

Create `.git/hooks/pre-commit`:
```bash
#!/bin/bash
helm-docs
git add */README.md
```

### GitHub Actions

Create `.github/workflows/helm-docs.yml`:
```yaml
name: Generate Helm Docs
on:
  pull_request:
    paths:
      - '**/Chart.yaml'
      - '**/values.yaml'
      - '**/README.md.gotmpl'

jobs:
  docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: norwoodj/helm-docs-action@v1.1.0
      - name: Commit changes
        run: |
          git config user.name "GitHub Actions"
          git config user.email "actions@github.com"
          git add */README.md
          git commit -m "Update Helm docs" || exit 0
          git push
```

## Configuration

Create `.helm-docs.yaml` in the chart directory for custom configuration:

```yaml
# Sort values alphabetically
sort-values-order: alphabetical

# Template files to process
template-files:
  - README.md.gotmpl

# Values file to parse
values-file: values.yaml

# Chart file to parse
chart-file: Chart.yaml
```

## Verification

After generating, verify the README.md:

```bash
# Check if file was generated
ls -la README.md

# View the generated content
cat README.md

# Compare with template
diff README.md.gotmpl README.md
```

## Troubleshooting

### helm-docs not found
```bash
# Check if installed
which helm-docs

# Check version
helm-docs --version
```

### Template errors
```bash
# Run with debug output
helm-docs --dry-run --log-level debug
```

### Values not appearing in table
- Ensure comments start with `# --`
- Check YAML indentation
- Verify values.yaml syntax

## Best Practices

1. **Keep template updated**: Update README.md.gotmpl when adding features
2. **Document all values**: Use `# --` comments for all configurable values
3. **Regenerate regularly**: Run helm-docs after any values.yaml changes
4. **Version control**: Commit both .gotmpl and generated .md files
5. **CI/CD integration**: Automate generation in your pipeline

## Example Workflow

```bash
# 1. Edit values.yaml and add documentation
vim values.yaml

# 2. Update README.md.gotmpl with new sections
vim README.md.gotmpl

# 3. Generate README.md
helm-docs

# 4. Review changes
git diff README.md

# 5. Commit both files
git add README.md.gotmpl README.md values.yaml
git commit -m "Update chart documentation"
```

## Additional Resources

- [helm-docs GitHub](https://github.com/norwoodj/helm-docs)
- [helm-docs Documentation](https://github.com/norwoodj/helm-docs#usage)
- [Go Template Documentation](https://pkg.go.dev/text/template)