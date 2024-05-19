" autoload/ctrlp/ido.vim

if exists('g:loaded_ctrlp_ido') && g:loaded_ctrlp_ido
  finish
endif
let g:loaded_ctrlp_ido = 1

let s:ido_var = {
      \ 'init': 'ctrlp#ido#init(s:compare_lim)',
      \ 'accept': 'ctrlp#acceptfile',
      \ 'lname': 'ido',
      \ 'sname': 'ido',
      \ 'type': 'path',
      \ 'opmul': 1,
      \ 'spaceinput': 1,
      \ 'sort': 0,
      \ }

if exists('g:ctrlp_ext_vars') && !empty(g:ctrlp_ext_vars)
  let g:ctrlp_ext_vars = add(g:ctrlp_ext_vars, s:ido_var)
else
  let g:ctrlp_ext_vars = [s:ido_var]
endif

" Utilities

" Public

function! ctrlp#ido#init(clim)
  let buf = ctrlp#buffers()
  let mru = ctrlp#mrufiles#list('raw')
  " to absolute path
  call map(buf, '0 <= match(v:val, "^\\[\\d\\+\\*No Name\\]$") ? v:val : fnamemodify(v:val, get(g:, "ctrlp_tilde_homedir", 0) ? ":p:~" : ":p")')
  " current buffer to last
  let buf = buf[1:] + [buf[0]]
  " remove buf from mru
  call filter(mru, 'index(buf, v:val) < 0')
  " concat buf and mru, separating by '.'
  let g:ctrlp_lines = buf + ['.'] + mru
  return g:ctrlp_lines
endfunction

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

function! ctrlp#ido#id()
  return s:id
endfunction
