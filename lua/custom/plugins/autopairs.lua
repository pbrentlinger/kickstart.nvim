if vim.g.vscode then
    -- VSCode extension not needed
else
    -- ordinary Neovim
 return{
	"windwp/nvim-autopairs",
	config = function ()
		require("nvim-autopairs").setup {}
	end,
}
end
