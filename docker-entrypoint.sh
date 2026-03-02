#!/usr/bin/env bash
set -euo pipefail

if [[ $# -eq 0 ]]; then
  set -- "${APP_HOME}/HSQX_Input.json"
fi

exec python "${APP_HOME}/HSQX.py" "$@"
