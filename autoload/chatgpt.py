#!/usr/bin/env python2
import os
import argparse
import json
try:
    import openai
except Exception as e:
    os.system("pip2 install --user openai")
    import openai


def chat(model, content, session):
    openai.api_key = os.environ["OPENAI_API_KEY"]
    base_url = os.environ["OPENAI_BASE_URL"] if "OPENAI_BASE_URL" in os.environ else ""
    if len(base_url) != -1:
        openai.base_url = base_url
    msg = {"role": "user", "content": content}
    msgs = load_session(session)
    msgs.append(msg)
    try:
        response_msg = openai.ChatCompletion.create(model=model, messages=msgs, stop=r'@@@').choices[-1].message
    except Exception as e:
        return e
    msgs.append(response_msg)
    save_session(session, msgs)
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


