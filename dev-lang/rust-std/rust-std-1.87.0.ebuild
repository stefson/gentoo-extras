# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit bash-completion-r1 toolchain-funcs

MY_P="rust-std-${PV}"

DESCRIPTION="std libraries for rust"
HOMEPAGE="https://www.rust-lang.org/"

SRC_URI="armv5tel-softfloat-std? ( https://static.rust-lang.org/dist/"${P}"-armv5te-unknown-linux-gnueabi.tar.xz )
	armv6j-softfloat-std? ( https://static.rust-lang.org/dist/"${P}"-arm-unknown-linux-gnueabi.tar.xz )
	armv6j-hardfloat-std? ( https://static.rust-lang.org/dist/"${P}"-arm-unknown-linux-gnueabihf.tar.xz )
	armv7-hardfloat-std? (  https://static.rust-lang.org/dist/"${P}"-armv7-unknown-linux-gnueabihf.tar.xz )
	aarch64-gnu-std? ( https://static.rust-lang.org/dist/"${P}"-aarch64-unknown-linux-gnu.tar.xz ) 
	wasm32-unknown-unknown-std? ( https://static.rust-lang.org/dist/"${P}"-wasm32-unknown-unknown.tar.xz )
	i686-linux-gnu-std? ( https://static.rust-lang.org/dist/"${P}"-i686-unknown-linux-gnu.tar.xz )"

RUST_PROVIDER="rust-bin-${PV}"

LICENSE="|| ( MIT Apache-2.0 ) BSD-1 BSD-2 BSD-4 UoI-NCSA"
SLOT="stable"
KEYWORDS="~amd64"
IUSE="aarch64-gnu-std armv5tel-softfloat-std armv6j-softfloat-std armv6j-hardfloat-std +armv7-hardfloat-std wasm32-unknown-unknown-std wasm32-wasi-std i686-linux-gnu-std"

DEPEND=""
RDEPEND="app-eselect/eselect-rust
	~dev-lang/rust-bin-${PV}
	!dev-lang/rust:0"

QA_PREBUILT="
	opt/"${RUST_PROVIDER}"/lib/rustlib/*/lib/*.so
	opt/"${RUST_PROVIDER}"/lib/rustlib/*/lib/*.rlib*
"

pkg_setup() {
	if use armv5tel-softfloat-std ; then
		RUSTHOST=armv5te-unknown-linux-gnueabi
	elif use armv6j-softfloat-std ; then
		RUSTHOST=arm-unknown-linux-gnueabi
	elif use armv6j-hardfloat-std ; then
		RUSTHOST=arm-unknown-linux-gnueabihf
	elif use armv7-hardfloat-std ; then
		RUSTHOST=armv7-unknown-linux-gnueabihf
	elif use aarch64-gnu-std ; then
		RUSTHOST=aarch64-unknown-linux-gnu
	elif use i686-linux-gnu-std ; then
		RUSTHOST=i686-unknown-linux-gnu
	elif use wasm32-unknown-unknown-std ; then
		RUSTHOST=wasm32-unknown-unknown
	fi

	ewarn "please make sure to have a full cross-compile"
	ewarn "toolchain for your target installed via crossdev"
	ewarn "for stripping of *.so libs to work."
}

src_unpack() {
	default
	mv "${WORKDIR}/${MY_P}-"${RUSTHOST}"" "${S}" || die
}

src_prepare() {
	default
	cd "${S}"/"${PN}"-"${RUSTHOST}"/lib/rustlib/"${RUSTHOST}"/lib || die
	if use armv5tel-softfloat-std ; then
		armv5tel-unknown-linux-gnueabi-strip *.so || die
	elif use armv6j-softfloat-std ; then
		armv6j-unknown-linux-gnueabi-strip *.so || die
	elif use armv6j-hardfloat-std ; then
		armv6j-unknown-linux-gnueabihf-strip *.so || die 
	elif use armv7-hardfloat-std ; then
		armv7a-unknown-linux-gnueabihf-strip *.so || die
	elif use aarch64-gnu-std ; then
		aarch64-unknown-linux-gnu-strip *.so || die
	elif use i686-linux-gnu-std ; then
		strip *.so || die
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

