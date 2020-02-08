#!/bin/sh
set -e

ls /

java -cp /LanguageTool-${LANGUAGETOOL_VERSION}/languagetool-server.jar org.languagetool.server.HTTPServer --port 8010
curl --data "language=en-US&text=a simple test" http://localhost:8010/v2/check

if [ -n "${GITHUB_WORKSPACE}" ]; then
  cd "${GITHUB_WORKSPACE}" || exit
fi

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

# misspell -locale="${INPUT_LOCALE}" . \
#   | reviewdog -efm="%f:%l:%c: %m" -name="linter-name (misspell)" -reporter="${INPUT_REPORTER:-github-pr-check}" -level="${INPUT_LEVEL}"
