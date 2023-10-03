{
    description = "Tools for high frequency quantitative analysis";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    };
    outputs = { self, nixpkgs }:
    let 
        system = "x86_64-linux"; 
        pkgs = (import nixpkgs) { inherit system; };

        custom-r = pkgs.rWrapper.override{ 
            packages = with pkgs.rPackages; [
                rmarkdown
            ]; 
        };
    in
    {
        devShells.${system}.default = pkgs.mkShell {
            buildInputs = with pkgs; [
                custom-r
            ];
        };

        packages.${system}.main = pkgs.stdenv.mkDerivation rec{
            name = "main";
            src = ./.;
            nativeBuildInputs = with pkgs; [ 
                pkgs.bashInteractive
            ];
            buildInputs = with pkgs; [ 
                pkgs.texlive.combined.scheme-full
                pkgs.pandoc
                custom-r 
            ];
            buildPhase = ''
                ${custom-r}/bin/Rscript -e "rmarkdown::render('main.rmd’, 'html_document')"
            '';
            installPhase = ''
                mkdir -p $out/doc
                mkdir -p $out/bin
                cp main.rmd $out/bin
                chmod +x $out/bin/main.rmd
                mv main.html $out/doc
            '';
        };

        apps.${system}.main = {
            type = "app";
            program = "${self.packages.${system}.main}/bin/main.rmd";
        };
    };
}
