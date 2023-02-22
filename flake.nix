{
  description = "Your jupyterWith project";

  inputs.utils.url = "github:numtide/flake-utils";
  # inputs.jupyterWith.url = "github:tweag/jupyterWith";
  inputs.jupyterWith.url = "github:gtrunsec/jupyterWith/dev";

  outputs =
    { self
    , utils
    , jupyterWith
    }:
    utils.lib.eachSystem
      [
        utils.lib.system.x86_64-linux
      ]
      (
        system:
        let
          inherit (jupyterWith.inputs) nixpkgs poetry2nix;
          inherit (jupyterWith.lib.${system}) mkJupyterlabFromPath;
          jupyterlab = mkJupyterlabFromPath ./kernels { inherit system poetry2nix nixpkgs; };
          pkgs = import nixpkgs {
            inherit system;
          };
        in
        rec {
          packages = { inherit jupyterlab; };
          packages.default = jupyterlab;

          devShells.default = pkgs.mkShell { packages = [ jupyterWith.inputs.poetry2nix.packages."${system}".poetry ]; };
          apps = {
            default = { type = "app"; program = "${packages.jupyterlab}/bin/jupyter-lab"; };
            update-lock = jupyterWith.apps."${system}".update-poetry-lock;
            fmt = utils.lib.mkApp {
              drv = with pkgs;
                pkgs.writeShellScriptBin "jupyter-fmt" ''
                  export PATH=${
                    pkgs.lib.strings.makeBinPath [
                      findutils
                      nixpkgs-fmt
                    ]
                  }
                  find . -type f -name '*.nix' -exec nixpkgs-fmt {} +
                '';
            };
          };
        }
      );
}
