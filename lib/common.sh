#!/bin/bash

set -Eeuo pipefail

# Helper function to kill execution when something goes wrong
function die() {
    echo "ERROR: ${1}" >&2
    if which buildkite-agent >/dev/null 2>/dev/null; then
        # By default, the annotation context is unique to the message
        local CONTEXT=$(echo "${1}" | cksum | cut -d' ' -f1)
        if [[ "$#" -gt 1 ]]; then
            CONTEXT="${2}"
        fi
        buildkite-agent annotate --context="${CONTEXT}" --style=error "${1}"
    fi
    exit 1
}

# Is this a 40-character hexadecimal string?
function is_gitsha() {
    [[ "$1" =~ ^[a-fA-F0-9]{40}$ ]]
}

# Attempts to resolve the given version down to a gitsha
# Takes the input version as first argument and a git repo as second argument
# Input version can be one of:
#  - A gitsha (this does no resolution)
#  - A version file path (should contain either a gitsha or a gitref)
#  - A gitref (requires a checked-out git repo)
function resolve_version() {
    local VERSION="${1}"
    local GIT_REPO="${2}"

    # Are we already a gitsha?  If so, just return that back
    if is_gitsha "${VERSION}"; then
        echo -n "${VERSION}"
        return 0
    fi

    # Are we a file?  We only accept files that start with `./`, to disambiguate
    # files from valid git tags that look like files.  We also check to make sure
    # that reading the file results in only a single word (a gitsha or gitref)
    if [[ "${VERSION}" == "./"* ]]; then
        local VERSION_CONTENTS="$(cat "${VERSION}" 2>/dev/null)"
        if [[ "$(wc -w <<< "${VERSION_CONTENTS}" | xargs)" -ne "1" ]]; then
            die "The ${VERSION} file must contain exactly 1 word!"
        fi

        # If the version_CONTENTS file contains a gitsha, excellent, we're done
        if is_gitsha "${VERSION_CONTENTS}"; then
            echo -n "${VERSION_CONTENTS}"
            return 0
        fi

        # Otherwise, continue on, substituting `VERSION`
        VERSION="${VERSION_CONTENTS}"
    fi

    # At this point, we assume `VERSION` is a gitref, and we try to look it up in `GIT_REPO`
    if [[ -d "${GIT_REPO}/.git" ]]; then
        git -C "${GIT_REPO}" rev-list -n 1 "${VERSION}"
        return 0
    fi

    # If none of the above are true, we need to complain
    die "Invalid version specification '${VERSION}'"
}

# Helper function to first query `buildkite-agent metadata` to see if a value
# has been set, if it has not, the environment, and finally if it was not found
# if we are given a default value, return that.  Otherwise error out with a
# descriptive error message.  If the name does not start with `BUILDKITE_`,
# this function willl prepend the prefix `BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_`
# to any name passed in.
function get_meta_env_value() {
    NAME="${1}"
    if [[ "${NAME}" != "BUILDKITE_"* ]]; then
        NAME="BUILDKITE_PLUGIN_EXTERNAL_BUILDKITE_${NAME}"
    fi

    # Check to see if it's defined in buildkite-agent metadata:
    if buildkite-agent metadata exists "${NAME}"; then
        buildkite-agent metadata get "${NAME}"
        return
    fi

    # If this name is already defined in the environment, use that value
    if [[ -v "${NAME}" ]]; then
        echo -n "${!NAME}"
        return
    fi

    # If all else fails, see if we have a default value
    if [[ "$#" -ge 2 ]]; then
        echo -n "${2}"
    else
        # If we don't have a default for this value, we terminate execution
        die "No value supplied for ${NAME}"
    fi
}
