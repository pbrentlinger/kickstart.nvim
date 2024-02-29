if vim.g.vscode then
    -- VSCode extension will be used instead
else
    -- local codeium_workspace_root_hints = {'.bzr','.git','.hg','.svn','_FOSSIL_','package.json'}

    return {
        'Exafunction/codeium.vim',
        config = function ()
            -- vim.g.codeium_workspace_root_hints = codeium_workspace_root_hints
            vim.g.codeium_no_map_tab = 1
            -- Change '<C-g>' here to any keycode you like.
            vim.keymap.set('i', '<C-l>', function () return vim.fn['codeium#Accept']() end, { expr = true })
            vim.keymap.set('i', '<c-;>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true })
            vim.keymap.set('i', '<c-,>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true })
            vim.keymap.set('i', "<c-'>", function() return vim.fn['codeium#Clear']() end, { expr = true })
            vim.keymap.set('i', '<c-x>', function() return vim.fn['codeium#Close']() end, { expr = true })
            -- vim.keymap.set('i', '<c-g>', function() return vim.fn['codeium#Open']() end, { expr = true })
            -- vim.api.nvim_set_keymap('n', '<leader>cc', '<cmd>' .. vim.fn['codeium#Chat']() .. '<CR>', { noremap = true, silent = true })
        end
    }
end
