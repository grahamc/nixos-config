(p: (import <nixpkgs> {}).callPackage p {})
(
{ runCommand, requireFile, jdk
, buildFHSUserEnv, makeWrapper, autoPatchelfHook, binutils
, stdenv, libstdcxx5, strace, xlibs
}:
let
  env = buildFHSUserEnv {
    name = "oxygen-env";
    targetPkgs = pkgs: [ pkgs.jdk ];
    runScript = ''
      bash -c "set -x
      cp ${./oxygen.sh} ./install.sh
      chmod +x ./install.sh
      sh ./install.sh -q -varfile ${./varfile}"
    '';

  };

installed = runCommand "oxygen-cmd" {
  installer = ./oxygen.sh;
  buildInputs = [ binutils jdk ];
} ''
  # the varfile passed in the FHS wrapper will
  ${env}/bin/oxygen-env

  mv staged $out
'';

patchelftry = stdenv.mkDerivation {
  name = "oxygen";
  src = installed;

  buildInputs = [
    autoPatchelfHook
    libstdcxx5
  ];

  buildPhase = ''
    echo hi
  '';

  installPhase = ''
    pwd
    cd ..
    mv ./oxygen-cmd $out
  '';
};
deletejre = stdenv.mkDerivation {
  name = "oxygen-nojre";
  src = installed;

  buildInputs = [ makeWrapper jdk ];

  buildPhase = ''
    ls -la
    rm -rf jre
  '';

  installPhase = ''
    pwd
    cd ..
    mv ./oxygen-cmd $out

    cd $out
    wrapProgram $out/oxygen.sh \
      --set JAVA_HOME "${jdk.home}" \
      --set _JAVA_AWT_WM_NONREPARENTING=1

      # _JAVA_AWT_WM_NONREPARENTING=1 is for sway bugs
      # see: https://github.com/swaywm/sway/issues/595
  '';
};

fhstry = buildFHSUserEnv {
  name = "oxygen-fhs";
  # target pkgs found via:
  # nix-build && strace -f ./result/bin/oxygen-fhs 2>&1 | tee oxygen.log
  # then: ./missing.sh (listed numbers on left are # of times it was loaded OK)
  targetPkgs = pkgs: with pkgs; [
    acl
    attr
    utillinux # libblkid?
    bzip2
    libcap
    dbus_daemon
    dbus-glib
    expat
    glibc # libc, libdl, libm, libpthread, librt
    libffi
    fontconfig
    freetype
    gnome2.GConf
    gnome2.ORBit2
    gnome2.gtk
    gnome3.gtk
    gnome2.gnome_vfs
    libgcrypt
    libgpgerror
    glib
    readline
    lz4
    lzma
    ncurses
    pcre

    libpng
    libpng_apng
    libselinux
    systemd
    libuuid

    xlibs.libX11
    xlibs.libXau
    xlibs.libxcb
    xlibs.libXcursor
    xlibs.libXdmcp
    xlibs.libXext
    xlibs.libXfixes
    xlibs.libXinerama
    xlibs.libXi
    xlibs.libXrender
    xlibs.libXtst
    zlib
    watch
    xterm


  ];


  #runScript = "bash -c 'JAVA_HOME=${jdk.home} ${strace}/bin/strace -f ${installed}/oxygen.sh'";
  runScript = "bash -x ${deletejre}/oxygen.sh";

    /*''
      bash -c "set -x
      cp ${./oxygen.sh} ./install.sh
      chmod +x ./install.sh
      sh ./install.sh -q -varfile ${./varfile}"
    '';
    */
  };

in deletejre # fhstry
)
