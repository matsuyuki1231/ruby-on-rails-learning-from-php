section "07章: モデルとマイグレーション"

check "Project モデルとテーブルがある" do
  assert_model!("Project",
    columns: { name: :string, description: :text, due_on: :date, created_at: :datetime, updated_at: :datetime })
end

check "マイグレーションが適用済みで db/schema.rb が更新されている" do
  assert_file! "db/schema.rb"
  assert!(file_body("db/schema.rb").include?('create_table "projects"'),
    "db/schema.rb に projects テーブルがありません（bin/rails db:migrate は実行しましたか？）")
  pending = ActiveRecord::Base.connection_pool.migration_context.needs_migration?
  assert!(!pending, "未適用のマイグレーションがあります。bin/rails db:migrate を実行してください")
end

check "db/seeds.rb でプロジェクトを登録している" do
  seeds = file_body("db/seeds.rb")
  assert!(seeds.match?(/Project/), "db/seeds.rb に Project を作るコードがありません")
  assert!(seeds.match?(/find_or_create_by|upsert|create!/),
    "何度実行しても壊れないように find_or_create_by! などを使いましょう")
end

check "seed データが 3 件以上入っている" do
  assert!(projects.count >= 3,
    "Project が #{projects.count} 件しかありません（bin/rails db:seed を実行しましたか？）")
end

check "登録したプロジェクトに名前と期限が入っている" do
  project = projects.first
  assert!(project.name.present?, "name が空のプロジェクトがあります")
  assert!(projects.where.not(due_on: nil).any?, "due_on を設定したプロジェクトが 1 件もありません")
end

check "Active Record の基本操作ができる状態になっている" do
  project = create_project!(name: "チェック用の一時プロジェクト", description: "自動チェックが作成しました")
  temporarily(project) do
    assert!(projects.find_by(name: "チェック用の一時プロジェクト").present?, "find_by で取得できません")
    project.update!(description: "更新後")
    assert_equal!("更新後", project.reload.description, "update! の結果が保存されていません")
  end
  assert!(projects.find_by(name: "チェック用の一時プロジェクト").nil?, "後片付けに失敗しました")
end
