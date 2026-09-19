# Ruby でゼロから作る Stockfish

チェスエンジン Stockfish の仕組みを、Ruby でゼロから再実装しながら学ぶ技術書（技術書典向け）の原稿とコード。

- `book/` … Vivliostyle による原稿（HTML + CSS）
- `engine/` … 本書で作るチェスエンジン本体（仮称 rubyfish）
- `tools/board_svg.rb` … FEN から盤面図 SVG を生成するツール
- `dialogues/` … 執筆中の Claude と champierre のやり取りのログ

## ビルド

```sh
cd book && npm install && cd ..
rake figures   # book/figures.rb の盤面図を生成
rake pdf       # book/output.pdf を生成
rake preview   # ブラウザでプレビュー
rake test      # エンジンのテスト
```

必要なもの：Ruby 3.4 以降、Node.js 22 以降

## 公開

`main` に push すると GitHub Actions（`.github/workflows/pages.yml`）が PDF と Web 版をビルドし、GitHub Pages に公開する。

- Web 版：https://champierre.github.io/stockfish-rb/
- ローカルで Web 版を組み立てる：`rake pdf && ruby tools/build_site.rb`（`_site/` に出力）
