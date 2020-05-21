# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit eutils cmake-utils git-r3 xdg-utils

DESCRIPTION="Open Source remake of The Settlers II game (needs original game files)"
HOMEPAGE="http://www.siedler25.org/ https://github.com/Return-To-The-Roots/s25client/"

EGIT_REPO_URI="https://github.com/Return-To-The-Roots/s25client.git"
EGIT_BRANCH="master"
#EGIT_COMMIT="a01a3ec937ba63e955b0982dc217573d540149a4"

#EGIT_REPO_URI="https://github.com/Flamefire/s25client.git"
#EGIT_BRANCH="nowide"
#EGIT_COMMIT="6487c631ab4695c20814ff9afcd0e09aea7c6830"

LICENSE="GPL2+ GPL-3 Boost-1.0"
SLOT="0"
#KEYWORDS="amd64 ~arm ~arm64"
IUSE="test"

RDEPEND=">=app-arch/bzip2-1.0.6-r11
	dev-lang/lua:5.2
	media-libs/libsamplerate
	>=media-libs/libsdl2-2.0.12-r1[X,sound,static-libs,opengl,video]
	>=media-libs/sdl2-mixer-2.0.4[vorbis]
	media-libs/libsndfile
	net-libs/miniupnpc
	virtual/libiconv
	virtual/opengl"
DEPEND="${RDEPEND}
	>=dev-libs/boost-1.73.0:0=[nls]
	sys-devel/gettext
	test? ( sys-devel/clang )"
BDEPEND="app-arch/unzip"

#PATCHES=( )

src_prepare() {

	# Ensure no bundled libraries are used
	rm -r external/dev-tools || die
	rm -r extras/macosLauncher || die

	# remove release tools and win32 stuff
	rm -r tools || die
	rm -r data/win32 || die

	# remove source files for updater
	rm -r external/s25update || die

	# Prevent installation of git stuff
	rm -r external/languages/.git/ || die
	rm external/languages/.gitignore || die
	rm data/RTTR/LSTS/CREDITS.LST/*.bmp || die

	# remove sdl1 in favour of sdl2
	# rm -r extras/videoDrivers/SDL || die

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
		arm64)
			arch="aarch64" ;;
		*) die "Architecture ${ARCH} not yet supported" ;;
	esac

	local mycmakeargs=(
		-DCMAKE_SKIP_RPATH=ON
		-DRTTR_DRIVERDIR="$(get_libdir)/${PN}"
		-DRTTR_GAMEDIR="share/s25rttr/S2/"
		-DRTTR_LIBDIR="$(get_libdir)/${PN}"
		-DRTTR_BUILD_UPDATER=OFF
		-DRTTR_BUILD_UPDATER_DEF=OFF
		-DRTTR_INCLUDE_DEVTOOLS=OFF
		-DFETCHCONTENT_FULLY_DISCONNECTED=ON
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
	cmake-utils_src_compile
}

src_test() {
	cmake-utils_src_test
}

src_install() {
	cd "${CMAKE_BUILD_DIR}" || die

	exeinto /usr/"$(get_libdir)"/${PN}/video
	doexe "$(get_libdir)"/s25rttr/video/libvideoSDL2.so

	exeinto /usr/"$(get_libdir)"/${PN}/audio
	doexe "$(get_libdir)"/s25rttr/audio/libaudioSDL.so

	insinto /usr/share
	doins -r share/"${PN}"

	dobin bin/s25client
	dobin bin/s25edit

#	doicon -s 64 tools/release/debian/s25rttr.png
}

pkg_postinst() {
	elog "Copy your Settlers2 game files into /usr/share/${PN}/S2"

	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_icon_cache_update
}
