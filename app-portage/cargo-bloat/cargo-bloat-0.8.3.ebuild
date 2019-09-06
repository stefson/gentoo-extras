# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

CRATES="
aho-corasick-0.7.6
cargo-bloat-0.8.3
json-0.11.15
kernel32-sys-0.2.2
lazy_static-1.3.0
libc-0.2.61
memchr-2.2.1
memmap-0.7.0
multimap-0.5.0
pico-args-0.2.0
redox_syscall-0.1.56
regex-1.2.1
regex-syntax-0.6.11
term_size-0.3.1
thread_local-0.3.6
time-0.1.42
winapi-0.2.8
winapi-0.3.7
winapi-build-0.1.1
winapi-i686-pc-windows-gnu-0.4.0
winapi-x86_64-pc-windows-gnu-0.4.0
"

inherit cargo

DESCRIPTION="Find out what takes most of the space in your executable."
HOMEPAGE="https://github.com/RazrFalcon/cargo-bloat"
SRC_URI="$(cargo_crate_uris ${CRATES})"
RESTRICT="mirror"
LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=""
RDEPEND=""

src_install() {
	cargo install --path . -j $(makeopts_jobs) --root="${D}/usr" $(usex debug --debug "") \
		|| die "cargo install failed"
	rm -f "${D}/usr/.crates.toml"
}
