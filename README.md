# Docker container for running old versions of D

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

	> bsource=$(echo 'void main() { import std.conv; std.stdio; writefln("Hello World, %s", 42.to!int); }' | base64 -w0)
	> docker run --rm dlangtour/core-dreg $bsource

```
Up to      2.062  : Failure with output:
-----
onlineapp.d(1): Error: undefined identifier 'to'
onlineapp.d(1): Error: undefined identifier 'to'
-----

Since      2.063  : Success with output: Hello World, 2
```

## Docker image

The docker image gets built after every push to `master` and pushed to [DockerHub](https://hub.docker.com/r/dlang-tour/core-dreg/).

## License

Boost license.
