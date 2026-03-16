# common role

共通ホスト設定を適用する。

対象:

- ホスト名
- タイムゾーン
- 基本パッケージ
- ユーザ作成
- sudo グループ付与
- authorized_keys 配置
- swap 無効化

例:

```yaml
common_hostname: "cp01"
common_users:
  - name: ansible
    comment: "Ansible automation user"
    sudo: true
    authorized_keys:
      - "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGexample ansible@example"
```

メモ:

- `common_timezone` の既定値は `Asia/Tokyo`
- 作成するユーザのログインシェルは `/bin/bash`
