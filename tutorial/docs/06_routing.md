# 06章 ルーティングとパラメータ

## この章のゴール

- `config/routes.rb` の書き方が分かる
- URL の一部（`/greet/matsu` の `matsu`）を受け取れる
- クエリ文字列（`?style=shout`）を受け取れる
- **名前付きルート**（`about_path`）を使ってリンクを書ける

所要時間: 45 分

---

## 1. まず動かす

```powershell
ruby bin/rails routes
```

前章で追加した `root` と `about` が出ているはずです。

---

## 2. ルーティングの書き方

### 2-1. 基本形

```ruby
get "about", to: "pages#about"
#    ↑URL        ↑コントローラ#アクション
```

HTTP メソッドごとに `get` / `post` / `patch` / `put` / `delete` があります。

| HTTP メソッド | 意味 | 例 |
| --- | --- | --- |
| GET | 取得する | 一覧を見る、詳細を見る |
| POST | 新しく作る | フォーム送信 |
| PATCH / PUT | 更新する | 編集の保存 |
| DELETE | 削除する | 削除ボタン |

PHP では GET と POST しか使わないことが多かったと思いますが、
Rails では **同じ URL でも HTTP メソッドが違えば別の処理** になります。これが 09 章の CRUD の土台です。

### 2-2. URL の一部を受け取る

```ruby
get "greet/:name", to: "pages#greet"
```

`:name` の部分は何でもマッチし、コントローラで `params[:name]` として受け取れます。

```
/greet/matsu   →  params[:name] == "matsu"
/greet/ruby    →  params[:name] == "ruby"
```

### 2-3. 名前付きルート（`as:`）

```ruby
get "greet/:name", to: "pages#greet", as: :greet
```

`as: :greet` と書くと、`greet_path("matsu")` というメソッドが使えるようになります。

```erb
<%= link_to "あいさつ", greet_path("matsu") %>
```

これが生成する HTML は `<a href="/greet/matsu">あいさつ</a>` です。

> **なぜ `href="/greet/matsu"` と直接書かないのか**
> URL を後から変えたくなったとき、`routes.rb` の 1 行を直すだけで全リンクが追従するからです。
> 逆に直書きすると、全ファイルを grep して直すことになります。**Rails では必ずパスヘルパーを使ってください。**

`get "about", to: "pages#about"` のように `as:` を省略した場合も、
URL から自動で `about_path` という名前が付きます。名前は `ruby bin/rails routes` の Prefix 列で確認できます。

### 2-4. `params` の中身

`params` には 3 種類の値が混ざって入ってきます。

| 出どころ | 例 | 取り出し方 |
| --- | --- | --- |
| URL の一部 | `/greet/matsu` | `params[:name]` |
| クエリ文字列 | `/greet/matsu?style=shout` | `params[:style]` |
| フォームの送信内容 | POST の body | `params[:project][:name]` |

`params` はハッシュのように見えますが、`ActionController::Parameters` という専用クラスです。
**文字列キーでもシンボルキーでも同じ値が取れます**（`params["name"]` と `params[:name]` は同じ）。

そして重要なのは、**`params` の中身はすべて外部から来た信用できない値** ということです。
そのまま DB に流し込めないようになっています（09章の Strong Parameters）。

---

## 3. 課題

### 3-1. あいさつページを作る

- `config/routes.rb` に `/greet/:name` のルートを追加する（名前は `greet`）
- `PagesController` に `greet` アクションを追加する
  - `params[:name]` を受け取ってインスタンス変数に入れる
  - `params[:style]` が `"shout"` のときは、名前を大文字にする
- `app/views/pages/greet.html.erb` を作り、名前を表示する

確認:

- <http://localhost:3000/greet/matsu>
- <http://localhost:3000/greet/matsu?style=shout> ← 大文字になる

### 3-2. トップページからリンクを張る

`app/views/pages/home.html.erb` に、次の 2 つのリンクを追加してください。

- 「このアプリについて」→ `about_path`
- 「あいさつ」→ `greet_path("matsu")`

**必ず `link_to` とパスヘルパーを使うこと**（`<a href="/about">` と直書きしない）。

```erb
<%= link_to "表示する文字", パス %>
```

---

## 4. 自己チェック

```powershell
ruby bin/rails runner tutorial/check_rails.rb 06
```

---

## 5. 理解を深める（Claude への質問例）

- 「`ruby bin/rails routes` の出力の各列の意味を教えて」
- 「`greet_path` と `greet_url` の違いは？」
- 「`params[:name]` が来なかった場合、どうなる？ 安全に扱うには？」
- 「`resources :projects` と書くと 7 つのルートができるらしいが、それは何？」（次章以降の予習）

---

## 6. つまずきポイント

| 症状 | 原因 |
| --- | --- |
| `undefined local variable or method 'greet_path'` | `as:` を書いていない、またはルートが未定義。`ruby bin/rails routes` で Prefix 列を確認 |
| `/greet/matsu` が 404 | ルートの順番の問題か、パスの綴り違い |
| `params[:style]` が取れない | `?style=shout` のクエリを付けているか確認 |
| 日本語の名前で 404 | URL に日本語を入れるとエンコードが必要。半角英数で試す |

---

## 終わったら

`PROGRESS.md` を更新して [07章](07_models_migrations.md) へ。
次はいよいよデータベースです。
