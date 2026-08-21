# frozen_string_literal: true

#
# 04章 模範解答

module Ch04
  class InsufficientBalanceError < StandardError; end

  Money = Data.define(:amount, :currency) do
    def +(other)
      raise ArgumentError, "通貨が異なります" unless currency == other.currency

      # with は「一部だけ変えた新しいインスタンス」を返す（元は不変のまま）
      with(amount: amount + other.amount)
    end
  end

  module_function

  def withdraw(balance, amount)
    raise ArgumentError, "金額が不正です" if amount <= 0

    if amount > balance
      raise InsufficientBalanceError, "残高が足りません（残高: #{balance}円 / 要求: #{amount}円）"
    end

    balance - amount
  end

  def safe_divide(dividend, divisor)
    dividend / divisor
  rescue ZeroDivisionError
    nil
  end
  # メソッド定義の中では begin を省いて直接 rescue が書ける（def が begin を兼ねる）

  def with_logging(log)
    log << "start"
    yield
  ensure
    # ensure は「例外が出ても出なくても」必ず通る。後始末はここに書く。
    log << "end"
  end

  def parse_int(text, default: 0)
    Integer(text)
  rescue ArgumentError, TypeError
    default
  end
  # 1 行で書くなら: Integer(text) rescue default （ただし拾う例外を選べないので雑）

  def fetch_setting(settings, key)
    settings.fetch(key)
  end

  def fetch_with_retry(max_attempts)
    attempts = 0
    begin
      attempts += 1
      yield
    rescue StandardError
      retry if attempts < max_attempts
      raise
      # 引数なしの raise は「いま処理中の例外をそのまま投げ直す」
    end
  end

  def describe_response(response)
    case response
    in { status: 200, body: String => body }
      "OK: #{body}"
    in { status: 404 }
      "Not Found"
    in { status: Integer => code } if code >= 500
      "Server Error (#{code})"
    in { status: Integer => code }
      "Unexpected (#{code})"
    else
      "Unknown"
    end
  end

  def expensive_settings
    @expensive_settings ||= begin
      @build_count = build_count + 1
      { host: "localhost", port: 3000 }
    end
  end

  def build_count
    @build_count ||= 0
  end

  def reset_settings!
    @expensive_settings = nil
    @build_count = 0
  end
end
