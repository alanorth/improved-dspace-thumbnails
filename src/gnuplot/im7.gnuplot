# Use a helper script to plot average scores and file sizes for each quality
# step since gnuplot's stats function only works on an entire column.

# General settings
set datafile separator comma
# Use PNG rendering from Cairo
set terminal pngcairo enhanced size 1024,768
# Don't mirror xy tics on opposite axis
set xtics nomirror
set ytics nomirror
# Minor xy tics
set mxtics
set mytics
# Grid for y and my tics
set grid y my
# Move legend to bottom right so it doesn't overlap graph
set key right bottom

# Library versions (static from dpokidov/imagemagick container)
IMAGEMAGICK_VERSION = "7.1.1-3"
LIBJPEG_VERSION = "2.0.6"
LIBWEBP_VERSION = "1.3.0"
LIBHEIF_VERSION = "1.15.2"
AOM_VERSION = "3.6.0"

VERSIONS = sprintf("ImageMagick %s, libwebp %s, libheif %s (aom %s), libjpeg-turbo %s", IMAGEMAGICK_VERSION, LIBWEBP_VERSION, LIBHEIF_VERSION, AOM_VERSION, LIBJPEG_VERSION)

# Chart title should be "Y vs. X"
set title sprintf("Average Score vs. Quality (ImageMagick)\n{/*0.8 %s}", VERSIONS)
set key title "Format"
set ylabel "Score (ssimulacra2 v2.1)"
set xlabel "Quality"
set output "results/im7/score-vs-quality.png"

# Plot scores (1) against qualities (4)
plot '<src/average.py results/im7/webp.csv' using 4:1 title 'WebP' with linespoints, \
     '<src/average.py results/im7/jpeg.csv' using 4:1 title 'JPEG' with linespoints, \
     '<src/average.py results/im7/avif.csv' using 4:1 title 'AVIF' with linespoints

set title sprintf("Average Size vs. Quality (ImageMagick)\n{/*0.8 %s", VERSIONS)
set key title "Format"
set ylabel "Size (bytes)"
set xlabel "Quality"
set output "results/im7/size-vs-quality.png"

# Plot sizes (2) against qualities (4)
plot '<src/average.py results/im7/webp.csv' using 4:2 title 'WebP' with linespoints, \
     '<src/average.py results/im7/jpeg.csv' using 4:2 title 'JPEG' with linespoints, \
     '<src/average.py results/im7/avif.csv' using 4:2 title 'AVIF' with linespoints

set title sprintf("Average Score vs Average BPP (ImageMagick)\n{/*0.8 %s}", VERSIONS)
set key title "Format"
set ylabel "Score (ssimulacra2 v2.1)"
set xlabel "Bits per pixel (BPP)"
set output "results/im7/score-vs-bpp.png"

# Plot scores (1) against bpp (3)
plot '<src/average.py results/im7/webp.csv' using 3:1 title 'WebP' with linespoints, \
     '<src/average.py results/im7/jpeg.csv' using 3:1 title 'JPEG' with linespoints, \
     '<src/average.py results/im7/avif.csv' using 3:1 title 'AVIF' with linespoints

set title sprintf("Average Size vs Average Score (ImageMagick)\n{/*0.8 %s}", VERSIONS)
set key title "Format"
set ylabel "Size (bytes)"
set xlabel "Score (ssimulacra2 v2.1)"
# Move legend to bottom right so it doesn't overlap graph
set key left top
set output "results/im7/size-vs-score.png"

# Plot scores (1) against sizes (2)
plot '<src/average.py results/im7/webp.csv' using 1:2 title 'WebP' with linespoints, \
     '<src/average.py results/im7/jpeg.csv' using 1:2 title 'JPEG' with linespoints, \
     '<src/average.py results/im7/avif.csv' using 1:2 title 'AVIF' with linespoints
