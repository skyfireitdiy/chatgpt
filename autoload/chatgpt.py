import os
import argparse
try:
    import openai
except Exception as e:
    os.system("pip3 install --user openai")
    import openai


keyFile = os.path.join(os.environ["HOME"], ".openai.key")

def readOpenAiApiKey():
    with open(keyFile, "r") as f:
        openai.api_key = f.read().strip()

def chat(model, content):
    if openai.api_key is None:
        return "please put your apikey to %s" % keyFile
    print(openai.api_key)
    return openai.ChatCompletion.create(model=model, messages=[
        {"role":"user", "content": content}
        ]).choices[0].message.content

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--keyfile", default=keyFile)
    parser.add_argument("--model", default="gpt-3.5-turbo")
    parser.add_argument("content")
    result = parser.parse_args()
    if os.path.exists(result.keyfile):
        readOpenAiApiKey()
    print(chat(result.model,result.content))

if __name__ == "__main__":
    main()
