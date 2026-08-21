# frozen_string_literal: true

#
# 03章 模範解答

module Ch03
  class Book
    include Comparable

    attr_reader :title, :author, :price

    def initialize(title:, author:, price:)
      @title = title
      @author = author
      @price = price
    end

    def to_s
      "「#{title}」#{author} #{price}円"
    end

    def discounted_price(rate)
      (price * (1 - rate)).floor
    end

    def self.from_hash(hash)
      # ** でハッシュをキーワード引数に展開する
      new(**hash)
    end

    def <=>(other)
      price <=> other.price
    end
  end

  class EBook < Book
    attr_reader :file_size_mb

    def initialize(title:, author:, price:, file_size_mb:)
      # 親の initialize に共通部分を任せる
      super(title: title, author: author, price: price)
      @file_size_mb = file_size_mb
    end

    def to_s
      # super は同名の親メソッドを呼ぶ
      "#{super} [EPUB #{file_size_mb}MB]"
    end
  end

  module Taggable
    def tags
      @tags ||= []
    end

    def add_tag(tag)
      tags << tag unless tagged?(tag)
      self
    end

    def tagged?(tag)
      tags.include?(tag)
    end
  end

  class Library
    include Enumerable
    include Taggable

    def initialize(books = [])
      @books = books.dup
    end

    def add(book)
      @books << book
      self
    end

    def each(&block)
      @books.each(&block)
      self
    end
  end
end
