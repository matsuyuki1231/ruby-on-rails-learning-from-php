# frozen_string_literal: true

#
# 01章 演習: Ruby の基礎（PHP との差分を体で覚える）
#
# 採点: ruby tutorial/check.rb 01
#
# 各メソッドの `raise NotImplementedError` を消して、自分の実装に置き換えてください。
# 上から順に解くこと。1 問通すごとに採点コマンドを走らせるのがおすすめです。

module Ch01
  module_function

  # 【問1】あいさつ文を返す
  # - 文字列の式展開 #{} を使うこと（PHP の "$name" 相当）
  # - name を省略したら "世界" とみなす（デフォルト引数）
  #
  #   greet("松")   #=> "こんにちは、松さん！"
  #   greet         #=> "こんにちは、世界さん！"
  def greet(name = "世界")
    raise NotImplementedError, "問1 が未実装です"
  end

  # 【問2】Ruby の「真偽」を返す
  # value が Ruby にとって真なら true、偽なら false を返す。
  #
  # ここは PHP と一番違うところ。PHP では 0 も "" も "0" も偽だが、
  # Ruby で偽になるのは false と nil の 2 つだけ。
  #
  #   truthy?(0)     #=> true
  #   truthy?("")    #=> true
  #   truthy?(nil)   #=> false
  def truthy?(value)
    raise NotImplementedError, "問2 が未実装です"
  end

  # 【問3】FizzBuzz を 1 件分だけ返す
  # - 3 の倍数なら "Fizz"、5 の倍数なら "Buzz"、両方の倍数なら "FizzBuzz"
  # - それ以外は数値を文字列にして返す
  # - `return` は書かないこと。Ruby では if 自体が値を持つ（最後に評価した式が戻り値）
  #
  #   describe_number(15) #=> "FizzBuzz"
  #   describe_number(7)  #=> "7"
  def describe_number(number)
    raise NotImplementedError, "問3 が未実装です"
  end

  # 【問4-a】元の文字列は変えずに、大文字にしたものを返す
  #
  #   text = "hello"
  #   shout(text)  #=> "HELLO"
  #   text         #=> "hello"   ← 変わらない
  def shout(text)
    raise NotImplementedError, "問4-a が未実装です"
  end

  # 【問4-b】渡された文字列そのものを大文字に書き換える（破壊的）
  # 末尾の ! は「気をつけろ」の目印。Ruby では慣習として対で用意することが多い。
  #
  #   text = "hello"
  #   shout!(text)  #=> "HELLO"
  #   text          #=> "HELLO"  ← 元が書き換わる
  def shout!(text)
    raise NotImplementedError, "問4-b が未実装です"
  end

  # 【問5】成人判定。true / false を返す述語メソッド。
  # メソッド名の末尾 ? は「真偽値を返す」という慣習。
  #
  #   adult?(18) #=> true
  #   adult?(17) #=> false
  def adult?(age)
    raise NotImplementedError, "問5 が未実装です"
  end

  # 【問6】nil に強い文字数カウント
  # text が nil なら 0 を返す。文字列なら文字数を返す。
  #
  # ヒント: `&.`（ぼっち演算子）と `||` を組み合わせると 1 行で書ける。
  #
  #   safe_length("abc") #=> 3
  #   safe_length(nil)   #=> 0
  def safe_length(text)
    raise NotImplementedError, "問6 が未実装です"
  end

  # 【問7】2 つの値を入れ替えて返す
  # Ruby のメソッドは配列を返すことで実質的に複数の値を返せる。
  #
  #   swap(1, 2) #=> [2, 1]
  #   a, b = swap(1, 2)  # 多重代入で受け取れる
  def swap(first, second)
    raise NotImplementedError, "問7 が未実装です"
  end

  # 【問8】金額を 3 桁区切りの文字列にする
  #
  #   format_price(1234)    #=> "1,234円"
  #   format_price(100)     #=> "100円"
  #   format_price(1234567) #=> "1,234,567円"
  #
  # ヒント: 数字を反転させて 3 文字ずつ区切る方法（reverse + scan + join）か、
  #         gsub と正規表現の先読みを使う方法がある。好きな方で。
  def format_price(yen)
    raise NotImplementedError, "問8 が未実装です"
  end

  # 【問9】氏名からイニシャルを作る
  # 空白区切りの名前を受け取り、各語の頭文字を大文字にしてピリオドで繋ぐ。
  #
  #   initials("yuki matsu")     #=> "Y.M."
  #   initials("ada lovelace")   #=> "A.L."
  #   initials("  john ronald  reuel  tolkien ") #=> "J.R.R.T."
  #
  # ヒント: split は連続した空白をうまく処理してくれる。
  def initials(full_name)
    raise NotImplementedError, "問9 が未実装です"
  end
end
