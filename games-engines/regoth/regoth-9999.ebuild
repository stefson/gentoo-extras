# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit eutils cmake-utils git-r3

DESCRIPTION="Open Source reimplementation of the Gothic I/II engine"
HOMEPAGE="http://www.worldofgothic.de"

EGIT_REPO_URI="https://github.com/REGoth-project/REGoth.git"
EGIT_BRANCH="master"
#EGIT_COMMIT=""

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""
#IUSE="glfw"

RDEPEND="virtual/opengl
	dev-libs/libbsd
	x11-libs/libX11
	>=sys-devel/gcc-6.4.0"
#	sci-physics/bullet[bullet3]
#	glfw? ( <media-libs/glfw-3 )"
DEPEND="${RDEPEND}"

#PATCHES=(
#	"${FILESDIR}"/${P}-.patch
#)

src_prepare() {

	cmake-utils_src_prepare
}

src_configure() {

#	local mycmakeargs=(
#	)

	cmake-utils_src_configure
}

src_compile() {

	cmake-utils_src_compile
}

src_install() {

#	cmake-utils_src_install

	cd "${CMAKE_BUILD_DIR}" || die

	exeinto /usr/"$(get_libdir)"/regoth/
	doexe lib/*.a
	doexe lib/*.so
#	if that doesn't work, try whole lib dir instead

	insinto /usr/bin/
	doins -r bin/shaders

	dobin bin/altonegen
	dobin bin/makehrtf
	dobin bin/openal-info
	dobin bin/REGoth

}

#pkg_preinst() {
#	gnome2_icon_savelist
#}

#pkg_postinst() {
#	elog "something fancy"
#}

#pkg_postrm() {
#
#}
