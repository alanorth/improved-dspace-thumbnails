# Improving DSpace PDF Thumbnails
DSpace can be [configured](https://wiki.lyrasis.org/display/DSDOC6x/Mediafilters+for+Transforming+DSpace+Content) to use ImageMagick to generate thumbnails for PDF bitstreams. Out of the box the quality of these thumbnails is underwhelming because the resolution is low and the image is often blurry. The quality can be improved by using a "supersampling" technique and by preferring the PDF `CropBox` over the `MediaBox` where possible. These two minor changes produce an image that more accurately resembles what the user would see if they opened the PDF on a screen, which is especially noticeable if the PDF contains text, gradients, or curved lines.

I propose adding the `-density 144` and `-define pdf:use-cropbox=true` parameters to the DSpace ImageMagick PDF thumbnail operation in DSpace 6.x and 7.x.

## Example
A comparison of the default DSpace PDF thumbnail for an item on the CGSpace repository before and after adding the `-density 144` parameter.

<p align="center">
  <img width="300" alt="Default DSpace thumbnail for 10568/3149" src="img/10568-3149-dspace.jpg">
  <img width="300" alt="Default DSpace thumbnail for 10568/3149 with density 144" src="img/10568-3149-improved.jpg">
</p>

See more in-depth discussion and comparisons here: https://alanorth.github.io/improved-dspace-thumbnails/

## License

>Copyright (C) 2022 Alan Orth
>
>This program is free software: you can redistribute it and/or modify
>it under the terms of the GNU General Public License as published by
>the Free Software Foundation, either version 3 of the License, or
>(at your option) any later version.
>
>This program is distributed in the hope that it will be useful,
>but WITHOUT ANY WARRANTY; without even the implied warranty of
>MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
>GNU General Public License for more details.
>
>You should have received a copy of the GNU General Public License
>along with this program.  If not, see <http://www.gnu.org/licenses/>.

This repository contains code from the [image-compare-viewer](https://github.com/kylewetton/image-compare-viewer) and [sakura](https://github.com/oxalorg/sakura) projects, both of which are licensed under the MIT license.
