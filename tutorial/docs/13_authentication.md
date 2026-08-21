# 13章 ログイン機能をつける

## この章のゴール

- Rails 8 の認証ジェネレータで、ログイン機能を導入できる
- `has_secure_password` の仕組みが説明できる
- 既存データを壊さずにカラムを追加できる（backfill）
- 「他人のデータが見えない」設計ができる
- 仕様変更で壊れたテストを直せる

所要時間: 120 分（この章がいちばん実務的です）

---

## 1. 認証を自分で書かない理由

パスワードの保存、セッションの管理、総当たり攻撃への対策……
認証は「自分で書くと必ずどこかを間違える」領域です。

Rails 8 には認証の雛形を生成するコマンドが入りました。これを使います。

```powershell
ruby bin/rails generate authentication
```

生成されるもの:

| ファイル | 役割 |
| --- | --- |
| `app/models/user.rb` | ユーザー |
| `app/models/session.rb` | ログインセッション（DB に保存される） |
| `app/models/current.rb` | いまのリクエストの「現在のユーザー」を保持する |
| `app/controllers/concerns/authentication.rb` | 認証の共通処理 |
| `app/controllers/sessions_controller.rb` | ログイン / ログアウト |
| `app/controllers/passwords_controller.rb` | パスワード再設定 |
| `app/views/sessions/`, `app/views/passwords/` | その画面 |

さらに `Gemfile` に `bcrypt` が追加され、`config/routes.rb` に 2 行足されます。

```powershell
ruby bin/rails db:migrate
```

---

## 2. 仕組みを読む

### `has_secure_password`

`app/models/user.rb` にこの 1 行があります。

```ruby
class User < ApplicationRecord
  has_secure_password
end
```

これだけで次が手に入ります。

- `user.password = "秘密"` と書くと、bcrypt でハッシュ化して `password_digest` カラムに保存
- `user.authenticate("秘密")` で照合
- `password` と `password_confirmation` の一致チェック

**平文のパスワードはどこにも保存されません。** `password_digest` に入るのはハッシュ値だけです。

### `ApplicationController` に入った 1 行

```ruby
class ApplicationController < ActionController::Base
  include Authentication
end
```

`Authentication` は `before_action :require_authentication` を仕掛けます。
つまり **既定で全ページがログイン必須** になります。

公開したいページには、コントローラで例外を宣言します。

```ruby
class PagesController < ApplicationController
  allow_unauthenticated_access only: %i[home about greet]
end
```

> **この設計思想を覚えてください**: 「既定で閉じ、必要なものだけ開ける」。
> 逆（既定で開け、必要なものを閉じる）にすると、閉じ忘れが事故になります。

### `Current.user`

コントローラでもビューでも `Current.user` で現在のユーザーが取れます。
リクエストごとにリセットされる特別な入れ物です。

---

## 3. ユーザーを作ってログインしてみる

```powershell
ruby bin/rails console
```

```ruby
User.create!(email_address: "me@example.com", password: "password123")
```

サーバーを起動して <http://localhost:3000/projects> を開いてください。
ログイン画面（`/session/new`）に飛ばされるはずです。作ったメールアドレスとパスワードで入れます。

---

## 4. プロジェクトに持ち主を持たせる

いまは全員が全プロジェクトを見られる状態です。これを直します。

### 4-1. マイグレーション

**既存のプロジェクトが 3 件あるのに `user_id` を NOT NULL で追加すると失敗します。**
実務でよくある状況なので、正しい手順を踏みます。

```powershell
ruby bin/rails generate migration AddUserToProjects user:references
```

生成されたファイルを、次のように書き換えてください。

```ruby
class AddUserToProjects < ActiveRecord::Migration[8.1]
  def up
    # 1. まずは NULL を許して列を足す
    add_reference :projects, :user, foreign_key: true

    # 2. 既存データに持ち主を割り当てる（backfill）
    if (owner = User.first)
      Project.update_all(user_id: owner.id)
      change_column_null :projects, :user_id, false
    end

    # 3. 名前の重複判定を「ユーザーごと」に張り替える
    remove_index :projects, :name
    add_index :projects, [ :user_id, :name ], unique: true
  end

  def down
    remove_index :projects, [ :user_id, :name ]
    add_index :projects, :name, unique: true
    remove_reference :projects, :user
  end
end
```

> **`change` ではなく `up` / `down` を書いた理由**
> `change` は「逆操作を Rails が推測できる」ときだけ使えます。
> データの書き換え（backfill）が入ると推測できないので、明示的に書きます。

```powershell
ruby bin/rails db:migrate
```

### 4-2. モデル

- `Project` に `belongs_to :user`
- `Project` の `name` の重複チェックをユーザー単位にする
  - `uniqueness: { scope: :user_id }`
- `User` に `has_many :projects, dependent: :destroy`

### 4-3. コントローラ ← ここが本章の肝

`ProjectsController` の `Project` を、すべて `Current.user.projects` に置き換えてください。

```ruby
def index
  @projects = Current.user.projects.includes(:tasks).order(:due_on)
end

def new
  @project = Current.user.projects.build
end

def create
  @project = Current.user.projects.build(project_params)
  # ...
end

def set_project
  @project = Current.user.projects.find(params[:id])
end
```

`TasksController` の `set_project` も同様に直します。

**なぜこれで安全なのか**

```ruby
Project.find(params[:id])              # 他人のプロジェクトも取れてしまう
Current.user.projects.find(params[:id])  # 自分のものだけ。他人のなら RecordNotFound（404）
```

「権限チェックを `if` で書く」のではなく、**そもそも見える範囲を絞る**。
これが Rails で一番事故が少ないやり方です。

### 4-4. 画面

`app/views/layouts/application.html.erb` のナビゲーションに追加してください。

```erb
<% if authenticated? %>
  <%= Current.user.email_address %>
  <%= button_to "ログアウト", session_path, method: :delete %>
<% else %>
  <%= link_to "ログイン", new_session_path %>
<% end %>
```

### 4-5. seed を直す

`db/seeds.rb` はもう動きません（`user_id` が無いため）。ユーザーを作り、その配下にプロジェクトを作るよう直してください。

```ruby
user = User.find_or_create_by!(email_address: "me@example.com") do |u|
  u.password = "password123"
end

[ ... ].each do |attributes|
  user.projects.find_or_create_by!(name: attributes[:name]) do |project|
    # ...
  end
end
```

### 4-6. トップページは公開のままにする

`PagesController` に `allow_unauthenticated_access` を追加してください。

---

## 5. 壊れたテストを直す ← 実務そのもの

```powershell
ruby bin/rails db:test:prepare
ruby bin/rails test
```

**大量に落ちます。** これが正常です。仕様が変わったのだからテストも変わります。

直すべき点は 3 つ:

### ① fixtures にユーザーを紐付ける

`test/fixtures/users.yml` はジェネレータが作ってくれています（`one` と `two`）。
`test/fixtures/projects.yml` の各プロジェクトに `user: one` を追加してください。

「他人のプロジェクト」を確かめるために、`user: two` のプロジェクトも 1 件足しておくと便利です。

### ② テストでログインする

ジェネレータが `test/test_helpers/session_test_helper.rb` を作っています。
統合テストの `setup` で呼んでください。

```ruby
setup do
  sign_in_as users(:one)
end
```

### ③ モデルテストをユーザー経由に直す

```ruby
project = Project.new(name: "x")            # user がいないので必ず無効になってしまう
project = users(:one).projects.build(name: "x")   # こう直す
```

### 追加で書いてほしいテスト

- ログインしていなければログイン画面にリダイレクトされる（`sign_out` を使う）
- 他人のプロジェクトを開くと 404 になる

> **ヒント**: 統合テストの中では、コントローラで起きた `RecordNotFound` は例外として飛んでこず、
> Rails が 404 レスポンスに変換します。`assert_response :not_found` で確かめてください。

---

## 6. 自己チェック

```powershell
ruby bin/rails runner tutorial/check_rails.rb 13
```

このチェックは `ruby bin/rails test` も走らせます。テストが全部通っている必要があります。

---

## 7. 理解を深める（Claude への質問例）

- 「bcrypt はなぜ「わざと遅い」ハッシュ関数なのか」
- 「`Current` はどうやってリクエストごとに分離されている？ スレッドとの関係は？」
- 「セッションを DB に保存する方式と、cookie に全部入れる方式の違いは？」
- 「`Current.user.projects.find` が 404 を返す設計と、`403 Forbidden` を返す設計、どちらが良い？」

---

## 8. つまずきポイント

| 症状 | 原因 |
| --- | --- |
| 全ページがログイン画面に飛ぶ | 正常。公開したいコントローラに `allow_unauthenticated_access` |
| `NOT NULL constraint failed: projects.user_id` | seed か fixtures で user を渡していない |
| マイグレーションが途中で失敗した | `db:rollback` してから書き直す。SQLite なら `storage/development.sqlite3` を消して作り直す手もある |
| テストが大量に落ちる | 想定どおり。fixtures → sign_in → モデルテストの順に直す |
| ログインしてもすぐ戻される | cookie が保存されていない。ブラウザの設定かポートを確認 |

---

## 終わったら

`PROGRESS.md` を更新して [14章](14_search_i18n.md) へ。
機能はほぼ完成です。最後に使い勝手を整えます。
