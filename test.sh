#!/usr/bin/env bash

WHAT=$1

if [ -z "$WHAT" ]; then
	WHAT=all
fi

haxe "test-$WHAT.hxml"