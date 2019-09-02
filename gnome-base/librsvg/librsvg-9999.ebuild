# Copyright 2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7
GNOME2_LA_PUNT="yes"


inherit cargo git-r3 multilib-minimal

DESCRIPTION="Scalable Vector Graphics (SVG) rendering library"
HOMEPAGE="https://wiki.gnome.org/Projects/LibRsvg"

RESTRICT="mirror"
LICENSE="LGPL-2"
SLOT="2"
KEYWORDS=""

IUSE="gtk-doc introspection tools"

EGIT_REPO_URI="https://github.com/GNOME/librsvg.git"
#EGIT_BRANCH=""
#EGIT_COMMIT=""

RDEPEND=">=dev-libs/glib-2.34.3:2[${MULTILIB_USEDEP}]
	>=x11-libs/cairo-1.15.12[${MULTILIB_USEDEP}]
	>=x11-libs/pango-1.36.3[${MULTILIB_USEDEP}]
	>=dev-libs/libxml2-2.9.1-r4:2[${MULTILIB_USEDEP}]
	>=dev-libs/libcroco-0.6.8-r1[${MULTILIB_USEDEP}]
	>=x11-libs/gdk-pixbuf-2.30.7:2[introspection?,${MULTILIB_USEDEP}]
	introspection? ( >=dev-libs/gobject-introspection-0.10.8:= )
	tools? ( >=x11-libs/gtk+-3.10.0:3 )"

DEPEND="dev-libs/gobject-introspection-common
	dev-libs/vala-common
	>=dev-util/gtk-doc-am-1.13
	>=virtual/pkgconfig-0-r1[${MULTILIB_USEDEP}]
	gtk-doc? ( >=dev-util/gtk-doc-1.13 )"

BDEPEND=">=virtual/rust-1.37.0
	>=virtual/cargo-1.37.0"

# >=gtk-doc-am-1.13, gobject-introspection-common, vala-common needed by eautoreconf


S="${WORKDIR}"/librsvg-${PV}

src_unpack() {
        if [[ "${PV}" == *9999* ]]; then
                git-r3_src_unpack
                cargo_live_src_unpack
        else
                cargo_src_unpack
        fi
}

src_prepare() {

	local build_dir
	gnome2_src_prepare

	# important to do it after patches
	eautoreconf

src_configure() {

	local myconf=()

	# -Bsymbolic is not supported by the Darwin toolchain
	if [[ ${CHOST} == *-darwin* ]]; then
		myconf+=( --disable-Bsymbolic )
	fi

	# --disable-tools even when USE=tools; the tools/ subdirectory is useful
	# only for librsvg developers
	ECONF_SOURCE=${S} \
	gnome2_src_configure \
		--build=${CHOST_default} \
		--disable-static \
		--disable-tools \
		$(multilib_native_use_enable gtk-doc) \
		$(multilib_native_use_enable introspection) \
		--disable-vala \
		--enable-pixbuf-loader \
		"${myconf[@]}"

	if multilib_is_native_abi; then
	ln -s "${S}"/doc/html doc/html || die
fi

}

src_compile() {
	# causes segfault if set, see bug #411765
	unset __GL_NO_DSO_FINALIZER
	gnome2_src_compile
}

src_install() {
	gnome2_src_install
}
