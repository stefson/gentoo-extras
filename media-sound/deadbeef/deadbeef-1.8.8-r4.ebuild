# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

PLOCALES="be bg bn ca cs da de el en_GB es et eu fa fi fr gl he hr hu id it ja kk km lg
	lt lv nl pl pt pt_BR ro ru si_LK sk sl sr sr@latin sv te tr ug uk vi zh_CN zh_TW"

PLOCALE_BACKUP="en_GB"

inherit autotools plocale xdg-utils

SRC_URI="https://sourceforge.net/projects/${PN}/files/travis/linux/${PV}/deadbeef-${PV}.tar.bz2/download
	-> ${P}.tar.bz2"
#KEYWORDS="~amd64 ~arm ~x86"

DESCRIPTION="foobar2k-like music player"
HOMEPAGE="http://deadbeef.sourceforge.net"

LICENSE="BSD
	UNICODE
	ZLIB
	aac? ( GPL-1 GPL-2 )
	alac? ( MIT GPL-2 )
	alsa? ( GPL-2 )
	cdda? ( GPL-2 LGPL-2 GPL-3 )
	cdparanoia? ( GPL-2 )
	cover? ( ZLIB )
	converter? ( GPL-2 )
	curl? ( curl ZLIB )
	dts? ( GPL-2 )
	dumb? ( DUMB-0.9.3 ZLIB )
	equalizer? ( GPL-2 )
	ffmpeg? ( GPL-2 )
	flac? ( BSD )
	gme? ( LGPL-2.1 )
	gtk2? ( GPL-2 )
	gtk3? ( GPL-2 )
	hotkeys? ( ZLIB )
	libsamplerate? ( GPL-2 )
	m3u? ( ZLIB )
	mac? ( GPL-2 )
	mad? ( GPL-2 ZLIB )
	midi? ( LGPL-2.1 ZLIB )
	mms? ( GPL-2 ZLIB )
	mono2stereo? ( ZLIB )
	mpg123? ( LGPL-2.1 ZLIB )
	musepack? ( BSD ZLIB )
	nullout? ( ZLIB )
	opus? ( ZLIB )
	oss? ( GPL-2 )
	playlist-browser? ( ZLIB )
	psf? ( BSD GPL-1 MAME ZLIB )
	pulseaudio? ( GPL-2 )
	shell-exec? ( GPL-2 )
	shn? ( shorten ZLIB )
	sid? ( GPL-2 )
	sndfile? ( GPL-2 LGPL-2 )
	tta? ( BSD ZLIB )
	vorbis? ( BSD ZLIB )
	vtx? ( GPL-2 ZLIB )
	wavpack? ( BSD )
	wma? ( GPL-2 LGPL-2 ZLIB )
	zip? ( ZLIB )"

SLOT="0"

IUSE="+alsa +flac +gtk2 +hotkeys +m3u +mad +mp3 +sndfile +vorbis
	aac alac cdda cdparanoia converter cover cover-imlib2 cover-network curl dts dumb equalizer
	ffmpeg gme gtk3 libsamplerate mac midi mms mono2stereo mpg123 musepack nls
	nullout opus oss playlist-browser psf pulseaudio sc68 shell-exec shn sid tta unity vtx wavpack wma zip"

REQUIRED_USE="cdparanoia? ( cdda )
	converter? ( || ( gtk2 gtk3 ) )
	cover-imlib2? ( cover )
	cover-network? ( cover curl )
	cover? ( || ( gtk2 gtk3 ) )
	mp3? ( || ( mad mpg123 ) )
	playlist-browser? ( || ( gtk2 gtk3 ) )
	shell-exec? ( || ( gtk2 gtk3 ) )
	|| ( alsa oss pulseaudio nullout )"

PDEPEND="media-plugins/deadbeef-plugins-meta:0"

RDEPEND="dev-libs/glib:2
	aac? ( media-libs/faad2:0 )
	alsa? ( media-libs/alsa-lib:0 )
	alac? ( media-libs/faad2:0 )
	cdda? ( dev-libs/libcdio:0=
		media-libs/libcddb:0 )
	cdparanoia? ( dev-libs/libcdio-paranoia:0 )
	cover? ( cover-imlib2? ( media-libs/imlib2:0 )
		media-libs/libpng:0=
		virtual/jpeg:0
		x11-libs/gdk-pixbuf:2[jpeg] )
	curl? ( net-misc/curl:0 )
	elibc_musl? ( sys-libs/queue-standalone )
	ffmpeg? ( media-video/ffmpeg:= )
	flac? ( media-libs/flac:= )
	gme? ( sys-libs/zlib:0 )
	gtk2? ( >=app-accessibility/at-spi2-core-2.46.0
		dev-libs/jansson:=
		x11-libs/cairo:0
		x11-libs/gtk+:2
		x11-libs/pango:0 )
	gtk3? ( dev-libs/jansson:=
		x11-libs/gtk+:3 )
	hotkeys? ( x11-libs/libX11:0 )
	libsamplerate? ( media-libs/libsamplerate:0 )
	mad? ( media-libs/libmad:0 )
	midi? ( media-sound/timidity-freepats:0 )
	mpg123? ( media-sound/mpg123-base )
	opus? ( media-libs/opusfile:0 )
	psf? ( sys-libs/zlib:0 )
	pulseaudio? ( media-libs/libpulse )
	sndfile? ( media-libs/libsndfile:0 )
	vorbis? ( media-libs/libogg:0
		media-libs/libvorbis:0 )
	wavpack? ( media-sound/wavpack:0 )
	zip? ( dev-libs/libzip:0 )"

DEPEND="${RDEPEND}
	virtual/pkgconfig:0
	nls? ( dev-util/intltool:0
		virtual/libintl:0 )
	mac? ( x86? ( dev-lang/yasm:0 )
		amd64? ( dev-lang/yasm:0 ) )"

S="${WORKDIR}/${P}"

src_prepare() {
	if [[ "$(plocale_get_locales disabled)" =~ "ru" ]] ; then
		eapply "${FILESDIR}/${PN}-1.8.3-remove-ru-help-translation.patch"
		rm -v "${S}/translation/help.ru.txt" || die
	fi

	remove_locale() {
		sed -e "/${1}/d" \
			-i "${S}/po/LINGUAS" || die
	}

	plocale_for_each_disabled_locale remove_locale

	if use midi ; then
		# set default gentoo path
		sed -e 's;/etc/timidity++/timidity-freepats.cfg;/usr/share/timidity/freepats/timidity.cfg;g' \
			-i "${S}/plugins/wildmidi/wildmidiplug.c" || die
	fi

	if ! use unity ; then
		# remove unity trash
		eapply "${FILESDIR}/${PN}-1.8.3-remove-unity-trash.patch"
		eapply "${FILESDIR}/${PN}-1.8.3-fix-missmatching-desktop-groups-warnings.patch"
	fi
	
	eapply "${FILESDIR}/${PN}-1.8.3-fix-config-with-gettext-0.20.patch"

	eapply "${FILESDIR}/alsa-regression/0001-revert-alsa-pulse-setformat-requested-cleanup.patch"
	eapply "${FILESDIR}/alsa-regression/0002-revert-alsa-setformat-error-handling.patch"
	eapply "${FILESDIR}/alsa-regression/0003-revert-alsa-move-hwparams-setting-to-the-playback-thread.patch"

	# backported from deadbeef-1.8.9-dev
	eapply "${FILESDIR}/0004-update-translation.patch"
	eapply "${FILESDIR}/0005-change-print-version-to-stdout.patch"

	eapply "${FILESDIR}/ffmpeg-git-patches/0006-fix-the-use-of-deprecated-API.patch"
	eapply "${FILESDIR}/ffmpeg-git-patches/0007-replace-avcodec_decode_audio4-with-avcodec_receive_frame.patch"
	eapply "${FILESDIR}/ffmpeg-git-patches/0008-ffmpeg-add-fallback-to-support-older-ffmpeg.patch"

	# fix for url plenk in curl-7.78 and above
	eapply "${FILESDIR}/deadbeef-1.8.8-fix-curl-endings.patch"
	eapply "${FILESDIR}/deadbeef-1.8.8-fix-ffmpeg-5.0.patch"
	eapply "${FILESDIR}/deadbeef-1.8.8-fix-clang-15.patch"
	eapply "${FILESDIR}/deadbeef-1.8.8-fix-build-with-musl-pthread.patch"
	eapply "${FILESDIR}/deadbeef-1.8.8-fix-clang-16.patch"
	eapply "${FILESDIR}/deadbeef-1.8.8-fix-popup-log-on-errors.patch"
	eapply "${FILESDIR}/deadbeef-1.9.5-fixup-musl-1.2.4-lfs.patch"
#	eapply "${FILESDIR}/deadbeef-1.9.6-fixup-ffmpeg-7.patch"

	rm -fr intl || die

	eapply_user

	config_rpath_update "${S}/config.rpath"
	eautoreconf
}

src_configure() {

	econf --disable-coreaudio \
		--disable-portable \
		--disable-static \
		$(use_enable ffmpeg) \
		$(use_enable aac) \
		--disable-adplug \
		$(use_enable alac) \
		$(use_enable alsa) \
		$(use_enable cdda) \
		$(use_enable cdparanoia cdda-paranoia) \
		$(use_enable converter) \
		$(use_enable cover artwork) \
		$(use_enable cover-imlib2 artwork-imlib2) \
		$(use_enable cover-network artwork-network) \
		$(use_enable curl vfs-curl) \
		$(use_enable dts dca) \
		$(use_enable dumb) \
		$(use_enable equalizer supereq) \
		$(use_enable flac) \
		$(use_enable gme) \
		$(use_enable gtk2) \
		$(use_enable gtk3) \
		$(use_enable hotkeys) \
		--disable-lfm \
		--disable-notify \
		$(use_enable libsamplerate src) \
		$(use_enable m3u) \
		$(use_enable mac ffap) \
		$(use_enable mad libmad) \
		$(use_enable midi wildmidi) \
		$(use_enable mms) \
		$(use_enable mono2stereo) \
		$(use_enable mpg123 libmpg123) \
		$(use_enable musepack) \
		$(use_enable nls) \
		$(use_enable nullout) \
		$(use_enable opus) \
		$(use_enable oss) \
		$(use_enable playlist-browser pltbrowser) \
		$(use_enable psf) \
		$(use_enable pulseaudio pulse) \
		$(use_enable sc68) \
		$(use_enable shell-exec shellexecui) \
		$(use_enable shn) \
		$(use_enable sid) \
		$(use_enable sndfile) \
		$(use_enable tta) \
		$(use_enable vorbis) \
		$(use_enable vtx) \
		$(use_enable wavpack) \
		$(use_enable wma) \
		$(use_enable zip vfs-zip)
}

src_install() {
	default

	find "${ED}" -name '*.la' -delete || die
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update

	if use gtk2 || use gtk3 ; then
		xdg_icon_cache_update
	fi
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_mimeinfo_database_update

	if use gtk2 || use gtk3 ; then
		xdg_icon_cache_update
	fi
}
