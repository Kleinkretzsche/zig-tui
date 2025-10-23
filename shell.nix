with import <nixpkgs> {};

let
  unstable = import
    (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz")
    { config = config; };
in
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    unstable.zls
    unstable.zig_0_15
    gdb
    valgrind
    python3
    wabt
    expat
    vscode-langservers-extracted
    linuxPackages_latest.perf
    pkg-config
    zip
  ];
  shellHook =
  ''
    export ZIG_GLOBAL_CACHE_DIR=$PWD/.zig-cache
  '';
}
