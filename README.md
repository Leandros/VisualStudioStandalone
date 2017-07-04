# MSVC Standalone

Create a portable Visual Studio distribution from your current installation.

# Why?

Installing Visual Studio takes time, requires explicit user interaction and is
very hard to automate. By bundling the compiler with your source, you can remove
the need of requiring stateful installations of software on computers you wish to build.
This process is often called "vendorization".

It can be useful for many cases, one major of them being CI. Your CI sytem now doesn't
require any special treatment, since your build can run on any clean Windows installation.

Another case is in development of big systems, for example game engines. If all you
need for building your engine is inside your repository, creating reproducible builds
becomes a lot easier. You want to upgrade your toolchain from VS 2015 to 2017? No problem,
your whole studio does not have to reinstall everything on their computers, it's only
required to update the binaries in your repository.

# What?

The `vs2017.bat` script will find your Visual Studio 2017 installation and copy
all the required files to use just the compiler and libraries to the first argument
specified.
This folder can now be used and included wherever you like.

# Usage

Simply open a shell (`cmd.exe`) and execute the `vs2017.bat` script.

It takes a single argument, which is the target directory where to create the portable
distribution.

```
$ .\vs2017.bat portableVS
```

# Configuration

Currently the distribution excludes all `HostX86` files, since there is a clear
advantage of using the x64 compiler as opposed to the x86, if you still would
like to use it, you can go into the `vs2017.bat` script and uncomment the section
creating the x86 distribution.

# TODO

- [ ] Add VS2015 script
- [ ] Add tests

# Contribution

**All contributions welcome!**

# License

Licensed under the MIT License.

Copyright (c) 2017 Arvid Gerstmann

