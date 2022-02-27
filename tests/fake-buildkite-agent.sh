#!/bin/bash

# This script used by the tests to mock out the `buildkite-agent meta-data` utility,
# storing metadata blobs on the filesystem.  It is installed as `buildkite-agent` and
# used to test functionality that depends on a functioning metadata store.
mkdir -p /tmp/metadata_store

function handle_metadata() {
    case "$1" in
        exists)
            [ -f "/tmp/metadata_store/${2}" ] && exit 0
            exit 1
            ;;
        set)
            echo "${3}" > "/tmp/metadata_store/${2}"
            ;;
        get)
            cat "/tmp/metadata_store/${2}"
            ;;
        unset)
            rm -f "/tmp/metadata_store/${2}"
            ;;
        clear-all)
            rm -rf "/tmp/metadata_store"
            ;;
        *)
            echo "Unrecognized meta-data command $1" >&2
            exit 1
            ;;
    esac
}

case "$1" in
    meta-data)
        shift 1
        handle_metadata "$@"
        ;;
    *)
        echo "Unrecognized command $1" >&2
        exit 1
esac
