{ username, ... }:

{
  users.users.${username}.extraGroups = [ "docker" ];

  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      registry-mirrors = [ "https://dockerhub.vshn.net" ];
    };
  };
}
