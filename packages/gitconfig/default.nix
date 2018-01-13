{ mutate, gnupg }:
mutate ./gitconfig {
  inherit gnupg;

  gitattributes = ./gitattributes;
  gitignore = ./gitignore;
}
