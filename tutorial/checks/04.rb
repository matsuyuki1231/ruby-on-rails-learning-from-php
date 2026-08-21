# 04章の採点内容

require "minitest/autorun" unless defined?(Minitest::Test)

class Ch04Test < Minitest::Test
  i_suck_and_my_tests_are_order_dependent!

  def test_問1a_独自例外はStandardErrorを継承している
    assert defined?(Ch04::InsufficientBalanceError),
      "Ch04::InsufficientBalanceError が定義されていません"
    assert Ch04::InsufficientBalanceError < StandardError,
      "StandardError を継承してください"
  end

  def test_問1b_正常な出金
    assert_equal 700, Ch04.withdraw(1000, 300)
    assert_equal 0, Ch04.withdraw(100, 100)
  end

  def test_問1b_不正な金額はArgumentError
    error = assert_raises(ArgumentError) { Ch04.withdraw(1000, 0) }
    assert_equal "金額が不正です", error.message
    assert_raises(ArgumentError) { Ch04.withdraw(1000, -5) }
  end

  def test_問1b_残高不足は独自例外
    error = assert_raises(Ch04::InsufficientBalanceError) { Ch04.withdraw(100, 500) }
    assert_equal "残高が足りません（残高: 100円 / 要求: 500円）", error.message
  end

  def test_問2_ゼロ除算をnilで受け止める
    assert_equal 5, Ch04.safe_divide(10, 2)
    assert_equal 3, Ch04.safe_divide(10, 3)
    assert_nil Ch04.safe_divide(10, 0)
  end

  def test_問3_ensureで前後にログが残る
    log = []
    assert_equal 42, Ch04.with_logging(log) { 42 }
    assert_equal [ "start", "end" ], log
  end

  def test_問3_例外が起きてもendが残り例外は伝播する
    log = []
    assert_raises(RuntimeError) do
      Ch04.with_logging(log) { raise "boom" }
    end
    assert_equal [ "start", "end" ], log, "ensure を使っていますか？"
  end

  def test_問4_整数に変換できる
    assert_equal 42, Ch04.parse_int("42")
    assert_equal(-7, Ch04.parse_int("-7"))
    assert_equal 42, Ch04.parse_int(42)
  end

  def test_問4_変換できなければデフォルト値
    assert_equal 0, Ch04.parse_int("abc")
    assert_equal 0, Ch04.parse_int(nil)
    assert_equal(-1, Ch04.parse_int("abc", default: -1))
    assert_equal 0, Ch04.parse_int("12abc"), "to_i を使うと 12 になってしまいます"
  end

  def test_問5_設定を取り出す
    assert_equal "localhost", Ch04.fetch_setting({ host: "localhost" }, :host)
  end

  def test_問5_キーが無ければKeyError
    assert_raises(KeyError) { Ch04.fetch_setting({}, :host) }
  end

  def test_問5_nilが入っている場合とキーが無い場合を区別する
    assert_nil Ch04.fetch_setting({ host: nil }, :host), "hash[key] では区別できません。fetch を使いましょう"
  end

  def test_問6_成功すればそのまま返す
    calls = 0
    result = Ch04.fetch_with_retry(3) { calls += 1; "ok" }
    assert_equal "ok", result
    assert_equal 1, calls, "成功したらリトライしてはいけません"
  end

  def test_問6_失敗したらやり直す
    calls = 0
    result = Ch04.fetch_with_retry(3) do
      calls += 1
      raise "temporary failure" if calls < 3
      "ok"
    end
    assert_equal "ok", result
    assert_equal 3, calls
  end

  def test_問6_上限まで失敗したら例外を投げ直す
    calls = 0
    error = assert_raises(RuntimeError) do
      Ch04.fetch_with_retry(2) { calls += 1; raise "always fails" }
    end
    assert_equal "always fails", error.message
    assert_equal 2, calls, "合計 max_attempts 回だけ試してください"
  end

  def test_問7_Dataで値オブジェクトを作れる
    assert defined?(Ch04::Money), "Ch04::Money が定義されていません"
    money = Ch04::Money.new(amount: 100, currency: "JPY")
    assert_equal 100, money.amount
    assert_equal "JPY", money.currency
    assert money.frozen?, "Data のインスタンスは不変です"
  end

  def test_問7_値が同じなら等しい
    a = Ch04::Money.new(amount: 100, currency: "JPY")
    b = Ch04::Money.new(amount: 100, currency: "JPY")
    assert_equal a, b, "Data は値が同じなら == が true になります"
  end

  def test_問7_足し算できる
    a = Ch04::Money.new(amount: 100, currency: "JPY")
    b = Ch04::Money.new(amount: 200, currency: "JPY")
    sum = a + b
    assert_equal 300, sum.amount
    assert_equal "JPY", sum.currency
    assert_equal 100, a.amount, "元のオブジェクトは変わりません"
  end

  def test_問7_通貨が違えばArgumentError
    a = Ch04::Money.new(amount: 100, currency: "JPY")
    b = Ch04::Money.new(amount: 200, currency: "USD")
    assert_raises(ArgumentError) { a + b }
  end

  def test_問8_パターンマッチで分岐する
    assert_equal "OK: hi", Ch04.describe_response({ status: 200, body: "hi" })
    assert_equal "Not Found", Ch04.describe_response({ status: 404, body: "" })
    assert_equal "Server Error (503)", Ch04.describe_response({ status: 503, body: "" })
    assert_equal "Server Error (500)", Ch04.describe_response({ status: 500, body: "" })
    assert_equal "Unexpected (302)", Ch04.describe_response({ status: 302, body: "" })
  end

  def test_問8_形が違えばUnknown
    assert_equal "Unknown", Ch04.describe_response("こわれたレスポンス")
    assert_equal "Unknown", Ch04.describe_response({ code: 200 })
    assert_equal "Unknown", Ch04.describe_response(nil)
  end

  def test_問9_メモ化されて1度しか組み立てない
    Ch04.reset_settings!
    first = Ch04.expensive_settings
    second = Ch04.expensive_settings
    Ch04.expensive_settings

    assert_same first, second, "毎回同じオブジェクトを返してください（||= を使う）"
    assert_equal 1, Ch04.build_count, "組み立ては 1 回だけのはずです"
  ensure
    Ch04.reset_settings!
  end
end
