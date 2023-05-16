# Create an "improved" PDF thumbnail by supersampling and forcing ImageMagick
# to use the PDF CropBox instead of the MediaBox.

# Curious how these settings compare
# See: https://blog.developer.adobe.com/image-optimisation-with-next-gen-image-formats-webp-and-avif-248c75afacc4
QUALITY_START=$(jq -r '.recipes.avif.quality_start' < src/recipes/im7.json)
QUALITY_END=$(jq -r '.recipes.avif.quality_end' < src/recipes/im7.json)
QUALITY_STEP=$(jq -r '.recipes.avif.quality_step' < src/recipes/im7.json)
ENCODE_EXTENSION=$(jq -r '.recipes.avif.encode_extension' < src/recipes/im7.json)
ENCODE_CMD=$(jq -r '.recipes.avif.encode_cmd' < src/recipes/im7.json)
EXPORT_TO_PNG=$(jq -r '.recipes.avif.export_to_png' < src/recipes/im7.json)
RESULTS_FILE=results/im7/avif.csv

# Only create the results file if it doesn't exist, ie on the first run
[[ ! -f "$RESULTS_FILE" ]] && echo "filename,score,size,quality" > "$RESULTS_FILE"

# Generate thumbnails at each quality step
for q in $(seq $QUALITY_START $QUALITY_STEP $QUALITY_END); do
    target="img/im7/${pdf_filename}-q${q}.${ENCODE_EXTENSION}"

    # ssimulacra2 can't read AVIF or WebP, so we need to export to PNG. To make
    # this easier I will reuse the EXPORT_TO_PNG variable for the filename if we
    # need to export to png.
    if [[ $EXPORT_TO_PNG == true ]]; then
        export_to_png="img/im7/${pdf_filename}-q${q}.${ENCODE_EXTENSION}.png"
    else
        export_to_png=$EXPORT_TO_PNG
    fi

    # Check if target already exists. If so, then we only need to submit the job
    # for calculating the score. If not, then we have to run the encode and then
    # the stats.
    if [[ -f "$target" ]]; then
        pueue add -l "Score $target" -- ./src/stats.sh "img/im7/${pdf_filename}.png" "$target" $q $ENCODE_EXTENSION $export_to_png $pdf_filename $RESULTS_FILE
    else
        # Use eval to interpolate our command and echo print it
        CMD=$(eval echo $ENCODE_CMD)

        # Add encode command to queue, printing only the task ID so we can use
        # it when we enqueue the subsequent score command
        encode_task_id=$(pueue add -l "Encode $target" -p -- $CMD)

        # Add stats command to score queue with a dependency on the encode task
        pueue add -a $encode_task_id -l "Score $target" -- ./src/stats.sh "img/im7/${pdf_filename}.png" "$target" $q $ENCODE_EXTENSION $export_to_png $pdf_filename $RESULTS_FILE
    fi
done
