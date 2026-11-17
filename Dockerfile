FROM erikvl87/languagetool:6.8
# https://github.com/Erikvl87/docker-languagetool

ENV REVIEWDOG_VERSION=v0.21.0
ENV TMPL_VERSION=v1.2.0
ENV OFFSET_VERSION=v1.0.6
ENV LANGUAGETOOL_VERSION=5.2
ENV GHGLOB_VERSION=v2.0.2

USER root

SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

# hadolint ignore=DL3006
RUN apk --no-cache add git curl

RUN wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/fd59714416d6d9a1c0692d872e38e7f8448df4fc/install.sh| sh -s -- -b /usr/local/bin/ ${REVIEWDOG_VERSION} && \
  wget -O - -q https://raw.githubusercontent.com/haya14busa/tmpl/0f3ab9222c8445feb80db1783e630a8b2526a285/install.sh| sh -s -- -b /usr/local/bin/ ${TMPL_VERSION} && \
  wget -O - -q https://raw.githubusercontent.com/haya14busa/offset/672ac5ecc5cae667caa8b46cead9ad822a07278b/install.sh| sh -s -- -b /usr/local/bin/ ${OFFSET_VERSION} && \
  wget -O - -q https://raw.githubusercontent.com/haya14busa/ghglob/c28f127bd85ea42b4ef62381bd7a9861ffb1b785/install.sh| sh -s -- -b /usr/local/bin/ ${GHGLOB_VERSION}

COPY entrypoint.sh /entrypoint.sh
COPY langtool.tmpl /langtool.tmpl

ENTRYPOINT ["/entrypoint.sh"]
