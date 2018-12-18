{ runCommand, secrets }:
runCommand "helvetica" {}
''
  mkdir -p $out/share/fonts
  cp ${secrets.helvetica_location} $out/share/fonts
''
