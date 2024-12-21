# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..13} )
inherit cmake flag-o-matic llvm.org python-any-r1 toolchain-funcs

DESCRIPTION="OpenMP offloading support"
HOMEPAGE="https://openmp.llvm.org"

LICENSE="Apache-2.0-with-LLVM-exceptions || ( UoI-NCSA MIT )"
SLOT="0/${LLVM_SOABI}"
KEYWORDS="~amd64"
IUSE="+debug ompt test llvm_targets_AMDGPU llvm_targets_NVPTX"
RESTRICT="!test? ( test )"

RDEPEND="
	dev-libs/libffi:=
	~sys-devel/llvm-${PV}
	~sys-libs/libomp-${PV}[ompt?]
	llvm_targets_AMDGPU? ( dev-libs/rocr-runtime:= )
"
DEPEND="
	${RDEPEND}
"
# tests:
# - dev-python/lit provides the test runner
# - llvm-core/llvm provide test utils (e.g. FileCheck)
# - llvm-core/clang provides the compiler to run tests
BDEPEND="
	dev-lang/perl
	virtual/pkgconfig
	llvm_targets_AMDGPU? ( sys-devel/clang )
	llvm_targets_NVPTX? ( sys-devel/clang )
	test? (
		${PYTHON_DEPS}
		$(python_gen_any_dep '
			dev-python/lit[${PYTHON_USEDEP}]
		')
		sys-devel/clang
	)
"
# TODO: can it be fixed to compile with gcc?
BDEPEND+="
	sys-devel/clang
"

LLVM_COMPONENTS=( offload cmake runtimes/cmake )
LLVM_TEST_COMPONENTS=( openmp/cmake )
llvm.org_set_globals

pkg_pretend() {
	if [[ ${LLVM_ALLOW_GPU_TESTING} ]]; then
		ewarn "LLVM_ALLOW_GPU_TESTING set.  This package will run tests against your"
		ewarn "GPU if it is supported.  Note that these tests may be flaky, fail or"
		ewarn "hang, or even cause your GPU to crash (requiring a reboot)."
	fi
}

python_check_deps() {
	python_has_version "dev-python/lit[${PYTHON_USEDEP}]"
}

pkg_setup() {
	if use test; then
		python-any-r1_pkg_setup
	fi
}

src_configure() {
	# TODO
	local -x CC=${CHOST}-clang
	local -x CXX=${CHOST}-clang++
	strip-unsupported-flags

	# LLVM_ENABLE_ASSERTIONS=NO does not guarantee this for us, #614844
	use debug || local -x CPPFLAGS="${CPPFLAGS} -DNDEBUG"

	local libdir="$(get_libdir)"
	local ffi_cflags=$($(tc-getPKG_CONFIG) --cflags-only-I libffi)
	local ffi_ldflags=$($(tc-getPKG_CONFIG) --libs-only-L libffi)
	local plugins="host"
	local gpus=
	local build_devicertl=FALSE

	if has "${CHOST%%-*}" aarch64 powerpc64le x86_64; then
		if use llvm_targets_AMDGPU; then
			plugins+=";amdgpu"
			build_devicertl=TRUE
			gpus+=";gfx700;gfx701;gfx801;gfx803;gfx900;gfx902;gfx906"
			gpus+=";gfx908;gfx90a;gfx90c;gfx940;gfx941;gfx942"
			gpus+=";gfx1010;gfx1030;gfx1031;gfx1032;gfx1033"
			gpus+=";gfx1034;gfx1035;gfx1036;gfx1100;gfx1101;gfx1102"
			gpus+=";gfx1103;gfx1150;gfx1151;gfx1152"
		fi
		if use llvm_targets_NVPTX; then
			plugins+=";cuda"
			build_devicertl=TRUE
			gpus+=";sm_35;sm_37;sm_50;sm_52;sm_53;sm_60;sm_61;sm_62"
			gpus+=";sm_70;sm_72;sm_75;sm_80;sm_86;sm_87;sm_89;sm_90"
		fi
	fi

	local mycmakeargs=(
		-DCMAKE_PREFIX_PATH="${ESYSROOT}/usr/lib/llvm/${LLVM_MAJOR}"

		-DOFFLOAD_LIBDIR_SUFFIX="${libdir#lib}"
		-DLIBOMPTARGET_PLUGINS_TO_BUILD="${plugins}"
		-DLIBOMPTARGET_OMPT_SUPPORT="$(usex ompt)"
		-DLIBOMPTARGET_BUILD_DEVICERTL_BCLIB="${build_devicertl}"

		# this breaks building static target libs
		-DBUILD_SHARED_LIBS=OFF

		-DFFI_INCLUDE_DIR="${ffi_cflags#-I}"
		-DFFI_LIBRARY_DIR="${ffi_ldflags#-L}"
	)

	[[ ! ${LLVM_ALLOW_GPU_TESTING} ]] && mycmakeargs+=(
		# prevent trying to access the GPU
		-DLIBOMPTARGET_AMDGPU_ARCH=LIBOMPTARGET_AMDGPU_ARCH-NOTFOUND
		-DLIBOMPTARGET_NVPTX_ARCH=LIBOMPTARGET_NVPTX_ARCH-NOTFOUND
	)
	[[ -n ${gpus} ]] && mycmakeargs+=(
		-DLIBOMPTARGET_DEVICE_ARCHITECTURES="${gpus}"
	)
	use test && mycmakeargs+=(
		# this project does not use standard LLVM cmake macros
		-DOPENMP_LLVM_LIT_EXECUTABLE="${EPREFIX}/usr/bin/lit"
		-DOPENMP_LIT_ARGS="$(get_lit_flags)"

		-DOPENMP_TEST_C_COMPILER="$(type -P "${CHOST}-clang")"
		-DOPENMP_TEST_CXX_COMPILER="$(type -P "${CHOST}-clang++")"
	)

	cmake_src_configure

	if [[ -z ${gpus} ]]; then
		# clang requires libomptarget.devicertl.a, but it can be empty
		> "${BUILD_DIR}"/libomptarget.devicertl.a || die
	fi
}

src_test() {
	# respect TMPDIR!
	local -x LIT_PRESERVES_TMP=1

	cmake_build check-offload
}

src_install() {
	cmake_src_install

	if [[ ! -f ${ED}/usr/$(get_libdir)/libomptarget.devicertl.a ]]
	then
		dolib.a "${BUILD_DIR}"/libomptarget.devicertl.a
	fi
}
