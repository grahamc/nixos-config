# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let
  root = ../..;
  secrets = import "${root}/secrets.nix";
in
{
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
      ./vault.nix
    ];

  console = {
    earlySetup = true;
    keyMap = "dvorak";
  };
  boot = {

    kernelParams = [
      "acpi_rev_override=5" # "acpi_rev_override=1" "pcie_port_pm=off"
    ] ++ (if config.virtualisation.docker.enable then [] else [ "cgroup_no_v1=all" "systemd.unified_cgroup_hierarchy=yes" ]);
    kernel.sysctl = {
      #"net.ipv6.conf.all.use_tempaddr" = 2;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    extraModulePackages = [
      (
        config.boot.kernelPackages.v4l2loopback.overrideAttrs (
          { ... }: {
            src = pkgs.fetchFromGitHub {
              owner = "umlaeute";
              repo = "v4l2loopback";
              rev = "10b1c7e6bda4255fdfaa187ce2b3be13433416d2";
              sha256 = "0xsn4yzj7lwdg0n7q3rnqpz07i9i011k2pwn06hasd45313zf8j2";
            };
          }
        )
      )
    ];
    extraModprobeConfig = ''
      options v4l2loopback exclusive_caps=1 video_nr=9 card_label="obs"
    '';
    loader = {
      systemd-boot = {
        enable = true;
        #signed = false;
        #signing-key = secrets.secure-boot.key;
        #signing-certificate = secrets.secure-boot.certificate;
      };
      efi.canTouchEfiVariables = true;
    };

    cleanTmpDir = true;
  };

  networking.hostName = "Petunia"; # Define your hostname.
  networking.networkmanager.enable = true;
  networking.networkmanager.dispatcherScripts = [
    {
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
    }
  ];
  networking.networkmanager.packages = with pkgs; [
    # gnome3.networkmanager-openconnect
    # grahamc.networkmanager-openconnect
  ];

  networking.extraHosts = ''
    127.0.0.1 www.facebook.com facebook.com x.facebook.com
  '';

  hardware = {
    sane.enable = true;
    #kevin.console-font = {
    #  fontfile = ../../ComicSans.otf;
    #  ptSize = 8;
    #};
    opengl = {
      enable = true;
      # extraPackages = [ pkgs.libGL ];
    };
    # u2f.enable = true;
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      extraModules = [ pkgs.pulseaudio-modules-bt ]; # https://nixos.wiki/wiki/Bluetooth#Enabling_extra_codecs
    };
    mcelog.enable = true;
    bluetooth = {
      enable = true;
      config.general.Enable = "Source,Sink,Media,Socket";
    };
  };
  systemd.tmpfiles.rules = [
    "L /var/lib/bluetooth - - - - /rpool/persist/var/lib/bluetooth"
  ];

  i18n = {
    # consoleFont = "latarcyrheb-sun32";
    # defaultLocale = "fr_FR.UTF-8";
    #
    # # I tried to make ibus work for emoji input, but I never managed to.
    #inputMethod = {
    #  enabled = "ibus";
    #  ibus.engines = with pkgs.ibus-engines; [ uniemoji ];
    #};
  };

  time.timeZone = secrets.timezone;
  security.pam.services.lightdm.enableKwallet = true;

  environment = {
    binsh = "${pkgs.dash}/bin/dash";
    variables = {
      EDITOR = "emacs -nw";
      MOZ_ENABLE_WAYLAND = "1";
      XCURSOR_PATH = lib.mkForce [ "${pkgs.gnome3.adwaita-icon-theme}/share/icons" ];
    };
    systemPackages = with pkgs; [
      git
      gitAndTools.git-absorb
      file
      gnupg
      (grahamc.guiduckAlias "firefox")
      # firefox#-beta-bin
      #google-chrome
      custom-emacs
      ripgrep
      nixpkgs-maintainer-tools
      pass
      #slack
      direnv
      h
      nixpkgs-fmt
    ];

    etc."ipsec.secrets" = {
      mode = "0600";
      text = "";
    };
    etc."sway/config".source = lib.mkForce pkgs.swayconfig;

    # Wacky erase-root-on-every-boot stuff.
    etc."NetworkManager/system-connections".source = "/rpool/persist/etc/NetworkManager/system-connections/";
  };

  powerManagement.powertop.enable = true;
  powerManagement.cpuFreqGovernor = "powersave";

  location = {
    latitude = secrets.latitude;
    longitude = secrets.longitude;
  };

  services = {
    logind.extraConfig = ''
      RuntimeDirectorySize=30%
    '';
    fwupd.enable = true;
    avahi = {
      enable = true;
    };
    kresd = {
      enable = true;
      extraConfig = ''
        verbose(true)
      '';
    };
    znapzend = {
      enable = true;
      autoCreation = true;
      pure = true;
      zetup = let
        localOnlyNotRecursive = {
          enable = true;
          plan = "1hour=>15min,1day=>1hour,4day=>1day,1month=>1week";
          timestampFormat = "%Y-%m-%d--%H%M%SZ";
        };
      in
        {
          "tank/user/home" = {
            enable = true;
            plan = "15min=>5min,4hour=>15min,2day=>1hour,4day=>1day,3week=>1week";
            recursive = true;
            timestampFormat = "%Y-%m-%d--%H%M%SZ";
            destinations.kif = {
              plan = "1hour=>5min,4day=>1hour,1week=>1day,1year=>1week,10year=>1month";
              host = "kif";
              dataset = "rpool/backups/gsc.io/Petunia/home";
            };
          };

          # less robust snapshot techniques
          "tank/system/persist" = localOnlyNotRecursive;
        };
    };

    # gnome3.evolution-data-server.enable = true;
    # gnome3.gnome-keyring.enable = true; # for Evolution
    openssh = {
      enable = true;
    };

    emacs = {
      enable = true;
      package = pkgs.custom-emacs;
    };

    redshift = {
      enable = true;
      temperature.night = 3400;
      extraOptions = [ "-m" "wayland" ];
    };
    # disabled, re-enable for 20.03 so we can use SDDM as a login-manager :)
    # note: this doesn't make sway the default, so that is still a todo.
    #xserver = {
    #  enable = true;
    #  libinput.enable = true;
    #  displayManager.sddm.enable = true;
    #};
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
    ssh = {
      knownHosts.ogden = {
        hostNames = [ "ogden" "10.10.2.15" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHICIvUL8AAPDjwP0wUdYADwWSWBieS8iTgNPVa+fynN";
      };
      knownHosts.kif = {
        hostNames = [ "kif.wg.gsc.io" "kif" "10.10.2.16" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEjBFLoalf56exb7GptkI151ee+05CwvXzoyBuvzzUbK";
      };

      knownHosts.arm = {
        hostNames = [ "147.75.79.198" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDCo+z5d8C6SpCyvC8KAPMAcMEtd5J74tRsk+7sm2KgD";
      };
      extraConfig = ''
        Match User root
          Host 147.75.79.198
          IdentitiesOnly yes
          IdentityFile /rpool/persist/private/root/arm

        Match User root
          Host ogden
          IdentitiesOnly yes
          IdentityFile /rpool/persist/private/root/ogden

        Match User root
          Host kif
          IdentitiesOnly yes
          IdentityFile /rpool/persist/private/root/ogden

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
  };

  users.mutableUsers = false;
  users.users.root.hashedPassword = secrets.hashedPassword;

  users.users.root.symlinks = {
    ".aws" = "/rpool/persist/private/root/aws";
  };
  users.users.grahamc = rec {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "scanner" "lp" "wheel" "pcscd" "networkmanager" "video" "vboxusers" "libvirtd" ];
    createHome = true;
    #home = "/C∶/Documents and Settings/grahamc";
    home = "/home/grahamc";
    shell = pkgs.zsh; # "/run/current-system/sw/bin/zsh";
    hashedPassword = secrets.hashedPassword;
    subUidRanges = [ { count = 65535; startUid = 100000; } ];
    subGidRanges = [ { count = 65535; startGid = 100000; } ];
    symlinks = {
      ".bashrc" = pkgs.bash-config;
      ".zshrc" = pkgs.zsh-config;
      ".background-image" = "${pkgs.nixos-artwork.wallpapers.gnome-dark}/share/artwork/gnome/nix-wallpaper-simple-dark-gray_bottom.png";
      ".gitconfig" = pkgs.gitconfig;
      ".gnupg/gpg.conf" = pkgs.gnupgconfig.gpgconf;
      ".gnupg/scdaemon.conf" = pkgs.gnupgconfig.scdaemonconf;
      ".mozilla/native-messaging-hosts/passff.json" = "${pkgs.passff-host}/share/passff-host/passff.json";
    } // (
      if (builtins.pathExists "${home}/projects/nixpkgs") then {
        "projects/nixpkgs/.git/hooks/pre-push" = pkgs.nixpkgs-pre-push;
        "projects/nix/.git/hooks/pre-push" = pkgs.nixpkgs-pre-push;
      } else {}
    );
  };

  nix = {
    # package = pkgs.grahamc.nixUnstable;
    useSandbox = true;
    distributedBuilds = true;
    buildMachines = secrets.buildMachines;
    nixPath = [
      "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
      "nixos-config=${toString root}/devices/petunia/configuration.nix"
    ];
    # trustedUsers = [ "grahamc" ];
    systemFeatures = [ "recursive-nix" "kvm" "nixos-test" ];
    extraOptions = ''
      experimental-features = recursive-nix
    '';
    gc = {
      automatic = false;
      dates = "*:0/10";
    };
  };

  systemd.user.targets.sway-session = {
    description = "Sway compositor session";
    documentation = [ "man:systemd.special(7)" ];
    bindsTo = [ "graphical-session.target" ];
    wants = [ "graphical-session-pre.target" ];
    after = [ "graphical-session-pre.target" ];
  };

  systemd.user.services.mako = {
    description = "Wayland notification daemon";
    bindsTo = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = ''
        ${pkgs.mako}/bin/mako --group-by app-name,summary --on-button-left dismiss-group
      '';
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  systemd.user.services.guiduck = {
    description = "Guiduck";
    wants = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = ''
        ${pkgs.grahamc.guiduck}/bin/receive \
          --map firefox ${pkgs.firefox}/bin/firefox
      '';
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  systemd.user.services.sway = {
    description = "Sway - Wayland window manager";
    documentation = [ "man:sway(5)" ];
    bindsTo = [ "graphical-session.target" ];
    wants = [ "graphical-session-pre.target" ];
    after = [ "graphical-session-pre.target" ];
    # We explicitly unset PATH here, as we want it to be set by
    # systemctl --user import-environment in startsway
    environment.PATH = lib.mkForce null;
    serviceConfig = {
      Type = "simple";
      ExecStart = ''
        ${pkgs.dbus}/bin/dbus-run-session ${pkgs.sway}/bin/sway --debug
      '';
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  services.lorri.enable = true;
  systemd.user.services.lorri = {
    wantedBy = [ "ac.target" ];
    partOf = [ "ac.target" ];
    unitConfig = {
      ConditionGroup = "users";
      StopWhenUnneeded = true;
    };
  };


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
         timeout 120 '${pkgs.backlight-locker} down' resume '${pkgs.backlight-locker} up' \
         timeout 150 'swaylock -elfF -s fill -i ${../../nixos-nineish.png}' \
         timeout 300 'swaymsg "output * dpms off"' resume 'swaymsg "output * dpms on"' \
         before-sleep 'swaylock -elfF -s fill -i ${../../nixos-nineish.png}'
         lock 'swaylock -elfF -s fill -i ${../../nixos-nineish.png}'
    '';
  };


  # 20.03 beta kres-cache-gc took 20% cpu all the time
  systemd.services.kres-cache-gc.enable = false;
  systemd.timers.nix-gc = {
    wantedBy = [ "ac.target" ];
    partOf = [ "ac.target" ];
    unitConfig = {
      StopWhenUnneeded = true;
    };
  };
  systemd.timers.zfs-scrub = {
    wantedBy = lib.mkForce [ "ac.target" ];
    partOf = [ "ac.target" ];
    unitConfig = {
      StopWhenUnneeded = true;
    };
  };
  systemd.timers.zpool-trim = {
    wantedBy = lib.mkForce [ "ac.target" ];
    partOf = [ "ac.target" ];
    # timerConfig.OnCalendar = config.services.zfs.trim.interval;
    unitConfig = {
      StopWhenUnneeded = true;
    };
  };

  systemd.services.znapzend = {
    wantedBy = lib.mkForce [ "ac.target" ];
    partOf = [ "ac.target" ];
    unitConfig.StopWhenUnneeded = true;
  };

  programs.dconf.enable = true;
  services.dbus.socketActivated = true;
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

  virtualisation.libvirtd = {
    enable = true;
    /*
    this doesn't belong in extraConfig:
    extraConfig = ''
      <pool type="dir">
        <name>default</name>
        <target>
          <path>/var/lib/virt/images</path>
        </target>
      </pool>
    '';
    */
  };
  # virtualisation.virtualbox.host.enable = true; # broken with linux_latest on 2020-09-10_
  # virtualisation.virtualbox.host.enableExtensionPack = true;
  virtualisation.docker = {
    enable = false;
    storageDriver = "zfs";
  };

  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplip ];

  services.zfs.autoScrub.enable = true;
  services.zfs.autoScrub.interval = "weekly";
  hardware.cpu.intel.updateMicrocode = true;
  hardware.printers = {
    ensurePrinters = [
      {
        name = "hp-laserjet";
        description = "HP LaserJet Pro M118dw";
        location = "Home";
        # lpd://10.5.4.134/queue worked, but SLOW
        # socket://10.5.4.134:9100
        deviceUri = "ipp://10.5.4.134/ipp/print";
        model = "HP/hp-laserjet_pro_m118-m119-ps.ppd.gz";
        ppdOptions = {
          PageSize = "Letter";
          Duplex = "DuplexNoTumble";
        };
      }
    ];
  };
}
