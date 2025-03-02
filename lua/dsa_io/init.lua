local M = {}

M.input_file = "~/dsa_global_io/input.txt"
M.output_file = "~/dsa_global_io/output.txt"

local function setup_files()
	vim.fn.mkdir(vim.fn.expand("~/dsa_global_io"), "p")
	if vim.fn.filereadable(M.input_file) == 0 then
		vim.fn.writefile({}, vim.fn.expand(M.input_file), "b")
	end
	if vim.fn.filereadable(M.output_file) == 0 then
		vim.fn.writefile({}, vim.fn.expand(M.output_file), "b")
	end
end

M.open_io_splits = function()
	vim.cmd("vsplit " .. M.input_file)
	vim.cmd("split " .. M.output_file)
end

M.run_cpp_with_gpp = function()
	local file = vim.fn.expand("%:p") -- Current file
	local cmd = string.format(
		"g++ -std=c++23 -O2 -Wall -Wextra -Wshadow -D_GLIBCXX_DEBUG -DLOCAL -o a.out %s && ./a.out < %s > %s",
		file,
		M.input_file,
		M.output_file
	)
	vim.cmd("silent !" .. cmd)
	vim.cmd("redraw!")
	print("Ran file with gpp: " .. file)
end

M.setup = function()
	setup_files()

	vim.api.nvim_set_keymap(
		"n",
		"<leader>io",
		":lua require('dsa_io').open_io_splits()<CR>",
		{ noremap = true, silent = true }
	)
	vim.api.nvim_set_keymap(
		"n",
		"<leader>rr",
		":lua require('dsa_io').run_cpp_with_gpp()<CR>",
		{ noremap = true, silent = true }
	)
end

return M
