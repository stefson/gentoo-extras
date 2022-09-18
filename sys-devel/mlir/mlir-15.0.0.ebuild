# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CMAKE_ECLASS=cmake

inherit cmake-multilib llvm llvm.org

DESCRIPTION="Multi-Level IR Compiler Framework for LLVM"
HOMEPAGE="https://mlir.llvm.org/"

LICENSE="Apache-2.0-with-LLVM-exceptions UoI-NCSA MIT"
SLOT="14"
KEYWORDS="~amd64"
IUSE="test"

RDEPEND="~sys-devel/llvm-${PV}"
DEPEND="${RDEPEND}"
BDEPEND="
	sys-devel/llvm:15=[${MULTILIB_USEDEP}]
	sys-devel/clang:15=[${MULTILIB_USEDEP}]
	sys-devel/lld
"
RDEPEND="${DEPEND}"
RESTRICT="!test? ( test )"

LLVM_MAX_SLOT=15
LLVM_COMPONENTS=( mlir cmake )
llvm.org_set_globals

multilib_src_configure() {
	local mycmakeargs=(
		-GNinja
		-DCMAKE_BUILD_TYPE=Release
		-DCMAKE_INSTALL_PREFIX="${BROOT}/usr/lib/llvm/${SLOT}"
		-DBUILD_SHARED_LIBS:BOOL=ON
		-DLLVM_LINK_LLVM_DYLIB:BOOL=ON
		-DCMAKE_PREFIX_PATH="${BROOT}/usr/lib/llvm/${SLOT}/$(get_libdir)/cmake/llvm/"
		-DLLVM_LINK_LLVM_DYLIB=ON
		-DLLVM_BUILD_LLVM_DYLIB=ON
		-DMLIR_LINK_MLIR_DYLIB=ON
		-DLLVM_BUILD_TOOLS=ON
		-DLLVM_BUILD_UTILS=ON
		-DLLVM_ENABLE_PIC=ON
		-DMLIR_INCLUDE_TESTS=$(usex test)
		-Wno-dev
	)
	cmake_src_configure
}
