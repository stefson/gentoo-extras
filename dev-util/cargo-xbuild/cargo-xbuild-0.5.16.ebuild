# Copyright 2017-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# Auto-Generated by cargo-ebuild 0.1.5

EAPI=6

CRATES="
backtrace-0.3.37
backtrace-sys-0.1.31
cargo-xbuild-0.5.16
cargo_metadata-0.5.8
cc-1.0.45
cfg-if-0.1.9
error-chain-0.11.0
error-chain-0.7.2
fs2-0.4.3
fuchsia-cprng-0.1.1
itoa-0.4.4
kernel32-sys-0.2.2
lazy_static-0.2.11
libc-0.2.62
owning_ref-0.2.4
parking_lot-0.3.8
parking_lot_core-0.2.14
proc-macro2-1.0.3
quote-1.0.2
rand-0.4.6
rand_core-0.3.1
rand_core-0.4.2
rdrand-0.4.0
redox_syscall-0.1.56
remove_dir_all-0.5.2
rustc-demangle-0.1.16
rustc-serialize-0.3.24
rustc_version-0.1.7
ryu-1.0.0
same-file-0.1.3
semver-0.1.20
semver-0.9.0
semver-parser-0.7.0
serde-1.0.100
serde_derive-1.0.100
serde_json-1.0.40
smallvec-0.6.10
syn-1.0.5
tempdir-0.3.7
thread-id-3.3.0
toml-0.2.1
unicode-xid-0.2.0
walkdir-1.0.7
winapi-0.2.8
winapi-0.3.8
winapi-build-0.1.1
winapi-i686-pc-windows-gnu-0.4.0
winapi-x86_64-pc-windows-gnu-0.4.0
"

inherit cargo

DESCRIPTION="Automatically cross-compiles the sysroot crates core, compiler_builtins, and alloc."
HOMEPAGE="https://github.com/rust-osdev/cargo-xbuild"
SRC_URI="$(cargo_crate_uris ${CRATES})"
RESTRICT="mirror"
LICENSE="MIT OR Apache-2.0" # Update to proper Gentoo format
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND=""
