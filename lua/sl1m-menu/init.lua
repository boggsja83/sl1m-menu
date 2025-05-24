local M = {}
local config = {}
local defaults = {
    user = 'guest',
    keymaps = {
	--greet = { lhs = "<leader>T", desc = "sl1m - greet" },
	pick = { lhs = "<leader>sp", desc = "sl1m - picker" },
    },
}
-----------------------------------------------------------
--testin
-----------------------------------------------------------
--make this a generic funciton and pass in tables of the required info
--for a custom-custom picker
--better yet, make my own popup windows...
function M.show_custom_picker()
    local menu = {
	{ text = "1. greet", action = M.sl1mfunc, desc = "sl1mfunc" },
	{ text = "2. buffers", action = ":buffers", desc = "show buffers" },
    }

    local snacks = require("snacks")

    snacks.picker({
	title = "sl1m menu",
	layout = {
	    preset="default",
	    preview=false,
	},
	items = menu,
	format = function(item, _)
	    return {
		{ item.text, "SnacksPickerText" },
		{ " - " .. (item.desc or ""), "Comment" },
	    }
	end,
	confirm = function(picker, item)
	    picker:close()
	    if type(item.action) == "string" then
		if item.action:find("^:") then
		    vim.cmd(item.action:sub(2)) -- Execute command if it starts with :
		else
		    vim.api.nvim_input(vim.api.nvim_replace_termcodes(item.action, true, true,true))
		end
	    elseif type(item.action) == "function" then
		item.action()
	    end
	end,
    })
end
-----------------------------------------------------------
-- slimfunc
-----------------------------------------------------------
function M.sl1mfunc()
    vim.notify("user: " .. config.user)
end
-----------------------------------------------------------
-- setup
-----------------------------------------------------------
function M.setup(user_config)
    config = vim.tbl_deep_extend("force", defaults, user_config or {})
    if config.keymaps.greet then
	vim.keymap.set("n", config.keymaps.greet.lhs, M.sl1mfunc, { desc = config.keymaps.greet.desc })
    end
    if config.keymaps.pick then
	vim.keymap.set("n", config.keymaps.pick.lhs, M.show_custom_picker, { desc = config.keymaps.pick.desc })
    end
end
-----------------------------------------------------------
return M
-----------------------------------------------------------
