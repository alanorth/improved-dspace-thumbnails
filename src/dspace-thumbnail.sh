# Create a "default" DSpace 6.4 / 7.4 PDF thumbnail first. Note that DSpace
# does this by generating a large image from the PDF and then resizing it in
# a separate step.

temp_file=$(mktemp --suffix=.jpg)

# DSpace default thumbnail
thumbnail_filename="${pdf_filename%%.pdf}-dspace.jpg"

if [[ $cmyk == 'yes' ]]; then
    # First generate a large JPEG from the PDF (pay attention to the order
    # of the thumbnails for CMYK handling.
    $CONVERT_BIN_PATH -profile "$GHOSTSCRIPT_CMYK_PROFILE_PATH" \
        -flatten -define pdf:use-cropbox=true "data/$pdf_filename"\[0\] \
        -profile "$GHOSTSCRIPT_RGB_PROFILE_PATH" \
        "$temp_file" 2> /dev/null

    # Then scale down the large JPEG using -thumbnail
    $CONVERT_BIN_PATH "$temp_file" -thumbnail "$THUMBNAIL_SIZE" \
        -quality "$THUMBNAIL_QUALITY" "img/$thumbnail_filename" 2> /dev/null
else
    $CONVERT_BIN_PATH -flatten -define pdf:use-cropbox=true "data/$pdf_filename"\[0\] \
        "$temp_file" 2> /dev/null

    $CONVERT_BIN_PATH "$temp_file" -thumbnail "$THUMBNAIL_SIZE" \
        -quality "$THUMBNAIL_QUALITY" "img/$thumbnail_filename" 2> /dev/null
fi

rm "$temp_file"
