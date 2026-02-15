FROM astral/uv:alpine

RUN apk add zsh build-base

COPY files/ /

ENV HOME=/workspace \
    UV_PROJECT_ENVIRONMENT=/workspace/.venv

WORKDIR /workspace

