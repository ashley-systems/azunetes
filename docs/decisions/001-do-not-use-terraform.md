# Decision: 001-Terraform を採用しない

- Status: Active
- Related: なし

## Context
このプロジェクトは IaaS 上にアンマネージドな Kubernetes を構築する。
ただし、採用する事業者は Terraform を利用できるとは限らず、将来的にマルチクラウド構成になる可能性もある。
特定の IaC ツールへの依存を前提にすると、利用できる事業者や構成の選択肢を狭める。

## Decision
インフラ構築の主手段として Terraform は採用しない。

## Why
Terraform を前提にすると、Terraform Provider の有無や成熟度に構成が左右される。
このプロジェクトでは、まず事業者選定や構成の自由度を優先する。
そのため、環境の初期化やブートストラップは、必要に応じて専用の script を用意して実行する方針とする。

## Consequences
Terraform Provider に依存せずに IaaS を選定できる。
一方で、Terraform の state 管理や差分検知、module の再利用といった利点は使えない。
代替として、bootstrap script の保守、再実行性、冪等性を設計で担保する必要がある。

## Notes
bootstrap script は、初期セットアップやノード準備など、Terraform の代わりに必要な自動化を担当する。
