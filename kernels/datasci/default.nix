{ name
, availableKernels
, extraArgs
,
}:
let
  pkgs = import extraArgs.nixpkgs
    {
      inherit (extraArgs) system;
      overlays = [ extraArgs.poetry2nix.overlay ];
    };
in

availableKernels.python
{
  name = "datasci";
  displayName = "Data Science Environment";

  ignoreCollisions = true;
  overrides = pkgs.poetry2nix.overrides.withDefaults (import ./overrides.nix pkgs);
  projectDir = ./.;
}
