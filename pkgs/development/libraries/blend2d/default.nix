{ stdenv
, fetchFromGitHub
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "blend2d";
  version = "0.10.6";
  src = fetchFromGitHub {
    owner = "blend2d";
    repo = "blend2d";
  };
})
