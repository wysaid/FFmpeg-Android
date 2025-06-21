#!/bin/bash

# Compiler wrapper to filter out unsupported Clang flags
# This wrapper removes -mfp16-format=ieee flag which is not supported by Clang

# Get the original compiler command (first argument)
ORIGINAL_COMPILER="$1"
shift

# Filter out the problematic flag
FILTERED_ARGS=()
for arg in "$@"; do
    if [[ "$arg" != "-mfp16-format=ieee" ]]; then
        FILTERED_ARGS+=("$arg")
    fi
done

# Execute the original compiler with filtered arguments
exec "$ORIGINAL_COMPILER" "${FILTERED_ARGS[@]}"
