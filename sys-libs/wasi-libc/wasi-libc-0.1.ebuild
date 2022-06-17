# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit llvm

DESCRIPTION="WASI libc implementation for WebAssembly"
HOMEPAGE="https://github.com/WebAssembly/wasi-libc"

#if [[ ${PV} == *_p* ]] ; then
	MY_COMMIT="30094b6ed05f19cee102115215863d185f2db4f0"
	SRC_URI="https://github.com/WebAssembly/wasi-libc/archive/${MY_COMMIT}.tar.gz -> ${P}.tar.gz"

	S="${WORKDIR}"/${PN}-${MY_COMMIT}
#elif
#fi	
LICENSE=""
SLOT="0"
KEYWORDS=""
#IUSE=""

DEPEND="
	sys-devel/llvm
	sys-devel/clang
"

src_prepare () {

	default
	
	export WASM_CC=/usr/bin/clang
	export WASM_AR=/usr/bin/llvm-ar
	export WASM_NM=/usr/bin/llvm-nm
		
	# Remove bulk memory support
	# https://bugzilla.mozilla.org/show_bug.cgi?id=1773200#c4
	export BULK_MEMORY_SOURCES=
    	
}
