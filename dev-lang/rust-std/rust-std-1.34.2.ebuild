# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils bash-completion-r1 rust-toolchain versionator toolchain-funcs

MY_P="rust-std-${PV}"

DESCRIPTION="std libraries for rust"
HOMEPAGE="https://www.rust-lang.org/"
#SRC_URI="$(rust_all_arch_uris ${MY_P})"

RUSTHOST="armv7-unknown-linux-gnueabihf"
#RUSTHOST="thumbv7neon-unknown-linux-gnueabihf"
RUST_PROVIDER="rust-bin-1.34.2"

SRC_URI="https://static.rust-lang.org/dist/"${P}"-"${RUSTHOST}".tar.xz"

LICENSE="|| ( MIT Apache-2.0 ) BSD-1 BSD-2 BSD-4 UoI-NCSA"
SLOT="stable"
KEYWORDS="~amd64"
IUSE="cpu_flags_x86_sse2 doc libressl +rust-std-armv7-h"

DEPEND=""
RDEPEND=">=app-eselect/eselect-rust-0.3_pre20150425
	=dev-lang/rust-bin-1.34.2
	!dev-lang/rust:0"
REQUIRED_USE="x86? ( cpu_flags_x86_sse2 )"

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
	local std=$(grep 'std' ./components)
	local components="${std}"
	./install.sh \
		--components="${components}" \
		--disable-verify \
		--prefix="${D}/opt/"${RUST_PROVIDER}"" \
		--disable-ldconfig \
		|| die

# INSTALL_MASK="${INSTALL_MASK} install.log rust-installer-version components uninstall.sh"

#	rm "${S}"/opt/rust-std-1.30.1/lib/rustlib/components || die
#	rm "${S}"/uninstall.sh || die
#	rm "${S}"/rust-installer-version || die
#	rm "${S}"/opt/rust-std-1.30.1/lib/rustlib/install.log || die

}

pkg_postinst() {
	eselect rust update --if-unset

}

pkg_postrm() {
	eselect rust unset --if-invalid
}

