# 02章の採点内容

require "minitest/autorun" unless defined?(Minitest::Test)

class Ch02Test < Minitest::Test
  i_suck_and_my_tests_are_order_dependent!

  def test_問1_偶数だけを取り出す
    assert_equal [ 2, 4 ], Ch02.evens([ 1, 2, 3, 4 ])
    assert_equal [], Ch02.evens([ 1, 3 ])
    assert_equal [ -2, 0 ], Ch02.evens([ -2, 0, 7 ])
  end

  def test_問2_全要素を2倍にする
    assert_equal [ 2, 4, 6 ], Ch02.doubled([ 1, 2, 3 ])
    assert_equal [], Ch02.doubled([])
  end

  def test_問2_元の配列を壊さない
    numbers = [ 1, 2, 3 ]
    Ch02.doubled(numbers)
    assert_equal [ 1, 2, 3 ], numbers, "map は非破壊。map! を使っていませんか？"
  end

  def test_問3_合計を求める
    assert_equal 6, Ch02.total([ 1, 2, 3 ])
    assert_equal 0, Ch02.total([])
    assert_equal 0, Ch02.total([ -5, 5 ])
  end

  def test_問4_いちばん長い単語
    assert_equal "ruby", Ch02.longest(%w[ruby php go])
    assert_equal "php", Ch02.longest(%w[php go]), "同着なら先に現れた方を返します"
  end

  def test_問5_単語と文字数のハッシュ
    assert_equal({ "ruby" => 4, "go" => 2 }, Ch02.word_lengths(%w[ruby go]))
    assert_equal({}, Ch02.word_lengths([]))
  end

  def test_問6_頭文字ごとにまとめる
    expected = { "a" => [ "apple", "avocado" ], "b" => [ "banana" ] }
    assert_equal expected, Ch02.group_by_initial(%w[apple avocado banana])
  end

  def test_問7_価格の高い順に並べる
    sorted = Ch02.sort_by_price_desc(Ch02::ITEMS)
    assert_equal [ 12800, 3520, 3200, 2640, 1800 ], sorted.map { |i| i[:price] }
    assert_equal "キーボード", sorted.first[:name]
  end

  def test_問7_元の配列を壊さない
    items = [ { name: "a", price: 1 }, { name: "b", price: 2 } ]
    Ch02.sort_by_price_desc(items)
    assert_equal [ "a", "b" ], items.map { |i| i[:name] }, "sort_by! を使っていませんか？"
  end

  def test_問8_カテゴリ別の合計金額
    expected = { "book" => 6160, "gadget" => 16000, "food" => 1800 }
    assert_equal expected, Ch02.total_by_category(Ch02::ITEMS)
  end

  def test_問9_単語の出現回数
    assert_equal({ "ruby" => 2, "php" => 1 }, Ch02.count_words("Ruby ruby PHP"))
    assert_equal({}, Ch02.count_words(""))
  end

  def test_問10_文字列キーをシンボルキーにする
    assert_equal({ name: "松", age: 30 }, Ch02.symbolize({ "name" => "松", "age" => 30 }))
    assert_equal({}, Ch02.symbolize({}))
  end

  def test_問11_ブロックを受け取って数える
    assert_equal 2, Ch02.count_matching([ 1, 2, 3, 4 ]) { |n| n.even? }
    assert_equal 0, Ch02.count_matching([]) { |n| true }
    assert_equal 3, Ch02.count_matching(%w[a bb ccc]) { |s| s.length >= 1 }
  end

  def test_問11_nilやfalseを返すブロックは数えない
    assert_equal 1, Ch02.count_matching([ 1, 2 ]) { |n| n == 1 ? "yes" : nil },
      "偽なのは false と nil だけ。文字列は真として数えます"
  end
end
