# Kubernetes コンポーネント導入 (kubeadm / kubelet / kubectl)

このドキュメントは、Debian 13 Trixie を前提として、`kubeadm` / `kubelet` / `kubectl` を Ansible を用いて導入する方法を説明します。

## 前提

- 対象 OS: **Debian 13 Trixie**
- このリポジトリの `ansible/` ディレクトリで uv により Ansible 実行環境が構築されていること

## 役割分割

- `roles/kubernetes_apt_repo`:
  - Kubernetes 公式 APT リポジトリと GPG キーを設定し、パッケージキャッシュを更新する
- `roles/kubelet_kubectl`:
  - `kubelet` と `kubectl` をインストールし、`apt-mark hold` によりバージョンを固定する
- `roles/kubeadm`:
  - `kubeadm` をインストールし、`apt-mark hold` によりバージョンを固定する

`kubernetes_apt_repo` は共通の依存 role として利用され、Debian 向けの Kubernetes APT リポジトリ設定を一箇所に集約しています。

## バージョン管理方針

- **前提バージョン**: **Kubernetes v1.35.2** を前提に kubeadm / kubelet / kubectl のバージョンを固定しています。
- リポジトリのマイナーバージョンは、`roles/kubernetes_apt_repo/defaults/main.yml` の
  `kubernetes_apt_repo_version` で指定します (例: `v1.35`)。
- 各パッケージの固定バージョンは、`roles/kubeadm/defaults/main.yml` の `kubeadm_kubernetes_version` および
  `roles/kubelet_kubectl/defaults/main.yml` の `kubelet_kubectl_kubernetes_version` で指定します (デフォルト: `1.35.2`)。
- インストール後は `apt-mark hold` により、意図しないアップグレードを防ぎます。
- バージョンを変更する場合は、`kubernetes_apt_repo_version` と各 role の `kubernetes_version` を更新したうえで、
  公式ドキュメントに従ってアップグレード手順を検討してください。

## 実行方法

ローカルなどから Ansible を実行する場合の例:

```bash
cd ansible
uv run ansible-playbook -i inventories/local playbooks/site.yml
```

- すべてのホスト (`all`) に対して:
  - Kubernetes APT リポジトリ設定 (`kubernetes_apt_repo`)
  - `kubelet` / `kubectl` の導入 (`kubelet_kubectl`)
- `controlplane` グループに属するホストに対して:
  - Kubernetes APT リポジトリ設定 (`kubernetes_apt_repo`)
  - `kubeadm` の導入 (`kubeadm`)

同じ playbook を再実行しても、role は冪等な設計になっており、破綻しにくい形になっています。

