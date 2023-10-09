#!/usr/bin/env python3
import os
import argparse
import json
try:
    import openai
except Exception as e:
    os.system("pip3 install --user openai")
    import openai


def chat(model, content, session):
    openai.api_key = os.environ["OPENAI_API_KEY"]
    msg = {"role": "user", "content": content}
    if session:
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
        response_msg = openai.ChatCompletion.create(model=model, messages=msgs, stop=r'@@@').choices[0].message
    except Exception as e:
        return e
    msgs.append(response_msg)
    if session:
        try:
            with open(session, "w") as f:
                json.dump(msgs, f)
        except Exception as e:
            return e
    return response_msg.content

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--model", required=True)
    parser.add_argument("--session", default="")
    parser.add_argument("content")
    result = parser.parse_args()
    print(chat(result.model,result.content, result.session))

if __name__ == "__main__":
    main()


