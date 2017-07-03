# MSVC Standalone

Create a portable Visual Studio distribution from your current installation.

# Usage

Simply open a shell (`cmd.exe`) and execute the `vs2017.bat` script.

It takes a single argument, which is the target directory where to create the portable
distribution.

```
$ .\vs2017.bat portableVS
```

# Configuration

Currently the distribution excludes all `HostX64` files, since there is currently
no clear advantage of using the compiler compiled as native x64, if you still would
like to use it, you can go into the `vs2017.bat` script and uncomment the section
creating the x64 distribution.

# TODO

- [ ] Add VS2015 script
- [ ] Add tests

# Contribution

**All contributions welcome!**

# License

Licensed under the MIT License.

Copyright (c) 2017 Arvid Gerstmann

