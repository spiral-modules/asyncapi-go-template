# syntax=docker/dockerfile:1.2

FROM node:19-alpine as builder

# install gofmt
COPY --from=golang:1.19 /usr/local/go/bin/gofmt /usr/local/bin/gofmt

ENV \
    # Generator releases: <https://github.com/asyncapi/generator/releases>
    GENERATOR_VERSION="1.9.14" \
    # Template releases: <https://github.com/asyncapi/markdown-template/releases>
    MD_TEMPLATE_VERSION="1.2.1" \
    # Template releases: <https://github.com/asyncapi/html-template/releases>
    HTML_TEMPLATE_VERSION="0.28.1" \
    # additional NPM options
    NPM_CONFIG_UPDATE_NOTIFIER=false \
    NPM_CONFIG_AUDIT=false

# install generator & other dependencies
RUN set -x \
    && apk add --no-cache git \
    && npm install -g \
      "@asyncapi/generator@${GENERATOR_VERSION}" \
      "@asyncapi/markdown-template@${MD_TEMPLATE_VERSION}" \
      "@asyncapi/html-template@${HTML_TEMPLATE_VERSION}" \
    # cleanup
    && find /usr/local/lib/node_modules -type f \( -name "*.map" -o -name "*.md" -o -name "LICENSE*" \) -delete \
    && npm cache clean --force \
    # create temporary directories
    && for dir in /usr/local/lib/node_modules/@asyncapi/*; do \
      mkdir --mode=777 -- "${dir}/__transpiled"; \
    done \
    # verify installation
    && ag --version

# install custom generator templates
COPY . /usr/local/lib/node_modules/@spiral/asyncapi-go-template

RUN set -x \
    && for dir in /usr/local/lib/node_modules/@spiral/*; do \
      mkdir --mode=777 -- "${dir}/__transpiled" \
      && npm install --prefix "${dir}" \
      && find "${dir}/node_modules" -type f \( -name "*.map" -o -name "*.md" -o -name "LICENSE*" \) -delete; \
    done \
    && npm cache clean --force

LABEL \
    org.opencontainers.image.title="asyncapi-go-template" \
    org.opencontainers.image.description="AsyncAPI Go template" \
    org.opencontainers.image.url="https://github.com/spiral/asyncapi-go-template" \
    org.opencontainers.image.source="https://github.com/spiral/asyncapi-go-template" \
    org.opencontainers.image.vendor="SpiralScout" \
    org.opencontainers.image.licenses="MIT"

# use an unprivileged user by default
USER node:node

# override/unset default entrypoint & cmd
ENTRYPOINT ["ag"]
CMD []
