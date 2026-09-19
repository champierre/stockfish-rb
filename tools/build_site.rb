#!/usr/bin/env ruby
# frozen_string_literal: true

# book/ の原稿から GitHub Pages 用の Web 版を _site/ に組み立てる。
#   ruby tools/build_site.rb
# 章の順番は book/vivliostyle.config.js の entry に従う。

require "fileutils"

ROOT = File.expand_path("..", __dir__)
BOOK = File.join(ROOT, "book")
SITE = File.join(ROOT, "_site")

config = File.read(File.join(BOOK, "vivliostyle.config.js"))
title = config[/title:\s*'([^']+)'/, 1]
entries = config[/entry:\s*\[(.*?)\]/m, 1].scan(/'([^']+)'/).flatten

chapters = entries.map do |path|
  html = File.read(File.join(BOOK, path))
  h1 = html[%r{<h1 class="chapter" data-chapter="(\d+)">(.*?)</h1>}m]
  num = Regexp.last_match(1).to_i
  label = num.zero? ? "はじめに" : "第#{num}章 #{Regexp.last_match(2)}"
  { path: path, file: File.basename(path), html: html, label: h1 ? label : File.basename(path) }
end

FileUtils.rm_rf(SITE)
FileUtils.mkdir_p(File.join(SITE, "chapters"))
FileUtils.cp_r(File.join(BOOK, "images"), SITE)
FileUtils.cp_r(File.join(BOOK, "theme"), SITE)
pdf = File.join(BOOK, "output.pdf")
FileUtils.cp(pdf, File.join(SITE, "stockfish-rb.pdf")) if File.exist?(pdf)

head_extra = <<~HTML
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="../theme/book.css">
  <link rel="stylesheet" href="../theme/web.css">
HTML

chapters.each_with_index do |ch, i|
  prev_ch = i.positive? ? chapters[i - 1] : nil
  next_ch = chapters[i + 1]
  nav = +%(<nav class="web-nav">)
  nav << (prev_ch ? %(<a href="#{prev_ch[:file]}">← #{prev_ch[:label]}</a>) : "<span></span>")
  nav << %(<a href="../index.html">目次</a>)
  nav << (next_ch ? %(<a href="#{next_ch[:file]}">#{next_ch[:label]} →</a>) : "<span></span>")
  nav << "</nav>"

  html = ch[:html]
    .sub("</head>", "#{head_extra}<title>#{ch[:label]} | #{title}</title>\n</head>")
    .sub(%r{<title>.*?</title>\n?}, "") # 元の <title> を差し替え
    .sub("<body>", %(<body>\n<main class="web-page">\n#{nav}))
    .sub("</body>", "#{nav}\n</main>\n</body>")
  File.write(File.join(SITE, "chapters", ch[:file]), html)
end

toc = chapters.map { %(<li><a href="chapters/#{_1[:file]}">#{_1[:label]}</a></li>) }.join("\n")
File.write(File.join(SITE, "index.html"), <<~HTML)
  <!DOCTYPE html>
  <html lang="ja">
  <head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>#{title}</title>
  <link rel="stylesheet" href="theme/book.css">
  <link rel="stylesheet" href="theme/web.css">
  </head>
  <body>
  <main class="web-page">
  <h1 class="web-title">#{title}</h1>
  <p class="web-lead">チェスエンジン Stockfish の仕組みを、Ruby でゼロから作り直しながら学ぶ本です。先生役の Claude と生徒役の champierre の対話で進みます。現在執筆中。</p>
  <p class="web-links"><a href="stockfish-rb.pdf">PDF 版をダウンロード</a> ・ <a href="https://github.com/champierre/stockfish-rb">GitHub</a></p>
  <h2>目次</h2>
  <ul class="web-toc">
  #{toc}
  </ul>
  </main>
  </body>
  </html>
HTML

puts "built #{chapters.size} chapters into _site/"
