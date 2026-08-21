# Ruby / Ruby on Rails 実践チュートリアル

PHP 経験者が、**手を動かしながら** Ruby と Rails を身につけるための教材です。
読むだけの章はありません。すべての章に「自分で書く課題」と「自動で採点されるチェック」が付いています。

---

## この教材の前提

| 項目 | 内容 |
| --- | --- |
| 想定読者 | 他言語（PHP など）でのプログラミング経験はあるが、Web フレームワークは未経験 |
| 環境 | Ruby 4.0.6 / Rails 8.1.3 / SQLite（このリポジトリにセットアップ済み） |
| 作るもの | タスク管理アプリ（プロジェクトとタスク、ログイン機能つき） |
| 期間の目安 | 1 日 45〜90 分 × 3 週間程度 |

---

## 進め方（この順番を守ってください）

```
1. docs/NN_xxx.md を開いて「この章のゴール」を読む
2. 「まず動かす」のコマンドを打って、結果を目で見る
3. 「課題」を自分で書く    ← ここが本体。答えを写さない
4. 「自己チェック」のコマンドを打つ → 緑になるまで直す
5. 「終わったら」に従って次の章へ
```

**重要**: 課題は必ず自分で書いてください。詰まったら答えを見るのではなく、
Claude に `/tutorial-hint` と打ってください。答えではなくヒントが返ってきます。

---

## 章の一覧

### 第 1 部: Ruby 単体（コードを書いて採点する）

| 章 | 内容 | 採点コマンド |
| --- | --- | --- |
| [00](docs/00_setup.md) | 環境確認と道具の使い方 | — |
| [01](docs/01_ruby_basics.md) | 変数・メソッド・条件分岐・文字列 | `ruby tutorial/check.rb 01` |
| [02](docs/02_collections_blocks.md) | 配列・ハッシュ・ブロック | `ruby tutorial/check.rb 02` |
| [03](docs/03_classes_modules.md) | クラス・継承・モジュール | `ruby tutorial/check.rb 03` |
| [04](docs/04_errors_and_idioms.md) | 例外処理と Ruby らしい書き方 | `ruby tutorial/check.rb 04` |

### 第 2 部: Rails（アプリを 1 本作る）

| 章 | 内容 | チェックコマンド |
| --- | --- | --- |
| [05](docs/05_rails_overview.md) | Rails の地図とはじめての画面 | `ruby bin/rails runner tutorial/check_rails.rb 05` |
| [06](docs/06_routing.md) | ルーティングとパラメータ | `... 06` |
| [07](docs/07_models_migrations.md) | モデルとマイグレーション | `... 07` |
| [08](docs/08_controllers_views.md) | コントローラとビュー | `... 08` |
| [09](docs/09_crud_forms.md) | CRUD とフォーム | `... 09` |
| [10](docs/10_validations.md) | バリデーションとエラー表示 | `... 10` |
| [11](docs/11_associations.md) | アソシエーション（1 対多） | `... 11` |
| [12](docs/12_testing.md) | テストを書く | `... 12` |
| [13](docs/13_authentication.md) | ログイン機能をつける | `... 13` |
| [14](docs/14_search_i18n.md) | 検索と日本語化 | `... 14` |
| [15](docs/15_capstone.md) | 総合課題（自分で設計する） | 自己採点 |

進捗は [PROGRESS.md](PROGRESS.md) に記録していきます。

---

## よく使うコマンド

Windows の PowerShell でも Git Bash でも動くように、`ruby` を先頭に付けた形で統一しています。
（他の Rails 資料では `bin/rails ...` と書かれていますが、PowerShell ではそれだと動きません）

```powershell
# Ruby 編の採点
ruby tutorial/check.rb 01
ruby tutorial/check.rb all

# Rails 編のチェック
ruby bin/rails runner tutorial/check_rails.rb 07
ruby bin/rails runner tutorial/check_rails.rb all

# アプリを起動する（http://localhost:3000）
ruby bin/rails server

# 対話コンソール（Rails を読み込んだ irb）
ruby bin/rails console

# ルーティング一覧
ruby bin/rails routes

# テスト
ruby bin/rails test
```

---

## Claude の使い方（この教材の要）

このチュートリアルは Claude Code と一緒に進める前提で作られています。
`/` に続けて次のコマンドが使えます。

| コマンド | 用途 |
| --- | --- |
| `/tutorial-next` | いまどこまで進んだかを確認し、次にやることを案内してもらう |
| `/tutorial-check` | 現在の章のチェックを実行し、失敗の原因を解説してもらう |
| `/tutorial-hint` | **答えを教えずに** ヒントだけもらう（詰まったらこれ） |
| `/tutorial-review` | 自分が書いたコードを Ruby / Rails らしさの観点でレビューしてもらう |
| `/tutorial-quiz` | その章の理解度を口頭クイズで確認してもらう |

### やってはいけない使い方

- ❌ 「この課題のコードを書いて」→ 学習になりません
- ❌ エラーが出たらすぐ貼り付けて丸投げ → まず自分でエラーメッセージを読む
- ❌ `tutorial/checks/` や `tutorial/rails_checks/`（採点の中身）を、通るように書き換える

### おすすめの使い方

- ✅ 「なぜ Ruby では `return` を書かないのが普通なのか」
- ✅ 「自分はこう書いたが、もっと Ruby らしい書き方はあるか」
- ✅ 「このエラーメッセージはどこを見ろと言っているのか」

---

## ファイル構成

```
tutorial/
├── README.md            この文書
├── PROGRESS.md          進捗チェックリスト
├── docs/                各章の教材
├── exercises/           Ruby 編で自分が書き込むファイル
├── solutions/           Ruby 編の模範解答（解いてから見る）
├── checks/              Ruby 編の採点内容
├── check.rb             Ruby 編の採点スクリプト
├── check_rails.rb       Rails 編のチェックスクリプト
└── rails_checks/        Rails 編のチェック内容
```

Rails 編で作るアプリのコードは、`tutorial/` の外（`app/`, `config/`, `db/`, `test/`）に置きます。
つまり **本物の Rails アプリを 1 本作る** ことになります。
