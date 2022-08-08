{
  pkgs,
  config,
  lib,
  ...
}: let
  sources = pkgs.callPackage ./generated.nix {};
in
  pkgs.writeShellScript "prepare-alpine" ''
    set -x
    tar -xv -p -f ${sources.rootfs.src}
    cp -av ${./etc}/* etc

    ${lib.concatMapStringsSep "\n" (c: ''
        ${pkgs.bubblewrap}/bin/bwrap \
          --bind $PWD / \
          --uid 0 \
          --gid 0 \
          --setenv PATH /bin:/sbin:/usr/bin:/usr/sbin \
          -- ${c}
      '') [
        "adduser -h ${config.home.homeDirectory} -s /bin/sh -G users -D ${config.home.username}"
        "addgroup ${config.home.username} wheel"
      ]}
    set +x
  ''
