# 03章の採点内容

require "minitest/autorun" unless defined?(Minitest::Test)

class Ch03Test < Minitest::Test
  i_suck_and_my_tests_are_order_dependent!

  def build_book(title: "リーダブルコード", author: "ダスティン・ボズウェル", price: 2640)
    Ch03::Book.new(title: title, author: author, price: price)
  end

  def test_問1_キーワード引数で初期化して読み出せる
    book = build_book
    assert_equal "リーダブルコード", book.title
    assert_equal "ダスティン・ボズウェル", book.author
    assert_equal 2640, book.price
  end

  def test_問2_to_sの書式
    assert_equal "「リーダブルコード」ダスティン・ボズウェル 2640円", build_book.to_s
    assert_equal "「A」B 100円", build_book(title: "A", author: "B", price: 100).to_s
  end

  def test_問2_文字列に埋め込むとto_sが呼ばれる
    assert_equal "在庫: 「A」B 100円", "在庫: #{build_book(title: 'A', author: 'B', price: 100)}"
  end

  def test_問3_割引価格は整数で切り捨て
    book = build_book(price: 2640)
    assert_equal 2112, book.discounted_price(0.2)
    assert_equal 2640, book.discounted_price(0)
    assert_equal 0, book.discounted_price(1)
    assert_equal 66, build_book(price: 100).discounted_price(0.335), "切り捨てになっているか確認"
  end

  def test_問4_ハッシュからインスタンスを作れる
    book = Ch03::Book.from_hash({ title: "x", author: "y", price: 100 })
    assert_instance_of Ch03::Book, book
    assert_equal "x", book.title
    assert_equal 100, book.price
  end

  def test_問5_価格で大小比較できる
    cheap = build_book(price: 100)
    pricey = build_book(price: 999)
    assert cheap < pricey
    assert pricey > cheap
    assert cheap.between?(build_book(price: 1), build_book(price: 101))
  end

  def test_問5_Comparableをincludeしているのでsortできる
    books = [ build_book(price: 300), build_book(price: 100), build_book(price: 200) ]
    assert_equal [ 100, 200, 300 ], books.sort.map(&:price),
      "include Comparable を書きましたか？"
    assert_equal 300, books.max.price
  end

  def test_問6_継承とsuper
    ebook = Ch03::EBook.new(title: "Ruby入門", author: "まつもと", price: 3000, file_size_mb: 12)
    assert_kind_of Ch03::Book, ebook, "EBook は Book を継承している必要があります"
    assert_equal "Ruby入門", ebook.title, "親の initialize を super で呼びましたか？"
    assert_equal 3000, ebook.price
  end

  def test_問6_to_sは親の結果を拡張する
    ebook = Ch03::EBook.new(title: "Ruby入門", author: "まつもと", price: 3000, file_size_mb: 12)
    assert_equal "「Ruby入門」まつもと 3000円 [EPUB 12MB]", ebook.to_s
  end

  def test_問6_継承したメソッドもそのまま使える
    ebook = Ch03::EBook.new(title: "x", author: "y", price: 1000, file_size_mb: 1)
    assert_equal 800, ebook.discounted_price(0.2)
  end

  def test_問7_タグは最初は空
    library = Ch03::Library.new
    assert_equal [], library.tags
  end

  def test_問7_タグを追加できて重複しない
    library = Ch03::Library.new
    library.add_tag("ruby")
    library.add_tag("rails")
    library.add_tag("ruby")
    assert_equal [ "ruby", "rails" ], library.tags
    assert_equal true, library.tagged?("rails")
    assert_equal false, library.tagged?("php")
  end

  def test_問7_add_tagはselfを返すのでチェーンできる
    library = Ch03::Library.new
    assert_equal [ "a", "b" ], library.add_tag("a").add_tag("b").tags
  end

  def test_問8_addでためてeachで取り出せる
    a = Ch03::Book.new(title: "A", author: "x", price: 100)
    b = Ch03::Book.new(title: "B", author: "y", price: 200)
    library = Ch03::Library.new.add(a).add(b)

    collected = []
    library.each { |book| collected << book.title }
    assert_equal [ "A", "B" ], collected
  end

  def test_問8_初期化時に配列を渡せる
    a = Ch03::Book.new(title: "A", author: "x", price: 100)
    assert_equal [ "A" ], Ch03::Library.new([ a ]).map(&:title)
  end

  def test_問8_Enumerableのメソッドが手に入る
    books = [
      Ch03::Book.new(title: "A", author: "x", price: 300),
      Ch03::Book.new(title: "B", author: "y", price: 100),
      Ch03::Book.new(title: "C", author: "z", price: 200)
    ]
    library = Ch03::Library.new(books)

    assert_equal 3, library.count, "include Enumerable を書きましたか？"
    assert_equal [ "A", "B", "C" ], library.map(&:title)
    assert_equal [ "A", "C" ], library.select { |b| b.price >= 200 }.map(&:title)
    assert_equal "B", library.min.title, "Comparable と Enumerable が両方効いています"
    assert_equal 600, library.sum(&:price)
  end
end
