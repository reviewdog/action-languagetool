FROM erikvl87/languagetool:6.5
# https://github.com/Erikvl87/docker-languagetool

ENV REVIEWDOG_VERSION=v0.20.3
ENV TMPL_VERSION=v1.2.0
ENV OFFSET_VERSION=v1.0.6
ENV LANGUAGETOOL_VERSION=5.2
ENV GHGLOB_VERSION=v2.0.2

USER root

SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

# hadolint ignore=DL3006
RUN apk --no-cache add git curl bash

RUN wget -O - -q https://raw.githubusercontent.com/reviewdog/reviewdog/fd59714416d6d9a1c0692d872e38e7f8448df4fc/install.sh| sh -s -- -b /usr/local/bin/ ${REVIEWDOG_VERSION} && \
  wget -O - -q https://raw.githubusercontent.com/haya14busa/tmpl/master/install.sh| sh -s -- -b /usr/local/bin/ ${TMPL_VERSION} && \
  wget -O - -q https://raw.githubusercontent.com/haya14busa/offset/master/install.sh| sh -s -- -b /usr/local/bin/ ${OFFSET_VERSION} && \
  wget -O - -q https://raw.githubusercontent.com/haya14busa/ghglob/master/install.sh| sh -s -- -b /usr/local/bin/ ${GHGLOB_VERSION}

COPY entrypoint.sh /entrypoint.sh
COPY langtool.tmpl /langtool.tmpl

# files for bitbucket pipe
COPY pipe.yml /
RUN wget -P / https://bitbucket.org/bitbucketpipelines/bitbucket-pipes-toolkit-bash/raw/0.6.0/common.sh

ENTRYPOINT ["/entrypoint.sh"]
