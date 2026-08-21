# 00章 環境確認と道具の使い方

## この章のゴール

- 手元の Ruby と Rails が動くことを確認できる
- これから毎日使う 4 つのコマンドを覚える
- PHP の開発と何が違うのかを掴む

所要時間: 20 分

---

## 1. まず動かす

ターミナル（RubyMine 下部のターミナル、PowerShell、Git Bash のどれでも可）で、
プロジェクトのフォルダにいることを確認してから、順に打ってください。

```powershell
ruby -v
```

`ruby 4.0.6 ...` のように出れば OK です。

```powershell
ruby bin/rails -v
```

`Rails 8.1.3.1` と出れば OK です。

> **Windows の注意**
> 他の Rails の資料では `bin/rails -v` と書かれています。
> Git Bash や macOS ではそれで動きますが、**PowerShell では動きません**。
> この教材では、どちらでも動く `ruby bin/rails ...` の形で統一しています。

---

## 2. 学習を始める前にコミットしておく

これから 15 章にわたって、このリポジトリのファイルを自分で書き換えていきます。
「動いていたところまで戻りたい」ときのために、git で記録を残しながら進めてください。

```powershell
git add -A
git commit -m "チュートリアル開始前の状態"
```

**各章が終わるたびにコミットする**習慣をつけると、次の 2 つが手に入ります。

- どこで壊したかを `git diff` で追える
- 章ごとの差分が、そのまま自分専用の復習資料になる

```powershell
git add -A
git commit -m "05章 はじめての画面"
```

壊してしまって戻したいときは、まず `git diff` で自分が何を変えたかを読んでください。
いきなり `git checkout` で捨てるより、**差分を読むほうが学習になります**。


## 3. データベースを用意する

Rails はデータベースを使います。この教材では設定不要の SQLite を使います。

```powershell
ruby bin/rails db:prepare
```

`storage/development.sqlite3` というファイルができれば成功です。
PHP + MySQL のように別サーバーを立てる必要はありません。**ファイル 1 つが DB** です。

---

## 4. サーバーを起動してみる

```powershell
ruby bin/rails server
```

ブラウザで <http://localhost:3000> を開くと、Rails の初期画面が出ます。

止めるときは、ターミナルで `Ctrl + C` です。

> **PHP との違い**
> PHP は「ファイルを置けば URL になる」（`/about.php` → `about.php`）方式でした。
> Rails は違います。**URL とファイルの間に「ルーティング」という対応表がある**ので、
> ファイルを置いただけでは何も起きません。この違いが 05 章の主役です。

---

## 5. 対話コンソール

Rails のコードをその場で試せる対話環境があります。PHP でいう `php -a` の強力版です。

```powershell
ruby bin/rails console
```

中で試してみましょう。

```ruby
1 + 1
"hello".upcase
Rails.env
Date.current
exit          # 抜ける
```

これから何度も使います。**「動くか分からない」と思ったら、まずコンソールで試す**。
これが Rails 開発でいちばん大事な習慣です。

---

## 6. 覚える 4 つのコマンド

| コマンド | 何をするか |
| --- | --- |
| `ruby bin/rails server` | アプリを起動する |
| `ruby bin/rails console` | コードを試す |
| `ruby bin/rails routes` | URL の一覧を見る |
| `ruby bin/rails test` | テストを走らせる |

---

## 7. この教材の採点の仕組み

### Ruby 編（01〜04章）

`tutorial/exercises/` のファイルを自分で埋めて、次のコマンドで採点します。

```powershell
ruby tutorial/check.rb 01
```

最初は全部エラー（`NotImplementedError`）が出ます。**それが正常です**。
1 問ずつ実装して、緑を増やしていってください。

### Rails 編（05〜14章）

アプリを実際に作りながら、次のコマンドで確認します。

```powershell
ruby bin/rails runner tutorial/check_rails.rb 05
```

`✓` と `✗` の一覧が出ます。`✗` の下に「何が足りないか」が書いてあります。

---

## 8. 課題

1. 上のコマンドをすべて実行して、エラーが出ないことを確認する
2. `ruby bin/rails console` の中で、次を実行して結果を見る

```ruby
puts "こんにちは"
p "こんにちは"
pp({ name: "松", langs: ["PHP", "Ruby"] })
```

`puts` と `p` の出力の違いに気づけましたか？
（`p` はデバッグ用で、文字列にクォートが付きます。この違いは 01 章で扱います）

---

## 9. Claude に聞いてみよう

- 「`bin/rails` の中身は何をしている？」
- 「`Gemfile` と `Gemfile.lock` の関係は？ PHP の composer.json との違いは？」
- 「development / test / production 環境はどう切り替わる？」

---

## 終わったら

`tutorial/PROGRESS.md` の 00 にチェックを入れて、[01章](01_ruby_basics.md) へ進んでください。
