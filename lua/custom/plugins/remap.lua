return {
	-- move highlighted items
	vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv"),
	vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv"),

	-- Makes cursor stay in place with appending lines together
	vim.keymap.set("n", "J", "mzJ`z"),
	-- with half page jumps cursor stays in middle of screen
	vim.keymap.set("n", "<C-d>", "<C-d>zz"),
	vim.keymap.set("n", "<C-u>", "<C-u>zz"),
	-- seartch terms stay in the middle of the sceen.
	vim.keymap.set("n", "n", "nzzzv"),
	vim.keymap.set("n", "N", "Nzzzv"),


	-- greatest remap ever: deletes hightlighted word into the void register and pastes without
	-- losing what was in the main register
	vim.keymap.set("x", "<leader>p", [["_dP]]),

	-- next greatest remap ever : asbjornHaland -> Yank into system clipboard.
	vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]]),
	vim.keymap.set("n", "<leader>Y", [["+Y]]),

	vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]]),

	-- This is going to get me cancelled
	vim.keymap.set("i", "<C-c>", "<Esc>"),
	-- Nope we don't want to record, thanks
	vim.keymap.set("n", "Q", "<nop>"),


	-- vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")


	vim.keymap.set("n", "<leader>f", vim.lsp.buf.format),

	-- quick fix navigation
	vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz"),
	vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz"),
	vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz"),
	vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz"),

	-- menu to replace word you are on
	vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]]),

	-- makes script executable
	vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true }),

}
