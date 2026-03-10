# AGENTS.md

## Purpose

IaaS上に、アンマネージドな Kubernetes を構築する

## Ground Rules

- 大きな変更は事前に確認する
- 無関係な差分は触らない
- セキュリティや機微情報の管理の取り扱いには十分に注意する
- 変更は目的達成に必要な最小限にする

## Validation

- 変更箇所に対応するテストや確認を行う
- 実行できない場合は理由を明記する

## GitHub Workflow

- コミットは Conventional Commits に従う
- 言語は下記に従う
  - PR本文: 日本語
  - PRタイトル: 英語
  - Issueタイトル: 日本語
  - Issue本文: 日本語

## References

- 詳細手順: `docs/agents/`
- 設計判断: `docs/decisions/`
