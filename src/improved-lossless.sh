# Create a lossless reference PNG of the PDF to use when comparing with distort-
# JPEG, WebP, and AVIF thumbnails of the same PDF. The IM7 command runs in a co-
# ntainer because I suspect there's something wrong with my Ghostscript in Arch.

pueue add -l "Encode img/im7/${pdf_filename}.png" -- podman run --rm -v .:/imgs docker.io/dpokidov/imagemagick -colorspace sRGB -density 144 -define pdf:use-cropbox=true data/${pdf_filename}[0] -quality 100 -thumbnail $THUMBNAIL_SIZE -flatten "img/im7/${pdf_filename}.png"
