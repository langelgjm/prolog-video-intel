#!/bin/bash

TEMP_DIR=$(mktemp -d /tmp/thumbnails-XXXX) && \
ffmpeg -ss ${2} -i "${1}" -to ${3} -vf fps=1 ${TEMP_DIR}/tmp_%02d.jpg && \
THUMBNAILS=$(mktemp -u thumbnails-XXXX) && \
montage ${TEMP_DIR}/tmp_??.jpg -geometry 320x -geometry +1+1 ${THUMBNAILS}.jpg && \
rm -rf ${TEMP_DIR} && \
echo ${THUMBNAILS}.jpg