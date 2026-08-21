section "12章: テストを書く"

check "fixtures を自分のデータに書き換えている" do
  projects_yml = file_body("test/fixtures/projects.yml")
  assert!(!projects_yml.include?("MyString"),
    "test/fixtures/projects.yml がジェネレータの初期値（MyString）のままです")
  assert!(file_body("test/fixtures/tasks.yml").match?(/project:/),
    "test/fixtures/tasks.yml でタスクを project に紐付けてください")
end

check "モデルのテストを 3 つ以上書いている" do
  source = file_body("test/models/project_test.rb")
  count = source.scan(/^\s*test\s+["']/).size
  assert!(count >= 3, "test/models/project_test.rb のテストが #{count} 件です。3 件以上書きましょう")
  assert!(source.match?(/assert_not|assert\s/), "assert 系のメソッドで検証してください")
end

check "タスク側のテストも書いている" do
  assert_file! "test/models/task_test.rb"
  source = file_body("test/models/task_test.rb")
  assert!(source.scan(/^\s*test\s+["']/).size >= 2,
    "test/models/task_test.rb のテストが足りません（2 件以上）")
end

check "統合テスト（画面をまたぐテスト）を書いている" do
  files = Dir[Rails.root.join("test/integration/*_test.rb")]
  assert!(files.any?, "test/integration に統合テストがありません")

  source = files.map { |f| File.read(f) }.join
  assert!(source.include?("ActionDispatch::IntegrationTest"), "IntegrationTest を継承してください")
  assert!(source.match?(/get\s|post\s/), "get / post でリクエストを送ってください")
  assert!(source.include?("assert_response"), "assert_response でステータスを検証してください")
end

check "ジェネレータが置いていったテストが壊れたままになっていない" do
  source = file_body("test/controllers/projects_controller_test.rb")
  assert!(!source.match?(/projects_index_url|projects_show_url/),
    "generate controller が書いた projects_index_url が残っています。resources のパスヘルパー（projects_path など）に直しましょう")
end

check "bin/rails test がすべて通る（少し時間がかかります）" do
  output = IO.popen([ RbConfig.ruby, "bin/rails", "test" ], chdir: Rails.root.to_s, err: [ :child, :out ], &:read)
  success = $?.success?
  summary = output.lines.grep(/runs,/).last.to_s.strip
  assert!(success, "テストが失敗しています。bin/rails test を自分で実行して内容を確認してください\n      #{summary}")
  note "テスト結果: #{summary}"
end
