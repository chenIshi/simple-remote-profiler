# simple-remote-profiler
A simple profiler with little system dependency using remote gdb.

> This work is basically a modified verion of [poor man's profiler](https://poormansprofiler.org/).

## Motivation
TL;DR: if your test program can run a normal environment with stable OS, then skip this. This tools is a work-around for low-level development.

When it comes to profiling tools, there are already rich enough supports to meet various kind of requirements.
However, in our current use case, we have only very, extremely limited inforation or tools within our reach.
When developing [asterinas](https://github.com/asterinas/asterinas), a Rust based kernel, apparently we have no support from 
any user-space tools.
Also, at the current time being, the `perf` subsystem is still not yet there. Even if it is there, we still need a profiler 
for the `perf` system as well.

Basically, we want to avoid any unnecessary dependency, and try to get a sense on where to optimize.
The original profiler without remote gdb should already suffice the need for minimum tool dependency.
However, in our case *asterinas* is running on a virtual machine so we need to use a remote gdb to do so.
