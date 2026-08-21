# 09章 CRUD とフォーム

## この章のゴール

- 7 つのアクションを全部書く
- `form_with` でフォームを作れる
- **Strong Parameters** の意味と必要性が説明できる
- `redirect_to` と `render` を使い分けられる
- `flash` でメッセージを出せる

所要時間: 90 分

---

## 1. 全体像

新規作成と編集は、それぞれ **2 つのアクションのペア** でできています。

```
[新規作成]
GET  /projects/new   → new     フォームを表示する
POST /projects       → create  受け取って保存する

[編集]
GET  /projects/1/edit → edit    フォームを表示する
PATCH /projects/1     → update  受け取って保存する

[削除]
DELETE /projects/1    → destroy 消す
```

PHP で `if ($_SERVER['REQUEST_METHOD'] === 'POST') { ... } else { ... }` と
1 ファイルに書いていた分岐が、**HTTP メソッドとアクションに分解されている** と考えてください。

---

## 2. 課題

### 2-1. ルーティングを全開放する

```ruby
resources :projects      # only: を外す
```

```powershell
ruby bin/rails routes
```

7 本出ることを確認してください。

### 2-2. コントローラを書く

`app/controllers/projects_controller.rb` に 5 つのアクションを足します。

```ruby
class ProjectsController < ApplicationController
  before_action :set_project, only: %i[show edit update destroy]

  def index
    @projects = Project.order(:due_on)
  end

  def show
  end

  def new
    @project = Project.new       # 空のフォーム用のオブジェクト
  end

  def create
    @project = Project.new(project_params)

    if @project.save
      redirect_to @project, notice: "プロジェクトを作成しました。"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to @project, notice: "プロジェクトを更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_path, notice: "プロジェクトを削除しました。", status: :see_other
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.expect(project: [ :name, :description, :due_on ])
  end
end
```

**写経で構いませんが、次の 4 点は必ず理解してください。**

#### ① `before_action`

`show` / `edit` / `update` / `destroy` の前に `set_project` を実行する、という宣言です。
4 箇所に同じ `Project.find(params[:id])` を書かずに済みます。

#### ② Strong Parameters（`project_params`）

```ruby
params.expect(project: [ :name, :description, :due_on ])
```

これは **「フォームから受け取ってよい項目のホワイトリスト」** です。

なぜ必要か。もしこれが無く `Project.new(params[:project])` と書けたら、
攻撃者がフォームに `<input name="project[admin]" value="1">` を勝手に足すだけで
管理者フラグを立てられてしまいます（Mass Assignment 脆弱性）。

だから Rails は **明示的に許可した項目以外を弾きます**。
`params.expect` は Rails 8 の書き方で、古い資料では `params.require(:project).permit(:name, ...)` と書かれています。

#### ③ `redirect_to` と `render` の違い ← 最頻出の混乱ポイント

| | `redirect_to` | `render` |
| --- | --- | --- |
| 何をする | ブラウザに「別の URL へ行け」と返す | その場で HTML を組み立てて返す |
| リクエスト回数 | 2 回（302 → 改めて GET） | 1 回 |
| インスタンス変数 | 引き継がれない | そのまま使える |
| 使う場面 | 保存に **成功** したとき | 保存に **失敗** してフォームを出し直すとき |

失敗時に `render :new` を使うのは、**エラー情報が入った `@project` をそのままフォームに渡したい** からです。
`redirect_to new_project_path` にすると、入力内容もエラーも全部消えてしまいます。

#### ④ `status: :unprocessable_entity`（422）

バリデーション失敗時は「200 OK」ではなく 422 を返すのが Rails の作法です。

### 2-3. フォームを作る

`app/views/projects/_form.html.erb` を作り、`new` と `edit` の **両方から使い回します**。

```erb
<%= form_with model: project do |form| %>
  <div>
    <%= form.label :name, "名前" %>
    <%= form.text_field :name %>
  </div>

  <div>
    <%= form.label :description, "説明" %>
    <%= form.text_area :description, rows: 4 %>
  </div>

  <div>
    <%= form.label :due_on, "期限" %>
    <%= form.date_field :due_on %>
  </div>

  <%= form.submit %>
<% end %>
```

`form_with model: project` の賢いところ:

| 渡したもの | 生成される form の action | メソッド |
| --- | --- | --- |
| 新規（未保存）の Project | `/projects` | POST |
| 保存済みの Project | `/projects/1` | PATCH |

**同じテンプレートが、新規作成にも編集にも使えます。**
入力欄の `name` 属性は `project[name]` になり、これが `params[:project][:name]` として届きます。

`new.html.erb` と `edit.html.erb` から呼びます。

```erb
<%= render "form", project: @project %>
```

### 2-4. 一覧・詳細からの導線

- `index.html.erb` に「新しいプロジェクト」リンク（`new_project_path`）
- `show.html.erb` に「編集」リンク（`edit_project_path(@project)`）と削除ボタン

削除は DELETE メソッドで送る必要があるため、リンクではなくボタンを使います。

```erb
<%= button_to "削除", @project, method: :delete %>
```

### 2-5. flash を表示する

`redirect_to ..., notice: "..."` で渡したメッセージを画面に出します。
`app/views/layouts/application.html.erb` に追加してください。

```erb
<% if flash[:notice] %>
  <p class="notice"><%= flash[:notice] %></p>
<% end %>
<% if flash[:alert] %>
  <p class="alert"><%= flash[:alert] %></p>
<% end %>
```

`flash` は **次の 1 リクエストだけ生き残るセッション** です。リダイレクト先で 1 回表示されて消えます。

---

## 3. 動作確認

ブラウザで一通り操作してください。

1. 一覧 → 新しいプロジェクト → 作成 → 詳細に飛んでメッセージが出る
2. 編集 → 更新 → 内容が変わる
3. 削除 → 一覧に戻る

---

## 4. 自己チェック

```powershell
ruby bin/rails runner tutorial/check_rails.rb 09
```

---

## 5. 理解を深める（Claude への質問例）

- 「`form_with` が生成する HTML を見せて。`authenticity_token` は何？」
- 「CSRF 攻撃とは何で、Rails はどう防いでいる？」
- 「`redirect_to @project` はなぜ動く？ 何に変換されている？」
- 「`status: :see_other`（303）を destroy で使う理由は？」

---

## 6. つまずきポイント

| 症状 | 原因 |
| --- | --- |
| `param is missing or the value is empty: project` | フォームの `name` 属性が `project[...]` になっていない。`form_with model:` を使う |
| 保存されるが一部の項目が空 | Strong Parameters に項目を追加し忘れ |
| 更新したのに変わらない | `update` に `project_params` を渡し忘れ |
| 削除ボタンで詳細ページが開く | `link_to` を使っている。`button_to ... method: :delete` に変える |
| フォーム送信後に入力内容が消える | 失敗時に `redirect_to` している。`render :new` に変える |

---

## 終わったら

`PROGRESS.md` を更新して [10章](10_validations.md) へ。
いまは名前が空でも保存できてしまうはずです。次はそれを塞ぎます。
