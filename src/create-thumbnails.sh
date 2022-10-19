#!/usr/bin/env bash
#
# create-thumbnails.sh v2022-10-09
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
10568/108972'

# Max width/height (will used the longest of the two, and not force the aspect)
export THUMBNAIL_SIZE='800x800'
# DSpace 6.x seems to use 92 (from checking a resulting JPEG)
export THUMBNAIL_QUALITY=92
export CURL_BIN_PATH='/usr/bin/curl'
export CONVERT_BIN_PATH='/usr/bin/magick convert'
export IDENTIFY_BIN_PATH='/usr/bin/magick identify'
export GHOSTSCRIPT_RGB_PROFILE_PATH='/usr/share/ghostscript/iccprofiles/default_rgb.icc'
export GHOSTSCRIPT_CMYK_PROFILE_PATH='/usr/share/ghostscript/iccprofiles/default_cmyk.icc'
# Unsharp uses <radius>{x<sigma>}{+<amount>}{+<threshold>}, but we only need
# radius and sigma to get the basic effect. Radius should be 0 to automatically
# select an appropriate radius, and a sigma of 0.5 seems to give a good effect.
#
# See: https://imagemagick.org/script/command-line-options.php#unsharp
# See: https://redskiesatnight.com/2005/04/06/sharpening-using-image-magick/
export UNSHARP_VALUE='0x0.5'
# URL to DSpace server (without /rest)
DSPACE_URL='https://dspacetest.cgiar.org'

# Create a directory to save PDFs
mkdir -p data

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

        [[ $? -eq 0 ]] && echo "Downloaded $pdf_filename"
    fi

    ./src/dspace-thumbnail.sh
done
