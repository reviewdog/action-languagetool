# action-languagetool

[![Test](https://github.com/reviewdog/action-languagetool/workflows/Test/badge.svg)](https://github.com/reviewdog/action-languagetool/actions?query=workflow%3ATest)
[![reviewdog](https://github.com/reviewdog/action-languagetool/workflows/reviewdog/badge.svg)](https://github.com/reviewdog/action-languagetool/actions?query=workflow%3Areviewdog)
[![depup](https://github.com/reviewdog/action-languagetool/workflows/depup/badge.svg)](https://github.com/reviewdog/action-languagetool/actions?query=workflow%3Adepup)
[![release](https://github.com/reviewdog/action-languagetool/workflows/release/badge.svg)](https://github.com/reviewdog/action-languagetool/actions?query=workflow%3Arelease)
[![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/reviewdog/action-languagetool?logo=github&sort=semver)](https://github.com/reviewdog/action-languagetool/releases)
[![action-bumpr supported](https://img.shields.io/badge/bumpr-supported-ff69b4?logo=github&link=https://github.com/haya14busa/action-bumpr)](https://github.com/haya14busa/action-bumpr)

![github-pr-review demo](https://user-images.githubusercontent.com/3797062/74084817-31e7ce80-4ab6-11ea-9d7f-621a9861148c.png)
![github-pr-check demo](https://user-images.githubusercontent.com/3797062/74084838-5ba0f580-4ab6-11ea-85fa-0944ff7709b5.png)

This action runs [LanguageTool](https://github.com/languagetool-org/languagetool) check with [reviewdog](https://github.com/reviewdog/reviewdog) on pull requests to improve code review experience.

## Inputs

| GitHub Action       | Bitbucket pipe      | Default                                                                                                                                                                                                                                                                                                        | Description                                                                     |
|---------------------|---------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------|
| github_token        | N/A                 | `${{ github.token }}`                                                                                                                                                                                                                                                                                          | GITHUB_TOKEN                                                                    |
| level               | LEVEL               | `error`                                                                                                                                                                                                                                                                                                        | Report level for reviewdog [info,warning,error]                                 |
| reporter            | REPORTER            | `github-pr-check`/`bitbucket-code-report`                                                                                                                                                                                                                                                                      | Reporter of reviewdog command [github-pr-check,github-pr-review]                |
| extra_args          | EXTRA_ARGS          |                                                                                                                                                                                                                                                                                                                | Add additional reviewdog cli args                                               |
| patterns            | PATTERNS            | `**/*.md **/*.txt'`                                                                                                                                                                                                                                                                                            | Space separated target file glob patterns. https://github.com/haya14busa/ghglob |
| language            | LANGUAGE            | `en-US`                                                                                                                                                                                                                                                                                                        | `language` of LanguageTool                                                      |
| enabled_rules       | ENABLED_RULES       |                                                                                                                                                                                                                                                                                                                | Comma separated `enabledRules` of LanguageTool                                  |
| disabled_rules      | DISABLED_RULES      | WHITESPACE_RULE,EN_QUOTES,DASH_RULE,WORD_CONTAINS_UNDERSCORE, UPPERCASE_SENTENCE_START,ARROWS,COMMA_PARENTHESIS_WHITESPACE, UNLIKELY_OPENING_PUNCTUATION,SENTENCE_WHITESPACE,CURRENCY, EN_UNPAIRED_BRACKETS,PHRASE_REPETITION,PUNCTUATION_PARAGRAPH_END, METRIC_UNITS_EN_US,ENGLISH_WORD_REPEAT_BEGINNING_RULE | Comma separated `disabledRules` of LanguageTool                                 |
| enabled_categories  | ENABLED_CATEGORIES  |                                                                                                                                                                                                                                                                                                                | Comma separated `enabledCategories` of LanguageTool                             |
| disabled_categories | DISABLED_CATEGORIES | TYPOS,TYPOGRAPHY                                                                                                                                                                                                                                                                                               | Comma separated `disabledCategories` of LanguageTool                            |
| enabled_only        | ENABLED_ONLY        | `false`                                                                                                                                                                                                                                                                                                        | `enabledOnly` of LanguageTool                                                   |
| custom_api_endpoint | CUSTOM_API_ENDPOINT |                                                                                                                                                                                                                                                                                                                | Custom API endpoint of LanguageTool server. e.g. https://languagetool.org/api    |

See [Language Tool API Docs](https://languagetool.org/http-api/swagger-ui/#!/default/post_check) for more detailed
explanation for some of the parameters

## GitHub Action example

```yaml
name: reviewdog
on: [pull_request]
jobs:
  linter_name:
    name: runner / <linter-name>
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: reviewdog/action-languagetool@v1
        with:
          github_token: ${{ secrets.github_token }}
          # Change reviewdog reporter if you need [github-pr-check,github-check,github-pr-review].
          reporter: github-pr-review
          # Change reporter level if you need.
          level: info
```

## Bitbucket pipe example

```yaml
pipelines:
  default:
    - step:
        script:
          - pipe: docker://reviewdog/action-languagetool:1.5.0
            variables:
              LEVEL: info
              PATTERNS: "**/*.txt"
```

## Development

### Release

#### [haya14busa/action-bumpr](https://github.com/haya14busa/action-bumpr)
You can bump version on merging Pull Requests with specific labels (bump:major,bump:minor,bump:patch).
Pushing tag manually by yourself also work.

#### [haya14busa/action-update-semver](https://github.com/haya14busa/action-update-semver)

This action updates major/minor release tags on a tag push. e.g. Update v1 and v1.2 tag when released v1.2.3.
ref: https://help.github.com/en/articles/about-actions#versioning-your-action

### Lint - reviewdog integration

This reviewdog action template itself is integrated with reviewdog to run lints
which is useful for Docker container based actions.

![reviewdog integration](https://user-images.githubusercontent.com/3797062/72735107-7fbb9600-3bde-11ea-8087-12af76e7ee6f.png)

Supported linters:

- [reviewdog/action-shellcheck](https://github.com/reviewdog/action-shellcheck)
- [reviewdog/action-hadolint](https://github.com/reviewdog/action-hadolint)
- [reviewdog/action-misspell](https://github.com/reviewdog/action-misspell)

### Dependencies Update Automation
This repository uses [haya14busa/action-depup](https://github.com/haya14busa/action-depup) to update
reviewdog version.

[![reviewdog depup demo](https://user-images.githubusercontent.com/3797062/73154254-170e7500-411a-11ea-8211-912e9de7c936.png)](https://github.com/reviewdog/action-template/pull/6)

