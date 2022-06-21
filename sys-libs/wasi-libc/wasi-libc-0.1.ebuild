# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit llvm

DESCRIPTION="WASI libc implementation for WebAssembly"
HOMEPAGE="https://github.com/WebAssembly/wasi-libc"

MY_COMMIT="30094b6ed05f19cee102115215863d185f2db4f0"
SRC_URI="https://github.com/WebAssembly/wasi-libc/archive/${MY_COMMIT}.tar.gz -> ${P}.tar.gz"

S="${WORKDIR}"/${PN}-${MY_COMMIT}

LICENSE="Apache-2.0 Apache-2.0-with-LLVM-exceptions MIT"
SLOT="0"

KEYWORDS=""

#IUSE=""

BDEPEND="
	sys-devel/llvm:14
	sys-devel/clang:14
"

src_prepare () {
	default

}

src_compile() {

	SYSROOT="S{S}"

	emake CC="clang" \
	AR="llvm-ar" \
	NM="llvm-nm"
}

