{ config, pkgs, lib, ... }:

let
  fishPath = "${config.home.profileDirectory}/bin/fish";
in

{
  home.activation.setFishAsDefaultShell = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if ! grep -qx "${fishPath}" /etc/shells; then
      echo "Adding ${fishPath} to /etc/shells"
      echo "${fishPath}" | /usr/bin/sudo tee -a /etc/shells
    fi

    if [ "$SHELL" != "${fishPath}" ]; then
      echo "Changing shell to ${fishPath}"
      /usr/bin/chsh -s "${fishPath}" "$USER"
    fi
  '';
}
