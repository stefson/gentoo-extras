# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils bash-completion-r1 rust-toolchain versionator toolchain-funcs

MY_P="rust-std-${PV}"

DESCRIPTION="std libraries for rust"
HOMEPAGE="https://www.rust-lang.org/"
SRC_URI="$(rust_all_arch_uris ${MY_P})"

#RUSTHOST="armv7-unknown-linux-gnueabihf"
RUSTHOST="thumbv7neon-unknown-linux-gnueabihf"
RUST_PROVIDER="rust-bin-1.36.0"

#SRC_URI="https://static.rust-lang.org/dist/"${P}"-"${RUSTHOST}".tar.xz"

LICENSE="|| ( MIT Apache-2.0 ) BSD-1 BSD-2 BSD-4 UoI-NCSA"
SLOT="stable"
KEYWORDS="~amd64"
IUSE="+rust-std-thumbv7-neon"

DEPEND=""
RDEPEND="app-eselect/eselect-rust
	=dev-lang/rust-bin-1.36.0
	!dev-lang/rust:0"
REQUIRED_USE=""

QA_PREBUILT="
	opt/"${RUST_PROVIDER}"/lib/rustlib/*/lib/*.so
	opt/"${RUST_PROVIDER}"/lib/rustlib/*/lib/*.rlib*
"

src_unpack() {
	default
	mv "${WORKDIR}/${MY_P}-"${RUSTHOST}"" "${S}" || die
}

src_prepare() {
	default
	cd "${S}"/"${PN}"-"${RUSTHOST}"/lib/rustlib/"${RUSTHOST}"/lib || die
	armv7a-unknown-linux-gnueabihf-strip *.so || die
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

