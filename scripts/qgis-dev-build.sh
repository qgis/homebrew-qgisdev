#!/bin/bash
###########################################################################
# Script for CMake build of QGIS when built off Homebrew dependencies
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

BUILD_DIR="$1"

if ! [[ "$BUILD_DIR" = /* ]] || ! [ -d "$BUILD_DIR" ]; then
  echo "usage: <script> 'absolute path to build directory'"
  exit 1
fi

CMAKE=$(which cmake)
if [ -z $CMAKE ]; then
  echo "CMake executable 'cmake' not found"
  exit 1
fi

# parent directory of script
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")"; pwd -P)

# use maximum number of available cores
CPUCORES=$(/usr/sbin/sysctl -n hw.ncpu)

# if HOMEBREW_PREFIX undefined in env, then set to standard prefix
if [ -z "$HOMEBREW_PREFIX" ]; then
  HB=$(brew --prefix)
else
  HB=$HOMEBREW_PREFIX
fi

if [ -d $HB/Frameworks/QtCore.framework/Versions/4 ]; then
  echo 'Unlink Qt4 Homebrew formula, e.g. `brew unlink qt`'
  exit 1
fi

# get python3 short version (major.minor)
PY_VER=$(python3 -c "import sys;print('{0}.{1}'.format(sys.version_info[0],sys.version_info[1]).strip())")

# set up environment
export PATH=${HB}/opt/gdal2/bin:${HB}/bin:${HB}/sbin:${PATH}
export PYTHONPATH=${HB}/opt/gdal2/lib/python${PY_VER}/site-packages:${HB}/lib/python${PY_VER}/site-packages:${PYTHONPATH}

echo "PATH set to: ${PATH}"
echo "PYTHONPATH set to: ${PYTHONPATH}"
echo "BUILD_DIR set to: ${BUILD_DIR}"

echo "Building QGIS..."
cd $BUILD_DIR
time $CMAKE --build . --target all -- -j${CPUCORES}
if [ $? -gt 0 ]; then
    echo -e "\nERROR building QGIS"
    exit 1
fi

# # stage/compile plugins so they are available when running from build directory
# echo "Staging plugins to QGIS build directory..."
# make -j ${CPUCORES} staged-plugins-pyc
# if [ $? -gt 0 ]; then
#     echo -e "\nERROR staging plugins to QGIS build directory"
#     exit 1
# fi

# write LSEnvironment entity to app's Info.plist
if [ -d "${BUILD_DIR}/output/bin/QGIS.app" ]; then
  # this differs from LSEnvironment in bundled app; see set-qgis-app-env.py
  echo "Setting QGIS.app environment variables..."
  $SCRIPT_DIR/qgis-set-app-env.py -p $HB -b $BUILD_DIR "${BUILD_DIR}/output/bin/QGIS.app"
  if [ $? -gt 0 ]; then
      echo -e "\nERROR setting QGIS.app environment variables"
      exit 1
  fi
fi

if [ -d "${BUILD_DIR}/output/bin/QGIS Browser.app" ]; then
  echo "Setting QGIS Browser.app environment variables..."
  $SCRIPT_DIR/qgis-set-app-env.py -p $HB -b $BUILD_DIR "${BUILD_DIR}/output/bin/QGIS Browser.app"
  if [ $? -gt 0 ]; then
      echo -e "\nERROR setting QGIS Browser.app environment variables"
      exit 1
  fi
fi

exit 0
