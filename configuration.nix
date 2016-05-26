# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  mypkgs = import ./packages { inherit pkgs; };
in {
  imports =
    [
      ./hardware-configuration.nix
      ./yubikey.nix
      ./openvpn.nix
      ./desktop-i3.nix
      #./desktop-gnome.nix
    ];

  # Use the gummiboot efi boot loader.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.gummiboot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use privacy-protecting IPv6 address generation
  boot.kernel.sysctl = {
    "net.ipv6.conf.all.use_tempaddr" = 2;
  };

  boot.initrd.luks.devices = [
    {

      device = "/dev/sda4";
      name = "cryptedroot";
    }
  ];
  boot.kernelParams = [
   "libata.force=noncq"
  ];

  networking.hostName = "NdNdNx";

  # Select internationalisation properties.
  i18n = {
    consoleFont = "sun12x22";
    consoleKeyMap = "dvorak";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
     acpi
     pciutils

     vlc
     ffmpeg
     openh264
     file
     docker
     gnupg
     aspell
     aspellDicts.en
     gitRepo
     wine
     git
     chromium
     emacs24
     spotify
     dropbox
     scrot
     xclip
     thunderbird-bin

     terminator

  ];

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Enable CUPS to print documents.
  # This never worked.
  # services.printing.enable = true;
  # services.printing.drivers = [ pkgs.gutenprint ];

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    autorun = true;
    layout = "dvorak";
    xkbVariant = "mac";
    xkbOptions = "terminate:ctrl_alt_bksp, ctrl:nocaps";
    videoDrivers = [ "nvidia" ];
    vaapiDrivers = [ pkgs.vaapiIntel ];

    monitorSection = ''
      DisplaySize 381 238
    '';

    screenSection = ''
      Option "DPI" "192 x 192"
      Option "NoLogo" "TRUE"
    
      Option         "nvidiaXineramaInfoOrder" "DFP-5"
      Option         "metamodes" "DP-2: 2880x1800 +0+0, DP-4: nvidia-auto-select +2880+0 {viewportin=5120x2880}; DP-2: nvidia-auto-select +0+0 {viewportin=1680x1050}"
    '';

    synaptics = {
      enable = true;
      tapButtons = false;
      fingersMap = [ 0 0 0 ];
      buttonsMap = [ 1 3 2 ];
      twoFingerScroll = true;
      vertEdgeScroll = false;
      accelFactor = "0.002";

      additionalOptions = ''
        Option "VertScrollDelta" "-100"
        Option "HorizScrollDelta" "-100"
      '';
    };
  };

  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.enable = true;
  hardware.facetimehd.enable = true;



  networking.networkmanager.enable = true;


  services.logind.extraConfig = ''
    HandlePowerKey=suspend
  '';
  services.upower.enable = true;

  services.redshift = {
    enable = true;
    latitude = "30.25";
    longitude = "-97.75";
    temperature.night = 1900;
  };

  fonts = {
    enableFontDir = true;
    fonts = with pkgs; [
      unifont
      ttf_bitstream_vera
      noto-fonts-emoji
    ];
  };

  networking.extraHosts = ''
  104.178.175.4  sc
  '';

  programs.zsh.enable = true;


  users.mutableUsers = false;
  users.extraUsers.root.passwordFile = "/etc/nixos/user-root-passwordfile";
  users.extraUsers.grahamc = {
    isNormalUser = true;
    name = "grahamc";
    uid = 1000;
    passwordFile = "/etc/nixos/user-grahamc-passwordfile";
    extraGroups = [ "wheel" "docker" ];
    createHome = true;
    home = "/home/grahamc";
    shell = "/run/current-system/sw/bin/zsh";
  };

  nixpkgs.config.chromium = {
    # hiDPISupport = true;
    enableWideVine = true;
    enablePepperFlash = true;
 };

  systemd.services.backlight-control = {
    wantedBy = [ "multi-user.target" "post-resume.target" ];
    after = [ "multi-user.target" "post-resume.target" ];
    serviceConfig.Type = "oneshot";

    serviceConfig.ExecStart = "${pkgs.pciutils}/bin/setpci -v -H1 -s 00:01.00 BRIDGE_CONTROL=0";
  };

  systemd.services.disable-usb-wakeup = {
    wantedBy = [ "multi-user.target" "post-resume.target" ];
    after = [ "multi-user.target" "post-resume.target" ];
    serviceConfig.Type = "oneshot";

    serviceConfig.script = ''
      if ${pkgs.gnugrep}/bin/grep -q '\bXHC1\b.*\benabled\b' /proc/acpi/wakeup; then
        echo XHC1 > /proc/acpi/wakeup
      fi
    '';
  };
  
  systemd.services.monitor-hotplug = {
    wantedBy = [ "default.target" ];
    after = [ "graphical.target" ];
    enable = true;
    description = "Handle monitor hot-plugging";

    environment = {
        XAUTHORITY = "/home/grahamc/.Xauthority"; # Use %h and a user-service somehow
        DISPLAY = ":0";
    };

    serviceConfig = {
      RestartSec = 5;
      ExecStart = "${mypkgs.monitor-hotplug}/bin/monitor-hotplug  --delay 15 --side right --primary DP-2";
    };
  };

  systemd.user.services.emacs = {
    enable = true;
    description = "Emacs Daemon";
    environment = {
      GTK_DATA_PREFIX = config.system.path;
      SSH_AUTH_SOCK = "%t/ssh-agent";
      GTK_PATH = "${config.system.path}/lib/gtk-3.0:${config.system.path}/lib/gtk-2.0";
      NIX_PROFILES = "${pkgs.lib.concatStringsSep " " config.environment.profiles}";
      TERMINFO_DIRS = "/run/current-system/sw/share/terminfo";
      ASPELL_CONF = "dict-dir /run/current-system/sw/lib/aspell";
    };

    serviceConfig = {
      Type = "forking";
      ExecStart = "${pkgs.emacs}/bin/emacs --daemon";
      ExecStop = "${pkgs.emacs}/bin/emacsclient --eval (kill-emacs)";
      Restart = "always";
    };

    wantedBy = [ "default.target" ];
  };



  virtualisation.docker.enable = true;
  nix = {
    useChroot = true;
  };

  nixpkgs.config.allowUnfree = true;

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "15.09";
}
