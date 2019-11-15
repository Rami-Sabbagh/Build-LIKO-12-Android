# LIKO-12 Build-Templates

![Build Status](https://github.com/LIKO-12/Build-Templates/workflows/Build%20Templates/badge.svg)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/LIKO-12/Build-Templates?label=Release)
![GitHub All Releases](https://img.shields.io/github/downloads/LIKO-12/Build-Templates/total?label=Downloads)
![Licnse MIT](https://img.shields.io/github/license/LIKO-12/Build-Templates?label=License)
![GitHub stars](https://img.shields.io/github/stars/LIKO-12/Build-Templates?style=social)

This repository generates the build templates for LIKO-12 using Github Actions.

It downloads LÖVE binaries, and patches them, then re-upload them into Github Releases of this repository.

## Templates Platforms

Currently it makes tamplates for Windows (x86_64 and i686), Linux (x86_64 AppImage), macOS and Android (arm64 and armeabiv7).

## Applied Patches

### Windows (x86_64, i686)

- Replaced `love.exe` and `lovec.exe` icons with LIKO-12's icon.
- Replaced `love.exe` and `lovec.exe` manifest with LIKO-12's manifest.
- Added in `lua-sec 0.8.1` and `openssl 1.1.1d` dlls (Compiled by @RamiLego4Game).
- Renamed `license.txt` into `LOVE-license.txt`.
- Added `LIKO-12-license.txt`.

### Linux (x86_64)

- Replaced `love.svg` with LIKO-12 png icon stored in a `.svg` (For scaling support).
- Changed the application name & command and removed mime-type in `love.desktop` (By replacing the whole file).
- Added in `LIKO-12-license.txt`.

### macOS

- Replaced `OS X Application.icns` and `GameIcon.icns` with LIKO-12's icon converted using an online website.
- Patched `Info.plist` to change the application name and id, and removed the exports section.
- Renamed `license.txt` into `LOVE-license.txt`.
- Added `LIKO-12-license.txt`.

### Android (arm64 and armeabiv7)

- Injected LIKO-12's icon, Activity and manifest.
- Injected OpenSSL and LuaSec.
- Patched `build.gradle` to change applicationId, VersionCode and VersionName.
- Injected OpenSSL and LuaSec into `love/src/jni/love/Android.mk`.
- Patched `love/src/jni/love/src/common/config.h` to enable LuaSec.
- Injected LuaSec into `love/src/jni/love/src/modules/love/love.cpp`.

## Updating LÖVE version

> Usually the build system doesn't need any modifications for new LÖVE versions, but if some restructuring had been made into LÖVE, the build system would get broken and need inspection and manual update...

- Change the value in `LOVE_VERSION.txt`
- Wait to see if the Github Actions build goes well.
- If it worked, publish a new release

## Publishing new release

- Create a new tag using `git tag TAGNAME`, make it follow semver and don't prefix it with `v`.
- Push the new tag using `git push --tags`.
- Wait for GitHub Actions to finish, their should be a new published release if everything went well.

## Reverting a release (Usually done incase of build failure)

- Delete the Github release if present.
- Delete the tag from Github using `git push --delete origin TAGNAME`.
- Delete the local tag using `git tag --delete TAGNAME`.

## When to change MAJOR, MINOR and PATCH of the templates version

- Change PATCH whenever any minor changes made into the templates, like updating the year number in `LIKO-12-license.txt`.
- Change MINOR whenever LÖVE version is changed, or the included libraries are changed/update.
- Change MAJOR when the templates struction is changed causing other build system replying on those templates to fail.

## Build Templates workflow overview

The `Build Templates` workflow is triggered whenever a new commit is pushed, and consist of 4 jobs:

#### Windows

Creates the build templates for Windows machines, it runs on a Windows machine due to `Resource Hacker` not being available but only on Windows, it uploads the generated build templates as artifacts.

#### Linux

Creates the build template for Linux machines, it runs on a linux machine and uses Lua scripts for generating the builds, it uplaods the generated build templates as artifacts.

#### macOS

Creates the build templates for macOS machines, it runs on a linux machine and uses a Lua script for patching a file during the process, it uploads the generated build templates as artifcats.

#### Android

Creates the build templates for Android devices, it runs on a linux machine and uses a Lua scripts for injecting in LuaSec into LÖVE's sourcecode and changing the package name.

It downloads and installs all the development tools required to compile LÖVE for Android.

> Those 4 jobs run in parallel.

#### Upload into GitHub Releases

This is the final job, it uses Lua scripts and some third-party tools to do it's job, it runs on a linux machine and waits for the previous 3 jobs to finish successfully inorder to run.

It downloads all the build templates artifacts, and compresses the Windows ones into `.zip`s.

Internally the Lua script terminates the execution with success if the build was running on non-tagged commit.

If running on a tagged commit it creates a new public release and uploads the build templates into it.

> _Document written by Rami Sabbagh (RamiLego4Game) at 2019-09-26, last updated at 2019-10-20._
