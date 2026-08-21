# 11章 アソシエーション（1 対多）

## この章のゴール

- `has_many` / `belongs_to` でモデル同士を繋げる
- ネストしたルーティング（`/projects/1/tasks`）が書ける
- `scope` でよく使う絞り込みに名前を付けられる
- **N+1 問題**を理解し、`includes` で解決できる

所要時間: 100 分（この章がいちばん長い）

---

## 1. 作るもの

プロジェクトの中にタスクを持たせます。

```
Project（1）───< Task（多）

projects テーブル          tasks テーブル
+----+--------+           +----+------------+-------+------+
| id | name   |           | id | project_id | title | done |
+----+--------+           +----+------------+-------+------+
| 1  | 学習   |  ←────────| 1  | 1          | 読む  | false|
                          | 2  | 1          | 書く  | true |
```

**外部キー `project_id` は「多」の側が持ちます。** これは SQL の常識どおりです。

---

## 2. モデルを作る

```powershell
ruby bin/rails generate model Task project:references title:string done:boolean
```

`project:references` と書くと、マイグレーションに次が入ります。

```ruby
t.references :project, null: false, foreign_key: true
```

これは `project_id` カラム + インデックス + 外部キー制約をまとめて作る指定です。
さらに `app/models/task.rb` に `belongs_to :project` が自動で書かれます。

### マイグレーションを手直しする

生成されたファイルを開いて、次のように直してください。

```ruby
create_table :tasks do |t|
  t.references :project, null: false, foreign_key: true
  t.string :title, null: false            # ← 追加
  t.boolean :done, null: false, default: false   # ← 追加

  t.timestamps
end
```

**`boolean` に `default` と `null: false` を付けるのは重要な作法です。**
これを怠ると `done` が `nil` の行ができ、`if task.done` の判定が三通り（true / false / nil）になって苦しみます。

```powershell
ruby bin/rails db:migrate
```

---

## 3. 関連の書き方

### `belongs_to`（Task 側）

```ruby
class Task < ApplicationRecord
  belongs_to :project
end
```

これで `task.project` が使えます。**Rails 5 以降、`belongs_to` は既定で必須**です
（project が無い Task は保存できません）。

### `has_many`（Project 側）

```ruby
class Project < ApplicationRecord
  has_many :tasks, dependent: :destroy
end
```

これで `project.tasks` が使えます。

`dependent: :destroy` は「プロジェクトを消したらタスクも消す」指定です。
指定しないと、親のいないタスクが DB に残ります（外部キー制約があるとエラーになります）。

| 指定 | 動き |
| --- | --- |
| `dependent: :destroy` | 子を 1 件ずつ削除（コールバックも走る） |
| `dependent: :delete_all` | 子をまとめて SQL で削除（速いがコールバックは走らない） |
| `dependent: :nullify` | 子の外部キーを NULL にする |
| 指定なし | 何もしない（孤児が残る） |

### 関連経由で作る

```ruby
project = Project.first
project.tasks.create!(title: "ガイドを読む")     # project_id が自動で入る
project.tasks.count
project.tasks.build(title: "下書き")            # 保存はしない
```

**`Task.create!(project_id: project.id, ...)` ではなく `project.tasks.create!` と書いてください。**
関連経由で書くのが Rails の作法です（13 章の「他人のデータを触らせない」に効いてきます）。

---

## 4. `scope`

よく使う絞り込みに名前を付けられます。

```ruby
class Task < ApplicationRecord
  scope :done, -> { where(done: true) }
  scope :pending, -> { where(done: false) }
end
```

```ruby
Task.done
project.tasks.pending            # 繋げられる
project.tasks.pending.count
```

`->{ }` は「ラムダ（無名関数）」です。呼ばれるたびに評価されます。

---

## 5. N+1 問題 ← 実務で最も重要

一覧ページで、各プロジェクトのタスク数を表示するとします。

```erb
<% @projects.each do |project| %>
  <%= project.name %> : <%= project.tasks.size %> 件
<% end %>
```

このとき発行される SQL は、

```sql
SELECT * FROM projects;                          -- 1 回
SELECT * FROM tasks WHERE project_id = 1;        -- ↓
SELECT * FROM tasks WHERE project_id = 2;        --  プロジェクトの数だけ
SELECT * FROM tasks WHERE project_id = 3;        -- ↑
```

プロジェクトが 100 件なら SQL は 101 本。これが **N+1 問題** です。
サービスが遅くなる原因の第 1 位と言ってよいくらい頻出します。

解決策は `includes` です。

```ruby
@projects = Project.includes(:tasks).order(:due_on)
```

```sql
SELECT * FROM projects;
SELECT * FROM tasks WHERE project_id IN (1, 2, 3);   -- まとめて 1 回
```

**確認方法**: サーバーを動かした状態でページを開き、`log/development.log` を見てください。
同じ形の SQL が並んでいたら N+1 です。

---

## 6. ネストしたルーティング

タスクは必ずプロジェクトに属するので、URL もその形にします。

```ruby
resources :projects do
  resources :tasks, only: %i[create update destroy]
end
```

```
POST   /projects/1/tasks       tasks#create
PATCH  /projects/1/tasks/5     tasks#update
DELETE /projects/1/tasks/5     tasks#destroy
```

コントローラでは `params[:project_id]` と `params[:id]` の **両方** が届きます。

パスヘルパーは `project_tasks_path(project)` / `project_task_path(project, task)` です。

---

## 7. 課題

### 7-1. モデル

- `Task` を生成し、マイグレーションを手直しして実行する
- `Task` に `belongs_to :project`、`title` の presence バリデーション（100 文字以内）
- `Task` に `scope :done` と `scope :pending`
- `Project` に `has_many :tasks, dependent: :destroy`
- `Project` に進捗率を返すメソッド `progress` を追加する
  - タスクが 0 件なら 0
  - 完了したタスクの割合（整数のパーセント）

### 7-2. ルーティング

上のとおりネストさせる。

### 7-3. `TasksController`

`app/controllers/tasks_controller.rb` を新規作成します。

- `before_action` で `@project` を `params[:project_id]` から取得
- `create` … `@project.tasks.build(task_params)` で作り、保存できたら詳細ページへ戻る
- `update` … 完了 / 未完了の切り替えに使う
- `destroy` … 削除して詳細ページへ戻る
- `task_params` は `:title` と `:done` だけ許可する

タスク専用のビューは（`_task.html.erb` 以外）不要です。すべてプロジェクト詳細へリダイレクトします。

### 7-4. プロジェクト詳細にタスクを出す

`app/views/projects/show.html.erb` に追加:

- タスク一覧（パーシャル `app/views/tasks/_task.html.erb` を使う）
- 完了 / 未完了を切り替えるボタン
- 削除ボタン
- タスク追加フォーム

追加フォームは、**配列を渡す** と URL が組み立てられます。

```erb
<%= form_with model: [ @project, Task.new ] do |form| %>
  <%= form.text_field :title, placeholder: "やることを入力" %>
  <%= form.submit "追加" %>
<% end %>
```

切り替えボタンは `button_to` に `params` を渡します。

```erb
<%= button_to task.done? ? "戻す" : "完了",
      project_task_path(task.project, task),
      method: :patch, params: { task: { done: !task.done } } %>
```

### 7-5. 一覧の N+1 を潰す

`ProjectsController#index` を `Project.includes(:tasks)` に変更し、
一覧のパーシャルにタスク件数と進捗率を表示してください。

---

## 8. 自己チェック

```powershell
ruby bin/rails runner tutorial/check_rails.rb 11
```

「SQL 本数」のチェックが、N+1 になっていないかを実測しています。

---

## 9. 理解を深める（Claude への質問例）

- 「`project.tasks.size` と `.count` と `.length` の違いは？ `includes` したときの挙動は？」
- 「`includes` と `preload` と `eager_load` の使い分けは？」
- 「`dependent: :destroy` と DB の外部キー `ON DELETE CASCADE` はどう違う？」
- 「`log/development.log` から N+1 を見つけるコツを教えて」

---

## 10. つまずきポイント

| 症状 | 原因 |
| --- | --- |
| `Project must exist` | `belongs_to` は既定で必須。関連経由（`project.tasks.build`）で作る |
| `undefined method 'tasks'` | `has_many :tasks` を書き忘れ |
| `No route matches` | ネストしたパスヘルパーは引数が 2 つ（`project_task_path(project, task)`） |
| チェックボックスを外しても false にならない | HTML の仕様。`check_box` は hidden フィールドとセットで使う |
| SQL が減らない | `includes` を書いた場所が違う（`each` の中では意味がない） |

---

## 終わったら

`PROGRESS.md` を更新して [12章](12_testing.md) へ。
ここまでで機能は一通り揃いました。次は「壊れていないこと」を自動で確かめます。
