#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "${0}")/.."
output_dir="$(mktemp -d -t maptiles-tests-outputs-XXX)"
input_dir="${output_dir}/input"
mkdir "${input_dir}"

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

function assert_not_dir {
  if [ -d "${output_dir}/${1}" ]; then
    echo "Directory should not exist."
    exit 1
  fi
}

function assert_failure {
  set +e
  ${@}
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

echo "RUNNING TESTS"
echo "  Outputs: ${output_dir}"

echo
echo 'TEST: Generates map tiles.'
./maptiles "${input_dir}/512x512.png" "${output_dir}/basic"
assert_dir basic

echo
echo 'TEST: Squares source image.'
./maptiles "${input_dir}/250x500.png" --square "${output_dir}/square"
assert_dir square

echo
echo 'TEST: Optimises map tiles.'
./maptiles "${input_dir}/512x512.png" --optimise "lossy" "${output_dir}/optimise"
assert_dir optimise

echo
echo 'TEST: Upscales source image.'
./maptiles "${input_dir}/500x500.png" "${output_dir}/scaleup"
assert_dir scaleup

echo
echo 'TEST: Generates using given format.'
./maptiles "${input_dir}/512x512.png" --format jpg "${output_dir}/format"
assert_dir format

echo
echo 'TEST: Sets background color.'
./maptiles "${input_dir}/512x512.png" --background 'red' --format jpg "${output_dir}/background"
assert_dir background

echo
echo 'TEST: Generates json.'
./maptiles "${input_dir}/512x512.png" --json '{b}/' "${output_dir}/json"
assert_dir json

echo
echo 'TEST: Rejects non-existing source image.'
assert_failure ./maptiles "${input_dir}/doesnotexist.png" "${output_dir}/doesnotexist"
assert_not_dir doesnotexist

echo
echo 'TEST: Rejects existing destination directory.'
mkdir "${output_dir}/exists"
assert_failure ./maptiles "${input_dir}/512x512.png" "${output_dir}/exists"

echo
echo 'TEST: Rejects non-square source image.'
assert_failure ./maptiles "${input_dir}/250x500.png" "${output_dir}/nonsquare"
assert_not_dir nonsquare

echo
echo 'TEST: Rejects missing arguments.'
assert_failure ./maptiles

echo
echo 'TEST: Rejects unknown arguments.'
assert_failure ./maptiles "${input_dir}/512x512.png" "${output_dir}/unknown" --unknown
assert_not_dir unknown

echo
echo 'All tests passed.'
