# frozen_string_literal: true

#
# 01章 模範解答
#
# 自分で解き終わってから読むこと。「別解」も併記してあるので、
# 自分の書き方と見比べて Ruby らしさを盗んでください。

module Ch01
  module_function

  def greet(name = "世界")
    "こんにちは、#{name}さん！"
  end

  def truthy?(value)
    # ! を 2 回かけると「真偽値そのもの」に変換できる定番イディオム
    !!value
  end

  def describe_number(number)
    # if は式。最後に評価された枝の値がそのままメソッドの戻り値になる
    if number % 15 == 0
      "FizzBuzz"
    elsif number % 3 == 0
      "Fizz"
    elsif number % 5 == 0
      "Buzz"
    else
      number.to_s
    end
  end

  def shout(text)
    text.upcase
  end

  def shout!(text)
    # 破壊的メソッドはレシーバ自身を書き換え、レシーバを返す
    text.upcase!
    text
  end

  def adult?(age)
    age >= 18
  end

  def safe_length(text)
    # text が nil なら &. の結果が nil になり、|| で 0 に落ちる
    text&.length || 0
  end

  def swap(first, second)
    [ second, first ]
  end

  def format_price(yen)
    # 逆順にして 3 文字ずつ切り、カンマで繋いでまた逆順に戻す
    delimited = yen.to_s.reverse.scan(/\d{1,3}/).join(",").reverse
    "#{delimited}円"

    # 別解（正規表現の先読み）:
    #   "#{yen.to_s.gsub(/(\d)(?=(\d{3})+\z)/, '\1,')}円"
  end

  def initials(full_name)
    full_name.split.map { |word| "#{word[0].upcase}." }.join

    # 別解:
    #   full_name.split.map { |word| word[0] }.join(".").upcase + "."
  end
end
