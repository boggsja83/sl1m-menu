
return
{
    dir = vim.fn.stdpath("config") .. "/lua/sl1m-menu",
    config = function()
	require("sl1m-menu").setup()
	--vim.keymap.set("n", "<leader>T",sl1m.sl1mfunc, { noremap = false, desc = "DeZ NO0tS"})
    end,

}
