" plugin/ctrlp-ido.vim

if exists('g:loaded_ido')
  finish
endif
let g:loaded_ido = 1

command! CtrlPIdo call ctrlp#init(ctrlp#ido#id())
