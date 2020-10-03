{ resholve, mutate, vim, oil, gzip, coreutils, pstree, jq, utillinux }:
# decode the logs from this via:
# journalctl -t snoopy -o json --output-fields _PID,MESSAGE | jq -rs '. | group_by(._PID) | .[] | [ .[] | .MESSAGE ] | join("") | @base64d'
target:
resholve {
  src = mutate ./snoop.sh {
    buildInputs = [ oil ];
    inherit target oil;
  };

  inputs = [ gzip coreutils jq vim pstree utillinux ];
  allow = { resholved_inputs = [ target ]; };
}
