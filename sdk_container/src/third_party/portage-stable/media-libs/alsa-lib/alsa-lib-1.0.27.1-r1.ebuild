# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/alsa-lib/alsa-lib-1.0.27.1-r1.ebuild,v 1.2 2013/07/19 16:41:41 ssuominen Exp $

EAPI=5

# no support for python3_2 or above yet wrt #471326
PYTHON_COMPAT=( python2_7 )

inherit autotools eutils multilib multilib-minimal python-single-r1

DESCRIPTION="Advanced Linux Sound Architecture Library"
HOMEPAGE="http://www.alsa-project.org/"
SRC_URI="mirror://alsaproject/lib/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~amd64-linux ~x86-linux"
IUSE="doc debug alisp python"

RDEPEND="python? ( ${PYTHON_DEPS} )
	abi_x86_32? ( !<=app-emulation/emul-linux-x86-soundlibs-20130224-r1
		!app-emulation/emul-linux-x86-soundlibs[-abi_x86_32(-)] )"
DEPEND="${RDEPEND}
	doc? ( >=app-doc/doxygen-1.2.6 )"

pkg_setup() {
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	find . -name Makefile.am -exec sed -i -e '/CFLAGS/s:-g -O2::' {} + || die
	epatch "${FILESDIR}"/${P}-rewind.patch #477282
	epatch_user
	eautoreconf
}

multilib_src_configure() {
	local myconf
	# enable Python only on final ABI
	if [[ ${ABI} == ${DEFAULT_ABI} ]]; then
		myconf="$(use_enable python)"
	else
		myconf="--disable-python"
	fi
	use elibc_uclibc && myconf+=" --without-versioned"

	ECONF_SOURCE=${S} \
	econf \
		--disable-maintainer-mode \
		--enable-shared \
		--disable-resmgr \
		--enable-rawmidi \
		--enable-seq \
		--enable-aload \
		$(use_with debug) \
		$(use_enable alisp) \
		${myconf}
}

multilib_src_compile() {
	emake

	if [[ ${ABI} == ${DEFAULT_ABI} ]] && use doc; then
		emake doc
		fgrep -Zrl "${S}" doc/doxygen/html | \
			xargs -0 sed -i -e "s:${S}::"
	fi
}

multilib_src_install() {
	emake DESTDIR="${D}" install
	if [[ ${ABI} == ${DEFAULT_ABI} ]] && use doc; then
		dohtml -r doc/doxygen/html/.
	fi
}

multilib_src_install_all() {
	prune_libtool_files --all
	find "${ED}"/usr/$(get_libdir)/alsa-lib -name '*.a' -exec rm -f {} +
	dodoc ChangeLog doc/asoundrc.txt NOTES TODO
}
