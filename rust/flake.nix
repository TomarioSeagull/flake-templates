{
    inputs = {
        nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";
		naersk = {
			url = "github:nix-community/naersk";
			inputs.nixpkgs.follows = "nixpkgs";
		};
    };

    outputs = inputs: rec {
        packages = builtins.mapAttrs (system: pkgs: {
			default = inputs.naersk.lib.${system}.buildPackage ./.;
			container = pkgs.dockerTools.buildLayeredImage {
				inherit (builtins.parseDrvName packages.${system}.default.name) name;
				contents = [ packages.${system}.default ];
				config = {
					Cmd = [ "/bin/${packages.${system}.container.name}" ];
				};
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
