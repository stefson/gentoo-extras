# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MULTILIB_COMPAT=( abi_x86_{32,64} )
inherit flag-o-matic meson-multilib

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/AlpyneDreams/d8vk.git"
else
	HASH_LIBDISPLAY=ac857e89852acf6e24a4068d1915300ff780920b
	HASH_SPIRV=0bcc624926a25a2a273d07877fd25a6ff5ba1cfb
	HASH_VULKAN=98f440ce6868c94f5ec6e198cc1adda4760e8849
	SRC_URI="
		https://github.com/AlpyneDreams/d8vk/archive/refs/tags/${PN}-v${PV}.tar.gz -> ${P}.tar.gz
		https://gitlab.freedesktop.org/JoshuaAshton/libdisplay-info/-/archive/${HASH_LIBDISPLAY}/libdisplay-info-${HASH_LIBDISPLAY}.tar.gz -> ${PN}-libdisplay-info-${HASH_LIBDISPLAY::10}.tar.gz
		https://github.com/KhronosGroup/SPIRV-Headers/archive/${HASH_SPIRV}.tar.gz -> ${PN}-spirv-headers-${HASH_SPIRV::10}.tar.gz
		https://github.com/KhronosGroup/Vulkan-Headers/archive/${HASH_VULKAN}.tar.gz -> ${PN}-vulkan-headers-${HASH_VULKAN::10}.tar.gz"		
	KEYWORDS="-* ~amd64 ~x86"
fi
DESCRIPTION="Vulkan-based implementation of D3D9, D3D10 and D3D11 for Linux / Wine"
HOMEPAGE="https://github.com/doitsujin/dxvk/"

LICENSE="ZLIB"
SLOT="0"
IUSE="+abi_x86_32 crossdev-mingw +d3d8 +d3d9 debug"
REQUIRED_USE="
	d3d8? ( d3d9 )"

BDEPEND="
	dev-util/glslang
	!crossdev-mingw? ( dev-util/mingw64-toolchain[${MULTILIB_USEDEP}] )"

pkg_pretend() {
	[[ ${MERGE_TYPE} == binary ]] && return

	if use crossdev-mingw && [[ ! -v MINGW_BYPASS ]]; then
		local tool=-w64-mingw32-g++
		for tool in $(usev abi_x86_64 x86_64${tool}) $(usev abi_x86_32 i686${tool}); do
			if ! type -P ${tool} >/dev/null; then
				eerror "With USE=crossdev-mingw, it is necessary to setup the mingw toolchain."
				eerror "For instructions, please see: https://wiki.gentoo.org/wiki/Mingw"
				use abi_x86_32 && use abi_x86_64 &&
					eerror "Also, with USE=abi_x86_32, will need both i686 and x86_64 toolchains."
				die "USE=crossdev-mingw is set but ${tool} was not found"
			elif [[ ! $(LC_ALL=C ${tool} -v 2>&1) =~ "Thread model: posix" ]]; then
				eerror "${PN} requires GCC to be built with --enable-threads=posix"
				eerror "Please see: https://wiki.gentoo.org/wiki/Mingw#POSIX_threads_for_Windows"
				die "USE=crossdev-mingw is set but ${tool} does not use POSIX threads"
			fi
		done
	fi
}

src_prepare() {
	default
	
	rmdir subprojects/libdisplay-info || die
	mv ../libdisplay-info-${HASH_LIBDISPLAY} subprojects/libdisplay-info || die
	rmdir include/{spirv,vulkan} || die
	mv ../SPIRV-Headers-${HASH_SPIRV} include/spirv || die
	mv ../Vulkan-Headers-${HASH_VULKAN} include/vulkan || die

	sed -i "/^basedir=/s|=.*|=${EPREFIX}/usr/lib/${PN}|" setup_d3d8.sh || die
}

src_configure() {
	use crossdev-mingw || PATH=${BROOT}/usr/lib/mingw64-toolchain/bin:${PATH}

	# AVX has a history of causing issues with this package, disable for safety
	# https://github.com/Tk-Glitch/PKGBUILDS/issues/515
	append-flags -mno-avx

	if [[ ${CHOST} != *-mingw* ]]; then
		if [[ ! -v MINGW_BYPASS ]]; then
			unset AR CC CXX RC STRIP
			filter-flags '-fuse-ld=*'
		fi

		CHOST_amd64=x86_64-w64-mingw32
		CHOST_x86=i686-w64-mingw32
		CHOST=$(usex x86 ${CHOST_x86} ${CHOST_amd64})

		strip-unsupported-flags
	fi

	multilib-minimal_src_configure
}

multilib_src_configure() {
	# multilib's ${CHOST_amd64}-gcc -m32 is unusable with crossdev,
	# unset again so meson eclass will set ${CHOST}-gcc + others
	use crossdev-mingw && [[ ! -v MINGW_BYPASS ]] && unset AR CC CXX RC STRIP

	local emesonargs=(
		--prefix="${EPREFIX}"/usr/lib/${PN}
		--{bin,lib}dir=x${MULTILIB_ABI_FLAG: -2}
		$(meson_use {,enable_}d3d8)
		$(meson_use {,enable_}d3d9)
		-Denable_d3d10=false
		-Denable_d3d11=false
		-Denable_dxgi=false
		$(usev !debug --strip) # portage won't strip .dll, so allow it here
#		-Denable_tests=false # needs wine/vulkan and is intended for manual use
	)

	meson_src_configure
}

multilib_src_install_all() {
	dobin setup_d3d8.sh
	dodoc README.md dxvk.conf

	find "${ED}" -type f -name '*.a' -delete || die
}

pkg_preinst() {
	[[ -e ${EROOT}/usr/$(get_libdir)/dxvk/d3d11.dll ]] && DXVK_HAD_OVERLAY=
}

pkg_postinst() {
	if [[ ! ${REPLACING_VERSIONS} ]]; then
		elog "To enable ${PN} on a wine prefix, you can run the following command:"
		elog
		elog "	WINEPREFIX=/path/to/prefix setup_dxvk.sh install --symlink"
		elog
		elog "See ${EROOT}/usr/share/doc/${PF}/README.md* for details."
	elif [[ -v DXVK_HAD_OVERLAY ]]; then
		# temporary warning until this version is more widely used
		elog "Gentoo's main repo ebuild for ${PN} uses different paths than most overlays."
		elog "If you were using symbolic links in wine prefixes it may be necessary to"
		elog "refresh them by re-running the command:"
		elog
		elog "	WINEPREFIX=/path/to/prefix setup_dxvk.sh install --symlink"
		elog
		elog "Also, if you were using /etc/${PN}.conf, ${PN} is no longer patched to load"
		elog "it. See ${EROOT}/usr/share/doc/${PF}/README.md* for handling configs."
	fi

	# don't try to keep wine-*[vulkan] in RDEPEND, but still give a warning
	local wine
	for wine in app-emulation/wine-{vanilla,staging}; do
		has_version ${wine} && ! has_version ${wine}[vulkan] &&
			ewarn "${wine} was not built with USE=vulkan, ${PN} will not be usable with it"
	done
}
