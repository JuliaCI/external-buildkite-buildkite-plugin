#!/usr/bin/env bats

load "${BATS_PATH:?}/load.bash"

# Uncomment the following line to debug stub failures:
# export BUILDKITE_AGENT_STUB_DEBUG=/dev/tty

@test "Integration test" {
    TEMPORARY_DIRECTORY=$(mktemp -d)

    export BUILDKITE_PLUGIN_EXTERNAL_VERSION_FILE="${TEMPORARY_DIRECTORY:?}/buildkite.version"
    export BUILDKITE_PLUGIN_EXTERNAL_EXTERNAL_REPO="https://github.com/JuliaLang/julia.git"
    export BUILDKITE_PLUGIN_EXTERNAL_FOLDER="${TEMPORARY_DIRECTORY:?}/.buildkite"

    run bash -c "rm -rf ${BUILDKITE_PLUGIN_EXTERNAL_VERSION_FILE:?}"
    run bash -c "echo d08b05df6f01cf4ec6e4c28ad94cedda76cc62e8 > ${BUILDKITE_PLUGIN_EXTERNAL_VERSION_FILE:?}"

    run "${PWD:?}/hooks/post-checkout"

    assert_success

    assert_file_exist ${BUILDKITE_PLUGIN_EXTERNAL_VERSION_FILE:?}
    assert_file_exist ${BUILDKITE_PLUGIN_EXTERNAL_FOLDER}/README.md
    assert_file_exist ${BUILDKITE_PLUGIN_EXTERNAL_FOLDER}/stdlib/Pkg.version

    assert_output --partial "The Buildkite config version is: d08b05df6f01cf4ec6e4c28ad94cedda76cc62e8"
    assert_output --partial "commit d08b05df6f01cf4ec6e4c28ad94cedda76cc62e8"
    assert_output --partial "Author: Viral B. Shah <ViralBShah@users.noreply.github.com>"
    assert_output --partial "Date:   Thu Nov 11 18:48:11 2021 -0500"

    # Uncomment the following line to print the output from the hook (useful for debugging):
    # assert_failure

    rm -rf ${TEMPORARY_DIRECTORY:?}
    unset TEMPORARY_DIRECTORY
}
