with import <nixpkgs> {};

stdenv.mkDerivation rec {
    name = "Shotwell";

    buildInputs = [
        pkgs.sqlite
        pkgs.sqlite-utils
        pkgs.lua53Packages.lua
        pkgs.lua53Packages.luarocks
        pkgs.lua53Packages.luadbi-sqlite3
        #pkgs.lua
        #pkgs.luarocks
    ];

    env = buildEnv {
        name = name;
        paths = buildInputs;
    };

    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
        pkgs.sqlite
    ];

    shellHook = "export PS1='\n\\[\\033[01;32m\\][nix Shotwell] \\w\\$\\[\\033[00m\\] '";
}
