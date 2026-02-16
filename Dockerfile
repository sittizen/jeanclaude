FROM astral/uv:alpine

RUN apk add zsh build-base python3

COPY files/ /

ENV HOME=/workspace \
    UV_PROJECT_ENVIRONMENT=/workspace/.venv

WORKDIR /workspace

