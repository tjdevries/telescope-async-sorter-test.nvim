R('telescope')
R('async_sorter_test')

local sorter = require('async_sorter_test').new_scorer()

require('telescope.builtin').find_files {
  sorter = sorter,
}
