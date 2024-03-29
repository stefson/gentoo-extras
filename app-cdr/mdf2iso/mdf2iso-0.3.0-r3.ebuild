# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit toolchain-funcs

DESCRIPTION="Alcohol 120% bin image to ISO image file converter"
HOMEPAGE="https://www.berlios.de/software/mdf2iso/"
SRC_URI="http://download.berlios.de/${PN}/${P}-src.tar.bz2"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ~ppc ~x86"
IUSE=""
DEPEND="virtual/libc"
RDEPEND="virtual/libc"

S=${WORKDIR}/${PN}

PATCHES=(
	"${FILESDIR}/${P}-bigfiles.patch"
)

src_install() {
	dodoc ChangeLog
	dobin src/${PN} || die "dobin failed"
}

