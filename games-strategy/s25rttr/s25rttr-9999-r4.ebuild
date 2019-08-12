# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-strategy/s25rttr/s25rttr-0.8.1.ebuild,v 1.1 2013/12/23 13:45:08 hasufell Exp $

EAPI=6
inherit eutils cmake-utils gnome2-utils git-r3

DESCRIPTION="Open Source remake of The Settlers II game (needs original game files)"
HOMEPAGE="http://www.siedler25.org/ https://github.com/Return-To-The-Roots/s25client/"

#EGIT_REPO_URI="https://github.com/Return-To-The-Roots/s25client.git"
#EGIT_BRANCH="master"
#EGIT_COMMIT="194195c4d614d177ce1f6a16cd0e62d6e4548eec"

EGIT_REPO_URI="https://github.com/Flamefire/s25client.git"
EGIT_BRANCH="sanitizers"
#EGIT_COMMIT="6487c631ab4695c20814ff9afcd0e09aea7c6830"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 ~arm"
IUSE="test"

RDEPEND="app-arch/bzip2
	dev-lang/lua:5.2
	media-libs/libsamplerate
	media-libs/libsdl[X,sound,static-libs,opengl,video]
	media-libs/sdl-mixer[vorbis]
	>=media-libs/libsdl2-2.0.4[X,sound,static-libs,opengl,video]
	>=media-libs/sdl2-mixer-2.0.4[vorbis]
	media-libs/libsndfile
	net-libs/miniupnpc
	virtual/libiconv
	virtual/opengl"
DEPEND="${RDEPEND}
	>=dev-libs/boost-1.64.0:0=[nls]
	sys-devel/gettext
	test? ( sys-devel/clang )"

#PATCHES=(
#)

src_prepare() {

	# Ensure no bundled libraries are used
	rm -r external/lua || die
	rm -r external/macos || die
	rm -r external/libsamplerate || die

	rm external/full-contrib-msvc.rar || die

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
		-DRTTR_DRIVERDIR="$(get_libdir)/${PN}"
		-DRTTR_GAMEDIR="share/s25rttr/S2/"
		-DRTTR_LIBDIR="$(get_libdir)/${PN}"
		-DRTTR_BUILD_UPDATER=OFF
		-DRTTR_USE_SYSTEM_SAMPLERATE=ON
	)

	if ! use test ; then
		mycmakeargs+=(
			-DBUILD_TESTING=OFF
			-DRTTR_ENABLE_SANITIZERS=OFF
		)
	elif use test ; then
	# todo: this needs CC=clang
	einfo "Enforcing the use of clang due to USE=test ..."
		CC=${CHOST}-clang
		CXX=${CHOST}-clang++

		mycmakeargs+=(
			-DBUILD_TESTING=ON
			-DRTTR_ENABLE_SANITIZERS=ON
		)
	fi

	cmake-utils_src_configure
}

src_compile() {
	# source build now supported
	cmake-utils_src_compile
}

src_test() {
	# try to enable tests
	cmake-utils_src_test
}

src_install() {
	cd "${CMAKE_BUILD_DIR}" || die

	exeinto /usr/"$(get_libdir)"/${PN}/video
	doexe "$(get_libdir)"/s25rttr/video/libvideoSDL.so
	doexe "$(get_libdir)"/s25rttr/video/libvideoSDL2.so

	exeinto /usr/"$(get_libdir)"/${PN}/audio
	doexe "$(get_libdir)"/s25rttr/audio/libaudioSDL.so

	insinto /usr/share
	doins -r share/"${PN}"

	dobin bin/s25client
	dobin bin/s25edit

#	doicon -s 64 "${CMAKE_USE_DIR}"/debian/${PN}.png

}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	elog "Copy your Settlers2 game files into /usr/share/${PN}/S2"

	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
