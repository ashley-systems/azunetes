# Decision: 004-Keep the initial Ansible directory layout simple

- Status: Active
- Related: [002-ansible-uv](./002-ansible-uv.md), PR #12

## Context
kubeadm を利用した Kubernetes クラスタ構築のために Ansible 配下の初期構成を決めたい。

この段階では、対象ノードの inventory、Ansible の入口となる playbook、再利用する role の責務を分けたい。一方で、初期段階から playbook を用途別に細かく分割すると、どこから実行するのか分かりにくくなりやすい。

## Decision
Ansible の初期構成は `ansible/` 配下に `inventories`、`playbooks`、`roles` を置き、playbook の入口は `playbooks/site.yml` に一本化する。

## Why
inventory、実行入口、再利用部品の置き場を分けると、ホスト情報と処理内容の責務が混ざりにくい。`site.yml` を唯一の入口にしておくと、実行開始点が明確で、初見でも追いやすい。

また、ディレクトリの細かな分割は実装が進んでからでも遅くない。最初は最小構成にしておき、必要が出たときだけ playbook や role を増やす方が理解しやすい。

## Consequences
初期状態では、環境ごとの差分は `inventories` で管理し、playbook は `site.yml` を中心に扱う。個別用途の playbook や role の細分化は、実際の運用要件が見えてから追加する前提になる。

この decision ではディレクトリの細部までは固定しない。今後、クラスタ更新や運用タスクが増えて構成の分割が必要になった場合は、別の decision で見直す。
