# im-map-tiles

Map Tile Generator for Google Maps, Leaflet and other Map libraries using ImageMagick.

[![Discord Chat](https://img.shields.io/badge/discord-chat-7289da.svg)](https://discord.gg/crmfAsJ)
[![Patreon](https://img.shields.io/badge/patreon-donate-f96854.svg)](https://www.patreon.com/jahed)

## Dependencies

- [ImageMagick](https://www.imagemagick.org)
- [Bash](https://en.wikipedia.org/wiki/Bash_%28Unix_shell%29)

## Usage

```sh
$ ./im-map-tiles.sh 
Usage: ./im-map-tiles.sh SOURCE_IMAGE TILES_DESTINATION_DIR [TILE_FORMAT]

SOURCE_IMAGE must exist.
TILE_FORMAT defaults to 'png'.
```

Output will take the format of:

```
${TILES_DESTINATION_DIR}/${ZOOM_LEVEL}/tile_${X}_${Y}.${TILE_FORMAT}
```

e.g.

```
./tiles/1/tile_0_1.png
./tiles/3/tile_2_3.png
./tiles/5/tile_2_3.png
...
```

`${ZOOM_LEVEL}` will start at `0` and go up to the maximum zoom possible for the `${SOURCE_IMAGE}` rounding up to the next zoom
level. A `${SOURCE_IMAGE}` with dimensions 2048x2048 will go up to `4` whereas an image with 3000x3000 will go up to `5`. This
is done to make the most out of the level of detail in the image without enlargening too much.

Each `tile` has a dimension of 256x256 and each `${ZOOM_LEVEL}` goes up in dimensions of `2^${ZOOM_LEVEL}` (i.e. 1x1, 2x2, 4x4,
8x8, 16x16 etc.). So overall, for each zoom level, the resulting map resolution will be 256x256, 512x512, 1024x1024, 2048x2048
and so on.

If you're using Leaflet, I suggest you set this maximum zoom as your `map.maxNativeZoom` so you can have higher zoom levels
without the need to download larger, low quality, upscaled tiles.

If a `${ZOOM_LEVEL}` directory already exists, it will be skipped.

## FAQ

### Is Graphics Magick supported?

While I would've preferred using Graphics Magick for this script, it does not support the syntax used to generate the filename of each tile (tile_1_2.png, tile_2_3.png, etc.).

Graphics Magick does support iterative names (tile_01.png, tile_02.png, etc.), which could be calculated using known X/Y coordinates but that's not typically how map tiles are named. Following this approach however, an alternative is to rename the tiles after they're generated, but that's just more work for something Image Magick does for free.

The aim for this script is to be as simple as possible so feel free to modify it to your specific use cases.

## License

[MIT](LICENSE)
