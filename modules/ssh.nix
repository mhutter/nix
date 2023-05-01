{ pkgs, ... }:

{
  home.packages = [
    (pkgs.writeShellScriptBin "ssh" ''
      TERM=xterm-256color ${pkgs.openssh}/bin/ssh -t $@ "tmux -2 new-session -A -s mh || bash"
    '')
  ];

  programs.ssh = {
    enable = true;

    controlMaster = "auto";
    controlPath = "~/.ssh/%C";
    forwardAgent = false;
    hashKnownHosts = true;

    extraConfig = ''
      AddKeysToAgent yes

      # Disable unused features
      ForwardX11 no
      ForwardX11Trusted no

      # Disable unused authentication methods
      GSSAPIAuthentication no
      HostbasedAuthentication no

      # Harden cryptography
      Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
      KexAlgorithms sntrup761x25519-sha512@openssh.com,curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,diffie-hellman-group-exchange-sha256
      MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,umac-128-etm@openssh.com
      HostKeyAlgorithms ssh-ed25519,ssh-ed25519-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,sk-ssh-ed25519-cert-v01@openssh.com,rsa-sha2-256,rsa-sha2-256-cert-v01@openssh.com,rsa-sha2-512,rsa-sha2-512-cert-v01@openssh.com
    '';

    includes = [
      "~/.ssh/sshop_config"
      "~/.ssh/vshn_config"
    ];
    matchBlocks = {
      "monitoring" = {
        hostname = "10.42.0.2";
        forwardAgent = true;
      };
      "rasputin" = {
        user = "mhutter";
      };
      "bastion" = {
        port = 7713;
        hostname = "bastion.tail896c4.ts.net";
      };
    };
  };

  programs.zsh.initExtra = ''
    # SSH-Agent
    if ! pgrep -u "$USER" ssh-agent >/dev/null; then
      ${pkgs.openssh}/bin/ssh-agent -t 12h > "$XDG_RUNTIME_DIR/ssh-agent.env"
    fi
    if [[ ! "$SSH_AGENT_SOCK" ]]; then
      source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
    fi
  '';
}
