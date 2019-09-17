# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let
  root = ../..;
  secrets = import "${root}/secrets.nix";
in {
  nixpkgs = {
    system = "x86_64-linux";
    config = {
      allowUnfree = true;
    };
    overlays = [
      (import ../../packages/overlay.nix { inherit secrets; })
    ];
  };

  imports =
    [
      ./hardware-configuration.nix
      ../../packages/services.nix
      (import ./wireguard-ensure.nix { inherit secrets; })
    ];

  boot = {
    earlyVconsoleSetup = true;
    kernelParams = [ "acpi_rev_override=5" ]; # "acpi_rev_override=1" "pcie_port_pm=off"
    kernel.sysctl = {
      "net.ipv6.conf.all.use_tempaddr" = 2;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot = {
        enable = true;
        signed = false;
        signing-key = secrets.secure-boot.key;
        signing-certificate = secrets.secure-boot.certificate;
      };
      efi.canTouchEfiVariables = true;
    };

    cleanTmpDir = true;
  };

  networking.hostName = "Petunia"; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.networkmanager.dispatcherScripts = [{
    source = pkgs.writeScript "up-fix-wireguard" ''
      #!/bin/sh

      PATH=$PATH:${pkgs.wireguard}/bin

      if [ "$2" != "up" ]; then
        exit
      fi

      if [ "$CONNECTION_ID" = "Bearrocscir" ]; then
        echo "internal"
        wg set wg0 peer gNU592zxr8y+kuaH3+aGuwEhRmwA+FFoBckOATFr7U0= endpoint 10.5.3.105:41741
      else
        echo "external"
        wg set wg0 peer gNU592zxr8y+kuaH3+aGuwEhRmwA+FFoBckOATFr7U0= endpoint lord-nibbler.gsc.io:41741
      fi
    '';
  }];

  networking.extraHosts = ''
    127.0.0.1 www.facebook.com facebook.com x.facebook.com
  '';

  networking.nameservers = [ "4.2.2.2" "4.2.2.3" ];

  hardware = {
    kevin.console-font = {
      fontfile = ../../ComicSans.otf;
      ptSize = 8;
    };
    opengl = {
      enable = true;
      # extraPackages = [ pkgs.libGL ];
    };
    u2f.enable = true;
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
    };
    mcelog.enable = true;
    bluetooth = {
      enable = true;
      extraConfig = ''
        [general]
        Enable=Source,Sink,Media,Socket
      '';
    };
  };

  i18n = {
    # consoleFont = "latarcyrheb-sun32";
    consoleKeyMap = "dvorak";
    # defaultLocale = "fr_FR.UTF-8";
  };

  time.timeZone = secrets.timezone;
  security.pam.services.lightdm.enableKwallet = true;

  environment = {
    variables = {
      EDITOR = "emacs -nw";
      MOZ_ENABLE_WAYLAND = "1";
      XCURSOR_PATH = [ "${pkgs.gnome3.adwaita-icon-theme}/share/icons" ];
    };
    systemPackages = with pkgs; [
      git
      file
      gnupg
      firefox
      google-chrome
      xclip
      custom-emacs
      ripgrep
      nixpkgs-maintainer-tools
      pass
      slack
      direnv
      h
      gnome3.evolution
    ];

    etc."sway/config".source = lib.mkForce pkgs.swayconfig;

    # Wacky erase-root-on-every-boot stuff.
    etc."NetworkManager/system-connections".source = "/rpool/persist/etc/NetworkManager/system-connections/";
  };

  powerManagement.powertop.enable = true;
  powerManagement.cpuFreqGovernor = "powersave";

  services = {
    avahi = {
      enable = true;
    };
    znapzend = {
      enable = true;
      autoCreation = true;
      pure = true;
      zetup.rpool = {
        enable = true;
        plan = "1d=>1h,1m=>1d,1y=>1m";
        recursive = true;
        timestampFormat = "%Y-%m-%d--%H%M%SZ";
        mbuffer.enable = true;
        destinations.ogden = {
          host = "ogden";
          dataset = "mass/${config.networking.hostName}";
        };
      };
    };

    gnome3.evolution-data-server.enable = true;
    gnome3.gnome-keyring.enable = true; # for Evolution
    openssh = {
      enable = true;
    };

    emacs = {
      enable = true;
      package = pkgs.custom-emacs;
    };

    redshift = {
      enable = true;
      latitude = secrets.latitude;
      longitude = secrets.longitude;
      temperature.night = 3400;
      extraOptions = [ "-m" "wayland" ];
    };
  };


  fonts = {
    enableFontDir = true;
    fonts = with pkgs; [
      powerline-fonts
      source-code-pro
      twemoji-color-font

      # Consider just symbola instead of noto-*
      noto-fonts
      noto-fonts-extra
      noto-fonts-emoji
      noto-fonts-cjk

      helvetica
      vegur # the official NixOS font
    ];
  };

  programs = {
    light.enable = true;
    sway.enable = true;
    zsh.enable = true;
    zsh.interactiveShellInit = ''
      eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
      if [ "$(cat "''${XDG_CACHE_HOME:-$HOME/.cache}/shell-warning/"* | wc -l)" -gt 0 ]; then
           cat ${../../warning}
           for f in "''${XDG_CACHE_HOME:-$HOME/.cache}/shell-warning/"*; do
             printf "\n\n\n";
             cat "$f";
           done
           printf "\n\n\n";
           echo " ^^^ go fix those before your computer breaks ^^^"
      fi
    '';
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    ssh.extraConfig = ''
      Host rpi1-0
      User root
      HostName 10.5.5.106
      ProxyCommand ssh grahamc@10.5.3.1 nc %h %p
      IdentitiesOnly yes
      IdentityFile /rpool/persist/private/root/rpi

      Host rpi1-1
      User root
      HostName 10.5.5.107
      ProxyCommand ssh grahamc@10.5.3.1 nc %h %p
      IdentitiesOnly yes
      IdentityFile /rpool/persist/private/root/rpi

    '';
  };

  users.mutableUsers = false;
  users.users.root.hashedPassword = secrets.hashedPassword;

  users.users.root.symlinks = {
    ".aws" = "/rpool/persist/private/root/aws";
  };
  users.users.grahamc = rec {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "pcscd" "networkmanager" "video" "vboxusers" ];
    createHome = true;
    home = "/home/grahamc";
    shell = "/run/current-system/sw/bin/zsh";
    hashedPassword = secrets.hashedPassword;
    symlinks = {
      ".bashrc" = pkgs.bash-config;
      ".zshrc" = pkgs.zsh-config;
      ".background-image" = "${pkgs.nixos-artwork.wallpapers.gnome-dark}/share/artwork/gnome/nix-wallpaper-simple-dark-gray_bottom.png";
      ".gitconfig" = pkgs.gitconfig;
      ".gnupg/gpg.conf" = pkgs.gnupgconfig.gpgconf;
      ".gnupg/scdaemon.conf" = pkgs.gnupgconfig.scdaemonconf;
      ".mozilla/native-messaging-hosts/passff.json" = "${pkgs.passff-host}/share/passff-host/passff.json";
    } // (if (builtins.pathExists "${home}/projects/nixpkgs") then {
      "projects/nixpkgs/.git/hooks/pre-push" = pkgs.nixpkgs-pre-push;
      "projects/nix/.git/hooks/pre-push" = pkgs.nixpkgs-pre-push;
    } else {});
  };

  nix = {
    useSandbox = true;
    distributedBuilds = true;
    buildMachines = secrets.buildMachines;
    nixPath = [
      "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
      "nixos-config=${toString root}/devices/petunia/configuration.nix"
    ];

    extraOptions = let
      diffWrapper = pkgs.writeScript "diff-wrapper"
            ''
              #! ${pkgs.stdenv.shell}
              exec >&2

              ls -la "$1"
              ls -la "$2"
              ls -la "$3"
              ls -la "$4"
              ls -la /nix
              ${pkgs.utillinux}/bin/mount
              ${pkgs.coreutils}/bin/whoami
              ${pkgs.coreutils}/bin/groups

              echo "For derivation $3:"
              ${pkgs.diffutils}/bin/diff -r "$1" "$2"
              exit 0
            '';
    in ""; /*''
      #diff-hook = ${diffWrapper}
      #run-diff-hook = true
      #post-build-hook = ${./upload-to-cache.sh}
    '';*/

    binaryCaches = [
      https://cache.nixos.org/
      s3://example-nix-cache?region=eu-west-2
    ];
    binaryCachePublicKeys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "example-nix-cache:1/cKDz3QCCOmwcztD2eV6Coggp6rqc9DGjWv7C0G+rM=" # 2019-07-10
      "example-nix-cache:GnyIc3QRFKI417xj663gaw0HpctZN/ghBjz//b6qrBs=" # 2019-07-14
    ];
    gc = {
      automatic = true;
      dates = "*:0/10";
    };
  };

  systemd.coredump.enable = true;
  systemd.user.services.swayidle = {
    enable = true;
    description = "swayidle locking";
    requiredBy = [ "graphical-session.target" ];
    unitConfig = {
      PartOf = [ "graphical-session.target" ];
      ConditionGroup = "users";
    };

    path = with pkgs; [ bash strace swayidle swaylock sway ];
    script = ''
      swayidle -w \
         timeout 150 'swaylock -elfF -s fill -i ${../../nixos-nineish.png}' \
         timeout 300 'swaymsg "output * dpms off"' \
         resume 'swaymsg "output * dpms on"' \
         before-sleep 'swaylock -elfF -s fill -i ${../../nixos-nineish.png}'
    '';
  };

  systemd.services.nix-gc.unitConfig.ConditionACPower = true;

  programs.dconf.enable = true;
  services.dbus.packages = [ pkgs.gnome3.dconf ];

  programs.zsh.promptInit = ''
    # Lifted from programs.bash.promptInit
    # Provide a nice prompt if the terminal supports it.
    if [ "$TERM" != "dumb" -o -n "$INSIDE_EMACS" ]; then
      PROMPT_COLOR="red"
      let $UID && PROMPT_COLOR="green"

      PS1=$'\n'"%B%F{$PROMPT_COLOR}[%n@%m:%~]$%f%b "
      if test "$TERM" = "xterm"; then
        PS1="$'\n'[%n@%m:%~]$ "
      fi
    fi
  '';

  # The NixOS release to be compatible w/ for stateful data such
  system.stateVersion = "18.09";

  # Only start emacs for actual users, lol
  systemd.user.services.emacs.unitConfig = {
    ConditionGroup = "users";
  };

  #virtualisation.virtualbox.host.enable = true;
  #virtualisation.virtualbox.host.enableExtensionPack = true;
  #virtualisation.docker.enable = true;

  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplip ];

  services.zfs.autoScrub.enable = true;
  services.zfs.autoScrub.interval = "weekly";
  systemd.services.zfs-scrub.unitConfig.ConditionACPower = true;
  hardware.cpu.intel.updateMicrocode = true;
}
