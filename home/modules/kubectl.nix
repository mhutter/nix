{ pkgs, ... }:
{
  home.packages = with pkgs; [
    kind
    kubectl
    kubelogin-oidc # kubectl oidc-login
    kubernetes-helm
    openshift # oc
  ];

  programs.kubecolor = {
    enable = true;
  };

  programs.zsh.shellAliases = {
    k = "${pkgs.kubecolor}/bin/kubecolor";
    ka = "k --as=cluster-admin";
    kubens = "k config set-context --current --namespace";
  };
  programs.zsh.initExtra = ''
    # Fix completions for kubecolor aliases
    compdef kubecolor=kubectl

    # Add `cluster` command
    cluster() { cp ~/.config/cattledog/kubeconfigs/"$1" ~/.kube/config }
    _cluster() { _files -W ~/.config/cattledog/kubeconfigs -/; }
    compdef _cluster cluster

    display-secret() {
      kubectl get secret "$1" -o json | jq '.data | map_values(@base64d)'
    }
  '';
}
