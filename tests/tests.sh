#!/usr/bin/env bash
set -euo pipefail

input_dir="$(mktemp -d -t im-map-tiles-tests-inputs-XXX)"
output_dir="$(mktemp -d -t im-map-tiles-tests-outputs-XXX)"

function list_dir {
  pushd "${output_dir}" &> /dev/null
  du -a "./${1}/" | sort -k 2
  popd &> /dev/null
}

function assert_dir {
  local result="$(list_dir "${1}")"
  local snapshot_file="./tests/snapshots/${1}.snapshot"
  if [ -f "${snapshot_file}" ]; then
    if ! echo "${result}" | diff --color "${snapshot_file}" -; then
        echo 'Result does not match snapshot.'
        exit 1
    fi
  else
    echo "${result}" > "${snapshot_file}"
    echo "Created snapshot ${snapshot_file}"
  fi
}

function assert_failure {
  set +e
  ${@} &> /dev/null
  local exit_code="${?}"
  set -e
  if [[ "${exit_code}" == "0" ]]; then
    echo 'Expected command to fail.'
    exit 1
  fi
}

function create_input {
  local dim="${1}"
  convert ./tests/original.png \
    -background none \
    -resize "${dim}" \
    -gravity center \
    -extent "${dim}" \
    "${input_dir}/${dim}.png"
}

create_input 512x512
create_input 500x500
create_input 250x500

rm -rf "${output_dir}"
mkdir "${output_dir}"

echo "Inputs: ${input_dir}"
echo "Outputs: ${output_dir}"

echo 'Test Case: Generates map tiles.'
./im-map-tiles.sh "${input_dir}/512x512.png" "${output_dir}/basic" &> /dev/null
assert_dir basic

echo 'Test Case: Upscales source image.'
./im-map-tiles.sh "${input_dir}/500x500.png" "${output_dir}/scaleup" &> /dev/null
assert_dir scaleup

echo 'Test Case: Generates using given format.'
./im-map-tiles.sh "${input_dir}/512x512.png" "${output_dir}/format" jpg &> /dev/null
assert_dir format

echo 'Test Case: Rejects non-existing source image.'
assert_failure ./im-map-tiles.sh "${input_dir}/doesnotexist.png" "${output_dir}/doesnotexist"
if [ -d "${output_dir}/doesnotexist" ]; then
  echo "Output directory should not exist."
  exit 1
fi

echo 'Test Case: Rejects existing destination directory.'
mkdir "${output_dir}/exists"
assert_failure ./im-map-tiles.sh "${input_dir}/512x512.png" "${output_dir}/exists"

echo 'Test Case: Rejects non-square source image.'
assert_failure ./im-map-tiles.sh "${input_dir}/250x500.png" "${output_dir}/nonsquare"
if [ -d "${output_dir}/nonsquare" ]; then
  echo "Output directory should not exist."
  exit 1
fi

echo 'Tests passed.'