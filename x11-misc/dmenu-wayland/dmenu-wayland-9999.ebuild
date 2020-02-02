EAPI=7

DESCRIPTION="dmenu-wl is an efficient dynamic menu for wayland (wlroots)."
HOMEPAGE="https://github.com/nyyManni/dmenu-wayland"
EGIT_REPO_URI="https://github.com/nyyManni/dmenu-wayland.git"

LICENCE="MIT"
SLOT="0"
KEYWORDS=""
IUSE=""

inherit meson git-r3

DEPENDS="dev-libs/glib
	dev-libs/wayland
	dev-libs/wayland-protocols
	x11-libs/cairo
	x11-libs/pango
	x11-libs/libxkbcommon"

RDEPENDS="${DEPEND}"
BDEPENDS="dev-util/ninja"
