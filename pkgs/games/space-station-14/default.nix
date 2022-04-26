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
  dotnet-runtime = dotnetCorePackages.runtime_6_0;
  installPath = "$out/opt/space-station-14";
  buildType = "Release";
  executables = [];
  #dotnetBuildFlags = [
  #  "-p:FullRelease=true"
  #];
  #patches = [./loaderenv.patch];
  #dontDotnetConfigure = true;
  #buildPhase = ''
  #  dotnet publish SS14.Launcher/SS14.Launcher.csproj /p:FullRelease=True -c Release --no-self-contained -r linux-x64 /nologo
  #  dotnet publish SS14.Loader/SS14.Loader.csproj -c Release --no-self-contained -r linux-x64 /nologo

  #  # Create intermediate directories.
  #  mkdir -p bin/publish/Linux/bin
  #  mkdir -p bin/publish/Linux/bin/loader
  #  mkdir -p bin/publish/Linux/dotnet

  #  cp PublishFiles/SS14.Launcher PublishFiles/SS14.desktop bin/publish/Linux/
  #  cp SS14.Launcher/bin/Release/net6.0/linux-x64/publish/* bin/publish/Linux/bin/
  #  cp SS14.Loader/bin/Release/net6.0/linux-x64/publish/* bin/publish/Linux/bin/loader
  #  cp -r Dependencies/dotnet/linux/* bin/publish/Linux/dotnet/
  #'';
  installPhase = ''
    ls
    dotnet publish SS14.Launcher/SS14.Launcher.csproj /p:FullRelease=True -c Release --no-self-contained --p:Deterministic=true --no-build /nologo
    dotnet publish SS14.Loader/SS14.Loader.csproj -c Release --no-self-contained --p:Deterministic=true --no-build /nologo
    # Create intermediate directories.
    mkdir -p bin/publish/Linux/bin
    mkdir -p bin/publish/Linux/bin/loader
    mkdir -p bin/publish/Linux/dotnet

    ls SS14.Launcher/bin/Release/net6.0/publish
    cp -r SS14.Launcher/bin/Release/net6.0/publish/* bin/publish/Linux/bin/
    cp -r SS14.Loader/bin/Release/net6.0/publish/* bin/publish/Linux/bin/loader

    mkdir -p $out/lib/space-station-14
    mv bin/publish/Linux/bin/* $out/lib/space-station-14/
  '';

  dotnetFlags = [
    "-p:FullRelease=True"
  ];

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
