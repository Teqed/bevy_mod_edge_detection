{
  description = "Rust development environment and shell";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };
  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          buildInputs = with pkgs; [
              udev
              alsa-lib
              vulkan-loader
              xorg.libX11
              xorg.libXcursor
              xorg.libXi
              xorg.libXrandr # To use the x11 feature
              libxkbcommon
              wayland # To use the wayland feature
              openssl
              pkg-config
              gcc
              pkg-config
              rust
              bacon
              clippy
              trunk# For WASM development
              # tracy # Profiler
            ];
          overlays = [ (import rust-overlay) ];
          pkgs = import nixpkgs {
            inherit system overlays;
          };
          rust = pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default.override {
            extensions = [
              "rust-src" # for rust-analyzer
              "rust-analyzer"
            ];
            targets = [ "wasm32-unknown-unknown" ];
          });
          nativeBuildInputs = with pkgs; [ rust pkg-config ];
        in
        with pkgs;
        {
          devShells.default = mkShell {
            inherit buildInputs nativeBuildInputs;
            LD_LIBRARY_PATH = nixpkgs.legacyPackages.x86_64-linux.lib.makeLibraryPath buildInputs;
            RUST_BACKTRACE = 1;
          };
        }
      );
}