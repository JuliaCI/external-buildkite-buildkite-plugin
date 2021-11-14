# `external-buildkite` Buildkite Plugin

[![Continuous Integration (CI)][ci-img]][ci-url]

[ci-img]: https://github.com/JuliaCI/external-buildkite-buildkite-plugin/actions/workflows/ci.yml/badge.svg "Continuous Integration (CI)"
[ci-url]: https://github.com/JuliaCI/external-buildkite-buildkite-plugin/actions/workflows/ci.yml

Download Buildkite configuration files from an external repository.

## Example

To use this plugin, add the following YAML snippets to your `pipeline.yml` file. Note that
the appropriate snippet is different for the first job versus all subsequent jobs.

### First job

This snippet should only be used for the first job. All other jobs should use the snippet
from the "Subsequent jobs" section.

```yml
steps:
  - plugins:
    - JuliaCI/external-buildkite#v1.0:
        this_is_first_job: true
        version_file: 'buildkite.version'
        external_repo: 'https://github.com/JuliaCI/julia-buildkite.git'
        folder: '.buildkite'
```

### Subsequent jobs

This snippet should be used for all jobs except the first job.

```yml
steps:
  - plugins:
    - JuliaCI/external-buildkite#v1.0:
        version: '${BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_VERSION?}'
        external_repo: '${BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_EXTERNAL_REPO?}'
        folder: '${BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_FOLDER?}'
```
