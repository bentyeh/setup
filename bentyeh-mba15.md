- [Settings](#settings)
  - [Terminal](#terminal)
- [Software Installation Notes](#software-installation-notes)
  - [Packages installed via Homebrew](#packages-installed-via-homebrew)
  - [LaTeX](#latex)
  - [macOS configurations](#macos-configurations)
  - [Not kept](#not-kept)
    - [fuse-zip](#fuse-zip)
- [Compiling on macOS with Apple Silicon](#compiling-on-macos-with-apple-silicon)
  - [Using GNU C++ toolchain](#using-gnu-c-toolchain)
- [Ideas](#ideas)
  - [Cross-platform encrypted external drive syncing](#cross-platform-encrypted-external-drive-syncing)

# Settings

## Terminal

Additions to `~/.zshrc` and `~/.bashrc`:

```
alias ll='ls -l'
MANPATH="$HOME/local/share/man:$MANPATH"
PATH="/Users/bentyeh/local/bin:$PATH"

# additional lines added by conda init
```

# Software Installation Notes

## Packages installed via Homebrew

Casks
- basictex: see [below](#latex)
- [unnaturalscrollwheels](https://github.com/ther0n/UnnaturalScrollWheels)
  - Command: `brew install --cask unnaturalscrollwheels`

Formulas
- gcc
- graphviz
- libzip
- pandoc
- pkg-config
- sevenzip
- wget

## LaTeX

Install basictex via homebrew: `brew install basictex`
- Update TeX Live package manager (`sudo tlmgr update --self`)
- Update TeX packages (`sudo tlmgr update --all`)
- Install new packages (`sudo tlmgr install enumitem latexmk`)
  - `latexmk` is the LaTeX compiler used by the default build recipe of LaTeX Workshop for VS Code.
- Add build recipes for VS Code LaTeX Workshop: `pdftex * 3`

## macOS configurations

Stop .DS_Store files on removable drives and network stores

On 2024-05-03, ran the following commands:
```
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
defaults write com.apple.desktopservices DSDontWriteNetworkStores true
```

Prior to running this command, the domain `com.apple.desktopservices` did not exist, so to reset the state, run the following:
```
defaults delete com.apple.desktopservices DSDontWriteUSBStores
defaults delete com.apple.desktopservices DSDontWriteNetworkStores
```
or 
```
defaults delete com.apple.desktopservices
```

## Not kept

### fuse-zip

Context: Want to have a sync-able encrypted archive. Specifically, mount an encrypted archive (e.g., zip or 7-zip), then sync via `rsync`, SyncBack, FreeFileSync, etc.

Outcome
- Many compilation warnings (can be bypassed by removing several gcc flags, see below) --> does not inspire confidence in the code/software
  - Concern for potential data loss due to IO caching. See [fuse-t GitHub issue](https://github.com/macos-fuse-t/fuse-t/issues/45) and [cautionary README from similar `archivemount` tool](https://github.com/cybernoid/archivemount)
- fuse-zip does not support encrypted archives

Git repo: https://bitbucket.org/agalanin/fuse-zip
- Version tested: https://bitbucket.org/agalanin/fuse-zip/commits/f9bc474ecaf4b1bae68c4b9e424d344a6b0cfec3
- See also a fork by the author of `fuse-t`: https://github.com/macos-fuse-t/fuse-zip

Dependencies: `libzip`, `libfuse`
- Install `libzip` with homebrew: `brew install libzip`
- Install [`fuse-t`](https://github.com/macos-fuse-t/fuse-t), a drop-in replacement for `libfuse`, with homebrew: `brew install macos-fuse-t/homebrew-cask/fuse-t`

Process
- Install GNU C++ toolchain: `brew install pkg-config gcc`
- Edit Makefile (apply edits to one or both of the Makefiles in the base directory and the `lib/` directory as appropriate)
  1. Set prefix for local install, rather than user/system install: `prefix=/Users/bentyeh/local`
  2. Use `fuse-t` instead of `libfuse`: Change `$(shell $(PKG_CONFIG) fuse --libs)` to `$(shell $(PKG_CONFIG) fuse-t --libs)`
  3. Update gcc flags to avoid warnings: add `-D_FILE_OFFSET_BITS=64`, remove `-Wconversion -Wsign-conversion -Wshadow`
- Compile: `make release CXX=/opt/homebrew/bin/g++-13; make install CXX=/opt/homebrew/bin/g++-13`

Usage: follow README
1. Create mount directory (e.g., via mkdir)
2. `fuse-zip <path_to_archive> <path_to_mount_dir>`
3. Unmount via `umount <path_to_mount_dir>`

# Compiling on macOS with Apple Silicon

## Using GNU C++ toolchain

The default compilers, located at `/usr/bin/gcc` and `/usr/bin/g++`, are Apple clang compilers. (Unclear how these are related to `/Library/Developer/CommandLineTools/usr/bin/gcc` and `/Library/Developer/CommandLineTools/usr/bin/g++`.)

To use GNU compilers, one can install them via conda or homebrew.

homebrew: `brew install gcc`

conda: `conda install clang_osx-arm64 clangxx_osx-arm64 gfortran_osx-arm64`

Whereas `conda activate <env>` sets appropriate environment variables, using gcc installed by homebrew requires manually setting the path via one of several options, described here: https://stackoverflow.com/questions/50076721/set-gcc-path-in-makefile.

# Ideas

## Cross-platform encrypted external drive syncing

Option 1: VeraCrypt
- Format drive as ExFAT
- Either keep multiple platform-specific binaries of Veracrypt on the external drive, or install (or use a portable version of) VeraCrypt on each host system.
- Main downside: requires macFUSE installed on Mac systems

Option 2: Cryptomator
- Essentially identical idea to VeraCrypt, except that Cryptomator does not require a FUSE system.
- Downsides
  - Neither FUSE-T nor WebDAV protocols on Mac properly support date modified timestamps.
  - Slow.

Option 3: Bitlocker + "Bitlocker for Mac"
- Format drive as ExFAT
- Encrypt with Bitlocker on a Windows PC
- Install (paid) software on Mac/Linux that can unlock and provide read/write access to Bitlocker-encrypted drives, such as [UUByte Bitlocker Geeker](https://www.uubyte.com/bitlocker-geeker.html) or [iBoysoft BitLocker for Mac](https://iboysoft.com/bitlocker-for-mac/)

Option 4: Bitlocker + VirtualBox
- Format drive as ExFAT or NTFS
- Either install Windows in VirtualBox on the external drive or on Mac/Linux systems.
- Use Bitlocker either from a Windows PC or Windows in VirtualBox on Mac/Linux systems.

Option 5: 7-Zip Update
- Format drive as ExFAT
- 7-zip's update subcommand can generate differential/incremental archives. See https://nagimov.me/post/simple-differential-and-incremental-backups-using-7-zip/ or https://superuser.com/questions/544336/incremental-backup-with-7zip.
  - However, incremental archives cannot be merged directly into the base archive: https://sourceforge.net/p/sevenzip/discussion/45797/thread/cacbba19/.
- Since 7-zip does not show a diff prior to performing the archive update, roll your own diff solution (e.g., comparing the outputs of 7z l <archive> and ls <folder>).

Option 6: Mount Zip/7-Zip archive
- Format drive as ExFAT
- Mount encrypted archive on host system
- Use platform-agnostic (e.g., FreeFileSync, rsync) or platform-specific (e.g., SyncBack) to sync from host folder to external archive.
- Challenge: could not find no free and reliable tools to mount encrypted archives on Mac

Option 7: git
- Challenge: integrate something like git LFS for large files and git-crypt or git-remote-gcrypt for encryption of the git repository on the external drive.

Option 8: wine + SyncBack
- Install Wine on Mac/Linux, then run SyncBack via Wine
- SyncBack can sync from a host folder directly to an encrypted archive.
- Problem: could not get SyncBack to run via Wine on macOS arm64.

Option 9: rclone
- Format drive as ExFAT
- Create an encrypted remote on the external drive via `rclone crypt`
- rclone can be used to perform syncs via `rclone sync` or `rclone bisync`
- Challenge: `rclone mount` does not work on Mac without FUSE, so instead can use `rclone serve nfs`, but file writing was limited - extended attributes cannot be set.
