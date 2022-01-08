# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit cmake eutils

DESCRIPTION="Efficient and performance-portable SIMD"
HOMEPAGE="https://github.com/google/highway"

if [[ "${PV}" == *9999* ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/google/highway.git"
else
	SRC_URI="https://github.com/google/highway/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
fi

LICENSE="Apache-2.0"
SLOT="0"
#KEYWORDS=""

#IUSE=""

PATCHES=( "${FILESDIR}/${P}-shared-libraries.patch" )

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

src_install() {

	cmake_src_install

}
