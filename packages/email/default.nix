{ mutate, gnupg, coreutils, notmuch, isync, findutils, gnused,
  gnugrep, lib, pass, timeout_tcl }:
{
  mbsyncrc = mutate ./mbsyncrc {
    inherit pass;
  };

  msmtprc = mutate ./msmtprc {
    inherit pass;
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
