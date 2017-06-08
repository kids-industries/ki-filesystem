#!/usr/bin/env bash

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WHAT=$1
CLEAN=false

if [ -z "$WHAT" ]; then
	WHAT=all
fi

pushd "$ROOT"

if [ "$2" == "clean" ]; then
	CLEAN=true
fi

mkdir -p report bin

ERROR=false
declare -a ERROR_TARGETS

function build()
{
	local target=$1
	local log="report/$target.log"

	# Ensure the playground doesn't exist
	rm -rf "bin/test-data"

	if [ $CLEAN == true ]; then
		rm -rf $log bin/$target
	fi

	echo "############################################################" >> $log

	haxe "test-$target.hxml" > >(tee -a $log) 2> >(tee -a $log >&2)

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