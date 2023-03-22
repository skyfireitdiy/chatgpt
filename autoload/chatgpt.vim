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
            if g:currentSession != ""
                call append(line('$'), '- Session: ' . g:currentSession)
            endif
            call append(line('$'), '------------------------------------------------')
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
    setlocal paste
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

function! chatgpt#outbufChatJobStdoutHandler(j, d, e)
    let current_datetime = strftime("%Y-%m-%d %H:%M:%S")
    call chatgpt#addContent('## '.current_datetime.' ChatGPT '.g:chatgptModel.':')
    call chatgpt#addContent(a:d)
    call chatgpt#addContent('------------------------------------------------')
endfunction


function! chatgpt#inbufChatJobStdoutHandler(j, d, e)
    call chatgpt#outbufChatJobStdoutHandler(a:j, a:d, a:e)
    let codes = chatgpt#getCodeBlocks(a:d)
    if len(codes) > 0
        call append(line('.'), codes)
    endif
endfunction

function! chatgpt#inbufVisualJobStdoutHandler(j, d, e)
    call chatgpt#outbufChatJobStdoutHandler(a:j, a:d, a:e)
    let codes = a:d
    if len(codes) > 0
        normal! gvd
        call append(line('.'), codes)
    endif
endfunction

function! chatgpt#outbufCallPythonChat(content)
    let cmd = "python3 " . g:chatgptPyScript . " --keyfile " . shellescape(g:openaiKeyFile) . " --model " .shellescape(g:chatgptModel) . " " . shellescape(a:content)
    if g:currentSession != ""
        let cmd = cmd . " --session " . shellescape(chatgpt#sessionDataName(g:currentSession))
    endif
    call jobstart(cmd, {'on_stdout': function("chatgpt#outbufChatJobStdoutHandler"), 'stdout_buffered': 1})
endfunction


function! chatgpt#inbufCallPythonChat(content, vmode)
    let cmd = "python3 " . g:chatgptPyScript . " --keyfile " . shellescape(g:openaiKeyFile) . " --model " .shellescape(g:chatgptModel) . " " . shellescape(a:content)
    if a:vmode
        call jobstart(cmd, {'on_stdout': function("chatgpt#inbufVisualJobStdoutHandler"), 'stdout_buffered': 1})
    else
        call jobstart(cmd, {'on_stdout': function("chatgpt#inbufChatJobStdoutHandler"), 'stdout_buffered': 1})
    endif
endfunction

function! chatgpt#addMyInput(content)
    let current_datetime = strftime("%Y-%m-%d %H:%M:%S")
    call chatgpt#addContent('# '.current_datetime.' You:')
    call chatgpt#addContent(split(a:content, '\n'))
endfunction

function! chatgpt#outbufChatInVim(content)
    call chatgpt#addMyInput(a:content)
    call chatgpt#outbufCallPythonChat(a:content)
endfunction

function! chatgpt#inbufChatInVim(content, vmode)
    call chatgpt#addMyInput(a:content)
    call chatgpt#inbufCallPythonChat(a:content . "\n[Do not output any content other than code snippets.]", a:vmode)
endfunction

function! chatgpt#SetKeyFile(keyfile)
    let g:openaiKeyFile = a:keyfile
endfunction

function! chatgpt#SetModel(model)
    let g:chatgptModel = a:model
endfunction

function! chatgpt#getVisualText()
    let save_reg = @a
    normal! gv"ay
    let text = @a
    let @a = save_reg
    return text
endfunction

function! chatgpt#outbufChatViusalContent(content)
    let selected = chatgpt#getVisualText()
    let new_content = substitute(a:content, '&', selected, 'g')
    call chatgpt#outbufChatInVim(new_content)
endfunction


function! chatgpt#inbufChatViusalContent(content)
    let selected = chatgpt#getVisualText()
    let new_content = substitute(a:content, '&', selected, 'g')
    call chatgpt#inbufChatInVim(new_content)
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

" ---------------------- 下面是对外接口 ----------------------

function! chatgpt#AddConfig(key, content)
    call chatgpt#AddOutBufConfig(a:key, a:content)
endfunction

function! chatgpt#AddOutBufConfig(key, content)
    execute 'vnoremap <silent> '. a:key . ' :<bs><bs><bs><bs><bs>call chatgpt#outbufChatViusalContent("' . a:content . '")<cr>'
endfunction

function! chatgpt#AddInBufConfig(key, content)
    execute 'vnoremap <silent> '. a:key . ' :<bs><bs><bs><bs><bs>call chatgpt#inbufChatViusalContent("' . a:content . '")<cr>'
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
    else
        call chatgpt#OpenWindow()
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

function! chatgpt#OutBufChat()
    if g:currentSession == ""
        let content = input("You say:")
    else
        let content = input(g:currentSession . ":")
    endif
    if content == ""
        return
    endif
    call chatgpt#outbufChatInVim(content)
endfunction

function! chatgpt#Chat()
    call chatgpt#OutbufChat()
endfunction

function! chatgpt#OutBufChatVisual()
    if g:currentSession == ""
        let content = input("You say:")
    else
        let content = input(g:currentSession . ":")
    endif
    if content == ""
        return
    endif
    let text = chatgpt#getVisualText()
    call chatgpt#outbufChatInVim("```\n" . text . "\n```\n" . content)
endfunction

function! chatgpt#InBufChat()
    if g:currentSession == ""
        let content = input("You say:")
    else
        let content = input(g:currentSession . ":")
    endif
    if content == ""
        return
    endif
    call chatgpt#inbufChatInVim(content, 0)
endfunction


function! chatgpt#InBufChatVisual()
    if g:currentSession == ""
        let content = input("You say:")
    else
        let content = input(g:currentSession . ":")
    endif
    if content == ""
        return
    endif
    let text = chatgpt#getVisualText()
    call chatgpt#inbufChatInVim("```\n" . text . "\n```\n" . content, 1)
endfunction


augroup chatgptWipeBuf
    autocmd!
    autocmd VimLeave * :call chatgpt#wipeBuf()
    autocmd VimEnter * :call chatgpt#wipeBuf()
    autocmd SessionLoadPost * :call chatgpt#wipeBuf()
augroup END


" 公开函数：
"    chatgpt#AddConfig(key, content)
"        添加一个新的配置到插件中。配置是一个键值对，其中键是表示键绑定的字符串，值是表示要发送到OpenAI API的内容的字符串。
"    chatgpt#AddInBufConfig(key, content)
"        添加一个新的配置到插件中。配置是一个键值对，其中键是表示键绑定的字符串，值是表示要发送到OpenAI API的内容的字符串。此函数用于缓冲区内模式。
"    chatgpt#AddOutBufConfig(key, content)
"        添加一个新的配置到插件中。配置是一个键值对，其中键是表示键绑定的字符串，值是表示要发送到OpenAI API的内容的字符串。此函数用于缓冲区外模式。
"    chatgpt#Chat()
"        开始一个新的聊天会话。
"    chatgpt#CloseSession()
"        关闭当前的聊天会话。
"    chatgpt#DeleteSession()
"        删除聊天会话。
"    chatgpt#InBufChat()
"        在缓冲区内模式下向OpenAI API发送消息。
"    chatgpt#InBufChatVisual()
"        在缓冲区内模式下向OpenAI API发送消息，包括所选文本。
"    chatgpt#LoadSession()
"        加载聊天会话。
"    chatgpt#OpenWindow()
"        打开聊天窗口。
"    chatgpt#OutBufChat()
"        在缓冲区外模式下向OpenAI API发送消息。
"    chatgpt#OutBufChatVisual()
"        在缓冲区外模式下向OpenAI API发送消息，包括所选文本。
"    chatgpt#SetKeyFile(keyfile)
"        设置OpenAI API密钥文件的路径。
"    chatgpt#SetModel(model)
"        设置要使用的GPT模型的名称。
"
" 示例配置：
" nnoremap <silent><leader>cg :call chatgpt#OutBufChat()<cr>
" nnoremap <silent><leader>cL :call chatgpt#LoadSession()<cr>
" nnoremap <silent><leader>cD :call chatgpt#DeleteSession()<cr>
" nnoremap <silent><leader>cC :call chatgpt#CloseSession()<cr>
" nnoremap <silent><leader>cO :call chatgpt#OpenWindow()<cr>

" nnoremap <silent><leader>ck :call chatgpt#InBufChat()<cr>

" vnoremap <silent><leader>cg <ESC>:call chatgpt#OutBufChatVisual()<cr>
" vnoremap <silent><leader>ck <ESC>:call chatgpt#InBufChatVisual()<cr>


" call chatgpt#AddOutBufConfig('<leader>ce', '请解释以下代码：&')
" call chatgpt#AddOutBufConfig('<leader>cd', '以下代码有什么问题吗：&')
" call chatgpt#AddOutBufConfig('<leader>cpp', '请用c++实现以下功能：&')
" call chatgpt#AddOutBufConfig('<leader>cgo', '请用go实现以下功能：&')
" call chatgpt#AddOutBufConfig('<leader>cpy', '请用python实现以下功能：&')
" call chatgpt#AddOutBufConfig('<leader>ca', '&')
" call chatgpt#AddOutBufConfig('<leader>cw', '编写以“&”为题目的文章，以markdown格式输出')
" call chatgpt#AddOutBufConfig('<leader>c?', '什么是&')
" call chatgpt#AddOutBufConfig('<leader>ch', '如何&')


