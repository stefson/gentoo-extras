# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils

SRC_URI="https://doc-0s-a4-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/4mmgeaihdele7um6uh225ei2hmghn9vg/1501646400000/03293037723036671428/*/0B99O3A0dDe67S053UE8zN3NwM2c?e=download -> ${PN}.sh"
#	KEYWORDS="amd64 x86"

DESCRIPTION="Use this to inject either newer kernels or missing packages into debian or ubuntu iso images, for instance to make them bootable on Lenevo Miix 310"
HOMEPAGE="http://www.linuxium.com.au/ http://linuxiumcomau.blogspot.com/"

#LICENSE="LGPL-2.1+"
SLOT="0"
#IUSE=""

DEPEND=""

RDEPEND="sys-devel/bc 
	sys-apps/util-linux 
	sys-apps/iproute2
	app-cdr/cdrtools 
	sys-fs/dosfstools
	sys-fs/squashfs-tools:0= 
	net-misc/rsync 
	app-arch/unzip 
	net-misc/wget 
	sys-apps/findutils 
	dev-libs/libisoburn
	app-admin/sudo"

#/sbin/mkdosfs /not! ok, needs symlink? or binary needs patch

#runtime depends on genisoimage? # dpkg? debhelper?

#use app-misc/binwalk to have a look into the binary attached to the bash script. It seems as if those are mostly grub stages for the bootloader, efi-32bit and plain grub 64bit. 

# extract bash script from payload - head -n 3208 isorespin-arbeitskopie.sh  > isorespin.sh

src_unpack() {
	mkdir "${S}" || die 
}

src_prepare() {

default
#cp "${FILESDIR}"/${PN}.sh "${S}" || die
#Wenn du nichts zu entpacken hast wirst du eine eigene src_unpack() schreiben wollen die über $A iteriert
cp "${DISTDIR}"/${PN}.sh "${S}" || die
mv "${S}"/${PN}.sh ${S}"/${PN}" || die

eapply "${FILESDIR}"/gentoo-compat.patch

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
