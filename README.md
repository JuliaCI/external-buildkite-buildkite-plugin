# External Buildkite Plugin

Download Buildkite configuration files from an external repository

## Example

Add the following to your `pipeline.yml`:

```yml
steps:
  - plugins:
    - JuliaCI/external#v1.0:
        version_file: 'buildkite.version'
        external_repo: 'https://github.com/JuliaCI/julia-buildkite.git'
        folder: '.buildkite'
```
