{
    description = "Tools for high frequency quantitative analysis";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    };
    outputs = { self, nixpkgs }:
    let 
        system = "x86_64-linux"; 
        pkgs = (import nixpkgs) { inherit system; };
    in
    {
        devShells.${system}.default = pkgs.mkShell {
            buildInputs = with pkgs; [
                R
            ];
        };

        packages.${system}.main = pkgs.stdenv.mkDerivation rec{
            name = "main";
            src = ./.;
            buildInputs = with pkgs; [];
            buildPhase = ''
                chmod +x main.rmd
            '';
            installPhase = ''
                mkdir -p $out/bin
                cp main.rmd $out/bin
            '';
        };

        apps.${system}.main = {
            type = "app";
            program = "${self.packages.${system}.main}/bin/main.rmd";
        };
    };
}
