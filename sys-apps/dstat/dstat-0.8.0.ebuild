# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_{6,7} )

inherit python-r1

SRCHASH=6f5db0aed26bf8cf2700d4ffe90a9bd3436ac728

DESCRIPTION="Versatile replacement for vmstat, iostat and ifstat"
HOMEPAGE="http://dag.wieers.com/home-made/dstat/"
SRC_URI="https://github.com/dagwieers/dstat/archive/${SRCHASH}.tar.gz -> ${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc ~x86 ~amd64-linux ~x86-linux"
IUSE="wifi doc examples"
REQUIRED_USE="wifi? ( ${PYTHON_REQUIRED_USE} )"

RDEPEND="
	wifi? (
		${PYTHON_DEPS}
		net-wireless/python-wifi
	)"
DEPEND=""


S="${WORKDIR}"/dstat-${SRCHASH}

src_install() {
	emake DESTDIR="${ED}" install
	einstalldocs

	if use examples; then
		dodoc examples/{mstat,read}.py
	fi
	if use doc; then
		dodoc docs/*.html
	fi
}
