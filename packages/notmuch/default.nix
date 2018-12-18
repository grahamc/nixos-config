{ fetchgit, fetchpatch }:
oldAttrs: {
  name = "notmuch-0.27.1";
  # 0.28 + patches for indexed headers
  src = fetchgit {
    url = "git://pivot.cs.unb.ca/notmuch.git";
    rev = "925bb96ae5117be11693f1efd8c7669355303757";
    sha256 = "16f48afs48in3zz0c657xjzpbijdz8gcj743x95yjsqbycgn3w08";
  };
}
