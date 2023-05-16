#!/usr/bin/env bash

# I'm not happy that we have to pass in all these, but we seem to need them.
ORIGINAL=$1
DISTORTED=$2
QUALITY=$3
ENCODE_EXTENSION=$4
EXPORT_TO_PNG=$5
# Use this instead of $pdf_filename to work around some concurrency issues (?).
PDF_FILENAME=$6
RESULTS_FILE=$7

# Exit early if the original doesn't exist, perhaps due to a race condition.
# The next time we run the script it should exist and succeed here.
[[ ! -f "$ORIGINAL" ]] && exit 1

# EXPORT_TO_PNG will either be false or a filename we should be exporting to.
if [[ $EXPORT_TO_PNG == false ]]; then
    score=$(ssimulacra2 "$ORIGINAL" "$DISTORTED" 2>/dev/null)
else
    $CONVERT_BIN_PATH "$DISTORTED" -quality 100 "$EXPORT_TO_PNG"

    score=$(ssimulacra2 "$ORIGINAL" "$EXPORT_TO_PNG" 2>/dev/null)
fi

size=$(stat -c '%s' "$DISTORTED")

echo "$PDF_FILENAME,$score,$size,$QUALITY" >> "$RESULTS_FILE"

# Clean the queue after encoding and scoring each sample to reduce the overhead
# for the pueued service. According to the developer pueue is meant for tens or
# hundreds of jobs, not thousands! Comment this out if you need to see job logs
# for debug purposes.
pueue clean
