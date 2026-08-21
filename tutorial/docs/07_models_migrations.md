# 07章 モデルとマイグレーション

## この章のゴール

- **マイグレーション**でテーブルを作れる（SQL を手で書かない）
- Active Record（Rails の ORM）で CRUD ができる
- `rails console` でデータを触れる
- `db/seeds.rb` で初期データを投入できる

所要時間: 90 分

---

## 1. PHP との違い

PHP + 素の PDO では、こう書いていたはずです。

```php
$stmt = $pdo->prepare("SELECT * FROM projects WHERE name = ?");
$stmt->execute([$name]);
$rows = $stmt->fetchAll();
```

Rails では、テーブル 1 つにつきクラス 1 つを対応させます（Active Record パターン）。

```ruby
Project.where(name: name)          # SQL は Rails が組み立てる
Project.find(1)
Project.create!(name: "新規")
```

そして **テーブル定義も SQL では書きません**。マイグレーションという Ruby のファイルで書きます。

| | PHP でよくあるやり方 | Rails |
| --- | --- | --- |
| テーブル作成 | `CREATE TABLE` を手で実行 | マイグレーションファイル + `db:migrate` |
| 変更履歴 | 誰かの手元にある .sql | `db/migrate/` に全部残る |
| チーム共有 | 口頭かドキュメント | git に入るので自動で共有される |

---

## 2. ジェネレータでモデルを作る

これから作るのは「プロジェクト」です。名前・説明・期限を持ちます。

```powershell
ruby bin/rails generate model Project name:string description:text due_on:date
```

> **モデル名は必ず単数形・キャメルケース**（`Project`）です。
> Rails が勝手に複数形にしてテーブル名（`projects`）を決めます。この命名規則が Rails の背骨です。

生成されたものを確認してください。

- `db/migrate/2026...._create_projects.rb` … テーブル定義
- `app/models/project.rb` … モデルクラス
- `test/models/project_test.rb` … テスト（12章で書く）
- `test/fixtures/projects.yml` … テスト用データ（12章で書く）

### 型の一覧（よく使うもの）

| 指定 | SQL の型 | 使いどころ |
| --- | --- | --- |
| `string` | VARCHAR(255) | 名前、タイトル |
| `text` | TEXT | 長い文章 |
| `integer` | INTEGER | 数量 |
| `boolean` | BOOLEAN | フラグ |
| `date` | DATE | 期限 |
| `datetime` | DATETIME | 日時 |
| `references` | 外部キー | 他テーブルへの参照（11章） |

---

## 3. マイグレーションを読んで実行する

`db/migrate/..._create_projects.rb` を開いてください。

```ruby
class CreateProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :projects do |t|
      t.string :name
      t.text :description
      t.date :due_on

      t.timestamps      # created_at と updated_at を自動で追加
    end
  end
end
```

実行します。

```powershell
ruby bin/rails db:migrate
```

`db/schema.rb` が更新されます。これが **いまのテーブル構造の正本** です。

```ruby
create_table "projects", force: :cascade do |t|
  t.datetime "created_at", null: false
  t.text "description"
  t.date "due_on"
  t.string "name"
  t.datetime "updated_at", null: false
end
```

> `schema.rb` を手で編集しないでください。マイグレーションを足して `db:migrate` するのが正しい直し方です。
> （Rails 8 では列がアルファベット順に並びます。定義順と違っても異常ではありません）

### 覚えておくコマンド

| コマンド | 用途 |
| --- | --- |
| `ruby bin/rails db:migrate` | 未適用のマイグレーションを適用 |
| `ruby bin/rails db:rollback` | 直前のマイグレーションを取り消す |
| `ruby bin/rails db:migrate:status` | 適用済み / 未適用の一覧 |
| `ruby bin/rails db:prepare` | DB が無ければ作って適用まで |

---

## 4. Active Record で遊ぶ

```powershell
ruby bin/rails console
```

上から順に打って、**SQL のログが出ることを確認しながら** 進めてください。

```ruby
# 作る
Project.create!(name: "はじめてのプロジェクト", description: "お試し", due_on: Date.current + 7)

# 読む
Project.count
Project.all
Project.first
Project.find(1)                       # 主キーで探す（無いと例外）
Project.find_by(name: "はじめてのプロジェクト")   # 無いと nil
Project.where("due_on < ?", Date.current + 10)
Project.order(due_on: :desc)
Project.pluck(:name)                  # 名前だけ配列で取り出す

# 更新
project = Project.first
project.name = "名前を変えた"
project.save!
project.update!(description: "まとめて更新")

# 消す
project.destroy
```

### `!` の有無の違い（重要）

| メソッド | 失敗したとき |
| --- | --- |
| `save` / `create` / `update` | `false` を返す（黙って失敗する） |
| `save!` / `create!` / `update!` | 例外を投げる |

**コンソールや seed では `!` 付きを使ってください。** 失敗に気づけます。
コントローラでは `if project.save` のように戻り値で分岐するのが定番です（09章）。

### `find` と `find_by` の違い

```ruby
Project.find(999)          #=> ActiveRecord::RecordNotFound（例外）
Project.find_by(id: 999)   #=> nil
```

---

## 5. 課題

### 5-1. モデルを作る

上の手順どおり `Project` モデルを作り、マイグレーションを実行してください。

### 5-2. 初期データを書く

`db/seeds.rb` を編集して、プロジェクトを **3 件以上** 登録してください。

要件:

- 何度実行しても増殖しないこと（`find_or_create_by!` を使う）
- 少なくとも 1 件は `due_on` を設定すること

```ruby
[
  { name: "...", description: "...", due_on: Date.current + 30 },
  # ...
].each do |attributes|
  Project.find_or_create_by!(name: attributes[:name]) do |project|
    # ここは「新規作成のときだけ」実行されるブロック
    project.description = attributes[:description]
    project.due_on = attributes[:due_on]
  end
end
```

投入します。

```powershell
ruby bin/rails db:seed
```

**2 回実行して、件数が増えないことを確認してください。**

### 5-3. コンソールで確認する

```ruby
Project.count
Project.pluck(:name)
Project.order(:due_on).first.name
```

---

## 6. 自己チェック

```powershell
ruby bin/rails runner tutorial/check_rails.rb 07
```

---

## 7. 理解を深める（Claude への質問例）

- 「`Project.all` を実行しても SQL が発行されないのはなぜ？（遅延評価）」
- 「`where` の中で文字列を直接埋め込むと何が危険？ 正しい書き方は？」
- 「`find_or_create_by!` に渡すブロックはいつ実行される？」
- 「`db:migrate` を取り消したいときの正しい手順は？」

---

## 8. つまずきポイント

| 症状 | 原因 |
| --- | --- |
| `Migrations are pending` | `ruby bin/rails db:migrate` を忘れている |
| `undefined method 'name' for #<Project...>` | カラム名の綴り違い。`Project.column_names` で確認 |
| `NameError: uninitialized constant Project` | モデル名が違う。`app/models/project.rb` と `class Project` |
| seed を実行するたびに件数が増える | `create!` を使っている。`find_or_create_by!` に変える |
| コンソールで変更が反映されない | コンソールを開き直すか `reload!` を実行 |

---

## 終わったら

`PROGRESS.md` を更新して [08章](08_controllers_views.md) へ。
次は、いま作ったデータを画面に出します。
