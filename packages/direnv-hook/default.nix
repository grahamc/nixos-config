{ mutate, direnv }:
mutate ./zshrc.local {
  inherit direnv;
}
