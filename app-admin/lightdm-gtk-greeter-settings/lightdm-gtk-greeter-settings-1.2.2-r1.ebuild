# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
DISTUTILS_SINGLE_IMPL=1
PYTHON_COMPAT=( python3_{11..13} )

inherit distutils-r1 xdg

DESCRIPTION="Settings editor for LightDM GTK+ greeter"
HOMEPAGE="https://github.com/Xubuntu/lightdm-gtk-greeter"
SRC_URI="https://github.com/Xubuntu/${PN}/releases/download/${P}/${P}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE=""

RDEPEND="
	dev-libs/glib:2
	x11-libs/gtk+:3[introspection]
	x11-libs/pango[introspection]
	x11-misc/lightdm-gtk-greeter
	$(python_gen_cond_dep '
		dev-libs/gobject-introspection[${PYTHON_SINGLE_USEDEP}]
		dev-python/pygobject[${PYTHON_USEDEP}]
	')
"
BDEPEND="
	$(python_gen_cond_dep '
		dev-python/python-distutils-extra[${PYTHON_USEDEP}]
	')
"

src_install() {
	distutils-r1_src_install
	rm -r "${ED}/usr/share/doc/${PN}" || die
}

