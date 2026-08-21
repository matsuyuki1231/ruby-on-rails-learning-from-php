section "10章: バリデーションとエラー表示"

check "名前は必須" do
  assert_invalid!("Project", { name: "" })
  assert_invalid!("Project", { name: nil })
end

check "名前は 50 文字まで" do
  assert_valid!("Project", { name: "あ" * 50 })
  assert_invalid!("Project", { name: "あ" * 51 })
end

check "名前は重複できない" do
  existing = projects.first
  assert!(existing, "先に 07章の seed を実行してください")
  assert_invalid!("Project", { name: existing.name })
end

check "データベース側にもユニーク制約がある" do
  indexes = ActiveRecord::Base.connection.indexes("projects")
  # 13章で「ユーザーごとに一意」へ張り替えるので、name を含むユニーク索引があれば合格とする
  unique_on_name = indexes.any? { |i| i.unique && i.columns.include?("name") }
  assert!(unique_on_name,
    "projects.name にユニークインデックスがありません（マイグレーションで add_index ... unique: true）")
end

check "独自バリデーション: 期限に過去の日付は入れられない（新規作成時）" do
  assert_invalid!("Project", { name: "過去日テスト", due_on: Date.current - 1 }, on: :due_on)
  assert_valid!("Project", { name: "未来日テスト", due_on: Date.current + 1 })
end

check "不正な入力での作成は保存されず 422 が返る" do
  before = projects.count
  post!("/projects", params: { project: { name: "" } }, expect: 422)
  assert_equal!(before, projects.count, "バリデーションに失敗したのに保存されています")
end

check "エラー時にフォームへエラーメッセージが表示される" do
  post!("/projects", params: { project: { name: "" } }, expect: 422)
  body = session.response.body
  assert!(body.include?("error_explanation") || body.match?(/件のエラー/),
    "フォームにエラー一覧を表示してください（_form.html.erb で project.errors を出す）")
end

check "エラー時に入力済みの値が残る" do
  post!("/projects", params: { project: { name: "", description: "消えたら困る説明" } }, expect: 422)
  assert!(session.response.body.include?("消えたら困る説明"),
    "render :new で @project を再利用すると入力値が残ります（redirect_to にしていませんか？）")
end
