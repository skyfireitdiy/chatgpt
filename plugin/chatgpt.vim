
let g:home_dir = $HOME
let g:apikey = ""
let g:defaulApikeyFile = g:home_dir.."/.openai.key"

function! SetApkKeyFile(apikeyFile)
    let g:defaulApikeyFile = a:apikeyFile
endfunction

function! ReadApiKey()
    if g:apikey != ""
        return TRUE
    endif
    if !filereadable(g:defaulApikeyFile)
        return FALSE
    endif
    let filelines = readfile(g:defaulApikeyFile)
    let g:apikey = join(filelines, "\n")
    return g:apikey != ""
endfunction
