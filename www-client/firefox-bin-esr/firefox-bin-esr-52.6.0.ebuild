# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils unpacker versionator

MY_VERSION="52.6.0esr"
MY_DEBVERSION=deb9
KEYWORDS="~arm"
#SRC_URI="http://security.debian.org/debian-security/pool/updates/main/f/firefox-esr/firefox-esr_${MY_VERSION}-1~${MY_DEBVERSION}u1_armhf.deb
#	http://security.debian.org/debian-security/pool/updates/main/f/firefox-esr/firefox-esr-l10n-de_${MY_VERSION}-1~${MY_DEBVERSION}u1_all.deb"

SRC_URI="http://ftp.de.debian.org/debian/pool/main/f/firefox-esr/firefox-esr_52.6.0esr-2+b1_armhf.deb
	http://ftp.de.debian.org/debian/pool/main/f/firefox-esr/firefox-esr-l10n-de_52.6.0esr-2_all.deb
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
	dev-libs/libgcrypt:11
	dev-libs/libpcre
	dev-libs/libtasn1
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
	x11-libs/pango"

src_prepare() {
	eapply_user
}

src_install() {
	rm -rf "${S}"/usr/lib/mime || die
	mv "${S}"/{usr,etc} "${D}"/ || die
}
