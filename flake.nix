{
    description = "Tools for high frequency quantitative analysis";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    };
    outputs = { self, nixpkgs }:
    let 
        system = "x86_64-linux"; 
        pkgs = (import nixpkgs) { inherit system; };

        custom-r = pkgs.rWrapper.override {  
            packages = with pkgs.rPackages; [
                rmarkdown
            ]; 
        };

        working_dir = "$(${pkgs.coreutils}/bin/pwd)";
    in
    {
        devShells.${system}.default = pkgs.mkShell {
            buildInputs = with pkgs; [
                custom-r
            ];
            shellHook = ''
                export HOME=${working_dir}
            '';
        };

        packages.${system}.main = pkgs.stdenv.mkDerivation rec{
            name = "main";
            src = ./.;
            nativeBuildInputs = with pkgs; [ 
                pkgs.pandoc
                pkgs.texlive.combined.scheme-full
                pkgs.bashInteractive
                custom-r 
            ];
            buildPhase = ''
                export HOME=${working_dir}
                echo $HOME 
                ${custom-r}/bin/Rscript -e "rmarkdown::render('main.rmd’, 'html_document')"
            '';
            installPhase = ''
                mkdir -p $out/doc
                mv main.html $out/doc/
            '';
        };
    };
}
