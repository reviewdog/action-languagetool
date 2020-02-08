#!/bin/sh
set -eo pipefail

java -cp "/LanguageTool-${LANGUAGETOOL_VERSION}/languagetool-server.jar" org.languagetool.server.HTTPServer --port 8010 &
sleep 3 # Wait the server statup.

if [ -n "${GITHUB_WORKSPACE}" ]; then
  cd "${GITHUB_WORKSPACE}" || exit
fi

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

run_langtool() {
  # test
  echo "langugage=${INPUT_LANGUAGE}" >&2
  echo "enabledRules=${INPUT_ENABLED_RULES}" >&2
  echo "disabledRules=${INPUT_DISABLED_RULES}" >&2
  echo "enabledCategories=${INPUT_ENABLED_CATEGORIES}" >&2
  echo "disabledCategories=${INPUT_DISABLED_CATEGORIES}" >&2
  echo "enabledOnly=${INPUT_ENABLED_ONLY}" >&2

  for FILE in $(git ls-files | ghglob '**/*.md' '**/*.txt'); do
    # https://languagetool.org/http-api/swagger-ui/#!/default/post_check
      # --data "langugage=${INPUT_LANGUAGE}&enabledRules=${INPUT_ENABLED_RULES}&disabledRules=${INPUT_DISABLED_RULES}&enabledCategories=${INPUT_ENABLED_CATEGORIES}&disabledCategories=${INPUT_DISABLED_CATEGORIES}&enabledOnly=${INPUT_ENABLED_ONLY}" \
    curl \
      --data "langugage=${INPUT_LANGUAGE}" \
      --data-urlencode "text=$(cat "${FILE}")" \
      http://localhost:8010/v2/check | \
      FILE="${FILE}" tmpl /langtool.tmpl
  done
}

run_langtool \
  | reviewdog -efm="%A%f:%l:%c: %m" -efm="%C %m" -name="LanguageTool" -reporter="${INPUT_REPORTER:-github-pr-check}" -level="${INPUT_LEVEL}"
