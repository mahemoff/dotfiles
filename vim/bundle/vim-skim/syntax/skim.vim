" Vim syntax file
" Language: Skim
" Maintainer: Andrew Stone <andy@stonean.com>
" Version:  1
" Last Change:  2010 Sep 25
" TODO: Feedback is welcomed.

" Quit when a syntax file is already loaded.
if exists("b:current_syntax")
  finish
endif

if !exists("main_syntax")
  let main_syntax = 'skim'
endif

" Allows a per line syntax evaluation.
let b:ruby_no_expensive = 1

" Include Ruby syntax highlighting
syn include @skimRubyTop syntax/ruby.vim
unlet! b:current_syntax
" Include Haml syntax highlighting
syn include @skimHaml syntax/haml.vim
unlet! b:current_syntax

syn match skimBegin  "^\s*\(&[^= ]\)\@!" nextgroup=skimTag,skimClassChar,skimIdChar,skimRuby

syn region  rubyCurlyBlock start="{" end="}" contains=@skimRubyTop contained
syn cluster skimRubyTop    add=rubyCurlyBlock

syn cluster skimComponent contains=skimClassChar,skimIdChar,skimWrappedAttrs,skimRuby,skimAttr,skimInlineTagChar

syn keyword skimDocType        contained html 5 1.1 strict frameset mobile basic transitional
syn match   skimDocTypeKeyword "^\s*\(doctype\)\s\+" nextgroup=skimDocType

syn keyword skimTodo        FIXME TODO NOTE OPTIMIZE XXX contained
syn keyword htmlTagName     contained script

syn match skimTag           "\w\+[><]*"         contained contains=htmlTagName nextgroup=@skimComponent
syn match skimIdChar        "#{\@!"        contained nextgroup=skimId
syn match skimId            "\%(\w\|-\)\+" contained nextgroup=@skimComponent
syn match skimClassChar     "\."           contained nextgroup=skimClass
syn match skimClass         "\%(\w\|-\)\+" contained nextgroup=@skimComponent
syn match skimInlineTagChar "\s*:\s*"      contained nextgroup=skimTag,skimClassChar,skimIdChar

syn region skimWrappedAttrs matchgroup=skimWrappedAttrsDelimiter start="\s*{\s*" skip="}\s*\""  end="\s*}\s*"  contained contains=skimAttr nextgroup=skimRuby
syn region skimWrappedAttrs matchgroup=skimWrappedAttrsDelimiter start="\s*\[\s*" end="\s*\]\s*" contained contains=skimAttr nextgroup=skimRuby
syn region skimWrappedAttrs matchgroup=skimWrappedAttrsDelimiter start="\s*(\s*"  end="\s*)\s*"  contained contains=skimAttr nextgroup=skimRuby

syn match skimAttr "\s*\%(\w\|-\)\+\s*" contained contains=htmlArg nextgroup=skimAttrAssignment
syn match skimAttrAssignment "\s*=\s*" contained nextgroup=skimWrappedAttrValue,skimAttrString

syn region skimWrappedAttrValue matchgroup=skimWrappedAttrValueDelimiter start="{" end="}" contained contains=skimAttrString,@skimRubyTop nextgroup=skimAttr,skimRuby,skimInlineTagChar
syn region skimWrappedAttrValue matchgroup=skimWrappedAttrValueDelimiter start="\[" end="\]" contained contains=skimAttrString,@skimRubyTop nextgroup=skimAttr,skimRuby,skimInlineTagChar
syn region skimWrappedAttrValue matchgroup=skimWrappedAttrValueDelimiter start="(" end=")" contained contains=skimAttrString,@skimRubyTop nextgroup=skimAttr,skimRuby,skimInlineTagChar

syn region skimAttrString start=+\s*"+ skip=+\%(\\\\\)*\\"+ end=+"\s*+ contained contains=skimInterpolation,skimInterpolationEscape nextgroup=skimAttr,skimRuby,skimInlineTagChar
syn region skimAttrString start=+\s*'+ skip=+\%(\\\\\)*\\"+ end=+'\s*+ contained contains=skimInterpolation,skimInterpolationEscape nextgroup=skimAttr,skimRuby,skimInlineTagChar

syn region skimInnerAttrString start=+\s*"+ skip=+\%(\\\\\)*\\"+ end=+"\s*+ contained contains=skimInterpolation,skimInterpolationEscape nextgroup=skimAttr
syn region skimInnerAttrString start=+\s*'+ skip=+\%(\\\\\)*\\"+ end=+'\s*+ contained contains=skimInterpolation,skimInterpolationEscape nextgroup=skimAttr

syn region skimInterpolation matchgroup=skimInterpolationDelimiter start="#{" end="}" contains=@hamlRubyTop containedin=javascriptStringS,javascriptStringD,skimWrappedAttrs
syn region skimInterpolation matchgroup=skimInterpolationDelimiter start="#{{" end="}}" contains=@hamlRubyTop containedin=javascriptStringS,javascriptStringD,skimWrappedAttrs
syn match  skimInterpolationEscape "\\\@<!\%(\\\\\)*\\\%(\\\ze#{\|#\ze{\)"

syn region skimRuby matchgroup=skimRubyOutputChar start="\s*[=]\==[']\=" skip=",\s*$" end="$" contained contains=@skimRubyTop keepend
syn region skimRuby matchgroup=skimRubyChar       start="\s*-"           skip=",\s*$" end="$" contained contains=@skimRubyTop keepend

syn match skimComment /^\(\s*\)[/].*\(\n\1\s.*\)*/ contains=skimTodo
syn match skimText    /^\(\s*\)[`|'].*\(\n\1\s.*\)*/

syn match skimFilter /\s*\w\+:\s*/                            contained
syn match skimHaml   /^\(\s*\)\<haml:\>.*\(\n\1\s.*\)*/       contains=@skimHaml,skimFilter

syn match skimIEConditional "\%(^\s*/\)\@<=\[\s*if\>[^]]*]" contained containedin=skimComment

hi def link skimAttrString                String
hi def link skimBegin                     String
hi def link skimClass                     Type
hi def link skimAttr                      Type
hi def link skimClassChar                 Type
hi def link skimComment                   Comment
hi def link skimDocType                   Identifier
hi def link skimDocTypeKeyword            Keyword
hi def link skimFilter                    Keyword
hi def link skimIEConditional             SpecialComment
hi def link skimId                        Identifier
hi def link skimIdChar                    Identifier
hi def link skimInnerAttrString           String
hi def link skimInterpolationDelimiter    Delimiter
hi def link skimRubyChar                  Special
hi def link skimRubyOutputChar            Special
hi def link skimText                      String
hi def link skimTodo                      Todo
hi def link skimWrappedAttrValueDelimiter Delimiter
hi def link skimWrappedAttrsDelimiter     Delimiter
hi def link skimInlineTagChar             Delimiter

let b:current_syntax = "skim"
