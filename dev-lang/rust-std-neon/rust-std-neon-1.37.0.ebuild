# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils bash-completion-r1 versionator toolchain-funcs

MY_P="rust-std-${PV}"

DESCRIPTION="std libraries for rust"
HOMEPAGE="https://www.rust-lang.org/"

SRC_URI="thumbv7-neon-std? ( https://static.rust-lang.org/dist/rust-std-"${PV}"-thumbv7neon-unknown-linux-gnueabihf.tar.xz )"

RUST_PROVIDER="rust-bin-1.37.0"

LICENSE="|| ( MIT Apache-2.0 ) BSD-1 BSD-2 BSD-4 UoI-NCSA"
SLOT="stable"
KEYWORDS="~amd64 ~arm"
IUSE="+thumbv7-neon-std"

DEPEND=""
RDEPEND="app-eselect/eselect-rust
	=dev-lang/rust-bin-1.37.0*
	!dev-lang/rust:0"

QA_PREBUILT="
	opt/"${RUST_PROVIDER}"/lib/rustlib/*/lib/*.so
	opt/"${RUST_PROVIDER}"/lib/rustlib/*/lib/*.rlib*
"

pkg_setup() {
	if use thumbv7-neon-std ; then
		RUSTHOST=thumbv7neon-unknown-linux-gnueabihf
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
	cd "${S}"/rust-std-"${RUSTHOST}"/lib/rustlib/"${RUSTHOST}"/lib || die
	if use amd64 ; then
		if use thumbv7-neon-std ; then
			armv7a-unknown-linux-gnueabihf-strip *.so || die
		fi
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
