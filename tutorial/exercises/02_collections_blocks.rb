# frozen_string_literal: true

#
# 02章 演習: 配列・ハッシュ・ブロック
#
# 採点: ruby tutorial/check.rb 02
#
# PHP の array_map / array_filter / usort に相当する処理を、Ruby の Enumerable で書きます。
# ここで身につけるブロックの感覚は、そのまま Rails のコードを読む力になります。

module Ch02
  module_function

  # 採点で使うサンプルデータ（変更しないでください）
  ITEMS = [
    { name: "リーダブルコード", category: "book",   price: 2640 },
    { name: "メタプログラミングRuby", category: "book",   price: 3520 },
    { name: "キーボード",       category: "gadget", price: 12800 },
    { name: "マウス",           category: "gadget", price: 3200 },
    { name: "コーヒー豆",       category: "food",   price: 1800 }
  ].freeze

  # 【問1】偶数だけを取り出す
  # ヒント: select（別名 filter）とブロック { |n| ... }
  #
  #   evens([1, 2, 3, 4]) #=> [2, 4]
  def evens(numbers)
    raise NotImplementedError, "問1 が未実装です"
  end

  # 【問2】すべての要素を 2 倍にした新しい配列を返す
  # ヒント: map（別名 collect）
  #
  #   doubled([1, 2, 3]) #=> [2, 4, 6]
  def doubled(numbers)
    raise NotImplementedError, "問2 が未実装です"
  end

  # 【問3】合計を返す（空配列なら 0）
  # ヒント: sum が使える。inject / reduce でも書けるので余裕があれば両方試すこと。
  #
  #   total([1, 2, 3]) #=> 6
  def total(numbers)
    raise NotImplementedError, "問3 が未実装です"
  end

  # 【問4】いちばん長い単語を返す（同着なら先に現れた方）
  # ヒント: max_by
  #
  #   longest(%w[ruby php go]) #=> "ruby"
  def longest(words)
    raise NotImplementedError, "問4 が未実装です"
  end

  # 【問5】単語 => 文字数 のハッシュを作る
  # ヒント: each_with_object({}) か、map で二要素配列を作って to_h
  #
  #   word_lengths(%w[ruby go]) #=> { "ruby" => 4, "go" => 2 }
  def word_lengths(words)
    raise NotImplementedError, "問5 が未実装です"
  end

  # 【問6】頭文字ごとに単語をまとめる
  # ヒント: group_by
  #
  #   group_by_initial(%w[apple avocado banana])
  #   #=> { "a" => ["apple", "avocado"], "b" => ["banana"] }
  def group_by_initial(words)
    raise NotImplementedError, "問6 が未実装です"
  end

  # 【問7】商品を価格の高い順に並べた配列を返す（元の配列は壊さないこと）
  # ヒント: sort_by の結果を reverse するか、-price をキーにする
  #
  #   sort_by_price_desc(ITEMS).first[:name] #=> "キーボード"
  def sort_by_price_desc(items)
    raise NotImplementedError, "問7 が未実装です"
  end

  # 【問8】カテゴリごとの合計金額を返す
  # ヒント: group_by してから transform_values、その中で sum
  #
  #   total_by_category(ITEMS)
  #   #=> { "book" => 6160, "gadget" => 16000, "food" => 1800 }
  def total_by_category(items)
    raise NotImplementedError, "問8 が未実装です"
  end

  # 【問9】文章の中の単語の出現回数を数える（空白区切り、大文字小文字は区別しない）
  # ヒント: split → downcase → tally
  #
  #   count_words("Ruby ruby PHP") #=> { "ruby" => 2, "php" => 1 }
  def count_words(sentence)
    raise NotImplementedError, "問9 が未実装です"
  end

  # 【問10】文字列キーのハッシュをシンボルキーに変換する
  # Rails では params(文字列キー)とモデルの属性(シンボル)を行き来するので頻出。
  # ヒント: transform_keys
  #
  #   symbolize({ "name" => "松", "age" => 30 }) #=> { name: "松", age: 30 }
  def symbolize(hash)
    raise NotImplementedError, "問10 が未実装です"
  end

  # 【問11】ブロックを受け取るメソッドを自分で書く
  # 配列の各要素にブロックを適用し、結果が true になった個数を返す。
  # （count にブロックを渡せば一発だが、ここでは yield を使って自分で実装すること）
  #
  #   count_matching([1, 2, 3, 4]) { |n| n.even? } #=> 2
  def count_matching(items)
    raise NotImplementedError, "問11 が未実装です"
  end
end
