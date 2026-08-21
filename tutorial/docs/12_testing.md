# 12章 テストを書く

## この章のゴール

- Rails のテストの種類と置き場所が分かる
- fixtures でテスト用データを用意できる
- モデルテストと統合テストが書ける
- `ruby bin/rails test` を日常的に使えるようになる

所要時間: 90 分

---

## 1. Rails のテストの種類

| 種類 | 置き場所 | 何を確かめるか |
| --- | --- | --- |
| モデルテスト | `test/models/` | バリデーション、メソッド、関連 |
| コントローラ / 統合テスト | `test/controllers/`, `test/integration/` | リクエストを送って応答を確かめる |
| システムテスト | `test/system/` | 実ブラウザを動かす（この教材では扱いません） |
| ヘルパーテスト | `test/helpers/` | ヘルパーメソッド |

Rails には最初から **minitest** が入っています（PHP の PHPUnit に相当）。
別途 RSpec を入れる現場も多いですが、まずは標準のこれで十分です。

---

## 2. テスト用データベース

テストは development とは **別のデータベース**（`storage/test.sqlite3`）で動きます。
マイグレーションを実行したあとは、テスト DB にも反映が必要です。

```powershell
ruby bin/rails db:test:prepare
```

`Migrations are pending` と言われたら、このコマンドを打ってください。

---

## 3. fixtures

テストのたびに投入される初期データです。`test/fixtures/*.yml` に書きます。

```yaml
# test/fixtures/projects.yml
rails_study:
  name: Rails 学習
  description: チュートリアルを進める
  due_on: <%= Date.current + 30 %>

cleanup:
  name: 家の片付け
  due_on: <%= Date.current + 7 %>
```

- `rails_study:` の部分は **ラベル**。テストから `projects(:rails_study)` で参照します
- ERB が使えるので `<%= %>` で式を書けます
- 関連は **ラベルで書けます**（ID を書きません）

```yaml
# test/fixtures/tasks.yml
read_guide:
  project: rails_study      # ← projects.yml のラベル
  title: ガイドを読む
  done: false
```

fixtures は各テストの前に投入され、テストが終わるとロールバックされます。
**テストが互いに影響しない** のはこの仕組みのおかげです。

> **注意**: fixtures はバリデーションを通りません。直接 INSERT されます。
> だから「バリデーションを通らないデータ」も置けてしまいます。気をつけてください。

---

## 4. テストの書き方

### モデルテスト

```ruby
require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  test "名前が空なら無効" do
    project = Project.new(name: "")
    assert_not project.valid?
    assert project.errors[:name].any?
  end

  test "プロジェクトを消すとタスクも消える" do
    project = projects(:rails_study)
    assert_difference "Task.count", -project.tasks.count do
      project.destroy
    end
  end
end
```

### よく使うアサーション

| メソッド | 意味 |
| --- | --- |
| `assert 式` | 真であること |
| `assert_not 式` | 偽であること |
| `assert_equal 期待値, 実際の値` | 等しいこと（**期待値が先**） |
| `assert_nil 式` | nil であること |
| `assert_difference "Project.count", 1 do ... end` | ブロック実行で件数が変わること |
| `assert_no_difference "Project.count" do ... end` | 件数が変わらないこと |
| `assert_raises(ErrorClass) do ... end` | 例外が出ること |

### 統合テスト

画面をまたぐ流れを確かめます。

```ruby
require "test_helper"

class ProjectsFlowTest < ActionDispatch::IntegrationTest
  test "一覧から新規作成して詳細ページに辿り着ける" do
    get projects_path
    assert_response :success

    assert_difference "Project.count", 1 do
      post projects_path, params: { project: { name: "テストで作ったプロジェクト" } }
    end

    follow_redirect!                 # リダイレクト先まで追いかける
    assert_response :success
    assert_select "h1", "テストで作ったプロジェクト"    # HTML の中身を確かめる
  end
end
```

| メソッド | 意味 |
| --- | --- |
| `get` / `post` / `patch` / `delete` | リクエストを送る |
| `assert_response :success` | 200 番台であること（`:not_found`, `:unprocessable_entity` なども可） |
| `assert_redirected_to path` | 指定先へリダイレクトしていること |
| `follow_redirect!` | リダイレクト先へ進む |
| `assert_select "h1", "文字列"` | HTML 要素の中身を確かめる |

---

## 5. 実行

```powershell
ruby bin/rails test                            # 全部
ruby bin/rails test test/models                # ディレクトリ指定
ruby bin/rails test test/models/project_test.rb   # ファイル指定
ruby bin/rails test test/models/project_test.rb:12   # 行番号指定
```

---

## 6. 課題

### 6-1. 壊れているテストを直す

まず実行してみてください。

```powershell
ruby bin/rails db:test:prepare
ruby bin/rails test
```

08 章で `rails generate controller Projects index show` を実行したとき、
`test/controllers/projects_controller_test.rb` が自動生成されました。
中身は `projects_index_url` という **いまは存在しないパスヘルパー** を参照していて、失敗します。

これを `ActionDispatch::IntegrationTest` として正しく書き直してください。

- 一覧が表示できること
- 詳細が表示できること
- 編集フォームが表示できること

> ジェネレータが置いていったコードを放置しない、というのは実務で大事な習慣です。

### 6-2. fixtures を書く

`test/fixtures/projects.yml` と `test/fixtures/tasks.yml` を、
初期値（`MyString` など）から自分のデータに書き換えてください。

- プロジェクトは 2 件以上
- タスクは 2 件以上で、完了済みと未完了を 1 件ずつ
- タスクはラベルでプロジェクトに紐付ける

### 6-3. モデルテストを書く

`test/models/project_test.rb` に **4 つ以上** 書いてください。

- 名前があれば有効
- 名前が空なら無効
- 51 文字なら無効
- 同じ名前は登録できない
- 新規作成時に過去の期限は無効
- `progress` が正しい値を返す（fixtures のデータから計算できるはず）

`test/models/task_test.rb` に **2 つ以上**:

- タイトルが空なら無効
- `done` / `pending` スコープが正しく絞り込む

### 6-4. 統合テストを書く

`test/integration/projects_flow_test.rb` を新規作成し、次を確かめてください。

- 一覧 → 新規作成 → 詳細まで辿り着ける
- 名前が空なら作成されず 422 が返る
- タスクを追加すると詳細ページに表示される

### 6-5. 全部通す

```powershell
ruby bin/rails test
```

`0 failures, 0 errors` にしてください。

---

## 7. 自己チェック

```powershell
ruby bin/rails runner tutorial/check_rails.rb 12
```

このチェックは、最後に `ruby bin/rails test` も実際に走らせます（少し時間がかかります）。

---

## 8. 理解を深める（Claude への質問例）

- 「fixtures とファクトリ（FactoryBot）の違いと、それぞれの利点は？」
- 「`assert_equal` の引数の順番が「期待値が先」なのはなぜ？」
- 「テストが遅くなってきたときに最初に見るべきポイントは？」
- 「このアプリで、あと 3 つテストを足すならどこを狙う？」

---

## 9. つまずきポイント

| 症状 | 原因 |
| --- | --- |
| `Migrations are pending` | `ruby bin/rails db:test:prepare` |
| fixtures で `NOT NULL constraint failed` | 必須カラムを書いていない |
| `assert_select` が失敗する | 実際の HTML を `puts response.body` で確認 |
| テストが通ったり落ちたりする | テスト間でデータを共有している。fixtures を見直す |
| `NoMethodError: undefined method 'projects_index_url'` | 課題 6-1 の対象。書き直す |

---

## 終わったら

`PROGRESS.md` を更新して [13章](13_authentication.md) へ。
次は「誰のデータか」を扱います。テストも一緒に壊れるので、直すところまでが課題です。
