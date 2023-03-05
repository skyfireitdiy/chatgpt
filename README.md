# ChatGPT Vim Plugin

- Author: SkyFire
- GitHub: https://github.com/skyfireitdiy/chatgpt
- Email: skyfireitdiy@hotmail.com

This is a Vim plugin for ChatGPT. It allows you to chat with the OpenAI-powered ChatGPT model within Vim.

## Installation

1. Install the `python3` executable.
2. Clone the `chatgpt` repository at `https://github.com/skyfireitdiy/chatgpt.git`.
3. Add the following lines to your `~/.vimrc` file:

```
let g:chatgptPyScript = expand("<path/to/chatgpt.py>")
let g:openaiKeyFile = "<path/to/openai.key>"
let g:chatgptModel = "gpt-3.5-turbo"

nnoremap <silent> <leader>C :call chatgpt#Chat()<cr>
```

Make sure to replace `<path/to/chatgpt.py>` and `<path/to/openai.key>` with the actual paths. You can obtain an OpenAI API key at https://beta.openai.com/signup/.

## Usage 

### Basic Usage

To chat with ChatGPT, simply type `<leader>C` in Normal mode. This will open a prompt where you can type your message to the model. Once you press Enter, the model's response will be shown in a new buffer named "__chatgpt__".

### Customization

The ChatGPT plugin supports a number of customization options. These can be set in your `~/.vimrc` file using the following commands:

- `chatgpt#SetKeyFile(keyfile)`: Sets the path to your OpenAI API key file.
- `chatgpt#SetModel(model)`: Sets the name of the ChatGPT model to use.

In addition, you can define new mappings for visual mode using the `chatgpt#AddConfig(key, content)` function. For example, the following command creates a new mapping that sends the selected text to ChatGPT:

```
call chatgpt#AddConfig('<leader>g', 'Somebody said: %selected%')
```

Now, in visual mode, you can select some text and then type `<leader>g` to send it to ChatGPT with the message "Somebody said: <selected text>". The `%selected%` placeholder will be replaced with the actual selected text.

## License

This plugin is released under the MIT License. See LICENSE file for more details.

--------------------------------------------------
