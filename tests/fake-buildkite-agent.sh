#!/bin/bash

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
        unset)
            rm -f "/tmp/metadata_store/${2}"
            ;;
        get)
            cat "/tmp/metadata_store/${2}"
            ;;
        *)
            echo "Unrecognized metadata command $1" >&2
            exit 1
            ;;
    esac
}

case "$1" in
    metadata)
        shift 1
        handle_metadata "$@"
        ;;
    *)
        echo "Unrecognized command $1" >&2
        exit 1
esac