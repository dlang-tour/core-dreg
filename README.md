# Docker container for running old versions of D

[![master](https://github.com/dlang-tour/core-dreg/actions/workflows/default.yml/badge.svg)](https://github.com/dlang-tour/core-dreg/actions/workflows/default.yml)

This docker image provides the old versions of the [D](https://dlang.org) compiler.
The container takes source code encoded as **Base64** on the command line and
decodes it internally and passes it to `dreg`. The compiler
tries to compile the source and, if successful, outputs
the program's output. Compiler errors will also be output,
to stderr.

This container is used in the [dlang-tour](https://github.com/dlang-tour/core)
to support online compilation of user code in a safe sandbox.

## Usage

Run the docker container passing the base64 source as command line parameter:

```bash
bsource=$(echo 'void main() { import std.conv; std.stdio; writefln("Hello World, %s", 42.to!int); }' | base64 -w0)
docker run --rm dlangtour/core-dreg $bsource
```

It returns:

```
Up to      2.062  : Failure with output:
-----
onlineapp.d(1): Error: undefined identifier 'to'
onlineapp.d(1): Error: undefined identifier 'to'
-----

Since      2.063  : Success with output: Hello World, 2
```

### Bash aliases

As this Docker images is intended for [run.dlang.io](https://run.dlang.io), it
base64-encodes the input. As this is a bit bulky, for local usage, this wrapper
is recommended.
For example, create this file `dreg` and add it to your `PATH`:

```bash
#!/bin/bash
docker run --rm dlangtour/core-dreg $(echo "$1" | base64 -w0) ${@:2}
```

Usage is as follows:

```
dreg "import std.experimental.allocator;" -c
```

it returns:

```
Up to      2.068.2: Failure with output:
-----
onlineapp.d(1): Error: module allocator is in file 'std/experimental/allocator.d' which cannot be read
import path[0] = /path/to/dmd/dmd2/linux/bin64/../../src/phobos
import path[1] = /path/to/dmd/dmd2/linux/bin64/../../src/druntime/import
-----

Since      2.069.2: Success and no output
```

## Docker image

The docker image gets built after every push to `master` and pushed to [DockerHub](https://hub.docker.com/r/dlang-tour/core-dreg/).

## License

Boost license.
