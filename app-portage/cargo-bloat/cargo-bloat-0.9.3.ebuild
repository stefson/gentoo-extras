# Copyright 2017-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CRATES="
cargo-bloat-0.9.3
json-0.12.4
kernel32-sys-0.2.2
libc-0.2.68
memmap2-0.1.0
multimap-0.8.1
pico-args-0.3.1
regex-1.3.6
regex-syntax-0.6.17
term_size-0.3.1
winapi-0.2.8
winapi-build-0.1.1
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
