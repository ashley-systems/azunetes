# VM Bootstrap for Ansible

Debian 13 Trixie の VM に対して、`ansible` ユーザ作成、GitHub Actions 用 SSH 公開鍵登録、sudo 実行に必要な初期設定を行うための最小 runbook。

## 前提条件

- 対象 VM は Debian 13 Trixie
- `root` でログインできる、または同等権限で実行できる
- GitHub Actions から接続するための OpenSSH 公開鍵を 1 行文字列で用意済み
- `sudo` が利用可能

## 実行方法

```sh
chmod +x scripts/bootstrap-ansible-user.sh
sudo ./scripts/bootstrap-ansible-user.sh \
  --authorized-key "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBexamplepublickeyforgithubactions github-actions"
```

`--authorized-key` には GitHub Actions で使う SSH 鍵ペアの公開鍵を渡す。

続けて、`ansible` ユーザに sudo 用パスワードを設定する。

```sh
sudo passwd ansible
```

## 実行後の状態

- `ansible` ユーザが存在する
- `~ansible/.ssh/authorized_keys` に指定公開鍵が登録される
- `ansible` ユーザが `sudo` グループに所属する
- 同じ公開鍵で再実行しても重複登録されない

## 確認例

```sh
id ansible
sudo stat -c '%a %U %G %n' /home/ansible/.ssh /home/ansible/.ssh/authorized_keys
```

Ansible 実行時は `-K` / `--ask-become-pass`、または `ansible_become_pass` を使って sudo パスワードを渡す。

## 非対象

- SSH 元 IP 制限
- `PasswordAuthentication` の無効化
- `PermitRootLogin` の無効化
- 基本パッケージ導入
- ホスト名設定
- Ansible playbook 実行

## 後続フロー

- production の inventory や具体的なデプロイ値は public repository には置かない
- 実値管理と GitHub Actions からの playbook 実行は private repository `azunetes-deploy` 側で扱う
