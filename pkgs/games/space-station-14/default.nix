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
, mkNugetDeps
, mkNugetSource
}:
let
  version = "0.13.0";
  ss14-launcher = pkgs.writeShellScriptBin "space-station-14" ''
    SS14_PATH=$(nix-store -r $(which space-station-14))
    exec $SS14_PATH/space-station-14/SS14.Launcher
  '';
  nugetDeps = ./deps.nix;
  _nugetDeps = mkNugetDeps { name = "ss14-nuget-deps"; nugetDeps = import nugetDeps; };
  nugetSource = mkNugetSource {
    name = "ss14-nuget-source";
    description = "A Nuget source with the dependencies for ss14";
    deps = [ _nugetDeps ];
  };
in
buildDotnetModule rec {
  pname = "space-station-14";
  inherit version nugetDeps;

  src = fetchFromGitHub {
    owner = "space-wizards";
    repo =  "SS14.Launcher";
    rev = "v${version}";
    fetchSubmodules = true;
    sha256 = "YeLWwA7wFNvEZ7Tp3GqIsXDjPV6gvxcjhzwSqPHWGrg=";
  };

  projectFile = "SS14.Launcher.sln";

  patches = [];

  dotnet-sdk = dotnetCorePackages.sdk_6_0;
  dotnet-runtime = dotnetCorePackages.runtime_6_0;
  installPath = "$out/opt/space-station-14";
  executables = [];
  dontDotnetConfigure = true;
  buildPhase = ''
    dotnet publish SS14.Launcher/SS14.Launcher.csproj \
      /p:FullRelease=True \
      -c Release \
      --no-self-contained \
      -r linux-x64 \
      /nologo \
      --source "${nugetSource}/lib"
    dotnet publish SS14.Loader/SS14.Loader.csproj \
      -c Release \
      --no-self-contained \
      -r linux-x64 \
      /nologo \
      --source "${nugetSource}/lib"
  '';
  installPhase = ''
    mkdir -p $out/lib/space-station-14/loader

    cp -r SS14.Launcher/bin/Release/net6.0/linux-x64/publish/* $out/lib/space-station-14/
    cp -r SS14.Loader/bin/Release/net6.0/linux-x64/publish/* $out/lib/space-station-14/loader
  '';

  runtimeDeps = [
    libX11
    libICE
    libSM
    fontconfig
    pkgs.bash
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
