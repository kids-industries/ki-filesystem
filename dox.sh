#!/usr/bin/env bash

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WHAT=$1

if [ -z "$WHAT" ]; then
	WHAT=all
fi

pushd "$ROOT"

rm -rf docs
mkdir -p docs

ERROR=false
declare -a ERROR_TARGETS

VERSION=$(cat haxelib.json | jq '.version' -r)
GIT=$(cat haxelib.json | jq '.url' -r)
GIT_PATH="$(echo $GIT | grep / | cut -d/ -f5-)"
REPO_ID=${GIT_PATH%/*}
SOURCE_PATH="https://phabricator.kidsindustries.com/diffusion/$REPO_ID/browse/master/src/"

function build()
{
	local target=$1

	haxe "test-$target.hxml" \
		-xml "docs/$target.xml" \
		--each "dox-each.hxml"

	if [ $? != 0 ]; then
		ERROR=true
		ERROR_TARGETS+=("$target")
	fi
}

if [ $WHAT != "all" ]; then
	build $WHAT
else
	FILES=test-*.hxml
	for FILE in $FILES; do
		if [ $FILE != "test-each.hxml" ]; then
			TARGET=${FILE%.hxml*}
			TARGET=${TARGET#*test-}
			build $TARGET
		fi
	done
fi

# https://github.com/HaxeFoundation/dox/wiki/Commandline-arguments-overview
haxelib run dox \
	--input-path docs \
	--output-path docs/pages \
	--include filesystem \
	--define version "$VERSION" \
	--define source-path "$SOURCE_PATH"

popd

if [ $ERROR == true ]; then
	echo "-------------------------------------------"
	echo "-------------------------------------------"
	echo "The follow targets failed:"

	for T in "${ERROR_TARGETS[@]}"; do
	   echo " - $T"
	done

	echo "-------------------------------------------"
	echo "-------------------------------------------"
	exit 1
fi