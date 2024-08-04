# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..13} )
inherit cmake python-any-r1

DESCRIPTION="LLVM/CLANG/LLD based mingw64-toolchain"
HOMEPAGE="https://github.com/mstorsjo/llvm-mingw"

SRC_URI=""

LICENSE="ISC"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="${PYTHON_DEPS}"
RDEPEND="
	sys-libs/zlib:0=
	>=dev-libs/libffi-3.4.2-r1:0=
"
BDEPEND="dev-util/cmake
	sys-devel/gnuconfig
"

src_prepare() {
	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-Wno-dev
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr/lib/llvm/dxc"
		-DLLVM_BUILD_DOCS=0
		-DLLVM_BUILD_TOOLS=0
		-DSPIRV_BUILD_TESTS=0
		-DBUILD_SHARED_LIBS=OFF
		-DLLVM_VERSION_SUFFIX=dxc
	)
	cmake_src_configure
}
