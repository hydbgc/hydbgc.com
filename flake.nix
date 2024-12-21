{
  description = "hydbgc.com website flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    fu.url = "github:numtide/flake-utils";
    ruby-nix.url = "github:inscapist/ruby-nix";
    bundix = {
      url = "github:inscapist/bundix/main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, fu, ruby-nix, bundix }:
    fu.lib.eachDefaultSystem
    (system:
      let
        pkgs = import nixpkgs {
            inherit system;
            overlays = [ ruby-nix.overlays.ruby ];
          };
        rubyNix = ruby-nix.lib pkgs;
        bundixcli = bundix.packages.${system}.default;
        inherit (rubyNix {
            name = "hydbgc-ruby-deps";
            gemset = ./gemset.nix;
          })
        env ruby;
      in
      with pkgs;
      {
          devShells.default = mkShell {
              buildInputs = [env ruby bundixcli];
            };
        });
}
