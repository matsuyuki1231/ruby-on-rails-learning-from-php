# 02章 配列・ハッシュ・ブロック

## この章のゴール

- 配列とハッシュを Ruby 流に扱える
- **ブロック**（`{ |x| ... }` / `do |x| ... end`）が何なのか説明できる
- `map` / `select` / `group_by` などで、ループを書かずにデータを加工できる
- シンボル `:name` と文字列 `"name"` の違いが分かる

所要時間: 90 分

この章の内容は、そのまま Rails のコードを読む力になります。
Rails のコードは 8 割がたブロックでできています。

---

## 1. まず動かす

```ruby
# rails console で
numbers = [1, 2, 3, 4, 5]

numbers.select { |n| n.even? }
numbers.map { |n| n * 10 }
numbers.sum
numbers.each_slice(2).to_a

person = { name: "松", age: 30 }
person[:name]
person.keys
person.map { |key, value| "#{key}=#{value}" }
```

---

## 2. PHP との違い

### 2-1. 配列とハッシュは別物

PHP の配列は「添字配列」と「連想配列」を兼ねていましたが、Ruby では完全に別の型です。

```php
// PHP はどちらも array
$list = [1, 2, 3];
$map  = ["name" => "松"];
```

```ruby
# Ruby
list = [1, 2, 3]              # Array
map  = { name: "松" }          # Hash
```

### 2-2. シンボル `:name`

`{ name: "松" }` の `name:` はシンボルというオブジェクトです。

```ruby
:name.class      #=> Symbol
"name".class     #=> String

{ name: "松" }           # キーはシンボル :name
{ "name" => "松" }       # キーは文字列 "name"
```

**同じ綴りのシンボルは、プログラム中でずっと同じ 1 個のオブジェクト**です。
そのため、識別子（キー、メソッド名、状態名）にはシンボルを使うのが Ruby の作法です。

```ruby
:name.object_id == :name.object_id       #=> true
"name".object_id == "name".object_id     #=> false（別物）
```

Rails では、**ブラウザから来たパラメータは文字列キー**、**自分のコードの中はシンボル**、
という使い分けをよく見かけます（Rails はこの差を吸収する仕組みを持っています）。

### 2-3. ブロック = メソッドに渡す「処理のかたまり」

PHP の `array_map` に無名関数を渡していたのと同じ考え方ですが、
Ruby ではこれが言語の中心にあります。

```php
// PHP
$doubled = array_map(fn($n) => $n * 2, $numbers);
$evens   = array_filter($numbers, fn($n) => $n % 2 === 0);
```

```ruby
# Ruby
doubled = numbers.map { |n| n * 2 }
evens   = numbers.select { |n| n.even? }
```

書き方は 2 通りあり、意味は同じです。

```ruby
numbers.each { |n| puts n }        # 1 行なら波かっこ

numbers.each do |n|                # 複数行なら do ... end
  puts n
  puts n * 2
end
```

### 2-4. `&:method` という短縮記法

```ruby
numbers.select { |n| n.even? }
numbers.select(&:even?)            # 同じ意味

words.map { |w| w.upcase }
words.map(&:upcase)                # 同じ意味
```

Rails のコードで頻出します。「ブロックの中で引数のメソッドを呼ぶだけ」のときに使えます。

---

## 3. 覚えておきたい Enumerable

配列やハッシュで使えるメソッド群です。**for 文を書く場面はほぼありません。**

| メソッド | 何をするか |
| --- | --- |
| `each` | 1 つずつ処理する（戻り値は元の配列） |
| `map` | 1 つずつ変換した **新しい配列** を作る |
| `select` / `filter` | 条件に合うものだけ残す |
| `reject` | 条件に合うものを捨てる |
| `find` / `detect` | 条件に合う **最初の 1 つ** |
| `sum` | 合計 |
| `min_by` / `max_by` | 何かを基準に最小 / 最大の要素 |
| `sort_by` | 何かを基準に並べ替え |
| `group_by` | キーごとにグループ分けしたハッシュを作る |
| `tally` | 出現回数を数えたハッシュを作る |
| `each_with_object` | 空の入れ物を渡して詰めていく |
| `to_h` | 二要素の配列からハッシュを作る |
| `transform_keys` / `transform_values` | ハッシュのキー / 値を変換 |

```ruby
items = [
  { name: "本", category: "book", price: 2000 },
  { name: "鍵盤", category: "gadget", price: 12000 }
]

# カテゴリごとの合計金額
items.group_by { |i| i[:category] }
     .transform_values { |group| group.sum { |i| i[:price] } }
#=> { "book" => 2000, "gadget" => 12000 }
```

この「メソッドを繋げていく」書き方（メソッドチェーン）が Ruby の気持ちよさです。

---

## 4. 自分でブロックを受け取るメソッドを書く

```ruby
def each_twice(items)
  items.each do |item|
    yield(item)      # 呼び出し元から渡されたブロックを実行する
    yield(item)
  end
end

each_twice([1, 2]) { |n| puts n }   #=> 1, 1, 2, 2
```

`yield` は「ここでブロックを呼ぶ」という命令です。演習の問 11 で書きます。

---

## 5. 課題

`tutorial/exercises/02_collections_blocks.rb` の 11 問を解いてください。

```powershell
ruby tutorial/check.rb 02
```

**縛り**: `for` 文は使わないこと。すべて Enumerable のメソッドで書いてください。

---

## 6. 自己チェック

```powershell
ruby tutorial/check.rb 02
```

---

## 7. 理解を深める（Claude への質問例）

- 「`each` と `map` の違いを、戻り値の観点で説明して」
- 「`select` と `find` はどう使い分ける？」
- 「`each_with_object` と `inject`（`reduce`）の違いは？ どちらを使うべき？」
- 「`&:upcase` はなぜ動くのか、`Symbol#to_proc` の仕組みから説明して」

---

## 8. つまずきポイント

| 症状 | 原因 |
| --- | --- |
| `map` したのに元の配列が変わらない | 正常。`map` は新しい配列を返す。`map!` なら破壊的 |
| `each` の結果を変数に入れたら元の配列が入った | `each` の戻り値はレシーバ自身。変換したいなら `map` |
| ハッシュのキーが取れない | `params["name"]` と `params[:name]` は別物。キーの型を確認 |
| `sum` でエラー | 要素が数値でない。`sum { |i| i[:price] }` のようにブロックで数値を取り出す |

---

## 終わったら

`PROGRESS.md` を更新して [03章](03_classes_modules.md) へ。
