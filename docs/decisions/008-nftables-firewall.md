# Decision: Firewall 設定に nftables を直接使用する

- Status: Active
- Related: Issue #34, roles/security

## Context
azunetes は段階的に Kubernetes クラスタを構築していくプロジェクトであり、初期フェーズではまず control plane の立ち上げが対象になる。この段階で、不要なポートを開けたままにせず、最小限の到達性だけを許可する形でホストの防御面を整えておきたい。あわせて、firewall 設定を手作業ではなく Ansible の role として管理することで、再現性・設定差分の可視性・将来の拡張性を確保したい。

## Decision
firewall は ufw を使わず、nftables を直接操作する方針とする。

## Why
- Debian 13 前提との相性がよい（nftables は Debian の標準）
- ufw の抽象化を挟まない方が、role として管理する際に挙動が明確になる
- 将来的に Kubernetes 関連ポートや worker node 向けルールを追加するとき、nftables ベースの方が細かい制御がしやすい
- 学習用途としても、実際にどうフィルタされるかが理解しやすい

## Consequences
**良い点:**
- 許可ポートを変数化しており、ポート追加時は `defaults/main.yml` に値を足すだけで対応できる
- 専用テーブル `ansible_security` で管理しているため、kube-proxy 等の他コンポーネントが作成するテーブルと干渉しない
- systemd による有効化・永続化まで管理しているため、再起動後もルールが維持される

**受け入れるトレードオフ:**
- ufw に比べて設定の記述量が多く、nftables の知識が前提になる
- ルールの追加・変更時は Ansible を経由する運用が必要になる（手動での直接編集は role の管理と乖離する）

## Notes
- 現在の許可ポート: 22/tcp（SSH）、6443/tcp（Kubernetes API server）。それ以外は reject
- 将来的に追加を検討するもの: worker node 向けルール、クラスタ内部通信、ICMP、監視用ポート、環境別の差分管理
- ファイル構成:
  - `ansible/roles/security/tasks/main.yml` — メインタスク
  - `ansible/roles/security/templates/nftables.conf.j2` — nftables 設定テンプレート
  - `ansible/roles/security/handlers/main.yml` — reload ハンドラ
  - `ansible/roles/security/defaults/main.yml` — デフォルト変数
