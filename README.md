# azunetes

苦しんで学ぶ Kubernetes クラスタ構築

## Target

- IaaS上に、アンマネージドな Kubernetes を構築する
- 下記の技術を勉強する
  - IaC
  - CI/CD
  - kubeadm
  - kubernetes の 認証認可

## Assumed OS

- Debian 13 Trixie

## Phase

- Phase 1: controlplane を構築する
- Phase 2: workernode を構築して、controlplane と接続する
- Phase 3: （オプション）ストレージサーバを構築して、実運用を試す

## Ansible Development Environment

Ansible 実行環境は `ansible/` 配下で `uv` を前提に管理する。
Python は 3.14 も候補だが、collection や周辺ツールとの互換性を考慮して、当面は 3.12 を基準にする。

```sh
cd ansible
uv python install 3.12
uv sync
```

動作確認:

```sh
cd ansible
uv run --frozen ansible-playbook --version
```
