# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let
  root = /home/grahamc/projects/grahamc/nixos-config;
  secrets = import "${root}/secrets.nix";
in {
  nixpkgs = {
    system = "x86_64-linux";
    config = {
      allowUnfree = true;
    };
    overlays = [
      (import ./packages/overlay.nix { inherit secrets; })
    ];
  };

  imports =
    [
      ./hardware-configuration.nix
      ./packages/services.nix
    ];

  boot = {
    kernelParams = [ "acpi_rev_override=5" ]; # "acpi_rev_override=1" "pcie_port_pm=off"
    kernel.sysctl = {
      "net.ipv6.conf.all.use_tempaddr" = 2;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot = {
        enable = true;
        signed = true;
        signing-key = secrets.secure-boot.key;
        signing-certificate = secrets.secure-boot.certificate;
      };
      efi.canTouchEfiVariables = true;
    };

    cleanTmpDir = true;
  };

  networking.hostName = "Morbo"; # Define your hostname.
  networking.networkmanager.enable = true;

  networking.extraHosts = ''
    127.0.0.1 www.facebook.com facebook.com x.facebook.com
  '';

  hardware = {
    u2f.enable = true;
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
    };
    mcelog.enable = true;
    nvidiaOptimus.disable = true;
    bluetooth = {
      enable = true;
      extraConfig = ''
        [general]
        Enable=Source,Sink,Media,Socket
      '';
    };
  };

  i18n = {
    consoleFont = "latarcyrheb-sun32";
    consoleKeyMap = "dvorak";
  };

  time.timeZone = secrets.timezone;
  security.pam.services.lightdm.enableKwallet = true;

  environment = {
    variables = {
      EDITOR = "emacs -nw";
    };
    systemPackages = with pkgs; [
      git
      file
      gnupg
      (if false then firefox-devedition-bin else firefox)
      google-chrome
      xclip
      custom-emacs
      ripgrep
      nixpkgs-maintainer-tools
      pass
      slack
      direnv
      h
    ];

    etc."i3/config".source = pkgs.i3config;
    etc."xdg/autorandr".source = pkgs.autorandr-configs;

    # Wacky erase-root-on-every-boot stuff.
    etc."NetworkManager/system-connections".source = "/rpool/persist/etc/NetworkManager/system-connections/";
  };

  powerManagement.powertop.enable = true;
  powerManagement.cpuFreqGovernor = "powersave";

  services = {
    autorandr.enable = true;

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
    };

    xserver = {
      enable = true;
      autorun = true;
      layout = "dvorak";
      xkbOptions = "compose:ralt";
      libinput = {
        enable = true;
        naturalScrolling = true;
        disableWhileTyping = true;
      };

      displayManager.lightdm.enable = true;
      desktopManager.default = "none";
      windowManager.default = "i3";
      windowManager.i3 = {
        enable = true;
        configFile = "/etc/i3/config";
      };

      inputClassSections = [
        ''
          Identifier "libinput touchscreen catchall"
          MatchIsTouchscreen "on"
          MatchDevicePath "/dev/input/event*"
          Driver "libinput"
          Option "DisableWhileTyping" "true"
        ''

        ''
          Identifier "yubikey"
          MatchIsKeyboard "on"
          MatchProduct "Yubikey"
          Option "XkbLayout" "us"
        ''
      ];

      monitorSection = ''
        Modeline "1920x1080_60.00"  173.00  1920 2048 2248 2576  1080 1083 1088 1120 -hsync +vsync
        Option "PreferredMode" "1920x1080_60.00"
        DisplaySize 345 191
      '';
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
      font-b612
    ];
  };

  programs = {
    zsh.enable = true;
    zsh.interactiveShellInit = ''
      eval "$(${pkgs.direnv}/bin/direnv hook zsh)"
      if [ "$(cat "''${XDG_CACHE_HOME:-$HOME/.cache}/shell-warning/"* | wc -l)" -gt 0 ]; then
           cat ${./warning}
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
  };

  users.mutableUsers = false;
  users.users.root.hashedPassword = secrets.hashedPassword;

  users.users.grahamc = rec {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "pcscd" "networkmanager" ];
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
      "nixos-config=${toString root}/configuration.nix"
    ];

    gc = {
      automatic = true;
      dates = "*:0/10";
    };
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

  systemd.services.autorandr = {
    path = [ pkgs.xorg.xrandr ];
    # Sometimes I need to run this by hand, and I use:
    # XDG_CONFIG_DIRS=/etc/xdg autorandr -c --force
    serviceConfig.Environment = "XDG_CONFIG_DIRS=/etc/xdg";
  };

  #virtualisation.virtualbox.host.enable = true;
  virtualisation.docker.enable = true;


  services.printing.enable = true;
  services.printing.drivers = [ pkgs.gutenprint pkgs.gutenprintBin ];

  services.zfs.autoScrub.enable = true;
  services.zfs.autoScrub.interval = "weekly";
  systemd.services.zfs-scrub.unitConfig.ConditionACPower = true;
  hardware.cpu.intel.updateMicrocode = true;
}
