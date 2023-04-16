#!/bin/bash
set -eo pipefail

echo "API ENDPOINT: ${INPUT_API_ENDPOINT}" >&2

if [ -n "${GITHUB_WORKSPACE}" ]; then
	cd "${GITHUB_WORKSPACE}" || exit
fi

git config --global --add safe.directory "$GITHUB_WORKSPACE"

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
if [ -n "${INPUT_USERNAME}" ]; then
	DATA="$DATA&username=${INPUT_USERNAME}"
fi
if [ -n "${INPUT_API_KEY}" ]; then
	DATA="$DATA&apiKey=${INPUT_API_KEY}"
fi

# Disable glob to handle glob patterns with ghglob command instead of with shell.
set -o noglob

if [ "${INPUT_FILTER_FILES}" = "changed" ]; then
	PR_NUMBER=$(echo "${GITHUB_REF}" | awk -F / '{print $3}')
	PAGE=1
	FILES=""
	while :; do
		RESPONSE="$(curl --silent -H "Authorization: token ${INPUT_GITHUB_TOKEN}" \
			"https://api.github.com/repos/${GITHUB_REPOSITORY}/pulls/${PR_NUMBER}/files?per_page=100&page=${PAGE}")"
		PAGE_FILES="$(echo "${RESPONSE}" | jq -r '.[] | select(.status != "deleted") | .filename' | ghglob "${INPUT_PATTERNS}")"
		if [ -z "${PAGE_FILES}" ]; then
			break
		fi
		FILES="${FILES}${PAGE_FILES}"
		PAGE=$((PAGE + 1))
	done
else
	FILES="$(git ls-files | ghglob "${INPUT_PATTERNS}")"
fi

# echo list of files to check
echo "Files to check:"
echo "${FILES}"

set +o noglob

urlencode() {
	local input="$1"
	local output=""
	while IFS= read -r -n1 char; do
		if [[ "${char}" =~ [a-zA-Z0-9\.\~\_\-] ]]; then
			output+="${char}"
		else
			printf -v hex_char "%02X" "'${char}"
			output+="%${hex_char}"
		fi
	done <<<"${input}"
	echo "${output}"
}

run_langtool() {
	for FILE in ${FILES}; do
		DATA_JSON=$(node /annotate.js "${FILE}")
		ENCODED_DATA_JSON=$(urlencode "${DATA_JSON}")
		DATA_FOR_FILE="${DATA}&data=${ENCODED_DATA_JSON}"
		RESPONSE_JSON=$(curl --silent \
			--request POST \
			--data "${DATA_FOR_FILE}" \
			"${INPUT_API_ENDPOINT}/v2/check")

		# Pass the file path to tmpl
		PARSED_RESPONSE=$(echo "${RESPONSE_JSON}" | FILE="${FILE}" tmpl /langtool.tmpl)

		echo "${PARSED_RESPONSE}"
	done
}

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

LANGTOOL_RESPONSE=$(run_langtool)

echo "${LANGTOOL_RESPONSE}" | reviewdog -efm="%A%f:%l:%c: %m" \
	-efm="%C %m" \
	-name="LanguageTool" \
	-reporter="${INPUT_REPORTER:-github-pr-review}" \
	-level="${INPUT_LEVEL}" \
	-filter-mode="${INPUT_FILTER_MODE}"
