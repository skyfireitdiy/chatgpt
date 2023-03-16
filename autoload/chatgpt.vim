let g:chatgptPyScript = expand("<sfile>:p:h") . "/chatgpt.py"
let g:openaiKeyFile = $HOME . "/.openai.key"
let g:chatgptModel = "gpt-3.5-turbo"
let g:currentSession = ""

function! chatgpt#OpenWindow(addheader=1)
    let index = bufnr('__chatgpt__')
    let new = 0
    if index == -1
        vsplit
        wincmd L
        enew
        file __chatgpt__
        let index = bufnr('%')
        if a:addheader == 1
            call append(line('$'), '- ChatGPT Vim Plugin')
            call append(line('$'), '- SkyFire')
            call append(line('$'), '- https://github.com/skyfireitdiy/chatgpt')
            call append(line('$'), '- skyfireitdiy@hotmail.com')
            call append(line('$'), '-------------------------------------------------')
        endif
        let new = 1
    else
        if index(tabpagebuflist(), index) == -1
            vsplit
            wincmd L
            execute 'buffer' index
        else
            call win_gotoid(win_findbuf(index)[0])
        endif
    endif
    setlocal noswapfile
    setlocal hidden
    setlocal wrap
    setlocal filetype=markdown
    setlocal buftype=nofile
    return new
endfunction

function! chatgpt#addContent(content, addheader=1)
    let isInGpt = bufname('%') == '__chatgpt__'
    let new = chatgpt#OpenWindow(a:addheader)
    call append(line('$'), a:content)
    let sessionFile = chatgpt#sessionFileName(g:currentSession)
    if new == 1
        0delete
    endif
    if sessionFile != ""
        execute "w! " . sessionFile
    endif
    normal! G
    if (!isInGpt)
        wincmd p
    endif
endfunction

function! chatgpt#wipeBuf()
    let index = bufnr('__chatgpt__')
    if index == -1
        return
    endif
    if index(tabpagebuflist(), index) == -1
        vsplit
        execute 'buffer' index
    else
        call win_gotoid(win_findbuf(index)[0])
    endif
    bwipeout!
endfunction

function! chatgpt#JobStdoutHandler(j, d, e)
    call chatgpt#addContent('## Chatgpt:')
    call chatgpt#addContent(a:d)
    call chatgpt#addContent('--------------------------------------------------')
endfunction

function! chatgpt#callPythonChat(content)
    let cmd = "python3 " . g:chatgptPyScript . " --keyfile " . shellescape(g:openaiKeyFile) . " --model " .shellescape(g:chatgptModel) . " " . shellescape(a:content)
    if g:currentSession != ""
        let cmd = cmd . " --session " . shellescape(chatgpt#sessionDataName(g:currentSession))
    endif
    call jobstart(cmd, {'on_stdout': function("chatgpt#JobStdoutHandler"), 'stdout_buffered': 1})
endfunction

function! chatgpt#chatInVim(content)
    call chatgpt#addContent('# You:')
    call chatgpt#addContent(split(a:content, '\n'))
    call chatgpt#addContent('--------------------------------------------------')
    call chatgpt#callPythonChat(a:content)
endfunction


function! chatgpt#SetKeyFile(keyfile)
    let g:openaiKeyFile = a:keyfile
endfunction

function! chatgpt#SetModel(model)
    let g:chatgptModel = a:model
endfunction

function! chatgpt#getSelectedText()
    let save_reg = @a
    normal! gv"ay
    let text = @a
    let @a = save_reg
    return text
endfunction

function! chatgpt#chatViusalContent(content)
    let selected = chatgpt#getSelectedText()
    let new_content = substitute(a:content, '&', selected, 'g')
    call chatgpt#chatInVim(new_content)
endfunction

function! chatgpt#AddConfig(key, content)
    execute 'vnoremap <silent> '. a:key . ' :<bs><bs><bs><bs><bs>call chatgpt#chatViusalContent("' . a:content . '")<cr>'
endfunction

function! chatgpt#sessionFileName(session)
    if a:session == ""
        return ""
    endif
    return $HOME . "/.chatgpt/" . a:session . "_chat"
endfunction

function! chatgpt#sessionDataName(session)
    if a:session == ""
        return ""
    endif
    return $HOME . "/.chatgpt/" . a:session . "_meta"
endfunction



function! chatgpt#safeSession(str)
    let pathstr = substitute(a:str, '[^[:alnum:]]', '_', 'g')
    let pathstr = substitute(pathstr, '__*', '_', 'g')
    let pathstr = substitute(pathstr, '^_', '', '')
    let pathstr = substitute(pathstr, '_$', '', '')
    let pathstr = tolower(pathstr)
    return pathstr
endfunction

function! chatgpt#LoadSession()
    let session = input("Chat Session Name:")
    if session == ""
        return
    endif
    call chatgpt#wipeBuf()
    call system("mkdir -p ~/.chatgpt")
    let g:currentSession = session
    let sessionFile = chatgpt#sessionFileName(session)
    if filereadable(sessionFile)
        let data = readfile(sessionFile)
        call chatgpt#addContent(data, 0)
    endif
endfunction

function! chatgpt#CloseSession()
    let g:currentSession = ""
    call chatgpt#wipeBuf()
endfunction

function! chatgpt#DeleteSession()
    let session = input("Chat Session Name:")
    if session == ""
        return
    endif
    let session = chatgpt#safeSession(session)
    if g:currentSession == session
        call chatgpt#wipeBuf()
        let g:currentSession = ""
    endif
    let sessionData = chatgpt#sessionDataName(session)
    let sessionFile = chatgpt#sessionFileName(session)
    call system("rm -f " . sessionData)
    call system("rm -f " . sessionFile)
endfunction


function! chatgpt#Chat()
    let content = input("You say:")
    if content == ""
        return
    endif
    call chatgpt#chatInVim(content)
endfunction

augroup chatgptWipeBuf
    autocmd!
    autocmd VimLeave * :call chatgpt#wipeBuf()
    autocmd VimEnter * :call chatgpt#wipeBuf()
    autocmd SessionLoadPost * :call chatgpt#wipeBuf()
augroup END


" 公开函数：
" chatgpt#Chat
" chatgpt#LoadSession
" chatgpt#DeleteSession
" chatgpt#CloseSession()
" chatgpt#OpenWindow()
" chatgpt#SetModel
" chatgpt#SetKeyFile


" 示例配置：
" nnoremap <silent><leader>cg :call chatgpt#Chat()<cr>
" nnoremap <silent><leader>cL :call chatgpt#LoadSession()<cr>
" nnoremap <silent><leader>cD :call chatgpt#DeleteSession()<cr>
" nnoremap <silent><leader>cC :call chatgpt#CloseSession()<cr>
" nnoremap <silent><leader>cO :call chatgpt#OpenWindow()<cr>
"
" call chatgpt#AddConfig('<leader>ce', '请解释以下代码：&')
" call chatgpt#AddConfig('<leader>cd', '以下代码有什么问题吗：&')
" call chatgpt#AddConfig('<leader>cpp', '请用c++实现以下功能：&')
" call chatgpt#AddConfig('<leader>cgo', '请用go实现以下功能：&')
" call chatgpt#AddConfig('<leader>cpy', '请用python实现以下功能：&')
" call chatgpt#AddConfig('<leader>ca', '&')
" call chatgpt#AddConfig('<leader>cw', '编写以“&”为题目的文章，以markdown格式输出')
" call chatgpt#AddConfig('<leader>c?', '什么是&')
" call chatgpt#AddConfig('<leader>ch', '如何&')
