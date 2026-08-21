# 08章 コントローラとビュー

## この章のゴール

- `resources` で 7 本のルートがまとめて定義できることを知る
- 一覧ページと詳細ページを作れる
- **パーシャル**（部分テンプレート）でビューを分割できる
- **ヘルパー**で表示ロジックをビューから追い出せる
- レイアウトの役割が分かる

所要時間: 75 分

---

## 1. ジェネレータでコントローラを作る

```powershell
ruby bin/rails generate controller Projects index show
```

> **コントローラ名は複数形**（`Projects`）です。モデルは単数形（`Project`）でした。この対比を覚えてください。

生成されたもの:

- `app/controllers/projects_controller.rb`
- `app/views/projects/index.html.erb` と `show.html.erb`
- `app/helpers/projects_helper.rb`
- `test/controllers/projects_controller_test.rb`

そして **`config/routes.rb` に勝手に 2 行足されています**。

```ruby
get "projects/index"
get "projects/show"
```

これは仮のルートです。次の手順で消して、正しい形に書き換えます。

---

## 2. `resources` を知る

Rails では、1 つのリソース（ここでは「プロジェクト」）に対する URL の並びが決まっています。

```ruby
resources :projects
```

この 1 行が、次の 7 本のルートに展開されます。

| HTTP | URL | アクション | 意味 |
| --- | --- | --- | --- |
| GET | /projects | index | 一覧 |
| GET | /projects/new | new | 新規作成フォーム |
| POST | /projects | create | 作成する |
| GET | /projects/:id | show | 詳細 |
| GET | /projects/:id/edit | edit | 編集フォーム |
| PATCH/PUT | /projects/:id | update | 更新する |
| DELETE | /projects/:id | destroy | 削除する |

同じ URL `/projects` でも、GET なら一覧、POST なら作成です。
この設計を **REST** と呼びます。Rails のアプリは基本的にこの形に揃えます。

この章ではまだ一覧と詳細だけなので、絞って書きます。

```ruby
resources :projects, only: %i[index show]
```

生成されるパスヘルパー:

| ヘルパー | URL |
| --- | --- |
| `projects_path` | /projects |
| `project_path(project)` | /projects/1 |
| `new_project_path` | /projects/new |
| `edit_project_path(project)` | /projects/1/edit |

`link_to "詳細", project` のように **モデルのオブジェクトをそのまま渡す** こともできます（Rails が `project_path(project)` に変換します）。

---

## 3. 課題

### 3-1. ルーティングを整える

`config/routes.rb` から、ジェネレータが書いた `get "projects/index"` と `get "projects/show"` を削除し、
代わりに `resources :projects, only: %i[index show]` を書いてください。

```powershell
ruby bin/rails routes
```

### 3-2. コントローラ

`app/controllers/projects_controller.rb`

- `index` … `@projects` に全プロジェクトを入れる。期限順（`order(:due_on)`）に並べる
- `show` … `params[:id]` を使って 1 件を探し、`@project` に入れる

```ruby
def show
  @project = Project.find(params[:id])
end
```

### 3-3. 一覧ページ（パーシャルを使う）

`app/views/projects/index.html.erb` に一覧を表示します。
ただし **1 件分の表示は別ファイル（パーシャル）に切り出してください**。

`app/views/projects/_project.html.erb`（ファイル名の先頭のアンダースコアがパーシャルの目印）

```erb
<article>
  <h2><%= link_to project.name, project %></h2>
  <p><%= project.description %></p>
</article>
```

パーシャルの中では `@project` ではなく **ローカル変数 `project`** を使います。

`index.html.erb` からの呼び出しは、次のどちらでも書けます。

```erb
<%= render partial: "project", collection: @projects %>
<%= render @projects %>      <%# 省略形。配列を渡すと _project.html.erb を各要素で描く %>
```

後者の短い形が Rails の慣用句です。**モデル名からパーシャル名を推測する規約** が効いています。

要件:

- `<h1>` に「プロジェクト一覧」
- 件数を表示する
- 各プロジェクトの名前が、詳細ページへのリンクになっている

### 3-4. 詳細ページ

`app/views/projects/show.html.erb`

- `<h1>` にプロジェクト名
- 説明と期限を表示
- 一覧へ戻るリンク

### 3-5. ヘルパーを作る

期限の表示（`nil` のときは「未設定」、あるときは「2026/09/18（あと30日）」）を
ビューに直接書くと読みにくくなります。**ヘルパー**に切り出してください。

`app/helpers/projects_helper.rb`

```ruby
module ProjectsHelper
  def format_due_on(date)
    return "未設定" if date.nil?

    # 「2026/09/18（あと30日）」のような文字列を返す
  end
end
```

ヘルパーはすべてのビューから呼べます。一覧と詳細の両方で使ってください。

> **なぜヘルパーに出すのか**
> ビューは「見た目の構造」に集中させ、条件分岐や整形はヘルパーへ。
> あとでテストも書けるようになります。

### 3-6. レイアウトに共通ナビを置く

`app/views/layouts/application.html.erb` の `<%= yield %>` の上に、
全ページ共通のナビゲーションを追加してください。

- ホーム（`root_path`）
- プロジェクト（`projects_path`）
- このアプリについて（`about_path`）

`<%= yield %>` の場所に、各ページのビューが差し込まれます。
つまり **レイアウトは「外枠」、ビューは「中身」** です。

---

## 4. 自己チェック

```powershell
ruby bin/rails runner tutorial/check_rails.rb 08
```

ブラウザでも <http://localhost:3000/projects> を確認してください。

---

## 5. 理解を深める（Claude への質問例）

- 「`render @projects` だけで `_project.html.erb` が呼ばれる仕組みを説明して」
- 「パーシャルに変数を渡す方法（`locals`）の書き方は？」
- 「ヘルパーとモデルのメソッド、どちらに書くべきかの判断基準は？」
- 「`link_to "詳細", project` が `/projects/1` になるのはなぜ？」

---

## 6. つまずきポイント

| 症状 | 原因 |
| --- | --- |
| `undefined method 'each' for nil` | コントローラで `@projects` を入れ忘れ、またはビューで変数名が違う |
| パーシャルが見つからない | ファイル名の先頭に `_` が無い |
| パーシャルで `undefined local variable 'project'` | パーシャル内で `@project` を使っている、または `render` の呼び方が違う |
| `Couldn't find Project with 'id'=999` | 存在しない ID。404 になるのは正しい挙動 |
| リンクが 404 | `link_to` の第 2 引数がパスヘルパーになっているか確認 |

---

## 終わったら

`PROGRESS.md` を更新して [09章](09_crud_forms.md) へ。
次は「作る・更新する・消す」です。
