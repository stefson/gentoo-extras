# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit xdg-utils

DESCRIPTION="A weather plug-in for the Xfce desktop environment"
HOMEPAGE="https://goodies.xfce.org/projects/panel-plugins/xfce4-weather-plugin"
SRC_URI="https://archive.xfce.org/src/panel-plugins/${PN}/${PV%.*}/${P}.tar.bz2"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="amd64 ~arm ~ppc ~ppc64 ~x86"
IUSE="upower"

RDEPEND=">=dev-libs/glib-2.42
	dev-libs/libxml2:=
	>=net-libs/libsoup-2.42:2.4[ssl]
	>=x11-libs/gtk+-3.22:3
	>=xfce-base/libxfce4ui-4.12:=
	>=xfce-base/libxfce4util-4.12:=
	>=xfce-base/xfce4-panel-4.12:=
	upower? ( >=sys-power/upower-0.9.23 )"
DEPEND="${RDEPEND}
	dev-util/intltool
	virtual/pkgconfig"

src_prepare() {
	default
	eapply "${FILESDIR}"/0001-Switch-to-locationforecast-product.patch
	eapply "${FILESDIR}"/0002-fix-day-night-calculation.patch
	eapply "${FILESDIR}"/0003-support-solarnoon-and-solarmidnight.patch
	eapply "${FILESDIR}"/0004-enable-keyboard-scrolling-in-details-pane.patch
	eapply "${FILESDIR}"/0005-improve-contrast-in-weather-report.patch
	eapply "${FILESDIR}"/0006-fix-unprintable-character-in-sumarry-subtitle.patch
	eapply "${FILESDIR}"/0007-move-from-exo-csource-to-xdt-csource.patch
	eapply "${FILESDIR}"/0008-switch-to-the-2.0-api.patch
	eapply "${FILESDIR}"/0009-update-copyright-bugzilla-urls.patch
	eapply "${FILESDIR}"/0010-fix-gtimeval-deprecation.patch
	eapply "${FILESDIR}"/0011-weather-icon-fix-user-after-free.patch
	eapply "${FILESDIR}"/0012-remove-gsourcefunc-casts.patch
	eapply "${FILESDIR}"/0013-enable-debug-yes-when-compiling-from-git.patch
	eapply "${FILESDIR}"/0014-fix-missing-prototypes.patch
#	eapply "${FILESDIR}"/

#	eautoconf #need autotools
#	elibtoolize #need autoools

}

src_configure() {
	# For GEONAMES_USERNAME, read README file and ask ssuominen@!
	local myconf=(
		$(use_enable upower)
		GEONAMES_USERNAME=Gentoo
	)
	econf "${myconf[@]}"
}

src_install() {
	default
	find "${D}" -name '*.la' -delete || die
}

pkg_postinst() {
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_icon_cache_update
}
