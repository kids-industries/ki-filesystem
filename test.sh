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

mkdir -p report/test report/coverage report/emma bin

ERROR=false
declare -a ERROR_TARGETS

function build()
{
	local target=$1
	local log="report/$target.log"
	local testLog="report/test/$target.log"
	local coverageLog="report/coverage/$target.log"
	local emmaXml="report/emma/$target.xml"

	# Ensure the playground doesn't exist
	rm -rf "bin/test-data"

	rm -rf $log $testLog $coverageLog $emmaXml
	if [ $CLEAN == true ]; then
		rm -rf bin/$target
	fi

	echo ""
	echo "-------------------------------------------"
	echo "Compiling and running: $target"
	echo "-------------------------------------------"
	echo ""

	haxe "test-$target.hxml" --each "test-each.hxml" > >(tee -a $log) 2> >(tee -a $log >&2)

	if [ $? != 0 ]; then
		ERROR=true
		ERROR_TARGETS+=("$target")
	fi

	# there is slight lag between tee and writing to the file, sleep a little before continuing
	sleep 2

	sed -n '/%%%RUNNER-START%%%/{:a;n;/%%%RUNNER-END%%%/b;p;ba}' $log > $testLog
	sed -n '/%%%COVERAGE-START%%%/{:a;n;/%%%COVERAGE-END%%%/b;p;ba}' $log > $coverageLog
	sed -n '/%%%EMMA-START%%%/{:a;n;/%%%EMMA-END%%%/b;p;ba}' $log > $emmaXml

	# Delete files if they are empty
	if [ ! -s $testLog ]; then
		rm -f $testLog
	fi
	if [ ! -s $coverageLog ]; then
		rm -f $coverageLog
	fi
	if [ ! -s $emmaXml ]; then
		rm -f $emmaXml
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