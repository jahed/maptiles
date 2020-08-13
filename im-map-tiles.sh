#!/usr/bin/env bash

function print_help {
  cat <<EOF
NAME
  im-map-tiles - Converts an image to map tiles

SYNOPSIS
  ${0} <input_image> [<options>] <output_directory>

DESCRIPTION
  Converts an image to map tiles to be used in Google Maps, Leaflet and other
  map rendering software.

  For more information, visit: https://github.com/jahed/im-map-tiles

OPTIONS
  <input_image>
    Image to convert into tiles. Must exist. Must be square.

  <output_directory>
    Output directory. Must NOT exist, to avoid polluting existing directories.

  -f, --format <format>
    Tile format (e.g. 'png'). Defaults to <input_image> file extension.

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
EOF
}

function failure {
  echo "error:        ${1}"
  echo "for help use: ${0} --help"
  exit 1
}

POSITIONAL=()
while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    -h|--help)
      print_help
      exit 0
      ;;
    -f|--format)
      format="$2"
      shift
      shift
      ;;
    -o|--optimise)
      optimise="$2"
      shift
      shift
      ;;
    -s|--square)
      square="true"
      shift
      ;;
    -*)
      failure "unknown argument $1"
      exit 1
    ;;
    *)
    POSITIONAL+=("$1")
    shift
    ;;
  esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

input_image="${1}"
output_directory="${2}"

if [ -z ${input_image} ] || [ ! -f ${input_image} ]; then
  failure "<input_image> must exist."
fi

if [ -z ${output_directory} ]; then
  failure "<output_directory> not given."
fi

if [ -d "${output_directory}" ] || [ -f "${output_directory}" ]; then
  failure "<output_directory> must not exist."
fi

if [ -z ${format} ]; then
  format=$(identify -format '%[e]' "${input_image}")
fi

square_image="${input_image}"
input_width=$(identify -format '%[w]' "${input_image}")
input_height=$(identify -format '%[h]' "${input_image}")
if [ "${input_width}" != "${input_height}" ]; then
  if [ ! -z ${square} ]; then
    echo "SQUARING"
    mkdir -p "${output_directory}"
    square_dim="$(identify -format "%[fx:max(w,h)]x%[fx:max(w,h)]+0+0" "${input_image}")"
    square_image="${output_directory}/square.png"
    convert "${input_image}" \
      -gravity center \
      -background none \
      -extent "${square_dim}" \
      +repage \
      "${square_image}"
    echo
  else
    failure "<input_image> must be square (e.g. 1000x1000), but was ${input_width}x${input_height}. Maybe use the --square option."
  fi
fi

echo "GENERATING"
mkdir -p "${output_directory}"
square_width=$(identify -format '%[w]' "${square_image}")
tile_size=256
for ((zoom_level=0, resize=0; resize < square_width; zoom_level++)); do
  dimensions=$((2 ** ${zoom_level}))
  resize=$((${tile_size} * ${dimensions}))

  zoom_dir="${output_directory}/${zoom_level}"
  echo "  ${zoom_dir}"
  mkdir "${zoom_dir}"

  convert "${square_image}" \
    -colorspace RGB \
    -filter Lanczos2 \
    -background none \
    -resize "${resize}x${resize}" \
    -colorspace sRGB \
    -crop "${tile_size}x${tile_size}" \
    -set filename:tile "%[fx:page.x/${tile_size}]_%[fx:page.y/${tile_size}]" \
    +repage \
    +adjoin \
    "${output_directory}/${zoom_level}/tile_%[filename:tile].${format}"
done
echo

if [ ! -z ${optimise} ]; then
  echo "OPTIMISING"
  if [[ "${format}" == "png" ]]; then
    if [[ "${optimise}" == "lossy" ]]; then
      find "${output_directory}" -type f -regex '.+\.png' -print0 | xargs -0 -L 1 -I % pngquant --speed 1 --ext '.png' --quiet --force '%'
    else
      find "${output_directory}" -type f -regex '.+\.png' -print0 | xargs -0 -L 1 -I % optipng -quiet -out '%' '%'
    fi
  elif [[ "${format}" == "jpg" ]]; then
    find "${output_directory}" -type f -regex '.+\.jpg' -print0 | xargs -0 -L 1 -I % jpegtran -optimize -copy none -progressive -outfile '%' '%'
  else
    echo "  No optimiser found for output format (${format})."
  fi
  echo
fi

cat <<EOF
RESULT
  Input Image:       ${input_image}
  Output Directory:  ${output_directory}
  Format:            ${format}
  Maximum Zoom:      $((${zoom_level} - 1))

Done.
EOF
