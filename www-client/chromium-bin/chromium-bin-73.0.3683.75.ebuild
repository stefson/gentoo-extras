# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils unpacker versionator

#MY_VERSION="$(get_version_component_range 1-4)"
MY_VERSION="73.0.3683.75"
#MY_PATCH="$(get_version_component_range 5)"
MY_UBUNTUVERS=16.04.1
KEYWORDS="~arm"

SRC_URI="https://launchpad.net/~canonical-chromium-builds/+archive/ubuntu/stage/+files/chromium-browser_${MY_VERSION}-0ubuntu0.${MY_UBUNTUVERS}_armhf.deb
	https://launchpad.net/~canonical-chromium-builds/+archive/ubuntu/stage/+files/chromium-codecs-ffmpeg_${MY_VERSION}-0ubuntu0.${MY_UBUNTUVERS}_armhf.deb"

#SRC_URI="http://ports.ubuntu.com/ubuntu-ports/pool/universe/c/chromium-browser/chromium-browser_${MY_VERSION}-0ubuntu0.14.04.${MY_PATCH}_armhf.deb
#	http://ports.ubuntu.com/ubuntu-ports/pool/universe/c/chromium-browser/chromium-codecs-ffmpeg_${MY_VERSION}-0ubuntu0.14.04.${MY_PATCH}_armhf.deb"

DESCRIPTION="Chromium Binary from Ubuntu for ARM (e.g. Raspberry Pi)"
HOMEPAGE="http://packages.ubuntu.com/trusty/chromium-browser"

LICENSE="BSD"
SLOT="0"

#QA_PREBUILT="usr/lib*/chromium-browser/*"
QA_PRESTRIPPED="usr/lib*/chromium-browser/*"

S="${WORKDIR}"

RDEPEND="app-accessibility/speech-dispatcher
	app-crypt/mit-krb5
	dev-libs/expat
	dev-libs/libgcrypt:0/20
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
	x11-libs/libXtst
	x11-libs/pango
	x11-misc/xdg-utils
	>=sys-libs/glibc-2.17"

src_prepare() {
	eapply_user
}

src_install() {
	mv "${S}"/{usr,etc} "${D}"/ || die
	dosym /usr/bin/chromium-browser /usr/bin/chromium
	chmod 4755 "${D}/usr/$(get_libdir)/chromium-browser/chrome-sandbox" || die
}
