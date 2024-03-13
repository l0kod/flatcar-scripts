# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=7
CROS_WORKON_PROJECT="flatcar/flatcar-dev-util"
CROS_WORKON_REPO="https://github.com"
CROS_WORKON_LOCALNAME="dev"
CROS_WORKON_LOCALDIR="src/platform"

if [[ "${PV}" == 9999 ]]; then
	KEYWORDS="~amd64 ~arm ~arm64 ~x86"
else
	CROS_WORKON_COMMIT="00396595376d8d6a3c4b9251ba94e9de2d7a9e39" # flatcar-master
	KEYWORDS="amd64 arm arm64 x86"
fi

PYTHON_COMPAT=( python3_{6..11} )

inherit cros-workon python-single-r1

DESCRIPTION="emerge utilities for Flatcar developer images"
HOMEPAGE="https://github.com/flatcar/flatcar-dev-util/"

LICENSE="Apache-2.0"
SLOT="0"
IUSE=""

RDEPEND="sys-apps/portage"

src_compile() {
	echo "Nothing to compile"
}

src_install() {
	python_doscript emerge-gitclone
}
