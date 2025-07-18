# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

LUA_COMPAT=( lua5-3 )

inherit cmake lua-single git-r3 xdg

DESCRIPTION="Open Source remake of The Settlers II game (needs original game files)"
HOMEPAGE="http://www.siedler25.org/ https://github.com/Return-To-The-Roots/s25client/"

EGIT_REPO_URI="https://github.com/Return-To-The-Roots/s25client.git"
EGIT_BRANCH="master"
#EGIT_COMMIT="a01a3ec937ba63e955b0982dc217573d540149a4"

#EGIT_REPO_URI="https://github.com/Flamefire/s25client.git"
#EGIT_BRANCH="musl"
#EGIT_COMMIT="6487c631ab4695c20814ff9afcd0e09aea7c6830"

LICENSE="GPL2+ GPL-3 Boost-1.0"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64"
IUSE="test"

RDEPEND=">=app-arch/bzip2-1.0.6-r11
	dev-lang/lua:5.3
	media-libs/libsamplerate
	>=media-libs/libsdl2-2.0.12-r1[X,sound,static-libs,opengl,video]
	>=media-libs/sdl2-mixer-2.0.4[vorbis]
	media-libs/libsndfile
	net-libs/miniupnpc:=
	virtual/libiconv
	virtual/opengl"
DEPEND="${RDEPEND}
	>=dev-libs/boost-1.73.0:=[nls]
	sys-devel/gettext
	test? ( sys-devel/clang )"
BDEPEND="app-arch/unzip"

#PATCHES=( "${FILESDIR}"/lang.patch )

PATCHES=(
	"${FILESDIR}"/${PN}-0.9.0_pre20200723-cmake_lua_version.patch
)

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
	rm -r .github/ || die
	rm -r external/languages/.github/ || die
	rm external/languages/.gitignore || die
#	rm data/RTTR/assets/base/credits/*.bmp || die

#	rm -v external/{kaguya,libutil}/cmake/FindLua.cmake || die

	CMAKE_BUILD_TYPE="Debug"

	cmake_src_prepare
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
		-DLUA_VERSION=$(lua_get_version)
		-DRTTR_DRIVERDIR="$(get_libdir)/${PN}"
		-DRTTR_GAMEDIR="share/s25rttr/S2/"
		-DRTTR_LIBDIR="$(get_libdir)/${PN}"
		-DRTTR_BUILD_UPDATER=OFF
		-DRTTR_BUILD_UPDATER_DEF=OFF
		-DRTTR_INCLUDE_DEVTOOLS=OFF
	)

	# bug #787299
	append-cxxflags -std=gnu++14

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

	cmake_src_configure
}

src_compile() {
	cmake_src_compile
}

src_test() {
	cmake_src_test
}

src_install() {
	cd "${BUILD_DIR}" || die

	# disable install of quirky git headers
	rm -r share/s25rttr/RTTR/MAPS/.git || die
	rm share/s25rttr/RTTR/MAPS/.gitattributes || die
	
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
	xdg_pkg_postinst

	if ! has_version -r games-strategy/settlers-2-gold-data; then
		elog "Install games-strategy/settlers-2-gold-data or manually copy the DATA"
		elog "and GFX directories from original data files into"
		elog "${EPREFIX}/usr/share/${PN}/S2."
	fi
}
