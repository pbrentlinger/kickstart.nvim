return {
  'tigion/nvim-asciidoc-preview',
  ft = { 'asciidoc' },
  build = 'cd server && npm install --omit=dev',
  opts = {
    server = {
      -- Determines how the AsciiDoc file is converted to HTML for the preview.
      -- `js`  - asciidoctor.js (no local installation needed)
      -- `cmd` - asciidoctor command (local installation needed)
      converter = 'cmd',

      -- Determines the local port of the preview website.
      -- Must be between 10000 and 65535.
      port = 11235,
    },
    preview = {
      -- Determines the scroll position of the preview website.
      -- `current` - Keep current scroll position
      -- `start`   - Start of the website
      -- `sync`    - (experimental) Same (similar) position as in Neovim
      --             => inaccurate, because very content dependent
      position = 'current',
    },
  },
}
