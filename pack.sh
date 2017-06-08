#!/bin/bash -e

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

NAME=$(cat haxelib.json | jq '.name' -r)
VERSION=$(cat haxelib.json | jq '.version' -r)
TARGET=$NAME-$VERSION.zip

if [ ! -z "$1" ]; then
    if [ "$1" == "--output-name" ]; then
        echo $NAME
    elif [ "$1" == "--output-version" ]; then
        echo $VERSION
    elif [ "$1" == "--output-file" ]; then
        echo $TARGET
    else
        echo "Unknown argument: $1"
        exit 1
    fi
    exit
fi

pushd "$ROOT"

if [ -d "$NAME" ]; then
    rm -rf "$NAME"
fi

if [ -f "$TARGET" ]; then
    rm -rf "$TARGET"
fi

mkdir $NAME

rsync -ravc ./ $NAME/ \
    --exclude '/bin' \
    --exclude '/test' \
    --exclude '/test-data' \
    --exclude '/out' \
    --exclude '/report' \
    --exclude '/.git' \
    --exclude '/.gitignore' \
    --exclude '/.temp' \
    --exclude '/.idea' \
    --exclude '/.vscode' \
    --exclude '/*.iml' \
    --exclude '/.arcconfig' \
    --exclude '/.arclint' \
    --exclude '/checkstyle.json' \
    --exclude '/test-air.xml' \
    --exclude '/*.sh' \
    --exclude '/*.hxml' \
    --exclude "/$NAME"

zip -r $TARGET $NAME

if [ -d "$NAME" ]; then
    rm -rf "$NAME"
fi

popd