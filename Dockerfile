FROM erikvl87/languagetool:5.3
# https://github.com/Erikvl87/docker-languagetool

ENV REVIEWDOG_VERSION=v0.11.0
ENV TMPL_VERSION=v1.2.0
ENV OFFSET_VERSION=v1.0.6
ENV LANGUAGETOOL_VERSION=5.2
ENV GHGLOB_VERSION=v2.0.2

USER root

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

# hadolint ignore=DL3006
RUN apk --no-cache add git curl

RUN wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh| sh -s -- -b /usr/local/bin/ ${REVIEWDOG_VERSION} && \
  wget -O - -q https://raw.githubusercontent.com/haya14busa/tmpl/master/install.sh| sh -s -- -b /usr/local/bin/ ${TMPL_VERSION} && \
  wget -O - -q https://raw.githubusercontent.com/haya14busa/offset/master/install.sh| sh -s -- -b /usr/local/bin/ ${OFFSET_VERSION} && \
  wget -O - -q https://raw.githubusercontent.com/haya14busa/ghglob/master/install.sh| sh -s -- -b /usr/local/bin/ ${GHGLOB_VERSION}

COPY entrypoint.sh /entrypoint.sh
COPY langtool.tmpl /langtool.tmpl

ENTRYPOINT ["/entrypoint.sh"]
