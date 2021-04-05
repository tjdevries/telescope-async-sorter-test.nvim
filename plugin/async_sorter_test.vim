if exists('g:loaded_TelescopeAsyncSorterTest')
    finish
endif
let g:loaded_TelescopeAsyncSorterTest = 1

function! s:RequireTelescopeAsyncSorterTest(host) abort
  let binary_file = nvim_get_runtime_file('bin/TelescopeAsyncSorterTest', v:false)[0]
  return jobstart([binary_file], {'rpc': v:true})
endfunction

call remote#host#Register('TelescopeAsyncSorterTest', 'x', function('s:RequireTelescopeAsyncSorterTest'))
call remote#host#RegisterPlugin('TelescopeAsyncSorterTest', '0', [
\ {'type': 'function', 'name': 'AsyncHello', 'sync': 0, 'opts': {}},
\ {'type': 'function', 'name': 'AsyncTelescopeSort', 'sync': 0, 'opts': {}},
\ {'type': 'function', 'name': 'Hello', 'sync': 1, 'opts': {}},
\ {'type': 'function', 'name': 'TestThing', 'sync': 0, 'opts': {}},
\ ])
