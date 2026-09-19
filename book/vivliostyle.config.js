// @ts-check
/** @type {import('@vivliostyle/cli').VivliostyleConfigSchema} */
const vivliostyleConfig = {
  title: 'Ruby でゼロから作る Stockfish 第1巻',
  author: 'champierre',
  language: 'ja',
  size: 'JIS-B5',
  theme: './theme/book.css',
  entry: [
    'chapters/00-preface.html',
    'chapters/01-rules.html',
  ],
  output: ['./output.pdf'],
};

module.exports = vivliostyleConfig;
