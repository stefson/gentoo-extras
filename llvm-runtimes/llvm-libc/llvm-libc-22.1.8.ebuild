# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LLVM_COMPAT=( 22 )

inherit cmake llvm-r1

DESCRIPTION="LLVM's libc implementation (Math overlay components only)"
HOMEPAGE="https://llvm.org"
SRC_URI="https://github.com{PV}/llvm-project-${PV}.src.tar.xz"

LICENSE="Apache-2.0-with-LLVM-exceptions"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

S="${WORKDIR}/llvm-project-${PV}.src/runtimes"

# Target dependencies mapped to the new llvm-runtimes/* category
RDEPEND="
	llvm-runtimes/compiler-rt:${LLVM_COMPAT}
"
DEPEND="${RDEPEND}"

# Host build tools pulled from llvm-core/*, resolved via LLVM_SLOT
BDEPEND="
	$(llvm_gen_dep '
		llvm-core/clang:${LLVM_SLOT}
		llvm-core/lld:${LLVM_SLOT}
	')
"
src_prepare() {
	cmake_src_prepare

	# Fix upstream issue #92337 by ensuring startup_target is always empty.
	# This avoids the missing rule error during install-libc in overlay mode.
	if [[ -f "${WORKDIR}/llvm-project-${PV}.src/libc/lib/CMakeLists.txt" ]]; then
		sed -i 's/set(startup_target "libc-startup")/set(startup_target "")/g' \
			"${WORKDIR}/llvm-project-${PV}.src/libc/lib/CMakeLists.txt" || die
	fi

	# Fix musl compilation failure where 'struct flock64' is an incomplete type.
	# Since musl structures are 64-bit by default, we can safely alias it to 'flock'.
	if [[ -f "${WORKDIR}/llvm-project-${PV}.src/libc/src/__support/OSUtil/linux/fcntl.cpp" ]]; then
		sed -i '1i #define flock64 flock' \
			"${WORKDIR}/llvm-project-${PV}.src/libc/src/__support/OSUtil/linux/fcntl.cpp" || die
	fi
}

src_configure() {
	local mycmakeargs=(
		-DLLVM_ENABLE_RUNTIMES="libc"
		-DCMAKE_C_COMPILER=clang
		-DCMAKE_CXX_COMPILER=clang++
		
		# Overlay mode prevents overwriting your system musl installation
		-DLIBC_BUILD_MODE="overlay"

		# Safe isolated installation path under Gentoo's standard LLVM root
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr/lib/llvm/${LLVM_SLOT}/llvm-libc"
	)
	cmake_src_configure
}

src_compile() {
	cmake_build libc
}

src_install() {
	DESTDIR="${D}" cmake_build install-libc
}
