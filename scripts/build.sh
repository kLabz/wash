#!/bin/sh

./haxe/haxe build.hxml

python --version

# pip install astunparse
# python -m astunparse
# python ./scripts/postprocess.py

# pip3 install astunparse
# python3.10 -m astunparse
# python3.10 ./scripts/postprocess.py

echo "build cache plz"

