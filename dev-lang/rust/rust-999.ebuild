# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..13} )

inherit check-reqs estack flag-o-matic llvm multiprocessing multilib-build python-any-r1 rust-toolchain toolchain-funcs git-r3

SLOT="beta"
MY_P="rust-beta"
EGIT_REPO_URI="https://github.com/rust-lang/rust.git"
EGIT_BRANCH="beta"

EGIT_CHECKOUT_DIR="${MY_P}-src"
#KEYWORDS=""

CHOST_arm64=aarch64-unknown-linux-gnu
CHOST_arm=armv7-unknown-linux-gnu
CHOST_amd64=x86_64-unknown-linux-gnu
#CHOST_amd64=x86_64-gentoo-linux-musl

DESCRIPTION="Systems programming language from Mozilla"
HOMEPAGE="https://www.rust-lang.org/"

RESTRICT="network-sandbox"

ALL_LLVM_TARGETS=( AArch64 AMDGPU ARC ARM AVR BPF CSKY DirectX Hexagon Lanai
	LoongArch M68k Mips MSP430 NVPTX PowerPC RISCV Sparc SPIRV SystemZ VE
	WebAssembly X86 XCore Xtensa )
ALL_LLVM_TARGETS=( "${ALL_LLVM_TARGETS[@]/#/llvm_targets_}" )
LLVM_TARGET_USEDEPS=${ALL_LLVM_TARGETS[@]/%/?}

LICENSE="|| ( MIT Apache-2.0 ) BSD BSD-1 BSD-2 BSD-4"

IUSE="clippy cpu_flags_x86_sse2 debug doc rustfmt system-bootstrap system-llvm wasm sanitize miri zsh-completion ${ALL_LLVM_TARGETS[*]}"

# Please keep the LLVM dependency block separate. Since LLVM is slotted,
# we need to *really* make sure we're not pulling one than more slot
# simultaneously.

# How to use it:
# 1. List all the working slots (with min versions) in ||, newest first.
# 2. Update the := to specify *max* version, e.g. < 9.
# 3. Specify LLVM_MAX_SLOT, e.g. 8.
LLVM_DEPEND="
	|| (
		sys-devel/llvm:18[llvm_targets_WebAssembly?]
		wasm? ( >=sys-devel/lld-18 )
	)
	<sys-devel/llvm-19:=
"
LLVM_MAX_SLOT=18

# to bootstrap we need at least exactly previous version, or same.
# most of the time previous versions fail to bootstrap with newer
# for example 1.47.x, requires at least 1.46.x, 1.47.x is ok,
# but it fails to bootstrap with 1.48.x
# https://github.com/rust-lang/rust/blob/${PV}/src/stage0.txt
RUST_DEP_PREV="1.62.0"
#RUST_DEP_PREV="$(ver_cut 1).$(($(ver_cut 2) - 1))*"
#RUST_DEP_CURR="$(ver_cut 1).$(ver_cut 2)*"
BOOTSTRAP_DEPEND="||
	(
		=dev-lang/rust-"${RUST_DEP_PREV}"
	)
"

COMMON_DEPEND="
	>=app-arch/xz-utils-5.2
	net-misc/curl:=[http2,ssl]
	elibc_musl? ( >=sys-libs/musl-1.2.1-r2 )
	sys-libs/zlib:=
	dev-libs/openssl:0=
	system-llvm? (
		${LLVM_DEPEND}
	)
"

DEPEND="${COMMON_DEPEND}
	${PYTHON_DEPS}
	|| (
		>=sys-devel/gcc-4.7
		>=sys-devel/clang-3.5
	)
	dev-build/cmake
"

RDEPEND="${COMMON_DEPEND}
	app-eselect/eselect-rust
	system-bootstrap? ( ${BOOTSTRAP_DEPEND} )
"

REQUIRED_USE="|| ( ${ALL_LLVM_TARGETS[*]} )
	wasm? ( llvm_targets_WebAssembly )
	x86? ( cpu_flags_x86_sse2 )
	?? ( system-llvm sanitize )
"

# An rmeta file is custom binary format that contains the metadata for the crate.
# rmeta files do not support linking, since they do not contain compiled object files.
# so we can safely silence the warning for this QA check.
QA_EXECSTACK="usr/lib/${PN}/${PV}/lib/rustlib/*/lib*.rlib:lib.rmeta"

# tests need a bit more work, currently they are causing multiple
# re-compilations and somewhat fragile.
RESTRICT="test network-sandbox"

S="${WORKDIR}/${MY_P}-src"

#PATCHES=( )

toml_usex() {
	usex "$1" true false
}

pre_build_checks() {
	CHECKREQS_DISK_BUILD="7G"
	eshopts_push -s extglob
	if is-flagq '-g?(gdb)?([1-9])'; then
		CHECKREQS_DISK_BUILD="10G"
	fi
	eshopts_pop
	check-reqs_pkg_setup
}

pkg_pretend() {
	pre_build_checks
}

pkg_setup() {
	unset SUDO_USER

	pre_build_checks
	python-any-r1_pkg_setup
	
	if use system-llvm; then
		EGIT_SUBMODULES=( "*" "-src/llvm-project" )
		llvm_pkg_setup
	fi
}

src_prepare() {

	if ! use system-bootstrap; then
		local rust_stage0_root="${WORKDIR}"/rust-stage0

	fi
	default
}

src_unpack() {
	git-r3_src_unpack
}

src_configure() {
	local rust_target="" rust_targets="" arch_cflags

	# Collect rust target names to compile standard libs for all ABIs.
	for v in $(multilib_get_enabled_abi_pairs); do
		rust_targets="${rust_targets},\"$(rust_abi $(get_abi_CHOST ${v##*.}))\""
	done
	if use wasm; then
		rust_targets="${rust_targets},\"wasm32-unknown-unknown\""
	fi
	rust_targets="${rust_targets#,}"

	local extended="true" tools="\"cargo\","
	if use clippy; then
		tools="\"clippy\",$tools"
	fi
	if use rustfmt; then
		tools="\"rustfmt\",$tools"
	fi
	if use miri; then
		tools="\"miri\",$tools"
	fi

#	local rust_stage0_root="${WORKDIR}"/rust-stage0

	local rust_stage0_root
	if use system-bootstrap; then
		local printsysroot
		printsysroot="$(rustc --print sysroot || die "Can't determine rust's sysroot")"
		rust_stage0_root="${printsysroot}"
	else
		rust_stage0_root="${WORKDIR}"/rust-stage0
	fi

	rust_target="$(rust_abi)"

	cat <<- EOF > "${S}"/config.toml
		[llvm]
		optimize = $(toml_usex !debug)
		release-debuginfo = $(toml_usex debug)
		assertions = $(toml_usex debug)
		targets = "${LLVM_TARGETS// /;}"
		experimental-targets = ""
		link-shared = $(toml_usex system-llvm)
		download-ci-llvm = false
		[build]
		build = "${rust_target}"
		host = ["${rust_target}"]
		target = [${rust_targets}]
		docs = $(toml_usex doc)
		submodules = false
		python = "${EPYTHON}"
		locked-deps = true
		vendor = false
		sanitizers = $(toml_usex sanitize)
		extended = ${extended}
		tools = [${tools}]
		verbose = 2
		[install]
		prefix = "${EPREFIX}/usr"
		libdir = "$(get_libdir)/${P}"
		docdir = "share/doc/${P}"
		mandir = "share/${P}/man"
		[rust]
		optimize = $(toml_usex !debug)
		debuginfo-level = $(usex debug 2 0)
		debug-assertions = $(toml_usex debug)
		default-linker = "$(tc-getCC)"
		rpath = false
		omit-git-hash = false
		lld = $(usex system-llvm false $(toml_usex wasm))
		llvm-tools = $(usex system-llvm false true)
	EOF

	for v in $(multilib_get_enabled_abi_pairs); do
		rust_target=$(rust_abi $(get_abi_CHOST ${v##*.}))
		arch_cflags="$(get_abi_CFLAGS ${v##*.})"

		cat <<- EOF >> "${S}"/config.env
			CFLAGS_${rust_target}=${arch_cflags}
		EOF

		cat <<- EOF >> "${S}"/config.toml
			[target.${rust_target}]
			cc = "$(tc-getBUILD_CC)"
			cxx = "$(tc-getBUILD_CXX)"
			linker = "$(tc-getCC)"
			ar = "$(tc-getAR)"
		EOF
		if use system-llvm; then
			cat <<- EOF >> "${S}"/config.toml
				llvm-config = "$(get_llvm_prefix "${LLVM_MAX_SLOT}")/bin/llvm-config"
			EOF
		fi
	done

	if use wasm; then
		cat <<- EOF >> "${S}"/config.toml
			[target.wasm32-unknown-unknown]
			linker = "$(usex system-llvm lld rust-lld)"
		EOF
	fi
}

src_compile() {
	env $(cat "${S}"/config.env)\
		"${EPYTHON}" ./x.py build -vv --config="${S}"/config.toml -j$(makeopts_jobs) || die
}

src_install() {
	local rust_target abi_libdir

	env DESTDIR="${D}" "${EPYTHON}" ./x.py install -vv -j$(makeopts_jobs) --config="${S}"/config.toml || die

	mv "${ED}/usr/bin/rustc" "${ED}/usr/bin/rustc-${PV}" || die
	mv "${ED}/usr/bin/rustdoc" "${ED}/usr/bin/rustdoc-${PV}" || die
	mv "${ED}/usr/bin/rust-gdb" "${ED}/usr/bin/rust-gdb-${PV}" || die
	mv "${ED}/usr/bin/rust-gdbgui" "${ED}/usr/bin/rust-gdbgui-${PV}" || die
	mv "${ED}/usr/bin/rust-lldb" "${ED}/usr/bin/rust-lldb-${PV}" || die
	mv "${ED}/usr/bin/cargo" "${ED}/usr/bin/cargo-${PV}" || die
	if use clippy; then
		mv "${ED}/usr/bin/clippy-driver" "${ED}/usr/bin/clippy-driver-${PV}" || die
		mv "${ED}/usr/bin/cargo-clippy" "${ED}/usr/bin/cargo-clippy-${PV}" || die
	fi
	if use rustfmt; then
		mv "${ED}/usr/bin/rustfmt" "${ED}/usr/bin/rustfmt-${PV}" || die
		mv "${ED}/usr/bin/cargo-fmt" "${ED}/usr/bin/cargo-fmt-${PV}" || die
	fi
	if use miri; then
		mv "${ED}/usr/bin/miri" "${ED}/usr/bin/miri-${PV}" || die
		mv "${ED}/usr/bin/cargo-miri" "${ED}/usr/bin/cargo-miri-${PV}" || die
	fi
	if ! use zsh-completion; then
		rm "${ED}/usr/share/zsh/site-functions/_cargo" # fix https://bugs.gentoo.org/675026
	fi

	# Copy shared library versions of standard libraries for all targets
	# into the system's abi-dependent lib directories because the rust
	# installer only does so for the native ABI.
	for v in $(multilib_get_enabled_abi_pairs); do
		if [ ${v##*.} = ${DEFAULT_ABI} ]; then
			continue
		fi
		abi_libdir=$(get_abi_LIBDIR ${v##*.})
		rust_target=$(rust_abi $(get_abi_CHOST ${v##*.}))
		mkdir -p "${ED}/usr/${abi_libdir}/${P}"
		cp "${ED}/usr/$(get_libdir)/${P}/rustlib/${rust_target}/lib"/*.so \
		   "${ED}/usr/${abi_libdir}/${P}" || die
	done

	dodoc COPYRIGHT

	cat <<-EOF > "${T}"/50${P}
		LDPATH="${EPREFIX}/usr/$(get_libdir)/${P}"
		MANPATH="${EPREFIX}/usr/share/${P}/man"
	EOF
	doenvd "${T}"/50${P}

	# note: eselect-rust adds EROOT to all paths below
	cat <<-EOF > "${T}/provider-${P}"
		/usr/bin/rustdoc
		/usr/bin/rust-gdb
		/usr/bin/rust-gdbgui
		/usr/bin/rust-lldb
	EOF
	echo /usr/bin/cargo >> "${T}/provider-${P}"
	if use clippy; then
		echo /usr/bin/clippy-driver >> "${T}/provider-${P}"
		echo /usr/bin/cargo-clippy >> "${T}/provider-${P}"
	fi
	if use rustfmt; then
		echo /usr/bin/rustfmt >> "${T}/provider-${P}"
		echo /usr/bin/cargo-fmt >> "${T}/provider-${P}"
	fi
	if use miri; then
		echo /usr/bin/miri >> "${T}/provider-${P}"
		echo /usr/bin/cargo-miri >> "${T}/provider-${P}"
	fi
	dodir /etc/env.d/rust
	insinto /etc/env.d/rust
	doins "${T}/provider-${P}"
}

pkg_postinst() {
	eselect rust update --if-unset

	elog "Rust installs a helper script for calling GDB and LLDB,"
	elog "for your convenience it is installed under /usr/bin/rust-{gdb,lldb}-${PV}."

	ewarn "cargo is now installed from dev-lang/rust{,-bin} instead of dev-util/cargo."
	ewarn "This might have resulted in a dangling symlink for /usr/bin/cargo on some"
	ewarn "systems. This can be resolved by calling 'sudo eselect rust set ${P}'."

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
	eselect rust cleanup
}
