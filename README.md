# im-map-tiles

[![Patreon](https://img.shields.io/badge/patreon-donate-f96854.svg)](https://www.patreon.com/jahed)
[![Liberapay](https://img.shields.io/badge/liberapay-donate-d9b113.svg)](https://liberapay.com/jahed)
[![PayPal](https://img.shields.io/badge/paypal-donate-009cde.svg)](https://paypal.me/jahed/5)

Converts an image to map tiles to be used in Google Maps, Leaflet and other map
rendering software.

## Usage

```
$ ./im-map-tiles.sh --help
NAME
  im-map-tiles - Converts an image to map tiles

SYNOPSIS
  ./im-map-tiles.sh <input_image> [<options>] <output_directory>

DESCRIPTION
  Converts an image to map tiles to be used in Google Maps, Leaflet and other
  map rendering software.

  Version:   v1.0.0
  Homepage:  https://github.com/jahed/im-map-tiles
  Donate:    https://jahed.dev/donate

OPTIONS
  <input_image>
    Image to convert into tiles. Must exist. Must be square.

  <output_directory>
    Output directory. Must NOT exist, to avoid polluting existing directories.

  -f, --format <format>
    Tile format (e.g. 'png'). Defaults to <input_image> file extension.

  -b, --background <background>
    Can be any ImageMagick-compatible colour. Defaults to 'none' (transparent).
    See: https://imagemagick.org/script/color.php

  -o, --optimise (lossy|lossless)
    Optimises tiles depending on the <format>.

    png uses pngquant (lossy) or optipng (lossless)
    jpg uses jpegtran (lossless)

    Lossy optimisations may cause a size increase depending on each tile's
    complexity. Only use it for maps which store a lot of detail per tile.

  -s, --square
    Converts a non-square <input_image> into a square one, using whichever
    dimension is largest and centering the image.

  -h, --help
    Prints this help message.

  --version
    Prints the version.

OUTPUT
  Tiles in the <output_directory> will take the format of:
  <output_directory>/{zoom_level}/tile_{x}_{y}.<format>

  {zoom_level} will start at 0 and go up to the maximum zoom possible for the
  <input_image> rounding up to the next zoom level. An <input_image> with
  dimensions 2048x2048 will go up to 4 whereas an image with 3000x3000 will go
  up to 5. This is done to make the most out of the level of detail in the image
  without enlargening too much.

  Each tile has a dimension of 256x256 and each {zoom_level} goes up in
  dimensions of 2 to the power of {zoom_level} (i.e. 1x1, 2x2, 4x4, 8x8, etc.).
  So overall, for each zoom level, the resulting map resolution will be 256x256,
  512x512, 1024x1024, 2048x2048 and so on.

  If you're using Leaflet, I suggest you set this maximum zoom as your
  map.maxNativeZoom so you can have higher zoom levels without the need to
  download larger, low quality, upscaled tiles.

EXAMPLES
  Take a detailed image and create optimised tiles to save space.
    ./im-map-tiles.sh detailed_map.png --optimise lossy ./tiles

  Take an rectangular image, square it with a red background and output it as
  JPG tiles.
    ./im-map-tiles.sh map.png --square --format jpg --background #ff0000 ./tiles

DEPENDENCIES
  Required
    ImageMagick  https://www.imagemagick.org
    Bash         https://en.wikipedia.org/wiki/Bash_%28Unix_shell%29

  Optional
    pngquant    https://pngquant.org/
    optipng     http://optipng.sourceforge.net/
    jpegtran    https://jpegclub.org/jpegtran/

COPYRIGHT
  The MIT License (MIT)
  Copyright (c) 2020 Jahed Ahmed
```

## License

[MIT](LICENSE)
