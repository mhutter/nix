{ pkgs, ... }:
{
  home.packages = with pkgs; [
    kind
    kubectl
    kubernetes-helm
  ];

  programs.kubecolor = {
    enable = true;
  };

  programs.zsh.shellAliases = {
    k = "${pkgs.kubecolor}/bin/kubecolor";
    ka = "k --as=cluster-admin";
    kubens = "k config set-context --current --namespace";
  };
  programs.zsh.initContent = ''
    # Fix completions for kubecolor aliases
    compdef kubecolor=kubectl

    # Add `cluster` command
    # FIXME: get rid of "cattledog" term
    cluster() { cp ~/.config/kubeconfigs/"$1" ~/.kube/config }
    _cluster() { _files -W ~/.config/kubeconfigs -/; }
    compdef _cluster cluster

    function k-decode-secret() {
      kubectl get secret $@ -o json | jq '.data | map_values(@base64d)'
    }
  '';
}
