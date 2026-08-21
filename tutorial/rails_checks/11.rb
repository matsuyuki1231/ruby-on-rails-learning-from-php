section "11章: アソシエーション（1 対多）"

check "Task モデルとテーブルがある" do
  assert_model!("Task", columns: { project_id: :integer, title: :string, done: :boolean })
end

check "done は既定値 false で NULL を許さない" do
  column = Task.columns_hash["done"]
  assert!(!column.null, "done カラムに null: false を付けてください")
  assert!([ false, "false", "0", 0 ].include?(column.default) || column.default == false,
    "done カラムの既定値を false にしてください（実際: #{column.default.inspect}）")
end

check "Project has_many :tasks / Task belongs_to :project" do
  assert_association!("Project", :has_many, :tasks)
  assert_association!("Task", :belongs_to, :project)
end

check "プロジェクトを消すとタスクも消える（dependent: :destroy）" do
  project = create_project!(name: "関連チェック用プロジェクト")
  project.tasks.create!(title: "ぶら下がりタスク")
  task_id = project.tasks.first.id

  project.destroy
  assert!(Task.find_by(id: task_id).nil?,
    "プロジェクトを消してもタスクが残っています。has_many に dependent: :destroy を付けてください")
end

check "タスクにはタイトルが必須" do
  project = projects.first
  task = project.tasks.build(title: "")
  task.valid?
  assert!(task.errors[:title].any?, "Task の title に presence バリデーションを付けてください")
end

check "scope で完了 / 未完了を絞り込める" do
  assert!(Task.respond_to?(:done), "Task に scope :done を定義してください")
  assert!(Task.respond_to?(:pending), "Task に scope :pending を定義してください")

  project = create_project!(name: "scope チェック用プロジェクト")
  temporarily(project) do
    project.tasks.create!(title: "済んだ仕事", done: true)
    project.tasks.create!(title: "これから", done: false)

    assert_equal!([ "済んだ仕事" ], project.tasks.done.pluck(:title), "done スコープの結果が違います")
    assert_equal!([ "これから" ], project.tasks.pending.pluck(:title), "pending スコープの結果が違います")
  end
end

check "ネストしたルートでタスクを操作できる" do
  project = projects.first
  assert_route!(:post,   "/projects/#{project.id}/tasks",   to: "tasks#create")
  assert_route!(:patch,  "/projects/#{project.id}/tasks/1", to: "tasks#update")
  assert_route!(:delete, "/projects/#{project.id}/tasks/1", to: "tasks#destroy")
end

check "詳細ページからタスクを追加できる" do
  project = create_project!(name: "画面チェック用プロジェクト")
  temporarily(project) do
    post!("/projects/#{project.id}/tasks", params: { task: { title: "画面から追加したタスク" } }, expect: [ 302, 303 ])
    assert_equal!([ "画面から追加したタスク" ], project.tasks.reload.pluck(:title), "タスクが作られていません")
    get!("/projects/#{project.id}", includes: [ "画面から追加したタスク" ])
  end
end

check "タスクの完了 / 未完了を切り替えられる" do
  project = create_project!(name: "完了チェック用プロジェクト")
  temporarily(project) do
    task = project.tasks.create!(title: "切り替え対象")
    patch!("/projects/#{project.id}/tasks/#{task.id}", params: { task: { done: true } }, expect: [ 302, 303 ])
    assert_equal!(true, task.reload.done, "done が true になっていません")
  end
end

check "タスクを削除できる" do
  project = create_project!(name: "削除チェック用プロジェクト")
  temporarily(project) do
    task = project.tasks.create!(title: "消す対象")
    delete!("/projects/#{project.id}/tasks/#{task.id}", expect: [ 302, 303 ])
    assert!(Task.find_by(id: task.id).nil?, "タスクが削除されていません")
  end
end

check "一覧ページの SQL 本数がプロジェクト数に比例して増えない" do
  # プロジェクトを増やしても発行される SQL がほとんど増えないことを確かめる
  extra = 5.times.map { |i| create_project!(name: "N+1 チェック用 #{i}") }
  temporarily(extra) do
    queries = count_queries { get!("/projects") }
    assert!(queries <= 6,
      "一覧表示で SQL が #{queries} 本も発行されています。プロジェクト 1 件ごとにタスクを引きに行っていませんか（N+1 問題）")
    note "発行された SQL: #{queries} 本"
  end
end

check "一覧でタスクをまとめて読み込んでいる" do
  source = file_body("app/controllers/projects_controller.rb")
  assert!(source.match?(/includes|preload|eager_load/),
    "index で Project.includes(:tasks) を使ってタスクをまとめて読み込みましょう")
end
