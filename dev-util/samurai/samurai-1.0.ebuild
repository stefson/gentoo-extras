# Copyright 2017-2019 Haelwenn (lanodan) Monnier <contact@hacktivis.me>
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="ninja-compatible build tool written in C"
HOMEPAGE="https://github.com/michaelforney/samurai"
SRC_URI="https://github.com/michaelforney/samurai/releases/download/${PV}/${P}.tar.gz"
LICENSE="ISC Apache-2.0 MIT"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"

IUSE="+ninja-replace"

RDEPEND="
	ninja-replace? (
		!dev-util/ninja
	)
"

src_install() {
	emake DESTDIR="${D}" PREFIX=/usr install

	if use ninja-replace; then
		dosym samu /usr/bin/ninja
	fi
}
