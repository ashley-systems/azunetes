# Decision: 007-Phase1/Phase2 の基盤リソースは GitHub Actions から apply する

- Status: Active
- Related: Issue #43, Issue #23, Issue #31, Issue #38, Issue #41, [002-ansible-uv](./002-ansible-uv.md), [005-keep-production-inventory-private](./005-keep-production-inventory-private.md)

## Context

`CNI`、`cert-manager`、`Ingress Controller` などの基盤リソースを、どこから Kubernetes クラスタへ適用するかを決めておきたい。

適用経路が曖昧なままだと、bootstrap 手順、`kubeconfig` や DNS API token の保管場所、production 向け private repository との責務分離、障害時の復旧手順まで一貫しなくなる。

既存 decision では、ホスト構築に Ansible を採用し、production 向けの具体値は private repository `azunetes-deploy` で扱う方針になっている。一方で、基盤リソースの導入では、まず manifest を Git でレビューできる形に保ちつつ、早く適用経路を固めたい。

この decision では、恒久的な最終形ではなく、Phase1/Phase2 の標準方式と、Phase3 以降で再検討する範囲を切り分ける。

## Decision

Phase1/Phase2 の基盤リソースは、GitHub Actions から Kubernetes API に対して push 型で apply することを標準とする。

基盤系の manifest は Git 管理し、GitHub Actions から `kubectl apply` を実行する。production では private repository `azunetes-deploy` 側の workflow を実行入口とし、必要な認証情報は GitHub Actions Secrets に保存する前提とする。

対象 VM 上での `kubectl apply` や、Ansible control 側からの apply は、Phase1/Phase2 の標準方式にはしない。Argo CD / Flux などの pull 型 GitOps controller や、より統合的な secret 管理方式は、Phase3 を実施する場合に別途検討する。

## Why

GitHub Actions から `kubectl apply` する方式は、manifest を Git 上でレビューでき、実行入口も workflow に集約できるため、Phase1/Phase2 の初期運用として分かりやすい。特に CNI のように `kubeadm` 後すぐに入れたい基盤リソースは、クラスタ外から単純に apply できる経路があると扱いやすい。

また、pull 型 GitOps を最初から標準にすると、クラスタ内に Git credential や復号鍵を持ち込む設計が必要になり、private repository や secret 管理の検討を先に固める必要がある。Phase1/Phase2 ではそこまでの基盤は持たず、まずは最小限の仕組みで基盤 add-on を導入できる状態を優先する。

対象 VM 上で `kubectl apply` する運用は、実行起点や manifest の保管場所が分散しやすい。GitHub Actions に実行責務を寄せると、少なくとも初期フェーズでは実行入口と再実行手順を揃えやすい。

## Consequences

Phase1/Phase2 の CNI、`cert-manager`、Ingress Controller、RBAC、その他 cluster add-on は、GitHub Actions から Kubernetes API に対して適用する前提で実装する。個々の add-on で `manifest` と `Helm` のどちらを使うかは別途決めてよいが、適用の責務は workflow 側に集約する。

pull 型と比べると、CI 側が Kubernetes API を更新できる認証情報を保持するため、権限が GitHub Actions 側に寄りやすい。Phase1/Phase2 ではこの単純さを優先して受け入れるが、権限範囲の絞り込みや認証情報のローテーションは運用課題として残る。

また、Argo CD / Flux のような常駐 controller と比べると、リポジトリ上の manifest と実際のクラスタ状態、必要に応じて VM 側に置かれた補助設定との drift 検知や自己修復は弱い。差分是正は workflow の再実行タイミングに依存するため、定期実行や手動再実行の運用を別途整備する必要がある。

production の実行場所には、private repository `azunetes-deploy` 側の GitHub Actions workflow を用い、当面は public の GitHub Actions runner を利用する前提とする。したがって、Phase1/Phase2 ではクラスタ API がその runner から到達可能であることを前提条件として受け入れる。`kubeconfig` などの認証情報を GitHub Actions Secrets に置く運用も Phase1/Phase2 では受け入れるが、長期的な secret 管理方式として固定はしない。

Phase3 を実施する場合は、Argo CD などの統合的なデプロイ環境、secret 管理、Git credential や復号鍵の扱い、継続的 reconciliation の要否を改めて decision として整理する。

## Notes

この decision は、Phase1/Phase2 の基盤リソース適用経路を決めるものであり、各 add-on の採用可否や `manifest` / `Helm` の選択までは固定しない。

Phase3 の有無と、その段階で GitHub Actions push を継続するか、GitOps controller に移行するかは、この decision では確定しない。
