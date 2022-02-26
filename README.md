# `external-buildkite` Buildkite Plugin

[![Continuous Integration (CI)][ci-img]][ci-url]

[ci-img]: https://github.com/JuliaCI/external-buildkite-buildkite-plugin/actions/workflows/ci.yml/badge.svg "Continuous Integration (CI)"
[ci-url]: https://github.com/JuliaCI/external-buildkite-buildkite-plugin/actions/workflows/ci.yml

Download Buildkite configuration files from an external repository.

## Example

To use this plugin, add the following YAML snippets to your `pipeline.yml` file:

```yml
steps:
  - plugins:
    - JuliaCI/external-buildkite#v1.0:
        version: './buildkite.version'
        repo_url: 'https://github.com/JuliaCI/julia-buildkite.git'
        folder: '.buildkite'
```

Note that `version` can be a gitsha, a gitref (e.g. `master`) or a file that contains within it a gitsha or gitref.
If you opt to use a file for `version`, you must specify its path starting with `./` to disambiguate it from an arbitrary gitref.