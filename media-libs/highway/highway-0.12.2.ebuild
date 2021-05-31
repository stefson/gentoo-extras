# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit cmake eutils

DESCRIPTION="Efficient and performance-portable SIMD"
HOMEPAGE="https://github.com/google/highway"
SRC_URI="https://github.com/google/highway/archive/refs/tags/${PV}.tar.gz -> ${PN}-${PV}.tar.gz"

LICENSE="BSD"
SLOT="0"
#KEYWORDS=""

#IUSE=""

#S="${WORKDIR}/${MY_P}"

src_prepare() {

	CMAKE_BUILD_TYPE="Release"

	cmake_src_prepare

}

src_configure() {

	local mycmakeargs=(
		-DBUILD_TESTING=OFF
	)

	cmake_src_configure

}

src_compile() {

	cmake_src_compile

}
