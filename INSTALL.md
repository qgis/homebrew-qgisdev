**QGIS 3.2 Bonn on macOS with Homebrew**

![QGIS](https://raw.githubusercontent.com/fjperini/homebrew-qgisdev/matplotlib-fix%2Bpython/screenshot.png "QGIS")

`$ brew tap qgis/qgisdev`

Or install via URL (which will not receive updates):

`brew install https://raw.githubusercontent.com/qgis/homebrew-qgisdev/master/Formula/qgis3-dev.rb`

Another solution is to copy all the content directly to: `../Taps/qgis/homebrew-qgisdev`

`$ cd /usr/local/Homebrew/Library/Taps/qgis/homebrew-qgisdev`

`$ git checkout -b matplotlib-fix+python`

`$ brew edit qgis3-dev`

Fix for matplotlib and python. Change to:

```
url "https://github.com/qgis/QGIS.git", :branch => "release-3_2"
version “3.2.0"
```

```
depends_on “python"`
```

```
# depends_on "homebrew/science/matplotlib" # deprecated
depends_on "brewsci/bio/matplotlib"
```

`$ git add Formula/qgis3-dev.rb`

`$ git commit -m "fix for matplotlib and python”`


See [changes](https://github.com/fjperini/homebrew-qgisdev/blob/matplotlib-fix%2Bpython/Formula/qgis3-dev.rb). You can copy the entire file to make sure.

For, `ImportError: No module named site`

`$ brew install pyqt`

`$ brew install bison`

```
> $ python --version
Python 3.6.5
```

```
> $ python3 --version
Python 3.6.5
```

```
> $ python2 --version
Python 2.7.15
```

Modify the file `/usr/local/bin/pyrcc5` and change `pythonw2.7` to `python3`: 

```
#!/bin/sh
exec python3 -m PyQt5.pyrcc_main ${1+"$@"}
```

Build 

`$ brew install proj` # `--build-from-source`

Proj v5.1.0 # With Proj v4: Library not loaded: libproj.13.dylib

`$ brew install libspatialite` # `--build-from-source`

`$ brew install libgeotiff` # `--build-from-source`

`$ brew install gdal2` # recommended. Other: `gdal --with-complete`

`$ brew install -v --no-sandbox qgis3-dev --with-grass  --with-saga-gis-lts`  # other:  `--with-r` `--with-3d`

It can stop at the end of the `gdal2` installation, for that reason we installed it before. If it stops, just rerun the above command to continue with the installation of QGIS.
The same thing happens in Travis when doing a pull request. Suggestions to correct it?

`$ mv /usr/local/opt/qgis3-dev/QGIS.app /Applications/QGIS\ 3.app`

`$ ln -s /Applications/QGIS\ 3.app /usr/local/opt/qgis3-dev/QGIS.app`

To run

GRASS: `$ grass74` # in the installation: `ln -s ../Cellar/grass7/7.4.0/bin/grass74 /usr/local/bin/grass74`

SAGA:  `$ saga_gui` # create a direct link : `ln -s ../Cellar/saga-gis-lts/2.3.2/bin/saga_gui /usr/local/bin/saga_gui`

To create the `SAGA.app` package use `saga-gis-lts --with-app`. # with fails

There is also the package `saga-gis`

`
keg_only "QGIS fails to load the correct SAGA version, if the latest version is in the path"
`

For `GRASS.app`, it is not available in `grass7`.

References:

[http://luisspuerto.net/2018/03/qgis-on-macos-with-homebrew/](http://luisspuerto.net/2018/03/qgis-on-macos-with-homebrew/)

[https://github.com/qgis/homebrew-qgisdev/issues/62](https://github.com/qgis/homebrew-qgisdev/issues/62)

[https://github.com/qgis/homebrew-qgisdev/issues/64](https://github.com/qgis/homebrew-qgisdev/issues/64)

[https://github.com/qgis/homebrew-qgisdev/issues/66](https://github.com/qgis/homebrew-qgisdev/issues/66) 

[https://grasswiki.osgeo.org/wiki/Compiling_on_MacOSX_using_homebrew](https://grasswiki.osgeo.org/wiki/Compiling_on_MacOSX_using_homebrew)

[https://sourceforge.net/p/saga-gis/wiki/Compiling%20SAGA%20on%20Mac%20OS%20X/](https://sourceforge.net/p/saga-gis/wiki/Compiling%20SAGA%20on%20Mac%20OS%20X/)
