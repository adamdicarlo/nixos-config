{
  pkgs,
  lib,
  inputs,
  system,
  ...
}: let
  mkNixGLWrapper =
    # Based on https://github.com/nix-community/nixGL/issues/44#issuecomment-1182548777 and further comments
    cmd: pkg:
      pkgs.runCommand "${pkg.name}-nixgl-wrapper" {} ''
        mkdir $out
        ln -s ${pkg}/* $out
        rm $out/bin
        mkdir $out/bin
        for bin in ${pkg}/bin/*; do
          wrapped_bin=$out/bin/$(basename $bin)
          echo "exec ${lib.getExe' inputs.nixgl.outputs.packages.${system}.${cmd} "nixGL"} \"$bin\" \"\$@\"" > $wrapped_bin
          chmod +x $wrapped_bin
        done
      '';
in {
  gl = mkNixGLWrapper "nixGLIntel";
  vulkan = mkNixGLWrapper "nixVulkanIntel";
}
