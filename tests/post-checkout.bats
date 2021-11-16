#!/usr/bin/env bats

# load '/usr/local/lib/bats/load.bash'
load "${BATS_PATH:?}/load.bash"

function unset_plugin_variables() {
    unset BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_EXTERNAL_REPO
    unset BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_FOLDER
    unset BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_THIS_IS_FIRST_JOB
    unset BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_VERSION
    unset BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_VERSION_FILE
}

function setup() {
    unset_plugin_variables

    unset TEMPORARY_DIRECTORY
    TEMPORARY_DIRECTORY=$(mktemp -d)
}

function teardown() {
    unset_plugin_variables

    rm -rf ${TEMPORARY_DIRECTORY:?}
    unset TEMPORARY_DIRECTORY
}

function test_post_checkout_hook() {
    run "${PWD:?}/hooks/post-checkout"

    assert_success

    # Uncomment the following line to print the output from the hook (useful for debugging):
    # assert_failure

    assert_file_exist ${BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_FOLDER}/README.md
    assert_file_exist ${BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_FOLDER}/stdlib/Pkg.version

    assert_output --partial "INFO: The Buildkite config version (unresolved) is: d08b05df6f01cf4ec6e4c28ad94cedda76cc62e8"
    assert_output --partial "commit d08b05df6f01cf4ec6e4c28ad94cedda76cc62e8"
    assert_output --partial "Author: Viral B. Shah <ViralBShah@users.noreply.github.com>"
    assert_output --partial "Date:   Thu Nov 11 18:48:11 2021 -0500"
}

@test "Unit test: first job" {
    export BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_EXTERNAL_REPO="https://github.com/JuliaLang/julia.git"
    export BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_FOLDER="${TEMPORARY_DIRECTORY:?}/.buildkite"
    export BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_THIS_IS_FIRST_JOB="true"
    export BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_VERSION_FILE="${TEMPORARY_DIRECTORY:?}/buildkite.version"

    run rm -rf "${BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_VERSION_FILE:?}"
    run bash -c "echo d08b05df6f01cf4ec6e4c28ad94cedda76cc62e8 > ${BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_VERSION_FILE:?}"

    test_post_checkout_hook
}

@test "Unit test: subsequent job" {
    export BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_EXTERNAL_REPO="https://github.com/JuliaLang/julia.git"
    export BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_FOLDER="${TEMPORARY_DIRECTORY:?}/.buildkite"
    export BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_VERSION="d08b05df6f01cf4ec6e4c28ad94cedda76cc62e8"

    test_post_checkout_hook
}
