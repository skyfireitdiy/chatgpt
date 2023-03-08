import os
import argparse
import json
try:
    import openai
except Exception as e:
    os.system("pip3 install --user openai")
    import openai


keyFile = os.path.join(os.environ["HOME"], ".openai.key")

def readOpenAiApiKey():
    with open(keyFile, "r") as f:
        openai.api_key = f.read().strip()

def chat(model, content, session):
    if openai.api_key is None:
        return "please put your apikey to %s" % keyFile
    msg = {"role": "user", "content": content}
    if session != "":
        try:
            with open(session, "r") as f:
                msgs = json.load(f)
                if len(msgs) > 1000:
                    msgs = msgs[:1000]
                msgs.append(msg)
        except Exception:
            msgs = [msg]
    else:
        msgs = [msg]
    try:
        response_msg = openai.ChatCompletion.create(model=model, messages=msgs).choices[0].message
    except Exception as e:
        return e
    msgs.append(response_msg)
    if session!= "":
        try:
            with open(session, "w") as f:
                json.dump(msgs, f)
        except Exception:
            pass
    return response_msg.content

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--keyfile", default=keyFile)
    parser.add_argument("--model", default="gpt-3.5-turbo")
    parser.add_argument("--session", default="")
    parser.add_argument("content")
    result = parser.parse_args()
    if os.path.exists(result.keyfile):
        readOpenAiApiKey()
    print(chat(result.model,result.content, result.session))

if __name__ == "__main__":
    main()
