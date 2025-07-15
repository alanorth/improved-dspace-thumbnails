#!/usr/bin/env bash
#
# create-thumbnails.sh v2023-05-13
#

# A bunch of handles with a mix of pictures, text, etc.
HANDLES='10568/103447
10568/3149
10568/51999
10568/53155
10568/68624
10568/68680
10568/71249
10568/71259
10568/72646
10568/76976
10568/77628
10568/97925
10568/75477
10568/116598
10568/108972
10568/3030
10568/129639
10568/129206
10568/128829
10568/109734
10568/108738
10568/113761
10568/52329
10568/125404
10568/89049
10568/101420
10568/105388
10568/104574
10568/105185
10568/104619
10568/105262
10568/104719
10568/104591
10568/105063
10568/104354'

# Max width/height, which uses the longest of the two without forcing the aspect
export THUMBNAIL_SIZE='800x800'
# DSpace 6.x seems to use 92 (default in ImageMagick)
export THUMBNAIL_QUALITY=92
CURL_BIN_PATH='/usr/bin/curl'
export CONVERT_BIN_PATH='/usr/bin/magick convert'
export IDENTIFY_BIN_PATH='/usr/bin/magick identify'
# Only for ImageMagick 6, apparently not needed in ImageMagick 7
export GHOSTSCRIPT_RGB_PROFILE_PATH='/usr/share/ghostscript/iccprofiles/default_rgb.icc'
export GHOSTSCRIPT_CMYK_PROFILE_PATH='/usr/share/ghostscript/iccprofiles/default_cmyk.icc'
# Number of processes to run at a time
export NUM_CPUS=$(nproc)
# URL to DSpace server (without /rest)
DSPACE_URL='https://dspace7test.ilri.org'

# Create directories
mkdir -p data img/im7 results/im7

# Start pueue and adjust number of parallel tasks for our queue. Using the num-
# ber of logical CPUs minus two to account for overhead.
systemctl start --user pueued
pueue parallel $((NUM_CPUS-2))

for handle in $HANDLES; do
    echo "Processing $handle..."

    # construct PDF filename from handle, ie 10568/3149 → 10568-3149.pdf
    export pdf_filename="${handle/\//-}.pdf"

    # check if PDF has already been downloaded, download if not
    if ! [[ -f "data/$pdf_filename" ]]; then
        # command to fetch the link for retrieving the PDF bitstream from DSpace
        request_url="${DSPACE_URL}/rest/handle/${handle}?expand=bitstreams"
        cmd="${CURL_BIN_PATH} -s ${request_url}"
        json_response=$($cmd)

        # extract retrieveLink and strip quotes from URL
        retrieveLink=$(echo $json_response | jq '.bitstreams[] | select(.bundleName=="ORIGINAL") | .retrieveLink' | sed -e 's/"//g')

        # fetch the PDF (the retrieveLink includes a leading "/")
        request_url="${DSPACE_URL}$retrieveLink"
        ${CURL_BIN_PATH} -s "${request_url}" -o "data/$pdf_filename"

        [[ $? -eq 0 ]] && echo "> Downloaded $pdf_filename"
    fi

    # check if PDF uses CMYK colorspace (only used for ImageMagick)
    export cmyk="no"
    identify_output=$($IDENTIFY_BIN_PATH -format "%[colorspace]\n" "data/$pdf_filename"\[0\] 2> /dev/null)
    if [[ $identify_output == 'CMYK' ]]; then
        export cmyk="yes"
    fi

    # Original analysis from 2022. For use with ImageMagick 6.
    #./src/dspace-thumbnail.sh # DSpace 6.3 / 7.4 thumbnails
    #./src/improved-thumbnail.sh # DSpace 7.5

    # Experimental things
    #./src/improved-lossless.sh # For comparison using ssimulacra2

    #./src/improved-thumbnail-im7.sh
    #./src/improved-thumbnail-im7-webp.sh
    #./src/improved-thumbnail-im7-avif.sh
done
