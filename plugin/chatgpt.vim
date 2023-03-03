
let g:home_dir = $HOME
let g:openaiApikey = ""
let g:defaulOpenaiApikeyFile = g:home_dir.."/.openai.key"

function! chatgpt#SetApiKeyFile(apikeyFile)
    let g:defaulOpenaiApikeyFile = a:apikeyFile
endfunction

function! chatgpt#ReadApiKey()
    if g:openaiApikey != ""
        return TRUE
    endif
    if !filereadable(g:defaulOpenaiApikeyFile)
        return FALSE
    endif
    let filelines = readfile(g:defaulOpenaiApikeyFile)
    let g:openaiApikey = join(filelines, "\n")
    return g:openaiApikey != ""
endfunction

function! chatgpt#GetModules()
    let cmd = 'curl https://api.openai.com/v1/models -H "Authorization: Bearer '..g:openaiApikey..'"'
    return system(cmd)
endfunction
