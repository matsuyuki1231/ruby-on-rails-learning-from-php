section "05章: はじめての画面（ルート → コントローラ → ビュー）"

check "GET / が pages#home に繋がっている" do
  assert_route!(:get, "/", to: "pages#home")
end

check "GET /about が pages#about に繋がっている" do
  assert_route!(:get, "/about", to: "pages#about")
end

check "PagesController がある" do
  assert_file! "app/controllers/pages_controller.rb"
end

check "home / about のビューがある" do
  assert_file! "app/views/pages/home.html.erb"
  assert_file! "app/views/pages/about.html.erb"
end

check "トップページが表示でき、h1 にアプリ名が出ている" do
  body = get!("/", includes: [ "タスク管理アプリ" ])
  assert!(body.match?(/<h1[^>]*>[^<]*タスク管理アプリ/), "h1 見出しの中にアプリ名を入れてください")
end

check "コントローラからビューへインスタンス変数を渡している" do
  erb = file_body("app/views/pages/home.html.erb")
  assert!(erb.match?(/<%=\s*@\w+/), "home.html.erb の中で <%= @変数 %> を出力していません")

  controller = file_body("app/controllers/pages_controller.rb")
  assert!(controller.match?(/@\w+\s*=/), "PagesController#home でインスタンス変数を代入していません")
end

check "トップページに今日の日付が表示されている" do
  source = file_body("app/views/pages/home.html.erb") + file_body("app/controllers/pages_controller.rb")
  assert!(source.match?(/Date\.|Time\./), "Date.current や Time.current を使って今日の日付を出しましょう")
  get!("/", includes: [ Date.current.year.to_s ])
end

check "/about が表示できる" do
  get!("/about", includes: [ "このアプリについて" ])
end
