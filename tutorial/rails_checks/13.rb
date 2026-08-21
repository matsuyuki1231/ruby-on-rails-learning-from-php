section "13章: ログイン機能をつける"

check "User と Session のモデルとテーブルがある" do
  assert_model!("User", columns: { email_address: :string, password_digest: :string })
  assert_model!("Session", columns: { user_id: :integer })
end

check "ApplicationController に認証が組み込まれている" do
  source = file_body("app/controllers/application_controller.rb")
  assert!(source.include?("Authentication"), "include Authentication がありません")
end

check "プロジェクトはユーザーに属している" do
  assert_association!("Project", :belongs_to, :user)
  assert_association!("User", :has_many, :projects)
  assert!(!Project.columns_hash["user_id"].null, "projects.user_id は null: false にしましょう")
end

check "ログインしていないとプロジェクト一覧に入れない" do
  reset_session!
  get!("/projects", expect: 302)
  assert!(redirect_location.to_s.include?("session"),
    "未ログインならログイン画面へ飛ばしてください（実際の遷移先: #{redirect_location}）")
end

check "トップページはログインしていなくても見られる" do
  reset_session!
  get!("/", expect: 200)
  note "PagesController の allow_unauthenticated_access が効いています"
end

check "ログインするとプロジェクト一覧が見られる" do
  user = User.find_or_create_by!(email_address: "checker@example.com") { |u| u.password = "checker-password" }
  user.projects.find_or_create_by!(name: "チェッカー専用プロジェクト")

  reset_session!
  post!("/session", params: { email_address: "checker@example.com", password: "checker-password" },
        expect: [ 302, 303 ])
  get!("/projects", expect: 200, includes: [ "チェッカー専用プロジェクト" ])
end

check "他人のプロジェクトは見えない" do
  other = User.find_or_create_by!(email_address: "other@example.com") { |u| u.password = "other-password" }
  other_project = other.projects.find_or_create_by!(name: "他人のプロジェクト")

  # 直前のチェックで checker としてログインしたままアクセスする
  get!("/projects", expect: 200, excludes: [ "他人のプロジェクト" ])

  session.get("/projects/#{other_project.id}")
  reset_execution_context!
  assert!([ 404, 302 ].include?(session.response.status),
    "他人のプロジェクトの詳細が見えてしまっています（ステータス: #{session.response.status}）。" \
    "Current.user.projects.find を使いましょう")
end

check "画面からログアウトできる" do
  layout = file_body("app/views/layouts/application.html.erb")
  assert!(layout.match?(/session_path|new_session_path/),
    "レイアウトにログイン / ログアウトのリンクを置きましょう")

  delete!("/session", expect: [ 302, 303 ])
  get!("/projects", expect: 302)
end

check "seed がユーザーごと作り直せるようになっている" do
  seeds = file_body("db/seeds.rb")
  assert!(seeds.include?("User"), "db/seeds.rb でユーザーも作るようにしてください")
  assert!(seeds.match?(/\.projects\./), "プロジェクトはユーザー経由（user.projects）で作りましょう")
end

check "認証を足したあともテストが全部通る" do
  output = IO.popen([ RbConfig.ruby, "bin/rails", "test" ], chdir: Rails.root.to_s, err: [ :child, :out ], &:read)
  success = $?.success?
  summary = output.lines.grep(/runs,/).last.to_s.strip
  assert!(success,
    "テストが失敗しています。fixtures に user を足す・テストで sign_in_as する、などの手当てが必要です
      #{summary}")
  note "テスト結果: #{summary}"
end

check "チェック用に作ったデータを片付ける" do
  User.where(email_address: [ "checker@example.com", "other@example.com" ]).destroy_all
  assert!(User.find_by(email_address: "checker@example.com").nil?, "後片付けに失敗しました")
  sign_in_default!
end
