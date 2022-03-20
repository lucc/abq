{
  description = "Development flake for abq";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs, utils }: utils.lib.eachDefaultSystem (system:
    let pkgs = import nixpkgs { inherit system; }; in
    {
      defaultPackage = pkgs.stdenv.mkDerivation {
        pname = "abq";
        version = "dev";
        src = ./.;
        makeFlags = [ "PREFIX=$(out)" ];
        buildInputs = with pkgs; [
          gnumake
          notmuch
          gnused
          bash
          gnupg
          coreutils
          khard
          jq
        ];
      };
    }
  );
}
