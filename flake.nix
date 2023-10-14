{
    description = "Tools for high frequency quantitative analysis";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    };
    outputs = { self, nixpkgs }:
    let 
        system = "x86_64-linux"; 
        pkgs = (import nixpkgs) { inherit system; };

        r_packages = with pkgs.rPackages; [ rmarkdown ];

        custom-r = pkgs.rWrapper.override{ packages = r_packages; };
        custom-r_studio = pkgs.rstudioWrapper.override{ packages = r_packages; };

        build_packages = with pkgs; [
            R
            coreutils
            pandoc
            texlive.combined.scheme-full
            custom-r
            custom-r_studio
        ];
    in
    {
        devShells.${system}.default = pkgs.mkShell {
            nativeBuildInputs = [ pkgs.bashInteractive ];
            buildInputs = build_packages;
            shellHook = ''
                export HOME=`${pkgs.coreutils}/bin/pwd`
                export LC_ALL="C"
            '';
        };

        packages.${system}.main = pkgs.stdenv.mkDerivation rec{
            name = "main";
            src = ./.;
            buildPhase = ''
                export HOME=`${pkgs.coreutils}/bin/pwd`
                export LC_ALL="C"
                #${pkgs.nix}/bin/nix develop -i --extra-experimental-features nix-command
                ${custom-r}/bin/Rscript -e "library(rmarkdown); rmarkdown::render('main.rmd’, 'html_document');"
            '';
            installPhase = ''
                mkdir -p $out/doc
                mv main.html $out/doc/
            '';
        };
    };
}
