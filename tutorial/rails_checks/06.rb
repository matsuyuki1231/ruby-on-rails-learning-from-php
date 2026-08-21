section "06章: ルーティングとパラメータ"

check "GET /greet/:name が pages#greet に繋がっている" do
  assert_route!(:get, "/greet/matsu", to: "pages#greet")
end

check "名前付きルート greet_path が使える" do
  assert_named_route!(:greet)
end

check "URL の一部（params[:name]）を画面に出せている" do
  get!("/greet/matsu", includes: [ "matsu" ])
  get!("/greet/rails", includes: [ "rails" ], excludes: [ "matsu" ])
end

check "クエリ文字列 ?style=shout で大文字表示になる" do
  get!("/greet/matsu?style=shout", includes: [ "MATSU" ])
end

check "トップページから about へ link_to でリンクしている" do
  erb = file_body("app/views/pages/home.html.erb")
  assert!(erb.include?("link_to"), "home.html.erb で link_to を使ってください（<a href> の直書きはしない）")
  assert!(erb.match?(/about_path/), "リンク先はパス文字列ではなく about_path で書きましょう")
  get!("/", includes: [ 'href="/about"' ])
end
