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

## Development

### Requirements

- [uv](https://docs.astral.sh/uv/)

### Lint

Ansible の静的解析には `ansible-lint` を利用します。

```bash
# 依存関係のインストール
uv sync

# lint の実行
uv run ansible-lint
```
