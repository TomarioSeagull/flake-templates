{
    inputs = {
        nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";
		naersk = {
			url = "github:nix-community/naersk";
			inputs.nixpkgs.follows = "nixpkgs";
		};
    };

    outputs = inputs: {
        packages = builtins.mapAttrs (system: pkgs: {
            default = inputs.naersk.lib.${system}.buildPackage {
				src = ./.;
				doCheck = true;
			};

			container = let
				default = inputs.self.packages.${system}.default;
				inherit (builtins.parseDrvName default.name) name;
			in pkgs.dockerTools.buildLayeredImage {
				inherit name;
				contents = [ default ];
				config.Cmd = [ "/bin/${name}" ];
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
