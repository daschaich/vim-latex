"=============================================================================
" 	     File: envmacros.vim
"      Author: Mikolaj Machowski
"     Created: Tue Apr 23 08:00 PM 2002 PST
"  Description: mappings/menus for environments. 
"=============================================================================

if !g:Tex_EnvironmentMaps && !g:Tex_EnvironmentMenus
	finish
endif

" line continuation used here.
let s:save_cpo = &cpo
set cpo&vim

exe 'so '.fnameescape(expand('<sfile>:p:h').'/wizardfuncs.vim')

nmap <silent> <script> <plug> i
imap <silent> <script> <C-o><plug> <Nop>

if Tex_GetVarValue('Tex_EnvEndWithCR')
	let s:end_with_cr = "\<CR>"
else
	let s:end_with_cr = ""
end

if Tex_GetVarValue('Tex_ItemsWithCR')
	let s:items_with_cr = "\<CR>"
else
	let s:items_with_cr = " "
end

" The prefix of labels of figures
let s:labelprefix_figure = Tex_GetVarValue("Tex_EnvLabelprefix_{'figure'}")
let s:labelprefix_table = Tex_GetVarValue("Tex_EnvLabelprefix_{'table'}")

" Define environments for IMAP evaluation " {{{
let s:figure =     "\\begin{figure}[<+htpb+>]\<cr>\\centering\<cr>\\includegraphics{<+file+>}\<cr>\\caption{<+caption text+>}\<cr>\\label{" . s:labelprefix_figure . "<+label+>}\<cr>\\end{figure}" . s:end_with_cr . "<++>"
let s:minipage =   "\\begin{minipage}[<+tb+>]{<+width+>}\<cr><++>\<cr>\\end{minipage}" . s:end_with_cr . "<++>"
let s:picture =    "\\begin{picture}(<+width+>, <+height+>)(<+xoff+>,<+yoff+>)\<cr>\\put(<+xoff+>,<+yoff+>){\\framebox(<++>,<++>){<++>}}\<cr>\\end{picture}" . s:end_with_cr . "<++>"
let s:list =       "\\begin{list}{<+label+>}{<+spacing+>}\<cr>\\item".s:items_with_cr."<++>\<cr>\\end{list}" . s:end_with_cr . "<++>"
let s:table =      "\\begin{table}\<cr>\\centering\<cr>\\begin{tabular}{<+dimensions+>}\<cr><++>\<cr>\\end{tabular}\<cr>\\caption{<+Caption text+>}\<cr>\\label{" . s:labelprefix_table . "<+label+>}\<cr>\\end{table}" . s:end_with_cr . "<++>"
let s:array =      "\\left<++>\<cr>\\begin{array}{<+dimension+>}\<cr><+elements+>\<cr>\\end{array}\<cr>\\right<++>"
let s:description ="\\begin{description}\<cr>\\item[<+label+>]".s:items_with_cr."<++>\<cr>\\end{description}" . s:end_with_cr . "<++>"
let s:document =   "\\documentclass[<+options+>]{<+class+>}\<cr>\<cr>\\begin{document}\<cr><++>\<cr>\\end{document}"
let s:tabular = "\\begin{tabular}[<+hbtp+>]{<+format+>}\<cr><++>\<cr>\\end{tabular}"
let s:tabular_star = "\\begin{tabular*}[<+hbtp+>]{<+format+>}\<cr><++>\<cr>\\end{tabular*}"

" }}}
" define environments with special behavior in line wise selection. {{{
if !exists('s:vis_center_left')
	let s:vis_center_left = '{\centering '
	let s:vis_center_right = '}'

	let s:vis_verbatim_left = '\verb\|'
	let s:vis_verbatim_right = '\|'

	let s:vis_flushright_left =  '{\raggedright '
	let s:vis_flushright_right = '}'

	let s:vis_fushleft_left = '{\raggedleft '
	let s:vis_fushleft_right = '}'

	let s:vis_lrbox_left = '\sbox{'
	let s:vis_lrbox_right = '}'
endif
" }}}
" Tex_EnvMacros: sets up maps and menus for environments {{{
" Description: 
function! <SID>Tex_EnvMacros(lhs, submenu, name)

	let vright = ''
	let vleft = ''
	if exists('s:vis_'.a:name.'_right')
		let vright = s:vis_{a:name}_right
		let vleft = s:vis_{a:name}_left
	endif
	let vrhs = "\<C-\\>\<C-N>:call VEnclose('".vleft."', '".vright."', '\\begin{".a:name."}', '\\end{".a:name."}')\<CR>"
	let location = g:Tex_EnvMenuLocation.a:submenu.a:name.'<tab>'

	if a:lhs != '' 

		let vlhs = g:Tex_Leader2.substitute(tolower(a:lhs), '^.', '', '')
		let location = location.a:lhs.'\ ('.vlhs.')'

		if g:Tex_EnvironmentMaps && !exists('s:doneOnce')
			call IMAP(a:lhs, "\<C-r>=Tex_PutEnvironment('".a:name."')\<CR>", 'tex')
			exec 'xnoremap <silent> '.vlhs.' '.vrhs
		endif

	endif

	if g:Tex_Menus && g:Tex_EnvironmentMenus && has("gui_running")
		exe 'amenu '.location.' <plug><C-r>=Tex_DoEnvironment("'.a:name.'")<CR>'
		exe 'vmenu '.location.' '.vrhs
	endif

endfunction 

" }}}
" Tex_SpecialMacros: macros with special right hand sides {{{
" Description: 
function! <SID>Tex_SpecialMacros(lhs, submenu, name, irhs, ...)

	let wiz = 1
	if a:0 > 0 && a:1 == 0
		let wiz = 0
	endif

	let location = g:Tex_EnvMenuLocation.a:submenu.a:name

	let vright = ''
	let vleft = ''
	if exists('s:vis_'.a:name.'_right')
		let vright = s:vis_{a:name}_right
		let vleft = s:vis_{a:name}_left
	endif
	let vrhs = "\<C-\\>\<C-N>:call VEnclose('".vleft."', '".vright."', '\\begin{".a:name."}', '\\end{".a:name."}')\<CR>"

	if a:lhs != ''

		let vlhs = g:Tex_Leader2.substitute(tolower(a:lhs), '^.', '', '')
		let location = location.'<tab>'.a:lhs.'\ ('.vlhs.')'

		if g:Tex_EnvironmentMaps && !exists('s:doneOnce')
			call IMAP(a:lhs, a:irhs, 'tex')
			exec 'xnoremap '.vlhs.' '.vrhs
		endif

	endif

	if g:Tex_Menus && g:Tex_EnvironmentMenus
		if wiz
			exe 'amenu '.location.' <plug><C-r>=Tex_DoEnvironment("'.a:name.'")<CR>'
		else
			exe 'amenu '.location." <plug><C-r>=IMAP_PutTextWithMovement('".a:irhs."')<CR>"
		endif
		exe 'vmenu '.location.' '.vrhs
	endif

endfunction " }}}
" Tex_SectionMacros: creates section maps and menus {{{
" Description: 
function! <SID>Tex_SectionMacros(lhs, name)

	let vlhs = g:Tex_Leader2.substitute(tolower(a:lhs), '^.', '', '')
	let vrhs = "\<C-\\>\<C-N>:call VEnclose('\\".a:name."{', '}', '', '')<CR>"

	if g:Tex_SectionMaps && !exists('s:doneOnce')
		exe 'xnoremap '.vlhs.' '.vrhs
		call IMAP (a:lhs, "\\".a:name.'{<++>}' . s:end_with_cr . '<++>', 'tex')
	endif

	if g:Tex_Menus && g:Tex_SectionMenus
		let location = g:Tex_EnvMenuLocation.'Sections.'.a:name.'<tab>'.a:lhs.'\ ('.vlhs.')'
		let advlocation = g:Tex_EnvMenuLocation.'Sections.Advanced.'.a:name

		let irhs = "\<C-r>=IMAP_PutTextWithMovement('\\".a:name."{<++>}" . s:end_with_cr . "<++>')\<CR>"

		let advirhs = "\<C-r>=Tex_InsSecAdv('".a:name."')\<CR>"
		let advvrhs = "\<C-\\>\<C-N>:call Tex_VisSecAdv('".a:name."')\<CR>"

		exe 'amenu '.advlocation.' <plug>'.advirhs
		exe 'vnoremenu '.advlocation." ".advvrhs

		exe 'amenu '.location.' <plug>'.irhs
		exe 'vnoremenu '.location." ".vrhs
	endif
endfunction " }}}

" NewEnvironments {{{
call s:Tex_SpecialMacros('', '', 'newenvironment',     '\newenvironment{<++>}[<++>][<++>]{<++>}{<++>}<++>', 0)
call s:Tex_SpecialMacros('', '', 'newenvironment*',    '\newenvironment*{<++>}[<++>][<++>]{<++>}{<++>}<++>', 0)
call s:Tex_SpecialMacros('', '', 'renewenvironment',   '\renewenvironment{<++>}[<++>][<++>]{<++>}{<++>}<++>', 0)
call s:Tex_SpecialMacros('', '', 'renewenvironment*',  '\renewenvironment*{<++>}[<++>][<++>]{<++>}{<++>}<++>', 0)
call s:Tex_SpecialMacros('', '', '-sepenv0-', ' :', 0)
" }}}
" Environments specific commands {{{
call s:Tex_SpecialMacros('', 'Env&Commands.&Lists.', '&item',     '\item', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Lists.', 'i&tem[]',    '\item[<++>]<++>', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Lists.', '&bibitem{}', '\bibitem{<++>}<++>', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', '\\&=', '\=', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', '\\&>', '\>', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', '&\\\\', '\\', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', '\\&+', '\+', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', '\\&-', '\-', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', "\\\'", "\\\'", 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', '\\&`', '\`', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', '\\&kill', '\kill', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', '&makron\ \\CHAR=', '\<++>=<++>', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', "&aigu\ \\CHAR\'", "\\<++>\'<++>", 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', '&grave\ \\CHAR`', '\<++>`<++>', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', 'p&ushtabs', '\pushtabs', 0)
call s:Tex_SpecialMacros('', 'Env&Commands.&Tabbing.', 'p&optabs', '\poptabs', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.&Tabular.', '&hline', '\hline', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.&Tabular.', '&cline', '\cline', 0) 
call s:Tex_SpecialMacros('', 'EnvCommands.&Tabular.', '&\&', '&', 0) 
call s:Tex_SpecialMacros('', 'EnvCommands.&Tabular.', '&\\\\', '\\', 0) 
call s:Tex_SpecialMacros('', 'EnvCommands.&Tabular.', '&multicolumn{}{}{}', '\multicolumn{<++>}{<++>}{<++>}<++>', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.Le&tter.', '&makelabels', '\makelabels', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.Le&tter.', '&address', '\address', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.Le&tter.', '&signature', '\signature', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.Le&tter.', '&date', '\date', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.Le&tter.', '-sepenva4-', ' :', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.Le&tter.', '&opening{}', '\opening{<++>}<++>', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.Le&tter.', '&closing{}', '\closing{<++>}<++>', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.Le&tter.', '&ps{}', '\ps{<++>}<++>', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.Le&tter.', 'cc&{}', '\cc{<++>}<++>', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.&Slides.', '&onlyslides{}', '\onlyslides{<++>}<++>', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.&Slides.', '&onlynotes{}', '\onlynotes{<++>}<++>', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.&Slides.', '-sepenva5-', ' :', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.&Slides.', '&invisible', '\invisible', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.&Slides.', '&visible', '\visible', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.&Slides.', '&settime', '\settime', 0)
call s:Tex_SpecialMacros('', 'EnvCommands.&Slides.', '&addtime', '\addtime', 0)
call s:Tex_SpecialMacros('', '', '-sepenv0-', ' :', 0)
" }}}
" Lists {{{
call s:Tex_SpecialMacros('ELI', '&Lists.',  'list', s:list)
call s:Tex_SpecialMacros('EDE', '&Lists.',  'description', s:description)
call s:Tex_EnvMacros('EEN', '&Lists.', 'enumerate')
call s:Tex_EnvMacros('EIT', '&Lists.', 'itemize')
call s:Tex_EnvMacros('ETI', '&Lists.', 'theindex')
call s:Tex_EnvMacros('ETL', '&Lists.', 'trivlist')
" }}}
" Tables {{{
call s:Tex_SpecialMacros('ETE', '&Tables.', 'table', s:table)
call s:Tex_EnvMacros('ETG', '&Tables.', 'tabbing')
call s:Tex_EnvMacros('',    '&Tables.', 'table*')
call s:Tex_EnvMacros('',    '&Tables.', 'table2')
call s:Tex_SpecialMacros('ETR', '&Tables.', 'tabular', s:tabular)
call s:Tex_SpecialMacros('', '&Tables.', 'tabular*', s:tabular_star)
" }}}
" Math {{{
call s:Tex_EnvMacros('EAL', '&Math.', 'align')
call s:Tex_EnvMacros('EAS', '&Math.', 'align*')
call s:Tex_EnvMacros('EAD', '&Math.', 'aligned')
call s:Tex_EnvMacros('EAR', '&Math.', 'array')
call s:Tex_EnvMacros('EDM', '&Math.', 'displaymath')
call s:Tex_EnvMacros('EEQ', '&Math.', 'equation')
call s:Tex_EnvMacros('EES', '&Math.', 'equation*')
call s:Tex_EnvMacros('EMA', '&Math.', 'math')
call s:Tex_EnvMacros('ESE', '&Math.', 'subequations')
" }}}
" Structure {{{
call s:Tex_SpecialMacros('EAR', 'Math.', 'array', s:array)
call s:Tex_EnvMacros('EAB', '&Structure.', 'abstract')
call s:Tex_EnvMacros('EAP', '&Structure.', 'appendix')
call s:Tex_EnvMacros('ECE', '&Structure.', 'center')
call s:Tex_EnvMacros('EDO', '&Structure.', 'document')
call s:Tex_EnvMacros('EFC', '&Structure.', 'filecontents')
call s:Tex_EnvMacros('',    '&Structure.', 'filecontents*')
call s:Tex_EnvMacros('EFL', '&Structure.', 'flushleft')
call s:Tex_EnvMacros('EFR', '&Structure.', 'flushright')
call s:Tex_EnvMacros('EQN', '&Structure.', 'quotation')
call s:Tex_EnvMacros('EQE', '&Structure.', 'quote')
call s:Tex_EnvMacros('ESP', '&Structure.', 'sloppypar')
call s:Tex_EnvMacros('ETI', '&Structure.', 'theindex')
call s:Tex_EnvMacros('ETP', '&Structure.', 'titlepage')
call s:Tex_EnvMacros('EVM', '&Structure.', 'verbatim')
call s:Tex_EnvMacros('',    '&Structure.', 'verbatim*')
call s:Tex_EnvMacros('EVE', '&Structure.', 'verse')
call s:Tex_EnvMacros('ETB', '&Structure.', 'thebibliography')
call s:Tex_SpecialMacros('', '&Structure.', '-sepstruct0-', ':', 0)
call s:Tex_EnvMacros('ENO', '&Structure.', 'note')
call s:Tex_EnvMacros('EOV', '&Structure.', 'overlay')
call s:Tex_EnvMacros('ESL', '&Structure.', 'slide')
" }}}
" Sections {{{
call s:Tex_SectionMacros('SPA', 'part')
call s:Tex_SectionMacros('SCH', 'chapter')
call s:Tex_SectionMacros('SSE', 'section')
call s:Tex_SectionMacros('SSS', 'subsection')
call s:Tex_SectionMacros('SS2', 'subsubsection')
call s:Tex_SectionMacros('SPG', 'paragraph')
call s:Tex_SectionMacros('SSP', 'subparagraph')
" }}}
" Miscellaneous {{{
call s:Tex_SpecialMacros('', '', '-sepenv1-', ' :', 0)
call s:Tex_SpecialMacros('EFI', '', 'figure', "\<C-r>=Tex_PutEnvironment('figure')\<CR>")
call s:Tex_EnvMacros('', '', 'figure*')
call s:Tex_EnvMacros('ELR', '', 'lrbox')
call s:Tex_SpecialMacros('EMP', '', 'minipage', s:minipage)
call s:Tex_SpecialMacros('EPI', '', 'picture', s:picture)
" }}}

if g:Tex_CatchVisMapErrors
	exe 'xnoremap '.g:Tex_Leader2."   :\<C-u>call ExecMap('".g:Tex_Leader2."', 'v')\<CR>"
endif

" ==============================================================================
" Specialized functions for various environments
"
" All these functions are to be used as:
"
"   inoremap <lhs> <C-r>=Tex_itemize('enumerate')<CR>
"   nnoremap <lhs> i<C-r>=Tex_itemize('enumerate')<CR>
"
" and so on...
" ============================================================================== 
" Tex_itemize: {{{
function! Tex_itemize(env)
	return IMAP_PutTextWithMovement('\begin{'.a:env."}\<cr>"
				\ . "\\item" . s:items_with_cr . "<++>\<cr>"
				\ . "\\end{".a:env."}" . s:end_with_cr . "<++>")
endfunction
" }}} 
" Tex_description: {{{
function! Tex_description(env)
	if g:Tex_UseMenuWizard == 1
		let itlabel = input('(Optional) Item label? ')
		if itlabel != ''
			let itlabel = '['.itlabel.']'
		endif
		return IMAP_PutTextWithMovement("\\begin{description}\<cr>\\item".itlabel.s:items_with_cr."<++>\<cr>\\end{description}" . s:end_with_cr . "<++>")
	else
		return IMAP_PutTextWithMovement(s:description)
	endif
endfunction
" }}} 
" Tex_figure: {{{
function! Tex_figure(env)
	if g:Tex_UseMenuWizard == 1
		let flto    = input('Float to (htbp)? ')
		let caption = input('Caption? ')
		let center  = input('Center ([y]/n)? ')
		let label   = input('Label (for use with \ref)? ')
		" additional to AUC Tex since my pics are usually external files
		let pic = input('Name of Pic-File? ')
		if flto != ''
			let flto = '['.flto."]\<cr>"
		else
			let flto = "\<cr>"
		endif
		if pic != ''
			let pic = '\input{'.pic."}\<cr>"
		else
			let pic = "<++>\<cr>"
		endif
		if caption != ''
			let caption = '\caption{'.caption."}\<cr>"
		endif
		if label != ''
			let label = '\label{' . s:labelprefix_figure . label . "}\<cr>"
		endif
		if center == 'y' || center == ''
			let centr = '\centering' . "\<cr>"
		else
			let centr = ''
		end
		let figure = '\begin{'.a:env.'}'.flto
		let figure = figure . centr . pic . caption . label
		let figure = figure . '\end{'.a:env.'}' . s:end_with_cr
		return IMAP_PutTextWithMovement(figure)
	else
		return IMAP_PutTextWithMovement(s:figure)
	endif
endfunction
" }}} 
" Tex_table: {{{
function! Tex_table(env)
	if g:Tex_UseMenuWizard == 1
		let flto    = input('Float to (htbp)? ')
		let caption = input('Caption? ')
		let center  = input('Center (y/n)? ')
		let label   = input('Label? ')
		if flto != ''
			let flto ='['.flto."]\<cr>"
		else
			let flto = ''
		endif
		let ret='\begin{table}'.flto
		if center == 'y'
			let ret=ret."\\centering\<cr>"
		endif
		let foo = '\begin{tabular}'
		let pos = input('(Optional) Position (t b)? ')
		if pos != ''
			let foo = foo.'['.pos.']'
		else
			let foo = foo."\<cr>"
		endif
		let format = input("Format  ( l r c p{width} | @{text} )? ")
		if format == ''
			let format = '<++>'
		endif
		let ret = ret.foo.'{'.format."}\<cr><++>\<cr>\\end{tabular}" . s:end_with_cr . "<++>"
		if caption != ''
			let ret=ret.'\caption{'.caption."}\<cr>"
		endif
		if label != ''
			let ret=ret.'\label{' s:labelprefix_table . label."}\<cr>"
		endif
		let ret=ret."\\end{table}" . s:end_with_cr . "<++>"
		return IMAP_PutTextWithMovement(ret)
	else
		return IMAP_PutTextWithMovement(s:table)
	endif
endfunction
" }}} 
" Tex_tabular: {{{
function! Tex_tabular(env)
	if g:Tex_UseMenuWizard == 1
		let pos    = input('(Optional) Position (t b)? ')
		let format = input("Format  ( l r c p{width} | @{text} )? ")
		if pos != ''
		  let pos = '['.pos.']'
		endif
		if format != ''
		  let format = '{'.format.'}'
		endif
		return IMAP_PutTextWithMovement('\begin{'.a:env.'}'.pos.format."\<cr> \<cr>\\end{".a:env.'}' . s:end_with_cr . '<++>')
	else
		return IMAP_PutTextWithMovement('\begin{'.a:env.'}[<+position+>]{<+format+>}'."\<cr><++>\<cr>\\end{".a:env.'}' . s:end_with_cr . '<++>')
	endif
endfunction
" }}} 
" Tex_standard_env: Provides a 'standard environment' including a label {{{
function! Tex_standard_env(env)
	if g:Tex_UseMenuWizard == 1
		if a:env !~ '\*'
			let label = input('Label?  ')
			if label != ''
				let arrlabel = '\label{'.label."}\<cr>"
			  else
				let arrlabel = ''
			endif
		else
			let arrlabel = ''
		endif
	else
		if a:env !~ '\*'
			let labelprefix = Tex_GetVarValue("Tex_EnvLabelprefix_{'".a:env."'}")
			let arrlabel = "\\label{".labelprefix."}\<cr>"
		else
			let arrlabel = ""
		endif
		if Tex_GetVarValue("Tex_LabelAfterContent")
			let content = "\<cr>" . arrlabel
		else
			let content = arrlabel . "\<cr>"
		end
	endif
	return IMAP_PutTextWithMovement('\begin{'.a:env."}\<cr>".content."\\end{".a:env."}" . s:end_with_cr . "<++>")
endfunction
" }}} 
" Tex_list: {{{
function! Tex_list(env)
	if g:Tex_UseMenuWizard == 1
		let label = input('Label (for \item)? ')
		if label != ''
			let label = '{'.label.'}'
			let addcmd = input('Additional commands? ')
			if addcmd != ''
				let label = label . '{'.addcmd.'}'
			endif
		else
			let label = ''
		endif
		return IMAP_PutTextWithMovement('\begin{list}'.label."\<cr>\\item".s:items_with_cr."\<cr>\\end{list}" . s:end_with_cr . "<++>")
	else
		return IMAP_PutTextWithMovement(s:list)
	endif
endfunction
" }}} 
" Tex_document: {{{
function! Tex_document(env)
	if g:Tex_UseMenuWizard == 1
		let dstyle = input('Document style? ')
		let opts = input('(Optional) Options? ')
		let foo = '\documentclass'
		if opts == ''
			let foo = foo.'{'.dstyle.'}'
		else
			let foo = foo.'['.opts.']'.'{'.dstyle.'}'
		endif
		return IMAP_PutTextWithMovement(foo."\<cr>\<cr>\\begin{document}\<cr><++>\<cr>\\end{document}")
	else
		return IMAP_PutTextWithMovement(s:document)
	endif
endfunction
" }}} 
" Tex_minipage: {{{
function! Tex_minipage(env)
	if g:Tex_UseMenuWizard == 1
		let foo = '\begin{minipage}'
		let pos = input('(Optional) Position (t b)? ')
		let width = input('Width? ')
		if pos == ''
			let foo = foo.'{'.width.'}'
		else
			let  foo = foo.'['.pos.']{'.width.'}'
		endif
		return IMAP_PutTextWithMovement(foo."\<cr><++>\<cr>\\end{minipage}" . s:end_with_cr . "<++>")
	else
		return IMAP_PutTextWithMovement(s:minipage)
	endif
endfunction
" }}} 
" Tex_thebibliography: {{{
function! Tex_thebibliography(env)
	if g:Tex_UseMenuWizard == 1
		" AUC Tex: "Label for BibItem: 99"
		let indent = input('Indent for BibItem? ')
		let foo = '{'.indent.'}'
		let biblabel = input('(Optional) Bibitem label? ')
		let key = input('Add key? ')
		let bar = '\bibitem'
		if biblabel != ''
			let bar = bar.'['.biblabel.']'
		endif
		let bar = bar.'{'.key.'}'
		return IMAP_PutTextWithMovement('\begin{thebibliography}'.foo."\<cr>".bar." \<cr>\\end{thebibliography}" . s:end_with_cr . "<++>\<Up>")
	else
		return IMAP_PutTextWithMovement(
			\ "\\begin{thebibliography}\<CR>".
			\ "\\bibitem[<+biblabel+>]{<+bibkey+>}".
			\ s:items_with_cr .
			\ "<++>\<CR>".
			\ "\\end{thebibliography}" . s:end_with_cr . "<++>")
	endif
endfunction
" }}} 

" ==============================================================================
" Contributions / suggestions from Carl Mueller (auctex.vim)
" ============================================================================== 
" PromptForEnvironment: prompts for an environment {{{
" Description: 
function! PromptForEnvironment(ask)
	return Tex_ChooseFromPrompt(
		\ a:ask."\n" . 
		\ Tex_CreatePrompt(g:Tex_PromptedEnvironments, 2, ",") .
		\ "\nEnter name or number of environment :", 
		\ g:Tex_PromptedEnvironments, ",")
endfunction " }}}
" Tex_DoEnvironment: fast insertion of environments {{{
" Description:
"   The menus call this function with an argument (the name of the environment
"   to insert). The maps call this without any arguments. In this case, it
"   prompts for an environment to enter if the current line is empty. If
"   called without arguments and there is a word on the current line, then use
"   that as the name of a new environment.
function! Tex_DoEnvironment(...)
	if a:0 < 1
		let env = matchstr(getline('.'), '^\s*\zs\w*\*\=\ze\s*$')
		" If in current line is more than one word or in visual mode
		" ignore contents of line and prompt for environment
		if env == '' || (exists('s:isvisual') && s:isvisual == 'yes')
			let env = PromptForEnvironment('Choose which environment to insert: ')
			if env != ''
				return Tex_PutEnvironment(env)
			else
				return ''
			endif
		else
			" delete the word on the line into the blackhole register.
			normal! 0"_D
			return Tex_PutEnvironment(env)
		endif
	else
		return Tex_PutEnvironment(a:1)
	endif
endfunction " }}}
" Tex_PutEnvironment: calls various specialized functions {{{
" Description: 
"   Based on input argument, it calls various specialized functions.
function! Tex_PutEnvironment(env)
	if exists("s:isvisual") && s:isvisual == "yes"
		let s:isvisual = 'no'
		if a:env == '\['
			return VEnclose('', '', '\[', '\]')
		endif
		return VEnclose('\begin{'.a:env.'}', '\end{'.a:env.'}', '\begin{'.a:env.'}', '\end{'.a:env.'}')
	else
		" first check if the keyword has been set as an alias
		let env = a:env
		if exists("g:Tex_Env_{'".a:env."'}_aliasto")
			let env = g:Tex_Env_{a:env}_aliasto
		endif
		" The user can define something like
		" let g:Tex_Env_theorem = "\\begin{theorem}\<CR><++>\<CR>\\end{theorem}"
		" This will effectively over-write the default definition of the
		" theorem environment which uses a \label.
		if exists("b:Tex_Env_{'".env."'}")
			return IMAP_PutTextWithMovement(b:Tex_Env_{env})
		elseif exists("g:Tex_Env_{'".env."'}")
			return IMAP_PutTextWithMovement(g:Tex_Env_{env})
		elseif env =~ '^\%(theorem\|definition\|lemma\|proposition\|corollary\|assumption\|remark\|equation\|align\*\|align\>\|multline\|subequations\)$'
			return Tex_standard_env(env)
		elseif env =~ '^\%(enumerate\|itemize\|theindex\|trivlist\)$'
			return Tex_itemize(env)
		elseif env =~ '^\%(table\|table*\)$'
			return Tex_table(env)
		elseif env =~ '^\%(tabular\|tabular*\|array\|array*\)$'
			return Tex_tabular(env)
		elseif env =~# '^\%(description\|figure\|list\|document\|minipage\|thebibliography\)$'
			" Call spezialized functions
			exe 'return Tex_'.env.'(env)'
		elseif env == '\['
			return IMAP_PutTextWithMovement("\\[\<CR><++>\<CR>\\]" . s:end_with_cr . "<++>")
		else
			" Look in supported packages if exists template for environment
			" given in the line
			if exists('g:Tex_package_supported') && g:Tex_package_supported != ''
				let i = 1
				while Tex_Strntok(g:Tex_package_supported, ',', i) != ''
					let checkpack = Tex_Strntok(g:Tex_package_supported, ',', i)
					if g:TeX_package_{checkpack} =~ 'e..:'.env
						if env =~ '*'
							" Don't allow * to be treated as wildcard
							let env = substitute(env, '*', '\\*', '')
						endif
						let envcommand = matchstr(g:TeX_package_{checkpack}, '\zse..:'.env.'[^,]\{-}\ze,')
						return Tex_ProcessPackageCommand(envcommand)
					endif
					let i = i + 1
				endwhile
			endif
		endif
		" If nothing before us managed to create an environment, then just
		" create a bare-bones environment from the name.
		return IMAP_PutTextWithMovement('\begin{'.env."}\<cr><++>\<cr>\\end{".env."}" . s:end_with_cr . "<++>")
	endif
endfunction " }}}
" Mapping the <F5> key to insert/prompt for an environment/package {{{
" and <S-F5> to prompt/replace an environment
"
" g:Tex_PromptedEnvironments is a variable containing a comma seperated list
" of environments. This list defines the prompt which latex-suite sets up when
" the user presses <F5> on an empty line.
"
" Leaving this empty is equivalent to disabling the feature.
if g:Tex_PromptedEnvironments != ''

	" Provide only <plug>s here. main.vim will create the actual maps.
	inoremap <silent> <Plug>Tex_FastEnvironmentInsert  <C-r>=Tex_FastEnvironmentInsert("no")<cr>
	nnoremap <silent> <Plug>Tex_FastEnvironmentInsert  i<C-r>=Tex_FastEnvironmentInsert("no")<cr>
	vnoremap <silent> <Plug>Tex_FastEnvironmentInsert  <C-\><C-N>:call Tex_FastEnvironmentInsert("yes")<CR>
	inoremap <silent> <Plug>Tex_FastEnvironmentChange  <C-O>:call Tex_ChangeEnvironments()<CR>
	nnoremap <silent> <Plug>Tex_FastEnvironmentChange  :call Tex_ChangeEnvironments()<CR>

	" Tex_FastEnvironmentInsert: maps <F5> to prompt for env and insert it " {{{
	" Description:
	"   This function calculates whether we are in the preamble. If we are
	"   then inserts a \usepackage line by either reading in a word from the
	"   current line or prompting to type in one. If not in the preamble, then
	"   inserts a environment template either by reading in a word from the
	"   current line or prompting the user to choose one.
	"
	function! Tex_FastEnvironmentInsert(isvisual)

		let start_line = line('.')
		let pos = Tex_GetPos()
		let s:isvisual = a:isvisual

		" Position the cursor at the start of the file
		call setpos('.', [0,1,1,0])

		" Search for the first \documentclass, which is not inside a comment
		while 1
			let classline = search('\C\\documentclass', 'cW')
			if classline == 0
				break
			endif
			if getline('.') =~# '\%(\\\@<!\%(\\\\\)*%.*\)\@<!\\documentclass'
				" No comment here, we have found it
				break
			endif
			" Move to end of line and search again.
			normal! $
		endwhile

		" Search for the first \begin{document}, which is not inside a comment
		while 1
			let documentline = search('\C\\begin{document}', 'cW')
			if documentline == 0
				break
			endif
			if getline('.') =~# '\%(\\\@<!\%(\\\\\)*%.*\)\@<!\\begin{document}'
				" No comment here, we have found it
				break
			endif
			" Move to end of line and search again.
			normal! $
		endwhile

		if documentline != 0 && start_line >= documentline
			" We are after the '\begin{document}'.
			" Put an environment.
			call Tex_SetPos(pos)
			return Tex_DoEnvironment()
		elseif classline != 0 && start_line >= classline
			" We are after the '\documentclass'.
			" Insert a package.
			call Tex_SetPos(pos)
			return Tex_package_from_line()
		else
			" Otherwise, insert an environment.
			call Tex_SetPos(pos)
			return Tex_DoEnvironment()
		endif
	endfunction 

	" }}}
	" Tex_package_from_line: puts a \usepackage line in the current line. " {{{
	" Description:
	"
	function! Tex_package_from_line()
		" Function Tex_PutPackage is defined in packages.vim
		" Ignores <F5> in Visual mode 
		if s:isvisual == "yes"
			return 0
		else	   
			let l = getline(".")
			let pack = matchstr(l, '^\s*\zs.*')
			normal!  0"_D

			" If the g:Tex_PackagesMenu variable is set to zero,
			" the function Tex_pack_one is not defined. In this case
			" we use a very simple replacement.
			if exists('*Tex_pack_one')
				return Tex_pack_one(pack)
			else
				return IMAP_PutTextWithMovement('\usepackage{'.pack."}\<CR>", '<+', '+>')
			endif
		endif
	endfunction 
	
	" }}}
	" Tex_ChangeEnvironments: calls Change() to change the environment {{{
	" Description:
	"   Finds out which environment the cursor is positioned in and changes
	"   that to the chosen new environment. This function knows the changes
	"   which need to be made to change one env to another and calls
	"   Change() with the info.
	"
	function! Tex_ChangeEnvironments() 


		let env_name = Tex_GetCurrentEnv()
		
		if env_name == ''
			echomsg "You are not inside environment"
			return 0
		endif

		exe 'echomsg "You are within a '.env_name.' environment."'
		let change_env = PromptForEnvironment('What do you want to change it to? ')

		if change_env == 'equation'
			call <SID>Change('equation', 1, '&\|\\\\', env_name =~ '\*$')
		elseif change_env == 'align'
			call <SID>Change('align', 1, '', env_name =~ '\*$')
		elseif change_env == 'align*'
			call <SID>Change('align*', 0, '\\nonumber', 0)
		elseif change_env == 'equation*'
			call <SID>Change('equation*', 0, '&\|\\lefteqn{\|\\nonumber\|\\\\', 0)
		elseif change_env == ''
			return 0
		else
			call <SID>Change(change_env, 0, '', '')
			return 0
		endif

	endfunction 
	
	" }}}
	" Change: changes the current env to the new env {{{
	" Description: 
	"   This function needs to know the changes which need to be made while
	"   going from an old environment to a new one. This info, it gets from
	"   Tex_ChangeEnvironments
	" 
	"   env : name of the new environment.
	"   label : if 1, then insert a \label at the end of the environment.
	"           otherwise, delete any \label line found.
	"   delete : a pattern which is to be deleted from the original environment.
	"            for example, going to a equation* environment means we need to
	"            delete \label's.
	"   putInNonumber : whether we need to put a \nonumber before the end of the
	"                 environment.
	function! s:Change(env, label, delete, putInNonumber)

		let start_line = line('.')
		let start_col = virtcol('.')

		if index(['[', '\[', '$$'], a:env) != -1
			let first = '\['
			let second = '\]'
		else
			let first = '\begin{' . a:env . '}'
			let second = '\end{' . a:env . '}'
		endif

		let match_no_comment = '\%(\\\@<!\%(\\\\\)*%.*\)\@<!'

		let top = searchpair(match_no_comment . '\%(\\\[\|\\begin{.\{-}}\)','', match_no_comment . '\%(\\\]\|\\end{.\{-}}\)\zs','cbW')
		let ix = getcurpos()[2]

		if  getline(top)[ix-1:] !~# '^\\begin{'
			let pat1 = '['
			let pat2 = ']'
		else
			let pat1 = '}'
			let pat2 = '}'
		end

		exe "normal! cf" . pat1 . "\<c-r>=first\<c-m>"

		let bottom = searchpair(match_no_comment . '\%(\\\[\|\\begin{\)','', match_no_comment . '\%(\\\]\|\\end{.\{-}}\)','W')
		exe "normal! cf" . pat2 . "\<c-r>=second\<c-m>"

		if a:delete != ''
			exe 'silent '. top . "," . bottom . 's/' . a:delete . '//e'
		endif

		if a:putInNonumber == 1
			exe top
			call search('\\end\|\\\\')
			if line('.') != bottom
				exe '.+1,' . bottom . 's/\\\\/\\nonumber\\\\/e'
				exe (bottom-1) . 's/\s*$/  \\nonumber/'
			endif
		endif

		if a:label == 1
			exe top
			if search("\\label", "W") > bottom
				exe top
				let local_label = input('Label? ')
				if local_label != ''
					put = '\label{'.local_label.'}'
				endif
				normal! $
			endif
		else
			exe 'silent '.top . ',' . bottom . ' g/\\label/delete'
		endif

		if exists('local_label') && local_label != ''
			exe 'silent!' start_line + 1.' | silent! normal! '.start_col.'|'
		else
			exe 'silent!' start_line.' | silent! normal! '.start_col.'|'
		endif
	endfunction " }}}

endif

" }}}
" Map <S-F1> through <S-F4> to insert environments {{{
if g:Tex_HotKeyMappings != ''

	" SetUpHotKeys: maps <F1> through <F4> to insert environments
	" Description: 
	function! <SID>SetUpHotKeys()
		let i = 1
		let envname = Tex_Strntok(g:Tex_HotKeyMappings, ',', i)
		while  envname != ''

			exec 'inoremap <silent> <buffer> <S-F'.i.'> <C-r>=Tex_PutEnvironment("'.envname.'")<CR>'

			let i = i + 1
			let envname = Tex_Strntok(g:Tex_HotKeyMappings, ',', i)
			
		endwhile

	endfunction

endif

" }}}
" Tex_SetFastEnvironmentMaps: function for setting up the <F5> and <S-F1>-<S-F4> keys {{{
" Description: This function is made public so it can be called by the
"              SetTeXOptions() function in main.vim
function! Tex_SetFastEnvironmentMaps()
	if g:Tex_PromptedEnvironments != ''
		call Tex_MakeMap("<F5>", "<Plug>Tex_FastEnvironmentInsert", 'i', '<silent> <buffer>')
		call Tex_MakeMap("<F5>", "<Plug>Tex_FastEnvironmentInsert", 'n', '<silent> <buffer>')
		call Tex_MakeMap("<F5>", "<Plug>Tex_FastEnvironmentInsert", 'v', '<silent> <buffer>')
		call Tex_MakeMap("<S-F5>", "<Plug>Tex_FastEnvironmentChange", 'i', '<silent> <buffer>')
		call Tex_MakeMap("<S-F5>", "<Plug>Tex_FastEnvironmentChange", 'n', '<silent> <buffer>')
	endif
	if g:Tex_HotKeyMappings != ''
		call s:SetUpHotKeys()
	endif
endfunction " }}}

" ==============================================================================
" Contributions / Tex_InsertItem() from Johannes Tanzler
" ============================================================================== 
" Tex_GetCurrentEnv: gets the current environment in which the cursor lies {{{
" Description: handles cases such as:
" 	
" 	\begin{itemize}
" 		\item first item
" 		\item second item
" 			\begin{description}
" 			\item first desc
" 			\item second
" 			% Tex_GetCurrentEnv will return "description" when called from here
" 			\end{description}
" 		\item third item
" 		% Tex_GetCurrentEnv will return "itemize" when called from here
" 	\end{itemize}
" 	% Tex_GetCurrentEnv will return "" when called from here 
"
" Author: Alan Schmitt
function! Tex_GetCurrentEnv()
	let pos = Tex_GetPos()

	let env_name = ''
	let match_no_comment = '\%(\\\@<!\%(\\\\\)*%.*\)\@<!'

	let env_line = searchpair(
				\ match_no_comment . '\%(\$\$\|\\\[\|\\begin{\)',
				\ '',
				\ match_no_comment . '\%(\$\$\|\\\]\|\\end{.\{-}}\)\zs',
				\ "bcW")

	let ix = getcurpos()[2]

	if env_line != 0
		let line = getline(env_line)[ix-1:]
		if line !~# '^\\begin{'
			let env_name = '['
		else
			let env_name = matchstr(line, '^\\begin{\zs.\{-}\ze}')
		endif
	endif

	call Tex_SetPos(pos)
	return env_name
endfunction
" }}}
" Tex_InsertItem: insert \item into a list   {{{
"    Description: Find last \begin line, extract env name, return to the start
"    			  position and insert proper \item, depending on env name.
"    			  Env names are stored in g: variables it can be used by
"    			  package files. 

for env in ['itemize', 'enumerate', 'theindex',
			\ 'asparaenum',  'asparaitem',
			\ 'compactenum', 'compactitem',
			\ 'inparaenum',  'inparaitem']
	exe "TexLet g:Tex_ItemStyle_" . env . " = '\\item" . s:items_with_cr . "'"
endfor

exe "TexLet g:Tex_ItemStyle_thebibliography = '\\bibitem[<+biblabel+>]{<+bibkey+>}" . s:items_with_cr . "<++>'"
exe "TexLet g:Tex_ItemStyle_description = '\\item[<+label+>]" . s:items_with_cr . "<++>'"

function! Tex_InsertItem()
    " Get current enclosing environment
	let env = Tex_GetCurrentEnv()

	if exists('g:Tex_ItemStyle_'.env)
		return IMAP_PutTextWithMovement(g:Tex_ItemStyle_{env})
	else
		return ''
	endif
endfunction
" }}}
" Tex_SetItemMaps: sets the \item inserting maps for current buffer {{{

inoremap <script> <silent> <Plug>Tex_InsertItemOnThisLine <C-r>=Tex_InsertItem()<CR>
inoremap <script> <silent> <Plug>Tex_InsertItemOnNextLine <ESC>o<C-R>=Tex_InsertItem()<CR>

function! Tex_SetItemMaps()
	" Only include the <M-i> mapping if the user want this. Note that it
	" conflicts with inserting 'é'.
	if !hasmapto("<Plug>Tex_InsertItemOnThisLine", "i") && g:Tex_AdvancedMath == 1
		imap <buffer> <M-i> <Plug>Tex_InsertItemOnThisLine
	endif
	if !hasmapto("<Plug>Tex_InsertItemOnNextLine", "i")
		imap <buffer> <C-CR> <Plug>Tex_InsertItemOnNextLine
	endif
endfunction " }}}

" ==============================================================================
" Implementation of Fast Environment commands for LaTeX commands 
" ==============================================================================
" Define certain commonly used command definitions {{{

TexLet g:Tex_Com_{'newtheorem'} = '\newtheorem{<+name+>}{<+caption+>}[<+within+>]'
TexLet g:Tex_Com_{'frac'} = '\frac{<+n+>}{<+d+>}<++>'
TexLet g:Tex_Com_{'tfrac'} = '\tfrac{<+n+>}{<+d+>}<++>'

" }}}
" PromptForCommand: prompts for a command {{{
" Description: 
function! PromptForCommand(ask)
	let common_com_prompt = 
				\ Tex_CreatePrompt(g:Tex_PromptedCommands, 2, ',') . "\n" .
				\ "Enter number or command name :"

	let inp = input(a:ask."\n".common_com_prompt)
	if inp =~ '^[0-9]\+$'
		let com = Tex_Strntok(g:Tex_PromptedCommands, ',', inp)
	else
		let com = inp
	endif

	return com
endfunction " }}}
" Tex_DoCommand: fast insertion of commands {{{
" Description:
"
function! Tex_DoCommand(isvisual)
	" If the current line is empty or if a visual selection has been made,
	" prompt for a new environment.
	if getline('.') == '' || a:isvisual == 'yes'
		let com = PromptForCommand('Choose a command to insert: ')
		if com != ''
			return Tex_PutCommand(com, a:isvisual)
		else
			return ''
		endif
	else
		" We want to find out the word under the cursor without issuing
		" any movement commands.
		let presline = getline('.')
		let c = col('.')

		let wordbef = matchstr(strpart(presline, 0, c-1), '\k\+\*\?$')
		let wordaft = matchstr(strpart(presline, c-1), '^\k\+\*\?')

		let word = wordbef . wordaft
		call Tex_Debug("Tex_DoCommand: wordbef = [".wordbef."], wordaft = [".wordaft."], word = [".word."]", 'env')

		" We use \<Del> instead of \<Bs> because \<Bs> does not work
		" unless bs=2
		if word != ''
			return substitute(wordbef, '.', "\<Left>", 'g')
				\ . substitute(word, '.', "\<Del>", 'g')
				\ . Tex_PutCommand(word, a:isvisual)
		else
			let cmd = PromptForCommand('Choose a command to insert: ')
			if cmd != ''
				return Tex_PutCommand(cmd, a:isvisual)
			else
				return ''
			endif
		endif
	endif
endfunction " }}}
" Tex_PutCommand: calls various specialized functions {{{
" Description: 
"   Based on input argument, it calls various specialized functions.
function! Tex_PutCommand(com, isvisual)
	if a:isvisual == "yes"
		if a:com == '$'
			return VEnclose('$', '$', '$', '$')
		elseif a:com == '\\('
			return VEnclose('\\(', '\\)', '\\(', '\\)')
		else
			return VEnclose("\\".a:com.'{', '}', "\\".a:com.'{', '}')
		endif
	else
		let com = a:com
		if exists('g:Tex_Com_{"'.a:com.'"}_aliasto')
			let com = g:Tex_Com_{a:com}_aliasto
		endif
		if exists('b:Tex_Com_{"'.com.'"}')
			return IMAP_PutTextWithMovement(b:Tex_Com_{com})
		elseif exists('g:Tex_Com_{"'.com.'"}')
			return IMAP_PutTextWithMovement(g:Tex_Com_{com})
		elseif com == '$'
			return IMAP_PutTextWithMovement('$<++>$')
		else
			return IMAP_PutTextWithMovement("\\".com.'{<++>}<++>')
		endif
	endif
endfunction " }}}
" Mapping the <F7> key to prompt/insert for command {{{
" and <S-F7> to prompt/replace command
"
" g:Tex_PromptedCommands is a variable containing a comma seperated list
" of commands. 
"
" Leaving this empty is equivalent to disabling the feature.
if g:Tex_PromptedCommands != ''

	inoremap <silent> <Plug>Tex_FastCommandInsert  <C-r>=Tex_DoCommand('no')<cr>
	nnoremap <silent> <Plug>Tex_FastCommandInsert  i<C-r>=Tex_DoCommand('no')<cr>
	vnoremap <silent> <Plug>Tex_FastCommandInsert  <C-\><C-N>:call Tex_DoCommand('yes')<CR>

	inoremap <silent> <Plug>Tex_FastCommandChange  <C-O>:call Tex_ChangeCommand('no')<CR>
	nnoremap <silent> <Plug>Tex_FastCommandChange  :call Tex_ChangeCommand('no')<CR>

	" Tex_ChangeCommand: calls ChangeCommand() to change the environment {{{
	" Description:
	"   Finds out which environment the cursor is positioned in and changes
	"   that to the chosen new environment. This function knows the changes
	"   which need to be made to change one env to another and calls
	"   ChangeCommand() with the info.
	"
	function! Tex_ChangeCommand(isvisual) 

		let pos_com = Tex_GetPos()

		let com_line = searchpair('\\\k\{-}{', '', '}', 'b')

		if com_line != 0
			normal! l
			let com_name = expand('<cword>')
		endif
		
		if !exists('com_name')
			echomsg "You are not inside command"
			call Tex_SetPos(pos_com)
			return 0
		endif

		exe 'echomsg "You are within a '.com_name.' command."'
		let change_com = PromptForCommand('Do you want to change it to (number or name)? ')

		if change_com == ''
			call Tex_SetPos(pos_com)
			return 0
		else
			call <SID>ChangeCommand(change_com)
			call Tex_SetPos(pos_com)
			return 0
		endif

	endfunction 

	" }}}
	" ChangeCommand: Changes current command according to prompt menu {{{
	" Description:
	"
	function! s:ChangeCommand(newcom)

		exe 'normal! ct{'.a:newcom."\<Esc>"
		
	endfunction
	" }}}

endif

" }}}
" Tex_SetFastCommandMaps: function for setting up the <F7> keys {{{
" Description: This function is made public so it can be called by the
"              SetTeXOptions() function in main.vim
function! Tex_SetFastCommandMaps()
	if g:Tex_PromptedCommands != ''
		if !hasmapto('<Plug>Tex_FastCommandInsert', 'i')
			imap <silent> <buffer> <F7> <Plug>Tex_FastCommandInsert
		endif
		if !hasmapto('<Plug>Tex_FastCommandInsert', 'n')
			nmap <silent> <buffer> <F7> <Plug>Tex_FastCommandInsert
		endif
		if !hasmapto('<Plug>Tex_FastCommandChange', 'i')
			imap <silent> <buffer> <S-F7> <Plug>Tex_FastCommandChange
		endif
		if !hasmapto('<Plug>Tex_FastCommandChange', 'n')
			nmap <silent> <buffer> <S-F7> <Plug>Tex_FastCommandChange
		endif
		if !hasmapto('<Plug>Tex_FastCommandInsert', 'v')
			vmap <silent> <buffer> <F7> <Plug>Tex_FastCommandInsert
		endif
	endif
endfunction " }}}

" SetEnvMacrosOptions: sets mappings for buffers {{{
" " Description: 
function! <SID>SetEnvMacrosOptions()
	if exists('b:doneTexEnvMaps')
		return
	endif
	let b:doneTexEnvMaps = 1
	if g:Tex_PromptedEnvironments != '' || g:Tex_HotKeyMappings != ''
		call Tex_SetFastEnvironmentMaps()
	endif
	if g:Tex_PromptedCommands != ''
		call Tex_SetFastCommandMaps()
	endif
	call Tex_SetItemMaps()
endfunction " }}}
" Catch the Filetype event so we set maps for each buffer {{{
augroup LatexSuite
	au LatexSuite User LatexSuiteFileType 
		\ call Tex_Debug('envmacros.vim: Catching LatexSuiteFileType event', 'env') |
		\ call s:SetEnvMacrosOptions()
augroup END
" }}}

let &cpo = s:save_cpo

" this statement has to be at the end.
let s:doneOnce = 1

" vim:fdm=marker:nowrap:noet:ff=unix
