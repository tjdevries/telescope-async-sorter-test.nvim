local Job = require('plenary.job')
local Sorter = require('telescope.sorters').Sorter

local function interp(s, tab)
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
  print("... building")
  local builder = Job:new { "go", "build", "-o", bin }
  builder:sync()

  if builder.code ~= 0 then
    error("Failed...\n\n" .. table.concat(builder:stderr_result(), "\n"))
  end

  print("... getting manifest")
  local registered = table.concat(Job:new { bin, "-manifest", host }:sync(), "\n")
  local plugin = interp(preamble, { host = host }) .. registered

  print("... updating plugin")
  vim.fn.writefile(vim.split(plugin, "\n"), "plugin/async_sorter_test.vim")

  print("... Done!")
end


local id = 0
local state = {}


local resolve = function(request_id, score)
  if not state[request_id] then
    print("No resolution possible...")
  end

  local cb = state[request_id].cb
  local entry = state[request_id].entry
  state[request_id] = nil

  if score == -1 then return end
  cb(score, entry)
end

local new_scorer = function()
  local channel = vim.fn["remote#host#Require"](host)

  return Sorter:new {
    discard = true,

    score = function(_, prompt, entry, cb)
      id = id + 1

      state[id] = { cb = cb, entry = entry }
      vim.rpcnotify(channel, "0:function:AsyncTelescopeSort", id, prompt, entry.ordinal)
    end,
  }
end

local test = function()
  local channel = vim.fn["remote#host#Require"](host)

  print("...requesting")
  -- print("request:", vim.rpcrequest(channel, "0:function:Hello", "yo"))
end

return {
  generate = generate,
  new_scorer = new_scorer,
  resolve = resolve,
  test = test,
}
