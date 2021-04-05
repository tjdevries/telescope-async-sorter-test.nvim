local Job = require('plenary.job')

function interp(s, tab)
  return (s:gsub('($%b{})', function(w) return tab[w:sub(3, -2)] or w end))
end

local host = 'TelescopeAsyncSorterTest'
local bin = "bin/" .. host
local preamble = [[
if exists('g:loaded_${host}')
    finish
endif
let g:loaded_${host} = 1

function! s:Require${host}(host) abort
  let binary_file = nvim_get_runtime_file('bin/${host}', v:false)[0]
  return jobstart([binary_file], {'rpc': v:true})
endfunction

call remote#host#Register('${host}', 'x', function('s:Require${host}'))
]]

local generate = function()
  Job:new { "go", "build", "-o", bin }:sync()

  local registered = table.concat(Job:new { bin, "-manifest", host }:sync(), "\n")
  local plugin = interp(preamble, { host = host }) .. registered

  vim.fn.writefile(vim.split(plugin, "\n"), "plugin/async_sorter_test.vim")
end

return {
  generate = generate,
}
