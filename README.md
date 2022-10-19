# Improving DSpace PDF Thumbnails
DSpace can be [configured](https://wiki.lyrasis.org/display/DSDOC6x/Mediafilters+for+Transforming+DSpace+Content) to use ImageMagick to generate thumbnails for PDF bitstreams. Out of the box the quality of these thumbnails is underwhelming because the resolution is low and the image is often blurry. The quality can be improved by increasing the resolution and applying an <em><a href="https://imagemagick.org/Usage/blur/#unsharp">unsharp mask</a></em> filter after resizing the image. This minor change has the effect of <em>sharpening</em> the resulting image, which is especially noticeable if the image contains text.

I propose adding the `-unsharp 0.5` parameter to the DSpace ImageMagick thumbnail operation in DSpace 6.x and 7.x.

## Example
A comparison of the default DSpace thumbnail for an item on the CGSpace repository before and after adding `-unsharp 0.5`.

<p align="center">
  <img width="300" alt="Default DSpace thumbnail for 10568/71249" src="img/10568-71249-dspace.jpg">
  <img width="300" alt="Default DSpace thumbnail for 10568/71249 with unsharp" src="img/10568-71249-dspace-unsharp.jpg">
</p>

See more in-depth comparisons here: https://alanorth.github.io/improved-dspace-thumbnails/

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
