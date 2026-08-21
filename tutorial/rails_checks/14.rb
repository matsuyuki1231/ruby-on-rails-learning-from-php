section "14章: 検索と日本語化"

check "既定のロケールが日本語になっている" do
  assert_equal!(:ja, I18n.default_locale, "config/application.rb で config.i18n.default_locale = :ja を設定してください")
  assert_file! "config/locales/ja.yml"
end

check "モデル名と属性名が日本語になる" do
  assert_equal!("プロジェクト", Project.model_name.human, "ja.yml の activerecord.models を確認してください")
  assert_equal!("名前", Project.human_attribute_name(:name), "ja.yml の activerecord.attributes を確認してください")
  assert_equal!("期限", Project.human_attribute_name(:due_on))
  assert_equal!("タイトル", Task.human_attribute_name(:title))
end

check "バリデーションのエラーメッセージが日本語になる" do
  project = Project.new(name: "")
  project.valid?
  messages = project.errors.full_messages
  assert!(messages.any? { |m| m.include?("名前") && m.include?("入力") },
    "「名前を入力してください」のようなメッセージになっていません（実際: #{messages.inspect}）")
  assert!(messages.none? { |m| m.match?(/[A-Za-z]{3,}/) },
    "英語のままのメッセージが残っています（実際: #{messages.inspect}）。ja.yml に足りないキーを追加しましょう")
end

check "Project に検索用のスコープがある" do
  assert!(Project.respond_to?(:search), "Project に scope :search を定義してください")
  source = file_body("app/models/project.rb")
  assert!(source.include?("sanitize_sql_like"),
    "LIKE 検索では sanitize_sql_like でキーワードをエスケープしましょう（% や _ の混入対策）")
end

check "キーワードが空なら全件返る" do
  user = User.find_or_create_by!(email_address: "search-checker@example.com") { |u| u.password = "search-password" }
  user.projects.find_or_create_by!(name: "検索用アルファ")
  user.projects.find_or_create_by!(name: "検索用ベータ")

  assert_equal!(2, user.projects.search(nil).count, "キーワードが nil のときは絞り込まないでください")
  assert_equal!(2, user.projects.search("").count, "キーワードが空文字のときは絞り込まないでください")
end

check "キーワードで部分一致検索できる" do
  user = User.find_by(email_address: "search-checker@example.com")
  assert_equal!([ "検索用アルファ" ], user.projects.search("アルファ").pluck(:name))
  assert_equal!(2, user.projects.search("検索用").count)
  assert_equal!(0, user.projects.search("存在しない名前").count)
end

check "ワイルドカード文字を渡しても全件一致にならない" do
  user = User.find_by(email_address: "search-checker@example.com")
  assert_equal!(0, user.projects.search("%").count,
    "% がそのまま LIKE のワイルドカードとして効いてしまっています")
end

check "一覧画面に検索フォームがあり、絞り込みが効く" do
  user = User.find_by(email_address: "search-checker@example.com")
  reset_session!
  post!("/session", params: { email_address: user.email_address, password: "search-password" }, expect: [ 302, 303 ])

  get!("/projects", includes: [ "検索用アルファ", "検索用ベータ" ])
  get!("/projects?q=#{CGI.escape('アルファ')}", includes: [ "検索用アルファ" ], excludes: [ "検索用ベータ" ])
end

check "チェック用に作ったデータを片付ける" do
  User.where(email_address: "search-checker@example.com").destroy_all
  assert!(User.find_by(email_address: "search-checker@example.com").nil?, "後片付けに失敗しました")
  sign_in_default!
end
