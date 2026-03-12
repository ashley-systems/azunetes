# Decision: 005-Keep production deployment values in a private repository

- Status: Active
- Related: Issue #16, Issue #18

## Context
production 向けの Ansible 変数や inventory には、シークレットそのものではなくても public repository に置きたくない情報が含まれやすい。

たとえば、ホスト名、内部 IP、ノード構成、接続先の前提情報に加えて、今後追加される認証認可まわりの具体的な値も GitHub Actions Secrets に保存するには構造化されすぎており、差分管理もしにくい。一方で、public repository にそのまま置くと、運用情報が過度に露出する。

## Decision
production 向けの具体的なデプロイ値は、この public repository には置かず、private repository `azunetes-deploy` で管理する。

これには `ansible/inventories/production` だけでなく、今後追加される認証認可の具体値や、production 固有の group_vars / host_vars を含む。

この public repository には、production 向け実装の土台となる playbook、role、変数のサンプル、利用方法のドキュメントのみを置く。

本番リリースは、private repository `azunetes-deploy` 側の GitHub Actions `workflow_dispatch` を起点に実行する想定とする。

## Why
private repository `azunetes-deploy` に分離すると、production 固有の構成情報を YAML のまま管理でき、GitHub Actions Secrets に無理に分解せずに済む。あわせて、public repository 側には再利用可能な実装だけを残せるため、公開範囲を最小限にできる。

また、inventory と関連変数を同じ private repository にまとめると、production 環境の差分を一か所でレビューしやすい。local 向け設定と production 向け設定の責務分離もしやすくなる。

## Consequences
production 向けの実行には、public repository だけでなく private repository `azunetes-deploy` の取得が必要になる。ローカル実行手順や CI での checkout 方法は、別途整理する必要がある。

本番向けの GitHub Actions workflow も `azunetes-deploy` 側に置く前提になるため、public repository 側では本番デプロイの直接実行は持たない。

この decision は、production の具体値の保管場所と本番リリースの実行場所を定めるものであり、private repository の取り込み方法やシークレット暗号化方式までは確定しない。シークレット値そのものの扱いは、別途安全な方式を決める。

## Notes
public repository 側では、production 用の実値は持たず、サンプルや雛形に留める。
