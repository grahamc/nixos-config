# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let
  secrets = import /etc/nixos/secrets.nix;
in {
  nixpkgs = {
    config = {
      allowUnfree = true;
    };
    overlays = [
      (import ./packages/overlay.nix)
    ];
  };

  imports =
    [
      ./hardware-configuration.nix
      ./packages/services.nix
    ];

  boot = {
    # Busted sometime
    # initrd.preDeviceCommands = "cat ${pkgs.motd-massive}";
    kernelParams = [ "acpi_rev_override=5" ];
    kernel.sysctl = {
      "net.ipv6.conf.all.use_tempaddr" = 2;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking.hostName = "Morbo"; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.firewall.allowedUDPPortRanges = [ { from = 32768; to = 61000; } ];
  networking.extraHosts = ''
    # 127.0.0.1 www.facebook.com facebook.com
  '';

  hardware = {
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
    consoleFont = "latarcyrheb-sun32";
    consoleKeyMap = "dvorak";
  };

  time.timeZone = secrets.timezone;
  security.pam.services.lightdm.enableKwallet = true;

  environment = {
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
      ghc
     ];

    etc."i3/config".source = pkgs.i3config;
    etc."xdg/autorandr".source = pkgs.autorandr-configs;
  };

  powerManagement.powertop.enable = true;
  powerManagement.cpuFreqGovernor = "powersave";

  services = {
    autorandr.enable = true;

    openssh = {
      enable = true;
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
      videoDrivers = [ "nvidia" ];

      libinput = {
        enable = true;
        naturalScrolling = true;
        disableWhileTyping = true;
      };


      displayManager.lightdm.enable = true;

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
      unifont
      ttf_bitstream_vera
      noto-fonts
      noto-fonts-emoji
      fira
      fira-mono
      fira-code
    ];
  };

  programs = {
    zsh.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  users.extraUsers.grahamc = rec {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "pcscd" "networkmanager" ];
    createHome = true;
    home = "/home/grahamc";
    shell = "/run/current-system/sw/bin/zsh";
    hashedPassword = secrets.hashedPassword;
    symlinks = {
      ".zshrc" = pkgs.direnv-hook;
      ".background-image" = "${pkgs.nixos-artwork.wallpapers.gnome-dark}/share/artwork/gnome/Gnome_Dark.png";
      ".mbsyncrc" = pkgs.email.mbsyncrc;
      ".msmtprc" = pkgs.email.msmtprc;
      ".notmuch-config" = pkgs.email.notmuch-config;
      ".gitconfig" = pkgs.gitconfig;
      ".gnupg/gpg.conf" = pkgs.gnupgconfig.gpgconf;
      ".gnupg/scdaemon.conf" = pkgs.gnupgconfig.scdaemonconf;
      ".mail/grahamc/.notmuch/hooks/pre-new" = pkgs.email.pre-new;
      ".mail/grahamc/.notmuch/hooks/post-new" = pkgs.email.post-new;
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
  };
  programs.dconf.enable = true;
  services.dbus.packages = [ pkgs.gnome3.dconf ];

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.09";

  systemd.services.autorandr = {
    path = [ pkgs.xorg.xrandr ];
    # Sometimes I need to run this by hand, and I use:
    # XDG_CONFIG_DIRS=/etc/xdg autorandr -c --force
    serviceConfig.Environment = "XDG_CONFIG_DIRS=/etc/xdg";
  };

  virtualisation.virtualbox.host.enable = true;
  virtualisation.docker.enable = true;
}
