#!/bin/rdmd

/++
Prints a list of all recent DMD releases

The list consists of the the latest patch release for each minor version.
++/
module list_tags;

import std.algorithm;
import std.array;
import std.conv;
import std.stdio;
import std.regex;
import std.process;

/// Git command that enumerates all tags found in the upstream repository
static immutable string[] gitCmd = ["git", "ls-remote", "--tags", "--exit-code", "https://github.com/dlang/dmd.git"];

/// Prints a list of latest release to stdout
int main(const(string)[] args)
{
    if (args.length > 2)
    {
        stderr.writeln("Usage: list_tags.d <number of releases>?");
        return 1;
    }

    size_t numReleases = 40;

    if (args.length == 2)
    {
        try
            numReleases = to!size_t(args[1]);
        catch (ConvException e)
        {
            stderr.writefln(`Invalid number: "%s"`, args[1]);
            return 1;
        }
    }

    stderr.writefln("Fetching the last %s release tags...", numReleases);

    const result = execute(gitCmd);
    if (result.status)
    {
        stderr.writefln("%-(%s %) failed with exit code %s:\n%s", gitCmd, result.status, result.output);
        return 1;
    }

    result.output
        .matchAll(`refs/tags/v(\d\.\d+(\.\d)?)\s`)    // Find all version numbers vX.YYY.Z
        .map!(m => m[1])                            // Extract from capture object
        .array                                      // git ls-remote should already emit a sorted list
        .sort                                       // but sort explicitly just to be sure
        .splitWhen!((a, b) => a[0..5] != b[0..5])   // Group by major release, e.g. 2.096
        .map!(c => c.fold!((a, b) => b))            // Fetch the last patch release
        .array[$ - min($, numReleases) .. $]        // Truncate to the latest `NUM_RELEASES`
        .map!(r => r < "2.065.0" ? r[0..5] : r)     // Prior releases numbers do not match the tag found in dmd
        .each!writeln;                              // Dump to stdout

    return 0;
}
