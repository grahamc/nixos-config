{ mutate, bash, git, coreutils }:
mutate ./pre-push {
  inherit bash git coreutils;
}
