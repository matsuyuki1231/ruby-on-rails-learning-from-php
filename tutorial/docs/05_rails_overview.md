# 05章 Rails の地図とはじめての画面

## この章のゴール

- Rails のディレクトリ構成が頭に入る
- リクエストが「ルーター → コントローラ → ビュー」と流れることを説明できる
- **ジェネレータを使わず手で** 画面を 1 枚作れる

所要時間: 60 分

これから 10 章かけて **タスク管理アプリ** を作ります。この章はその 1 枚目の画面です。

---

## 1. PHP との根本的な違い

PHP では、`about.php` というファイルを置けば `http://example.com/about.php` で見られました。
**ファイルの置き場所が URL** でした。

Rails は違います。

```
ブラウザ  →  ルーター       →  コントローラ        →  ビュー        →  ブラウザ
GET /about   config/routes.rb   PagesController#about   about.html.erb
             「この URL は          「データを用意する」    「HTML を組み立てる」
              誰の担当か」
```

**URL とファイルは自動では繋がりません。** `config/routes.rb` に書いて初めて繋がります。
面倒に見えますが、これのおかげで「URL を変えてもファイル構成は変えなくていい」
「1 つのコントローラで複数の URL を扱える」といった自由が手に入ります。

---

## 2. ディレクトリ地図

いま重要なのは太字の 4 つだけです。残りは必要になったら覚えれば十分です。

```
app/
├── controllers/   ← ★ リクエストを受け取る係
├── models/        ← ★ データベースと業務ルール（07章）
├── views/         ← ★ HTML のテンプレート
├── helpers/         ビューで使う小さなメソッド（08章）
├── assets/          CSS や画像
├── jobs/            非同期処理
└── mailers/         メール送信

config/
├── routes.rb      ← ★ URL の対応表
├── application.rb   アプリ全体の設定
├── environments/    development / test / production ごとの設定
└── locales/         翻訳ファイル（14章）

db/
├── migrate/         テーブル定義の変更履歴（07章）
├── schema.rb        いまのテーブル構造（自動生成。手で編集しない）
└── seeds.rb         初期データ

test/                テスト（12章）
```

---

## 3. まず動かす

```powershell
ruby bin/rails routes
```

いま存在する URL の一覧が出ます。まだ `/up`（ヘルスチェック）くらいしかありません。

読み方はこうです。

```
Prefix        Verb   URI Pattern     Controller#Action
rails_health  GET    /up(.:format)   rails/health#show
   ↑            ↑        ↑                  ↑
名前付きルート  HTTPメソッド  URL のパターン    担当（コントローラ#アクション）
```

---

## 4. 課題

トップページと「このアプリについて」ページを、**手で 3 つのファイルを作って** 実現してください。
ジェネレータ（`rails generate`）はまだ使いません。仕組みを手で追うためです。

### 4-1. ルーティングを書く

`config/routes.rb` を開いて、`Rails.application.routes.draw do ... end` の中に追記します。

- `/`（ルート）を `PagesController` の `home` アクションに繋ぐ
  - ヒント: `root "pages#home"`
- `/about` を `PagesController` の `about` アクションに繋ぐ
  - ヒント: `get "about", to: "pages#about"`

書いたら確認します。

```powershell
ruby bin/rails routes
```

### 4-2. コントローラを作る

`app/controllers/pages_controller.rb` を新規作成します。

- クラス名は `PagesController`、`ApplicationController` を継承する
- `home` と `about` という 2 つのメソッド（= アクション）を定義する
- `home` の中で、インスタンス変数に値を入れる
  - アプリ名（"タスク管理アプリ"）
  - 今日の日付（`Date.current` を使う）

```ruby
class PagesController < ApplicationController
  def home
    # ここでインスタンス変数に値を入れる
  end

  def about
  end
end
```

> **なぜインスタンス変数（`@` 付き）なのか**
> コントローラで `@app_name = "..."` と書いた変数だけが、ビューから見えます。
> ローカル変数（`app_name = "..."`）はビューに渡りません。ここが Rails の約束事です。

### 4-3. ビューを作る

`app/views/pages/home.html.erb` と `app/views/pages/about.html.erb` を新規作成します。

ファイル名の規則は **`app/views/コントローラ名/アクション名.html.erb`** です。
この規則があるので、コントローラのアクションに `render` を書かなくても勝手に対応するビューが表示されます。

`home.html.erb` の要件:

- `<h1>` の中にアプリ名を表示する（インスタンス変数を使うこと）
- 今日の日付を表示する

ERB の書き方は 2 種類です。

```erb
<%= 式 %>    結果を HTML に出力する
<%  式 %>    出力しない（if や each などの制御用）
```

```erb
<h1><%= @app_name %></h1>
<p>今日は <%= @today.strftime("%Y年%-m月%-d日") %> です。</p>
```

`about.html.erb` の要件:

- 「このアプリについて」という文字列を含めること

### 4-4. ブラウザで確認する

```powershell
ruby bin/rails server
```

<http://localhost:3000> と <http://localhost:3000/about> を開いてください。

---

## 5. 自己チェック

サーバーは起動したままで構いません。別のターミナルを開いて実行してください。

```powershell
ruby bin/rails runner tutorial/check_rails.rb 05
```

`✗` が出たら、その下のメッセージを読んで直します。

---

## 6. わざと壊して学ぶ（おすすめ）

理解を深めるために、次を試して **エラーメッセージを読んでください**。慣れると復旧が速くなります。

1. `config/routes.rb` の `root "pages#home"` を消す → `/` を開く
2. `app/views/pages/home.html.erb` の名前を `home2.html.erb` に変える → `/` を開く
3. コントローラの `def about` を消す → `/about` を開く

それぞれ違うエラーが出ます。「どのエラーが、どの段階の失敗なのか」が分かるようになります。
終わったら元に戻してください。

---

## 7. 理解を深める（Claude への質問例）

- 「`ApplicationController` は何をしている親クラス？」
- 「コントローラのアクションに `render` を書かなくてもビューが表示されるのはなぜ？」
- 「`app/views/layouts/application.html.erb` は何をしているファイル？」
- 「`root "pages#home"` の `pages#home` という書き方はどう解釈されている？」

---

## 8. つまずきポイント

| エラー | 意味 | 直し方 |
| --- | --- | --- |
| `No route matches [GET] "/about"` | ルーティングが無い | `config/routes.rb` に追記 |
| `uninitialized constant PagesController` | コントローラのファイル名かクラス名が違う | `pages_controller.rb` / `class PagesController` |
| `PagesController#about is missing a template` | ビューのファイルが無い | `app/views/pages/about.html.erb` を作る |
| `undefined method 'strftime' for nil` | コントローラで `@today` を入れ忘れている | `home` アクションを確認 |

---

## 終わったら

`PROGRESS.md` を更新して [06章](06_routing.md) へ。
