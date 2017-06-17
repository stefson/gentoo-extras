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



#src_unpack() {
#	default
#}

src_install() {
	dobin isocorespin
}

#pkg_preinst() {

#}

#pkg_postinst() {

#}

#pkg_postrm() {

#}
