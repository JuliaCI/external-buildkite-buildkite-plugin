# `external-buildkite` Buildkite Plugin

[![Continuous Integration (CI)][ci-img]][ci-url]

[ci-img]: https://github.com/JuliaCI/external-buildkite-buildkite-plugin/actions/workflows/ci.yml/badge.svg "Continuous Integration (CI)"
[ci-url]: https://github.com/JuliaCI/external-buildkite-buildkite-plugin/actions/workflows/ci.yml

Download Buildkite configuration files from an external repository.

## Example

Add the following to your `pipeline.yml`:

```yml
steps:
  - plugins:
    - JuliaCI/external-buildkite#v1.0:
        version_file: 'buildkite.version'
        external_repo: 'https://github.com/JuliaCI/julia-buildkite.git'
        folder: '.buildkite'
```
