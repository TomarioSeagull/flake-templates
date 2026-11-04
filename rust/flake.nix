{
	inputs = {
		nixpkgs.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.zst";
	};

	outputs = inputs:
	let cargoToml = fromTOML (builtins.readFile ./cargo.toml);
	in builtins.mapAttrs (system: pkgs: {
		packages.default = pkgs.rustPlatform.buildRustPackage {
			pname = cargoToml.package.name;
			version = cargoToml.package.version;
			src = ./.;

			cargoLock.lockFile = ./Cargo.lock;
		};

		devshells.default = pkgs.mkShell {
			packages = with pkgs; [
				rustc
				cargo
				clippy
				rustfmt
				rust-analyzer
			];
		};
	}) inputs.nixpkgs.legacyPackages;
}
