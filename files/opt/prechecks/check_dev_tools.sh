#!/usr/bin/env zsh

set -euo pipefail

DEV_TOOLS_FILE="/opt/prechecks/dev_tools.md"

if [[ ! -f "${DEV_TOOLS_FILE}" ]]; then
  echo "Error: ${DEV_TOOLS_FILE} not found." >&2
  exit 1
fi

if ! command -v uv >/dev/null 2>&1; then
  echo "Error: uv is not installed or not on PATH." >&2
  exit 1
fi

if ! UV_TREE_OUTPUT="$(cd /workspace && uv tree --group dev 2>&1 | grep dev)"; then
  echo "Error: failed to run 'uv tree --group dev'." >&2
  echo "${UV_TREE_OUTPUT}" >&2
  exit 1
fi

declare -A expected_versions
while IFS= read -r line; do
  line="${line%%#*}"
  line="${line//$'\r'/}"
  line="${line#${line%%[![:space:]]*}}"
  line="${line%${line##*[![:space:]]}}"

  [[ -z "${line}" ]] && continue

  if [[ "${line}" =~ ^([A-Za-z0-9._-]+)==([^[:space:]]+)$ ]]; then
    name="${match[1]:l}"
    name="${name//\"/}"
    name="${name//\'/}"
    version="${match[2]}"
    expected_versions["${name}"]="${version}"
  else
    echo "Error: invalid line in ${DEV_TOOLS_FILE}: '${line}' (expected name==version)." >&2
    exit 1
  fi
done < "${DEV_TOOLS_FILE}"

declare -A found_versions
while IFS= read -r line; do
  if [[ "${line}" =~ ^[[:space:]│├└─-]*\"?([A-Za-z0-9._-]+)\"?[[:space:]]+v([^[:space:]]+) ]]; then
    name="${match[1]:l}"
    name="${name//\"/}"
    name="${name//\'/}"
    version="${match[2]}"
    found_versions["${name}"]="${version}"
  fi
done <<< "${UV_TREE_OUTPUT}"

if [[ ${#found_versions[@]} -eq 0 ]]; then
  echo "Error: no packages were parsed from 'uv tree --group dev' output." >&2
  echo "Raw output:" >&2
  echo "${UV_TREE_OUTPUT}" >&2
  exit 1
fi


errors=0
echo "Found dev packages from toolchain:"
for name in ${(k)found_versions}; do
  actual_version="${found_versions[$name]}"

  if (( ! ${+expected_versions[$name]} )); then
    echo "Error: package '${name}' (version ${actual_version}) is not listed in dev_tools.md." >&2
    errors=1
    continue
  fi

  expected_version="${expected_versions[$name]}"
  clean_name="${name//\"/}"
  echo "${clean_name}"
  if [[ "${actual_version}" != "${expected_version}" ]]; then
    echo "Fixing: package '${name}' has version ${actual_version} but dev_tools.md specifies ${expected_version}." >&2
    clean_expected_version="${expected_version//\"/}"
    clean_expected_version="${clean_expected_version//\'/}"
    package_spec="${clean_name}==${clean_expected_version}"
    echo "${package_spec}"
    if ! uv add --group dev "${package_spec}"; then
      errors=1
    fi
  fi
done

for name in ${(k)expected_versions}; do
  if (( ! ${+found_versions[$name]} )); then
    echo "Fixing: package '${name}' is listed in dev_tools.md but missing from project." >&2
    clean_name="${name//\"/}"
    clean_name="${clean_name//\'/}"
    expected_version="${expected_versions[$name]}"
    clean_expected_version="${expected_version//\"/}"
    clean_expected_version="${clean_expected_version//\'/}"
    package_spec="${clean_name}==${clean_expected_version}"
    echo "${package_spec}"
    if ! uv add --group dev "${package_spec}"; then
      errors=1
    fi
  fi
done

if [[ ${errors} -ne 0 ]]; then
  echo "WARNING: dev packages must be fixed manually."
  exit 1
fi

echo "pyproject.toml already in sync"
