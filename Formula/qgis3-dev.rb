class Qgis3DevUnlinkedFormulae < Requirement
  fatal true
  satisfy(:build_env => false) { !qt4_linked && !pyqt4_linked && !txt2tags_linked }

  def qt4_linked
    (Formula["qt"].linked_keg/"lib/QtCore.framework/Versions/4").exist?
  rescue
    return false
  end

  def pyqt4_linked
    (Formula["pyqt"].linked_keg/"lib/python2.7/site-packages/PyQt").exist?
  rescue
    return false
  end

  def txt2tags_linked
    Formula["txt2tags"].linked_keg.exist?
  rescue
    return false
  end

  def message
    s = "Compilation can fail if these formulae are installed and linked:\n\n"

    s += "Unlink with `brew unlink qt` or remove with `brew uninstall qt`\n" if qt4_linked
    s += "Unlink with `brew unlink pyqt` or remove with `brew uninstall pyqt`\n" if pyqt4_linked
    s += "Unlink with `brew unlink txt2tags` or remove with `brew uninstall txt2tags`\n" if txt2tags_linked
    s
  end
end

class Qgis3Dev < Formula
  desc "User friendly open source Geographic Information System"
  homepage "https://www.qgis.org"

  url "https://github.com/qgis/QGIS.git", :branch => "master"
  version "2.99"

  option "without-ninja", "Disable use of ninja CMake generator"
  option "without-debug", "Disable debug build, which outputs info to system.log or console"
  option "without-qt5-webkit", "Build without webkit based functionality"
  option "without-server", "Build without QGIS Server (qgis_mapserv.fcgi)"
  option "without-postgresql", "Build without current PostgreSQL client"
  option "with-globe", "Build with Globe plugin, based upon osgEarth"
  option "with-grass", "Build with GRASS 7 integration plugin and Processing plugin support (or install grass-7x first)"
  option "with-oracle", "Build extra Oracle geospatial database and raster support"
  option "with-orfeo5", "Build extra Orfeo Toolbox for Processing plugin"
  option "with-r", "Build extra R for Processing plugin"
  option "with-saga-gis", "Build extra Saga GIS for Processing plugin"
  # option "with-qt-mysql", "Build extra Qt MySQL plugin for eVis plugin"
  option "with-qspatialite", "Build QSpatialite Qt database driver"
  option "with-api-docs", "Build the API documentation with Doxygen and Graphviz"

  deprecated_option "without-qt5-webkit-qt@5.7" => "without-qt5-webkit"

  depends_on Qgis3DevUnlinkedFormulae

  # core qgis
  depends_on "cmake" => :build
  depends_on "ninja" => :build if build.with? "ninja"
  depends_on "bison" => :build
  depends_on "flex" => :build
  if build.with? "api-docs"
    depends_on "graphviz" => [:build, "with-freetype"]
    depends_on "doxygen" => [:build, "with-dot"] # with graphviz support
  end

  depends_on :python3
  depends_on "future" => :python3
  depends_on "psycopg2" => :python3
  depends_on "dateutil" => :python3
  depends_on "httplib2" => :python3
  depends_on "pytz" => :python3
  depends_on "six" => :python3
  depends_on "nose2" => :python3
  depends_on "pygments" => :python3
  depends_on "jinja2" => :python3
  depends_on "yaml" => :python3
  depends_on "requests" => :python3
  depends_on "owslib" => :python3
  depends_on "matplotlib" => :python3

  depends_on "qt" # keg_only
  depends_on "osgeo/osgeo4mac/qt5-webkit" => :recommended # keg_only
  depends_on "sip" => ["with-python3"]
  depends_on "pyqt"
  depends_on "qca"
  depends_on "qtkeychain"
  depends_on "qscintilla2"
  depends_on "qwt"
  depends_on "qwtpolar"
  depends_on "gsl"
  depends_on "sqlite" # keg_only
  depends_on "expat" # keg_only
  depends_on "proj"
  depends_on "spatialindex"
  depends_on "fcgi" if build.with? "server"
  # use newer postgresql client than Apple's, also needed by `psycopg2`
  depends_on "postgresql" => :recommended

  # core providers
  depends_on "osgeo/osgeo4mac/gdal2" # keg_only
  depends_on "osgeo/osgeo4mac/gdal2-python" => ["with-python3"] # keg_only
  depends_on "osgeo/osgeo4mac/oracle-client-sdk" if build.with? "oracle"
  # TODO: add MSSQL third-party support formula?, :optional

  # core plugins (c++ and python)
  if build.with?("grass") || Formula["grass7"].opt_prefix.exist?
    depends_on "osgeo/osgeo4mac/grass7"
    depends_on "gettext" # keg_only
  end

  # Not until osgearth is Qt5-ready
  # if build.with? "globe"
  #   # this is pretty borked with OS X >= 10.10+
  #   depends on "open-scene-graph" => ["with-qt5"]
  #   depends on "homebrew/science/osgearth"
  # end

  depends_on "gpsbabel" => :optional
  # TODO: remove "pyspatialite" when PyPi package supports spatialite 4.x
  #       or DB Manager supports libspatialite >= 4.2.0 (with mod_spatialite)

  # TODO: what to do for Py3 and pyspatialite?
  # depends on "pyspatialite" # for DB Manager
  # depends on "qt-mysql" => :optional # for eVis plugin (non-functional in 2.x?)

  # core processing plugin extras
  # see `grass` above
  depends_on "osgeo/osgeo4mac/orfeo5" => :optional
  depends_on "homebrew/science/r" => :optional
  depends_on "osgeo/osgeo4mac/saga-gis-lts" => :optional
  # TODO: LASTools straight build (2 reporting tools), or via `wine` (10 tools)
  # TODO: Fusion from USFS (via `wine`?)

  # TODO: add one for Py3
  #       (only necessary when macOS ships a Python3 or 3rd-party isolation is needed)
  # resource "pyqgis-startup" do
  #   url "https://gist.githubusercontent.com/dakcarto/11385561/raw/e49f75ecec96ed7d6d3950f45ad3f30fe94d4fb2/pyqgis_startup.py"
  #   sha256 "385dce925fc2d29f05afd6508bc1f46ec84c0bc607cc0c8dfce78a4bb93b9c4e"
  #   version "2.14.0"
  # end
  
  # Python dependencies

  depends_on "future" => :python3
  depends_on "psycopg2" => :python3
  depends_on "numpy" => :python3
  


  def install
    # when gdal2-python.rb loaded, PYTHONPATH gets set to 2.7 site-packages...
    #   clear it before calling any local python3 functions
    ENV["PYTHONPATH"] = nil
    if ARGV.debug?
      puts "python_exec: #{python_exec}"
      puts "py_ver: #{py_ver}"
      puts "brewed_python?: #{brewed_python?}"
      puts "python_site_packages: #{python_site_packages}"
      puts "python_prefix: #{python_prefix}"
      puts "qgis_python_packages: #{qgis_python_packages}"
      puts "gdal_python_packages: #{gdal_python_packages}"
      puts "gdal_python_opt_bin: #{gdal_python_opt_bin}"
      puts "gdal_opt_bin: #{gdal_opt_bin}"
    end

    # Set bundling level back to 0 (the default in all versions prior to 1.8.0)
    # so that no time and energy is wasted copying the Qt frameworks into QGIS.

    # Install custom widgets Designer plugin to prefix
    mkdir lib/"qt5/plugins/designer"
    inreplace "src/customwidgets/CMakeLists.txt",
              "${QT_PLUGINS_DIR}/designer", lib/"qt5/plugins/designer".to_s

    args = std_cmake_args
    args << "-DCMAKE_BUILD_TYPE=RelWithDebInfo" if build.with? "debug" # override

    cmake_prefixes = %w[
      qt5
      qt5-webkit
      qscintilla2
      qwt
      qwtpolar
      qca
      gdal2
      gsl
      geos
      proj
      libspatialite
      spatialindex
      expat
      sqlite
      flex
      bison
      fcgi
    ].freeze
    # Force CMake to search HB/opt paths first, so headers in HB/include are not found instead;
    # specifically, ensure any gdal v1 includes are not used
    args << "-DCMAKE_PREFIX_PATH=#{cmake_prefixes.map { |f| Formula[f.to_s].opt_prefix }.join(";")}"

    args += %w[
      -DENABLE_PYTHON3=TRUE
      -DENABLE_TESTS=TRUE
      -DENABLE_MODELTEST=TRUE
      -DQGIS_MACAPP_BUNDLE=0
      -DQGIS_MACAPP_INSTALL_DEV=FALSE
      -DWITH_QWTPOLAR=TRUE
      -DWITH_INTERNAL_QWTPOLAR=FALSE
      -DWITH_ASTYLE=FALSE
      -DWITH_QSCIAPI=TRUE
      -DWITH_STAGED_PLUGINS=TRUE
      -DWITH_GRASS=FALSE
      -DWITH_CUSTOM_WIDGETS=TRUE
    ]

    args << "-DWITH_QTWEBKIT=#{build.with?("qt5-webkit") ? "TRUE" : "FALSE"}"

    # Prefer opt_prefix for CMake modules that find versioned prefix by default
    # This keeps non-critical dependency upgrades from breaking QGIS linking
    args << "-DGDAL_LIBRARY=#{Formula["gdal2"].opt_lib}/libgdal.dylib"
    args << "-DGEOS_LIBRARY=#{Formula["geos"].opt_lib}/libgeos_c.dylib"
    args << "-DGSL_CONFIG=#{Formula["gsl"].opt_bin}/gsl-config"
    args << "-DGSL_INCLUDE_DIR=#{Formula["gsl"].opt_include}"
    args << "-DGSL_LIBRARIES='-L#{Formula["gsl"].opt_lib} -lgsl -lgslcblas'"

    args << "-DWITH_SERVER=#{build.with?("server") ? "TRUE" : "FALSE"}"

    args << "-DPOSTGRES_CONFIG=#{Formula["postgresql"].opt_bin}/pg_config" if build.with? "postgresql"

    args << "-DWITH_GRASS7=#{(build.with?("grass") || brewed_grass7?) ? "TRUE" : "FALSE"}"
    if build.with?("grass") || brewed_grass7?
      # this is to build the GRASS Plugin, not for Processing plugin support
      grass7 = Formula["grass7"]
      args << "-DGRASS_PREFIX7='#{grass7.opt_prefix}/grass-base'"
      # Keep superenv from stripping (use Cellar prefix)
      ENV.append "CXXFLAGS", "-isystem #{grass7.prefix.resolved_path}/grass-base/include"
      # So that `libintl.h` can be found (use Cellar prefix; should not be needed anymore with QGIS 2.99+)
      # ENV.append "CXXFLAGS", "-isystem #{Formula["gettext"].include.resolved_path}"
    end

    args << "-DWITH_GLOBE=#{build.with?("globe") ? "TRUE" : "FALSE"}"
    if build.with? "globe"
      osg = Formula["open-scene-graph"]
      opoo "`open-scene-graph` formula's keg not linked." unless osg.linked_keg.exist?
      # must be HOMEBREW_PREFIX/lib/osgPlugins-#.#.#, since all osg plugins are symlinked there
      args << "-DOSG_PLUGINS_PATH=#{HOMEBREW_PREFIX}/lib/osgPlugins-#{osg.version}"
    end

    args << "-DWITH_ORACLE=#{build.with?("oracle") ? "TRUE" : "FALSE"}"
    if build.with? "oracle"
      oracle_opt = Formula["oracle-client-sdk"].opt_prefix
      args << "-DOCI_INCLUDE_DIR=#{oracle_opt}/include/oci"
      args << "-DOCI_LIBRARY=#{oracle_opt}/lib/libclntsh.dylib"
    end

    args << "-DWITH_QSPATIALITE=#{build.with?("qspatialite") ? "TRUE" : "FALSE"}"

    args << "-DWITH_APIDOC=#{build.with?("api-docs") ? "TRUE" : "FALSE"}"

    # if using Homebrew's Python, make sure its components are always found first
    # see: https://github.com/Homebrew/homebrew/pull/28597
    ENV["PYTHONHOME"] = python_prefix

    # handle custom site-packages for keg-only modules and packages
    ENV["PYTHONPATH"] = python_site_packages

    # handle some compiler warnings
    # ENV["CXX_EXTRA_FLAGS"] = "-Wno-unused-private-field -Wno-deprecated-register"
    # if ENV.compiler == :clang && (MacOS::Xcode.version >= "7.0" || MacOS::CLT.version >= "7.0")
    #   ENV.append "CXX_EXTRA_FLAGS", "-Wno-inconsistent-missing-override"
    # end

    mkdir "build" do
      # editor = "/usr/local/bin/bbedit"
      # cmake_config = Pathname("#{Dir.pwd}/#{name}_cmake-config.txt")
      # cmake_config.write ["cmake ..", *args].join(" \\\n")
      # system editor, cmake_config.to_s
      # raise
      system "cmake", "-G", build.with?("ninja") ? "Ninja" : "Unix Makefiles", *args, ".."
      # system editor, "CMakeCache.txt"
      # raise
      system "cmake", "--build", ".", "--target", "all", "--", "-j", Hardware::CPU.cores
      system "cmake", "--build", ".", "--target", "install", "--", "-j", Hardware::CPU.cores
    end

    # Update .app's bundle identifier, so other installers doesn't get confused
    inreplace prefix/"QGIS.app/Contents/Info.plist",
              "org.qgis.qgis3", "org.qgis.qgis3-hb-dev"

    py_lib = lib/"python#{py_ver}/site-packages"
    py_lib.mkpath
    ln_s "../../../QGIS.app/Contents/Resources/python/qgis", py_lib/"qgis"

    ln_s "QGIS.app/Contents/MacOS/fcgi-bin", prefix/"fcgi-bin" if build.with? "server"

    doc.mkpath
    mv prefix/"QGIS.app/Contents/Resources/doc/api", doc/"api" if build.with? "api-docs"
    ln_s "../../../QGIS.app/Contents/Resources/doc", doc/"doc"

    # copy PYQGIS_STARTUP file pyqgis_startup.py, even if not isolating (so tap can be untapped)
    # only works with QGIS > 2.0.1
    # doesn't need executable bit set, loaded by Python runner in QGIS
    # TODO: for Py3
    # libexec.install resource("pyqgis-startup")

    bin.mkdir
    qgis_bin = bin/name.to_s
    touch qgis_bin.to_s # so it will be linked into HOMEBREW_PREFIX
    qgis_bin.chmod 0755
    post_install
  end

  def post_install
    # configure environment variables for .app and launching binary directly.
    # having this in `post_intsall` allows it to be individually run *after* installation with:
    #    `brew postinstall -v <formula-name>`

    app = prefix/"QGIS.app"
    tab = Tab.for_formula(self)
    opts = tab.used_options

    # define default isolation env vars
    pthsep = File::PATH_SEPARATOR
    pypth = python_site_packages.to_s
    pths = %w[/usr/bin /bin /usr/sbin /sbin /opt/X11/bin /usr/X11/bin]

    # unless opts.include?("with-isolation")
    #   pths = ORIGINAL_PATHS.dup
    #   pyenv = ENV["PYTHONPATH"]
    #   if pyenv
    #     pypth = pyenv.include?(pypth) ? pyenv : pypth + pthsep + pyenv
    #   end
    # end

    unless pths.include?(HOMEBREW_PREFIX/"bin")
      pths = pths.insert(0, HOMEBREW_PREFIX/"bin")
    end

    # set install's lib/python#{py_ver}/site-packages first, so app will work if unlinked
    pypths = %W[#{opt_lib}/python#{py_ver}/site-packages #{pypth}]

    pths.insert(0, gdal_opt_bin)
    pths.insert(0, gdal_python_opt_bin)
    pypths.insert(0, gdal_python_packages)

    if opts.include?("with-gpsbabel")
      pths.insert(0, Formula["gpsbabel"].opt_bin.to_s)
    end

    envars = {
      :PATH => pths.join(pthsep),
      :PYTHONPATH => pypths.join(pthsep),
      :GDAL_DRIVER_PATH => "#{HOMEBREW_PREFIX}/lib/gdalplugins",
    }
    envars[:GDAL_DATA] = "#{Formula["gdal2"].opt_share}/gdal"

    proc_algs = "Contents/Resources/python/plugins/processing/algs"
    if opts.include?("with-grass") || brewed_grass7?
      grass7 = Formula["grass7"]
      # for core integration plugin support
      envars[:GRASS_PREFIX] = "#{grass7.opt_prefix}/grass-base"
      begin
        inreplace app/"#{proc_algs}/grass7/Grass7Utils.py",
                  "/Applications/GRASS-7.0.app/Contents/MacOS",
                  "#{grass7.opt_prefix}/grass-base"
      rescue Utils::InreplaceError
        puts "GRASS 7 GrassUtils already updated"
      end
    end

    unless opts.include?("without-globe")
      osg = Formula["open-scene-graph"]
      envars[:OSG_LIBRARY_PATH] = "#{HOMEBREW_PREFIX}/lib/osgPlugins-#{osg.version}"
    end

    # TODO: add for Py3
    # if opts.include?("with-isolation") || File.exist?("/Library/Frameworks/GDAL.framework")
    #   envars[:PYQGIS_STARTUP] = opt_libexec/"pyqgis_startup.py"
    # end

    # envars.each { |key, value| puts "#{key.to_s}=#{value}" }
    # exit

    # add env vars to QGIS.app's Info.plist, in LSEnvironment section
    plst = app/"Contents/Info.plist"
    # first delete any LSEnvironment setting, ignoring errors
    # CAUTION!: may not be what you want, if .app already has LSEnvironment settings
    dflt = `defaults read-type \"#{plst}\" LSEnvironment 2> /dev/null`
    `defaults delete \"#{plst}\" LSEnvironment` if dflt
    kv = "{ "
    envars.each { |key, value| kv += "'#{key}' = '#{value}'; " }
    kv += "}"
    `defaults write \"#{plst}\" LSEnvironment \"#{kv}\"`
    # add ability to toggle high resolution in Get Info dialog for app
    hrc = `defaults read-type \"#{plst}\" NSHighResolutionCapable 2> /dev/null`
    `defaults delete \"#{plst}\" NSHighResolutionCapable` if hrc
    `defaults write \"#{plst}\" NSHighResolutionCapable \"True\"`
    # leave the plist readable; convert from binary to XML format
    `plutil -convert xml1 -- \"#{plst}\"`
    # make sure plist is readble by all users
    plst.chmod 0644
    # update modification date on app bundle, or changes won't take effect
    touch app.to_s

    # add env vars to launch script for QGIS app's binary
    qgis_bin = bin/name.to_s
    rm_f qgis_bin if File.exist?(qgis_bin) # install generates empty file
    bin_cmds = %W[#!/bin/sh\n]
    # setup shell-prepended env vars (may result in duplication of paths)
    unless pths.include? HOMEBREW_PREFIX/"bin"
      pths.insert(0, HOMEBREW_PREFIX/"bin")
    end
    # even though this should be affected by with-isolation, allow local env override
    pths << "$PATH"
    pypths << "$PYTHONPATH"
    envars[:PATH] = pths.join(pthsep)
    envars[:PYTHONPATH] = pypths.join(pthsep)
    envars.each { |key, value| bin_cmds << "export #{key}=#{value}" }
    bin_cmds << opt_prefix/"QGIS.app/Contents/MacOS/QGIS \"$@\""
    qgis_bin.write(bin_cmds.join("\n"))
    qgis_bin.chmod 0755
  end

  def caveats
    s = <<-EOS.undent
      Bottles support only Homebrew's Python3

      QGIS is built as an application bundle. Environment variables for the
      Homebrew prefix are embedded in QGIS.app:
        #{opt_prefix}/QGIS.app

      You may also symlink QGIS.app into /Applications or ~/Applications:
        brew linkapps [--local]

      To directly run the `QGIS.app/Contents/MacOS/QGIS` binary use the wrapper
      script pre-defined with Homebrew prefix environment variables:
        #{opt_bin}/#{name}

      NOTE: Your current PATH and PYTHONPATH environment variables are honored
            when launching via the wrapper script, while launching QGIS.app
            bundle they are not.

      For standalone Python3 development, set the following environment variable:
        export PYTHONPATH=#{qgis_python_packages}:#{gdal_python_packages}:#{python_site_packages}:$PYTHONPATH

    EOS

    # check for recommended dev Python module dependencies
    xm = []
    %w[pyparsing mock nose2].each do |m|
      xm << m unless module_importable? m
    end
    unless xm.empty?
      s += <<-EOS.undent
        #{Tty.red}
        The following Python modules are recommended for QGIS development/testing:

            #{xm.join(", ")}

        You can install manually, via installer package or with `pip3` (if availble):

            pip3 install <module>
        #{Tty.red}
        #{Tty.reset}
      EOS
    end

    s += <<-EOS.undent
      If you have built GRASS 7 for the Processing plugin set the following in QGIS:
        Processing->Options: Providers->GRASS GIS 7 commands->GRASS 7 folder to:
           #{HOMEBREW_PREFIX}/opt/grass7/grass-base

    EOS

    s
  end

  test do
    output = `#{bin}/#{name.to_s} --help 2>&1` # why does help go to stderr?
    assert_match /^QGIS is a user friendly/, output
  end

  private

  def brewed_grass7?
    Formula["grass7"].opt_prefix.exist?
  end

  def python_exec
    `which python3`.strip
  end

  def py_ver
    `#{python_exec} -c 'import sys;print("{0}.{1}".format(sys.version_info[0],sys.version_info[1]))'`.strip
  end

  def brewed_python?
    Formula["python3"].linked_keg.exist?
  end

  def python_site_packages
    HOMEBREW_PREFIX/"lib/python#{py_ver}/site-packages"
  end

  def python_prefix
    `#{python_exec} -c 'import sys;print(sys.prefix)'`.strip
  end

  def qgis_python_packages
    opt_lib/"python#{py_ver}/site-packages".to_s
  end

  def gdal_python_packages
    Formula["gdal2-python"].opt_lib/"python#{py_ver}/site-packages".to_s
  end

  def gdal_python_opt_bin
    Formula["gdal2-python"].opt_bin.to_s
  end

  def gdal_opt_bin
    Formula["gdal2"].opt_bin.to_s
  end

  def module_importable?(mod)
    `#{python_exec} -c 'import sys;sys.path.insert(1, "#{gdal_python_packages}"); import #{mod}'`.strip
  end
end
