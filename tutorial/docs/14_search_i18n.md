# 14章 検索と日本語化

## この章のゴール

- 検索フォーム（GET のフォーム）を作れる
- `scope` に引数を渡せる
- **SQL インジェクションと LIKE のワイルドカード**に正しく対処できる
- エラーメッセージを日本語にできる（I18n）

所要時間: 75 分

---

## 1. 検索フォーム

一覧を絞り込む検索は、**GET** で送ります。

```erb
<%= form_with url: projects_path, method: :get do |form| %>
  <%= form.search_field :q, value: params[:q], placeholder: "プロジェクト名で検索" %>
  <%= form.submit "検索" %>
<% end %>
```

送信すると `/projects?q=学習` になります。GET にする理由:

- URL を共有・ブックマークできる
- 戻るボタンで戻れる
- 「取得するだけ」で副作用が無い（HTTP の作法）

`value: params[:q]` を書いておくと、検索後もフォームにキーワードが残ります。

---

## 2. 引数を取る scope

```ruby
class Project < ApplicationRecord
  scope :search, ->(keyword) {
    next all if keyword.blank?

    where("name LIKE ?", "%#{sanitize_sql_like(keyword)}%")
  }
end
```

ポイントが 3 つあります。

### ① キーワードが空なら絞り込まない

`next all` で「全件」を返します。`nil` を返すとチェーンが切れてエラーになります。
（ラムダの中では `return` ではなく `next` を使います）

### ② プレースホルダを使う ← セキュリティの本丸

```ruby
where("name LIKE '%#{keyword}%'")        # ❌ 絶対に書かない（SQL インジェクション）
where("name LIKE ?", "%#{keyword}%")     # ⭕ ? に値を差し込ませる
```

PHP でプリペアドステートメントを使っていたのと同じ理由です。
`?` を使えば、Rails が値を安全にエスケープします。

### ③ `sanitize_sql_like`

`?` を使っても、**LIKE のワイルドカードは別問題** です。

```ruby
# keyword が "%" のとき
where("name LIKE ?", "%%%")     # → 全件ヒットしてしまう
```

`sanitize_sql_like` は `%` と `_` をただの文字に変換します。
「検索キーワードに記号を入れたら全件出た」という不具合は、これで防げます。

コントローラ側:

```ruby
@projects = Current.user.projects.includes(:tasks).search(params[:q]).order(:due_on)
```

`scope` を挟むだけで済むのが、チェーンできる設計の利点です。

---

## 3. 日本語化（I18n）

いまエラーメッセージは `Name can't be blank` と英語です。これを直します。

### 3-1. 既定のロケールを変える

`config/application.rb` の `class Application < Rails::Application` の中に追加します。

```ruby
config.i18n.default_locale = :ja
config.i18n.available_locales = %i[ja en]
```

**設定を変えたらサーバーの再起動が必要です。**

### 3-2. 翻訳ファイルを書く

`config/locales/ja.yml` を新規作成します。

```yaml
ja:
  date:
    formats:
      default: "%Y/%m/%d"

  activerecord:
    models:
      project: プロジェクト
      task: タスク
      user: ユーザー
    attributes:
      project:
        name: 名前
        description: 説明
        due_on: 期限
        user: ユーザー
      task:
        title: タイトル
        done: 完了
        project: プロジェクト

  errors:
    format: "%{attribute}%{message}"
    messages:
      blank: を入力してください
      required: を入力してください
      taken: はすでに使われています
      too_long: は%{count}文字以内で入力してください
      too_short: は%{count}文字以上で入力してください
      invalid: の形式が正しくありません
```

仕組みはこうです。

```
errors.format = "%{attribute}%{message}"
                     ↓            ↓
              「名前」    +  「を入力してください」
                     ↓
              「名前を入力してください」
```

- `activerecord.models` … モデル名の訳
- `activerecord.attributes` … カラム名の訳
- `errors.messages` … エラーの文言

**YAML はインデントが命です。** 半角スペース 2 つで揃えてください（タブは使えません）。

### 3-3. 確認する

```powershell
ruby bin/rails console
```

```ruby
Project.model_name.human               #=> "プロジェクト"
Project.human_attribute_name(:name)    #=> "名前"

project = Project.new(name: "")
project.valid?
project.errors.full_messages           #=> ["名前を入力してください", ...]
```

英語のままのメッセージが混じっていたら、**そのキーが `ja.yml` に無い** ということです。
Rails は見つからないと英語（か `Translation missing`）を出すので、逆に何を足せばいいか分かります。

---

## 4. 課題

### 4-1. 検索

- `Project` に `scope :search` を追加する（空なら全件、`sanitize_sql_like` を使う）
- `ProjectsController#index` で `search(params[:q])` を挟む
- `index.html.erb` に検索フォームを追加する

動作確認:

- キーワードなし → 全件
- 「学習」で検索 → 該当だけ
- 「%」で検索 → 0 件（全件出たら `sanitize_sql_like` が抜けています）

### 4-2. 日本語化

- `config/application.rb` にロケール設定
- `config/locales/ja.yml` を作成
- **サーバーを再起動**して、名前を空でプロジェクトを作ろうとしたときのエラーが
  「名前を入力してください」になることを確認

### 4-3. 余力があれば

- `ja.yml` に `helpers.submit.create` / `helpers.submit.update` を足して、
  送信ボタンの文言（「Create Project」）も日本語にする
- 一覧に「期限が近い順 / 名前順」の並べ替えを追加する

---

## 5. 自己チェック

```powershell
ruby bin/rails runner tutorial/check_rails.rb 14
ruby bin/rails runner tutorial/check_rails.rb all
```

`all` で 05〜14 のすべてが緑になれば、アプリは完成です。

---

## 6. 理解を深める（Claude への質問例）

- 「`rails-i18n` gem を入れると何が楽になる？ 自分で書くのとの違いは？」
- 「`t("...")` ヘルパーでビューの文言も翻訳するには？」
- 「検索が遅くなってきたら、まず何をする？（インデックス、全文検索）」
- 「`LIKE '%キーワード%'` の前方ワイルドカードがインデックスを使えない理由は？」

---

## 7. つまずきポイント

| 症状 | 原因 |
| --- | --- |
| 日本語にならない | サーバーを再起動していない |
| `Translation missing` | `ja.yml` のキーの階層が違う。エラーに「探したキー」が全部出るので読む |
| YAML の読み込みエラー | インデントにタブを使っている |
| 検索で 0 件 | `params[:q]` の名前が合っているか。`p params` で確認 |
| 「%」で全件出る | `sanitize_sql_like` を使っていない |

---

## 終わったら

`PROGRESS.md` を更新して [15章](15_capstone.md) へ。
最後は、誰にも指示されずに自分で作る課題です。
