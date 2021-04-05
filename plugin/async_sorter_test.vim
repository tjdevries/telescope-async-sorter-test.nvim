if exists('g:loaded_hello')
    finish
endif
let g:loaded_hello = 1

function! s:Requirehello(host) abort
  let binary_file = nvim_get_runtime_file('bin/hello', v:false)[0]
  return jobstart([binary_file], {'rpc': v:true})
endfunction

call remote#host#Register('hello', 'x', function('s:Requirehello'))
call remote#host#RegisterPlugin('hello', '0', [
\ {'type': 'function', 'name': 'Hello', 'sync': 1, 'opts': {}},
\ ])
