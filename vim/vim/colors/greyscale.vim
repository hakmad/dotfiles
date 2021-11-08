" ~/.vim/colors/greyscale.vim
" Colourscheme for vim.

" Dark background.
set background=dark

" Clear highlighting.
highlight clear

" Reset syntax.
if exists("syntax_on")
	syntax reset
endif

" Colorscheme name.
let colors_name="greyscale"

" Actual colours.
highlight Normal ctermfg=7
highlight Comment ctermfg=8
highlight Constant ctermfg=9
highlight Identifier ctermfg=1
highlight Statement ctermfg=1
highlight PreProc ctermfg=3
highlight Type ctermfg=3
highlight Special ctermfg=6
highlight Title ctermfg=9
