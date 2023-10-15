#!/usr/bin/env python3
import json

def load_session(session):
    if not session:
        return []
    try:
        with open(session, "r") as f:
            msgs = json.load(f)
            if len(msgs) > 1000:
                msgs = msgs[:1000]
    except Exception:
        msgs = []
    return msgs

def save_session(session, msgs):
    if not session:
        return
    try:
        with open(session, "w") as f:
            json.dump(msgs, f, ensure_ascii=False, indent=4)
    except Exception as e:
        print(e)
        return e
