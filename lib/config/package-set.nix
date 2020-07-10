let

systemPkgs = import <nixpkgs> {};

in

import (systemPkgs.fetchFromGitHub {
  owner = "nixos";
  repo = "nixpkgs-channels";
  rev = "1d8018068278a717771e9ec4054dff1ebd3252b0";
  sha256 = "1vi3wbvlvpd4200swd3594vps1fsnd7775mgzm3nnfs1imzkg00i";
}) {}
