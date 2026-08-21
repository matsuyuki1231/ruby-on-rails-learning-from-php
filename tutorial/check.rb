#!/usr/bin/env ruby
# frozen_string_literal: true

#
# Ruby 編（01〜04章）の自動採点スクリプト。
#
#   ruby tutorial/check.rb 01        # 自分の解答 (tutorial/exercises/01_*.rb) を採点
#   ruby tutorial/check.rb 01 --solution   # 模範解答を採点（答え合わせ／教材の自己検証用）
#   ruby tutorial/check.rb all       # 全章まとめて採点
#
# 「まだ実装していない」箇所は NotImplementedError になる。最初は真っ赤で正常。

require "minitest"

TUTORIAL_ROOT = File.expand_path(__dir__)

CHAPTERS = {
  "01" => "01_ruby_basics",
  "02" => "02_collections_blocks",
  "03" => "03_classes_modules",
  "04" => "04_errors_and_idioms"
}.freeze

def die(message)
  warn "エラー: #{message}"
  exit 1
end

args = ARGV.dup
use_solution = args.delete("--solution") || ENV["SOLUTION"] == "1"
target = args.shift

die("章番号を指定してください（例: ruby tutorial/check.rb 01）") if target.nil?

targets =
  if target == "all"
    CHAPTERS.keys
  else
    key = target.rjust(2, "0")
    die("章 #{target} は存在しません。使えるのは #{CHAPTERS.keys.join(', ')} です。") unless CHAPTERS.key?(key)
    [ key ]
  end

source_dir = use_solution ? "solutions" : "exercises"

targets.each do |key|
  basename = CHAPTERS[key]
  answer = File.join(TUTORIAL_ROOT, source_dir, "#{basename}.rb")
  spec   = File.join(TUTORIAL_ROOT, "checks", "#{key}.rb")

  die("解答ファイルが見つかりません: #{answer}") unless File.exist?(answer)
  die("採点ファイルが見つかりません: #{spec}")   unless File.exist?(spec)

  require answer
  require spec
end

puts "=" * 62
puts "採点対象: #{targets.map { |k| "#{k}章" }.join(', ')}（#{use_solution ? '模範解答' : 'あなたの解答'}）"
puts "=" * 62

ok = Minitest.run([])

puts
if ok
  puts "🎉 全問正解。docs の該当章の「終わったら」に進んでください。"
else
  puts "-" * 62
  puts "まだ通っていないテストがあります。落ち着いて 1 つずつ潰していきましょう。"
  puts
  puts "  ・NotImplementedError  → まだ手をつけていない設問です"
  puts "  ・Expected / Actual    → 実装はあるが結果が違う設問です"
  puts
  puts "詰まったら Claude に `/tutorial-hint` と打ってください（答えではなくヒントが返ります）。"
  puts "-" * 62
end

exit(ok ? 0 : 1)
