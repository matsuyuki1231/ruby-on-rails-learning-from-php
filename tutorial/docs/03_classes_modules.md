# 03章 クラス・継承・モジュール

## この章のゴール

- Ruby のクラス定義が書ける（`attr_reader`、`initialize`、`self.` メソッド）
- 継承と `super` が使える
- **モジュール（mixin）** が PHP の trait / interface と何が違うか説明できる
- `Comparable` と `Enumerable` を include して、機能をタダで手に入れる体験をする

所要時間: 90 分

Rails の `app/models/`、`app/controllers/` はすべてクラスです。ここが分かれば Rails の中身が読めます。

---

## 1. まず動かす

```ruby
# rails console で
class Dog
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def bark
    "#{@name}: ワン"
  end
end

dog = Dog.new("ポチ")
dog.name
dog.bark
dog.instance_variables
```

---

## 2. PHP との違い

### 2-1. 基本のかたち

```php
// PHP
class Book {
    private string $title;

    public function __construct(string $title) {
        $this->title = $title;
    }

    public function getTitle(): string {
        return $this->title;
    }
}
```

```ruby
# Ruby
class Book
  attr_reader :title        # getTitle 相当を自動生成

  def initialize(title)     # コンストラクタは initialize
    @title = title          # インスタンス変数は @ 始まり
  end
end
```

| PHP | Ruby |
| --- | --- |
| `__construct` | `initialize` |
| `$this->title` | `@title` |
| `new Book("x")` | `Book.new("x")` |
| getter / setter を手書き | `attr_reader` / `attr_writer` / `attr_accessor` |
| `public function` | 既定で public（`private` と書くとそれ以降が private） |
| `static function` | `def self.method_name` |

### 2-2. `attr_reader` / `attr_writer` / `attr_accessor`

```ruby
class Book
  attr_reader :title        # book.title で読める
  attr_writer :price        # book.price = 100 で書ける
  attr_accessor :stock      # 読み書き両方
end
```

**インスタンス変数 `@title` は外から直接見えません。**
`attr_reader` を書いて初めて `book.title` と読めるようになります。

### 2-3. キーワード引数

引数が 3 つを超えたら、順番ではなく名前で渡すのが Ruby の作法です。

```ruby
def initialize(title:, author:, price:)     # 末尾のコロンは「必須のキーワード引数」
  @title = title
end

Book.new(title: "x", author: "y", price: 100)
```

ハッシュを `**` で展開して渡すこともできます。

```ruby
attributes = { title: "x", author: "y", price: 100 }
Book.new(**attributes)
```

### 2-4. 継承と `super`

```ruby
class EBook < Book
  def initialize(title:, author:, price:, file_size_mb:)
    super(title: title, author: author, price: price)   # 親の initialize を呼ぶ
    @file_size_mb = file_size_mb
  end

  def to_s
    "#{super} [EPUB]"     # 親の to_s の結果を使う
  end
end
```

`super`（かっこなし）は「今のメソッドと同じ引数で親を呼ぶ」、
`super(...)` は「指定した引数で親を呼ぶ」です。この違いはハマりどころなので覚えてください。

### 2-5. モジュール = 機能の部品

PHP の trait に似ていますが、Ruby ではもっと積極的に使われます。

```ruby
module Taggable
  def tags
    @tags ||= []
  end

  def add_tag(tag)
    tags << tag unless tags.include?(tag)
    self
  end
end

class Library
  include Taggable      # これで Library に tags / add_tag が生える
end
```

- `include` … インスタンスメソッドとして取り込む
- `extend` … クラスメソッドとして取り込む
- モジュールは `new` できない（インスタンス化しない、機能の入れ物）

### 2-6. 標準モジュールを include する（Ruby の醍醐味）

**`Comparable`**: `<=>` を 1 つ定義するだけで、`<` `>` `==` `between?` `sort` `min` `max` が全部使えるようになります。

```ruby
class Book
  include Comparable

  def <=>(other)
    price <=> other.price     # 自分が小さければ -1、同じなら 0、大きければ 1
  end
end

books.sort      # 価格順に並ぶ
books.max       # いちばん高い本
```

**`Enumerable`**: `each` を 1 つ定義するだけで、`map` `select` `count` `sum` `min_by` などが全部使えるようになります。

```ruby
class Library
  include Enumerable

  def each(&block)
    @books.each(&block)
  end
end

library.map(&:title)
library.select { |b| b.price > 1000 }
```

**この 2 つが Ruby のオブジェクト指向の面白さです。** 演習で体験してください。

### 2-7. `to_s` を定義すると表示が変わる

```ruby
def to_s
  "「#{title}」#{author}"
end

puts book          #=> 「リーダブルコード」ダスティン・ボズウェル
"在庫: #{book}"     #=> 文字列に埋め込むときも to_s が呼ばれる
```

---

## 3. 課題

`tutorial/exercises/03_classes_modules.rb` の 8 問を解いてください。

```powershell
ruby tutorial/check.rb 03
```

- 問 1〜5: `Book` クラス（`attr_reader`、`to_s`、クラスメソッド、`Comparable`）
- 問 6: `EBook` で継承と `super`
- 問 7: `Taggable` モジュール
- 問 8: `Library` で `Enumerable` を include

TODO コメントのある行（`include` を書く場所）も忘れずに埋めてください。

---

## 4. 自己チェック

```powershell
ruby tutorial/check.rb 03
```

---

## 5. 理解を深める（Claude への質問例）

- 「Ruby のモジュールと PHP の trait / interface の違いを整理して」
- 「`include` と `extend` と `prepend` の違いは？」
- 「`attr_accessor` を使わず自分で getter を書くのはどんなとき？」
- 「Rails の `ApplicationRecord` や `ApplicationController` はこの仕組みのどこに当たる？」

---

## 6. つまずきポイント

| 症状 | 原因 |
| --- | --- |
| `undefined method 'title'` | `attr_reader :title` を書いていない |
| `wrong number of arguments` | キーワード引数を位置引数で渡している（`Book.new("x")` ではなく `Book.new(title: "x")`） |
| `sort` できない | `Comparable` を include していない、または `<=>` が未定義 |
| `map` できない | `Enumerable` を include していない、または `each` が未定義 |
| `super` でエラー | 親の引数と合っていない。`super(title: title, ...)` のように明示する |

---

## 終わったら

`PROGRESS.md` を更新して [04章](04_errors_and_idioms.md) へ。
