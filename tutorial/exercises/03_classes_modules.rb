# frozen_string_literal: true

#
# 03章 演習: クラス・継承・モジュール（mixin）
#
# 採点: ruby tutorial/check.rb 03
#
# Rails のモデルやコントローラはすべてクラスです。ここが分かると app/ 配下が読めるようになります。

module Ch03
  # 【問1】Book クラスの初期化
  # - キーワード引数 title:, author:, price: を受け取る
  # - それぞれをインスタンス変数 @title, @author, @price に保存する
  # - 外から book.title のように読めるようにする（書き換えはできなくてよい）
  #   ヒント: attr_reader :title, :author, :price
  #
  # 【問5】でこのクラスに比較機能を足します（Comparable）。
  class Book
    # TODO: 問1 ここに attr_reader を書く

    # TODO: 問5 ここに include Comparable を書く

    def initialize(title:, author:, price:)
      raise NotImplementedError, "問1 が未実装です"
    end

    # 【問2】文字列表現
    # puts book としたときにこの形で表示されるようにする。
    #
    #   "「リーダブルコード」ダスティン・ボズウェル 2640円"
    def to_s
      raise NotImplementedError, "問2 が未実装です"
    end

    # 【問3】割引後の価格（小数点以下は切り捨てて整数で返す）
    #
    #   book.price #=> 2640
    #   book.discounted_price(0.2) #=> 2112   （20% オフ）
    #   book.discounted_price(0)   #=> 2640
    def discounted_price(rate)
      raise NotImplementedError, "問3 が未実装です"
    end

    # 【問4】ハッシュから Book を作るクラスメソッド
    # `def self.` で始めるとクラスメソッドになる（PHP の static メソッド相当）。
    #
    #   Book.from_hash({ title: "x", author: "y", price: 100 })
    #
    # ヒント: ハッシュを ** で展開するとキーワード引数として渡せる。
    def self.from_hash(hash)
      raise NotImplementedError, "問4 が未実装です"
    end

    # 【問5】価格で比較できるようにする
    # <=>（宇宙船演算子）は「self が小さければ -1、同じなら 0、大きければ 1」を返す。
    # クラスに Comparable を include して <=> を定義すると、
    # <, >, ==, between?, sort, min, max がすべて使えるようになる。
    #
    #   cheap < expensive #=> true
    #   books.sort        #=> 安い順に並ぶ
    #
    # ヒント: 整数同士も <=> で比較できる。
    def <=>(other)
      raise NotImplementedError, "問5 が未実装です"
    end
  end

  # 【問6】Book を継承した電子書籍クラス
  # - Book のキーワード引数に加えて file_size_mb: を受け取る
  # - 親の initialize は super で呼ぶこと（自分で @title = ... と書き直さない）
  # - to_s は親の結果の末尾に " [EPUB 12MB]" を足す（数値は file_size_mb の値）
  #
  #   ebook.to_s #=> "「Ruby入門」まつもと 3000円 [EPUB 12MB]"
  class EBook < Book
    def initialize(title:, author:, price:, file_size_mb:)
      raise NotImplementedError, "問6 が未実装です"
    end

    def to_s
      raise NotImplementedError, "問6 が未実装です"
    end
  end

  # 【問7】タグ付け機能を提供するモジュール（PHP の trait に近い）
  # このモジュールを include したクラスで次が使えるようにする。
  #
  #   obj.tags          #=> []            （最初は空の配列）
  #   obj.add_tag("ruby") #=> self        （メソッドチェーンできるよう自分自身を返す）
  #   obj.add_tag("ruby") # 同じタグを 2 回足しても増えない
  #   obj.tagged?("ruby") #=> true
  #
  # ヒント: @tags は initialize を通らない可能性があるので、
  #         tags の中で `@tags ||= []` としておくと安全。
  module Taggable
    def tags
      raise NotImplementedError, "問7 が未実装です"
    end

    def add_tag(tag)
      raise NotImplementedError, "問7 が未実装です"
    end

    def tagged?(tag)
      raise NotImplementedError, "問7 が未実装です"
    end
  end

  # 【問8】自作コレクション
  # - include Enumerable と each の定義だけで、map / select / sort / count などが
  #   まとめて手に入る。これが Ruby の mixin の威力。
  # - Taggable も include して、ライブラリ自体にタグを付けられるようにする。
  class Library
    # TODO: 問8 Enumerable と Taggable を include する

    def initialize(books = [])
      raise NotImplementedError, "問8 が未実装です"
    end

    # 本を追加して self を返す（library.add(a).add(b) と繋げられるように）
    def add(book)
      raise NotImplementedError, "問8 が未実装です"
    end

    # Enumerable が要求する唯一のメソッド。
    # 保持している本を 1 冊ずつブロックに渡す。
    def each(&block)
      raise NotImplementedError, "問8 が未実装です"
    end
  end
end
