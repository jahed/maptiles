# im-map-tiles

Map Tile Generator for Google Maps, Leaflet and other Map libraries using ImageMagick.

## Dependencies

- ImageMagick

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

## License

See `LICENSE` file.
