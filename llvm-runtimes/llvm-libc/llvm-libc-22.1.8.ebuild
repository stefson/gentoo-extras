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
	if [[ -f "${WORKDIR}/llvm-project-${PV}.src/libc/lib/CMakeLists.txt" ]]; then
		sed -i 's/set(startup_target "libc-startup")/set(startup_target "")/g' \
			"${WORKDIR}/llvm-project-${PV}.src/libc/lib/CMakeLists.txt" || die
	fi

	# Fix musl compilation failure where 'struct flock64' is an incomplete type.
	if [[ -f "${WORKDIR}/llvm-project-${PV}.src/libc/src/__support/OSUtil/linux/fcntl.cpp" ]]; then
		sed -i '1i #define flock64 flock' \
			"${WORKDIR}/llvm-project-${PV}.src/libc/src/__support/OSUtil/linux/fcntl.cpp" || die
	fi

	# Fix musl compilation failure caused by global scope resolution of ::stdout in vprintf.cpp
	if [[ -f "${WORKDIR}/llvm-project-${PV}.src/libc/src/stdio/generic/vprintf.cpp" ]]; then
		sed -i 's/#define PRINTF_STDOUT ::stdout/#if defined(__musl__) || !defined(__GLIBC__)\n#define PRINTF_STDOUT stdout\n#else\n#define PRINTF_STDOUT ::stdout\n#endif/g' \
			"${WORKDIR}/llvm-project-${PV}.src/libc/src/stdio/generic/vprintf.cpp" || die
	fi

	# Fix musl compilation failure caused by global scope resolution of ::stdout in printf.cpp
	if [[ -f "${WORKDIR}/llvm-project-${PV}.src/libc/src/stdio/generic/printf.cpp" ]]; then
		sed -i 's/#define PRINTF_STDOUT ::stdout/#if defined(__musl__) || !defined(__GLIBC__)\n#define PRINTF_STDOUT stdout\n#else\n#define PRINTF_STDOUT ::stdout\n#endif/g' \
			"${WORKDIR}/llvm-project-${PV}.src/libc/src/stdio/generic/printf.cpp" || die
	fi

	# Fix musl compilation failure caused by global scope resolution of ::stdin in vscanf.cpp
	if [[ -f "${WORKDIR}/llvm-project-${PV}.src/libc/src/stdio/generic/vscanf.cpp" ]]; then
		sed -i 's/#define SCANF_STDIN ::stdin/#if defined(__musl__) || !defined(__GLIBC__)\n#define SCANF_STDIN stdin\n#else\n#define SCANF_STDIN ::stdin\n#endif/g' \
			"${WORKDIR}/llvm-project-${PV}.src/libc/src/stdio/generic/vscanf.cpp" || die
	fi

	# Fix musl compilation failure caused by global scope resolution of ::stdin in scanf.cpp
	if [[ -f "${WORKDIR}/llvm-project-${PV}.src/libc/src/stdio/generic/scanf.cpp" ]]; then
		sed -i 's/#define SCANF_STDIN ::stdin/#if defined(__musl__) || !defined(__GLIBC__)\n#define SCANF_STDIN stdin\n#else\n#define SCANF_STDIN ::stdin\n#endif/g' \
			"${WORKDIR}/llvm-project-${PV}.src/libc/src/stdio/generic/scanf.cpp" || die
	fi

	# Fix termios speed fields (c_ospeed / c_ispeed) for musl in individual files
	if [[ -f "${WORKDIR}/llvm-project-${PV}.src/libc/src/termios/linux/cfsetospeed.cpp" ]]; then
		sed -i 's/t->c_ospeed = speed;/\/\/ Removed for musl compat/g' \
			"${WORKDIR}/llvm-project-${PV}.src/libc/src/termios/linux/cfsetospeed.cpp" || die
	fi

	if [[ -f "${WORKDIR}/llvm-project-${PV}.src/libc/src/termios/linux/cfsetispeed.cpp" ]]; then
		sed -i 's/t->c_ispeed = speed;/\/\/ Removed for musl compat/g' \
			"${WORKDIR}/llvm-project-${PV}.src/libc/src/termios/linux/cfsetispeed.cpp" || die
	fi

	if [[ -f "${WORKDIR}/llvm-project-${PV}.src/libc/src/termios/linux/tcgetattr.cpp" ]]; then
		sed -i 's/t->c_ispeed = kt.c_cflag \& CBAUD;/\/\/ Removed/g' \
			"${WORKDIR}/llvm-project-${PV}.src/libc/src/termios/linux/tcgetattr.cpp" || die
		sed -i 's/t->c_ospeed = kt.c_cflag \& CBAUD;/\/\/ Removed/g' \
			"${WORKDIR}/llvm-project-${PV}.src/libc/src/termios/linux/tcgetattr.cpp" || die
	fi

	if [[ -f "${WORKDIR}/llvm-project-${PV}.src/libc/src/termios/linux/tcsetattr.cpp" ]]; then
		sed -i 's/t->c_ispeed =/\/\/ Removed/g' \
			"${WORKDIR}/llvm-project-${PV}.src/libc/src/termios/linux/tcsetattr.cpp" || die
		sed -i 's/t->c_ospeed =/\/\/ Removed/g' \
			"${WORKDIR}/llvm-project-${PV}.src/libc/src/termios/linux/tcsetattr.cpp" || die
	fi
}

src_configure() {
	local mycmakeargs=(
		-DLLVM_ENABLE_RUNTIMES="libc"
		-DCMAKE_C_COMPILER=clang
		-DLLVM_LIBC_FULL_BUILD=OFF
		
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
