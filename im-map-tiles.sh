#!/usr/bin/env bash

source="${1}"
dest_path="${2}"
tile_format="${3}"

if [ ! -f ${source} ] || [ -z ${dest_path} ]; then
    echo "Usage: ${0} SOURCE_IMAGE TILES_DESTINATION_DIR [TILE_FORMAT]"
    echo
    echo "SOURCE_IMAGE must exist."
    echo "TILE_FORMAT defaults to 'png'."
    exit 1
fi

if [ ! -d ${dest_path} ]; then
    mkdir ${dest_path}
fi

if [ -z ${tile_format} ]; then
    tile_format='png'
fi

original_size=$(identify ${source} | cut -d' ' -f3 | cut -d'x' -f1)
if [ -z ${original_size} ]; then
    echo "Could not retrieve image dimensions."
    exit 1
fi

tile_size=256
set -x

for ((zoom=0, resize=0; resize < original_size; zoom++)); do
    dimensions=$((2 ** ${zoom}))
	resize=$((${tile_size} * ${dimensions}))

    if [ -d ${dest_path}/${zoom} ]; then
        echo "Zoom ${zoom} directory already exists. Skipping."
        continue
    fi

    echo "Generating tiles for Zoom ${zoom}"
	mkdir ${dest_path}/${zoom}

	convert ${source} \
	    -colorspace RGB \
	    -filter Lanczos2 \
	    -background none \
	    -resize ${resize}x${resize} \
	    -colorspace sRGB \
	    -crop ${tile_size}x${tile_size} \
	    -set filename:tile "%[fx:page.x/${tile_size}]_%[fx:page.y/${tile_size}]" \
	    +repage \
        +adjoin \
        "${dest_path}/${zoom}/tile_%[filename:tile].${tile_format}"
done
