#!/bin/sh
set -e


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

  # for FILE in $(git ls-files | ghglob '**/*.md' '**/*.txt'); do
  #   # https://languagetool.org/http-api/swagger-ui/#!/default/post_check
  #   curl \
  #     --data-urlencode "langugage=${INPUT_LANGUAGE}" \
  #     --data-urlencode "enabledRules=${INPUT_ENABLED_RULES}" \
  #     --data-urlencode "disabledRules=${INPUT_DISABLED_RULES}" \
  #     --data-urlencode "enabledCategories=${INPUT_ENABLED_CATEGORIES}" \
  #     --data-urlencode "disabledCategories=${INPUT_DISABLED_CATEGORIES}" \
  #     --data-urlencode "enabledOnly=${INPUT_ENABLED_ONLY}" \
  #     --data-urlencode "text=$(cat "${FILE}")" \
  #     http://localhost:8010/v2/check | \
  #     FILE="${FILE}" tmpl /langtool.tmpl
  # done
}

run_langtool \
  | reviewdog -efm="%A%f:%l:%c: %m" -efm="%C %m" -name="LanguageTool" -reporter="${INPUT_REPORTER:-github-pr-check}" -level="${INPUT_LEVEL}"
