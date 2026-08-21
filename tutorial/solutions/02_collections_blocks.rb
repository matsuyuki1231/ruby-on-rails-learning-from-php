# frozen_string_literal: true

#
# 02章 模範解答

module Ch02
  module_function

  ITEMS = [
    { name: "リーダブルコード", category: "book",   price: 2640 },
    { name: "メタプログラミングRuby", category: "book",   price: 3520 },
    { name: "キーボード",       category: "gadget", price: 12800 },
    { name: "マウス",           category: "gadget", price: 3200 },
    { name: "コーヒー豆",       category: "food",   price: 1800 }
  ].freeze

  def evens(numbers)
    numbers.select { |n| n.even? }
    # 別解: numbers.select(&:even?)
  end

  def doubled(numbers)
    numbers.map { |n| n * 2 }
  end

  def total(numbers)
    numbers.sum
    # 別解: numbers.inject(0) { |acc, n| acc + n }
  end

  def longest(words)
    words.max_by { |word| word.length }
    # 別解: words.max_by(&:length)
  end

  def word_lengths(words)
    words.to_h { |word| [ word, word.length ] }
    # 別解: words.each_with_object({}) { |word, result| result[word] = word.length }
  end

  def group_by_initial(words)
    words.group_by { |word| word[0] }
  end

  def sort_by_price_desc(items)
    # sort_by は新しい配列を返すので、元の配列は壊れない
    items.sort_by { |item| -item[:price] }
    # 別解: items.sort_by { |item| item[:price] }.reverse
  end

  def total_by_category(items)
    items
      .group_by { |item| item[:category] }
      .transform_values { |group| group.sum { |item| item[:price] } }
  end

  def count_words(sentence)
    sentence.downcase.split.tally
  end

  def symbolize(hash)
    hash.transform_keys(&:to_sym)
  end

  def count_matching(items)
    count = 0
    items.each do |item|
      # yield は「呼び出し元から渡されたブロック」を実行する
      count += 1 if yield(item)
    end
    count
  end
end
