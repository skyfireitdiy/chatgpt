#!/usr/bin/env python3
import requests
import json
import argparse
import sys
import os
from chatcore import *


urls = {
        "ErnieBot": "https://aip.baidubce.com/rpc/2.0/ai_custom/v1/wenxinworkshop/chat/eb-instant",
        "ErnieBot-turbo": "https://aip.baidubce.com/rpc/2.0/ai_custom/v1/wenxinworkshop/chat/eb-instant",
        }


def chat(api_key, secret_key, session, content, m):
    url = urls[m] + "?access_token=" + get_access_token(api_key, secret_key)
    msg = {"role": "user", "content": content}
    msgs = load_session(session)
    msgs.append(msg)
    payload = json.dumps({
        "messages": msgs
        })
    headers = {
            'Content-Type': 'application/json'
            }
    response = requests.request("POST", url, headers=headers, data=payload)
    try:
        res = json.loads(response.text)
        ret = res["result"]
        msgs.append({"role": "assistant", "content": ret})
        save_session(session, msgs)
        return ret
    except Exception as e:
        return e



def get_access_token(api_key, secret_key):
    url = "https://aip.baidubce.com/oauth/2.0/token"
    params = {"grant_type": "client_credentials",
              "client_id": api_key, "client_secret": secret_key}
    return str(requests.post(url, params=params).json().get("access_token"))


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--model", required=True)
    parser.add_argument("--session", default="")
    parser.add_argument("content")
    args = parser.parse_args()

    api_key = os.environ["QIANFAN_APIKEY"]
    secret_key = os.environ["QIANFAN_SECRET"]

    print(chat(api_key, secret_key, args.session, args.content, args.model))
