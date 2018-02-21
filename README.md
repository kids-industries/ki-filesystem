# KI-filesystem

A simple library that abstracts common file operations such as:

- Checking existence
- Recursive copy/delete
- Recursive directory listings
- Moving/Renaming
- Read/Write/Append
- See API docs for more

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

## Install

### From haxelib for Production

```
haxelib install ki-filesystem

```

### From git for Development

```
# Clone repo
git clone <repo-uri>

# Step into repo
cd ki-filesystem

# Activate haxelib dev mode
haxelib dev ki-filesystem $(pwd)

# Deactivate haxelib dev mode
haxelib dev ki-filesystem

```

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

trace(file.exists); // false

// Write simple string contents into the file
file.writeString('My awesome file contents!');

trace(file.exists); // true
trace(file.readString()); // My awesome file contents!

file.delete();

trace(file.exists); // false

```

## API Docs

View the latest: https://www.kidsindustries.com/open-source/ki-filesystem/latest/docs/index.html

Or replace `/latest/` -> `/1.1.3/` in the url to view a specific version.