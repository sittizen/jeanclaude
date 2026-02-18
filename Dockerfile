FROM astral/uv:alpine

RUN apk add --no-cache zsh build-base curl python3 py3-tomlkit bash
RUN uv tool install poethepoet
RUN curl -fsSL https://opencode.ai/install | bash && mv /root/.opencode /opt && apk del bash

COPY files/ /

ENV HOME=/workspace \
    PYTHONPATH=/workspace/src \
    UV_PROJECT_ENVIRONMENT=/workspace/.venv

WORKDIR /workspace

