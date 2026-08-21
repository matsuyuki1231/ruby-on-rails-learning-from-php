# 01章 変数・メソッド・条件分岐・文字列

## この章のゴール

- PHP と Ruby の「書き方の違い」を体で覚える
- Ruby では **`false` と `nil` 以外はすべて真** だと分かる
- メソッドの `?` と `!` の意味が説明できる
- 演習 9 問を自力で解いて採点を通す

所要時間: 60〜90 分

---

## 1. まず動かす

`ruby bin/rails console` を開いて、上から順に打ち込んでください。
**結果を予想してから Enter を押す** のがコツです。

```ruby
name = "松"
puts "こんにちは、#{name}さん"

3.times { puts "hello" }

"abc".class
1.class
nil.class

x = if 1 > 0 then "正" else "負" end   # if が値を返す！
```

---

## 2. PHP との違い（ここが本題）

### 2-1. 変数に `$` は不要、命名はスネークケース

```php
// PHP
$userName = "松";
```

```ruby
# Ruby
user_name = "松"      # ローカル変数はスネークケース
USER_LIMIT = 100      # 定数は大文字（再代入すると警告が出る）
```

Ruby では変数名の見た目で種類が分かります。

| 書き方 | 種類 |
| --- | --- |
| `name` | ローカル変数 |
| `@name` | インスタンス変数（オブジェクトが持つ変数） |
| `NAME` | 定数 |
| `:name` | シンボル（02章で扱う） |

### 2-2. すべてがオブジェクト

PHP では `1` は「ただの数値」でしたが、Ruby では `1` もオブジェクトです。

```ruby
1.even?        #=> false
1.to_s         #=> "1"
(-5).abs       #=> 5
"abc".length   #=> 3
nil.to_a       #=> []      nil にもメソッドがある
```

### 2-3. 真偽の判定が根本的に違う ← 最重要

PHP では `0`、`""`、`"0"`、`[]`、`null` がすべて偽でした。
**Ruby で偽になるのは `false` と `nil` の 2 つだけです。**

```ruby
if 0        then puts "0 は真" end       # 表示される！
if ""       then puts "空文字も真" end   # 表示される！
if []       then puts "空配列も真" end   # 表示される！
if nil      then puts "出ない" end
if false    then puts "出ない" end
```

PHP で `if ($count)` と書いて「0 なら偽」に頼っていたコードは、
Ruby では `if count > 0` や `if count.zero?` と明示的に書く必要があります。

### 2-4. `return` を書かない

Ruby のメソッドは **最後に評価した式** が自動的に戻り値になります。

```php
// PHP
function double($n) {
    return $n * 2;
}
```

```ruby
# Ruby
def double(n)
  n * 2      # これが戻り値
end
```

`if` 文自体も値を持つので、こう書けます。

```ruby
def sign(n)
  if n > 0
    "正"
  elsif n < 0
    "負"
  else
    "ゼロ"
  end
end
```

早期リターンしたいときだけ `return` を使います（それは Ruby でも普通）。

```ruby
def greet(name)
  return "名前がありません" if name.nil?   # 後置 if。読みやすい

  "こんにちは、#{name}さん"
end
```

### 2-5. 文字列

```ruby
'こんにちは #{name}'   #=> 'こんにちは #{name}'  （シングルは展開しない）
"こんにちは #{name}"   #=> "こんにちは 松"       （ダブルは展開する）
```

PHP と同じ考え方ですが、Ruby の式展開 `#{}` は **式なら何でも** 書けます。

```ruby
"合計: #{1 + 2}円"
"名前: #{user.name.upcase}"
```

### 2-6. `?` と `!` が付いたメソッド名

Ruby ではメソッド名に `?` と `!` が使えます。これは **慣習** であって文法ではありません。

| 記号 | 意味 | 例 |
| --- | --- | --- |
| `?` | 真偽値を返す | `empty?`, `nil?`, `even?` |
| `!` | 危険な操作（多くは「レシーバ自身を書き換える」） | `upcase!`, `sort!` |

```ruby
text = "hello"
text.upcase    #=> "HELLO"    text は "hello" のまま
text.upcase!   #=> "HELLO"    text 自体が "HELLO" になる
```

**注意**: `!` 付きメソッドは「変化がなかったとき `nil` を返す」ことが多いです。

```ruby
text = "HELLO"
text.upcase!   #=> nil   （もう大文字なので何も変わらなかった）
```

これは Ruby 初心者が必ず 1 度は踏むワナです。演習の問 4-b で体験します。

### 2-7. `nil` の扱い

PHP の `null` に当たるのが `nil` です。便利な道具が 2 つあります。

```ruby
# ぼっち演算子 &. : レシーバが nil ならメソッドを呼ばず nil を返す
user&.name        # user が nil でもエラーにならない

# || : 左が nil か false なら右を使う
name = input || "名無し"
```

---

## 3. 課題

`tutorial/exercises/01_ruby_basics.rb` を開いてください。
9 問あります。`raise NotImplementedError` の行を消して、自分の実装に置き換えます。

```powershell
ruby tutorial/check.rb 01
```

最初は全問エラーです。**1 問解くごとに採点コマンドを打つ** リズムで進めてください。

### 進め方の例

1. 問 1 を実装する
2. `ruby tutorial/check.rb 01` を打つ
3. 問 1 が `✓`（正確には `.`）になり、問 2 以降がエラーのまま → 正常
4. 問 2 へ

### 詰まったら

- まずエラーメッセージを読む（`Expected: ... Actual: ...` は「期待値」と「実際の値」）
- `ruby bin/rails console` で小さく試す
- それでもダメなら Claude に `/tutorial-hint` と打つ

---

## 4. 自己チェック

```powershell
ruby tutorial/check.rb 01
```

`🎉 全問正解` が出ればクリアです。

---

## 5. 理解を深める（Claude への質問例）

- 「`puts`、`p`、`print`、`pp` の違いを、それぞれの用途つきで教えて」
- 「`&.` と `||` を組み合わせた `text&.length || 0` は、`text` が空文字のときどうなる？」
- 「`upcase!` が `nil` を返す設計になっている理由は？」
- 「自分が書いた `format_price` を、もっと Ruby らしく書けるか見てほしい」（`/tutorial-review`）

---

## 6. つまずきポイント

| 症状 | 原因 |
| --- | --- |
| `undefined method 'xxx' for nil` | どこかで `nil` が返っている。`p` を挟んで犯人を探す |
| `!` 付きメソッドを使ったら `nil` になった | 変化がないと `nil` を返す。戻り値ではなく変数自体を使う |
| 文字列が展開されない | シングルクォートを使っている。`"` に変える |
| `if 0` が真になって驚いた | Ruby では `false` と `nil` 以外すべて真 |

---

## 終わったら

模範解答 `tutorial/solutions/01_ruby_basics.rb` を読んで、自分の書き方と比べてください。
別解のコメントも書いてあります。

`PROGRESS.md` にチェックを入れて [02章](02_collections_blocks.md) へ。
