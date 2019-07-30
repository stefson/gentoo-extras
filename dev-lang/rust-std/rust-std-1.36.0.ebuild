# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils bash-completion-r1 versionator toolchain-funcs

MY_P="rust-std-${PV}"

DESCRIPTION="std libraries for rust"
HOMEPAGE="https://www.rust-lang.org/"
#SRC_URI="$(rust_all_arch_uris ${MY_P})"

#RUSTHOST="armv7-unknown-linux-gnueabihf"
#RUSTHOST="thumbv7neon-unknown-linux-gnueabihf"
RUST_PROVIDER="rust-bin-1.36.0"

#SRC_URI="https://static.rust-lang.org/dist/"${P}"-"${RUSTHOST}".tar.xz"
SRC_URI="armv6j-softfloat-std? ( https://static.rust-lang.org/dist/"${P}"-arm-unknown-linux-gnueabi.tar.xz )
	armv6j-hardfloat-std? ( https://static.rust-lang.org/dist/"${P}"-arm-unknown-linux-gnueabihf.tar.xz )
	armv7-hardfloat-std? (  https://static.rust-lang.org/dist/"${P}"-armv7-unknown-linux-gnueabihf.tar.xz )
	thumbv7-neon-std? ( https://static.rust-lang.org/dist/"${P}"-thumbv7neon-unknown-linux-gnueabihf.tar.xz )
	aarch64-gnu-std? ( https://static.rust-lang.org/dist/"${P}"-aarch64-unknown-linux-gnu.tar.xz ) "

LICENSE="|| ( MIT Apache-2.0 ) BSD-1 BSD-2 BSD-4 UoI-NCSA"
SLOT="stable"
KEYWORDS="~amd64"
IUSE="aarch64-gnu-std armv6j-softfloat-std armv6j-hardfloat-std +armv7-hardfloat-std thumbv7-neon-std"

DEPEND=""
RDEPEND="app-eselect/eselect-rust
	=dev-lang/rust-bin-1.36.0
	!dev-lang/rust:0"
REQUIRED_USE=""

QA_PREBUILT="
	opt/"${RUST_PROVIDER}"/lib/rustlib/*/lib/*.so
	opt/"${RUST_PROVIDER}"/lib/rustlib/*/lib/*.rlib*
"

pkg_setup() {

	if use armv6j-softfloat-std ; then
		RUSTHOST=arm-unknown-linux-gnueabi
	elif use armv6j-hardfloat-std ; then
		RUSTHOST=arm-unknown-linux-gnueabihf
	elif use armv7-hardfloat-std ; then
		RUSTHOST=armv7-unknown-linux-gnueabihf
	elif use thumbv7-neon-std ; then
		RUSTHOST=thumbv7neon-unknown-linux-gnueabihf
	elif use aarch64-gnu-std ; then
		RUSTHOST=aarch64-unknown-linux-gnu
	fi
}

src_unpack() {
	default
	mv "${WORKDIR}/${MY_P}-"${RUSTHOST}"" "${S}" || die
}

src_prepare() {
	default
	cd "${S}"/"${PN}"-"${RUSTHOST}"/lib/rustlib/"${RUSTHOST}"/lib || die
	if use armv7-hardfloat-std ; then
		armv7a-unknown-linux-gnueabihf-strip *.so || die
	fi
}

src_install() {
	./install.sh \
		--disable-verify \
		--prefix="${D}/opt/"${RUST_PROVIDER}"" \
		--disable-ldconfig \
		|| die

	cd "${D}"/opt/"${RUST_PROVIDER}"/lib/rustlib || die
	rm install.log || die
	rm rust-installer-version || die
	rm components || die
	rm uninstall.sh || die
}

pkg_postinst() {
	eselect rust update --if-unset

}

pkg_postrm() {
	eselect rust unset --if-invalid
}

