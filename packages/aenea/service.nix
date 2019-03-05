{ pkgs, lib, ... }: {
  systemd.user.services."aenea" = {
    description = "DNS Aenea";

    serviceConfig = {
      ExecStart = ''${pkgs.ip2unix}/bin/ip2unix -r in,path=''${XDG_RUNTIME_DIR}/aenea.sock ${pkgs.aenea}/server.py'';
    };
  };

  systemd.user.services."dragon" = {
    description = "DNS";

    path = with pkgs; [ qemu cdrkit netcat ];

    script = let
        opts = [
          "user"
          "ipv4=on"
          "ipv6=off"
          "restrict=on"
          "guestfwd=tcp:10.0.2.43:8240-cmd:nc -N -U $XDG_RUNTIME_DIR/aenea.sock"
        ];
      in ''
        export QEMU_AUDIO_DRV="pa"

        (
            rm -rf /tmp/cdr
            cp -r ~/windows10 /tmp/cdr
            cd /tmp/cdr
            genisoimage -v -J -r -V CONFIG -o /tmp/config.iso .
        )

        if true; then
            # fast
            echo "Running in unsafe mode"
            cache=unsafe
        else
            # safe
            echo "Running in safe mode"
            cache=writeback
        fi

        qemu-system-x86_64 \
            -enable-kvm \
            -cpu host \
            -smp cpus=4,cores=4,threads=1,sockets=1 \
            -m 4096 \
            -device ide-drive,bus=ide.1,drive=C \
            -drive id=C,cache=$cache,if=none,file=/dev/rpool/windows10,format=raw \
            -device ide-drive,bus=ide.0,drive=config \
            -drive id=config,if=none,snapshot=on,media=cdrom,file=/tmp/config.iso \
            -vnc 127.0.0.1:0 \
            -uuid 883d6155-9dea-42c7-94bf-a123cb71c3cd \
            -soundhw hda \
            -device hda-micro \
            -nic "${lib.concatStringsSep "," opts}"

      '';
  };

}
