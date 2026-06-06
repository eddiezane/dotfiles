# Kubernetes + container-registry tooling.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    kubectl
    kubectx
    helm
    kind
    k3d
    k9s
    skopeo   # OCI image transport / inspect / copy
  ];
}
