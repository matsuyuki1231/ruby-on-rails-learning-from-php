# 10章 バリデーションとエラー表示

## この章のゴール

- モデルにバリデーションを書ける
- `valid?` と `errors` の中身を説明できる
- 独自のバリデーションを書ける
- データベース側の制約も併せて張れる（なぜ両方必要か分かる）
- フォームにエラーを表示できる

所要時間: 75 分

---

## 1. なぜモデルに書くのか

PHP では、フォームの受け取り処理の中で入力チェックを書くことが多かったと思います。
Rails では **モデルに書きます**。

理由は、データの入り口がフォームだけではないからです。

```
フォーム    ┐
API        ├→ Project モデル → データベース
コンソール  ┤
seed       ┘
```

モデルに書けば、どの経路から来ても同じルールが効きます。

---

## 2. 書き方

```ruby
class Project < ApplicationRecord
  validates :name, presence: true,
                   length: { maximum: 50 },
                   uniqueness: true
end
```

### よく使うバリデーション

| 書き方 | 意味 |
| --- | --- |
| `presence: true` | 空でないこと |
| `length: { maximum: 50 }` | 最大文字数 |
| `length: { minimum: 3 }` | 最小文字数 |
| `uniqueness: true` | 重複しないこと |
| `numericality: { greater_than: 0 }` | 数値であること、範囲 |
| `inclusion: { in: %w[todo doing done] }` | 決められた値のどれかであること |
| `format: { with: /\A[\w.]+@\w+\z/ }` | 正規表現に合うこと |

### 動きを確かめる

```ruby
# rails console
project = Project.new(name: "")
project.valid?              #=> false
project.errors.full_messages
#=> ["Name can't be blank"]

project.save                #=> false（保存されない）
project.save!               #=> ActiveRecord::RecordInvalid（例外）
```

`valid?` を呼ぶとバリデーションが走り、結果が `errors` に溜まります。
`save` は内部で `valid?` を呼び、false なら保存しません。

### 独自のバリデーション

決まった書き方で足りないときは、メソッドを書きます。

```ruby
class Project < ApplicationRecord
  validate :due_on_cannot_be_past, on: :create

  private

  def due_on_cannot_be_past
    return if due_on.blank?

    errors.add(:due_on, "は今日以降の日付にしてください") if due_on < Date.current
  end
end
```

- `validates`（s あり）… 用意された検証を使う
- `validate`（s なし）… 自分で書いたメソッドを使う
- `on: :create` … 新規作成のときだけ検証する

> **なぜ `on: :create` なのか**
> 期限を過去にできない制約を更新時にも掛けると、
> 「期限が過ぎたプロジェクトの説明文を直す」ことすらできなくなります。
> **制約は「いつ効くべきか」まで含めて設計する**、という良い例です。

---

## 3. データベース側の制約も張る

モデルのバリデーションだけでは不十分です。

- `Project.update_all` や直接の SQL はバリデーションを通りません
- 2 つのリクエストが同時に来ると、重複チェックをすり抜けることがあります（競合状態）

そこで **DB にも制約を張ります**。マイグレーションを追加してください。

```powershell
ruby bin/rails generate migration AddUniqueIndexToProjectsName
```

生成されたファイルに書きます。

```ruby
class AddUniqueIndexToProjectsName < ActiveRecord::Migration[8.1]
  def change
    change_column_null :projects, :name, false      # NOT NULL 制約
    add_index :projects, :name, unique: true        # ユニークインデックス
  end
end
```

```powershell
ruby bin/rails db:migrate
```

> **役割分担**
> - モデルのバリデーション … 利用者に親切なエラーメッセージを出すため
> - DB の制約 … 最後の砦。データを絶対に壊さないため
>
> 両方書くのが正解です。

---

## 4. 課題

### 4-1. `Project` にバリデーションを追加する

- `name` は必須
- `name` は 50 文字以内
- `name` は重複禁止
- `due_on` は新規作成時に過去の日付を禁止（独自バリデーション）

### 4-2. マイグレーションで DB 制約を追加する

上の手順どおり。

### 4-3. フォームにエラーを表示する

`app/views/projects/_form.html.erb` の先頭に、エラー一覧を追加してください。

```erb
<% if project.errors.any? %>
  <div id="error_explanation">
    <h2><%= project.errors.count %> 件のエラーがあります</h2>
    <ul>
      <% project.errors.full_messages.each do |message| %>
        <li><%= message %></li>
      <% end %>
    </ul>
  </div>
<% end %>
```

### 4-4. 動作確認

1. 名前を空にして「作成」→ エラーが表示され、**説明欄に入力した内容が残っている** こと
2. 既存と同じ名前で「作成」→ エラーになること
3. 期限に昨日の日付を入れて「作成」→ エラーになること

エラーメッセージが英語（`Name can't be blank`）なのは想定どおりです。14 章で日本語にします。

---

## 5. 自己チェック

```powershell
ruby bin/rails runner tutorial/check_rails.rb 10
```

---

## 6. 理解を深める（Claude への質問例）

- 「`validates` と `validate` の違いを整理して」
- 「`uniqueness: true` だけでは競合状態を防げない理由を具体的に説明して」
- 「`errors.add` の第 1 引数に `:base` を渡すとどうなる？」
- 「`save(validate: false)` はどんなときに使う？ 危険は？」

---

## 7. つまずきポイント

| 症状 | 原因 |
| --- | --- |
| エラーが表示されない | `render :new` ではなく `redirect_to` している |
| `SQLite3::ConstraintException` | DB 制約に引っかかっている。既存データが制約違反かも |
| `change_column_null` でマイグレーション失敗 | 既に `name` が空のレコードがある。先に直すか消す |
| バリデーションが効かない | `validates` の綴り違い（`validate` になっている） |

---

## 終わったら

`PROGRESS.md` を更新して [11章](11_associations.md) へ。
次はいよいよ「タスク」を追加して、テーブル同士を繋ぎます。
