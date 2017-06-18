# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils

SRC_URI="https://doc-0c-a4-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/nt3smr7gt5p7tpdvaevjadvjg9s5a4q3/1497715200000/03293037723036671428/*/0B99O3A0dDe67MjlpMWxWci1ORzQ?e=download -> ${PN}.sh"
#	KEYWORDS="amd64 x86"

DESCRIPTION="Use this to inject either newer kernels or missing packages into debian or ubuntu iso images, for instance to make them bootable on Lenevo Miix 310"
HOMEPAGE="http://www.linuxium.com.au/ http://linuxiumcomau.blogspot.com/"

#LICENSE="LGPL-2.1+"
SLOT="0"
#IUSE=""

DEPEND=""
#RDEPEND="app-arch/cabextract
#	app-arch/p7zip
#	app-arch/unzip
#	net-misc/wget
# dpkg? debhelper? wget? curl? 
#	gtk? ( gnome-extra/zenity )
#	kde? ( kde-apps/kdialog )
#	rar? ( app-arch/unrar )"

RDEPEND="sys-devel/bc #/usr/bin/bc /ok
	sys-apps/util-linux #/sbin/losetup /ok
	sys-apps/iproute2 #/bin/ip /ok
	app-cdr/cdrtools #/usr/bin/isoinfo /ok
	sys-fs/dosfstools #/sbin/mkdosfs /not! ok, needs symlink? or binary needs patch
	sys-fs/squashfs-tools:0= #/usr/bin/mksquashfs + /usr/bin/unsquashfs /ok?
	net-misc/rsync #/usr/bin/rsync /ok
	app-arch/unzip #/usr/bin/unzip /ok
	net-misc/wget #/usr/bin/wget /ok
	sys-apps/findutils #/usr/bin/xargs /ok
	dev-libs/libisoburn #/usr/bin/xorriso /ok
"

#runtime depends on sys-fs/squashfs-tools + xorriso and libisoburn???? + genisoimage + dosfstools

	[ ! $(sudo bash -c "command -v xorriso") ] && DISPLAY_MESSAGE "${0}: Please ensure package 'xorriso' or equivalent for your distro is installed ... exiting." && CLEAN_EXIT

src_unpack() {
	mkdir "${S}" || die 
}

src_prepare() {

default
#cp "${FILESDIR}"/${PN}.sh "${S}" || die
#Wenn du nichts zu entpacken hast wirst du eine eigene src_unpack() schreiben wollen die über $A iteriert
cp "${DISTDIR}"/${PN}.sh "${S}" || die
mv "${S}"/${PN}.sh ${S}"/${PN}" || die

}

src_install() {
	dobin isocorespin
}

#pkg_preinst() {

#}

#pkg_postinst() {

#}

#pkg_postrm() {

#}
