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

" if exists('*strchars') && exists('*strcharpart')
"   fu! s:pathshorten(str)
"     retu strcharpart(a:str, 0, 9).'...'.strcharpart(a:str, strchars(a:str) - s:winw + 16)
"   endf
" el
"   fu! s:pathshorten(str)
"     retu matchstr(a:str, '^.\{9}').'...'
"       \ .matchstr(a:str, '.\{'.( s:winw - 16 ).'}$')
"   endf
" en

" compare elms
function! s:cmp(a, b) abort
  let [a, b] = [a:a, a:b]
  return b[1] - a[1]
endfunction

" make elm from buffer b
function! s:elm(b) abort
  let b = a:b
  let path = fnamemodify(b, get(g:, 'ctrlp_tilde_homedir', 0) ? ':p:~' : ':p')
  let fname = fnamemodify(path, ':t')
  let fdir = fnamemodify(path, ':h')
  let bufnr = bufnr('^' . fnameescape(path) . '$')
  if (!filereadable(path) && bufnr < 1)
    if (path =~ '[\/]\?\[\d\+\*No Name\]$')
      let bufnr = str2nr(matchstr(path, '[\/]\?\[\zs\d\+\ze\*No Name\]$'))
      let fname = '[No Name]'
    else
      let bufnr = bufnr(path)
    echoerr 'bad bufnr: ' . bufnr . ': b = ' . b
    endif
  endif
  " XXX: bug case that bufnr becomes -1 when <F5> (PrtClearCache()) pressed
  if bufnr < 0
    echoerr 'bad bufnr: ' . bufnr . ': b = ' . b . ' ; path = ' . path
  endif
  "
  let n = bufnr == s:bufnr ? -1 : bufnr == bufnr('#') ? 1 : 0
  return [bufnr, n, fname, fdir]
endfunction

" format elm
function! s:format(elm) abort
  let bufnr = a:elm[0]
  let idc = a:elm[1] == -1 ? '%' : a:elm[1] == 1 ? '#' : ' '
  let fname = a:elm[2]
  let fdir = a:elm[3]
  return printf("%3s %1s %s\t%s/", bufnr, idc, fname, fdir)
endfunction

" Public

" set s:bufnr
function! ctrlp#ido#enter() abort
  let s:bufnr = bufnr('%')
  let s:winw = winwidth(0)
  let s:cwd = getcwd(0, 0)
endfunction

function! ctrlp#ido#accept(mode, str) abort
  call ctrlp#exit()
  let [mode, str] = [a:mode, a:str]
  if str =~ '^ *\d\+ '
    let str = str2nr(matchstr(str, '^ *\zs\d\+\ze '))
  endif
  " XXX: bug case that bufnr becomes -1 when <F5> (PrtClearCache()) pressed
  if str =~ '^ *-1\s'
    echoerr 'bad bufnr selected; exit'
    return
  endif
  "
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
  " XXX: ad hoc fix for
  " XXX: bug case that bufnr becomes -1 when <F5> (PrtClearCache()) pressed
  execute 'cd' s:cwd
  let buf = ctrlp#buffers()
  let mru = ctrlp#mrufiles#list()
  let tmp = map(copy(buf), {_, b -> s:elm(b)})
  call sort(tmp, 's:cmp')
  call map(tmp, {_, elm -> s:format(elm)})
  " subtract buf from mru
  let bufpaths = copy(buf)
  call map(bufpaths, '0 <= match(v:val, "^\\[\\d\\+\\*No Name\\]$") ? v:val : fnamemodify(v:val, get(g:, "ctrlp_tilde_homedir", 0) ? ":p:~" : ":p")')
  let mru = filter(copy(mru), 'index(bufpaths, v:val) < 0')
  " concat
  let g:ctrlp_lines = tmp + mru
  " syntax highlight
  call ctrlp#ido#syntax()
  " XXX: bug when path too long
  " return map(g:ctrlp_lines, 's:pathshorten(v:val)')
  " return map(copy(g:ctrlp_lines), 'v:val[:winwidth(0) - 8]')
  return g:ctrlp_lines
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
