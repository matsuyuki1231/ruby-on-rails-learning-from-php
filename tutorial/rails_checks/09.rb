section "09章: CRUD とフォーム"

check "resources :projects で 7 つのアクションが揃っている" do
  project = projects.first
  assert!(project, "先に 07章の seed を実行してください")

  assert_route!(:get,    "/projects",              to: "projects#index")
  assert_route!(:post,   "/projects",              to: "projects#create")
  assert_route!(:get,    "/projects/new",          to: "projects#new")
  assert_route!(:get,    "/projects/#{project.id}", to: "projects#show")
  assert_route!(:get,    "/projects/#{project.id}/edit", to: "projects#edit")
  assert_route!(:patch,  "/projects/#{project.id}", to: "projects#update")
  assert_route!(:delete, "/projects/#{project.id}", to: "projects#destroy")
end

check "新規作成フォームが表示できる" do
  body = get!("/projects/new")
  assert!(body.include?("<form"), "フォームが描画されていません")
  assert!(body.include?('name="project[name]"'),
    "form_with model: を使って project[name] という名前の入力欄を作ってください")
end

check "新規作成と編集で同じフォームパーシャルを使い回している" do
  assert_file! "app/views/projects/_form.html.erb"
  %w[new edit].each do |action|
    erb = file_body("app/views/projects/#{action}.html.erb")
    assert!(erb.match?(/render\s+["']form["']|render\s+partial:\s*["']form["']/),
      "#{action}.html.erb がフォームパーシャルを render していません")
  end
end

check "Strong Parameters で受け取る項目を絞っている" do
  source = file_body("app/controllers/projects_controller.rb")
  assert!(source.match?(/params\.expect|params\.require/),
    "project_params で params.expect（または params.require(...).permit）を使ってください")
  assert!(source.match(/private/), "project_params は private にしましょう")
end

check "フォーム送信でプロジェクトを作成できる" do
  before = projects.count
  post!("/projects", params: { project: { name: "自動チェックが作ったプロジェクト", description: "説明", due_on: Date.current.to_s } },
        expect: [ 302, 303 ])
  assert_equal!(before + 1, projects.count, "レコードが増えていません")

  created = projects.find_by(name: "自動チェックが作ったプロジェクト")
  assert!(created, "作成したはずのレコードが見つかりません")
  assert!(redirect_location.to_s.include?("/projects/#{created.id}"),
    "作成後は作ったプロジェクトの詳細ページへ redirect_to しましょう（実際の遷移先: #{redirect_location}）")
end

check "作成時に flash メッセージを出している" do
  created = projects.find_by(name: "自動チェックが作ったプロジェクト")
  get!("/projects/#{created.id}")
  layout = file_body("app/views/layouts/application.html.erb")
  assert!(layout.include?("flash"), "レイアウトで flash を表示していません")
end

check "編集フォームに既存の値が入っている" do
  created = projects.find_by(name: "自動チェックが作ったプロジェクト")
  get!("/projects/#{created.id}/edit", includes: [ "自動チェックが作ったプロジェクト" ])
end

check "更新できる" do
  created = projects.find_by(name: "自動チェックが作ったプロジェクト")
  patch!("/projects/#{created.id}", params: { project: { name: "更新後の名前" } }, expect: [ 302, 303 ])
  assert_equal!("更新後の名前", created.reload.name, "update が反映されていません")
end

check "削除できる" do
  created = projects.find_by(name: "更新後の名前")
  assert!(created, "1 つ前のチェックが通っている必要があります")
  delete!("/projects/#{created.id}", expect: [ 302, 303 ])
  assert!(projects.find_by(id: created.id).nil?, "レコードが削除されていません")
end

check "一覧と詳細から作成・編集・削除に辿り着ける" do
  project = projects.order(:id).first
  get!("/projects", includes: [ 'href="/projects/new"' ])
  get!("/projects/#{project.id}", includes: [ "/projects/#{project.id}/edit" ])
end
