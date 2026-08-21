# 01章の採点内容（読んでも構いません。むしろ「何が求められているか」の仕様書です）

require "minitest/autorun" unless defined?(Minitest::Test)

class Ch01Test < Minitest::Test
  # 問1から順に採点するための設定（minitest は既定だと実行順がランダム）
  i_suck_and_my_tests_are_order_dependent!

  def test_問1_あいさつ文を式展開で組み立てられる
    assert_equal "こんにちは、松さん！", Ch01.greet("松")
    assert_equal "こんにちは、Rubyさん！", Ch01.greet("Ruby")
  end

  def test_問1_引数を省略すると世界になる
    assert_equal "こんにちは、世界さん！", Ch01.greet
  end

  def test_問2_falseとnilだけが偽である
    assert_equal false, Ch01.truthy?(nil)
    assert_equal false, Ch01.truthy?(false)
  end

  def test_問2_PHPと違い0や空文字は真である
    assert_equal true, Ch01.truthy?(0)
    assert_equal true, Ch01.truthy?("")
    assert_equal true, Ch01.truthy?("0")
    assert_equal true, Ch01.truthy?([])
    assert_equal true, Ch01.truthy?(true)
  end

  def test_問3_FizzBuzzを1件返せる
    assert_equal "1", Ch01.describe_number(1)
    assert_equal "Fizz", Ch01.describe_number(3)
    assert_equal "Buzz", Ch01.describe_number(5)
    assert_equal "FizzBuzz", Ch01.describe_number(15)
    assert_equal "FizzBuzz", Ch01.describe_number(30)
    assert_equal "14", Ch01.describe_number(14)
  end

  def test_問4a_shoutは元の文字列を壊さない
    text = +"hello"
    assert_equal "HELLO", Ch01.shout(text)
    assert_equal "hello", text, "shout は非破壊。元の変数まで変えてはいけません"
  end

  def test_問4b_shout破壊版は元の文字列を書き換える
    text = +"hello"
    assert_equal "HELLO", Ch01.shout!(text)
    assert_equal "HELLO", text, "shout! は破壊的。呼び出し元の文字列が変わっている必要があります"
  end

  def test_問4b_すでに大文字でも戻り値は文字列である
    text = +"HELLO"
    assert_equal "HELLO", Ch01.shout!(text),
      "upcase! は変化がないと nil を返します。戻り値に注意"
  end

  def test_問5_成人判定
    assert_equal true, Ch01.adult?(18)
    assert_equal true, Ch01.adult?(65)
    assert_equal false, Ch01.adult?(17)
    assert_equal false, Ch01.adult?(0)
  end

  def test_問6_nilを渡しても落ちない
    assert_equal 3, Ch01.safe_length("abc")
    assert_equal 0, Ch01.safe_length("")
    assert_equal 0, Ch01.safe_length(nil)
  end

  def test_問7_2つの値を入れ替えて返す
    assert_equal [ 2, 1 ], Ch01.swap(1, 2)
    assert_equal [ "b", "a" ], Ch01.swap("a", "b")
  end

  def test_問7_多重代入で受け取れる
    a, b = Ch01.swap(:x, :y)
    assert_equal :y, a
    assert_equal :x, b
  end

  def test_問8_3桁区切りの金額
    assert_equal "0円", Ch01.format_price(0)
    assert_equal "100円", Ch01.format_price(100)
    assert_equal "1,000円", Ch01.format_price(1000)
    assert_equal "1,234円", Ch01.format_price(1234)
    assert_equal "1,234,567円", Ch01.format_price(1234567)
    assert_equal "12,345円", Ch01.format_price(12345)
  end

  def test_問9_イニシャルを作れる
    assert_equal "Y.M.", Ch01.initials("yuki matsu")
    assert_equal "A.L.", Ch01.initials("ada lovelace")
  end

  def test_問9_空白が多くても壊れない
    assert_equal "J.R.R.T.", Ch01.initials("  john ronald  reuel  tolkien ")
  end
end
