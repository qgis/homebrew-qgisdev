#!/usr/bin/env bash
###########################################################################
#    homebrew-qgisdev travis ci - before_install.sh
#    ---------------------
#    Date                 : Dec 2016
#    Copyright            : (C) 2016 by Boundless Spatial, Inc.
#    Author               : Larry Shaffer
#    Email                : lshaffer at boundlessgeo dot com
###########################################################################
#                                                                         #
#   This program is free software; you can redistribute it and/or modify  #
#   it under the terms of the GNU General Public License as published by  #
#   the Free Software Foundation; either version 2 of the License, or     #
#   (at your option) any later version.                                   #
#                                                                         #
###########################################################################

set -e

if [ -n "${DEBUG_TRAVIS}" ];then
  brew list --versions
fi

# Remove default gdal provided by travis (we will replace it with gdal2)
brew remove gdal || true

# Remove any qt or pyqt (should be fully deprecated and removed upstream)
brew remove qt || true
brew remove pyqt || true

# Add taps
# brew tap homebrew/science || true
brew tap brewsci/bio || true
brew tap osgeo/osgeo4mac || true

brew update || brew update

for f in ${CHANGED_FORMULAE};do
  echo "Homebrew setup for changed formula ${f}..."
  deps=$(brew deps -1 --include-build ${f})
  echo "${f} dependencies: ${deps}"

  if [ "$(echo ${deps} | grep -c 'python3')" != "0" ];then
    echo "Installing and configuring Homebrew Python3"
    brew install python

    # Set up Python .pth files
    # get python3 short version (major.minor)
    PY_VER=$(${HOMEBREW_PREFIX}/bin/python3 -c "import sys;print('{0}.{1}'.format(sys.version_info[0],sys.version_info[1]).strip())")
    mkdir -p ${HOME}/Library/Python/${PY_VER}/lib/python/site-packages
    echo 'import site; site.addsitedir("${HOMEBREW_PREFIX}/lib/python${PY_VER}/site-packages")' \
      >> ${HOME}/Library/Python/${PY_VER}/lib/python/site-packages/homebrew.pth
    echo 'import site; site.addsitedir("${HOMEBREW_PREFIX}/opt/gdal2/lib/python${PY_VER}/site-packages")' \
      >> ${HOME}/Library/Python/${PY_VER}/lib/python/site-packages/gdal2.pth

    if [[ "${f}" =~ "qgis" ]];then
      echo "Installing QGIS Python3 dependencies"
      ${HOMEBREW_PREFIX}/bin/pip3 install future mock nose2 numpy psycopg2 pyyaml
    fi
  fi
  
  brew install gdal2
  
done
# Remove any left over lock or stray cache files
brew cleanup
