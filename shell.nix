with import <nixpkgs> {};

let
  unstable = import
    (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz")
    # reuse the current configuration
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
}
