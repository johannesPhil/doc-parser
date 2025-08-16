#!/usr/bin/env python3
# tools/token_chunk.py
# Usage: cat file.txt | python3 tools/token_chunk.py <max_tokens> <overlap>
# Example: python3 tools/token_chunk.py 250 50

import sys
import json
from transformers import AutoTokenizer

MODEL = "sentence-transformers/all-MiniLM-L6-v2"

def chunk_text(text, max_tokens=250, overlap=50):
    tokenizer = AutoTokenizer.from_pretrained(MODEL, use_fast=True)
    # encode without special tokens to get raw tokens
    ids = tokenizer.encode(text, add_special_tokens=False)
    chunks = []
    start = 0
    n = 0
    while start < len(ids):
        end = min(start + max_tokens, len(ids))
        chunk_ids = ids[start:end]
        chunk_text = tokenizer.decode(chunk_ids, skip_special_tokens=True, clean_up_tokenization_spaces=True)
        chunks.append(chunk_text)
        n += 1
        if end == len(ids):
            break
        start += max_tokens - overlap
    return chunks

def main():
    args = sys.argv[1:]
    max_tokens = int(args[0]) if len(args) >= 1 else 250
    overlap = int(args[1]) if len(args) >= 2 else 50

    text = sys.stdin.read()
    if not text:
        print(json.dumps([]))
        return

    chunks = chunk_text(text, max_tokens=max_tokens, overlap=overlap)
    print(json.dumps(chunks))

if __name__ == "__main__":
    main()
