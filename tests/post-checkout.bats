#!/usr/bin/env bats

# load '/usr/local/lib/bats/load.bash'
load "${BATS_PATH:?}/load.bash"
source "/plugin/lib/common.sh"

# Create fake "buildkite-agent"
cp /plugin/tests/fake-buildkite-agent.sh /usr/local/bin/buildkite-agent
chmod +x /usr/local/bin/buildkite-agent

function unset_plugin_variables() {
    unset BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_REPO_URL
    unset BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_FOLDER
    unset BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_VERSION

    # Clear any metadata that was set previously
    buildkite-agent meta-data clear-all
}

function setup() {
    unset_plugin_variables

    unset TEMPORARY_DIRECTORY
    TEMPORARY_DIRECTORY=$(mktemp -d)
    pushd "${TEMPORARY_DIRECTORY}" >/dev/null
}

function teardown() {
    unset_plugin_variables

    rm -rf ${TEMPORARY_DIRECTORY:?}
    unset TEMPORARY_DIRECTORY
    popd >/dev/null
}

function test_known_checkout() {
    KNOWN_HASH="27b8700184aa282a89e380449eb0b2a11b2c7d85"
    run "/plugin/hooks/post-checkout"
    assert_success

    assert_output --partial "Note: checking out '${KNOWN_HASH}'"
    assert_output --partial "Cloning into '${BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_FOLDER:?}'..."

    # Ensure that we actually got some of these files
    assert_file_exist "${TEMPORARY_DIRECTORY:?}/.buildkite/README.md"
    assert_file_exist "${TEMPORARY_DIRECTORY:?}/.buildkite/tests/post-checkout.bats"

    assert [[ "$(buildkite-agent meta-data get BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_VERSION)" == "${KNOWN_HASH}" ]]
}

@test "Embedded gitsha" {
    # Ouroboros mode engage
    export BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_REPO_URL="https://github.com/JuliaCI/external-buildkite-buildkite-plugin"
    export BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_FOLDER="${TEMPORARY_DIRECTORY:?}/.buildkite"
    export BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_VERSION="27b8700184aa282a89e380449eb0b2a11b2c7d85"

    test_known_checkout
}

@test "Embedded gitref" {
    # Ouroboros mode engage
    export BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_REPO_URL="https://github.com/JuliaCI/external-buildkite-buildkite-plugin"
    export BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_FOLDER="${TEMPORARY_DIRECTORY:?}/.buildkite"
    export BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_VERSION="test-anchor"

    test_known_checkout
}

@test "File gitsha" {
    export BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_REPO_URL="https://github.com/JuliaCI/external-buildkite-buildkite-plugin"
    export BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_FOLDER="${TEMPORARY_DIRECTORY:?}/.buildkite"
    export BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_VERSION="./version"

    echo "27b8700184aa282a89e380449eb0b2a11b2c7d85" > ./version
    test_known_checkout
}

@test "File gitref" {
    export BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_REPO_URL="https://github.com/JuliaCI/external-buildkite-buildkite-plugin"
    export BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_FOLDER="${TEMPORARY_DIRECTORY:?}/.buildkite"
    export BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_VERSION="./version"

    echo "test-anchor" > ./version
    test_known_checkout
}

@test "buildkite-agent meta-data override" {
    export BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_REPO_URL="https://github.com/JuliaCI/external-buildkite-buildkite-plugin"
    export BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_FOLDER="${TEMPORARY_DIRECTORY:?}/.buildkite"
    export BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_VERSION="not a real version"

    # Set ourselves an overriding meta version
    buildkite-agent meta-data set BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_VERSION "test-anchor"

    assert [ $(buildkite-agent meta-data get BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_VERSION) == "test-anchor" ]
    test_known_checkout
}
