 # Decision: Debian 13 Trixie を前提 OS として採用する
 
 - Status: Active
 - Related: https://github.com/ashley-systems/azunetes/issues/3
 
 ## Context
 Kubernetes クラスタ構築用の初期構築手順や運用ドキュメントを整備するにあたり、前提とする OS を統一する必要があった。
 kubeadm 公式ドキュメントがサポートするディストリビューションの中から、学習用途と運用イメージの両面で扱いやすい OS を選定する必要がある。
 
 ## Decision
 このリポジトリで構築する Kubernetes クラスタの前提 OS として **Debian 13 Trixie** を採用する。
 
 ## Why
 - kubeadm の公式ドキュメントにおいて Debian 系がサポート対象であり、手順との整合性が取りやすい。
 - Ubuntu は snap などディストリ固有要素が多く、学習対象外の差分が増えるため採用しない。
 - CentOS / RHEL 系はライセンスやディストリの将来性・派生ディストリの選択など、別軸の検討が必要になるため今回のスコープから外す。
 - Fedora や Container Linux、HypriotOS などは用途やリリースサイクルの観点から、学習用のベース OS としては取り回しが悪い。
 - Debian はシンプルなパッケージ管理と長期的な安定性があり、学習・検証環境として扱いやすい。
 
 ## Consequences
 - 初期構築手順、運用ドキュメント、サンプル設定は Debian 13 Trixie を前提として記述する。
 - 他ディストリビューション向けの手順は本リポジトリのスコープ外とし、必要であれば別途ドキュメントを追加する。
 - 将来 OS バージョンアップが必要になった場合は、新たな decision を追加して取り扱う。
 
 ## Notes
 - 公式ドキュメントの参照元: https://kubernetes.io/ja/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
 - 実際の検証環境で利用するイメージの入手元やプロビジョニング方法は、別途 IaC レイヤの decision で扱う。
