#!/bin/bash
set -e

install -v -m 600 files/tailscale.conf "${STAGE_WORK_DIR}/${IMG_NAME}/boot/"
