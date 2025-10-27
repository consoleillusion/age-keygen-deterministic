{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nix-community/naersk";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, flake-utils, naersk, nixpkgs }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = (import nixpkgs) {
          inherit system;
        };
        naersk' = pkgs.callPackage naersk {};
      in rec {
        defaultPackage = naersk'.buildPackage {
          src = ./.;
        };

        packages.${system}.default = pkgs.stdenv.mkDerivation {
          name = "age-keygen-deterministic";
          src = self;
          buildPhase = "cargo build --release";
          installPhase = "mkdir -p $out/bin; install -t $out/bin age-keygen-deterministic";
        };
        packages.${system}.age-keygen-deterministic = packages.${system}.default;

        devShell = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [ rustc cargo ];
        };
        /*
        defaultApp = {
          type = "app";
          program = "${defaultPackage}/bin/age-keygen-deterministic";
        };
        */
      }
    );
}
