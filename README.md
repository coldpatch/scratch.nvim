# scratch.nvim

A simple and flexible daily, weekly, and monthly scratchpad for Neovim that can be workspace-specific or global.

## Installation

### Using neovim's built-in package manager

```lua
vim.pack.add({
  "https://github.com/coldpatch/scratch.nvim",
})

require("scratch").setup()
```

### **Using [lazy.nvim](https://github.com/folke/lazy.nvim)**

{  
    "coldpatch/scratch.nvim",  
    config = function()  
        require("scratch").setup()  
    end,  
}

### **Using [packer.nvim](https://github.com/wbthomason/packer.nvim)**

use {  
    "coldpatch/scratch.nvim",  
    config = function()  
        require("scratch").setup()  
    end  
}

## **Requirements**

* Neovim >= 0.7.0

## **Configuration**

You can configure the plugin by passing a table to the setup function. Here are the default settings:  
require("scratch").setup({  
    -- The command to use for opening the scratchpad window.  
    -- e.g., 'edit', 'split', 'vsplit', 'tabnew'  
    open_command = "edit",

    -- The file extension for your notes.  
    file_extension = "md",

    storage = {  
        -- If true, notes are stored in a subdirectory of the current workspace.  
        -- If false, all notes are stored in a single global directory.  
        use_workspace = true,

        -- The name of the subdirectory for workspace-specific notes.  
        -- This is created in your current working directory.  
        workspace_subdir = ".scratchpad",

        -- The global path for notes when 'use_workspace' is false.  
        global_path = vim.fn.stdpath("data") .. "/scratchpad",  
    }  
})

## **Usage**

### **Commands**

* :Scratch - Opens the scratchpad for the current day.  
* :ScratchWeekly - Opens the scratchpad for the current week.  
* :ScratchMonthly - Opens the scratchpad for the current month.

### **Key Mappings**

You can create your own key mappings for convenience:  
-- Open daily scratchpad  
vim.keymap.set("n", "<leader>sd", "<cmd>Scratch<cr>", { desc = "Open daily scratchpad" })

-- Open weekly scratchpad  
vim.keymap.set("n", "<leader>sw", "<cmd>ScratchWeekly<cr>", { desc = "Open weekly scratchpad" })

-- Open monthly scratchpad  
vim.keymap.set("n", "<leader>sm", "<cmd>ScratchMonthly<cr>", { desc = "Open monthly scratchpad" })  

