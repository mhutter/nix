{ pkgs, ... }:
{
  home.packages = with pkgs; [
    kubectl
    kubernetes-helm
    kubeconform
  ];

  programs.kubecolor = {
    enable = true;
  };

  programs.zsh.shellAliases = {
    k = "${pkgs.kubecolor}/bin/kubecolor";
    ka = "k --as=cluster-admin";
    kubens = "k config set-context --current --namespace";
    kcs = "k create secret --dry-run=client -o yaml";
    kconf = (
      "kubeconform -verbose -summary -strict "
      + "-schema-location default "
      + "-schema-location 'https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/{{.NormalizedKubernetesVersion}}/{{.ResourceKind}}.json' "
      + "-schema-location 'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json'"
    );
  };
  programs.zsh.initContent = ''
    # Fix completions for kubecolor aliases
    compdef kubecolor=kubectl

    # Add `cluster` command
    cluster() { cp ~/.config/kubeconfigs/"$1" ~/.kube/config }
    _cluster() { _files -W ~/.config/kubeconfigs -/; }
    compdef _cluster cluster

    function k-decode-secret() {
      kubectl get secret $@ -o json | jq '.data | map_values(@base64d)'
    }
  '';
}
