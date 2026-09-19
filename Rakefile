# frozen_string_literal: true

require_relative "tools/board_svg"

ROOT = __dir__

desc "book/figures.rb に列挙した盤面図を book/images/ に生成する"
task :figures do
  count = 0
  define_method(:fig) do |name, fen, **opts|
    File.write(File.join(ROOT, "book/images/#{name}.svg"), BoardSVG.render(fen, opts))
    count += 1
  end
  load File.join(ROOT, "book/figures.rb")
  puts "generated #{count} figures"
end

desc "PDF をビルドする (book/output.pdf)"
task pdf: :figures do
  Dir.chdir(File.join(ROOT, "book")) { sh "npx vivliostyle build" }
end

desc "ブラウザでプレビューする"
task preview: :figures do
  Dir.chdir(File.join(ROOT, "book")) { sh "npx vivliostyle preview" }
end

desc "エンジンのテストを実行する"
task :test do
  Dir.chdir(File.join(ROOT, "engine")) do
    sh "ruby -Ilib -Itest -e 'Dir[\"test/**/*_test.rb\"].each { require_relative _1 }'"
  end
end

task default: :test
