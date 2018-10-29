{ runCommand, python3 }:
runCommand "systemd-lock-handler" {
  # locker.py is from
  # https://github.com/grawity/code/blob/master/desktop/systemd-lock-handler
  # with my own patches to remove the need for an XDG_SESSION_ID.
  buildInputs = [
    (python3.withPackages (ps: with ps; [ dbus-python pygobject3 ]))
  ];
  }
''
    cp ${./locker.py} ./locker.py
    chmod 777 ./locker.py
    patchShebangs ./locker.py
    cp ./locker.py $out
  ''
