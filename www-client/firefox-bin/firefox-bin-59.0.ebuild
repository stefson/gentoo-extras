# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils unpacker versionator

MY_VERSION="52.6.0esr"
MY_DEBVERSION=deb9
KEYWORDS="~arm"
#SRC_URI="http://security.debian.org/debian-security/pool/updates/main/f/firefox-esr/firefox-esr_${MY_VERSION}-1~${MY_DEBVERSION}u1_armhf.deb
#	http://security.debian.org/debian-security/pool/updates/main/f/firefox-esr/firefox-esr-l10n-de_${MY_VERSION}-1~${MY_DEBVERSION}u1_all.deb"

SRC_URI="http://mirror.archlinuxarm.org/armv7h/extra/firefox-59.0-2-armv7h.pkg.tar.xz
	http://mirror.archlinuxarm.org/armv7h/extra/libvpx-1.7.0-1-armv7h.pkg.tar.xz
	http://mirror.archlinuxarm.org/armv7h/core/icu-60.2-1-armv7h.pkg.tar.xz"

DESCRIPTION="Firefox Binary from Arch linux for ARM (e.g. Raspberry Pi)"
HOMEPAGE="https://archlinuxarm.org/packages/armv7h/firefox"

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
	x11-libs/pango
	!media-libs/libvpx"

src_prepare() {
	eapply_user
}

src_install() {
	declare MOZILLA_FIVE_HOME=/opt/${MOZ_PN}
}
