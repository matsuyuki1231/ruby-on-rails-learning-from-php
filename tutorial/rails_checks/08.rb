section "08章: コントローラとビュー"

check "resources でプロジェクトのルートを定義している" do
  routes = file_body("config/routes.rb")
  assert!(routes.include?("resources :projects"),
    "config/routes.rb に resources :projects がありません")
  assert!(!routes.match?(/get\s+["']projects\/index["']/),
    "ジェネレータが書いた get \"projects/index\" が残っています。resources に置き換えてください")
  assert_route!(:get, "/projects", to: "projects#index")
  assert_named_route!(:projects)
end

check "個別ページのルートがある" do
  project = projects.first
  assert!(project, "先に 07章の seed を実行してください")
  assert_route!(:get, "/projects/#{project.id}", to: "projects#show")
  assert_named_route!(:project)
end

check "一覧ページに登録済みのプロジェクト名がすべて出ている" do
  names = projects.pluck(:name)
  get!("/projects", includes: names)
end

check "一覧は部分テンプレート（パーシャル）で 1 件分を描いている" do
  assert_file! "app/views/projects/_project.html.erb"
  index = file_body("app/views/projects/index.html.erb")
  assert!(index.match?(/render/), "index.html.erb からパーシャルを render していません")
end

check "詳細ページが表示できる" do
  project = projects.order(:id).first
  get!("/projects/#{project.id}", includes: [ project.name ])
end

check "一覧から詳細へリンクが張られている" do
  project = projects.order(:id).first
  get!("/projects", includes: [ "href=\"/projects/#{project.id}\"" ])
end

check "ヘルパーメソッドを定義してビューから使っている" do
  assert!(ProjectsHelper.instance_methods.include?(:format_due_on),
    "ProjectsHelper に format_due_on を定義してください")

  helper = Object.new.extend(ProjectsHelper)
  assert_equal!("未設定", helper.format_due_on(nil), "nil のときは「未設定」を返してください")

  views = file_body("app/views/projects/_project.html.erb") + file_body("app/views/projects/show.html.erb")
  assert!(views.include?("format_due_on"), "ビューから format_due_on を呼び出していません")
end

check "レイアウトに共通ナビゲーションがある" do
  layout = file_body("app/views/layouts/application.html.erb")
  assert!(layout.include?("projects_path"), "レイアウトに一覧へのリンクを追加してください")
  get!("/", includes: [ 'href="/projects"' ])
end
