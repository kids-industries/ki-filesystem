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

rsync -ravc ./src $NAME/
rsync -avc ./haxelib.json $NAME/
rsync -avc ./README.md $NAME/
rsync -avc ./CHANGELOG.md $NAME/
rsync -avc ./LICENSE.md $NAME/

cd "$NAME"
zip -r ../$TARGET ./
cd ..

if [ -d "$NAME" ]; then
    rm -rf "$NAME"
fi

popd