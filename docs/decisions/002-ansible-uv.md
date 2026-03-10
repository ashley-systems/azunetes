# Decision: 002-Use Ansible for host provisioning and uv for Python environment management

- Status: Active

## Context
IaaS上でアンマネージドな Kubernetes を構築するにあたり、OS 初期設定、パッケージ導入、設定ファイル配布、サービス起動のようなホスト構築作業を繰り返し安全に実行できる形にしたい。

このプロジェクトでは、手元や CI から同じ手順を再実行できること、構築手順がコードとして追跡できること、学習用途としても読みやすいことを重視する。また、Ansible の利用には Python 実行環境と依存パッケージの管理が必要になる。

## Decision
ホスト構築には Ansible を利用する。Ansible を実行するための Python 環境構築とパッケージ管理には uv を利用する。

## Why
Ansible は SSH ベースで動作し、対象ホストに常駐エージェントを前提としないため、最小構成のサーバにも導入しやすい。Playbook と role で構築手順を宣言的に表現でき、再実行による収束も期待できるため、手作業のばらつきを減らせる。

uv は Python 仮想環境の作成と依存解決が高速で、セットアップ手順を単純に保ちやすい。Ansible 実行用の依存をプロジェクト内に閉じ込めやすく、ローカルでも CI でも同じ手順で同じ実行環境を作りやすいため、手元と CI の差分を抑えながら再現性の高い運用がしやすい。

## Consequences
ホスト構築手順は Ansible の playbook / role に集約して管理する。シェルスクリプトの単発運用よりも構成の見通しと再利用性が上がる一方で、Ansible のディレクトリ構成や変数設計の整理が必要になる。

Python 関連ツールの導入方法は `uv` を前提にそろえる。`pip` やシステム Python に直接依存しない方針になるため、ローカル開発環境と CI の実行環境をそろえやすくなり、開発手順も明確になる。一方で、参加者には `uv` の利用方法を共有する必要がある。

## Notes
`uv` のセットアップは公式ドキュメントを参照する。

- uv のインストール: <https://docs.astral.sh/uv/getting-started/installation/>
- uv で Python を導入・管理する手順: <https://docs.astral.sh/uv/guides/install-python/>
