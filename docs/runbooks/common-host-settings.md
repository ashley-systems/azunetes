# Common Host Settings

`ansible/playbooks/site.yml` の `common` role で適用する共通ホスト設定の確認手順。

## 対象

- ホスト名設定
- タイムゾーン設定
- ユーザ作成
- swap の恒久無効化

## 変数例

`ansible/inventories/*/host_vars/<host>.yml`:

```yaml
common_hostname: "cp01"
common_users:
  - name: ansible
    comment: "Ansible automation user"
    groups:
      - sudo
    shell: /bin/bash
```

## 確認コマンド

```sh
hostnamectl
timedatectl
getent passwd ansible
swapon --show
grep -v '^[[:space:]]*#' /etc/fstab
```

期待値:

- `hostnamectl` で指定したホスト名が表示される
- `timedatectl` で `Time zone: Asia/Tokyo` が表示される
- `getent passwd <user>` で指定ユーザが存在する
- `swapon --show` が空になる
- `/etc/fstab` に swap エントリが残っていない
