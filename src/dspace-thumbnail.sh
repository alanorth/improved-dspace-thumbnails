# check if PDF uses CMYK colorspace (only used for ImageMagick)
cmyk="no"
identify_output=$($IDENTIFY_BIN_PATH "data/$pdf_filename"\[0\] 2> /dev/null)
if [[ $identify_output =~ CMYK ]]; then
    cmyk="yes"
fi

temp_file=$(mktemp --suffix=.jpg)

# DSpace default thumbnail
thumbnail_filename="${pdf_filename%%.pdf}-dspace.jpg"

if [[ $cmyk == 'yes' ]]; then
    # First generate a large JPEG from the PDF (pay attention to the order
    # of the thumbnails for CMYK handling.
    $CONVERT_BIN_PATH -profile "$GHOSTSCRIPT_CMYK_PROFILE_PATH" \
        -flatten "data/$pdf_filename"\[0\] \
        -profile "$GHOSTSCRIPT_RGB_PROFILE_PATH" \
        "$temp_file" 2> /dev/null

    # Then scale down the large JPEG using -thumbnail
    $CONVERT_BIN_PATH "$temp_file" -thumbnail "$THUMBNAIL_SIZE" \
        -quality "$THUMBNAIL_QUALITY" "img/$thumbnail_filename" 2> /dev/null
else
    $CONVERT_BIN_PATH -flatten "data/$pdf_filename"\[0\] \
        "$temp_file" 2> /dev/null

    $CONVERT_BIN_PATH "$temp_file" -thumbnail "$THUMBNAIL_SIZE" \
        -quality "$THUMBNAIL_QUALITY" "img/$thumbnail_filename" 2> /dev/null
fi

# DSpace default thumbnail with unsharp mask
thumbnail_filename="${pdf_filename%%.pdf}-dspace-unsharp.jpg"

if [[ $cmyk == 'yes' ]]; then
    $CONVERT_BIN_PATH -profile "$GHOSTSCRIPT_CMYK_PROFILE_PATH" \
        -flatten "data/$pdf_filename"\[0\] \
        -profile "$GHOSTSCRIPT_RGB_PROFILE_PATH" \
        "$temp_file" 2> /dev/null

    # Then scale down the large JPEG using -thumbnail and -unsharp
    $CONVERT_BIN_PATH "$temp_file" -thumbnail "$THUMBNAIL_SIZE" \
        -quality "$THUMBNAIL_QUALITY" -unsharp "$UNSHARP_VALUE" \
        "img/$thumbnail_filename" 2> /dev/null
else
    $CONVERT_BIN_PATH -flatten "data/$pdf_filename"\[0\] \
        "$temp_file" 2> /dev/null

    $CONVERT_BIN_PATH "$temp_file" -thumbnail "$THUMBNAIL_SIZE" \
        -quality "$THUMBNAIL_QUALITY" -unsharp "$UNSHARP_VALUE" \
        "img/$thumbnail_filename" 2> /dev/null
fi

rm "$temp_file"
