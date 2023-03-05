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
endfunction

function! chatgpt#JobStdoutHandler(j, d, e)
    call chatgpt#AddContent('- Chatgpt:')
    call chatgpt#AddContent(a:d)
    call chatgpt#AddContent('')
    call chatgpt#AddContent('==================================================')
endfunction

function! chatgpt#CallPythonChat(content)
    let cmd = "python3 " . g:chatgptPyScript . " --keyfile " . shellescape(g:openaiKeyFile) . " --model " . shellescape(g:chatgptModel) . " " . shellescape(a:content) 
    echom 'cmd is:' . cmd
    call jobstart(cmd, {'on_stdout': function("chatgpt#JobStdoutHandler"), 'stdout_buffered': 1})
endfunction

function! chatgpt#SetKeyFile(keyfile)
    let g:openaiKeyFile = keyfile
endfunction

function! chatgpt#SetModel(model)
    let g:chatgptModel = model
endfunction

function! chatgpt#Chat()
    let content = input("You say:")
    if content == ""
        return
    endif
    call chatgpt#AddContent('- You:')
    call chatgpt#AddContent('')
    call chatgpt#AddContent(content)
    call chatgpt#AddContent('')
    call chatgpt#CallPythonChat(content)
endfunction
