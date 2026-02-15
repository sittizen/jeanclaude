#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./run.sh --action <shell|publish|deploy> [--path <host_path>]

Examples:
  ./run.sh --action shell --path /home/user/workspace/my_project
  ./run.sh --action publish
  ./run.sh --action deploy
EOF
}

ACTION=""
HOST_PATH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --action)
      [[ $# -lt 2 ]] && { echo "Error: --action requires a value." >&2; usage; exit 1; }
      ACTION="$2"
      shift 2
      ;;
    --path)
      [[ $# -lt 2 ]] && { echo "Error: --path requires a value." >&2; usage; exit 1; }
      HOST_PATH="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Error: Unknown argument '$1'." >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$ACTION" ]]; then
  echo "Error: --action is required." >&2
  usage
  exit 1
fi

case "$ACTION" in
  shell)
    if [[ -z "$HOST_PATH" ]]; then
      echo "Error: --path is required for --action shell." >&2
      exit 1
    fi

    if [[ ! -d "$HOST_PATH" ]]; then
      echo "Error: Path '$HOST_PATH' is not a directory." >&2
      exit 1
    fi

    ABS_HOST_PATH="$(realpath "$HOST_PATH")"
    PROJECT_NAME="$(basename "$ABS_HOST_PATH")"
    CONTAINER_PATH="/workspace"
    PYPROJECT_FILE="$ABS_HOST_PATH/pyproject.toml"

    if [[ ! -f "$PYPROJECT_FILE" ]]; then
      echo "Error: '$PYPROJECT_FILE' not found. Expected a uv-based Python project." >&2
      exit 1
    fi

    if ! grep -Eq '^\[tool\.uv(\..*)?\]' "$PYPROJECT_FILE"; then
      echo "Error: '$PYPROJECT_FILE' does not contain a [tool.uv] configuration section." >&2
      exit 1
    fi

    IMAGE_TAG="local/jeanclaude-$ACTION"

    docker build -t "$IMAGE_TAG" .
    docker run --rm -it \
      -v "$ABS_HOST_PATH:$CONTAINER_PATH" \
      -w "$CONTAINER_PATH" \
      "$IMAGE_TAG" zsh
    ;;

  publish)
    echo "publish action placeholder (not implemented yet)"
    ;;

  deploy)
    echo "deploy action placeholder (not implemented yet)"
    ;;

  *)
    echo "Error: Invalid action '$ACTION'. Expected one of: shell, publish, deploy." >&2
    exit 1
    ;;
esac
