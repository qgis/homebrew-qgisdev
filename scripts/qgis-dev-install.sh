#!/bin/bash
###########################################################################
# Script for CMake configure and generation setup prior to use in Qt
# Creator with dev builds and installs of QGIS when built off dependencies
# from Homebrew project
#                              -------------------
#        begin    : November 2016
#        copyright: (C) 2016 Larry Shaffer
#        email    : larrys at dakotacarto dot com
###########################################################################
#                                                                         #
#   This program is free software; you can redistribute it and/or modify  #
#   it under the terms of the GNU General Public License as published by  #
#   the Free Software Foundation; either version 2 of the License, or     #
#   (at your option) any later version.                                   #
#                                                                         #
###########################################################################

# exit on errors
set -e

usage(){
  echo "usage: <script> 'absolute path to build directory'"
  exit 1
}

if [ "$#" -ne 1 ]; then
  usage
fi

BUILD_DIR="${1}"

if ! [[ "${BUILD_DIR}" = /* ]] || ! [ -d "${BUILD_DIR}" ] || ! [ -f "${BUILD_DIR}/CmakeCache.txt" ]; then
  usage
fi

CMAKE=$(which cmake)
if [ -z $CMAKE ]; then
  echo "CMake executable 'cmake' not found"
  exit 1
fi

INSTALL_DIR=$(cmake -L 2>/dev/null | grep 'CMAKE_INSTALL_PREFIX' | egrep -o '=.*$' | tr -d '=\n')

if ! [[ "${INSTALL_DIR}" = /* ]] || ! [ -d "${INSTALL_DIR}" ]; then
  echo "CMAKE_INSTALL_PREFIX directory not found"
fi

# parent directory of script
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd -P)

# use maximum number of available cores
CPUCORES=$(/usr/sbin/sysctl -n hw.ncpu)

QGIS_APP_NAME=QGIS.app
QGIS="${INSTALL_DIR}/${QGIS_APP_NAME}"

# if HOMEBREW_PREFIX undefined in env, then set to standard prefix
if [ -z "${HOMEBREW_PREFIX}" ]; then
  HB=$(brew --prefix)
else
  HB=$HOMEBREW_PREFIX
fi

if [ -d $HB/Frameworks/QtCore.framework/Versions/4 ]; then
  echo 'Unlink Qt4 Homebrew formula, e.g. `brew unlink qt`'
  exit 1
fi

if [ -d $HB/var/homebrew/linked/txt2tags/bin ]; then
  echo 'Unlink txt2tags Homebrew formula: `brew unlink txt2tags`'
  exit 1
fi

# ensure we can delete previous QGIS.app, then delete it
if [ -d "${QGIS}" ]; then
  echo "Removing existing QGIS.app..."
  chmod -R u+w "${QGIS}"
  rm -fdR "${QGIS}"
fi

echo "Installing QGIS..."
cd $BUILD_DIR
$CMAKE --build . --target install -- -j${CPUCORES}

if [ -d "${QGIS}" ]; then
  # ensure we can write to QGIS.app bundle components
  # NOTE: Homebrew's binaries are built as non-writable
  echo "Making QGIS.app user-writable..."
  /bin/chmod -R u+w "${QGIS}"

  # write LSEnvironment entity to app's Info.plist
  # this differs from LSEnvironment in app run from build directory; see qgis-set-app-env.py
  echo "Setting QGIS.app environment variables..."
  $SCRIPT_DIR/qgis-set-app-env.py -p $HB "${QGIS}"

  echo "Setting QGIS Browser.app environment variables..."
  $SCRIPT_DIR/qgis-set-app-env.py -p $HB "${QGIS}/Contents/MacOS/bin/QGIS Browser.app"
fi

exit 0
