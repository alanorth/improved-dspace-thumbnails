#!/usr/bin/env bash

# Attempt to quantify the effect of generation loss due to DSpace's default
# behavior of converting PDF to JPG to JPG.
#
# After generating the thumbnails I checked their similarity to the reference
# lossless PNG using ssimulacra:
#
#   $ for file in data/*.pdf; do ssimulacra2 "img/$(basename $file).png" "img/$(basename $file).jpg.jpg" 2>/dev/null; done
#   $ for file in data/*.pdf; do ssimulacra2 "img/$(basename $file).png" "img/$(basename $file).png.jpg" 2>/dev/null; done
#
# With my sample set of seventeen PDFs from CGSpace I found that the "JPG JPG"
# method of thumbnailing results in scores an average of 1.6% lower than with
# the "PNG JPG" method. The average file size with the "PNG JPG" method was
# only 200 bytes larger.
#
# Alan Orth, 2023-03-28
#
# imagemagick 7.1.1.5
# libjpeg-turbo 2.1.5
# ssimulacra 9851c9a11d16af48a1598e4ffbfd73e5bb9b806b

# ImageMagick's default quality is 92, but let's be explicit
THUMBNAIL_QUALITY=92
CONVERT_BIN_PATH='/usr/bin/magick convert'
IDENTIFY_BIN_PATH='/usr/bin/magick identify'
GHOSTSCRIPT_RGB_PROFILE_PATH='/usr/share/ghostscript/iccprofiles/default_rgb.icc'
GHOSTSCRIPT_CMYK_PROFILE_PATH='/usr/share/ghostscript/iccprofiles/default_cmyk.icc'

for pdf_filename in data/*.pdf; do
    # check if PDF uses CMYK colorspace (only used for ImageMagick)
    cmyk="no"
    identify_output=$($IDENTIFY_BIN_PATH "$pdf_filename"\[0\] 2> /dev/null)
    if [[ $identify_output =~ CMYK ]]; then
        cmyk="yes"
    fi

    # 10568-103447.pdf → 10568-103447.pdf.jpg
    supersample_lossy_out="img/$(basename $pdf_filename).jpg"
    # 10568-103447.pdf → 10568-103447.pdf.jpg.jpg
    lossy_thumbnail_out="img/$(basename $pdf_filename).jpg.jpg"

    # 10568-103447.pdf → 10568-103447.pdf.png
    supersample_lossless_out="img/$(basename $pdf_filename).png"
    # 10568-103447.pdf → 10568-103447.pdf.png.jpg
    lossless_thumbnail_out="img/$(basename $pdf_filename).png.jpg"

    # Create the supersamples first since we need to handle CMYK specially
    if [[ $cmyk == 'yes' ]]; then
        # Note that we have to set the density and the CMYK profile before we
        # open the input file!
        $CONVERT_BIN_PATH -density 144 -profile "$GHOSTSCRIPT_CMYK_PROFILE_PATH" \
            -flatten -define pdf:use-cropbox=true "$pdf_filename"\[0\]      \
            -profile "$GHOSTSCRIPT_RGB_PROFILE_PATH"                             \
            -quality "$THUMBNAIL_QUALITY" "$supersample_lossy_out"

        $CONVERT_BIN_PATH -density 144 -profile "$GHOSTSCRIPT_CMYK_PROFILE_PATH" \
            -flatten -define pdf:use-cropbox=true "$pdf_filename"\[0\]      \
            -profile "$GHOSTSCRIPT_RGB_PROFILE_PATH"                             \
            "$supersample_lossless_out"
    else
        $CONVERT_BIN_PATH -density 144 -flatten -define pdf:use-cropbox=true \
            "$pdf_filename"\[0\] -quality "$THUMBNAIL_QUALITY"          \
            "$supersample_lossy_out"

        $CONVERT_BIN_PATH -density 144 -flatten -define pdf:use-cropbox=true \
            "$pdf_filename"\[0\] "$supersample_lossless_out"
    fi

    # Create the resized thumbnails
    $CONVERT_BIN_PATH "$supersample_lossy_out" "$lossy_thumbnail_out"
    $CONVERT_BIN_PATH "$supersample_lossless_out" "$lossless_thumbnail_out"
done
