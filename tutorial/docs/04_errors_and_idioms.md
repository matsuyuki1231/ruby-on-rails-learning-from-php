# 04章 例外処理と Ruby らしい書き方

## この章のゴール

- `begin` / `rescue` / `ensure` / `raise` と、独自の例外クラスが書ける
- `retry` で再試行できる
- `Data.define` で不変の値オブジェクトを作れる
- `case ... in`（パターンマッチ）で構造を分解できる
- `||=` などのイディオムが読める

所要時間: 90 分

Ruby 編はこの章で終わりです。ここまでで Rails のコードは「読める」状態になります。

---

## 1. まず動かす

```ruby
# rails console で
begin
  1 / 0
rescue ZeroDivisionError => e
  puts "捕まえた: #{e.message}"
ensure
  puts "ここは必ず通る"
end

Integer("42")
Integer("abc") rescue "変換できない"

{ status: 200, body: "ok" } => { status:, body: }   # 右代入で分解
status
```

---

## 2. PHP との違い

### 2-1. 例外の基本

```php
// PHP
try {
    risky();
} catch (RuntimeException $e) {
    echo $e->getMessage();
} finally {
    cleanup();
}
```

```ruby
# Ruby
begin
  risky
rescue RuntimeError => e
  puts e.message
ensure
  cleanup
end
```

| PHP | Ruby |
| --- | --- |
| `try` | `begin` |
| `catch` | `rescue` |
| `finally` | `ensure` |
| `throw new Exception("x")` | `raise "x"` または `raise MyError, "x"` |

### 2-2. `def` は `begin` を兼ねる

メソッド全体を囲むだけなら `begin` は要りません。

```ruby
def safe_divide(a, b)
  a / b
rescue ZeroDivisionError
  nil
end
```

### 2-3. 独自例外は `StandardError` を継承する

```ruby
class InsufficientBalanceError < StandardError; end

raise InsufficientBalanceError, "残高が足りません"
```

**`Exception` を直接継承してはいけません。**
`rescue` は既定で `StandardError` の系統だけを捕まえるので、
`Exception` を継承すると「捕まえたつもりが素通りする」事故になります。

```ruby
rescue => e          # これは rescue StandardError => e と同じ意味
```

### 2-4. `raise` の引数なし = 投げ直し

```ruby
rescue StandardError => e
  logger.warn(e.message)
  raise                # いま処理中の例外をそのまま上へ投げる
end
```

### 2-5. `retry`

```ruby
attempts = 0
begin
  attempts += 1
  call_api
rescue StandardError
  retry if attempts < 3     # begin からやり直す
  raise
end
```

`retry` は `rescue` の中でしか使えません。**必ず回数の上限を付けてください**（無限ループになります）。

### 2-6. `to_i` の罠と `Integer()`

```ruby
"abc".to_i      #=> 0        黙って 0 になる（危険）
"12abc".to_i    #=> 12       途中まで読む（危険）
Integer("abc")  #=> ArgumentError   ちゃんと失敗する
```

ユーザー入力を数値にするときは `Integer()` を使い、失敗を `rescue` するのが安全です。

### 2-7. `Hash#fetch`

```ruby
config = { host: nil }

config[:host]          #=> nil    （キーが無いのか、値が nil なのか区別できない）
config.fetch(:host)    #=> nil    （キーはあるので nil が返る）
config.fetch(:port)    #=> KeyError（キーが無いと例外）
config.fetch(:port, 3000)  #=> 3000（既定値つき）
```

「設定が抜けていたら即エラーにしたい」場面では `fetch` を使います。

---

## 3. Ruby らしい書き方（イディオム）

### `||=` （メモ化）

```ruby
@settings ||= build_settings     # @settings が nil か false のときだけ代入
```

「1 回だけ計算して、以降は使い回す」の定番です。

### 後置 `if` / `unless`

```ruby
return if name.nil?
puts "警告" unless valid?
```

### `Data.define`（Ruby 3.2 以降）

不変（immutable）な値オブジェクトを 1 行で作れます。

```ruby
Money = Data.define(:amount, :currency) do
  def +(other)
    raise ArgumentError, "通貨が違います" unless currency == other.currency

    with(amount: amount + other.amount)   # 一部だけ変えた新しいインスタンス
  end
end

a = Money.new(amount: 100, currency: "JPY")
b = Money.new(amount: 200, currency: "JPY")
(a + b).amount        #=> 300
a.frozen?             #=> true（変更できない）
a == Money.new(amount: 100, currency: "JPY")   #=> true（値が同じなら等しい）
```

`Struct` という古い仕組みもありますが、これから書くなら `Data` を選んでください。

### パターンマッチ `case ... in`（Ruby 3.0 以降）

値ではなく **構造** で分岐できます。API のレスポンス処理で活躍します。

```ruby
case response
in { status: 200, body: String => body }
  "OK: #{body}"
in { status: 404 }
  "Not Found"
in { status: Integer => code } if code >= 500
  "Server Error (#{code})"
else
  "Unknown"
end
```

- `String => body` … 型が String ならその値を `body` に束縛
- `if code >= 500` … ガード条件
- `else` … どれにも当たらないとき（書かないと `NoMatchingPatternError`）

---

## 4. 課題

`tutorial/exercises/04_errors_and_idioms.rb` の 9 問を解いてください。

```powershell
ruby tutorial/check.rb 04
```

問 1-a（例外クラス）と問 7（`Money`）は、TODO コメントの場所に **自分でクラス定義を書く** 必要があります。

---

## 5. 自己チェック

```powershell
ruby tutorial/check.rb 04
ruby tutorial/check.rb all      # 01〜04 をまとめて
```

`all` がすべて緑になったら Ruby 編は修了です。

---

## 6. 理解を深める（Claude への質問例）

- 「`rescue Exception` が危険な理由を具体例で教えて」
- 「`ensure` の中で `return` すると何が起きる？」
- 「`Data` と `Struct` の違いは？ いつどちらを使う？」
- 「Rails のコードでパターンマッチが使われている例を見せて」

---

## 7. つまずきポイント

| 症状 | 原因 |
| --- | --- |
| `rescue` したのに捕まらない | 例外クラスが違う。まず `rescue => e; p e.class` で確認 |
| `retry` が止まらない | 回数の上限を付けていない |
| `NoMatchingPatternError` | `case ... in` に `else` が無い |
| `Data` のインスタンスを変更できない | 仕様。`with` で新しいインスタンスを作る |

---

## 終わったら

`PROGRESS.md` を更新して、いよいよ Rails 編 [05章](05_rails_overview.md) へ。

ここから先は **本物の Web アプリを 1 本作ります**。
