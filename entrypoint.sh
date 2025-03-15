#!/bin/bash
set -eo pipefail

# import bitbucket pipeline common script
source "$(dirname "$0")/common.sh"

# set default values
LEVEL="${LEVEL:-error}"
if [ -z "${BITBUCKET_PIPELINE_UUID}" ]; then 
  REPORTER="${REPORTER:-github-pr-check}"
else
  REPORTER="${REPORTER:-bitbucket-code-report}"
fi
PATTERNS="${PATTERNS:-**/*.md **/*.txt}"
LANGUAGE="${LANGUAGE:-en-US}"
DISABLED_RULES="${DISABLED_RULES:-WHITESPACE_RULE,EN_QUOTES,DASH_RULE,WORD_CONTAINS_UNDERSCORE,UPPERCASE_SENTENCE_START,ARROWS,COMMA_PARENTHESIS_WHITESPACE,UNLIKELY_OPENING_PUNCTUATION,SENTENCE_WHITESPACE,CURRENCY,EN_UNPAIRED_BRACKETS,PHRASE_REPETITION,PUNCTUATION_PARAGRAPH_END,METRIC_UNITS_EN_US,ENGLISH_WORD_REPEAT_BEGINNING_RULE}"
DISABLED_CATEGORIES="${DISABLED_CATEGORIES:-TYPOS,TYPOGRAPHY}"
ENABLED_ONLY="${ENABLED_ONLY:-false}"


# map bitbucket pipe variables (without the INPUT_ prefix) to github actions variables format
INPUT_CUSTOM_API_ENDPOINT="${INPUT_CUSTOM_API_ENDPOINT:-${CUSTOM_API_ENDPOINT}}"
INPUT_LANGUAGE="${INPUT_LANGUAGE:-${LANGUAGE}}"
INPUT_ENABLED_RULES="${INPUT_ENABLED_RULES:-${ENABLED_RULES}}"
INPUT_DISABLED_RULES="${INPUT_DISABLED_RULES:-${DISABLED_RULES}}"
INPUT_ENABLED_CATEGORIES="${INPUT_ENABLED_CATEGORIES:-${ENABLED_CATEGORIES}}"
INPUT_DISABLED_CATEGORIES="${INPUT_DISABLED_CATEGORIES:-${DISABLED_CATEGORIES}}"
INPUT_ENABLED_ONLY="${INPUT_ENABLED_ONLY:-${ENABLED_ONLY}}"
INPUT_PATTERNS="${INPUT_PATTERNS:-${PATTERNS}}"
INPUT_REPORTER="${INPUT_REPORTER:-${REPORTER}}"
INPUT_EXTRA_ARGS="${INPUT_EXTRA_ARGS:-${EXTRA_ARGS}}"

API_ENDPOINT="${INPUT_CUSTOM_API_ENDPOINT}"
if [ -z "${INPUT_CUSTOM_API_ENDPOINT}" ]; then
  API_ENDPOINT=http://localhost:8010
  java -cp "/LanguageTool/languagetool-server.jar" org.languagetool.server.HTTPServer --port 8010 &
  echo "Wait the server startup for ${INPUT_WAIT_SERVER_STARTUP_DURATION}s"
  sleep "${INPUT_WAIT_SERVER_STARTUP_DURATION}" # Wait the server startup.
fi

echo "API ENDPOINT: ${API_ENDPOINT}" >&2

if [ -n "${GITHUB_WORKSPACE}" ]; then
  cd "${GITHUB_WORKSPACE}" || exit
fi

git config --global --add safe.directory $GITHUB_WORKSPACE

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

# Disable glob to handle glob patterns with ghglob command instead of with shell.
set -o noglob
FILES="$(git ls-files | ghglob ${INPUT_PATTERNS})"
set +o noglob

# To manage whitespaces in filepath
IFS=$(echo -en "\n\b")

run_langtool() {
  for FILE in ${FILES}; do
    echo "Checking ${FILE}..." >&2
    # Skip empty files
    if [ ! -s "${FILE}" ]; then
      echo "Skipping empty file: ${FILE}" >&2
      continue
    fi
    curl --silent \
      --request POST \
      --data "${DATA}" \
      --data-urlencode "text@${FILE}" \
      "${API_ENDPOINT}/v2/check" | \
      FILE="${FILE}" tmpl /langtool.tmpl
  done
}

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

run_langtool \
  | reviewdog -efm="%A%f:%l:%c: %m" -efm="%C %m" -name="LanguageTool" -reporter="${INPUT_REPORTER:-github-pr-check}" -level="${INPUT_LEVEL}" ${INPUT_EXTRA_ARGS}
