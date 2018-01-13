{ mutate, expect }:
mutate ./timeout.tcl {
  inherit expect;
}
