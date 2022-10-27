# Create an "improved" PDF thumbnail by supersampling and forcing ImageMagick
# to use the PDF CropBox instead of the MediaBox.

temp_file=$(mktemp --suffix=.jpg)

thumbnail_filename="${pdf_filename%%.pdf}-improved.jpg"

if [[ $cmyk == 'yes' ]]; then
    $CONVERT_BIN_PATH -density 144 -profile "$GHOSTSCRIPT_CMYK_PROFILE_PATH" \
        -flatten -define pdf:use-cropbox=true "data/$pdf_filename"\[0\] \
        -profile "$GHOSTSCRIPT_RGB_PROFILE_PATH" "$temp_file" 2> /dev/null

    $CONVERT_BIN_PATH "$temp_file" -thumbnail "$THUMBNAIL_SIZE" \
        -quality "$THUMBNAIL_QUALITY" "img/$thumbnail_filename" 2> /dev/null
else
    $CONVERT_BIN_PATH -density 144 -flatten -define pdf:use-cropbox=true \
		"data/$pdf_filename"\[0\] "$temp_file" 2> /dev/null

    $CONVERT_BIN_PATH "$temp_file" -thumbnail "$THUMBNAIL_SIZE" \
        -quality "$THUMBNAIL_QUALITY" "img/$thumbnail_filename" 2> /dev/null
fi

rm "$temp_file"
