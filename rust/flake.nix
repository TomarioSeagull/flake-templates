{
    inputs = {
        nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";
    };

    outputs = inputs: 
    let cargoToml = fromTOML (builtins.readFile ./Cargo.toml);
    in {
        packages = builtins.mapAttrs (system: pkgs: {
            default = pkgs.rustPlatform.buildRustPackage {
                pname = cargoToml.package.name;
                version = cargoToml.package.version;
                src = ./.;

                cargoLock.lockFile = ./Cargo.lock;
            };
        }) inputs.nixpkgs.legacyPackages;

        devShells = builtins.mapAttrs (system: pkgs: {
            default = pkgs.mkShell {
                packages = with pkgs; [
                    rustc
                    cargo
                    clippy
                    rustfmt
                    rust-analyzer
                ];
            };
        }) inputs.nixpkgs.legacyPackages;
    };
}
