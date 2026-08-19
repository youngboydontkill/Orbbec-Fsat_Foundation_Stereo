#!/usr/bin/env bash
set -e

source /opt/ros/noetic/setup.bash
if [[ -f /root/gemini_ws/devel/setup.bash ]]; then
  source /root/gemini_ws/devel/setup.bash
fi

exec "$@"
