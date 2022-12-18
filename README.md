pkgforge
=========

[![Gem Version](https://img.shields.io/gem/v/pkgforge.svg)](https://rubygems.org/gems/pkgforge)
[![GitHub Workflow Status](https://img.shields.io/actions/github/workflow/status/akerl/pkgforge/build.yml?branch=main)](https://github.com/akerl/pkgforge/actions)
[![MIT Licensed](https://img.shields.io/badge/license-MIT-green.svg)](https://tldrlegal.com/license/mit-license)

DSL engine for building Arch packages

## Usage

### Running pkgforge

If you already have a .pkgforge file you want to run, the `pkgforge` tool has 3 subcommands:

```
❯ pkgforge
pkgforge 0.20.0 -- DSL engine for building Arch packages

Usage:

  pkgforge <subcommand> [options]

Options:
        -h, --help         Show this message
        -v, --version      Print the name and version
        -t, --trace        Show the full backtrace when an error occurs

Subcommands:
  build                 Build the package
  release               Release the package
  info                  Print package info
```

Each subcommand has help text that can be invoked w/ the `-h` flag detailing available options. Specific options of note:

* `-d DIR` -- Change to this directory before starting
* `-s` -- Don't clean up anything afterwards. Very useful for troubleshooting
* `-t` -- Enable tracebacks, so you can debug pkgforge internal errors

#### Standard flow

Generally, you'll want to run `pkgforge build` to confirm building works, and then `pkgforge release` to upload the package to GitHub. Releasing will use the tag on the current revision as the GitHub release name.

To avoid building the package twice (since build and release don't default to sharing state), you can use the `--statefile /path/to/file` option. This will cause the two commands to share state, so building builds an artifact and release updates that same artifact.

### Writing .pkgforge files

The pkgforge spec has a couple of required elements and then several optional ones. The file is parsed as Ruby, so Ruby syntax applies for strings and similar, and additionally for advanced use cases you can write arbitrary Ruby at any point.

Before we start, here's an example complete .pkgforge for `git`:

```
name 'git'
org 'amylum'

licenses 'COPYING'

deps(
  zlib: {
    version: '1.2.11-1',
    checksum: '5596e2d39ef98e2323ac415f50afa71a433ed65c23e8d1f2723f711f5ffb4f32'
  },
  openssl: {
    version: '1.1.0g-1',
    checksum: 'f70d94ca94f05be4a14438cf29ed4695d9731d023a4b72d30126d826720bc48b'
  },
  curl: {
    version: '7.57.0-1',
    checksum: 'ea8db25223edddd2668d4f25f8a030469aa90306b1204cc1cecf64d468cb2949'
  }
)

cflags
harden

build do
  run(['make', 'all', 'install',
    'CC=musl-gcc',
    "DESTDIR=#{releasedir}",
    "CURL_LIBCURL=#{@forge.dep(:curl)}/usr/lib/libcurl.a #{@forge.dep(:openssl)}/usr/lib/libssl.a #{@forge.dep(:openssl)}/usr/lib/libcrypto.a",
    "CFLAGS=#{@forge.cflags.join(' ')}",
    "LDFLAGS=#{@forge.cflags.join(' ')}",
    'NO_TCLTK=1',
    'NO_PYTHON=1',
    'NO_EXPAT=1',
    'NO_GETTEXT=1',
    'NO_REGEX=1',
    'prefix=/usr',
    'gitexecdir=/usr/lib/git-core'
  ])
end

test do
  run 'git --version'
end
```

#### name (required)

The name of the package, provided as a string

#### org (required)

The GitHub organization to upload the package to (this plus the name become the GitHub repo slug, as in `https://github.com/ORG/NAME`)

#### license (optional)

This defines where to find the license file. The default is to look for a file called 'LICENSE' in the source directory. This can be provided as a string or an array of strings (for multiple license files). If the given license does not exist, that is a fatal error during build.

#### source (optional)

The source block describes how to load the source of the upstream package. The default is "git" with a path of "./upstream". The available options:

##### git

Loads the source from a local git submodule. Accepts a single argument, "path", which defines the path to the submodule, relative to the repo base dir:

```
source(
  type: 'git',
  path: 'my_sub_dir'
)
```

##### tar

Loads the source from a remote tarball. Requires a "url" argument and a "checksum":

```
source(
  type: 'tar',
  url: 'https://invisible-mirror.net/archives/ncurses/current/ncurses-6.0-20171223.tgz',
  checksum: 'd0e2261c84f3fc56c13ebbc297a4b19fd6c9634fabd2143f88781b405ffe7698'
)
```

#### empty

This sets up a blank source dir. Useful if you'll be generating all the contents, as in [this example](https://github.com/amylum/iana-etc/blob/master/.pkgforge)

```
source(type: 'empty')
```

#### deps (optional)

The deps parameter is an hash of dep objects, each of which contains a version and checksum. Deps are expected themselves to be pkgforge-built GitHub release artifacts and exist in the same org as this package. They are described by a version number and checksum.

```
deps(
  zlib: {
    version: '1.2.11-1',
    checksum: '5596e2d39ef98e2323ac415f50afa71a433ed65c23e8d1f2723f711f5ffb4f32'
  },
  openssl: {
    version: '1.1.0g-1',
    checksum: 'f70d94ca94f05be4a14438cf29ed4695d9731d023a4b72d30126d826720bc48b'
  },
  curl: {
    version: '7.57.0-1',
    checksum: 'ea8db25223edddd2668d4f25f8a030469aa90306b1204cc1cecf64d468cb2949'
  }
)
```

#### configure_flags (optional)

This lets you set flags that will be used if you run `configure` while building. They are specified as a hash, where the keys are the configure flag names without leading "--". A value of "nil" adds the flag without a value.

```
configure_flags(
  prefix: '/usr',
  'with-termlib': 'tinfo',
  'with-ticlib': 'tic',
  'with-shared': nil,
  'with-normal': nil,
  'without-cxx': nil,
  'without-cxx-binding': nil,
  'enable-widec': nil
)
```

#### cflags (optional)

When called with no value, this auto-adds `-L /path/to/dep/lib -I /path/to/dep/include` to the CFLAGS variable used for build commands for every dep specified in the .pkgforge file. When called with a an array of strings, it adds those strings to the CFLAGS variable. It can be called multiple times.

```
cflags
cflags ['-Wa,--noexecstack']
```

#### libs (optional)

When called with no value, auto-adds `-lNAME` for every dep listed in the .pkgforge file to the LIBS variable that will be used for build commands. When called with an array of strings, adds those values to LIBS variable. Do not prefix with "-l" when calling with strings.

```
libs %w(gpg-error assuan)
```

#### remove_linker_archives (optional)

If called, this removes all .la files from deps. This exists because sometimes those files interfere with building.

#### remove_pkgconfig_files (optional)

If called, this removes all .pc files from deps. This exists because sometimes those files interfere with building.

#### harden (optional)

This adds a stock set of hardening options to CFLAGS. The list was originally sourced from [this blog](https://blog.mayflower.de/5800-Hardening-Compiler-Flags-for-NixOS.html), and can be seen [here](https://github.com/akerl/pkgforge/blob/master/lib/pkgforge/components/cflags.rb#L40). Passing an array of strings as arguments disables the listed options from the ALL_HARDEN_OPTS hash.

#### patch (optional)

This patches the source with the given patch files. Files must be stored in the `./patches` dir in the repo, and listed by name without the `./patches` prefix. This command can be used multiple times, and patches will be run in the order they are listed.

```
patch 'musl.patch'
patch 'elf.patch'
patch 'if_arp.patch'
```

#### package (optional)

This describes how to package the resulting build artifact. The default is to use "tarball"

##### tarball

This bundles the whole release dir into a .tar.gz file

##### file

This uploads individual files as listed. The "source" is where inside the release dir to find the file, the "name" is the name to give the artifact.

```
package(
  type: 'file',
  artifacts: [
    {
      source: 'bin/speculate_darwin',
      name: 'speculate_darwin'
    },
    {
      source: 'bin/speculate_linux',
      name: 'speculate_linux'
    }
  ]
)
```

#### test (required)

The test block describes how to check that the build works. It is run after building, from the context of the newly created release's directory. Available helper commands:

* `run` -- Runs a command with the environment adjusted to use only this package's libs and the libs of your named deps.

#### build (required)

The build command describes how to actually turn the source into a package. It has a number of helper commands:

* `run` -- runs a command from the build directory. Takes a string or array of strings
* `configure` -- runs `./configure` with any given configure_flags, CFLAGS, and LIBs, as well as with the CC set to musl-gcc. If you have other env vars to set, pass them as a hash
* `make` -- runs `make` with the CFLAGS / LIBS / CC set similarly to ./configure. Again, if you have extra env vars, pass them as a hash.
* `install` -- runs `make DESTDIR=#{releasedir} install` with the same CFLAGS / LIBS / CC as make. Again, env vars can be passed as a hash.
* `rm` -- Remove a file from the release dir. Useful for cleaning up extra files. Accepts a string or array of strings
* `cp` -- Copies a file from the build dir to the release dir. Pass just the source path to copy to the same dest path, or pass source and dest to copy to a new path.

There are also a handful of variables / helper functions for looking up info:

* `releasedir` -- resolves to the release dir's absolute path
* `dep(PACKAGE)` -- resolves to that dep's absolute path
* `default_env` -- the CC, CFLAGS, and LIBS vars used by the helper commands.

## Installation

    gem install pkgforge

## License

pkgforge is released under the MIT License. See the bundled LICENSE file for details.

