#!/bin/sh
set -eo pipefail

mkdir /ngrams
cd /ngrams
wget https://languagetool.org/download/ngram-data/ngrams-en-20150817.zip
unzip -o ngrams-en-20150817.zip
ls /ngrams

java -cp "/LanguageTool-${LANGUAGETOOL_VERSION}/languagetool-server.jar" org.languagetool.server.HTTPServer --port 8010 --languagemodel /ngrams &
sleep 3 # Wait the server statup.

if [ -n "${GITHUB_WORKSPACE}" ]; then
  cd "${GITHUB_WORKSPACE}" || exit
fi

# https://languagetool.org/http-api/swagger-ui/#!/default/post_check
DATA="language=${INPUT_LANGUAGE}"
if [ -n "${INPUT_ENABLED_RULES}" ]; then
  DATA="$DATA&enabledRules=${INPUT_ENABLED_RULES}"
fi
if [ -n "${INPUT_DISABLED_RULES}" ]; then
  DATA="$DATA&disabledRules=${INPUT_DISABLED_RULES}"
fi
if [ -n "${INPUT_ENABLED_CATEGORIES}" ]; then
  DATA="$DATA&enabledCategories=${INPUT_ENABLED_CATEGORIES}"
fi
if [ -n "${INPUT_DISABLED_CATEGORIES}" ]; then
  DATA="$DATA&disabledCategories=${INPUT_DISABLED_CATEGORIES}"
fi
if [ -n "${INPUT_ENABLED_ONLY}" ]; then
  DATA="$DATA&enabledOnly=${INPUT_ENABLED_ONLY}"
fi

run_langtool() {
  for FILE in $(git ls-files | ghglob ${INPUT_PATTERNS}); do
    echo "Checking ${FILE}..." >&2
    curl \
      --request POST \
      --data "${DATA}" \
      --data-urlencode "text=$(cat "${FILE}")" \
      http://localhost:8010/v2/check | tee /dev/stderr | \
      FILE="${FILE}" tmpl /langtool.tmpl
  done
}

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

run_langtool \
  | reviewdog -efm="%A%f:%l:%c: %m" -efm="%C %m" -name="LanguageTool" -reporter="${INPUT_REPORTER:-github-pr-check}" -level="${INPUT_LEVEL}" -tee
