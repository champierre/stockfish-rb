# 本文で使う盤面図の一覧。`rake figures` で book/images/ に SVG を生成する。
#   fig "ファイル名", "FEN", オプション（tools/board_svg.rb と同じキー）

START = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

# ---- 第1章 チェスのルール超入門 ----
fig "ch01-start",  START
fig "ch01-coords", "8/8/8/8/8/8/8/8 w - - 0 1", labels: true, hl: %w[e4]
fig "ch01-rook",   "8/8/8/8/3R4/8/8/8 w - - 0 1",
    mark: %w[d1 d2 d3 d5 d6 d7 d8 a4 b4 c4 e4 f4 g4 h4]
fig "ch01-bishop", "8/8/8/8/3B4/8/8/8 w - - 0 1",
    mark: %w[a1 b2 c3 e5 f6 g7 h8 a7 b6 c5 e3 f2 g1]
fig "ch01-queen",  "8/8/8/8/3Q4/8/8/8 w - - 0 1",
    mark: %w[d1 d2 d3 d5 d6 d7 d8 a4 b4 c4 e4 f4 g4 h4 a1 b2 c3 e5 f6 g7 h8 a7 b6 c5 e3 f2 g1]
fig "ch01-king",   "8/8/8/8/3K4/8/8/8 w - - 0 1",
    mark: %w[c3 d3 e3 c4 e4 c5 d5 e5]
fig "ch01-knight", "8/8/8/8/3N4/8/8/8 w - - 0 1",
    mark: %w[c2 e2 b3 f3 b5 f5 c6 e6]
fig "ch01-knight-jump", "8/8/8/2ppp3/2pNp3/2ppp3/8/8 w - - 0 1",
    mark: %w[c2 e2 b3 f3 b5 f5 c6 e6], arrow: %w[d4f5]
fig "ch01-pawn",   "8/8/8/8/8/8/4P3/8 w - - 0 1", mark: %w[e3 e4]
fig "ch01-pawn-capture", "8/8/8/3ppn2/4P3/8/8/8 w - - 0 1",
    arrow: %w[e4d5 e4f5], cross: %w[e5]
fig "ch01-blocked-rook", "8/8/3p4/8/1P1R4/8/8/8 w - - 0 1",
    mark: %w[d1 d2 d3 d5 c4 e4 f4 g4 h4], hl: %w[d6], cross: %w[a4 d7 d8]
fig "ch01-ep-before", "4k3/3p4/8/4P3/8/8/8/4K3 b - - 0 1", arrow: %w[d7d5]
fig "ch01-ep-after",  "4k3/8/8/3pP3/8/8/8/4K3 w - d6 0 1", arrow: %w[e5d6], hl: %w[d6], cross: %w[d5]
fig "ch01-ep-same",   "4k3/8/8/3pP3/8/8/8/4K3 w - - 0 1"
