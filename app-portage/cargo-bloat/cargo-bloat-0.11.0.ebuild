# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	cargo-bloat-0.11.0
	binfarce-0.2.1
	fallible-iterator-0.2.0
	json-0.12.4
	libc-0.2.112
	memmap2-0.5.0
	multimap-0.8.3
	pdb-0.7.0
	pico-args-0.4.2
	regex-1.5.4
	regex-syntax-0.6.25
	scroll-0.10.2
	term_size-0.3.2
	uuid-0.8.2
	winapi-0.3.9
	winapi-i686-pc-windows-gnu-0.4.0
	winapi-x86_64-pc-windows-gnu-0.4.0
"

inherit cargo

DESCRIPTION="Find out what takes most of the space in your executable."
HOMEPAGE="https://github.com/RazrFalcon/cargo-bloat"
SRC_URI="$(cargo_crate_uris)"
LICENSE="Apache-2.0 MIT"
SLOT="0"
KEYWORDS="~amd64"
