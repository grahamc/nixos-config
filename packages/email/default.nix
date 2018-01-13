{ mutate, gnupg, coreutils, notmuch, isync, findutils, gnused,
  gnugrep, lib, kdeFrameworks, timeout_tcl }:
{
  mbsyncrc = mutate ./mbsyncrc {
    kwallet = kdeFrameworks.kwallet.bin;
  };

  msmtprc = mutate ./msmtprc {
    kwallet = kdeFrameworks.kwallet.bin;
  };

  notmuch-config = mutate ./notmuch-config {
    inherit gnupg;
  };

  pre-new = mutate ./pre-new.sh {
    inherit isync timeout_tcl;
  };

  post-new = mutate ./post-new.sh {
    path = lib.makeBinPath [
      coreutils notmuch isync findutils gnused gnugrep
    ];
  };
}
