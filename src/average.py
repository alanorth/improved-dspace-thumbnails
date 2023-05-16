#!/usr/bin/env python3

import sys
import pandas as pd

df = pd.read_csv(sys.argv[1], usecols=['score', 'size', 'quality'])

# get qualities using a groupby
for q in df.groupby(by="quality").indices:
    average_score = df.query("quality == @q")['score'].mean()
    average_size = df.query("quality == @q")['size'].mean()

    # To calculate the bits per pixel we need to know how many pixels the image
    # has! Unfortunately we need to use an average here because the widths are
    # not the same (heights are all 800 pixels in my sample data). I used this
    # one liner to get the average width (assumes thirty-five samples):
    #
    #   $ widths=$(identify -format '%w\n' img/im7/*.pdf.png | paste -sd+ | bc); echo "$widths / 35" | bc
    #   578
    #
    average_bpp = (average_size * 8) / (578 * 800)

    print(f"{average_score},{average_size},{average_bpp},{q}")
