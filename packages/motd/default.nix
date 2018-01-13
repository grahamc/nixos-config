{ runCommand, ncurses }:
runCommand "motd-massive" {
  buildInputs = [ ncurses ];
}
  ''
    ${./motd.sh} > $out
  ''
