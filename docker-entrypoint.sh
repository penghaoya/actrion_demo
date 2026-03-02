#!/usr/bin/env bash
set -euo pipefail

script_path="${GRIDPREDICT_SCRIPT:-${APP_HOME}/HSQX.py}"
config_path="${GRIDPREDICT_CONFIG:-${APP_HOME}/HSQX_Input.json}"

if [[ ! -f "${script_path}" ]]; then
  echo "Missing script: ${script_path}" >&2
  echo "Mount your project directory into ${APP_HOME} (for example: -v \$(pwd)/GridPredict_OceanMeteo:${APP_HOME})" >&2
  exit 1
fi

if [[ $# -eq 0 ]]; then
  if [[ ! -f "${config_path}" ]]; then
    echo "Missing config: ${config_path}" >&2
    echo "Mount your project directory into ${APP_HOME} or pass a config path explicitly." >&2
    exit 1
  fi
  set -- "${config_path}"
fi

exec python "${script_path}" "$@"
