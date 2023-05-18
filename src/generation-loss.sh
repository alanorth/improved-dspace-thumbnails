#!/usr/bin/env bash

# Attempt to quantify the effect of generation loss due to DSpace's default
# behavior of converting PDF to JPG to JPG. JPEG is a lossy format, and we
# end up doing two lossy conversions with ImageMagick's default quality of
# 92. Note that ImageMagick does have a `-compress lossless` option, but the
# docs say that this refers to Lossless JPEG and should not be used. (A new
# attempt at creating true Lossless JPEG exists in JPEG-XL, but it is not
# widely adopted yet).
#
# After generating the thumbnails I checked their similarity to the reference
# lossless PNG using ssimulacra2:
#
#   $ for file in data/*.pdf; do ssimulacra2 "img/$(basename $file).png" "img/$(basename $file).jpg.jpg" 2>/dev/null; done
#   $ for file in data/*.pdf; do ssimulacra2 "img/$(basename $file).png" "img/$(basename $file).png.jpg" 2>/dev/null; done
#
# With my sample set of thirty-five PDFs from CGSpace I found that the "JPG JPG"
# method of thumbnailing results in ssimulacra2 scores an average of 1.2 points
# lower than with the "PNG JPG" method. The average file size with the "PNG JPG"
# method was only 400 *bytes* larger.
#
# Alan Orth, 2023-04-20
#
# Update (2023-05-18): instead of using PNG we can also use ImageMagick's own
# internal lossless format MIFF. The results are nearly identical to PNG's, but
# MIFF has the benefit of being faster.
#
# imagemagick 7.1.1.7
# libjpeg-turbo 2.1.5
# ssimulacra2 v2.1

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
    lossy_supersample_out="img/$(basename $pdf_filename).jpg"
    # 10568-103447.pdf → 10568-103447.pdf.jpg.jpg
    lossy_thumbnail_out="img/$(basename $pdf_filename).jpg.jpg"

    # 10568-103447.pdf → 10568-103447.pdf.png
    lossless_supersample_out="img/$(basename $pdf_filename).png"
    # 10568-103447.pdf → 10568-103447.pdf.png.jpg
    lossless_thumbnail_out="img/$(basename $pdf_filename).png.jpg"

    # 10568-103447.pdf → 10568-103447.pdf.miff
    lossless_miff_supersample_out="img/$(basename $pdf_filename).miff"
    # 10568-103447.pdf → 10568-103447.pdf.miff.jpg
    lossless_miff_thumbnail_out="img/$(basename $pdf_filename).miff.jpg"

    # Create the supersamples first since we need to handle CMYK specially
    if [[ $cmyk == 'yes' ]]; then
        # Note that we have to set the density and the CMYK profile before we
        # open the input file!
        $CONVERT_BIN_PATH \
            -density 144 \
            -profile "$GHOSTSCRIPT_CMYK_PROFILE_PATH" \
            -define pdf:use-cropbox=true \
            "$pdf_filename"\[0\] \
            -profile "$GHOSTSCRIPT_RGB_PROFILE_PATH" \
            -flatten \
            "$lossy_supersample_out"

        $CONVERT_BIN_PATH \
            -density 144 \
            -profile "$GHOSTSCRIPT_CMYK_PROFILE_PATH" \
            -define pdf:use-cropbox=true \
            "$pdf_filename"\[0\] \
            -profile "$GHOSTSCRIPT_RGB_PROFILE_PATH" \
            -flatten \
            "$lossless_supersample_out"

        $CONVERT_BIN_PATH \
            -density 144 \
            -profile "$GHOSTSCRIPT_CMYK_PROFILE_PATH" \
            -define pdf:use-cropbox=true \
            "$pdf_filename"\[0\] \
            -profile "$GHOSTSCRIPT_RGB_PROFILE_PATH" \
            -flatten \
            "$lossless_miff_supersample_out"
    else
        $CONVERT_BIN_PATH \
            -density 144 \
            -define pdf:use-cropbox=true \
            "$pdf_filename"\[0\] \
            -flatten \
            "$lossy_supersample_out"

        $CONVERT_BIN_PATH \
            -density 144 \
            -define pdf:use-cropbox=true \
            "$pdf_filename"\[0\] \
            -flatten \
            "$lossless_supersample_out"

        $CONVERT_BIN_PATH \
            -density 144 \
            -define pdf:use-cropbox=true \
            "$pdf_filename"\[0\] \
            -flatten \
            "$lossless_miff_supersample_out"
    fi

    # Create the final "distorted" thumbnails for comparison
    $CONVERT_BIN_PATH "$lossy_supersample_out" "$lossy_thumbnail_out"
    $CONVERT_BIN_PATH "$lossless_supersample_out" "$lossless_thumbnail_out"
    $CONVERT_BIN_PATH "$lossless_miff_supersample_out" "$lossless_miff_thumbnail_out"
done
