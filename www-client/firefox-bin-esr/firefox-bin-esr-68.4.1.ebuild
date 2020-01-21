# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils unpacker versionator

MY_VERSION="68.4.1esr"
MY_DEBVERSION="deb10u1"
KEYWORDS="~arm"

SRC_URI="http://security.debian.org/debian-security/pool/updates/main/f/firefox-esr/firefox-esr_${MY_VERSION}-1~${MY_DEBVERSION}_armhf.deb
	http://security.debian.org/debian-security/pool/updates/main/f/firefox-esr/firefox-esr-l10n-de_${MY_VERSION}-1~${MY_DEBVERSION}_all.deb
	http://ftp.de.debian.org/debian/pool/main/libv/libvpx/libvpx5_1.7.0-3_armhf.deb"

DESCRIPTION="Firefox Binary from Ubuntu for ARM (e.g. Raspberry Pi)"
HOMEPAGE="https://packages.debian.org/stretch/firefox-esr"

LICENSE="BSD"
SLOT="0"

#QA_PREBUILT="usr/lib*/chromium-browser/*"

S="${WORKDIR}"

RDEPEND="app-accessibility/speech-dispatcher
	app-crypt/mit-krb5
	dev-libs/expat
	dev-libs/libffi-compat
	dev-libs/libgcrypt:0/20
	dev-libs/libpcre
	dev-libs/libtasn1
	dev-libs/json-c
	dev-libs/nspr
	dev-libs/nss
	gnome-base/libgnome-keyring
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/libjpeg-turbo
	media-libs/libpng:0
	net-libs/gnutls
	net-print/cups
	sys-apps/lsb-release
	>=sys-devel/gcc-4.9
	x11-libs/gtk+:2
	x11-libs/libXScrnSaver
	x11-libs/pango
	!media-libs/libvpx"

src_prepare() {
	eapply_user
}

src_install() {
	rm -rf "${S}"/usr/lib/mime || die
	mv "${S}"/{usr,etc} "${D}"/ || die
}
