# ChatGPT Vim Plugin

ChatGPT Vim Plugin is a Vim plugin that provides a chat interface with OpenAI's GPT models. It allows you to chat with an AI in Vim and get responses in real-time.

## Installation

To install this plugin, you can use your favorite plugin manager. For example, if you're using Vim-Plug, you can add the following line to your vimrc file:

```vim
Plug 'skyfireitdiy/chatgpt'
```

## Usage

To start a new chat session, you can use the `:call chatgpt#Chat()` command. It will prompt you to enter the text you want to send to the AI, and show the response in the buffer. You can also use the following commands:

- `:call chatgpt#LoadSession()`: load an existing chat session.
- `:call chatgpt#DeleteSession()`: delete an existing chat session.
- `:call chatgpt#SetModel(model)`: set the GPT model to use. The default model is "gpt-3.5-turbo".
- `:call chatgpt#SetKeyFile(keyfile)`: set the path to your OpenAI API key file. The default path is "$HOME/.openai.key".

## Configuration

The plugin provides some example key mappings that can be used to quickly initiate a chat session with a specific prompt. To add your own key mappings, use the command :call chatgpt#AddConfig(key, content). Replace "key" with the key mapping you want to use and "content" with the prompt you want to start the chat session with. The prompt can contain a "&" symbol, which will be replaced with the currently selected text (if any) when the key mapping is used.

Example configuration:

```vim
nnoremap <silent><leader>cg :call chatgpt#Chat()<cr>
nnoremap <silent><leader>cN :call chatgpt#LoadSession()<cr>
nnoremap <silent><leader>cD :call chatgpt#DeleteSession()<cr>

call chatgpt#AddConfig('<leader>ce', 'Please explain the following code: &')
call chatgpt#AddConfig('<leader>cd', 'Is there anything wrong with the following code: &')
call chatgpt#AddConfig('<leader>cpp', 'Please implement the following functionality in C++: &')
call chatgpt#AddConfig('<leader>cgo', 'Please implement the following functionality in Go: &')
call chatgpt#AddConfig('<leader>cpy', 'Please implement the following functionality in Python: &')
call chatgpt#AddConfig('<leader>ca', '&')
call chatgpt#AddConfig('<leader>cw', 'Write an article on "&" using markdown')
call chatgpt#AddConfig('<leader>c?', 'What is &?')
call chatgpt#AddConfig('<leader>ch', 'How do I &?')
```

License

The ChatGPT Vim Plugin is released under the MIT License. See LICENSE file for details.

