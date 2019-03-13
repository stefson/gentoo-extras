# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit eutils bash-completion-r1 rust-toolchain versionator toolchain-funcs

MY_P="rust-std-${PV}"

DESCRIPTION="std libraries for rust"
HOMEPAGE="https://www.rust-lang.org/"
SRC_URI="$(rust_all_arch_uris ${MY_P})"

LICENSE="|| ( MIT Apache-2.0 ) BSD-1 BSD-2 BSD-4 UoI-NCSA"
SLOT="stable"
KEYWORDS="~amd64 ~arm64 ~x86"
IUSE="cpu_flags_x86_sse2 doc libressl"

DEPEND=""
RDEPEND=">=app-eselect/eselect-rust-0.3_pre20150425
	=dev-lang/rust-bin-1.29.2-r1
	!dev-lang/rust:0"
REQUIRED_USE="x86? ( cpu_flags_x86_sse2 )"

QA_PREBUILT="
	opt/${P}/lib/rustlib/*/lib/*.so
	opt/${P}/lib/rustlib/*/lib/*.rlib*
"

src_unpack() {
	default
	mv "${WORKDIR}/${MY_P}-$(rust_abi)" "${S}" || die
}

src_install() {
	local std=$(grep 'std' ./components)
	local components="${std}"
	./install.sh \
		--components="${components}" \
		--disable-verify \
		--prefix="${D}/opt/${P}" \
		--mandir="${D}/usr/share/${P}/man" \
		--disable-ldconfig \
		|| die

}

pkg_postinst() {
	eselect rust update --if-unset

	elog "Rust installs a helper script for calling GDB now,"
	elog "for your convenience it is installed under /usr/bin/rust-gdb-bin-${PV},"

	if has_version app-editors/emacs || has_version app-editors/emacs-vcs; then
		elog "install app-emacs/rust-mode to get emacs support for rust."
	fi

	if has_version app-editors/gvim || has_version app-editors/vim; then
		elog "install app-vim/rust-vim to get vim support for rust."
	fi

	if has_version 'app-shells/zsh'; then
		elog "install app-shells/rust-zshcomp to get zsh completion for rust."
	fi
}

pkg_postrm() {
	eselect rust unset --if-invalid
}

