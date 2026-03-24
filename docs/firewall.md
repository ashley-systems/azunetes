# Firewall 運用方針

## 概要

azunetes クラスタのホストファイアウォールは、Ansible の `roles/security` で管理する。
バックエンドには nftables を使用し、ufw は使用しない。

## 現在のルール（初期構築）

対象: control plane ノード

| ルール | 内容 |
|--------|------|
| 22/tcp | 許可（SSH） |
| その他 | reject |

加えて、確立済みの接続（established, related）とループバック通信は許可している。

## 設定の変更方法

許可ポートを追加する場合は `ansible/roles/security/defaults/main.yml` を編集する。
```yaml
security_allowed_tcp_ports:
  - 22
  - 6443  # 例: Kubernetes API server
```

変更後、playbook を実行すると反映される。
```bash
cd ansible
uv run --frozen ansible-playbook -i inventories/<環境>/hosts playbooks/site.yml
```

## 設計判断

- nftables を直接扱う理由や ufw を採用しない理由は [Issue #34](https://github.com/ashley-systems/azunetes/issues/34) を参照
- 将来的に worker node 向けルールや Kubernetes 関連ポートの追加を予定している

## ファイル構成
```
ansible/roles/security/
├── tasks/main.yml            # メインタスク
├── templates/nftables.conf.j2  # nftables 設定テンプレート
├── handlers/main.yml          # reload ハンドラ
├── defaults/main.yml          # デフォルト変数
└── meta/main.yml              # role メタ情報
```
