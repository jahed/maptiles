#!/usr/bin/env bash

source="${1}"
dest_path="${2}"
tile_format="${3}"

if [ ! -f ${source} ] || [ -z ${dest_path} ]; then
  echo "Usage: ${0} SOURCE_IMAGE TILES_DESTINATION_DIR [TILE_FORMAT]"
  echo
  echo "SOURCE_IMAGE must exist."
  echo "TILE_FORMAT defaults to SOURCE_IMAGE extension."
  exit 1
fi

source_width=$(identify -format '%[w]' "${source}")
source_height=$(identify -format '%[h]' "${source}")
if [ "${source_width}" != "${source_height}" ]; then
  echo "SOURCE_IMAGE must be square (e.g. 1000x1000), but was ${source_width}x${source_height}."
  exit 1
fi

if [ -z ${tile_format} ]; then
  tile_format=$(identify -format '%[e]' "${source}")
fi

mkdir -p "${dest_path}"
tile_size=256

for ((zoom=0, resize=0; resize < source_width; zoom++)); do
  dimensions=$((2 ** ${zoom}))
  resize=$((${tile_size} * ${dimensions}))

  zoom_dir="${dest_path}/${zoom}"
  echo "Generating tiles for ${zoom_dir}"
  mkdir "${zoom_dir}"

  convert "${source}" \
    -colorspace RGB \
    -filter Lanczos2 \
    -background none \
    -resize "${resize}x${resize}" \
    -colorspace sRGB \
    -crop "${tile_size}x${tile_size}" \
    -set filename:tile "%[fx:page.x/${tile_size}]_%[fx:page.y/${tile_size}]" \
    +repage \
    +adjoin \
    "${dest_path}/${zoom}/tile_%[filename:tile].${tile_format}"
done
