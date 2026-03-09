FROM astral/uv:alpine
#FROM debian:bookworm-slim


COPY files/usr /usr
RUN apk add --no-cache zsh build-base cmake sudo curl jq git tar ripgrep python3 py3-tomlkit ca-certificates openldap-dev unixodbc-dev openssl-dev zlib-dev \
    && curl https://releases.hashicorp.com/vault/1.21.4/vault_1.21.4_linux_amd64.zip --output vault.zip \
    && unzip vault.zip && mv vault /usr/bin/ && rm vault.zip LICENSE.txt \
    && update-ca-certificates \
    && uv tool install poethepoet && mv /root/.local/share/uv/tools/poethepoet /opt \
    && sed -i '1c\#!/opt/poethepoet/bin/python' /opt/poethepoet/bin/poe

WORKDIR /app

RUN chmod 666 /etc/passwd

COPY files/ /
ENV HOME=/app \
    PYTHONPATH=/app/src \
    UV_PROJECT_ENVIRONMENT=/app/.venv \
    UV_NATIVE_TLS=true
