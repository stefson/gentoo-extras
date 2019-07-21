# Copyright 2017-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# Auto-Generated by cargo-ebuild 0.1.5

EAPI=7

CRATES="
aho-corasick-0.7.4
ansi_term-0.11.0
argon2rs-0.2.5
arrayvec-0.4.11
atty-0.2.13
autocfg-0.1.5
backtrace-0.3.33
backtrace-sys-0.1.31
bitflags-1.1.0
blake2-rfc-0.2.18
byteorder-1.3.2
capstone-0.5.0
capstone-sys-0.9.1
cc-1.0.37
cfg-if-0.1.9
chrono-0.4.7
clap-2.33.0
cloudabi-0.0.3
cmake-0.1.40
constant_time_eq-0.1.3
cranelift-0.36.0
cranelift-bforest-0.36.0
cranelift-codegen-0.36.0
cranelift-codegen-meta-0.36.0
cranelift-entity-0.36.0
cranelift-faerie-0.36.0
cranelift-frontend-0.36.0
cranelift-module-0.36.0
cranelift-native-0.36.0
cranelift-preopt-0.36.0
cranelift-reader-0.36.0
cranelift-simplejit-0.36.0
cranelift-wasm-0.36.0
dirs-1.0.5
env_logger-0.6.2
errno-0.2.4
errno-dragonfly-0.1.1
faerie-0.10.1
failure-0.1.5
failure_derive-0.1.5
file-per-thread-logger-0.1.2
filecheck-0.4.0
fuchsia-cprng-0.1.1
gcc-0.3.55
glob-0.2.11
goblin-0.0.22
goblin-0.0.23
hashbrown-0.5.0
hashmap_core-0.1.10
heck-0.3.1
humantime-1.2.0
indexmap-1.0.2
itoa-0.4.4
lazy_static-1.3.0
libc-0.2.60
log-0.4.7
mach-0.2.3
memchr-2.2.1
memmap-0.7.0
nodrop-0.1.13
num-integer-0.1.41
num-traits-0.2.8
num_cpus-1.10.1
plain-0.2.3
pretty_env_logger-0.3.0
proc-macro2-0.4.30
quick-error-1.2.2
quote-0.6.13
rand_core-0.3.1
rand_core-0.4.0
rand_os-0.1.3
raw-cpuid-6.1.0
rdrand-0.4.0
redox_syscall-0.1.56
redox_users-0.3.0
regex-1.2.0
regex-syntax-0.6.10
region-2.1.2
rustc-demangle-0.1.15
rustc_version-0.2.3
ryu-1.0.0
scoped_threadpool-0.1.9
scroll-0.9.2
scroll_derive-0.9.5
semver-0.9.0
semver-parser-0.7.0
serde-1.0.97
serde_derive-1.0.97
serde_json-1.0.40
string-interner-0.6.3
strsim-0.8.0
structopt-0.2.18
structopt-derive-0.2.18
syn-0.15.40
synstructure-0.10.2
target-lexicon-0.4.0
term-0.5.2
termcolor-1.0.5
textwrap-0.11.0
thread_local-0.3.6
time-0.1.42
ucd-util-0.1.5
unicode-segmentation-1.3.0
unicode-width-0.1.5
unicode-xid-0.1.0
utf8-ranges-1.0.3
vec_map-0.8.1
wabt-0.7.4
wabt-sys-0.5.4
wasmparser-0.32.1
winapi-0.3.7
winapi-i686-pc-windows-gnu-0.4.0
winapi-util-0.1.2
winapi-x86_64-pc-windows-gnu-0.4.0
wincolor-1.0.1
"

inherit cargo

DESCRIPTION="Binaries for testing the Cranelift libraries"
HOMEPAGE="https://github.com/CraneStation/cranelift"

SRCHASH=e7f2b719eebfb9280c3e38eae42a9ee25221a4e3

SRC_URI="https://github.com/CraneStation/cranelift/archive/${SRCHASH}.tar.gz -> ${P}.tar.gz
	$(cargo_crate_uris ${CRATES})"
RESTRICT="mirror"
LICENSE="apache-2.0-with-llvm-exception"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"

DEPEND=">=virtual/rust-1.35.0"
RDEPEND=""

S="${WORKDIR}"/cranelift-${SRCHASH}

src_configure() {
	# Do nothing
	echo "Configuring cranelift..."
}

src_compile() {
	export CARGO_HOME="${ECARGO_HOME}"
	cargo build -j$(makeopts_jobs) --release || die
}

src_test() {
	RUST_BACKTRACE=1 cargo test --all || die "tests failed"
}

src_install() {
	dobin target/release/clif-util
}

