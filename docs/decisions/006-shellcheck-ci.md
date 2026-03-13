# Decision: 006-Add ShellCheck GitHub Actions workflow

- Status: Active
- Related: Issue #29

## Context
リポジトリ内に将来的に増えるシェルスクリプトの品質を自動でチェックし、クォート漏れや未定義変数参照などの典型的なバグを早期に検知したい。
既存の CI 構成（Ansible 関連の GitHub Actions）と整合する形で ShellCheck を組み込みつつ、push 時のジョブ増加によるノイズは避けたい。

## Decision
GitHub Marketplace に公開されている `ludeeus/action-shellcheck@2.0.0` を使用し、`.github/workflows/shellcheck.yml` から pull request と手動実行 (`workflow_dispatch`) のみをトリガとして ShellCheck を実行する。

## Why
`ludeeus/action-shellcheck` は GitHub Marketplace 上でメンテナンスされており、ShellCheck 実行のベストプラクティスがまとまっているため、独自 Action よりも保守コストが低い。
push でも常時実行すると開発フローに不要な CI ノイズが増えるため、レビュー時の `pull_request` と必要に応じた `workflow_dispatch` 実行のみとし、レビュアーと開発者が意図したタイミングでチェックできるようにする。

## Consequences
ShellCheck は PR 作成時・更新時、および明示的に workflow を起動した場合のみ実行されるため、ローカルブランチ上での push では自動チェックされない。
新規に追加される `.sh` / `.bash` ファイルや、既存スクリプトの変更は CI で検出されるが、ShellCheck のルールに従わない既存スクリプトがある場合は、将来的に別途 `.shellcheckrc` や ignore 設定の検討が必要になる。

