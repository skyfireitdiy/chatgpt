# ChatGPT Vim Plugin

ChatGPT Vim Plugin is a Vim plugin that provides a chat interface with OpenAI's GPT models. It allows you to chat with an AI in Vim and get responses in real-time.

## Installation

To install this plugin, you can use your favorite plugin manager. For example, if you're using Vim-Plug, you can add the following line to your vimrc file:

```vim
Plug 'skyfireitdiy/chatgpt'
```

## Usage

To ask for some question, you can use the `:call chatgpt#Chat()` command. It will prompt you to enter the text you want to send to the AI, and show the response in the buffer. 

The session feature enables ChatGPT to have the capability of conducting a continuous conversation. Therefore, before asking a question, you can first set up a session.

You can also use the following commands:

-    chatgpt#AddConfig(key, content)
        Add a new configuration to the plugin. The configuration is a key-value pair, where the key is a string that represents the keybinding, and the value is a string that represents the content to be sent to the OpenAI API.
-    chatgpt#AddInBufConfig(key, content)
        Add a new configuration to the plugin. The configuration is a key-value pair, where the key is a string that represents the keybinding, and the value is a string that represents the content to be sent to the OpenAI API. This function is used for in-buffer mode.
-    chatgpt#AddOutBufConfig(key, content)
        Add a new configuration to the plugin. The configuration is a key-value pair, where the key is a string that represents the keybinding, and the value is a string that represents the content to be sent to the OpenAI API. This function is used for out-buffer mode.
-    chatgpt#Chat()
        Start a new chat session.
-    chatgpt#CloseSession()
        Close the current chat session.
-    chatgpt#DeleteSession()
        Delete a chat session.
-    chatgpt#InBufChat()
        Send a message to the OpenAI API in in-buffer mode.
-    chatgpt#InBufChatVisual()
        Send a message to the OpenAI API in in-buffer mode, including the selected text.
-    chatgpt#LoadSession()
        Load a chat session.
-    chatgpt#OpenWindow()
        Open the chat window.
-    chatgpt#OutBufChat()
        Send a message to the OpenAI API in out-buffer mode.
-    chatgpt#OutBufChatVisual()
        Send a message to the OpenAI API in out-buffer mode, including the selected text.
-    chatgpt#SetKeyFile(keyfile)
        Set the path to the OpenAI API key file.
-    chatgpt#SetModel(model)
        Set the name of the GPT model to use.

The difference between inbuf and outbuf is that the content of inbuf will be directly inserted into the current buffer.

## Configuration

The plugin provides some example key mappings that can be used to quickly initiate a chat session with a specific prompt. To add your own key mappings, use the command :call chatgpt#AddConfig(key, content). Replace "key" with the key mapping you want to use and "content" with the prompt you want to start the chat session with. The prompt can contain a "&" symbol, which will be replaced with the currently selected text (if any) when the key mapping is used.

Example configuration:

```vim
nnoremap <silent><leader>cg :call chatgpt#OutBufChat()<cr>
nnoremap <silent><leader>cL :call chatgpt#LoadSession()<cr>
nnoremap <silent><leader>cD :call chatgpt#DeleteSession()<cr>
nnoremap <silent><leader>cC :call chatgpt#CloseSession()<cr>
nnoremap <silent><leader>cO :call chatgpt#OpenWindow()<cr>

nnoremap <silent><leader>ck :call chatgpt#InBufChat()<cr>

vnoremap <silent><leader>cg <ESC>:call chatgpt#OutBufChatVisual()<cr>
vnoremap <silent><leader>ck <ESC>:call chatgpt#InBufChatVisual()<cr>


call chatgpt#AddOutBufConfig('<leader>ce', 'Please explain the following code: &')
call chatgpt#AddOutBufConfig('<leader>cd', 'Is there any problem with the following code: &')
call chatgpt#AddOutBufConfig('<leader>cpp', 'Please implement the following function in c++: &')
call chatgpt#AddOutBufConfig('<leader>cgo', 'Please implement the following function in go: &')
call chatgpt#AddOutBufConfig('<leader>cpy', 'Please implement the following function in python: &')
call chatgpt#AddOutBufConfig('<leader>ca', '&')
call chatgpt#AddOutBufConfig('<leader>cw', 'Write an article with "&" as the topic and output it in markdown format')
call chatgpt#AddOutBufConfig('<leader>c?', 'What is &')
call chatgpt#AddOutBufConfig('<leader>ch', 'How to &')
```

License

The ChatGPT Vim Plugin is released under the MIT License. See LICENSE file for details.

