{
  description = "Home Manager configuration of leoz";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, dms, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations."leoz@desktop" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          dms.homeModules.dank-material-shell
          ./home.nix
          ./.modules/desktop.nix
          ./.modules/minecraft.nix
        ];
      };

      homeConfigurations."leoz@laptop" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home.nix
          ./.modules/laptop.nix
        ];
      };
    };
}
