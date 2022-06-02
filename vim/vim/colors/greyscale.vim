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

" Basic colours.
highlight Normal ctermfg=7
highlight Comment ctermfg=244
highlight Constant ctermfg=244
highlight Special ctermfg=244
highlight Identifier ctermfg=248
highlight Statement ctermfg=254
highlight PreProc ctermfg=238
highlight Type ctermfg=242

" Miscellaneous colours.
highlight Underlined ctermfg=7
highlight Ignore ctermfg=7
highlight Error ctermbg=1
highlight Todo ctermfg=15 ctermbg=2
highlight MatchParen ctermfg=7 ctermbg=8
highlight Title ctermfg=7

" Fold colours.
highlight Folded ctermfg=7 ctermbg=8

" Meta colours.
highlight NonText ctermfg=240
highlight LineNr ctermfg=240
