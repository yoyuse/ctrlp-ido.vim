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
      \ 'enter': 'ctrlp#ido#enter()',
      \ })

" Utilities

" compare elms
function! s:cmp(a, b) abort
  let [a, b] = [a:a, a:b]
  return b[1] - a[1]
endfunction

" make elm from buffer b
function! s:elm(b) abort
  let b = a:b
  let path = fnamemodify(b, s:tilde ? ':p:~' : ':p')
  let fname = fnamemodify(path, ':t')
  let fdir = fnamemodify(path, ':h')
  let bufnr = bufnr('^' . fnameescape(path) . '$')
  if (!filereadable(path) && bufnr < 1)
    if (path =~ '[\/]\?\[\d\+\*No Name\]$')
      let bufnr = str2nr(matchstr(path, '[\/]\?\[\zs\d\+\ze\*No Name\]$'))
      let fname = '[No Name]'
    else
      let bufnr = bufnr(path)
    endif
  endif
  let n = bufnr == s:bufnr ? -1 : bufnr == bufnr('#') ? 1 : 0
  return [bufnr, n, fname, fdir]
endfunction

" shorten path
function! s:shorten(path, width) abort
  let [path, width] = [a:path, a:width]
  let pat = '\v^(([^/.]?(/\.?[^/.])*/)*)(\.?[^/.])[^/]+(/.*)'
  while path =~ pat && width <= strdisplaywidth(path)
    let m = matchlist(path, pat)
    let path = m[1] . m[4] . m[5]
  endwhile
  return path
endfunction

" format elm
function! s:format(elm) abort
  let bufnr = a:elm[0]
  let idc = a:elm[1] == -1 ? '%' : a:elm[1] == 1 ? '#' : ' '
  let fname = a:elm[2]
  let fdir = a:elm[3]
  let line = printf("%3s %1s %s\t", bufnr, idc, fname)
  let fdir = s:shorten(fdir, s:winw - strdisplaywidth(line) - 4 - 1)
  return line . fdir . '/'
endfunction

" Public

" set s:bufnr
function! ctrlp#ido#enter() abort
  let s:bufnr = bufnr('%')
  let s:winw = winwidth(0)
  let s:cwd = getcwd(0, 0)
  let s:tilde = get(g:, 'ctrlp_tilde_homedir', 0)
endfunction

function! ctrlp#ido#accept(mode, str) abort
  " call ctrlp#exit()
  let [mode, str] = [a:mode, a:str]
  if str =~ '^ *\d\+ '
    let str = str2nr(matchstr(str, '^ *\zs\d\+\ze '))
  endif
  call ctrlp#acceptfile(mode, str)
endfunction

" syntax highlight
function! ctrlp#ido#syntax() abort
  if ctrlp#nosy() | return | endif
  call ctrlp#syntax() " XXX
  call ctrlp#hicheck('CtrlPIdoDirname', 'Comment')
  syntax match CtrlPIdoDirname '\t\zs[~.]\?/\(.*/\)\?\ze'
  syntax match CtrlPBufferNr '\s\zs\d\+\ze\s.*'
endfunction

function! ctrlp#ido#init(clim) abort
  " XXX: fix for bug that bufnr becomes -1 when <F5> (PrtClearCache())
  execute 'cd' s:cwd
  let buf = ctrlp#buffers()
  let mru = ctrlp#mrufiles#list()
  let sorted = sort(map(copy(buf), {_, b -> s:elm(b)}), 's:cmp')
  " subtract buf from mru
  let bufpaths = map(copy(buf), {_, b -> 0 <= match(b, '^\[\d\+\*No Name\]$') ? b : fnamemodify(b, s:tilde ? ':p:~' : ':p')})
  let mru = filter(copy(mru), {_, f -> index(bufpaths, f) < 0})
  let buflines = map(copy(sorted), {_, elm -> printf(' %d %s/%s', elm[0], elm[3], elm[2])})
  " concat
  " let g:ctrlp_lines = sorted + mru
  let g:ctrlp_lines = buflines + mru
  let shorten = map(copy(sorted), {_, elm -> s:format(elm)})
  " syntax highlight
  call ctrlp#ido#syntax()
  return shorten + mru
  " return g:ctrlp_lines
endfunction

function! ctrlp#ido#name(s) abort
  let s = a:s
  if s =~ '\t'
    let s = matchstr(s, '.*\s\zs\S.*\ze\t')
  else
    let s = matchstr(s, '\zs\S.*\ze')
  endif
  return s
endfunction

if exists('g:webdevicons_enable') && g:webdevicons_enable_ctrlp && exists('g:webdevicons_enable_ctrlp') && g:webdevicons_enable_ctrlp
  let g:ctrlp_formatline_func = 's:formatline(s:curtype() == "buf" ? v:val : WebDevIconsGetFileTypeSymbol(ctrlp#ido#name(v:val)) . " " . v:val) '
endif

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

function! ctrlp#ido#id()
  return s:id
endfunction
