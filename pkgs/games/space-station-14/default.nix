{ lib
, stdenv
, fetchFromGitHub
, buildDotnetModule
, dotnetCorePackages
, libX11
, libICE
, libSM
, fontconfig
, pkgs
}:
let
  version = "0.13.0";
  ss14-launcher = pkgs.writeShellScriptBin "space-station-14" ''
    SS14_PATH=$(nix-store -r $(which space-station-14))
    exec $SS14_PATH/space-station-14/SS14.Launcher
  '';
in
buildDotnetModule rec {
  pname = "space-station-14";
  inherit version;

  src = fetchFromGitHub {
    owner = "space-wizards";
    repo =  "SS14.Launcher";
    rev = "v${version}";
    fetchSubmodules = true;
    sha256 = "YeLWwA7wFNvEZ7Tp3GqIsXDjPV6gvxcjhzwSqPHWGrg=";
  };

  projectFile = "SS14.Launcher.sln";
  nugetDeps = ./deps.nix;

  dotnet-sdk = dotnetCorePackages.sdk_6_0;
  dotnet-runtime = dotnetCorePackages.aspnetcore_6_0;
  installPath = "$out/opt/space-station-14";
  executables = [];

  dotnetFlags = [
    "-p:FullRelease=True"
  ];

  runtimeDeps = [
    libX11
    libICE
    libSM
    fontconfig
    ss14-launcher
  ];

  meta = with lib; {
    description = "A multiplayer game about paranoia and chaos on a space station.";
    longDescription = ''
      A multiplayer game about paranoia and chaos on a space station. Remake 
      of the cult-classic Space Station 13. 
    '';
    homepage = "https://spacestation14.io/";
    license = licenses.mit;
    maintainers = [ maintainers.soupstraw ];
    platforms = [ "x86_64-linux" ];
  };
}
