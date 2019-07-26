# from https://raw.githubusercontent.com/thefloweringash/kevin-nix/master/modules/console-font.nix
{ config, pkgs, lib, ... }:

let
  cfg = config.hardware.kevin.console-font;
in

{
  options = {
    hardware.kevin.console-font = with lib; {
      fontfile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = ''
          Path to ttf font to be used as the console font.
        '';
        example = ''
        ''${pkgs.source-code-pro}/share/fonts/opentype/SourceCodePro-Regular.otf
      '';
      };

      dpi = mkOption {
        type = types.int;
        default = 192;
        description = ''
          DPI to render console font at.
        '';
      };

      ptSize = mkOption {
        type = types.int;
        default = 9;
        description = ''
          Font size in points of console font.
        '';
      };
    };
  };

  config = lib.mkIf (cfg.fontfile != null) {
    boot.earlyVconsoleSetup = true;

    i18n.consoleFont = toString (pkgs.ttf-console-font {
      inherit (cfg) fontfile dpi ptSize;
    });
  };
}
