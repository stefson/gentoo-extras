# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
VIRTUALX_REQUIRED="pgo"
WANT_AUTOCONF="2.1"
MOZ_ESR="1"

PYTHON_COMPAT=( python3_{6,7,8,9} )
PYTHON_REQ_USE='ncurses,sqlite,ssl,threads(+)'

# This list can be updated with scripts/get_langs.sh from the mozilla overlay
MOZ_LANGS=( ach af an ar ast az be bg bn br bs ca cak cs cy da de dsb
el en en-CA en-GB en-US eo es-AR es-CL es-ES es-MX et eu fa ff fi fr
fy-NL ga-IE gd gl gn gu-IN he hi-IN hr hsb hu hy-AM ia id is it ja ka
kab kk km kn ko lij lt lv mk mr ms my nb-NO nl nn-NO oc pa-IN pl pt-BR
pt-PT rm ro ru si sk sl son sq sr sv-SE ta te th tr uk ur uz vi xh
zh-CN zh-TW )

# Convert the ebuild version to the upstream mozilla version, used by mozlinguas
MOZ_PV="${PV/_alpha/a}" # Handle alpha for SRC_URI
MOZ_PV="${MOZ_PV/_beta/b}" # Handle beta for SRC_URI
MOZ_PV="${MOZ_PV%%_rc*}" # Handle rc for SRC_URI

if [[ ${MOZ_ESR} == 1 ]] ; then
	# ESR releases have slightly different version numbers
	MOZ_PV="${MOZ_PV}esr"
fi

# Patch version
PATCH="${PN}-68.0-patches-15"

MOZ_HTTP_URI="https://archive.mozilla.org/pub/${PN}/releases"
MOZ_SRC_URI="${MOZ_HTTP_URI}/${MOZ_PV}/source/${PN}-${MOZ_PV}.source.tar.xz"

if [[ "${PV}" == *_rc* ]]; then
	MOZ_HTTP_URI="https://archive.mozilla.org/pub/${PN}/candidates/${MOZ_PV}-candidates/build${PV##*_rc}"
	MOZ_LANGPACK_PREFIX="linux-i686/xpi/"
	MOZ_SRC_URI="${MOZ_HTTP_URI}/source/${PN}-${MOZ_PV}.source.tar.xz -> $P.tar.xz"
fi

LLVM_MAX_SLOT=10

inherit check-reqs eapi7-ver flag-o-matic toolchain-funcs eutils \
		gnome2-utils llvm mozcoreconf-v6 pax-utils xdg-utils \
		autotools mozlinguas-v2 multiprocessing virtualx

DESCRIPTION="Firefox Web Browser"
HOMEPAGE="https://www.mozilla.com/firefox"

KEYWORDS="amd64 ~arm ~x86"

SLOT="0"
LICENSE="MPL-2.0 GPL-2 LGPL-2.1"
IUSE="bindist clang cpu_flags_x86_avx2 dbus debug eme-free geckodriver
	+gmp-autoupdate hardened hwaccel jack lto cpu_flags_arm_neon
	+openh264 pgo pulseaudio +screenshot selinux startup-notification +system-av1
	+system-harfbuzz +system-icu +system-jpeg +system-libevent
	+system-sqlite +system-libvpx +system-webp test wayland wifi"

REQUIRED_USE="pgo? ( lto )
	wifi? ( dbus )"

RESTRICT="!bindist? ( bindist )
	!test? ( test )"

PATCH_URIS=( https://dev.gentoo.org/~{anarchy,axs,polynomial-c,whissi}/mozilla/patchsets/${PATCH}.tar.xz )
SRC_URI="${SRC_URI}
	${MOZ_SRC_URI}
	${PATCH_URIS[@]}"

CDEPEND="
	>=dev-libs/nss-3.44.4
	>=dev-libs/nspr-4.21
	dev-libs/atk
	dev-libs/expat
	>=x11-libs/cairo-1.10[X]
	>=x11-libs/gtk+-2.18:2
	>=x11-libs/gtk+-3.4.0:3[X]
	x11-libs/gdk-pixbuf
	>=x11-libs/pango-1.22.0
	>=media-libs/libpng-1.6.35:0=[apng]
	>=media-libs/mesa-10.2:*
	media-libs/fontconfig
	>=media-libs/freetype-2.4.10
	kernel_linux? ( !pulseaudio? ( media-libs/alsa-lib ) )
	virtual/freedesktop-icon-theme
	dbus? (
		>=sys-apps/dbus-0.60
		>=dev-libs/dbus-glib-0.72
	)
	startup-notification? ( >=x11-libs/startup-notification-0.8 )
	>=x11-libs/pixman-0.19.2
	>=dev-libs/glib-2.26:2
	>=sys-libs/zlib-1.2.3
	>=dev-libs/libffi-3.0.10:=
	media-video/ffmpeg
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrender
	x11-libs/libXt
	system-av1? (
		>=media-libs/dav1d-0.3.0:=
		>=media-libs/libaom-1.0.0:=
	)
	system-harfbuzz? (
		>=media-libs/harfbuzz-2.4.0:0=
		>=media-gfx/graphite2-1.3.13
	)
	system-icu? ( >=dev-libs/icu-63.1:= )
	system-jpeg? ( >=media-libs/libjpeg-turbo-1.2.1 )
	system-libevent? ( >=dev-libs/libevent-2.0:0=[threads] )
	system-libvpx? ( =media-libs/libvpx-1.7*:0=[postproc] )
	system-sqlite? ( >=dev-db/sqlite-3.28.0:3[secure-delete,debug=] )
	system-webp? ( >=media-libs/libwebp-1.0.2:0= )
	wifi? (
		kernel_linux? (
			>=sys-apps/dbus-0.60
			>=dev-libs/dbus-glib-0.72
			net-misc/networkmanager
		)
	)
	jack? ( virtual/jack )
	selinux? ( sec-policy/selinux-mozilla )"

RDEPEND="${CDEPEND}
	jack? ( virtual/jack )
	openh264? ( media-libs/openh264:*[plugin] )
	pulseaudio? (
		|| (
			media-sound/pulseaudio
			>=media-sound/apulse-0.1.9
		)
	)
	selinux? ( sec-policy/selinux-mozilla )"

DEPEND="${CDEPEND}
	app-arch/zip
	app-arch/unzip
	>=dev-util/cbindgen-0.8.7
	>=net-libs/nodejs-8.11.0
	>=sys-devel/binutils-2.30
	sys-apps/findutils
	virtual/pkgconfig
	>=virtual/rust-1.34.0
	|| (
		(
			sys-devel/clang:10
			!clang? ( sys-devel/llvm:10 )
			clang? (
				=sys-devel/lld-10*
				sys-devel/llvm:10[gold]
				pgo? ( =sys-libs/compiler-rt-sanitizers-10*[profile] )
			)
		)
		(
			sys-devel/clang:9
			!clang? ( sys-devel/llvm:9 )
			clang? (
				=sys-devel/lld-9*
				sys-devel/llvm:9[gold]
				pgo? ( =sys-libs/compiler-rt-sanitizers-9*[profile] )
			)
		)
		(
			sys-devel/clang:8
			!clang? ( sys-devel/llvm:8 )
			clang? (
				=sys-devel/lld-8*
				sys-devel/llvm:8[gold]
				pgo? ( =sys-libs/compiler-rt-sanitizers-8*[profile] )
			)
		)
	)
	pulseaudio? ( media-sound/pulseaudio )
	wayland? ( >=x11-libs/gtk+-3.11:3[wayland] )
	amd64? ( >=dev-lang/yasm-1.1 virtual/opengl )
	x86? ( >=dev-lang/yasm-1.1 virtual/opengl )
	!system-av1? (
		amd64? ( >=dev-lang/nasm-2.13 )
		x86? ( >=dev-lang/nasm-2.13 )
	)"

S="${WORKDIR}/firefox-${PV%_*}"

BUILD_OBJ_DIR="${S}/ff"

# allow GMP_PLUGIN_LIST to be set in an eclass or
# overridden in the enviromnent (advanced hackers only)
if [[ -z $GMP_PLUGIN_LIST ]] ; then
	GMP_PLUGIN_LIST=( gmp-gmpopenh264 gmp-widevinecdm )
fi

llvm_check_deps() {
	if ! has_version --host-root "sys-devel/clang:${LLVM_SLOT}" ; then
		ewarn "sys-devel/clang:${LLVM_SLOT} is missing! Cannot use LLVM slot ${LLVM_SLOT} ..." >&2
		return 1
	fi

	if use clang ; then
		if ! has_version --host-root "=sys-devel/lld-${LLVM_SLOT}*" ; then
			ewarn "=sys-devel/lld-${LLVM_SLOT}* is missing! Cannot use LLVM slot ${LLVM_SLOT} ..." >&2
			return 1
		fi

		if use pgo ; then
			if ! has_version --host-root "=sys-libs/compiler-rt-sanitizers-${LLVM_SLOT}*" ; then
				ewarn "=sys-libs/compiler-rt-sanitizers-${LLVM_SLOT}* is missing! Cannot use LLVM slot ${LLVM_SLOT} ..." >&2
				return 1
			fi
		fi
	fi

	einfo "Will use LLVM slot ${LLVM_SLOT}!" >&2
}

pkg_pretend() {
	if use pgo ; then
		if ! has usersandbox $FEATURES ; then
			die "You must enable usersandbox as X server can not run as root!"
		fi
	fi

	# Ensure we have enough disk space to compile
	if use pgo || use lto || use debug || use test ; then
		CHECKREQS_DISK_BUILD="8G"
	else
		CHECKREQS_DISK_BUILD="4G"
	fi

	check-reqs_pkg_pretend
}

pkg_setup() {
	moz_pkgsetup

	# Ensure we have enough disk space to compile
	if use pgo || use lto || use debug || use test ; then
		CHECKREQS_DISK_BUILD="8G"
	else
		CHECKREQS_DISK_BUILD="4G"
	fi

	check-reqs_pkg_setup

	# Avoid PGO profiling problems due to enviroment leakage
	# These should *always* be cleaned up anyway
	unset DBUS_SESSION_BUS_ADDRESS \
		DISPLAY \
		ORBIT_SOCKETDIR \
		SESSION_MANAGER \
		XDG_CACHE_HOME \
		XDG_SESSION_COOKIE \
		XAUTHORITY

	if ! use bindist ; then
		einfo
		elog "You are enabling official branding. You may not redistribute this build"
		elog "to any users on your network or the internet. Doing so puts yourself into"
		elog "a legal problem with Mozilla Foundation."
		elog "You can disable it by emerging ${PN} _with_ the bindist USE-flag."
	fi

	addpredict /proc/self/oom_score_adj

	llvm_pkg_setup
}

src_unpack() {
	default

	# Unpack language packs
	mozlinguas_src_unpack
}

src_prepare() {
	eapply "${WORKDIR}/firefox"

	if use arm ; then
	# moz 1526653, this copies over missing bits directly from linux headers
	eapply "${FILESDIR}/"firefox-68.0_arm-fp-wasm-fixes.patch

	# https://bugzilla.mozilla.org/show_bug.cgi?id=1542622
	# this is needed to make firefox-67.0 play nicely with rust-1.35.0 + llvm-7 + gcc-8.3.0 + cbindgen-0.8x in cross
	# todo: simplify, open bug
	eapply "${FILESDIR}/"firefox-67.0-cross-fix-stddef-not-found.patch
	fi

	if use lto ; then
		eapply "${FILESDIR}/"${PN}-68.0-fix-lto.patch
	fi

	eapply "${FILESDIR}/"firefox-68.0-update-mp4parse.patch

	# https://bugzilla.mozilla.org/show_bug.cgi?id=1581419
	eapply "${FILESDIR}/"firefox-69.0-arrayvec.patch

	# this fixes build with USE="clang" and libstdc++ 
	# upstream still pending #1594027 
	# this was fixed in 75.0, keeping the backport
	eapply "${FILESDIR}/"firefox-73.0_fix_llvm9.patch

	# XXX there is a bug in rust, which blocks USE="neon" see mozilla #1557350 
	# error is: The rust compiler host (armv7-unknown-linux-gnueabihf) is not suitable for 
	# the configure host (armv7-unknown-linux-gnueabihf/thumbv7neon-unknown-linux-gnueabihf).
	# v67.0 was fine, error is from build/moz.configure/rust.configure

	eapply "${FILESDIR}/"privacy-patchset-68/firefox-60-disable-data-sharing-infobar.patch
	eapply "${FILESDIR}/"privacy-patchset-68/firefox-60-disable-first-run-privacy-policy.patch
	eapply "${FILESDIR}/"privacy-patchset-68/firefox-60-disable-telemetry.patch

	# there's a compile error when using internal av1+aom _without_ neon and thumbv2 instructions 
	eapply "${FILESDIR}/"firefox-68.10.0-use-neon-flags-for-libaom.patch

	# Make LTO respect MAKEOPTS
	sed -i \
		-e "s/multiprocessing.cpu_count()/$(makeopts_jobs)/" \
		"${S}"/build/moz.configure/toolchain.configure \
		|| die "sed failed to set num_cores"

	# Allow user to apply any additional patches without modifing ebuild
	eapply_user

	einfo "Removing pre-built binaries ..."
	find "${S}"/third_party -type f \( -name '*.so' -o -name '*.o' \) -print -delete || die

	# Enable gnomebreakpad
	if use debug ; then
		sed -i -e "s:GNOME_DISABLE_CRASH_DIALOG=1:GNOME_DISABLE_CRASH_DIALOG=0:g" \
			"${S}"/build/unix/run-mozilla.sh || die "sed failed!"
	fi

	# Drop -Wl,--as-needed related manipulation for ia64 as it causes ld sefgaults, bug #582432
	if use ia64 ; then
		sed -i \
		-e '/^OS_LIBS += no_as_needed/d' \
		-e '/^OS_LIBS += as_needed/d' \
		"${S}"/widget/gtk/mozgtk/gtk2/moz.build \
		"${S}"/widget/gtk/mozgtk/gtk3/moz.build \
		|| die "sed failed to drop --as-needed for ia64"
	fi

	# Fix sandbox violations during make clean, bug 372817
	sed -e "s:\(/no-such-file\):${T}\1:g" \
		-i "${S}"/config/rules.mk \
		-i "${S}"/nsprpub/configure{.in,} \
		|| die

	# Don't exit with error when some libs are missing which we have in
	# system.
	sed '/^MOZ_PKG_FATAL_WARNINGS/s@= 1@= 0@' \
		-i "${S}"/browser/installer/Makefile.in || die

	# Don't error out when there's no files to be removed:
	sed 's@\(xargs rm\)$@\1 -f@' \
		-i "${S}"/toolkit/mozapps/installer/packager.mk || die

	# Keep codebase the same even if not using official branding
	sed '/^MOZ_DEV_EDITION=1/d' \
		-i "${S}"/browser/branding/aurora/configure.sh || die

	# rustfmt, a tool to format Rust code, is optional and not required to build Firefox.
	# However, when available, an unsupported version can cause problems, bug #669548
	sed -i -e "s@check_prog('RUSTFMT', add_rustup_path('rustfmt')@check_prog('RUSTFMT', add_rustup_path('rustfmt_do_not_use')@" \
		"${S}"/build/moz.configure/rust.configure || die

	# Autotools configure is now called old-configure.in
	# This works because there is still a configure.in that happens to be for the
	# shell wrapper configure script
	eautoreconf old-configure.in

	# Must run autoconf in js/src
	cd "${S}"/js/src || die
	autoconf-2.13
}

src_configure() {
	MEXTENSIONS="default"
	# Google API keys (see http://www.chromium.org/developers/how-tos/api-keys)
	# Note: These are for Gentoo Linux use ONLY. For your own distribution, please
	# get your own set of keys.
	_google_api_key=AIzaSyDEAOvatFo0eTgsV_ZlEzx0ObmepsMzfAc

	# Add information about TERM to output (build.log) to aid debugging
	# blessings problems
	if [[ -n "${TERM}" ]] ; then
		einfo "TERM is set to: \"${TERM}\""
	else
		einfo "TERM is unset."
	fi

	if use clang && ! tc-is-clang ; then
		# Force clang
		einfo "Enforcing the use of clang due to USE=clang ..."
		CC=${CHOST}-clang
		CXX=${CHOST}-clang++
		strip-unsupported-flags
	elif ! use clang && ! tc-is-gcc ; then
		# Force gcc
		einfo "Enforcing the use of gcc due to USE=-clang ..."
		CC=${CHOST}-gcc
		CXX=${CHOST}-g++
		strip-unsupported-flags
	fi

	####################################
	#
	# mozconfig, CFLAGS and CXXFLAGS setup
	#
	####################################

	mozconfig_init
	# common config components
	mozconfig_annotate 'system_libs' \
		--with-system-zlib \
		--with-system-bz2

	# Must pass release in order to properly select linker
	mozconfig_annotate 'Enable by Gentoo' --enable-release

	if use pgo ; then
		if ! has userpriv $FEATURES ; then
			eerror "Building firefox with USE=pgo and FEATURES=-userpriv is not supported!"
		fi
	fi

	# Don't let user's LTO flags clash with upstream's flags
	filter-flags -flto*

	if use lto ; then
		local show_old_compiler_warning=

		if use clang ; then
			# At this stage CC is adjusted and the following check will
			# will work
			if [[ $(clang-major-version) -lt 7 ]] ; then
				show_old_compiler_warning=1
			fi

			# Upstream only supports lld when using clang
			mozconfig_annotate "forcing ld=lld due to USE=clang and USE=lto" --enable-linker=lld
		else
			if [[ $(gcc-major-version) -lt 8 ]] ; then
				show_old_compiler_warning=1
			fi

			if ! use cpu_flags_x86_avx2 ; then
				local _gcc_version_with_ipa_cdtor_fix="8.3"
				local _current_gcc_version="$(gcc-major-version).$(gcc-minor-version)"

				if ver_test "${_current_gcc_version}" -lt "${_gcc_version_with_ipa_cdtor_fix}" ; then
					# due to a GCC bug, GCC will produce AVX2 instructions
					# even if the CPU doesn't support AVX2, https://gcc.gnu.org/ml/gcc-patches/2018-12/msg01142.html
					einfo "Disable IPA cdtor due to bug in GCC and missing AVX2 support -- triggered by USE=lto"
					append-ldflags -fdisable-ipa-cdtor
				else
					einfo "No GCC workaround required, GCC version is already patched!"
				fi
			else
				einfo "No GCC workaround required, system supports AVX2"
			fi

			# Linking only works when using ld.gold when LTO is enabled
			mozconfig_annotate "forcing ld=gold due to USE=lto" --enable-linker=gold
		fi

		if [[ -n "${show_old_compiler_warning}" ]] ; then
			# Checking compiler's major version uses CC variable. Because we allow
			# user to control used compiler via USE=clang flag, we cannot use
			# initial value. So this is the earliest stage where we can do this check
			# because pkg_pretend is not called in the main phase function sequence
			# environment saving is not guaranteed so we don't know if we will have
			# correct compiler until now.
			ewarn ""
			ewarn "USE=lto requires up-to-date compiler (>=gcc-8 or >=clang-7)."
			ewarn "You are on your own -- expect build failures. Don't file bugs using that unsupported configuration!"
			ewarn ""
			sleep 5
		fi

		mozconfig_annotate '+lto' --enable-lto=thin

		if use pgo ; then
			mozconfig_annotate '+pgo' MOZ_PGO=1
		fi
	else
		# Avoid auto-magic on linker
		if use clang ; then
			# This is upstream's default
			mozconfig_annotate "forcing ld=lld due to USE=clang" --enable-linker=lld
		elif tc-ld-is-gold ; then
			mozconfig_annotate "linker is set to gold" --enable-linker=gold
		else
			mozconfig_annotate "linker is set to bfd" --enable-linker=bfd
		fi
	fi

	# It doesn't compile on alpha without this LDFLAGS
	use alpha && append-ldflags "-Wl,--no-relax"

	# Add full relro support for hardened
	if use hardened ; then
		append-ldflags "-Wl,-z,relro,-z,now"
		mozconfig_use_enable hardened hardening
	fi

	# Modifications to better support ARM, bug 553364
	if use cpu_flags_arm_neon ; then
		mozconfig_annotate '' --with-fpu=neon

		if ! tc-is-clang ; then
			# thumb options aren't supported when using clang, bug 666966
			mozconfig_annotate '' --with-thumb=yes
			mozconfig_annotate '' --with-thumb-interwork=no
		fi
	fi

	if [[ ${CHOST} == armv*h* ]] ; then
		mozconfig_annotate '' --with-float-abi=hard
		if ! use system-libvpx ; then
			sed -i -e "s|softfp|hard|" \
				"${S}"/media/libvpx/moz.build
		fi
	fi

	mozconfig_use_enable !bindist official-branding

	mozconfig_use_enable debug
	mozconfig_use_enable debug tests
	if ! use debug ; then
		mozconfig_annotate 'disabled by Gentoo' --disable-debug-symbols
	else
		mozconfig_annotate 'enabled by Gentoo' --enable-debug-symbols
	fi
	# These are enabled by default in all mozilla applications
	mozconfig_annotate '' --with-system-nspr --with-nspr-prefix="${SYSROOT}${EPREFIX}"/usr
	mozconfig_annotate '' --with-system-nss --with-nss-prefix="${SYSROOT}${EPREFIX}"/usr
	mozconfig_annotate '' --x-includes="${SYSROOT}${EPREFIX}"/usr/include \
		--x-libraries="${SYSROOT}${EPREFIX}"/usr/$(get_libdir)
	mozconfig_annotate '' --prefix="${EPREFIX}"/usr
	mozconfig_annotate '' --libdir="${EPREFIX}"/usr/$(get_libdir)
	mozconfig_annotate '' --disable-crashreporter
	mozconfig_annotate 'Gentoo default' --with-system-png
	mozconfig_annotate '' --enable-system-ffi
	mozconfig_annotate '' --disable-gconf
	mozconfig_annotate '' --with-intl-api
	mozconfig_annotate '' --enable-system-pixman
	# Instead of the standard --build= and --host=, mozilla uses --host instead
	# of --build, and --target intstead of --host.
	# Note, mozilla also has --build but it does not do what you think it does.
	# Set both --target and --host as mozilla uses python to guess values otherwise
	mozconfig_annotate '' --target="${CHOST}"
	mozconfig_annotate '' --host="${CBUILD:-${CHOST}}"
	mozconfig_annotate '' --with-toolchain-prefix="${CHOST}-"
	if use system-libevent ; then
		mozconfig_annotate '' --with-system-libevent="${SYSROOT}${EPREFIX}"/usr
	fi

	if ! use x86 && [[ ${CHOST} != armv*h* ]] ; then
		mozconfig_annotate '' --enable-rust-simd
	fi

	# use the gtk3 toolkit (the only one supported at this point)
	# TODO: Will this result in automagic dependency on x11-libs/gtk+[wayland]?
	if use wayland ; then
		mozconfig_annotate '' --enable-default-toolkit=cairo-gtk3-wayland
	else
		mozconfig_annotate '' --enable-default-toolkit=cairo-gtk3
	fi

	mozconfig_use_enable startup-notification
	mozconfig_use_enable system-sqlite
	mozconfig_use_with system-av1
	mozconfig_use_with system-harfbuzz
	mozconfig_use_with system-harfbuzz system-graphite2
	mozconfig_use_with system-icu
	mozconfig_use_with system-jpeg
	mozconfig_use_with system-libvpx
	mozconfig_use_with system-webp
	mozconfig_use_enable pulseaudio
	# force the deprecated alsa sound code if pulseaudio is disabled
	if use kernel_linux && ! use pulseaudio ; then
		mozconfig_annotate '-pulseaudio' --enable-alsa
	fi

	# Disable built-in ccache support to avoid sandbox violation, #665420
	# Use FEATURES=ccache instead!
	mozconfig_annotate '' --without-ccache
	sed -i -e 's/ccache_stats = None/return None/' \
		python/mozbuild/mozbuild/controller/building.py || \
		die "Failed to disable ccache stats call"

	mozconfig_use_enable dbus

	mozconfig_use_enable wifi necko-wifi

	mozconfig_use_enable geckodriver

	# enable JACK, bug 600002
	mozconfig_use_enable jack

	# Enable/Disable eme support
	use eme-free && mozconfig_annotate '+eme-free' --disable-eme

	# Setup api key for location services and safebrowsing, https://bugzilla.mozilla.org/show_bug.cgi?id=1531176#c34
	echo -n "${_google_api_key}" > "${S}"/google-api-key
	mozconfig_annotate '' --with-google-location-service-api-keyfile="${S}/google-api-key"
	mozconfig_annotate '' --with-google-safebrowsing-api-keyfile="${S}/google-api-key"

	mozconfig_annotate '' --enable-extensions="${MEXTENSIONS}"

	# disable webrtc for now, bug 667642
	use arm && mozconfig_annotate 'broken on arm' --disable-webrtc

 	# disable some more stuff
 	mozconfig_annotate 'remove parental controlls' --disable-parental-controls
 	mozconfig_annotate 'remove accessibility' --disable-accessibility

	if use arm ; then
		mozconfig_annotate 'disable alsa, no sound anyway' --disable-alsa
 		mozconfig_annotate 'remove av1 decoder' --disable-av1
	fi

	if ! use amd64 ; then
		mozconfig_annotate 'disable cranelift, not yet ported to your arch' --disable-cranelift
	fi	

	# allow elfhack to work in combination with unstripped binaries
	# when they would normally be larger than 2GiB.
	append-ldflags "-Wl,--compress-debug-sections=zlib"

	if use clang ; then
		# https://bugzilla.mozilla.org/show_bug.cgi?id=1482204
		# https://bugzilla.mozilla.org/show_bug.cgi?id=1483822
		# toolkit/moz.configure Elfhack section: target.cpu in ('arm', 'x86', 'x86_64')
		local disable_elf_hack=
		if use amd64 ; then
			disable_elf_hack=yes
		elif use x86 ; then
			disable_elf_hack=yes
		elif use arm ; then
			disable_elf_hack=yes
		fi

		if [[ -n ${disable_elf_hack} ]] ; then
			mozconfig_annotate 'elf-hack is broken when using Clang' --disable-elf-hack
		fi
	fi

	if [[ ${CHOST} == armv*musl* ]] ; then
		mozconfig_annotate 'elf-hack is broken on arm and musl' --disable-elf-hack
	fi

	echo "mk_add_options MOZ_OBJDIR=${BUILD_OBJ_DIR}" >> "${S}"/.mozconfig
	echo "mk_add_options XARGS=/usr/bin/xargs" >> "${S}"/.mozconfig

	# Finalize and report settings
	mozconfig_final

	mkdir -p "${S}"/third_party/rust/libloading/.deps

	# workaround for funky/broken upstream configure...
	SHELL="${SHELL:-${EPREFIX}/bin/bash}" MOZ_NOSPAM=1 \
	./mach configure || die
}

src_compile() {
	local _virtx=
	if use pgo ; then
		_virtx=virtx

		# Reset and cleanup environment variables used by GNOME/XDG
		gnome2_environment_reset

		addpredict /root
		addpredict /etc/gconf
	fi

	GDK_BACKEND=x11 \
		MOZ_MAKE_FLAGS="${MAKEOPTS} -O" \
		SHELL="${SHELL:-${EPREFIX}/bin/bash}" \
		MOZ_NOSPAM=1 \
		${_virtx} \
		./mach build --verbose \
		|| die
}

src_install() {
	cd "${BUILD_OBJ_DIR}" || die

	# Pax mark xpcshell for hardened support, only used for startupcache creation.
	pax-mark m "${BUILD_OBJ_DIR}"/dist/bin/xpcshell

	# Add our default prefs for firefox
	cp "${FILESDIR}"/gentoo-default-prefs.js-3 \
		"${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/all-gentoo.js" \
		|| die

	# set dictionary path, to use system hunspell
	echo "pref(\"spellchecker.dictionary_path\", \"${EPREFIX}/usr/share/myspell\");" \
		>>"${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/all-gentoo.js" || die

	# force the graphite pref if system-harfbuzz is enabled, since the pref cant disable it
	if use system-harfbuzz ; then
		echo "sticky_pref(\"gfx.font_rendering.graphite.enabled\",true);" \
			>>"${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/all-gentoo.js" || die
	fi

	# force cairo as the canvas renderer on platforms without skia support
	if [[ $(tc-endian) == "big" ]] ; then
		echo "sticky_pref(\"gfx.canvas.azure.backends\",\"cairo\");" \
			>>"${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/all-gentoo.js" || die
		echo "sticky_pref(\"gfx.content.azure.backends\",\"cairo\");" \
			>>"${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/all-gentoo.js" || die
	fi

	# Augment this with hwaccel prefs
	if use hwaccel ; then
		cat "${FILESDIR}"/gentoo-hwaccel-prefs.js-1 >> \
		"${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/all-gentoo.js" \
		|| die
	fi

	if ! use screenshot ; then
		echo "pref(\"extensions.screenshots.disabled\", true);" >> \
			"${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/all-gentoo.js" \
			|| die
	fi

	echo "pref(\"extensions.autoDisableScopes\", 3);" >> \
		"${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/all-gentoo.js" \
		|| die

	if ! use gmp-autoupdate ; then
		local plugin
		for plugin in "${GMP_PLUGIN_LIST[@]}" ; do
			echo "pref(\"media.${plugin}.autoupdate\", false);" >> \
				"${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/all-gentoo.js" \
				|| die
		done
	fi

	cat "${FILESDIR}"/privacy-patchset-$(get_major_version)/custom-privacy.js-1 >> \
	"${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/all-gentoo.js" \
	|| die

	# add killswitch for system addons: formautofill  webcompat-reporter fxmonitor webcompat screenshots
	rm -frv "${BUILD_OBJ_DIR}"/dist/bin/browser/features/* || die

	cd "${S}"
	MOZ_MAKE_FLAGS="${MAKEOPTS}" SHELL="${SHELL:-${EPREFIX}/bin/bash}" MOZ_NOSPAM=1 \
	DESTDIR="${D}" ./mach install || die

	if use geckodriver ; then
		cp "${BUILD_OBJ_DIR}"/dist/bin/geckodriver "${ED%/}"${MOZILLA_FIVE_HOME} || die
		pax-mark m "${ED%/}"${MOZILLA_FIVE_HOME}/geckodriver

		dosym ${MOZILLA_FIVE_HOME}/geckodriver /usr/bin/geckodriver
	fi

	# Install language packs
	MOZEXTENSION_TARGET="distribution/extensions" MOZ_INSTALL_L10N_XPIFILE="1" mozlinguas_src_install

	local size sizes icon_path icon name
	if use bindist ; then
		sizes="16 32 48"
		icon_path="${S}/browser/branding/aurora"
		# Firefox's new rapid release cycle means no more codenames
		# Let's just stick with this one...
		icon="aurora"
		name="Aurora"

		# Override preferences to set the MOZ_DEV_EDITION defaults, since we
		# don't define MOZ_DEV_EDITION to avoid profile debaucles.
		# (source: browser/app/profile/firefox.js)
		cat >>"${BUILD_OBJ_DIR}/dist/bin/browser/defaults/preferences/all-gentoo.js" <<PROFILE_EOF
pref("app.feedback.baseURL", "https://input.mozilla.org/%LOCALE%/feedback/firefoxdev/%VERSION%/");
sticky_pref("lightweightThemes.selectedThemeID", "firefox-devedition@mozilla.org");
sticky_pref("browser.devedition.theme.enabled", true);
sticky_pref("devtools.theme", "dark");
PROFILE_EOF

	else
		sizes="16 22 24 32 48 64 128 256"
		icon_path="${S}/browser/branding/official"
		icon="${PN}"
		name="Mozilla Firefox"
	fi

	# Disable built-in auto-update because we update firefox through package manager
	insinto ${MOZILLA_FIVE_HOME}/distribution/
	newins "${FILESDIR}"/disable-auto-update.policy.json policies.json

	# Install icons and .desktop for menu entry
	for size in ${sizes} ; do
		insinto "/usr/share/icons/hicolor/${size}x${size}/apps"
		newins "${icon_path}/default${size}.png" "${icon}.png"
	done
	# Install a 48x48 icon into /usr/share/pixmaps for legacy DEs
	newicon "${icon_path}/default48.png" "${icon}.png"

	# Add StartupNotify=true bug 237317
	local startup_notify="false"
	if use startup-notification ; then
		startup_notify="true"
	fi

	local display_protocols="auto X11" use_wayland="false"
	if use wayland ; then
		display_protocols+=" Wayland"
		use_wayland="true"
	fi

	local app_name desktop_filename display_protocol exec_command
	for display_protocol in ${display_protocols} ; do
		app_name="${name} on ${display_protocol}"
		desktop_filename="${PN}-${display_protocol,,}.desktop"

		case ${display_protocol} in
			Wayland)
				exec_command='firefox-wayland --name firefox-wayland'
				newbin "${FILESDIR}"/firefox-wayland.sh firefox-wayland
				;;
			X11)
				if ! use wayland ; then
					# Exit loop here because there's no choice so
					# we don't need wrapper/.desktop file for X11.
					continue
				fi

				exec_command='firefox-x11 --name firefox-x11'
				newbin "${FILESDIR}"/firefox-x11.sh firefox-x11
				;;
			*)
				app_name="${name}"
				desktop_filename="${PN}.desktop"
				exec_command='firefox'
				;;
		esac

		newmenu "${FILESDIR}/icon/${PN}-r1.desktop" "${desktop_filename}"
		sed -i \
			-e "s:@NAME@:${app_name}:" \
			-e "s:@EXEC@:${exec_command}:" \
			-e "s:@ICON@:${icon}:" \
			-e "s:@STARTUP_NOTIFY@:${startup_notify}:" \
			"${ED%/}/usr/share/applications/${desktop_filename}" || die
	done

	rm "${ED%/}"/usr/bin/firefox || die
	newbin "${FILESDIR}"/firefox.sh firefox

	local wrapper
	for wrapper in \
		"${ED%/}"/usr/bin/firefox \
		"${ED%/}"/usr/bin/firefox-x11 \
		"${ED%/}"/usr/bin/firefox-wayland \
	; do
		[[ ! -f "${wrapper}" ]] && continue

		sed -i \
			-e "s:@PREFIX@:${EPREFIX%/}/usr:" \
			-e "s:@DEFAULT_WAYLAND@:${use_wayland}:" \
			"${wrapper}" || die
	done

	# Don't install llvm-symbolizer from sys-devel/llvm package
	[[ -f "${ED%/}${MOZILLA_FIVE_HOME}/llvm-symbolizer" ]] && \
		rm "${ED%/}${MOZILLA_FIVE_HOME}/llvm-symbolizer"

	# firefox and firefox-bin are identical
	rm "${ED%/}"${MOZILLA_FIVE_HOME}/firefox-bin || die
	dosym firefox ${MOZILLA_FIVE_HOME}/firefox-bin

	# Required in order to use plugins and even run firefox on hardened.
	pax-mark m "${ED%/}"${MOZILLA_FIVE_HOME}/{firefox,plugin-container}
}

pkg_preinst() {
	gnome2_icon_savelist

	# if the apulse libs are available in MOZILLA_FIVE_HOME then apulse
	# doesn't need to be forced into the LD_LIBRARY_PATH
	if use pulseaudio && has_version ">=media-sound/apulse-0.1.9" ; then
		einfo "APULSE found - Generating library symlinks for sound support"
		local lib
		pushd "${ED}"${MOZILLA_FIVE_HOME} &>/dev/null || die
		for lib in ../apulse/libpulse{.so{,.0},-simple.so{,.0}} ; do
			# a quickpkg rolled by hand will grab symlinks as part of the package,
			# so we need to avoid creating them if they already exist.
			if [[ ! -L ${lib##*/} ]] ; then
				ln -s "${lib}" ${lib##*/} || die
			fi
		done
		popd &>/dev/null || die
	fi
}

pkg_postinst() {
	gnome2_icon_cache_update
	xdg_desktop_database_update

	if ! use gmp-autoupdate ; then
		elog "USE='-gmp-autoupdate' has disabled the following plugins from updating or"
		elog "installing into new profiles:"
		local plugin
		for plugin in "${GMP_PLUGIN_LIST[@]}" ; do
			elog "\t ${plugin}"
		done
		elog
	fi

	if use pulseaudio && has_version ">=media-sound/apulse-0.1.9" ; then
		elog "Apulse was detected at merge time on this system and so it will always be"
		elog "used for sound.  If you wish to use pulseaudio instead please unmerge"
		elog "media-sound/apulse."
		elog
	fi

	local show_doh_information show_normandy_information

	if [[ -z "${REPLACING_VERSIONS}" ]] ; then
		# New install; Tell user that DoH is disabled by default
		show_doh_information=yes
		show_normandy_information=yes
	else
		local replacing_version
		for replacing_version in ${REPLACING_VERSIONS} ; do
			if ver_test "${replacing_version}" -lt 68.6.0-r3 ; then
				# Tell user only once about our DoH default
				show_doh_information=yes
			fi

			if ver_test "${replacing_version}" -lt 68.6.0-r3 ; then
				# Tell user only once about our Normandy default
				show_normandy_information=yes
			fi
		done
	fi

	if [[ -n "${show_doh_information}" ]] ; then
		elog
		elog "Note regarding Trusted Recursive Resolver aka DNS-over-HTTPS (DoH):"
		elog "Due to privacy concerns (encrypting DNS might be a good thing, sending all"
		elog "DNS traffic to Cloudflare by default is not a good idea and applications"
		elog "should respect OS configured settings), \"network.trr.mode\" was set to 5"
		elog "(\"Off by choice\") by default."
		elog "You can enable DNS-over-HTTPS in ${PN^}'s preferences."
	fi

	# bug 713782
	if [[ -n "${show_normandy_information}" ]] ; then
		elog
		elog "Upstream operates a service named Normandy which allows Mozilla to"
		elog "push changes for default settings or even install new add-ons remotely."
		elog "While this can be useful to address problems like 'Armagadd-on 2.0' or"
		elog "revert previous decisions to disable TLS 1.0/1.1, privacy and security"
		elog "concerns prevail, which is why we have switched off the use of this"
		elog "service by default."
		elog
		elog "To re-enable this service set"
		elog
		elog "    app.normandy.enabled=true"
		elog
		elog "in about:config."
	fi
}

pkg_postrm() {
	gnome2_icon_cache_update
	xdg_desktop_database_update
}
