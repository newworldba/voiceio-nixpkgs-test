{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs =
    { nixpkgs, ... }:
    {
      packages.x86_64-linux.voiceio =
        nixpkgs.legacyPackages.x86_64-linux.callPackage ./package.nix { };
    };
}
