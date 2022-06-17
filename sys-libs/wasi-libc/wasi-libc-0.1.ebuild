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

DEPEND="
	sys-devel/llvm:14
	sys-devel/clang:14
"

src_prepare () {

	default
	
	export WASM_CC="/usr/lib/llvm/14/bin/clang"
	export WASM_AR="/usr/lib/llvm/14/bin/llvm-ar"
	export WASM_NM="/usr/lib/llvm/14/bin/llvm-nm"
		
	# Remove bulk memory support
	# https://bugzilla.mozilla.org/show_bug.cgi?id=1773200#c4
	export BULK_MEMORY_SOURCES=
    	
}

src_compile () {

	emake 

}

src_install () {

	cp -r "${S}"/sys-root/

}
