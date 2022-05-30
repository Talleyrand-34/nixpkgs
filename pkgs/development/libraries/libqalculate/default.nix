{ lib, stdenv, fetchFromGitHub, mpfr, libxml2, intltool, pkg-config, doxygen,
  autoreconfHook, readline, libiconv, icu, curl, gnuplot, gettext }:

stdenv.mkDerivation rec {
  pname = "libqalculate";
  version = "4.2.0";

  src = fetchFromGitHub {
    owner = "qalculate";
    repo = "libqalculate";
    rev = "v${version}";
    sha256 = "sha256-mIzHizoDsdSVcepWACeVkCTgt4gxd99WKXrrGi+qASo=";
  };

  outputs = [ "out" "dev" "doc" ];

  nativeBuildInputs = [ intltool pkg-config autoreconfHook doxygen ];
  buildInputs = [ curl gettext libiconv readline ];
  propagatedBuildInputs = [ libxml2 mpfr icu ];
  enableParallelBuilding = true;

  preConfigure = ''
    intltoolize -f
  '';

  patchPhase = ''
    substituteInPlace libqalculate/Calculator-plot.cc \
      --replace 'commandline = "gnuplot"' 'commandline = "${gnuplot}/bin/gnuplot"' \
      --replace '"gnuplot - ' '"${gnuplot}/bin/gnuplot - '
  '' + lib.optionalString stdenv.cc.isClang ''
    substituteInPlace src/qalc.cc \
      --replace 'printf(_("aborted"))' 'printf("%s", _("aborted"))'
  '';

  preBuild = ''
    pushd docs/reference
    doxygen Doxyfile
    popd
  '';

  meta = with lib; {
    broken = (stdenv.isLinux && stdenv.isAarch64);
    description = "An advanced calculator library";
    homepage = "http://qalculate.github.io";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ gebner doronbehar ];
    mainProgram = "qalc";
    platforms = platforms.all;
  };
}
