# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-strategy/s25rttr/s25rttr-0.8.1.ebuild,v 1.1 2013/12/23 13:45:08 hasufell Exp $

EAPI=6
inherit eutils cmake-utils gnome2-utils git-r3

DESCRIPTION="Open Source remake of The Settlers II game (needs original game files)"
HOMEPAGE="http://www.siedler25.org/"

EGIT_REPO_URI="https://github.com/Return-To-The-Roots/s25client.git"
EGIT_BRANCH="master"
#EGIT_COMMIT="194195c4d614d177ce1f6a16cd0e62d6e4548eec"

#EGIT_REPO_URI="https://github.com/Flamefire/s25client.git"
#EGIT_BRANCH="restructure"
#EGIT_COMMIT="6487c631ab4695c20814ff9afcd0e09aea7c6830"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 ~arm"
IUSE=""

RDEPEND="app-arch/bzip2
	dev-lang/lua:5.2
	media-libs/libsamplerate
	media-libs/libsdl[X,sound,static-libs,opengl,video]
	>=media-libs/libsdl2-2.0.4[X,sound,static-libs,opengl,video]
	media-libs/libsndfile
	media-libs/sdl-mixer[vorbis]
	net-libs/miniupnpc
	virtual/libiconv
	virtual/opengl"
DEPEND="${RDEPEND}
	>=dev-libs/boost-1.64.0:0=
	sys-devel/gettext"

PATCHES=( 
)

src_prepare() {
	# Ensure no bundled libraries are used

#	for file in $(ls ${S}/external/); do
#		# Preserve boost backports and kaguya
#		if [ "${file}" != "backport" -a "${file}" != "kaguya" !="glad" ]; then
#			rm -r contrib/"${file}" || die
#		fi
#	done

	rm -r external/lua || die
	rm -r external/macos || die
	rm external/full-contrib-msvc.rar || die
	mkdir RTTR || die

	# Prevent installation of git stuff
	rm -r external/languages/.git/ || die
	rm external/languages/.gitignore || die
	rm data/RTTR/LSTS/CREDITS.LST/*.bmp || die

	CMAKE_BUILD_TYPE="Debug"

	cmake-utils_src_prepare
}

src_configure() {
	local arch
	case ${ARCH} in
		amd64)
			arch="x86_64" ;;
		x86)
			arch="i386" ;;
		arm)
			arch="arm" ;;
		*) die "Architecture ${ARCH} not yet supported" ;;
	esac

	local mycmakeargs=(
		-DCMAKE_SKIP_RPATH=ON
		-DENABLE_OPTIMIZATIONS=OFF
#		-DRTTR_INSTALL_PREFIX=/usr/
		-DRTTR_DRIVERDIR="$(get_libdir)/${PN}"
		-DRTTR_GAMEDIR="share/s25rttr/S2/"
		-DRTTR_LIBDIR="$(get_libdir)/${PN}"
#		-DCOMPILEFOR="linux"
#		-DCOMPILEARCH="${arch}"
		-DRTTR_TARGET_BOARD=RasPi2
	)

	cmake-utils_src_configure
}

src_compile() {
	# work around some relative paths (CMAKE_IN_SOURCE_BUILD not supported)
	ln -s "${CMAKE_USE_DIR}"/RTTR "${CMAKE_BUILD_DIR}"/RTTR || die

	cmake-utils_src_compile
}

src_install() {
	cd "${CMAKE_BUILD_DIR}" || die

	exeinto /usr/"$(get_libdir)"/${PN}
	doexe libexec/s25rttr/sound-convert libexec/s25rttr/s-c_resample
	exeinto /usr/"$(get_libdir)"/${PN}/video
	doexe "$(get_libdir)"/s25rttr/video/libvideoSDL.so
	doexe "$(get_libdir)"/s25rttr/video/libvideoSDL2.so
	exeinto /usr/"$(get_libdir)"/${PN}/audio
	doexe "$(get_libdir)"/s25rttr/audio/libaudioSDL.so

	insinto /usr/share/"${PN}"
	doins -r "${CMAKE_USE_DIR}"/data/RTTR

#	doicon -s 64 "${CMAKE_USE_DIR}"/debian/${PN}.png
	dobin bin/s25client
	dobin bin/s25edit
#	make_desktop_entry "s25client" "Settlers RTTR" "${PN}" "Game;StrategyGame" "Path=/usr/bin"
#	dodoc RTTR/texte/{keyboardlayout.txt,readme.txt}

}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	elog "Copy your Settlers2 game files into ~/.${PN}/S2"

	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
