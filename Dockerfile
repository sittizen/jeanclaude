FROM astral/uv:alpine

RUN apk add --no-cache zsh build-base curl python3 py3-tomlkit bash sudo git tar ripgrep
RUN uv tool install poethepoet
RUN curl -fsSL https://opencode.ai/install | bash && mv /root/.opencode /opt && apk del bash

RUN adduser -D jeanclaude && \
    addgroup jeanclaude wheel && \
    echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
USER jeanclaude
WORKDIR /workspace

RUN mkdir -p /workspace/.local/share/opencode && chown -R jeanclaude: /workspace/.local/share/opencode
RUN mkdir -p /workspace/.config/opencode && chown -R jeanclaude: /workspace/.config/opencode

COPY files/ /

ENV HOME=/workspace \
    PYTHONPATH=/workspace/src \
    UV_PROJECT_ENVIRONMENT=/workspace/.venv


