{ pkgs, haskellLib }:

with haskellLib;

self: super:
let
  # This contains updates to the dependencies, without which it would
  # be even more work to get it to build.
  # As of 2020-04, there's no new release in sight, which is why we're
  # pulling from Github.
  tensorflow-haskell = pkgs.fetchFromGitHub {
    owner = "tensorflow";
    repo = "haskell";
    rev = "925c2e95151c0ea1592c26b51a5d98e4ca4a2fe7";
    sha256 = "sha256-k5J7NAFRL4WlsbJ7dVdZps68e6brYxSTkFLn5fiUlFk=";
    fetchSubmodules = true;
  };

  setTensorflowSourceRoot = dir: drv:
    (overrideCabal (drv: { src = tensorflow-haskell; }) drv)
      .overrideAttrs (_oldAttrs: { sourceRoot = "${tensorflow-haskell.name}/${dir}"; });
in
{
  tensorflow-proto = doJailbreak (setTensorflowSourceRoot "tensorflow-proto" super.tensorflow-proto);

  tensorflow = overrideCabal
    (drv: { libraryHaskellDepends = drv.libraryHaskellDepends ++ [self.vector-split]; })
    (setTensorflowSourceRoot "tensorflow" super.tensorflow);

  tensorflow-core-ops = setTensorflowSourceRoot "tensorflow-core-ops" super.tensorflow-core-ops;

  tensorflow-logging = setTensorflowSourceRoot "tensorflow-logging" super.tensorflow-logging;

  tensorflow-opgen = setTensorflowSourceRoot "tensorflow-opgen" super.tensorflow-opgen;

  tensorflow-ops = setTensorflowSourceRoot "tensorflow-ops" super.tensorflow-ops;
}
