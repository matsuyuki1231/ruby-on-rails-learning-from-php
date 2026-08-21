# frozen_string_literal: true

#
# Rails 編（05章〜）の自動チェック。
#
#   bin/rails runner tutorial/check_rails.rb 05
#   bin/rails runner tutorial/check_rails.rb all
#
# 「まだ作っていないもの」は当然 ✗ になります。1 つずつ緑にしていくのがこの章の進め方です。

module TutorialCheck
  CheckFailed = Class.new(StandardError)

  CHAPTERS = %w[05 06 07 08 09 10 11 12 13 14].freeze

  class << self
    def run(chapter)
      @current_chapter = chapter
      path = File.expand_path("rails_checks/#{chapter}.rb", __dir__)
      unless File.exist?(path)
        puts "  （#{chapter}章の自動チェックはありません。docs の手順で自分で確認してください）"
        return
      end
      instance_eval(File.read(path), path)
    end

    def results
      @results ||= []
    end

    # --- DSL ---------------------------------------------------------------

    def section(title)
      puts
      puts "▼ #{title}"
    end

    def check(title)
      @note = nil
      yield
      results << [ :pass, title, nil ]
      puts "  ✓ #{title}"
      puts "      #{@note}" if @note
    rescue CheckFailed => e
      results << [ :fail, title, e.message ]
      puts "  ✗ #{title}"
      puts "      → #{e.message}"
    rescue StandardError, ScriptError => e
      results << [ :fail, title, "#{e.class}: #{e.message}" ]
      puts "  ✗ #{title}"
      puts "      → #{e.class}: #{e.message}"
      puts "      → #{e.backtrace&.first}"
    end

    def hint(text)
      puts "  💡 #{text}"
    end

    # チェック成功時に一言添えたいときに使う
    def note(text)
      @note = text
    end

    # --- アサーション -------------------------------------------------------

    def failure!(message)
      raise CheckFailed, message
    end

    def assert!(condition, message)
      failure!(message) unless condition
    end

    def assert_equal!(expected, actual, message = nil)
      return if expected == actual

      failure!([ message, "期待: #{expected.inspect} / 実際: #{actual.inspect}" ].compact.join(" | "))
    end

    def assert_file!(relative_path)
      full = Rails.root.join(relative_path)
      assert!(File.exist?(full), "ファイルがありません: #{relative_path}")
    end

    def file_body(relative_path)
      assert_file!(relative_path)
      File.read(Rails.root.join(relative_path))
    end

    # ルーティング: GET "/" が "pages#home" に繋がっているか
    def assert_route!(verb, path, to:)
      recognized =
        begin
          Rails.application.routes.recognize_path(path, method: verb)
        rescue ActionController::RoutingError
          failure!("#{verb.to_s.upcase} #{path} に対応するルートがありません（config/routes.rb を確認）")
        end

      actual = "#{recognized[:controller]}##{recognized[:action]}"
      assert_equal!(to, actual, "#{verb.to_s.upcase} #{path} の行き先が違います")
    end

    def assert_named_route!(name)
      assert!(
        Rails.application.routes.named_routes.key?(name.to_s),
        "名前付きルート #{name}_path がありません（rails routes で確認）"
      )
    end

    # モデル
    def model(name)
      Object.const_get(name)
    rescue NameError
      failure!("#{name} モデルがありません（app/models/#{name.to_s.underscore}.rb）")
    end

    def assert_model!(name, columns: {})
      klass = model(name)
      assert!(klass < ActiveRecord::Base, "#{name} は ActiveRecord::Base を継承していません")
      assert!(klass.table_exists?, "#{klass.table_name} テーブルがありません（マイグレーションは実行しましたか？）")

      columns.each do |column, type|
        info = klass.columns_hash[column.to_s]
        assert!(info, "#{klass.table_name} に #{column} カラムがありません")
        next if type.nil?

        assert_equal!(type.to_s, info.type.to_s, "#{klass.table_name}.#{column} の型が違います")
      end
      klass
    end

    def assert_association!(name, kind, association)
      klass = model(name)
      reflection = klass.reflect_on_association(association)
      assert!(reflection, "#{name} に #{kind} :#{association} がありません")
      assert_equal!(kind.to_s, reflection.macro.to_s, "#{name}.#{association} の関連の種類が違います")
      reflection
    end

    # バリデーション: 属性を invalid_value にしたときエラーが出るか
    def assert_invalid!(name, attributes, on: nil)
      record = name.to_s == "Project" ? build_project(attributes) : model(name).new(attributes)
      record.valid?
      target = on || attributes.keys.first
      assert!(
        record.errors[target].any?,
        "#{name}.new(#{attributes.inspect}) が #{target} のバリデーションに引っかかりません"
      )
    end

    def assert_valid!(name, attributes)
      record = name.to_s == "Project" ? build_project(attributes) : model(name).new(attributes)
      assert!(
        record.valid?,
        "#{name}.new(#{attributes.inspect}) は有効であるべきですが、#{record.errors.full_messages.join(', ')} で落ちました"
      )
    end

    # HTTP リクエスト（rails console の app と同じ仕組み）
    def session
      @session ||= begin
        s = ActionDispatch::Integration::Session.new(Rails.application)
        s.host! "localhost"
        s
      end
    end

    # 統合セッションでリクエストを 1 往復させると Rails の実行コンテキストが
    # 巻き戻ってしまい、そのあとの Active Record 呼び出しが落ちることがある。
    # runner から直接叩いている都合上の問題なので、毎回リセットしておく。
    def reset_execution_context!
      ActiveSupport::ExecutionContext.clear
    end

    # ログイン状態を捨てて、まっさらなブラウザとして振る舞う
    def reset_session!
      @session = nil
    end

    # --- 認証（13章）が入っていても入っていなくても動くようにするための補助 ---

    def auth_enabled?
      defined?(User) && defined?(Session) && User.table_exists? && Session.table_exists?
    rescue StandardError
      false
    end

    # チュートリアルの持ち主。13章より前は nil
    def tutorial_user
      return nil unless auth_enabled?

      @tutorial_user ||= User.order(:id).first
    end

    # 認証が入っていればログイン済みのセッションにする
    def sign_in_default!
      return unless tutorial_user

      reset_session!
      record = tutorial_user.sessions.create!
      jar = ActionDispatch::TestRequest.create.cookie_jar
      jar.signed[:session_id] = record.id
      session.cookies["session_id"] = jar[:session_id]
    end

    # プロジェクトを扱う起点。認証後は「持ち主のプロジェクト」に限定される
    def projects
      tutorial_user ? tutorial_user.projects : model("Project").all
    end

    def build_project(attributes = {})
      tutorial_user ? tutorial_user.projects.build(attributes) : model("Project").new(attributes)
    end

    def create_project!(attributes = {})
      build_project(attributes).tap(&:save!)
    end

    def get!(path, expect: 200, includes: nil, excludes: nil)
      session.get(path)
      reset_execution_context!
      assert_equal!(expect, session.response.status,
        "GET #{path} のステータスが違います（ログ: log/development.log を確認）")
      body = session.response.body
      Array(includes).each do |text|
        assert!(body.include?(text), "GET #{path} の表示に「#{text}」が含まれていません")
      end
      Array(excludes).each do |text|
        assert!(!body.include?(text), "GET #{path} の表示に「#{text}」が含まれてしまっています")
      end
      body
    end

    def post!(path, params: {}, expect: nil)
      request!(:post, path, params: params, expect: expect)
    end

    def patch!(path, params: {}, expect: nil)
      request!(:patch, path, params: params, expect: expect)
    end

    def delete!(path, expect: nil)
      request!(:delete, path, expect: expect)
    end

    def request!(verb, path, params: nil, expect: nil)
      if params.nil?
        session.public_send(verb, path)
      else
        session.public_send(verb, path, params: params)
      end
      reset_execution_context!
      if expect
        assert!(Array(expect).include?(session.response.status),
          "#{verb.to_s.upcase} #{path} のステータスが違います | 期待: #{Array(expect).join(' か ')} / 実際: #{session.response.status}")
      end
      session.response
    end

    def redirect_location
      session.response.headers["Location"]
    end

    # ブロックの中で発行された SQL の本数を数える（N+1 の検出に使う）
    def count_queries
      count = 0
      subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |_name, _start, _finish, _id, payload|
        next if payload[:cached]
        next if %w[SCHEMA TRANSACTION].include?(payload[:name].to_s)

        count += 1
      end
      yield
      count
    ensure
      ActiveSupport::Notifications.unsubscribe(subscriber)
    end

    # 検証用データは必ず後片付けする
    def temporarily(records)
      yield
    ensure
      Array(records).each { |r| r.destroy if r.respond_to?(:destroy) && r.persisted? }
    end
  end
end

# ---------------------------------------------------------------------------

target = ARGV.first

if target.nil?
  puts "章番号を指定してください（例: bin/rails runner tutorial/check_rails.rb 07）"
  $stdout.flush
  exit!(1)
end

chapters =
  if target == "all"
    TutorialCheck::CHAPTERS
  else
    key = target.rjust(2, "0")
    unless TutorialCheck::CHAPTERS.include?(key)
      puts "章 #{target} は存在しません。使えるのは #{TutorialCheck::CHAPTERS.join(', ')} です。"
      $stdout.flush
      exit!(1)
    end
    [ key ]
  end

puts "=" * 62
puts "Rails 編チェック: #{chapters.map { |c| "#{c}章" }.join(', ')}"
puts "=" * 62

# チェックからのリクエストには CSRF トークンが無いため、この実行中だけ検証を切る
# （本物のブラウザからのアクセスでは有効なままなので心配は要らない）
ActionController::Base.allow_forgery_protection = false

# 13章まで進んでいる場合は、ログイン済みの状態でチェックを始める
TutorialCheck.sign_in_default!

chapters.each { |c| TutorialCheck.run(c) }

passed = TutorialCheck.results.count { |status, _, _| status == :pass }
failed = TutorialCheck.results.count { |status, _, _| status == :fail }

puts
puts "-" * 62
puts "結果: #{passed} 件成功 / #{failed} 件失敗"
if failed.zero?
  puts "🎉 この章の要件はすべて満たしています。docs の次の章へ進みましょう。"
else
  puts
  puts "失敗した項目を上から 1 つずつ潰していきましょう。"
  puts "・エラーの詳細は log/development.log に出ています"
  puts "・詰まったら Claude に `/tutorial-hint` と打ってください"
end
puts "-" * 62

# runner の中で通常の exit を呼ぶと Rails 側の後処理で余計なトレースが出るため exit! を使う
$stdout.flush
exit!(failed.zero? ? 0 : 1)
