{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation rec {
  pname = "opengamepadui";
  version = "0.11.20";

  src = pkgs.fetchFromGitHub {
    owner = "ShadowBlip";
    repo = "OpenGamepadUI";
    rev = "v${version}";
    sha256 = "X6lWoTdKS9YyF9Xm8KYS7ZZK5/RIUuM7C/wWHYUuff8=";
  };

  nativeBuildInputs = with pkgs; [
    copyDesktopItems
    godot-headless
    wget
  ];

  buildInputs = with pkgs; [
    gamescope
    gcc.cc.libgcc
    glibc
    libevdev
    xorg.libX11
    xorg.libXau
    xorg.libxcb
    xorg.libXdmcp
    xorg.libXext
    xorg.libXres
  ];

  # patch shebangs so that e.g. the fake-editor script works:
  # error: /usr/bin/env 'perl': No such file or directory
  # error: There was a problem with the editor
  postPatch = ''
    patchShebangs scripts
  '';

  buildPhase = ''
    runHook preBuild

    # Cannot create file '/homeless-shelter/.config/godot/projects/...'
    export HOME=$TMPDIR

    # Link the export-templates to the expected location. The --export commands
    # expects the template-file at .../templates/3.2.3.stable/linux_x11_64_release
    # with 3.2.3 being the version of godot.
    mkdir -p $HOME/.local/share/godot
    ln -s ${pkgs.godot-export-templates}/share/godot/templates $HOME/.local/share/godot
    mkdir -p $out/share/OpenGamepadUI
    godot-headless --export "Linux/X11" $out/share/OpenGamepadUI/OpenGamepadUI

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    ln -s $out/share/OpenGamepadUI/OpenGamepadUI $out/bin
    # Patch binaries.
    interpreter=$(cat $NIX_CC/nix-support/dynamic-linker)
    patchelf \
      --set-interpreter $interpreter \
      --set-rpath ${pkgs.lib.makeLibraryPath buildInputs} \
      $out/share/OpenGamepadUI/OpenGamepadUI
    mkdir -p $out/share/pixmaps
    #cp images/OpenGamepadUI.png $out/share/pixmaps/OpenGamepadUI.png
    runHook postInstall
  '';

  meta = with pkgs.lib; {
    homepage = "https://github.com/ShadowBlip/OpenGamepadUI";
    description = "A free and open source game launcher and overlay";
    license = licenses.agpl3Plus;
    maintainers = [ maintainers.soupstraw ];
    platforms = platforms.unix;
  };

}
