{
  secrets,
  lib,
  pkgs,
  ...
}:

{
  services.ssh-agent.enable = true;

  programs.ssh = {
    enable = true;

    enableDefaultConfig = false; # will be deprecated in the future

    extraConfig = ''
      # Disable unused features
      ForwardX11 no
      ForwardX11Trusted no

      # Disable unused authentication methods
      HostbasedAuthentication no

      # Harden cryptography
      Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
      KexAlgorithms sntrup761x25519-sha512@openssh.com,curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512,diffie-hellman-group-exchange-sha256
      MACs hmac-sha2-256-etm@openssh.com,hmac-sha2-512-etm@openssh.com,umac-128-etm@openssh.com
      HostKeyAlgorithms ssh-ed25519,ssh-ed25519-cert-v01@openssh.com,sk-ssh-ed25519@openssh.com,sk-ssh-ed25519-cert-v01@openssh.com,rsa-sha2-256,rsa-sha2-256-cert-v01@openssh.com,rsa-sha2-512,rsa-sha2-512-cert-v01@openssh.com
    '';

    includes = [
      "~/.ssh/local_config"
    ];
    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
        controlMaster = "auto";
        controlPath = "~/.ssh/%C";
        forwardAgent = false;
      };
    }
    // secrets.sshHosts
    // {
      "source.developers.google.com" = {
        extraOptions = {
          "HostKeyAlgorithms" = "ecdsa-sha2-nistp256";
        };
      };
    };
  };

  programs.zsh.initContent = ''
    function ssh() {
      TERM=xterm-256color ${pkgs.openssh}/bin/ssh -t $@ "tmux -2 new-session -A -s mh || bash"
    }
  '';
}
