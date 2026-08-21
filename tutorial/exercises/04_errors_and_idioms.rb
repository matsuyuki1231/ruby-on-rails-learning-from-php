# frozen_string_literal: true

#
# 04章 演習: 例外処理と Ruby らしいイディオム
#
# 採点: ruby tutorial/check.rb 04

module Ch04
  # 【問1-a】独自の例外クラスを定義する
  # StandardError を継承すること（Exception を直接継承してはいけない。
  # rescue の既定が StandardError なので、握り損ねる事故のもとになる）。
  #
  # TODO: 問1-a InsufficientBalanceError を定義する
  # class InsufficientBalanceError < ...
  # end

  module_function

  # 【問1-b】出金する
  # - amount が 0 以下なら ArgumentError を "金額が不正です" というメッセージで投げる
  # - balance より amount が大きいなら InsufficientBalanceError を
  #   "残高が足りません（残高: 100円 / 要求: 500円）" というメッセージで投げる
  # - 問題なければ出金後の残高を返す
  #
  #   withdraw(1000, 300) #=> 700
  def withdraw(balance, amount)
    raise NotImplementedError, "問1-b が未実装です"
  end

  # 【問2】0 で割っても落ちない除算
  # ZeroDivisionError が起きたら nil を返す。それ以外は商（整数）を返す。
  # ヒント: begin / rescue ZeroDivisionError / end
  #
  #   safe_divide(10, 2) #=> 5
  #   safe_divide(10, 0) #=> nil
  def safe_divide(dividend, divisor)
    raise NotImplementedError, "問2 が未実装です"
  end

  # 【問3】前後にログを残しながらブロックを実行する
  # - 実行前に log << "start"
  # - ブロックを実行し、その戻り値をこのメソッドの戻り値にする
  # - 例外が起きても必ず log << "end" を残すこと（ensure）
  # - 例外は握りつぶさず、そのまま呼び出し元へ投げること
  #
  #   log = []
  #   with_logging(log) { 42 } #=> 42
  #   log #=> ["start", "end"]
  def with_logging(log)
    raise NotImplementedError, "問3 が未実装です"
  end

  # 【問4】文字列を整数に変換する。変換できなければ default を返す。
  # - to_i は "abc".to_i #=> 0 のように黙って 0 を返してしまうので使わないこと
  # - Kernel#Integer() は変換できないと ArgumentError / TypeError を投げる
  # - rescue は「式の後ろに置く」書き方（rescue 修飾子）も使える
  #
  #   parse_int("42")   #=> 42
  #   parse_int("abc")  #=> 0
  #   parse_int("abc", default: -1) #=> -1
  #   parse_int(nil)    #=> 0
  def parse_int(text, default: 0)
    raise NotImplementedError, "問4 が未実装です"
  end

  # 【問5】設定値を取り出す
  # - キーがあればその値を返す
  # - キーがなければ KeyError を投げる（Hash#fetch の既定の挙動）
  # - ただし値が nil で登録されている場合は nil をそのまま返すこと
  #   （hash[key] だと「無い」と「nil が入っている」を区別できない。これが fetch を使う理由）
  #
  #   fetch_setting({ host: "localhost" }, :host) #=> "localhost"
  #   fetch_setting({}, :host) #=> KeyError
  def fetch_setting(settings, key)
    raise NotImplementedError, "問5 が未実装です"
  end

  # 【問6】失敗したらリトライする
  # - ブロックを実行し、StandardError が起きたら再実行する
  # - 最大 max_attempts 回まで試す（1 回目 + リトライで合計 max_attempts 回）
  # - すべて失敗したら最後の例外をそのまま呼び出し元へ投げる
  # - ヒント: rescue 節の中で `retry` と書くと begin からやり直せる
  #
  #   attempts = 0
  #   fetch_with_retry(3) { attempts += 1; raise "boom" if attempts < 3; "ok" } #=> "ok"
  def fetch_with_retry(max_attempts)
    raise NotImplementedError, "問6 が未実装です"
  end

  # 【問7】値オブジェクトを Data で定義する
  # Data.define は「不変で、値が同じなら等しいオブジェクト」を一発で作る仕組み。
  # amount と currency を持つ Money を定義し、amount 同士を足す + メソッドを持たせる。
  #
  #   a = Ch04::Money.new(amount: 100, currency: "JPY")
  #   b = Ch04::Money.new(amount: 200, currency: "JPY")
  #   (a + b).amount #=> 300
  #   a == Ch04::Money.new(amount: 100, currency: "JPY") #=> true
  #   a.frozen? #=> true
  #
  # 通貨が違う場合は ArgumentError を投げること。
  #
  # TODO: 問7 Money を定義する
  # Money = Data.define(:amount, :currency) do
  #   def +(other)
  #     ...
  #   end
  # end

  # 【問8】パターンマッチでレスポンスを説明する
  # case / in はハッシュや配列の「形」で分岐できる（Ruby 3 以降）。
  #
  #   describe_response({ status: 200, body: "hi" }) #=> "OK: hi"
  #   describe_response({ status: 404, body: "" })   #=> "Not Found"
  #   describe_response({ status: 503, body: "" })   #=> "Server Error (503)"
  #   describe_response({ status: 302, body: "" })   #=> "Unexpected (302)"
  #   describe_response("こわれたレスポンス")          #=> "Unknown"
  #
  # ヒント:
  #   in { status: 200, body: String => body } then "OK: #{body}"
  #   in { status: Integer => code } if code >= 500 then ...
  #   in _ then "Unknown"   # どれにも当たらない場合の受け皿
  def describe_response(response)
    raise NotImplementedError, "問8 が未実装です"
  end

  # 【問9】設定を 1 度だけ組み立てて使い回す（メモ化）
  # - 何回呼んでも同じオブジェクト（object_id が同じ）を返すこと
  # - ヒント: `@cache ||= 重い処理` は「nil か false のときだけ代入する」イディオム
  # - build_count を数えているので、実際に組み立てるのは 1 回だけにすること
  def expensive_settings
    raise NotImplementedError, "問9 が未実装です"
  end

  def build_count
    @build_count ||= 0
  end

  def reset_settings!
    @expensive_settings = nil
    @build_count = 0
  end
end
