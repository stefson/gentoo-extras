# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Command line utility to rip MMS streams"
HOMEPAGE="http://nbenoit.tuxfamily.org/projects.php?rq=mmsrip"
SRC_URI="http://nbenoit.tuxfamily.org/projects/mmsrip/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="static"

DEPEND="virtual/libc"

src_configure() {
	econf \
		$(use_enable static) \
		|| die
}

src_compile() {
	make clean || die
	make || die
}
