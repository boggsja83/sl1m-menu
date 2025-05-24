local M = {}
local config = {}
local defaults = {
    user = 'guest',
    keymaps = {
	--greet = { lhs = "<leader>T", desc = "sl1m - greet" },
	pick = { lhs = "<leader>sp", desc = "sl1m - picker" },
	popup = { lhs = "<leader>sx", desc = "sl1m - popup" },
    },
}


-----------------------------------------------------------
-- testin popup from scratch
-----------------------------------------------------------

-----------------------------------------------------------
-- buffers_listed()
-----------------------------------------------------------
function M.get_listed_buffers()
    local buffers = vim.api.nvim_list_bufs()
    local listed_buffers = {}
    for _, buf in ipairs(buffers) do
	if vim.api.nvim_buf_get_option_value('buflisted', buf) then
	    local name = vim.api.nvim_buf_get_name(buf)
	    name = name == "" and "[Unnamed]" or vim.fn.fnamemodify(name, ":t")
	    table.insert(listed_buffers, string.format("%d: %s", buf, name))
	end
    end
end


-----------------------------------------------------------
-- Function to create and show a popup window
function M.show_popup()
    -- Create a new empty buffer
    local buf = vim.api.nvim_create_buf(false, true) -- false: not listed, true: scratch buffer

    -- Set buffer content (example lines)
    --[[
    local lines = {
        "Hello, this is a popup!",
        "Press q to close.",
    }
    ]]--
    local lines = M.get_listed_buffers()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

    -- Window configuration
    local width = 30
    local height = 5
    local opts = {
        style = "minimal", -- Minimal style for the window
        relative = "editor", -- Position relative to the editor
        width = width,
        height = height,
        row = math.floor(((vim.o.lines - height) / 2)), -- Center vertically
        col = math.floor((vim.o.columns - width) / 2), -- Center horizontally
        border = "single", -- Border style (single, double, rounded, none, etc.)
    }

    -- Open the floating window
    local win = vim.api.nvim_open_win(buf, true, opts)

    -- Optional: Set keymap to close the popup
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':q<CR>', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(buf, 'n', '<ESC>', ':q<CR>', { noremap = true, silent = true })
    --vim.api.nvim_buf_set_keymap(buf, 'n', '<CR>', ':lua require("sl1m-menu").switch_to_buffer()<CR>',{})

    -- Optional: Ensure buffer is deleted when window is closed
    vim.api.nvim_create_autocmd("WinClosed", {
        pattern = tostring(win),
        callback = function()
            vim.api.nvim_buf_delete(buf, { force = true })
        end,
        once = true,
    })
end





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
	{ text = "3. popup", action = M.show_popup, desc = "show popup" },
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
    if config.keymaps.popup then
	vim.keymap.set("n", config.keymaps.popup.lhs, M.show_popup, { desc = config.keymaps.popup.desc })
    end
end
-----------------------------------------------------------
return M
-----------------------------------------------------------
