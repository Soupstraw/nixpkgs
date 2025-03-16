{
  buildKodiAddon,
  fetchFromGitHub,
  pkgs,
  lib,
}: buildKodiAddon rec {
  pname = "moonlight-qt";
  namespace = "plugin.program";
  version = "0.4.6";

  src = fetchFromGitHub {
    owner = "veldenb";
    repo = "${namespace}.${pname}";
    rev = "v${version}";
    hash = "sha256-tv3dKZZsn+PtWK2FudZvYUOcWmA4FYc/+juulgsU5jg=";
  };

  propagatedBuildInputs = [
    pkgs.moonlight-qt
  ];

  passthru = {
    pythonPath = "resources/site-packages";
  };

  meta = with lib; {
    homepage = "https://github.com/veldenb/plugin.program.moonlight-qt";
    description = "Kodi 19+ Moonlight launcher for the Raspberry Pi 4 and Generic x86_64 systems";
    license = licenses.gpl3;
    maintainers = teams.kodi.members;
  };
}
