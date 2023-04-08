{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    gomod2nix = {
      url = "github:nix-community/gomod2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "utils";
    };
  };

  outputs = { self, nixpkgs, utils, gomod2nix }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ gomod2nix.overlays.default ];
        };
      in
      {
        packages = rec {
          default = gtkcord4;
          gtkcord4 = pkgs.buildGoApplication {
            pname = "gtkcord4";
            version = "0.10.0";
            modules = ./nix/gomod2nix.toml;

            src = ./.;
            pwd = ./.;

            nativeBuildInputs = with pkgs; [
              gobject-introspection
              pkg-config
              wrapGAppsHook4
            ];

            buildInputs = with pkgs; [
              cairo
              gdk-pixbuf
              glib
              graphene
              gtk4
              pango
              # Optional according to upstream but required for sound and video
              gst_all_1.gst-plugins-bad
              gst_all_1.gst-plugins-base
              gst_all_1.gst-plugins-good
              gst_all_1.gst-plugins-ugly
              gst_all_1.gstreamer
              libcanberra-gtk3
              sound-theme-freedesktop
              libadwaita
            ];

            postInstall = ''
              install -D -m 444 -t $out/share/applications nix/xyz.diamondb.gtkcord4.desktop
              install -D -m 444 internal/icons/svg/logo.svg $out/share/icons/hicolor/scalable/apps/gtkcord4.svg
              install -D -m 444 internal/icons/png/logo.png $out/share/icons/hicolor/256x256/apps/gtkcord4.png
            '';
          };
        };

        devShell = pkgs.mkShell {
          buildInputs = [
            (pkgs.mkGoEnv {
              pwd = ./.;
              modules = ./nix/gomod2nix.toml;
            })
            pkgs.gomod2nix
          ];
        };
      }
    );
}
