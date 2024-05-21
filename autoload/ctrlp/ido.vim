" autoload/ctrlp/ido.vim

if exists('g:loaded_ctrlp_ido') && g:loaded_ctrlp_ido
  finish
endif
let g:loaded_ctrlp_ido = 1

let g:ctrlp_ido_rev = get(g:, 'ctrlp_ido_rev', 2)

let g:ctrlp_ext_vars = add(get(g:, 'ctrlp_ext_vars', []), {
      \ 'init': 'ctrlp#ido#init(s:compare_lim)',
      \ 'accept': 'ctrlp#ido#accept',
      \ 'lname': 'ido',
      \ 'sname': 'ido',
      \ 'type': 'path',
      \ 'opmul': 1,
      \ 'spacinput': 0,
      \ 'sort': 0,
      \ })

function! ctrlp#ido#name(s) abort
  let s = a:s
  if s =~ '\s\s'
    let s = matchstr(s, '.*\s\zs\S.*\ze\s\s')
  else
    let s = matchstr(s, '\zs\S.*\ze')
  endif
  return s
endfunction

if exists('*WebDevIconsGetFileTypeSymbol')
  let g:ctrlp_formatline_func = 's:formatline(s:curtype() == "buf" ? v:val : WebDevIconsGetFileTypeSymbol(ctrlp#ido#name(v:val)) . " " . v:val) '
endif

" Utilities

function! s:flbuf(str) abort
  let path = a:str
  let bufnr = bufnr('^' . fnameescape(path) . '$')
  let fname = fnamemodify(path, ':t')
  let fext = fnamemodify(path, ':e')
  let fdir = fnamemodify(path, ':h')
  if (!filereadable(path) && bufnr < 1)
    if (path =~ '[\/]\?\[\d\+\*No Name\]$')
      let bufnr = str2nr(matchstr(path, '[\/]\?\[\zs\d\+\ze\*No Name\]$'))
      let fname = '[No Name]'
    else
      let bufnr = bufnr(path)
    endif
  endif
  let idc = bufnr == bufnr('#') ? '#' : ''
  let str = printf('%3s %1s %s  %s/', bufnr, idc, fname, fdir)
  return str
endfunction

" function! s:flmru(str) abort
"   let path = a:str
"   return path
" endfunction

"if exists('*strchars') && exists('*strcharpart')
"  fu! s:pathshorten(str)
"    let s:winw = winwidth(0)
"    "
"    retu strcharpart(a:str, 0, 9).'...'.strcharpart(a:str, strchars(a:str) - s:winw + 16)
"  endf
"el
"  fu! s:pathshorten(str)
"    let s:winw = winwidth(0)
"    "
"    retu matchstr(a:str, '^.\{9}').'...'
"      \ .matchstr(a:str, '.\{'.( s:winw - 16 ).'}$')
"  endf
"en

" Public

function! ctrlp#ido#accept(mode, str) abort
  call ctrlp#exit()
  let [mode, str] = [a:mode, a:str]
  " " if 0 <= match(str, '\s\s')
  " if str =~ '\S.*\s\s'
  "   let str = matchstr(str, '\zs\S.*\ze\s\s')
  " endif
  if g:ctrlp_ido_rev == 2
    if str =~ '^ *\d\+ '
      let str = str2nr(matchstr(str, '^ *\zs\d\+\ze '))
    endif
  endif
  call ctrlp#acceptfile(mode, str)
endfunction

function! ctrlp#ido#syntax() abort
  if ctrlp#nosy() | return | endif
  call ctrlp#syntax() " XXX
  call ctrlp#hicheck('CtrlPIdoDirname', 'Comment')
  syntax match CtrlPIdoDirname '\s*\zs[~.]\?/\(.*/\)\?\ze'
  syntax match CtrlPBufferNr '\s\zs\d\+\ze\s.*'
endfunction

function! ctrlp#ido#init(clim)
  let buf = ctrlp#buffers()
  let mru = ctrlp#mrufiles#list('raw')
  " to absolute path
  call map(buf, '0 <= match(v:val, "^\\[\\d\\+\\*No Name\\]$") ? v:val : fnamemodify(v:val, get(g:, "ctrlp_tilde_homedir", 0) ? ":p:~" : ":p")')
  " current buffer to last
  if 0 < len(buf)
    let buf = buf[1:] + [buf[0]]
  endif
  " remove buf from mru
  call filter(mru, 'index(buf, v:val) < 0')
  if g:ctrlp_ido_rev == 2
    call map(buf, 's:flbuf(v:val)')
    let g:ctrlp_lines = buf + mru
  else
    let g:ctrlp_lines = buf + ['.'] + mru
  endif
  " syntax highlight
  call ctrlp#ido#syntax()
  " XXX: bug when path too long
  " return map(g:ctrlp_lines, 's:pathshorten(v:val)')
  " return map(copy(g:ctrlp_lines), 'v:val[:winwidth(0) - 8]')
  return g:ctrlp_lines
endfunction

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

function! ctrlp#ido#id()
  return s:id
endfunction
