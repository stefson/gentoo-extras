# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..12} )

inherit distutils-r1

DESCRIPTION="Settings editor for LightDM GTK+ greeter"
HOMEPAGE="https://github.com/Xubuntu/lightdm-gtk-greeter"
SRC_URI="https://launchpad.net/${PN}/${PV}/+download/${P}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

COMMON_DEPEND="${PYTHON_DEPEND}"
DEPEND="
	${COMMON_DEPEND}
	x11-misc/lightdm-gtk-greeter
	dev-python/python-distutils-extra[${PYTHON_USEDEP}]
	dev-python/pygobject:3[${PYTHON_USEDEP}]
	x11-libs/gtk+:3"
RDEPEND="${DEPEND}"

