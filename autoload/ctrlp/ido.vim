" autoload/ctrlp/ido.vim

if exists('g:loaded_ctrlp_ido') && g:loaded_ctrlp_ido
  finish
endif
let g:loaded_ctrlp_ido = 1

call add(g:ctrlp_ext_vars, {
      \ 'init': 'ctrlp#ido#init(s:compare_lim)',
      \ 'accept': 'ctrlp#acceptfile',
      \ 'lname': 'ido',
      \ 'sname': 'ido',
      \ 'type': 'path',
      \ 'opmul': 1,
      \ 'spaceinput': 1,
      \ 'sort': 0,
      \ })

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

" Utilities

" Public

function! ctrlp#ido#init(clim)
  let buf = ctrlp#buffers()
  let mru = ctrlp#mrufiles#list('raw')
  " call map(buf, 'fnamemodify(v:val, get(g:, "ctrlp_tilde_homedir", 0) ? ":p:~" : ":p")')
  call map(buf, '0 <= match(v:val, "^\\[\\d\\+\\*No Name\\]$") ? v:val : fnamemodify(v:val, get(g:, "ctrlp_tilde_homedir", 0) ? ":p:~" : ":p")')
  " let buf = buf[1:]
  let buf = buf[1:] + [buf[0]]
  call filter(mru, 'index(buf, v:val) < 0')
  " let g:ctrlp_lines = buf + mru
  let g:ctrlp_lines = buf + ['.'] + mru
  return g:ctrlp_lines
endfunction

function! ctrlp#ido#id()
  return s:id
endfunction
