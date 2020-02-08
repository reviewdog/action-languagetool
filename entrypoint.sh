#!/bin/sh
set -e

if [ -n "${GITHUB_WORKSPACE}" ]; then
  cd "${GITHUB_WORKSPACE}" || exit
fi

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

source start.sh &
echo 'LanguageTool server started?'

# misspell -locale="${INPUT_LOCALE}" . \
#   | reviewdog -efm="%f:%l:%c: %m" -name="linter-name (misspell)" -reporter="${INPUT_REPORTER:-github-pr-check}" -level="${INPUT_LEVEL}"
