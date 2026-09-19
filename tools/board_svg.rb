#!/usr/bin/env ruby
# frozen_string_literal: true

# FEN からチェス盤の SVG を生成する図版ツール。
#
#   ruby tools/board_svg.rb "FEN" [options] > out.svg
#
# options:
#   --hl=e4,d5            マスを強調（黄色系）
#   --mark=e3,e4          小さな丸印（移動できるマスなど）
#   --cross=f7            ×印（行けないマス）
#   --arrow=e2e4,g1f3     矢印
#   --bits=0x000000000000FF00   ビットボードの 1 のマスを塗る
#   --labels              全マスにマス名を小さく表示
#   --index               全マスに 0..63 のマス番号を表示
#   --flip                黒番視点
#   --mono                白黒印刷向けの配色
#   --size=360            一辺のピクセル数
#
# 駒は本書オリジナルの簡易シルエット（viewBox 0 0 45 45）。

require "optparse"

module BoardSVG
  FILES = %w[a b c d e f g h].freeze

  PALETTES = {
    color: { light: "#f0d9b5", dark: "#b58863", hl: "#f6e05e", hl_op: 0.75,
             mark: "#2f855a", arrow: "#2b6cb0", bits: "#e53e3e", coord_on_light: "#b58863",
             coord_on_dark: "#f0d9b5", frame: "#5c4033" },
    mono:  { light: "#ffffff", dark: "#c8c8c8", hl: "#707070", hl_op: 0.55,
             mark: "#000000", arrow: "#000000", bits: "#404040", coord_on_light: "#707070",
             coord_on_dark: "#ffffff", frame: "#000000" }
  }.freeze

  # 各駒のシルエット。fill/stroke は描画時に与える。
  PIECES = {
    "p" => <<~SVG,
      <circle cx="22.5" cy="14" r="5.2"/>
      <path d="M17.5 21.5 h10 l1.5 4 h-2.2 l2.7 9 h-14 l2.7 -9 h-2.2 z"/>
      <path d="M12 35 h21 v4 h-21 z"/>
    SVG
    "r" => <<~SVG,
      <path d="M11 9 h5 v3.5 h3.5 v-3.5 h6 v3.5 h3.5 v-3.5 h5 v7 l-3 2.5 h-17 l-3 -2.5 z"/>
      <path d="M14.5 18.5 h16 l1.5 15 h-19 z"/>
      <path d="M10 34 h25 v5 h-25 z"/>
    SVG
    "n" => <<~SVG,
      <path d="M15 38 h19 c0.5-9-1.5-18-5-24 c-2-3.5-5-5.5-8-6 l-1 3.5 l-2.5-2.5 l-0.5 4 c-2.5 2-5 5.5-6.5 9.5 c-0.7 2 0.6 3.5 2.5 3 l3-1 c1.5 0.8 3.3 0.3 4.8-1.2 l1.2-1.5 c0.5 3.5-2.5 6.5-5.5 9.5 c-2 2-3 4-2.5 6.7 z"/>
      <circle cx="19.5" cy="15.5" r="1.3" class="eye"/>
    SVG
    "b" => <<~SVG,
      <circle cx="22.5" cy="7.5" r="2.5"/>
      <path d="M22.5 10.5 c-5 3.5-8 8-8 12 c0 4 3 6 5 7 h6 c2-1 5-3 5-7 c0-4-3-8.5-8-12 z"/>
      <path d="M17 29.5 h11 l1.5 4 h-14 z"/>
      <path d="M10 34 c4 0 8.5 1 12.5 3 c4-2 8.5-3 12.5-3 v4 c-4 0-8.5 1-12.5 3 c-4-2-8.5-3-12.5-3 z"/>
      <path d="M20 19.5 h5 M22.5 17 v5" class="slit"/>
    SVG
    "q" => <<~SVG,
      <circle cx="7" cy="12" r="2.5"/><circle cx="15" cy="8.5" r="2.5"/>
      <circle cx="22.5" cy="7" r="2.5"/><circle cx="30" cy="8.5" r="2.5"/><circle cx="38" cy="12" r="2.5"/>
      <path d="M9 26 l-2 -12 l7 9 l1 -12 l5 11 l2.5 -13 l2.5 13 l5 -11 l1 12 l7 -9 l-2 12 z"/>
      <path d="M9 26 c0 2 1.5 2 2.5 4 c1 1.5 1 1 0.5 3.5 c-1.5 1 -1.5 2.5 -1.5 2.5 c-1.5 1.5 0.5 2.5 0.5 2.5 c6.5 1 16.5 1 23 0 c0 0 1.5 -1 0 -2.5 c0 0 0.5 -1.5 -1 -2.5 c-0.5 -2.5 -0.5 -2 0.5 -3.5 c1 -2 2.5 -2 2.5 -4 c-8.5 -1.5 -18.5 -1.5 -27 0 z"/>
    SVG
    "k" => <<~SVG,
      <path d="M21.2 4 h2.6 v3 h3 v2.6 h-3 v4 h-2.6 v-4 h-3 v-2.6 h3 z"/>
      <path d="M22.5 25 c0 0 4.5-7.5 3-10.5 c0 0-1-2.5-3-2.5 s-3 2.5-3 2.5 c-1.5 3 3 10.5 3 10.5"/>
      <path d="M12.5 37 c5.5 3.5 14.5 3.5 20 0 v-7 c0 0 9-4.5 6-10.5 c-4-6.5-13.5-3.5-16 4 v3.5 v-3.5 c-2.5-7.5-12-10.5-16-4 c-3 6 6 10.5 6 10.5 z"/>
    SVG
  }.freeze

  module_function

  def square_index(name)
    FILES.index(name[0]) + (name[1].to_i - 1) * 8
  end

  def parse_fen_board(fen)
    board = {}
    fen.split.first.split("/").each_with_index do |row, i|
      rank = 7 - i
      file = 0
      row.each_char do |ch|
        if ch =~ /\d/
          file += ch.to_i
        else
          board[file + rank * 8] = ch
          file += 1
        end
      end
    end
    board
  end

  def render(fen, opts = {})
    pal = PALETTES[opts[:mono] ? :mono : :color]
    size = opts.fetch(:size, 360)
    margin = 18
    sq = 45
    total = sq * 8 + margin * 2
    flip = opts[:flip]
    board = parse_fen_board(fen)

    xy = lambda do |idx|
      f = idx % 8
      r = idx / 8
      col = flip ? 7 - f : f
      row = flip ? r : 7 - r
      [margin + col * sq, margin + row * sq]
    end
    center = ->(idx) { x, y = xy.(idx); [x + sq / 2.0, y + sq / 2.0] }

    out = []
    out << %(<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 #{total} #{total}" width="#{size}" height="#{size}" font-family="Helvetica, Arial, sans-serif">)
    out << %(<defs><marker id="ah" viewBox="0 0 10 10" refX="5" refY="5" markerWidth="3.2" markerHeight="3.2" orient="auto-start-reverse"><path d="M0,0 L10,5 L0,10 z" fill="#{pal[:arrow]}"/></marker></defs>)
    out << %(<rect x="0" y="0" width="#{total}" height="#{total}" fill="#ffffff"/>)
    out << %(<rect x="#{margin - 1.5}" y="#{margin - 1.5}" width="#{sq * 8 + 3}" height="#{sq * 8 + 3}" fill="none" stroke="#{pal[:frame]}" stroke-width="1.5"/>)

    bits = opts[:bits]
    hls = Array(opts[:hl]).map { square_index(_1) }

    64.times do |idx|
      x, y = xy.(idx)
      light = ((idx % 8) + (idx / 8)).odd?
      out << %(<rect x="#{x}" y="#{y}" width="#{sq}" height="#{sq}" fill="#{light ? pal[:light] : pal[:dark]}"/>)
      if hls.include?(idx)
        out << %(<rect x="#{x}" y="#{y}" width="#{sq}" height="#{sq}" fill="#{pal[:hl]}" fill-opacity="#{pal[:hl_op]}"/>)
      end
      if bits && bits[idx] == 1
        out << %(<rect x="#{x + 3}" y="#{y + 3}" width="#{sq - 6}" height="#{sq - 6}" fill="#{pal[:bits]}" fill-opacity="0.35" stroke="#{pal[:bits]}" stroke-width="1.5"/>)
      end
    end

    # 座標
    8.times do |i|
      f = flip ? 7 - i : i
      out << %(<text x="#{margin + i * sq + sq / 2}" y="#{total - 4}" font-size="11" text-anchor="middle" fill="#555">#{FILES[f]}</text>)
      r = flip ? i + 1 : 8 - i
      out << %(<text x="#{margin / 2}" y="#{margin + i * sq + sq / 2 + 4}" font-size="11" text-anchor="middle" fill="#555">#{r}</text>)
    end

    if opts[:labels] || opts[:index]
      64.times do |idx|
        x, y = xy.(idx)
        light = ((idx % 8) + (idx / 8)).odd?
        text = opts[:index] ? idx.to_s : "#{FILES[idx % 8]}#{idx / 8 + 1}"
        out << %(<text x="#{x + sq / 2}" y="#{y + sq / 2 + 5}" font-size="14" text-anchor="middle" fill="#{light ? pal[:coord_on_light] : pal[:coord_on_dark]}">#{text}</text>)
      end
    end

    board.each do |idx, ch|
      x, y = xy.(idx)
      white = ch == ch.upcase
      fill = white ? "#ffffff" : "#1a1a1a"
      detail = white ? "#1a1a1a" : "#ffffff"
      body = PIECES.fetch(ch.downcase)
        .gsub('class="eye"', %(fill="#{detail}" stroke="none"))
        .gsub('class="slit"', %(fill="none" stroke="#{detail}" stroke-width="1.5"))
      out << %(<g transform="translate(#{x},#{y})" fill="#{fill}" stroke="#1a1a1a" stroke-width="1.5" stroke-linejoin="round">#{body.gsub("\n", "")}</g>)
    end

    Array(opts[:mark]).each do |s|
      cx, cy = center.(square_index(s))
      out << %(<circle cx="#{cx}" cy="#{cy}" r="7" fill="#{pal[:mark]}" fill-opacity="0.7"/>)
    end

    Array(opts[:cross]).each do |s|
      cx, cy = center.(square_index(s))
      out << %(<path d="M#{cx - 9} #{cy - 9} L#{cx + 9} #{cy + 9} M#{cx + 9} #{cy - 9} L#{cx - 9} #{cy + 9}" stroke="#c53030" stroke-width="4" stroke-linecap="round"/>)
    end

    Array(opts[:arrow]).each do |mv|
      x1, y1 = center.(square_index(mv[0, 2]))
      x2, y2 = center.(square_index(mv[2, 2]))
      len = Math.hypot(x2 - x1, y2 - y1)
      shorten = 12.0
      x2s = x2 - (x2 - x1) * shorten / len
      y2s = y2 - (y2 - y1) * shorten / len
      out << %(<line x1="#{x1}" y1="#{y1}" x2="#{x2s.round(1)}" y2="#{y2s.round(1)}" stroke="#{pal[:arrow]}" stroke-width="6" stroke-opacity="0.8" stroke-linecap="round" marker-end="url(#ah)"/>)
    end

    out << "</svg>"
    out.join("\n") + "\n"
  end
end

if $PROGRAM_NAME == __FILE__
  opts = {}
  OptionParser.new do |o|
    o.on("--hl=LIST")    { opts[:hl] = _1.split(",") }
    o.on("--mark=LIST")  { opts[:mark] = _1.split(",") }
    o.on("--cross=LIST") { opts[:cross] = _1.split(",") }
    o.on("--arrow=LIST") { opts[:arrow] = _1.split(",") }
    o.on("--bits=HEX")   { opts[:bits] = Integer(_1) }
    o.on("--labels")     { opts[:labels] = true }
    o.on("--index")      { opts[:index] = true }
    o.on("--flip")       { opts[:flip] = true }
    o.on("--mono")       { opts[:mono] = true }
    o.on("--size=N", Integer) { opts[:size] = _1 }
  end.parse!(ARGV)
  fen = ARGV.first || "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
  print BoardSVG.render(fen, opts)
end
