let g:chatgptPyScript = expand("%:p:h") . "/chatgpt.py"
let g:openaiKeyFile = $HOME . "/.openai.key"
let g:chatgptModel = "gpt-3.5-turbo"

function! chatgpt#AddContent(content)
    let index = bufnr('__chatgpt__')
    if index == -1
        split
        enew
        file __chatgpt__
        setlocal noswapfile
        setlocal hidden
        setlocal wrap
        setlocal filetype=markdown
        setlocal buftype=nofile
        let index = bufnr('%')
    else
        if index(tabpagebuflist(), index) == -1
            split
            execute 'buffer' index
        else
            call win_gotoid(win_findbuf(index)[0])
        endif
    endif
    call append(line('$'), a:content)
    normal! G
endfunction

function! chatgpt#JobStdoutHandler(j, d, e)
    call chatgpt#AddContent('## Chatgpt:')
    call chatgpt#AddContent(a:d)
    call chatgpt#AddContent('--------------------------------------------------')
endfunction

function! chatgpt#CallPythonChat(content)
    let cmd = "python3 " . g:chatgptPyScript . " --keyfile " . shellescape(g:openaiKeyFile) . " --model " . shellescape(g:chatgptModel) . " " . shellescape(a:content) 
    call jobstart(cmd, {'on_stdout': function("chatgpt#JobStdoutHandler"), 'stdout_buffered': 1})
endfunction

function! chatgpt#ChatInVim(content)
    call chatgpt#AddContent('# You:')
    call chatgpt#AddContent(split(a:content, '\n'))
    call chatgpt#AddContent('--------------------------------------------------')
    call chatgpt#CallPythonChat(a:content)
endfunction


function! chatgpt#SetKeyFile(keyfile)
    let g:openaiKeyFile = keyfile
endfunction

function! chatgpt#SetModel(model)
    let g:chatgptModel = model
endfunction

function! chatgpt#getSelectedText()
	let save_reg = @a
	normal! gv"ay
	let text = @a
	let @a = save_reg
	return text
endfunction

function! chatgpt#ChatViusalContent(content)
	let selected = chatgpt#getSelectedText()
    let new_content = substitute(a:content, '%selected%', selected, 'g')
	call chatgpt#ChatInVim(new_content)
endfunction

function! chatgpt#AddConfig(key, content)
    execute 'vnoremap <silent> '. a:key . ' :<bs><bs><bs><bs><bs>call chatgpt#ChatViusalContent("' . a:content . '")<cr>'
endfunction


function! chatgpt#Chat()
    let content = input("You say:")
    if content == ""
        return
    endif
    call chatgpt#ChatInVim(content)
endfunction

nnoremap <silent><leader>cc :call chatgpt#Chat()

call chatgpt#AddConfig('<leader>ce', "请解释一下以下代码的含义：\\n%selected%")
call chatgpt#AddConfig('<leader>cd', "以下代码有什么问题吗：\\n%selected%")


