local M = {}

M.input_file = vim.fn.expand("~/dsa_global_io/input.txt")
M.output_file = vim.fn.expand("~/dsa_global_io/output.txt")

-- Track open/closed state
M.splits_open = false
M.win_ids = {}

local function setup_files()
	vim.fn.mkdir(vim.fn.expand("~/dsa_global_io"), "p")
	if vim.fn.filereadable(M.input_file) == 0 then
		vim.fn.writefile({}, M.input_file)
	end
	if vim.fn.filereadable(M.output_file) == 0 then
		vim.fn.writefile({}, M.output_file)
	end
end

-- Function to paste clipboard content to input file
local function paste_to_input_file()
	-- Get clipboard content
	local clipboard_content = vim.fn.getreg("+")

	-- If empty, try system clipboard
	if clipboard_content == "" then
		clipboard_content = vim.fn.getreg("*")
	end

	if clipboard_content ~= "" then
		-- Split content into lines
		local lines = {}
		for line in string.gmatch(clipboard_content, "[^\r\n]+") do
			table.insert(lines, line)
		end

		-- Write to input file
		vim.fn.writefile(lines, M.input_file)
		print("Clipboard content pasted to input file")

		-- Refresh the input buffer if it's open
		if M.splits_open and vim.api.nvim_win_is_valid(M.win_ids.input) then
			vim.api.nvim_win_call(M.win_ids.input, function()
				vim.cmd("edit!")
			end)
		end
	else
		print("Clipboard is empty")
	end
end

local function open_io_splits()
	-- Paste clipboard content to input file first
	paste_to_input_file()

	-- Vertical split (25% width)
	vim.cmd("botright vnew")
	local right_win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_set_width(right_win, math.floor(vim.o.columns * 0.3))

	local bufnr = vim.api.nvim_win_get_buf(right_win)
	vim.b[bufnr].lualine_disable = true

	-- Horizontal split (input on top, output on bottom)
	vim.cmd("edit " .. M.input_file)
	bufnr = vim.api.nvim_get_current_buf()
	vim.b[bufnr].lualine_disable = true

	vim.cmd("split")
	vim.cmd("edit " .. M.output_file)

	bufnr = vim.api.nvim_get_current_buf()
	vim.b[bufnr].lualine_disable = true

	-- Track window IDs
	M.win_ids = {
		input = vim.fn.win_getid(vim.fn.winnr("j")), -- Input split (below current)
		output = vim.api.nvim_get_current_win(), -- Output split (current)
		main = vim.fn.win_getid(vim.fn.winnr("#")), -- Main coding window
	}

	-- Adjust height (50% each inside the right split)
	vim.api.nvim_win_set_height(M.win_ids.output, math.floor(vim.o.lines * 0.5))
	M.splits_open = true
end

local function close_io_splits()
	for _, win_id in pairs(M.win_ids) do
		if vim.api.nvim_win_is_valid(win_id) then
			vim.api.nvim_win_close(win_id, true)
		end
	end
	M.win_ids = {}
	M.splits_open = false
end

M.toggle_io_splits = function()
	if M.splits_open then
		close_io_splits()
	else
		open_io_splits()
	end
end

-- Add standalone paste function
M.paste_clipboard_to_input = function()
	paste_to_input_file()
end

M.run_cpp_with_gpp = function()
	local file = vim.fn.expand("%:p") -- Current file
	local cmd = string.format(
		"g++ -std=c++23 -O2 -Wall -Wextra -Wshadow -D_GLIBCXX_DEBUG -DLOCAL -o a.out %s && ./a.out < %s > %s",
		vim.fn.shellescape(file),
		vim.fn.shellescape(M.input_file),
		vim.fn.shellescape(M.output_file)
	)

	vim.cmd("silent !" .. cmd)
	vim.cmd("redraw!")
	print("Compiled and ran: " .. file)

	-- Optionally refresh output split if open
	if M.splits_open and vim.api.nvim_win_is_valid(M.win_ids.output) then
		vim.api.nvim_win_call(M.win_ids.output, function()
			vim.cmd("edit!")
		end)
	end
end

M.setup = function()
	setup_files()

	vim.api.nvim_set_keymap(
		"n",
		"<leader>io",
		":lua require('dsa_io').toggle_io_splits()<CR>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_set_keymap(
		"n",
		"<leader>rr",
		":lua require('dsa_io').run_cpp_with_gpp()<CR>",
		{ noremap = true, silent = true }
	)
	-- Add separate keybinding for just pasting to input file without toggling split
	vim.api.nvim_set_keymap(
		"n",
		"<leader>ip",
		":lua require('dsa_io').paste_clipboard_to_input()<CR>",
		{ noremap = true, silent = true }
	)
end

return M
