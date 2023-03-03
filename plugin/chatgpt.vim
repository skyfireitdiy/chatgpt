python <<EOF
try:
    import os
    import openai
except Exception as e:
    os.system("pip3 install --user openai")
    import openai


keyFile = os.path.join(os.environ["HOME"], ".openai.key")
model = "gpt-3.5-turbo"

def readOpenAiApiKey():
    global opanaiApiKey
    with open(keyFile, "r") as f:
        openai.api_key = f.read().strip()

def chat(content):
    return openai.ChatCompletion.create(model=model, messages=[
        {"role":"user", "content": content}
        ]).choices[0].message.content

if os.path.exists(keyFile):
    readOpenAiApiKey()
EOF



function! chatgpt#AddContent(content)
    let index = bufnr('__chatgpt__')
    if index == -1
        split
        enew
        file __chatgpt__
        setlocal noswapfile
        setlocal nofile
        setlocal hidden
        let index = bufnr('%')
    else
        if index(tabpagebuflist(), index) == -1
            split
        endif
        execute 'buffer' index
      endif
    call append(line('$'), a:content)
endfunction
