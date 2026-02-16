FROM astral/uv:alpine

RUN apk add --no-cache zsh build-base python3 py3-tomlkit

COPY files/ /

ENV HOME=/workspace \
    UV_PROJECT_ENVIRONMENT=/workspace/.venv

WORKDIR /workspace

