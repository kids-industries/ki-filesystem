# KI-filesystem

A simple library that abstracts common file operations.

## Supported Targets / Runtimes

- Adobe AIR (requires `-D air`)
- CPP
- C#
- Java
- Macro
- Neko
- NodeJS
- OpenFL (automatic remap of package `flash` to `openfl` when using `ByteArray`)
- PhantomJS (requires `-D phantomjs` and `-lib phantomjs`)
- PHP
- Python

## Partial or Unknown Support

- HashLink (unable to get runtime working)
- Lua (partial - some failed tests)

## Sample Usage

Add these for best usage.

```haxe

import filesystem.File;

// Adds candy I/O (read/write/append) extension methods onto File
using filesystem.FileTools;

```

```haxe

// Create a file instance
var file = new File('some.txt');

// Write simple string contents into the file
file.writeString('My awesome file contents!');

// Read string contents into local variable
var contents = file.readString();

trace(contents); 

```